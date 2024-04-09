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
import okhttp3.`internal`.closeQuietly

private let logger: Logger = Logger(subsystem: "skip", category: "URLSession")
private let httpClient: OkHttpClient = OkHttpClient.Builder()
    .callTimeout(Int64(URLSessionConfiguration.default.timeoutIntervalForRequest * 1000), TimeUnit.MILLISECONDS)
    .readTimeout(Int64(URLSessionConfiguration.default.timeoutIntervalForResource * 1000), TimeUnit.MILLISECONDS)
    .cache(Cache(java.io.File(ProcessInfo.processInfo.androidContext.cacheDir, "http_cache"), 5 * 1024 * 1024))
    .build()

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

public final class URLSession {
    public static let shared = URLSession(configuration: URLSessionConfiguration.default)

    public var configuration: URLSessionConfiguration
    public let delegate: URLSessionDelegate?
    public let delegateQueue: OperationQueue?

    public init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
        self.delegate = nil
        self.delegateQueue = nil
    }

    @available(*, unavailable)
    public init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) {
        self.configuration = configuration
        self.delegate = delegate
        self.delegateQueue = delegateQueue
    }

    /// Use for non-HTTP requests.
    private static func genericConnection(for request: URLRequest, with url: URL) throws -> java.net.URLConnection {
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
    private static func httpCall(for request: URLRequest, with url: URL, configuration: URLSessionConfiguration, build: (Request.Builder) -> Void = {}) -> Call {
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
        return client.newCall(builder.build())
    }

    // SKIP ATTRIBUTES: nodispatch
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw NoURLInRequestError()
        }
        let configuration = configuration
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            switch RequestType(request) {
            case .generic:
                return Self.genericResponse(for: request, with: url, job: job)
            case .http:
                let call = Self.httpCall(for: request, with: url, configuration: configuration)
                return Self.httpResponse(for: call, with: url, job: job)
            }
        }
    }

    @available(*, unavailable)
    public func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        return self.data(for: URLRequest(url: url))
    }

    @available(*, unavailable)
    public func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    private static func genericResponse(for request: URLRequest, with url: URL, job: Job) async throws -> (Data, URLResponse) {
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
            inputStream?.closeQuietly()

            let bytes = outputStream.toByteArray()
            let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
            return (data: Data(platformValue: bytes), response: response)
        } onCancel: {
            inputStream?.closeQuietly()
            job.cancel()
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    private static func httpResponse(for call: Call, with url: URL, job: Job) async throws -> (Data, URLResponse) {
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

    private static func httpURLResponse(from response: Response, with url: URL) -> HTTPURLResponse {
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
            throw NoURLInRequestError()
        }
        let file = java.io.File(url.platformValue.toURI())
        // Only supported for HTTP
        let call = Self.httpCall(for: request, with: url, configuration: configuration) {
            $0.post(file.asRequestBody())
        }
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            return Self.httpResponse(for: call, with: url, job: job)
        }
    }

    @available(*, unavailable)
    public func upload(for request: URLRequest, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw NoURLInRequestError()
        }
        // Only supported for HTTP
        let call = Self.httpCall(for: request, with: url, configuration: configuration) {
            $0.post(bodyData.platformValue.toRequestBody())
        }
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            return Self.httpResponse(for: call, with: url, job: job)
        }
    }

    @available(*, unavailable)
    public func upload(for request: URLRequest, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(for request: URLRequest) async throws -> (AsyncBytes, URLResponse) {
        guard let url = request.url else {
            throw NoURLInRequestError()
        }
        let configuration = configuration
        let job = Job()
        return withContext(job + Dispatchers.IO) {
            switch RequestType(request) {
            case .generic:
                return Self.genericBytes(for: request, with: url, job: job)
            case .http:
                let call = Self.httpCall(for: request, with: url, configuration: configuration)
                return Self.httpBytes(for: call, with: url, job: job)
            }
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    private static func genericBytes(for request: URLRequest, with url: URL, job: Job) async throws -> (AsyncBytes, URLResponse) {
        let connection = try genericConnection(for: request, with: url)
        var inputStream: java.io.InputStream? = nil
        return withTaskCancellationHandler {
            inputStream = connection.getInputStream()
            let asyncBytes = AsyncBytes(inputStream: inputStream, onClose: { inputStream?.closeQuietly() })
            let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
            return (asyncBytes: asyncBytes, response: response)
        } onCancel: {
            inputStream?.closeQuietly()
            job.cancel()
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    private static func httpBytes(for call: Call, with url: URL, job: Job) async throws -> (AsyncBytes, URLResponse) {
        return withTaskCancellationHandler {
            let response = call.execute()
            let inputStream = response.body?.byteStream()
            let asyncBytes = AsyncBytes(inputStream: inputStream, onClose: { response.closeQuietly() })
            let urlResponse = httpURLResponse(from: response, with: url)
            return (asyncBytes, urlResponse)
        } onCancel: {
            do { call.cancel() } catch {}
            job.cancel()
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

    @available(*, unavailable)
    public func dataTask(with: URL) -> URLSessionDataTask {
        fatalError()
    }

    @available(*, unavailable)
    public func dataTask(with: URL, completionHandler: (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError()
    }

    @available(*, unavailable)
    public func dataTask(with: URLRequest) -> URLSessionDataTask {
        fatalError()
    }

    @available(*, unavailable)
    public func dataTask(with: URLRequest, completionHandler: (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError()
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

    @available(*, unavailable)
    public func uploadTask(with: URLRequest, from: Data) -> URLSessionUploadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func uploadTask(with: URLRequest, from: Data?, completionHandler: (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func uploadTask(with: URLRequest, fromFile: URL) -> URLSessionUploadTask {
        fatalError()
    }

    @available(*, unavailable)
    public func uploadTask(with: URLRequest, fromFile: URL, completionHandler: (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError()
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

    @available(*, unavailable)
    public func webSocketTask(with: URL) -> URLSessionWebSocketTask {
        fatalError()
    }

    @available(*, unavailable)
    public func webSocketTask(with: URLRequest) -> URLSessionWebSocketTask {
        fatalError()
    }

    @available(*, unavailable)
    public func webSocketTask(with: URL, protocols: [String]) -> URLSessionWebSocketTask {
        fatalError()
    }

    @available(*, unavailable)
    public func finishTasksAndInvalidate() {
    }

    @available(*, unavailable)
    public func flush(completionHandler: () -> Void) {
    }

    @available(*, unavailable)
    public func getTasksWithCompletionHandler(_ handler: ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) -> Void) {
    }

    @available(*, unavailable)
    public func getAllTasks(completionHandler: ([URLSessionTask]) -> Void) {
    }

    @available(*, unavailable)
    public func invalidateAndCancel() {
    }

    @available(*, unavailable)
    public func reset(completionHandler: () -> Void) {
    }

    public var sessionDescription: String?

    @available(*, unavailable)
    public func dataTaskPublisher(for: URLRequest) -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func dataTaskPublisher(for: URL) -> Any {
        fatalError()
    }

    public enum DelayedRequestDisposition : Int, @unchecked Sendable {
        case continueLoading = 0
        case useNewRequest = 1
        case cancel = 2
    }

    public enum AuthChallengeDisposition : Int, @unchecked Sendable {
        case useCredential = 0
        case performDefaultHandling = 1
        case cancelAuthenticationChallenge = 2
        case rejectProtectionSpace = 3
    }

    public enum ResponseDisposition : Int, @unchecked Sendable {
        case cancel = 0
        case allow = 1
        case becomeDownload = 2
        case becomeStream = 3
    }
}

public protocol URLSessionTask {
}

public protocol URLSessionDataTask : URLSessionTask {
}

public protocol URLSessionDownloadTask : URLSessionTask {
}

public protocol URLSessionUploadTask : URLSessionTask {
}

public protocol URLSessionStreamTask : URLSessionTask {
}

public protocol URLSessionWebSocketTask : URLSessionTask {
}

public protocol URLSessionDelegate {
}

public protocol URLSessionTaskDelegate : URLSessionDelegate {
}

public protocol URLSessionDataDelegate : URLSessionTaskDelegate {
}

public struct NoURLInRequestError : Error {
}

public struct FailedToDownloadURLError : Error {
}

public struct DownloadUnimplentedError : Error {
}

public struct UnableToStartDownload : Error {
}

public struct DownloadUnsupportedWithRobolectric : Error {
    let status: Int
}

#endif
