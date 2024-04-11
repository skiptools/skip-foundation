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
import kotlinx.coroutines.channels.Channel
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString
import okio.ByteString.Companion.toByteString

public class URLSessionTask {
    public static let defaultPriority = Float(0.5)
    public static let lowPriority = Float(0.25)
    public static let highPriority = Float(0.75)

    let session: URLSession
    let build: (Request.Builder) -> Void
    let lock = NSRecursiveLock()
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

    public var error: Error? {
        return lock.withLock { _error }
    }
    private var _error: Error?

    public var currentRequest: URLRequest? {
        return originalRequest
    }

    public let countOfBytesReceived = Int64(0)
    public let countOfBytesSent = Int64(0)
    public let countOfBytesExpectedToSend = Int64(0)
    public let countOfBytesExpectedToReceive = Int64(0)

    public var priority: Float {
        get {
            return lock.withLock { _priority }
        }
        set {
            lock.withLock { _priority = newValue }
        }
    }
    private var _priority: Float = URLSessionTask.defaultPriority

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
            close()
            completionError = URLError(.cancelled, userInfo: info)
        }
        completion(data: nil, response: nil, error: completionError)
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
                completionError = URLError(.badURL)
                return
            }
            do { open(request: request, with: url) } catch { completionError = error }
        }
        if completionError != nil {
            completion(data: nil, response: nil, error: completionError)
        }
    }

    // MARK: - Internal

    /// Open the connection. Called with lock.
    func open(request: URLRequest, with url: URL) throws {
    }

    /// Close the connection. Called with lock.
    func close() {
    }

    /// Send completion events.
    func completion(data: Data?, response: URLResponse?, error: Error?) {
        lock.withLock {
            _error = error
            if _state != .completed && _state != .canceling {
                _state = error == nil ? .completed : .canceling
            }
        }
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
    private var webSocket: WebSocket?
    private var url: URL?
    private var channel: Channel<Message>?

    override init(session: URLSession, request: URLRequest, taskIdentifier: Int, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        super.init(session: session, request: request, taskIdentifier: taskIdentifier, completionHandler: completionHandler)
        self.listener = Listener(task: self)
    }

    override func open(request: URLRequest, with url: URL) {
        let (client, httpRequest) = URLSession.httpRequest(for: request, with: url, configuration: session.configuration, build: build)
        self.url = url
        webSocket = client.newWebSocket(httpRequest, listener)
        channel = Channel<Message>(Channel.UNLIMITED)
    }

    override func close() {
        webSocket?.close((_closeCode ?? .invalid).rawValue, _closeReason?.utf8String)
        webSocket = nil
        channel?.close()
        channel = nil
    }

    @available(*, unavailable)
    public func sendPing() async throws {
    }

    @available(*, unavailable)
    public func sendPing(pongReceiveHandler: @escaping (Error?) -> Void) {
    }

    override func cancel() {
        cancel(with: .invalid, reason: nil)
    }

    public func cancel(with closeCode: CloseCode, reason: Data?) {
        lock.withLock {
            _closeCode = closeCode
            _closeReason = reason
        }
        super.cancel()
    }

    public var maximumMessageSize: Int = 1 * 1024 * 1024
    
    public var closeCode: CloseCode {
        return lock.withLock { _closeCode } ?? .invalid
    }
    private var _closeCode: CloseCode? = nil

    public var closeReason: Data? {
        return lock.withLock { _closeReason }
    }
    private var _closeReason: Data?

    public func send(_ message: Message) async throws -> Void {
        guard let webSocket = lock.withLock({ self.webSocket }) else {
            throw URLError(.cancelled)
        }
        switch message {
        case .data(let data):
            webSocket.send(data.platformValue.toByteString())
        case .string(let string):
            webSocket.send(string)
        }
    }

    public func receive() async throws -> Message {
        guard let channel = lock.withLock({ self.channel }) else {
            throw URLError(.cancelled)
        }
        return channel.receive()
    }

    private final class Listener : WebSocketListener {
        let task: URLSessionWebSocketTask

        init(task: URLSessionWebSocketTask) {
            self.task = task
        }

        override func onOpen(webSocket: WebSocket, response: Response) {
            super.onOpen(webSocket: webSocket, response: response)
            task.withDelegate(task.session.delegate as? URLSessionWebSocketDelegate) { delegate in
                delegate.urlSession(task.session, webSocketTask: task, didOpenWithProtocol: response.protocol.toString())
            }
        }

        override func onClosed(webSocket: WebSocket, code: Int, reason: String) {
            super.onClosed(webSocket: webSocket, code: code, reason: reason)
            task.withDelegate(task.session.delegate as? URLSessionWebSocketDelegate) { delegate in
                let closeCode = CloseCode(rawValue: code) ?? CloseCode.invalid
                let closeData = reason.utf8Data
                delegate.urlSession(task.session, webSocketTask: task, didCloseWith: closeCode, reason: closeData)
            }
        }

        override func onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            super.onFailure(webSocket: webSocket, t: t, response: response)
            let userInfo: [String : Any] = [
                NSUnderlyingErrorKey: t.aserror(),
                NSLocalizedDescriptionKey: t.toString()
            ]
            let urlError = URLError(.unknown, userInfo: userInfo)
            var httpResponse: URLResponse? = nil
            if let response, let url = task.url {
                httpResponse = URLSession.httpURLResponse(from: response, with: url)
            }
            task.completion(data: nil, response: httpResponse, error: urlError)
        }

        override func onMessage(webSocket: WebSocket, text: String) {
            super.onMessage(webSocket: webSocket, text: text)
            task.channel?.trySend(Message.string(text))
        }

        override func onMessage(webSocket: WebSocket, bytes: ByteString) {
            super.onMessage(webSocket: webSocket, bytes: bytes)
            task.channel?.trySend(Message.data(Data(platformValue: bytes.toByteArray())))
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
