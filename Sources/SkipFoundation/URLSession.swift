// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.withContext
import okhttp3.Cache
import okhttp3.CacheControl
import okhttp3.Call
import okhttp3.Headers.Companion.toHeaders
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response

private let logger: Logger = Logger(subsystem: "skip", category: "URLSession")
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

enum RequestType {
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

public final class URLSession {
    public static let shared = URLSession(configuration: URLSessionConfiguration.default)

    public let configuration: URLSessionConfiguration
    public let delegate: URLSessionDelegate?
    public let delegateQueue: OperationQueue

    private let lock = NSRecursiveLock()
    private var nextTaskIdentifier = 0

    public init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate? = nil, delegateQueue: OperationQueue? = nil) {
        self.configuration = configuration
        self.delegate = delegate
        self.delegateQueue = delegateQueue ?? OperationQueue()
    }

    public var sessionDescription: String?

    /// Use for non-HTTP requests.
    static func genericConnection(for request: URLRequest, with url: URL) throws -> java.net.URLConnection {
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

    /// Use for HTTP requests.
    static func httpRequest(for request: URLRequest, with url: URL, configuration: URLSessionConfiguration, build: (Request.Builder) -> Void = {}) -> (OkHttpClient, Request) {
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

    // SKIP ATTRIBUTES: nodispatch
    public func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }
        switch RequestType(request) {
        case .generic:
            return Self.genericResponse(for: request, with: url)
        case .http:
            let (client, httpRequest) = Self.httpRequest(for: request, with: url, configuration: configuration)
            return Self.httpResponse(client: client, request: httpRequest, with: url)
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    public func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        return self.data(for: URLRequest(url: url), delegate: delegate)
    }

    // SKIP ATTRIBUTES: nodispatch
    static func genericResponse(for request: URLRequest, with url: URL) async throws -> (Data, URLResponse) {
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            let connection = try genericConnection(for: request, with: url)
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
                let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
                return (data: Data(platformValue: bytes), response: response)
            } onCancel: {
                do { inputStream?.close() } catch {}
                job.cancel()
            }
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    static func httpResponse(client: OkHttpClient, request: Request, with url: URL) async throws -> (Data, URLResponse) {
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            let call = client.newCall(request)
            return withTaskCancellationHandler {
                call.execute().use { response in
                    let data: Data
                    if let bytes = response.body?.bytes() {
                        data = Data(bytes)
                    } else {
                        data = Data()
                    }
                    let urlResponse = httpURLResponse(from: response, with: url)
                    return (data, urlResponse)
                }
            } onCancel: {
                do { call.cancel() } catch {}
                job.cancel()
            }
        }
    }

    static func httpURLResponse(from response: Response, with url: URL) -> HTTPURLResponse {
        let statusCode = response.code
        let httpVersion = response.protocol.toString()
        let headerDictionary = Dictionary(response.headers.toMap(), nocopy: true)
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: httpVersion, headerFields: headerDictionary)
    }

    @available(*, unavailable)
    public func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        // NOTE: Partial implementation was here prior to 4/7/2024. See git history to revive
        fatalError()
    }

    @available(*, unavailable)
    public func download(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse) {
        fatalError()
    }

    @available(*, unavailable)
    public func download(from url: URL) async throws -> (URL, URLResponse) {
        fatalError()
    }

    @available(*, unavailable)
    public func download(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse) {
        fatalError()
    }

    @available(*, unavailable)
    func download(resumeFrom: Data, delegate: URLSessionTaskDelegate?) -> (URL, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }
        let file = java.io.File(url.platformValue.toURI())
        // Only supported for HTTP
        let (client, httpRequest) = Self.httpRequest(for: request, with: url, configuration: configuration) {
            $0.post(file.asRequestBody())
        }
        return Self.httpResponse(client: client, request: httpRequest, with: url)
    }

    @available(*, unavailable)
    public func upload(for request: URLRequest, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }
        // Only supported for HTTP
        let (client, httpRequest) = Self.httpRequest(for: request, with: url, configuration: configuration) {
            $0.post(bodyData.platformValue.toRequestBody())
        }
        return Self.httpResponse(client: client, request: httpRequest, with: url)
    }

    @available(*, unavailable)
    public func upload(for request: URLRequest, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(for request: URLRequest) async throws -> (AsyncBytes, URLResponse) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }
        switch RequestType(request) {
        case .generic:
            return Self.genericBytes(for: request, with: url)
        case .http:
            let (client, request) = Self.httpRequest(for: request, with: url, configuration: configuration)
            return Self.httpBytes(client: client, request: request, with: url)
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    static func genericBytes(for request: URLRequest, with url: URL) async throws -> (AsyncBytes, URLResponse) {
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            let connection = try genericConnection(for: request, with: url)
            var inputStream: java.io.InputStream? = nil
            return withTaskCancellationHandler {
                inputStream = connection.getInputStream()
                let asyncBytes = AsyncBytes(inputStream: inputStream, onClose: { do { inputStream?.close() } catch {} })
                let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
                return (asyncBytes: asyncBytes, response: response)
            } onCancel: {
                do { inputStream?.close() } catch {}
                job.cancel()
            }
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    static func httpBytes(client: OkHttpClient, request: Request, with url: URL) async throws -> (AsyncBytes, URLResponse) {
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            let call = client.newCall(request)
            return withTaskCancellationHandler {
                let response = call.execute()
                let inputStream = response.body?.byteStream()
                let asyncBytes = AsyncBytes(inputStream: inputStream, onClose: { do { response.close() } catch {} })
                let urlResponse = httpURLResponse(from: response, with: url)
                return (asyncBytes, urlResponse)
            } onCancel: {
                do { call.cancel() } catch {}
                job.cancel()
            }
        }
    }

    @available(*, unavailable)
    public func bytes(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (AsyncBytes, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(from url: URL) async throws -> (AsyncBytes, URLResponse) {
        return bytes(for: URLRequest(url: url))
    }

    @available(*, unavailable)
    public func bytes(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (AsyncBytes, URLResponse) {
        fatalError()
    }

    public struct AsyncBytes: AsyncSequence {
        typealias Element = UInt8
        
        var inputStream: java.io.InputStream?
        var onClose: (() -> Void)?

        init(inputStream: java.io.InputStream?, onClose: (() -> Void)? = nil) {
            self.inputStream = inputStream
            self.onClose = onClose
        }

        deinit {
            if let onClose {
                onClose()
            }
        }

        override func makeAsyncIterator() -> Iterator {
            return Iterator(bytes: self)
        }

        func close() {
            if let onClose {
                onClose()
                self.inputStream = nil
                self.onClose = nil
            }
        }

        public final class Iterator: AsyncIteratorProtocol {
            private let bytes: AsyncBytes

            init(bytes: AsyncBytes) {
                self.bytes = bytes
            }

            override func next() async -> UInt8? {
                guard let byte = try? bytes.inputStream?.read(), byte != -1 else {
                    bytes.close()
                    return nil
                }
                return UInt8(byte)
            }
        }
    }

    private func nextTaskIdentifier() -> Int {
        lock.withLock {
            nextTaskIdentifier += 1
            return nextTaskIdentifier
        }
    }

    public func dataTask(with url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        return dataTask(with: URLRequest(url: url), completionHandler: completionHandler)
    }

    public func dataTask(with request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        let identifier = nextTaskIdentifier()
        return URLSessionDataTask(session: self, request: request, taskIdentifier: identifier, completionHandler: completionHandler)
    }

    @available(*, unavailable)
    public func downloadTask(with: URL) -> URLSessionDownloadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func downloadTask(with: URL, completionHandler: (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func downloadTask(with: URLRequest) -> URLSessionDownloadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func downloadTask(with: URLRequest, completionHandler: (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func downloadTask(withResumeData: Data) -> URLSessionDownloadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func downloadTask(withResumeData: Data, completionHandler: (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        fatalError()
    }

    public func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionUploadTask {
        let identifier = nextTaskIdentifier()
        return URLSessionUploadTask(session: self, request: request, taskIdentifier: identifier, build: {
            if let bodyData {
                $0.post(bodyData.platformValue.toRequestBody())
            }
        }, completionHandler: completionHandler)
    }

    public func uploadTask(with request: URLRequest, fromFile url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) -> URLSessionUploadTask {
        let file = java.io.File(url.platformValue.toURI())
        let identifier = nextTaskIdentifier()
        return URLSessionUploadTask(session: self, request: request, taskIdentifier: identifier, build: {
            $0.post(file.asRequestBody())
        }, completionHandler: completionHandler)
    }

    @available(*, unavailable)
    public func uploadTask(withStreamedRequest: URLRequest) -> URLSessionUploadTask {
        fatalError()
    }

    @available(*, unavailable)
    func uploadTask(withResumeData: Data) -> URLSessionUploadTask {
        fatalError()
    }

    @available(*, unavailable)
    func uploadTask(withResumeData: Data, completionHandler: (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func streamTask(withHostName: String, port: Int) -> URLSessionStreamTask {
        fatalError()
    }

    public func webSocketTask(with url: URL) -> URLSessionWebSocketTask {
        return webSocketTask(with: URLRequest(url: url))
    }

    public func webSocketTask(with request: URLRequest) -> URLSessionWebSocketTask {
        let identifier = nextTaskIdentifier()
        return URLSessionWebSocketTask(session: self, request: request, taskIdentifier: identifier)
    }

    public func webSocketTask(with url: URL, protocols: [String]) -> URLSessionWebSocketTask {
        var request = URLRequest(url: url)
        request.setValue(protocols.joined(separator: ", "), forHTTPHeaderField: "Sec-WebSocket-Protocol")
        return webSocketTask(with: request)
    }

    public func finishTasksAndInvalidate() {
        //~~~
    }

    @available(*, unavailable)
    public func flush(completionHandler: () -> Void) {
    }

    public func getTasksWithCompletionHandler(_ handler: ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) -> Void) {
        //~~~
    }

    public var tasks: ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) {
        get async {
            //~~~
        }
    }

    public func getAllTasks(completionHandler: ([URLSessionTask]) -> Void) {
        //~~~
    }

    public var allTasks: [URLSessionTask] {
        get async {
            //~~~
        }
    }

    public func invalidateAndCancel() {
        //~~~
    }

    @available(*, unavailable)
    public func reset(completionHandler: () -> Void) {
    }

    @available(*, unavailable)
    public func dataTaskPublisher(for: URLRequest) -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func dataTaskPublisher(for: URL) -> Any {
        fatalError()
    }

    public enum DelayedRequestDisposition : Int {
        case continueLoading = 0
        case useNewRequest = 1
        case cancel = 2
    }

    public enum AuthChallengeDisposition : Int {
        case useCredential = 0
        case performDefaultHandling = 1
        case cancelAuthenticationChallenge = 2
        case rejectProtectionSpace = 3
    }

    public enum ResponseDisposition : Int {
        case cancel = 0
        case allow = 1
        case becomeDownload = 2
        case becomeStream = 3
    }
}

public protocol URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

extension URLSessionDelegate {
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    }
}

// Stub
public struct URLAuthenticationChallenge {
}
public struct URLCredential {
}
public struct CachedURLResponse {
}

#endif
