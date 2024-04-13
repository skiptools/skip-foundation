// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.channels.Channel
import okhttp3.Cache
import okhttp3.CacheControl
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Headers.Companion.toHeaders
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
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
    let completionHandler: ((Data?, URLResponse?, Error?) -> Void)?

    init(session: URLSession, request: URLRequest, taskIdentifier: Int, build: (Request.Builder) -> Void = {}, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        self.session = session
        self.originalRequest = request
        self.taskIdentifier = taskIdentifier
        self.build = build
        self.completionHandler = completionHandler
    }

    public let taskIdentifier: Int
    public let originalRequest: URLRequest?
    public var delegate: URLSessionTaskDelegate? {
        get {
            return lock.withLock { _delegate }
        }
        set {
            lock.withLock { _delegate = newValue }
        }
    }
    private var _delegate: URLSessionTaskDelegate?

    public var countOfBytesClientExpectsToReceive = Int64(-1)
    public var countOfBytesClientExpectsToSend = Int64(-1)
    
    @available(*, unavailable)
    public let progress: Any? = nil /* Progress(totalUnitCount: -1) */

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
            do { close() } catch {}
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
        session.taskDidComplete(self)
        if let completionHandler {
            completionHandler(data, response, error)
        }
        withDelegates(task: delegate, session: session.delegate as? URLSessionTaskDelegate) { delegate in
            delegate.urlSession(session, task: self, didCompleteWithError: error)
        }
    }

    func withDelegates<D>(task taskDelegate: D?, session sessionDelegate: D?, operation: (D) -> Void) {
        guard taskDelegate != nil || sessionDelegate != nil else {
            return
        }
        self.session.delegateQueue.runBlock {
            if let taskDelegate {
                operation(taskDelegate)
            }
            if let sessionDelegate {
                operation(sessionDelegate)
            }
        }
    }
}

public class _URLSessionDataTask : URLSessionTask {
    var genericJob: Job?
    var httpCall: Call?

    var isForResponse = false
    private(set) var genericConnection: java.net.URLConnection?
    private(set) var httpResponse: Response?

    override func open(request: URLRequest, with url: URL) {
        switch RequestType(request) {
        case .generic:
            let job = Job()
            genericJob = job
            GlobalScope.launch(job) {
                do {
                    let (data, response, connection) = genericResponse(for: request, with: url, isForResponse: isForResponse)
                    genericConnection = connection
                    notifyDelegate(response: response)
                    if let data {
                        notifyDelegate(data: data)
                    }
                    completion(data: data, response: response, error: nil)
                } catch {
                    completion(data: nil, response: nil, error: error)
                }
            }
        case .http:
            let (client, httpRequest) = httpRequest(for: request, with: url, configuration: session.configuration, build: build)
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
            withDelegates(task: delegate as? URLSessionDataDelegate, session: session.delegate as? URLSessionDataDelegate) { delegate in
                delegate.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: { _ in })
            }
        }
    }

    private func notifyDelegate(data: Data) {
        if let dataTask = self as? URLSessionDataTask {
            withDelegates(task: delegate as? URLSessionDataDelegate, session: session.delegate as? URLSessionDataDelegate) { delegate in
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
            defer {
                if response != task.httpResponse {
                    do { response.close() } catch {}
                }
            }
            do {
                let urlResponse = httpURLResponse(from: response, with: url)
                task.notifyDelegate(response: urlResponse)
                let data: Data?
                if task.isForResponse {
                    data = nil
                    task.httpResponse = response
                } else {
                    if let bytes = response.body?.bytes() {
                        data = Data(platformValue: bytes)
                    } else {
                        data = Data()
                    }
                    task.notifyDelegate(data: data)
                }
                task.completion(data: data, response: urlResponse, error: nil)
            } catch {
                task.httpResponse = nil
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
        let (client, httpRequest) = httpRequest(for: request, with: url, configuration: session.configuration, build: build)
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
            task.withDelegates(task: task.delegate as? URLSessionWebSocketDelegate, session: task.session.delegate as? URLSessionWebSocketDelegate) { delegate in
                delegate.urlSession(task.session, webSocketTask: task, didOpenWithProtocol: response.protocol.toString())
            }
        }

        override func onClosed(webSocket: WebSocket, code: Int, reason: String) {
            super.onClosed(webSocket: webSocket, code: code, reason: reason)
            task.withDelegates(task: task.delegate as? URLSessionWebSocketDelegate, session: task.session.delegate as? URLSessionWebSocketDelegate) { delegate in
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
                httpResponse = httpURLResponse(from: response, with: url)
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
    func urlSession(_ session: URLSession, didCreateTask: URLSessionTask)
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
//    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceiveInformationalResponse: HTTPURLResponse)
}

extension URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, didCreateTask: URLSessionTask) {
    }

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

    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceiveInformationalResponse: HTTPURLResponse) {
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

private enum RequestType {
    case generic, http

    init(_ request: URLRequest) {
        guard let url = request.url else {
            self = RequestType.generic
        }
        switch url.scheme?.lowercased() {
        case "http", "https", "ws", "wss":
            self = RequestType.http
        default:
            self = RequestType.generic
        }
    }
}

private let httpClient: OkHttpClient = {
    let builder = OkHttpClient.Builder()
        .callTimeout(Int64(URLSessionConfiguration.default.timeoutIntervalForRequest * 1000), TimeUnit.MILLISECONDS)
        .readTimeout(Int64(URLSessionConfiguration.default.timeoutIntervalForResource * 1000), TimeUnit.MILLISECONDS)
    do {
        builder.cache(Cache(java.io.File(ProcessInfo.processInfo.androidContext.cacheDir, "http_cache"), 5 * 1024 * 1024))
    } catch {
        // Can't access ProcessInfo in testing environments
    }
    return builder.build()
}()

/// Use for HTTP requests.
private func httpRequest(for request: URLRequest, with url: URL, configuration: URLSessionConfiguration, build: (Request.Builder) -> Void = {}) -> (OkHttpClient, Request) {
    let requestTimeout = request.timeoutInterval > 0.0 ? request.timeoutInterval : configuration.timeoutIntervalForRequest
    let resourceTimeout = configuration.timeoutIntervalForResource
    let client: OkHttpClient
    if requestTimeout != URLSessionConfiguration.default.timeoutIntervalForRequest || resourceTimeout != URLSessionConfiguration.default.timeoutIntervalForResource {
        client = httpClient.newBuilder()
            .callTimeout(Int64(requestTimeout * 1000), TimeUnit.MILLISECONDS)
            .readTimeout(Int64(resourceTimeout * 1000), TimeUnit.MILLISECONDS)
            .build()
    } else {
        client = httpClient
    }

    let builder = Request.Builder()
        .url(url.platformValue)
        .method(request.httpMethod ?? "GET", request.httpBody?.platformValue?.toRequestBody())
    // SKIP NOWARN
    if let headerMap = request.allHTTPHeaderFields?.kotlin(nocopy: true) as? Map<String, String> {
        builder.headers(headerMap.toHeaders())
    }
    switch request.cachePolicy {
    case URLRequest.CachePolicy.useProtocolCachePolicy:
        break
    case URLRequest.CachePolicy.returnCacheDataElseLoad:
        builder.header("Cache-Control", "max-stale=31536000") // One year
    case URLRequest.CachePolicy.returnCacheDataDontLoad:
        builder.cacheControl(CacheControl.FORCE_CACHE)
    case URLRequest.CachePolicy.reloadRevalidatingCacheData:
        builder.header("Cache-Control", "no-cache, must-revalidate")
    case URLRequest.CachePolicy.reloadIgnoringLocalCacheData:
        builder.cacheControl(CacheControl.FORCE_NETWORK)
    case URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData: builder.cacheControl(CacheControl.FORCE_NETWORK)
    }

    build(builder)
    return (client, builder.build())
}

private func httpURLResponse(from response: Response, with url: URL) -> HTTPURLResponse {
    let statusCode = response.code
    let httpVersion = response.protocol.toString()
    let headerDictionary = Dictionary(response.headers.toMap(), nocopy: true)
    return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: httpVersion, headerFields: headerDictionary)
}

/// Use for non-HTTP requests.
private func genericConnection(for request: URLRequest, with url: URL) throws -> java.net.URLConnection {
    // Calling openConnection does not actually connect
    let connection = url.platformValue.openConnection()
    switch request.cachePolicy {
    case URLRequest.CachePolicy.useProtocolCachePolicy:
        connection.setUseCaches(true)
    case URLRequest.CachePolicy.returnCacheDataElseLoad:
        connection.setUseCaches(true)
    case URLRequest.CachePolicy.returnCacheDataDontLoad:
        connection.setUseCaches(true)
    case URLRequest.CachePolicy.reloadRevalidatingCacheData:
        connection.setUseCaches(true)
    case URLRequest.CachePolicy.reloadIgnoringLocalCacheData:
        connection.setUseCaches(false)
    case URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData:
        connection.setUseCaches(false)
    }
    return connection
}

// SKIP ATTRIBUTES: nodispatch
private func genericResponse(for request: URLRequest, with url: URL, isForResponse: Bool) async throws -> (Data?, URLResponse, java.net.URLConnection?) {
    let job = Job()
    return withContext(job + Dispatchers.IO) {
        let connection = try genericConnection(for: request, with: url)
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        guard !isForResponse else {
            return (nil, response, connection)
        }
        var inputStream: java.io.InputStream? = nil
        return withTaskCancellationHandler {
            inputStream = connection.getInputStream()
            let outputStream = java.io.ByteArrayOutputStream()
            let buffer = ByteArray(1024)
            if let stableInputStream = inputStream {
                var bytesRead: Int
                while (stableInputStream.read(buffer).also { bytesRead = $0 } != -1) {
                    outputStream.write(buffer, 0, bytesRead)
                }
            }
            do { inputStream?.close() } catch {}
            let bytes = outputStream.toByteArray()
            return (Data(platformValue: bytes), response, nil)
        } onCancel: {
            do { inputStream?.close() } catch {}
            job.cancel()
        }
    }
}

#endif
