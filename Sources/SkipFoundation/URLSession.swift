// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

fileprivate let logger: Logger = Logger(subsystem: "skip", category: "URLSession")

public final class URLSession {
    public var configuration: URLSessionConfiguration

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

    public static let shared = URLSession(configuration: URLSessionConfiguration.default)

    public let delegate: URLSessionDelegate?
    public let delegateQueue: OperationQueue?

    private func connection(for request: URLRequest) throws -> (URL, java.net.URLConnection) {
        guard let url = request.url else {
            throw NoURLInRequestError()
        }
        let config = self.configuration

        // note that `openConnection` does not actually connect()
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

        if let httpConnection = connection as? java.net.HttpURLConnection {
            if let httpMethod = request.httpMethod {
                httpConnection.setRequestMethod(httpMethod)
            }

            httpConnection.connectTimeout = request.timeoutInterval > 0 ? (request.timeoutInterval * 1000.0).toInt() : (config.timeoutIntervalForRequest * 1000.0).toInt()
            httpConnection.readTimeout = config.timeoutIntervalForResource.toInt()
        }

        for (headerKey, headerValue) in request.allHTTPHeaderFields ?? [:] {
            connection.setRequestProperty(headerKey, headerValue)
        }

        if let httpBody = request.httpBody {
            connection.setDoOutput(true)
            let os = connection.getOutputStream()
            os.write(httpBody.platformValue)
            os.flush()
            os.close()
        }

        return (url, connection)
    }

    private func response(for url: URL, with connection: java.net.URLConnection) -> HTTPURLResponse {
        var statusCode = -1
        if let httpConnection = connection as? java.net.HttpURLConnection {
            statusCode = httpConnection.getResponseCode()
        }

        let headerFields = connection.getHeaderFields()

        let httpVersion: String? = nil // TODO: extract version from response
        var headers: [String: String] = [:]
        for (key, values) in headerFields {
            if let key = key, let values = values {
                for value in values {
                    if let value = value {
                        headers[key] = value
                    }
                }
            }
        }
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: httpVersion, headerFields: headers)
        return response!
    }

    // SKIP ATTRIBUTES: nodispatch
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let job = kotlinx.coroutines.Job()
        return kotlinx.coroutines.withContext(job + kotlinx.coroutines.Dispatchers.IO) {
            let (url, connection) = connection(for: request)
            var inputStream: java.io.InputStream? = nil
            return withTaskCancellationHandler {
                let response = response(for: url, with: connection)

                inputStream = connection.getInputStream()
                let outputStream = java.io.ByteArrayOutputStream()
                let buffer = ByteArray(1024)
                if let stableInputStream = inputStream {
                    var bytesRead: Int
                    while (stableInputStream.read(buffer).also { bytesRead = $0 } != -1) {
                        outputStream.write(buffer, 0, bytesRead)
                    }
                }
                cleanup(connection: connection, inputStream: inputStream)

                let bytes = outputStream.toByteArray()
                return (data: Data(platformValue: bytes), response: response)
            } onCancel: {
                cleanup(connection: connection, inputStream: inputStream)
                job.cancel()
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
    @available(*, unavailable)
    public func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        guard let url = request.url else {
            throw NoURLInRequestError()
        }

        // seems to be the typical way of converting from java.net.URL into android.net.Uri (which is needed by the DownloadManager)
        let uri = android.net.Uri.parse(url.description)

        let ctx = ProcessInfo.processInfo.androidContext
        let downloadManager = ctx.getSystemService(android.content.Context.DOWNLOAD_SERVICE) as android.app.DownloadManager

        let downloadRequest = android.app.DownloadManager.Request(uri)
            .setAllowedOverMetered(self.configuration.allowsExpensiveNetworkAccess)
            .setAllowedOverRoaming(self.configuration.allowsConstrainedNetworkAccess)
            .setShowRunningNotification(true)

        for (headerKey, headerValue) in request.allHTTPHeaderFields ?? [:] {
            downloadRequest.addRequestHeader(headerKey, headerValue)
        }

        let downloadId = downloadManager.enqueue(downloadRequest)
        let query = android.app.DownloadManager.Query()
            .setFilterById(downloadId)

        // Query the DownloadManager for the response, which returns a SQLite cursor with the current download status of all the outstanding downloads.
        func queryDownload() -> Result<(URL, URLResponse), Error>? {
            let cursor = downloadManager.query(query)

            defer { cursor.close() }

            if !cursor.moveToFirst() {
                // download not found
                let error = UnableToStartDownload()
                return Result.failure(error)
            }

            let status = cursor.getInt(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_STATUS))
            let uri = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_URI)) // URI to be downloaded.

            // STATUS_FAILED, STATUS_PAUSED, STATUS_PENDING, STATUS_RUNNING, STATUS_SUCCESSFUL
            if status == android.app.DownloadManager.STATUS_PAUSED {
                return nil
            }
            if status == android.app.DownloadManager.STATUS_PENDING {
                return nil
            }

            //let desc = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_DESCRIPTION)) // The client-supplied description of this download // NPE
            //let id = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_ID)) // An identifier for a particular download, unique across the system. // NPE
            // let lastModified = cursor.getLong(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_LAST_MODIFIED_TIMESTAMP)) // Timestamp when the download was last modified, in System.currentTimeMillis() (wall clock time in UTC).

            // Error: java.lang.SecurityException: COLUMN_LOCAL_FILENAME is deprecated; use ContentResolver.openFileDescriptor() instead
            // let localFilename = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_LOCAL_FILENAME)) // Path to the downloaded file on disk.

            //let localURI = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_LOCAL_URI)) // Uri where downloaded file will be stored. // NPE
            // let mediaproviderURI = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_MEDIAPROVIDER_URI)) // The URI to the corresponding entry in MediaProvider for this downloaded entry. // NPE
            //let mediaType = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_MEDIA_TYPE)) // Internet Media Type of the downloaded file.
            let reason = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_REASON)) // Provides more detail on the status of the download.
            //let title = cursor.getString(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_TITLE)) // The client-supplied title for this download.
            let totalSizeBytes = cursor.getLong(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_TOTAL_SIZE_BYTES)) // Total size of the download in bytes.
            let bytesDownloaded = cursor.getLong(cursor.getColumnIndexOrThrow(android.app.DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR)) // Number of bytes download so far.

            if status == android.app.DownloadManager.STATUS_RUNNING {
                // TODO: update progress
                //  if let progress = Progress.current() {
                //  }
                return nil
            } else if status == android.app.DownloadManager.STATUS_SUCCESSFUL {
                let httpVersion: String? = nil // TODO: extract version from response
                var headers: [String: String] = [:]
                let statusCode = 200 // TODO: extract status code
                headers["Content-Length"] = totalSizeBytes?.description
                //headers["Last-Modified"] = lastModified // TODO: convert to Date
                let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: httpVersion, headerFields: headers)
                //let localURL = URL(fileURLWithPath: localFilename)

                // Type mismatch: inferred type is String! but Uri was expected
//                guard let pfd = ctx.getContentResolver().openFileDescriptor(uri, "r") else {
//                    // TODO: create error from error
//                    let error = FailedToDownloadURLError()
//                    return Result.failure(error)
//                }

                // unfortunately we cannot get a file path from a descriptor, so we need to copy the contents to a temporary file, and then return that one
                return Result.failure(DownloadUnimplentedError())
                // TODO: return Result.success((localURL as URL, response as URLResponse))
            } else if status == android.app.DownloadManager.STATUS_FAILED {
                // File download failed
                // TODO: create error from error
                let error = FailedToDownloadURLError()
                return Result.failure(error)
            } else {
                // no known android.app.DownloadManager.STATUS_*
                // this can happen with Robolectric tests, since ShadowDownloadManager is just a stub and it sets 0 for the status
                let error = DownloadUnsupportedWithRobolectric(status: status)
                return Result.failure(error)
            }

            return nil
        }

        let isRobolectric = (try? Class.forName("org.robolectric.Robolectric")) != nil

        let response: Result<(URL, URLResponse), Error> = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
            if isRobolectric {
                // Robolectric's ShadowDownloadManager doesn't actually download anything, so we fake it for testing by just getting the data in-memory (hoping it isn't too large!) and saving it to a temporary file
                do {
                    let (data, response) = try await data(for: request)
                    let outputFileURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                    try data.write(to: outputFileURL)
                    return Result.success((outputFileURL, response))
                } catch {
                    return Result.failure(error)
                }
            } else {
                // initiate using android.app.DownloadManager
                // TODO: rather than polling in a loop, we could do android.registerBroadcastReceiver(android.app.DownloadManager.ACTION_DOWNLOAD_COMPLETE, handleDownloadEvent)
                while true {
                    if let downloadResult = queryDownload() {
                        return downloadResult
                    }
                    kotlinx.coroutines.delay(250) // wait and poll again
                }
            }
            return Result.failure(FailedToDownloadURLError()) // needed for Kotlin type checking
        }

        switch response {
        case .failure(let error): throw error
        case .success(let urlResponseTuple): return urlResponseTuple
        }
    }

    @available(*, unavailable)
    public func download(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    @available(*, unavailable)
    public func download(from url: URL) async throws -> (URL, URLResponse) {
        // return self.download(for: URLRequest(url: url))
        fatalError()
    }

    @available(*, unavailable)
    public func download(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse) {
        // return self.download(for: URLRequest(url: url))
        fatalError()
    }

    @available(*, unavailable)
    func download(resumeFrom: Data, delegate: URLSessionTaskDelegate?) -> (URL, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        let job = kotlinx.coroutines.Job()
        return kotlinx.coroutines.withContext(job + kotlinx.coroutines.Dispatchers.IO) {
            let data = Data(contentsOfFile: fileURL.absoluteString)
            request.httpBody = data
            return upload(for: request, job: job)
        }
    }

    @available(*, unavailable)
    public func upload(for request: URLRequest, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        let job = kotlinx.coroutines.Job()
        return kotlinx.coroutines.withContext(job + kotlinx.coroutines.Dispatchers.IO) {
            request.httpBody = bodyData
            return upload(for: request, job: job)
        }
    }

    @available(*, unavailable)
    public func upload(for request: URLRequest, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    private func upload(for request: URLRequest, job: kotlinx.coroutines.Job) async -> (Data, URLResponse) {
        let (url, connection) = connection(for: request)
        var inputStream: java.io.InputStream? = nil
        return withTaskCancellationHandler {
            let response = response(for: url, with: connection)

            inputStream = connection.getInputStream()
            let responseData = java.io.BufferedInputStream(inputStream).readBytes()
            cleanup(connection: connection, inputStream: inputStream)

            return (Data(platformValue: responseData), response as URLResponse)
        } onCancel: {
            cleanup(connection: connection, inputStream: inputStream)
            job.cancel()
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(for request: URLRequest) async throws -> (AsyncBytes, URLResponse) {
        let job = kotlinx.coroutines.Job()
        return kotlinx.coroutines.withContext(job + kotlinx.coroutines.Dispatchers.IO) {
            let (url, connection) = connection(for: request)
            withTaskCancellationHandler {
                let response = response(for: url, with: connection)
                let inputStream = connection.getInputStream()
                let stream = AsyncBytes(connection: connection, inputStream: inputStream)
                return (stream, response)
            } onCancel: {
                cleanup(connection: connection, inputStream: nil)
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
        
        let connection: java.net.URLConnection
        var inputStream: java.io.InputStream?

        init(connection: java.net.URLConnection, inputStream: java.io.InputStream) {
            self.connection = connection
            self.inputStream = inputStream
        }

        deinit {
            close()
        }

        override func makeAsyncIterator() -> Iterator {
            return Iterator(bytes: self)
        }

        func close() {
            cleanup(connection: connection, inputStream: inputStream)
            inputStream = nil
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

private func cleanup(connection: java.net.URLConnection, inputStream: java.io.InputStream?) {
    do { inputStream?.close() } catch {}
    if let httpConnection = connection as? java.net.HttpURLConnection {
        do { httpConnection.disconnect() }
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
