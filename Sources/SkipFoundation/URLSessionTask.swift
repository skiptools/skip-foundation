// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString

public class URLSessionTask {
    public static let defaultPriority = Float(0.5)
    public static let lowPriority = Float(0.25)
    public static let highPriority = Float(0.75)

    let session: URLSession
    let build: (Request.Builder) -> Void
    private let lock = NSRecursiveLock()
    private let completionHandler: ((Data?, URLResponse?, Error?) -> Void)?

    init(session: URLSession, request: URLRequest, taskIdentifier: Int, build: (Request.Builder) -> Void = {}, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        self.session = session
        self.originalRequest = request
        self.taskIdentifier = taskIdentifier
        self.build = build
        self.completionHandler = completionHandler
    }

    public let taskIdentifier: Int
    public let originalRequest: URLRequest?

    public var countOfBytesClientExpectsToReceive = Int64(-1)
    public var countOfBytesClientExpectsToSend = Int64(-1)
    
    @available(*, unavailable)
    public private(set) var progress: Any? = nil /* Progress(totalUnitCount: -1) */

    @available(*, unavailable)
    public var earliestBeginDate: Date? = nil

    public enum State : Int {
        case running
        case suspended
        case canceling
        case completed
    }

    public var state: URLSessionTask.State {
        return lock.withLock { _state }
    }
    private var _state: URLSessionTask.State = .suspended

    //~~~ should all this be internal?
    public internal(set) var error: Error? {
        get {
            return lock.withLock { _error }
        }
        set {
            lock.withLock { _error = newValue }
        }
    }
    private var _error: Error?

    public internal(set) var currentRequest: URLRequest? {
        get {
            return lock.withLock { _currentRequest }
        }
        set {
            lock.withLock { _currentRequest = newValue }
        }
    }
    private var _currentRequest: URLRequest?

    public internal(set) var countOfBytesReceived: Int64 {
        get {
            return lock.withLock { _countOfBytesReceived }
        }
        set {
            lock.withLock { _countOfBytesReceived = newValue }
        }
    }
    private var _countOfBytesReceived = Int64(0)

    public internal(set) var countOfBytesSent: Int64 {
        get {
            return lock.withLock { _countOfBytesSent }
        }
        set {
            lock.withLock { _countOfBytesSent = newValue }
        }
    }
    private var _countOfBytesSent = Int64(0)

    public var priority: Float {
        get {
            return lock.withLock { _priority }
        }
        set {
            lock.withLock { _priority = newValue }
        }
    }
    private var _priority: Float = URLSessionTask.defaultPriority

    public internal(set) var countOfBytesExpectedToSend = Int64(0)
    public internal(set) var countOfBytesExpectedToReceive = Int64(0)
    public var taskDescription: String?

    public func cancel() {
        var completionError: Error? = nil
        lock.withLock {
            guard _state == .running || _state == .suspended else {
                return
            }
            _state = .canceling
            var info = [NSLocalizedDescriptionKey: "\(URLError.Code.cancelled)" as Any]
            if let url = originalRequest?.url {
                info[NSURLErrorFailingURLErrorKey] = url
                info[NSURLErrorFailingURLStringErrorKey] = url.absoluteString
            }
            let urlError = URLError(_nsError: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: info))
            _error = urlError
            close()
            completionError = urlError
        }
        if completionError != nil {
            completion(data: nil, response: nil, error: completionError)
        }
    }

    public func suspend() {
        lock.withLock {
            guard _state != .canceling && _state != .completed else {
                return
            }
            _suspendCount += 1
            _state = .suspended
            guard _suspendCount == 1 else {
                return
            }
            close()
        }
    }
    private var _suspendCount = 0

    public func resume() {
        var completionError: Error? = nil
        lock.withLock {
            guard _state != .canceling && _state != .completed else {
                return
            }
            if _suspendCount > 0 {
                _suspendCount -= 1
            }
            guard _suspendCount == 0 else {
                return
            }
            _state = .running
            guard let request = originalRequest, let url = request.url else {
                let error = NoURLInRequestError()
                _error = error
                completionError = error
                return
            }
            open(request: request, with: url)
        }
        if completionError != nil {
            completion(data: nil, response: nil, error: completionError)
        }
    }

    // MARK: - Internal

    /// Open the connection. Called with lock.
    func open(request: URLRequest, with url: URL) {
    }

    /// Close the connection. Called with lock.
    func close() {
    }

    func completion(data: Data?, response: URLResponse?, error: Error?) {
        if let completionHandler {
            completionHandler(data, response, error)
        }
        withDelegate(session.delegate as? URLSessionTaskDelegate) { delegate in
            delegate.urlSession(session, task: self, didCompleteWithError: error)
        }
    }

    func withDelegate<D>(_ delegate: D?, operation: (D) -> Void) {
        guard let delegate else {
            return
        }
        GlobalScope.launch(Dispatchers.Main) {
            operation(delegate)
        }
    }
}

public class _URLSessionDataTask : URLSessionTask {
    var genericJob: Job?
    var httpCall: Call?

    override func open(request: URLRequest, with url: URL) {
        switch RequestType(request) {
        case .generic:
            let job = Job()
            genericJob = job
            GlobalScope.launch(job) {
                do {
                    let (data, response) = URLSession.genericResponse(for: request, with: url)
                    notifyDelegate(response: response)
                    notifyDelegate(data: data)
                    completion(data: data, response: response, error: nil)
                } catch {
                    completion(data: nil, response: nil, error: error)
                }
            }
        case .http:
            let (client, httpRequest) = URLSession.httpRequest(for: request, with: url, configuration: session.configuration, build: build)
            httpCall = client.newCall(httpRequest)
            httpCall?.enqueue(HTTPCallback(task: self, url: url))
        }
    }

    override func close() {
        do { httpCall?.cancel() } catch {}
        httpCall = nil
        do { genericJob?.cancel() } catch {}
        genericJob = nil
    }

    private func notifyDelegate(response: URLResponse) {
        if let dataTask = self as? URLSessionDataTask {
            withDelegate(session.delegate as? URLSessionDataDelegate) { delegate in
                delegate.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: { _ in })
            }
        }
    }

    private func notifyDelegate(data: Data) {
        if let dataTask = self as? URLSessionDataTask {
            withDelegate(session.delegate as? URLSessionDataDelegate) { delegate in
                delegate.urlSession(session, dataTask: dataTask, didReceive: data)
            }
        }
    }

    private final class HTTPCallback: Callback {
        private let task: _URLSessionDataTask
        private let url: URL

        init(task: _URLSessionDataTask, url: URL) {
            self.task = task
            self.url = url
        }

        override func onFailure(call: Call, e: java.io.IOException) {
            task.completion(data: nil, response: nil, error: ErrorException(e))
        }

        override func onResponse(call: Call, response: Response) {
            do {
                response.use { response in
                    let urlResponse = URLSession.httpURLResponse(from: response, with: url)
                    task.notifyDelegate(response: urlResponse)

                    let data: Data
                    if let bytes = response.body?.bytes() {
                        data = Data(bytes)
                    } else {
                        data = Data()
                    }
                    task.notifyDelegate(data: data)
                    task.completion(data: data, response: urlResponse, error: nil)
                }
            } catch {
                task.completion(data: nil, response: nil, error: error)
            }
        }
    }
}

public class URLSessionDataTask : _URLSessionDataTask {
}

public class URLSessionUploadTask : _URLSessionDataTask {
}

public class URLSessionDownloadTask : URLSessionTask {
    @available(*, unavailable)
    public func cancel(byProducingResumeData completionHandler: @escaping (Data?) -> Void) {
        fatalError()
    }
}

public class URLSessionWebSocketTask : URLSessionTask {
    public enum CloseCode : Int {
        case invalid = 0
        case normalClosure = 1000
        case goingAway = 1001
        case protocolError = 1002
        case unsupportedData = 1003
        case noStatusReceived = 1005
        case abnormalClosure = 1006
        case invalidFramePayloadData = 1007
        case policyViolation = 1008
        case messageTooBig = 1009
        case mandatoryExtensionMissing = 1010
        case internalServerError = 1011
        case tlsHandshakeFailure = 1015
    }

    public enum Message {
        case data(Data)
        case string(String)
    }

    private let listener: Listener

    override init(session: URLSession, request: URLRequest, taskIdentifier: Int, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        super.init(session: session, request: request, taskIdentifier: taskIdentifier, completionHandler: completionHandler)
        self.listener = Listener(task: self)
    }

    //~~~
//    private var taskError: Error? = nil {
//        didSet {
//            doPendingWork()
//        }
//    }
//
//    open override var error: Error? {
//        didSet {
//            doPendingWork()
//        }
//    }
//
//    private var sendBuffer = [(Message, (Error?) -> Void)]()
//    private var receiveBuffer = [Message]()
//    private var receiveCompletionHandlers = [(Result<Message, Error>) -> Void]()
//    private var pongCompletionHandlers = [(Error?) -> Void]()
//    private var closeMessage: (CloseCode, Data)? = nil
//
//    internal var protocolPicked: String? = nil
//
//    func appendReceivedMessage(_ message: Message) {
//        workQueue.async {
//            self.receiveBuffer.append(message)
//            self.doPendingWork()
//        }
//    }
//
//    func noteReceivedPong() {
//        workQueue.async {
//            guard !self.pongCompletionHandlers.isEmpty else {
//                self.close(code: .protocolError, reason: nil)
//                return
//            }
//            let completionHandler = self.pongCompletionHandlers.removeFirst()
//            completionHandler(nil)
//        }
//    }

    public func sendPing() async throws {
//        let _: Void = try await withCheckedThrowingContinuation { continuation in
//            sendPing { error in
//                if let error {
//                    continuation.resume(throwing: error)
//                } else {
//                    continuation.resume(returning: ())
//                }
//            }
//        }
    }

    public func sendPing(pongReceiveHandler: @escaping (Error?) -> Void) {
//        self.workQueue.async {
//            self._getProtocol { urlProtocol in
//                self.workQueue.async {
//                    if let webSocketProtocol = urlProtocol as? _WebSocketURLProtocol {
//                        do {
//                            try webSocketProtocol.sendWebSocketData(Data(), flags: [.ping])
//                            self.pongCompletionHandlers.append(pongReceiveHandler)
//                        } catch {
//                            pongReceiveHandler(error)
//                        }
//                    } else {
//                        let disconnectedError = URLError(_nsError: NSError(domain: NSURLErrorDomain,
//                                                                           code: NSURLErrorNetworkConnectionLost))
//                        pongReceiveHandler(disconnectedError)
//                    }
//                }
//            }
//        }
    }

    override func cancel() {
        cancel(with: .invalid, reason: nil)
    }

    public func cancel(with closeCode: CloseCode, reason: Data?) {
//        workQueue.async {
//            // If we've already errored out in some way, no need to re-close.
//            if self.taskError != nil { return }
//
//            self.closeCode = code
//            self.closeReason = reason
//            self.taskError = URLError(_nsError: NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost))
//            self.closeMessage = (code, reason ?? Data())
//            self.doPendingWork()
//        }
    }

    public var maximumMessageSize: Int = 1 * 1024 * 1024
    public private(set) var closeCode: CloseCode = .invalid
    public private(set) var closeReason: Data? = nil

    public func send(_ message: Message) async throws -> Void {
//        let _: Void = try await withCheckedThrowingContinuation { continuation in
//            send(message) { error in
//                if let error {
//                    continuation.resume(throwing: error)
//                } else {
//                    continuation.resume(returning: ())
//                }
//            }
//        }
    }

//    private func send(_ message: Message, completionHandler: @escaping (Error?) -> Void) {
//        self.workQueue.async {
//            self.sendBuffer.append((message, completionHandler))
//            self.doPendingWork()
//        }
//    }

    public func receive() async throws -> Message {
        fatalError()
//        try await withCheckedThrowingContinuation { continuation in
//            receive() { result in
//                continuation.resume(with: result)
//            }
//        }
    }

//    private func receive(completionHandler: @escaping (Result<Message, Error>) -> Void) {
//        self.workQueue.async {
//            self.receiveCompletionHandlers.append(completionHandler)
//            self.doPendingWork()
//        }
//    }

//    private func doPendingWork() {
//        self.workQueue.async {
//            let session = self.session as! URLSession
//            if let taskError = self.taskError ?? self.error {
//                for (_, handler) in self.sendBuffer {
//                    session.delegateQueue.addOperation {
//                        handler(taskError)
//                    }
//                }
//                self.sendBuffer.removeAll()
//                for handler in self.receiveCompletionHandlers {
//                    session.delegateQueue.addOperation {
//                        handler(.failure(taskError))
//                    }
//                }
//                self.receiveCompletionHandlers.removeAll()
//                self._getProtocol { urlProtocol in
//                    self.workQueue.async {
//                        if self.handshakeCompleted && self.state != .completed {
//                            if let webSocketProtocol = urlProtocol as? _WebSocketURLProtocol {
//                                if let closeMessage = self.closeMessage {
//                                    self.closeMessage = nil
//                                    var closeData = Data([UInt8(closeMessage.0.rawValue >> 8), UInt8(closeMessage.0.rawValue & 0xFF)])
//                                    closeData.append(contentsOf: closeMessage.1)
//                                    try? webSocketProtocol.sendWebSocketData(closeData, flags: [.close])
//                                }
//                            }
//                        }
//                    }
//                }
//            } else {
//                self._getProtocol { urlProtocol in
//                    self.workQueue.async {
//                        if self.handshakeCompleted {
//                            if let webSocketProtocol = urlProtocol as? _WebSocketURLProtocol {
//                                while !self.sendBuffer.isEmpty {
//                                    let (message, completionHandler) = self.sendBuffer.removeFirst()
//                                    do {
//                                        switch message {
//                                        case .data(let data):
//                                            try webSocketProtocol.sendWebSocketData(data, flags: [.binary])
//                                        case .string(let str):
//                                            try webSocketProtocol.sendWebSocketData(str.data(using: .utf8)!, flags: [.text])
//                                        }
//                                        completionHandler(nil)
//                                    } catch {
//                                        completionHandler(error)
//                                    }
//                                }
//                                if let closeMessage = self.closeMessage {
//                                    self.closeMessage = nil
//                                    var closeData = Data([UInt8(closeMessage.0.rawValue >> 8), UInt8(closeMessage.0.rawValue & 0xFF)])
//                                    closeData.append(contentsOf: closeMessage.1)
//                                    try? webSocketProtocol.sendWebSocketData(closeData, flags: [.close])
//                                }
//                            }
//                        }
//                        while !self.receiveBuffer.isEmpty && !self.receiveCompletionHandlers.isEmpty {
//                            let message = self.receiveBuffer.removeFirst()
//                            let handler = self.receiveCompletionHandlers.removeFirst()
//                            handler(.success(message))
//                        }
//                    }
//                }
//            }
//        }
//    }

    private final class Listener : WebSocketListener {
        let task: URLSessionWebSocketTask

        init(task: URLSessionWebSocketTask) {
            self.task = task
        }

        override func onOpen(webSocket: WebSocket, response: Response) {
            super.onOpen(webSocket: webSocket, response: response)
        }

        override func onClosed(webSocket: WebSocket, code: Int, reason: String) {
            super.onClosed(webSocket: webSocket, code: code, reason: reason)

        }

        override func onClosing(webSocket: WebSocket, code: Int, reason: String) {
            super.onClosing(webSocket: webSocket, code: code, reason: reason)
        }

        override func onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            super.onFailure(webSocket: webSocket, t: t, response: response)
        }

        override func onMessage(webSocket: WebSocket, text: String) {
            super.onMessage(webSocket: webSocket, text: text)
        }

        override func onMessage(webSocket: WebSocket, bytes: ByteString) {
            super.onMessage(webSocket: webSocket, bytes: bytes)
        }
    }
}

public protocol URLSessionWebSocketDelegate : URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?)
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
    }
}

public class URLSessionStreamTask : URLSessionTask {
    @available(*, unavailable)
    public func readData(ofMinLength minBytes: Int, maxLength maxBytes: Int, timeout: TimeInterval, completionHandler: @escaping (Data?, Bool, Error?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    public func write(_ data: Data, timeout: TimeInterval, completionHandler: @escaping (Error?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    public func captureStreams() {
        fatalError()
    }

    @available(*, unavailable)
    public func closeWrite() {
        fatalError()
    }

    @available(*, unavailable)
    public func closeRead() {
        fatalError()
    }

    @available(*, unavailable)
    public func startSecureConnection() {
        fatalError()
    }

    @available(*, unavailable)
    public func stopSecureConnection() {
        fatalError()
    }
}

public let URLSessionDownloadTaskResumeData: String = "NSURLSessionDownloadTaskResumeData"

public protocol URLSessionTaskDelegate : URLSessionDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
//    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
}

extension URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    }

//    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
//    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    }
}

public protocol URLSessionDataDelegate : URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void)
}

extension URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
    }
}

public protocol URLSessionDownloadDelegate : URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
}

extension URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
}

public protocol URLSessionStreamDelegate : URLSessionTaskDelegate {
//    func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask)
//    func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask)
//    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask)
//    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream)
}

extension URLSessionStreamDelegate {
//    public func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
//    }
//
//    public func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
//    }
//
//    public func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
//    }
//
//    public func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
//    }
}

// Stubs
public struct URLSessionTaskMetrics {
}

#endif
