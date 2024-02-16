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
    }

    public static let shared = URLSession(configuration: URLSessionConfiguration.default)

    private func openConnection(request: URLRequest) -> java.net.URLConnection {
        let config = self.configuration
        guard let url = request.url else {
            throw NoURLInRequestError()
        }

        // note that `openConnection` does not actually connect(); we do that below in a Dispatchers.IO coroutine
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

        return connection
    }

    private func connect(request: URLRequest) -> (java.net.URLConnection, HTTPURLResponse) {
        let connection = try openConnection(request: request)

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

        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: httpVersion, headerFields: headers)
        return (connection, response!)
    }

    // SKIP ATTRIBUTES: nodispatch
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
            let (connection, response) = try connect(request: request)
            let inputStream = connection.getInputStream()
            let outputStream = java.io.ByteArrayOutputStream()
            let buffer = ByteArray(1024)
            var bytesRead: Int
            while (inputStream.read(buffer).also { bytesRead = $0 } != -1) {
                outputStream.write(buffer, 0, bytesRead)
            }
            inputStream.close()

            let bytes = outputStream.toByteArray()
            return (data: Data(platformValue: bytes), response: response as HTTPURLResponse)
        }

        return (data, response)
    }

    // SKIP ATTRIBUTES: nodispatch
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        return self.data(for: URLRequest(url: url))
    }

    public func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        // WARNING: this is untested, since Robolectric's ShadowDownloadManager is a stub
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

    // SKIP ATTRIBUTES: nodispatch
    public func download(from url: URL) async throws -> (URL, URLResponse) {
        return self.download(for: URLRequest(url: url))
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        return kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
            let data = Data(contentsOfFile: fileURL.absoluteString)
            return uploadSync(for: request, from: data)
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        return kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
            return uploadSync(for: request, from: bodyData)
        }
    }

    private func uploadSync(for request: URLRequest, from bodyData: Data) -> (Data, URLResponse) {
        request.httpBody = bodyData
        let (connection, response) = connect(request: request)
        let responseData = java.io.BufferedInputStream(connection.inputStream).readBytes()
        (connection as? java.net.HttpURLConnection)?.disconnect()
        return (Data(platformValue: responseData), response as URLResponse)
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(from url: URL) async throws -> (AsyncBytes, URLResponse) {
        return bytes(for: URLRequest(url: url))
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(for request: URLRequest) async throws -> (AsyncBytes, URLResponse) {
        return kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
            let (connection, response) = try connect(request: request)
            let stream = AsyncBytes(connection: connection)
            return (stream, response)
        }
    }

    public struct AsyncBytes: AsyncSequence {
        typealias Element = UInt8
        
        let connection: java.net.URLConnection

        override func makeAsyncIterator() -> Iterator {
            return Iterator(inputStream: connection.getInputStream())
        }

        public final class Iterator: AsyncIteratorProtocol {
            private var inputStream: java.io.InputStream?

            init(inputStream: java.io.InputStream) {
                self.inputStream = inputStream
            }

            deinit {
                close()
            }

            override func next() async -> UInt8? {
                guard let byte = try? inputStream?.read(), byte != -1 else {
                    close()
                    return nil
                }
                return UInt8(byte)
            }

            private func close() {
                do { inputStream?.close() } catch {}
                inputStream = nil
            }
        }
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
