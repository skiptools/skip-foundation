// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP
import kotlinx.coroutines.channels.Channel
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody

public final class URLSession {
    public static let shared = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil, isShared: true)

    private static var sessions: [Int: URLSession] = [:]
    private static var nextSessionIdentifier = 0
    private static let sessionsLock = NSRecursiveLock()

    public let configuration: URLSessionConfiguration
    public private(set) var delegate: URLSessionDelegate?
    public private(set) var delegateQueue: OperationQueue

    private let identifier: Int
    private let lock = NSRecursiveLock()
    private var nextTaskIdentifier = 0
    private var tasks: [Int: URLSessionTask] = [:]
    private var invalidateOnCompletion = false

    public init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate? = nil, delegateQueue: OperationQueue? = nil) {
        self.init(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue, isShared: false)
    }

    private init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?, isShared: Bool) {
        self.configuration = configuration
        self.delegate = delegate
        self.delegateQueue = delegateQueue ?? OperationQueue()
        var identifier = -1
        if !isShared {
            Self.sessionsLock.withLock {
                identifier = Self.nextSessionIdentifier
                Self.nextSessionIdentifier += 1
                Self.sessions[identifier] = self
            }
        }
        self.identifier = identifier
    }

    public var sessionDescription: String?

    // SKIP ATTRIBUTES: nodispatch
    public func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        runDataTask(delegate: delegate, factory: { completionHandler in
            return dataTask(with: request, completionHandler: completionHandler)
        })
    }

    private func runDataTask(delegate: URLSessionTaskDelegate?, factory: ((Data?, URLResponse?, Error?) -> Void) -> URLSessionTask) async throws -> (Data, URLResponse) {
        let channel = Channel<(Data?, URLResponse?, Error?)>(1)
        let task = factory { data, response, error in
            channel.trySend((data, response, error))
        }
        task.delegate = delegate
        task.resume()
        let (data, response, error) = channel.receive()
        channel.close()
        if let error {
            throw error
        } else if let data, let response {
            return (data, response)
        } else {
            throw URLError(.unknown)
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    public func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        return self.data(for: URLRequest(url: url), delegate: delegate)
    }

    @available(*, unavailable)
    public func download(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (URL, URLResponse) {
        // NOTE: Partial implementation was here prior to 4/7/2024. See git history to revive
        fatalError()
    }

    @available(*, unavailable)
    public func download(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (URL, URLResponse) {
        fatalError()
    }

    @available(*, unavailable)
    func download(resumeFrom: Data, delegate: URLSessionTaskDelegate? = nil) -> (URL, URLResponse) {
        fatalError()
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, fromFile fileURL: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        runDataTask(delegate: delegate, factory: { completionHandler in
            return uploadTask(with: request, fromFile: fromFile, completionHandler: completionHandler)
        })
    }

    // SKIP ATTRIBUTES: nodispatch
    public func upload(for request: URLRequest, from bodyData: Data, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        runDataTask(delegate: delegate, factory: { completionHandler in
            return uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
        })
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (AsyncBytes, URLResponse) {
        let channel = Channel<(URLResponse?, Error?)>(1)
        let task = dataTask(with: request) { _, response, error in
            channel.trySend((response, error))
        }
        task.delegate = delegate
        task.isForResponse = true
        task.resume()
        let (response, error) = channel.receive()
        channel.close()
        if let error {
            throw error
        } else if let response, let genericConnection = task.genericConnection {
            let inputStream = genericConnection.getInputStream()
            let asyncBytes = AsyncBytes(inputStream: inputStream, onClose: { do { inputStream?.close() } catch {} })
            return (asyncBytes, response)
        } else if let response, let httpResponse = task.httpResponse {
            let inputStream = httpResponse.body?.byteStream()
            let asyncBytes = URLSession.AsyncBytes(inputStream: inputStream, onClose: { do { httpResponse.close() } catch {} })
            return (asyncBytes, response)
        } else {
            throw URLError(.unknown)
        }
    }

    // SKIP ATTRIBUTES: nodispatch
    public func bytes(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (AsyncBytes, URLResponse) {
        return bytes(for: URLRequest(url: url), delegate: delegate)
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

    public func dataTask(with url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        return dataTask(with: URLRequest(url: url), completionHandler: completionHandler)
    }

    public func dataTask(with request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        let task = lock.withLock {
            let identifier = nextTaskIdentifier
            nextTaskIdentifier += 1
            let task = URLSessionDataTask(session: self, request: request, taskIdentifier: identifier, completionHandler: completionHandler)
            tasks[task.taskIdentifier] = task
            return task
        }
        taskDidCreate(task)
        return task
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
        let task = lock.withLock {
            let identifier = nextTaskIdentifier
            nextTaskIdentifier += 1
            let task = URLSessionUploadTask(session: self, request: request, taskIdentifier: identifier, build: {
                if let bodyData {
                    $0.post(bodyData.platformValue.toRequestBody())
                }
            }, completionHandler: completionHandler)
            tasks[task.taskIdentifier] = task
            return task
        }
        taskDidCreate(task)
        return task
    }

    public func uploadTask(with request: URLRequest, fromFile url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) -> URLSessionUploadTask {
        let file = java.io.File(url.absoluteURL.platformValue)
        let task = lock.withLock {
            let identifier = nextTaskIdentifier
            nextTaskIdentifier += 1
            let task = URLSessionUploadTask(session: self, request: request, taskIdentifier: identifier, build: {
                $0.post(file.asRequestBody())
            }, completionHandler: completionHandler)
            tasks[task.taskIdentifier] = task
            return task
        }
        taskDidCreate(task)
        return task
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
        let task = lock.withLock {
            let identifier = nextTaskIdentifier
            nextTaskIdentifier += 1
            let task = URLSessionWebSocketTask(session: self, request: request, taskIdentifier: identifier)
            tasks[task.taskIdentifier] = task
            return task
        }
        taskDidCreate(task)
        return task
    }

    public func webSocketTask(with url: URL, protocols: [String]) -> URLSessionWebSocketTask {
        var request = URLRequest(url: url)
        request.setValue(protocols.joined(separator: ", "), forHTTPHeaderField: "Sec-WebSocket-Protocol")
        return webSocketTask(with: request)
    }

    /// We call this after task creation to inform our delegate.
    private func taskDidCreate(_ task: URLSessionTask) {
        if let taskDelegate = delegate as? URLSessionTaskDelegate {
            taskDelegate.urlSession(self, didCreateTask: task)
        }
    }

    /// Called by tasks to remove them from the session.
    func taskDidComplete(_ task: URLSessionTask) {
        lock.withLock {
            tasks[task.taskIdentifier] = nil
            if tasks.isEmpty, invalidateOnCompletion {
                invalidate()
            }
        }
    }

    /// Invalidate this session. Called with lock.
    private func invalidate() {
        Self.sessionsLock.withLock {
            Self.sessions[identifier] = nil
        }
        if let delegate {
            delegateQueue.runBlock {
                delegate.urlSession(self, didBecomeInvalidWithError: nil)
            }
        }
    }

    public func finishTasksAndInvalidate() {
        guard identifier >= 0 else {
            return
        }
        lock.withLock {
            if tasks.isEmpty {
                invalidate()
            } else {
                invalidateOnCompletion = true
            }
        }
    }

    @available(*, unavailable)
    public func flush(completionHandler: () -> Void) {
    }

    public func getTasksWithCompletionHandler(_ handler: ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) -> Void) {
        let (dataTasks, uploadTasks, downloadTasks) = tasksByType
        handler(dataTasks, uploadTasks, downloadTasks)
    }

    public var tasks: ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) {
        get async {
            return tasksByType
        }
    }

    private var tasksByType: ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) {
        return lock.withLock {
            var dataTasks: [URLSessionDataTask] = []
            var uploadTasks: [URLSessionUploadTask] = []
            var downloadTasks: [URLSessionDownloadTask] = []
            for task in tasks.values {
                if let dataTask = task as? URLSessionDataTask {
                    dataTasks.append(dataTask)
                } else if let uploadTask = task as? URLSessionUploadTask {
                    uploadTasks.append(uploadTask)
                } else if let downloadTask = task as? URLSessionDownloadTask {
                    downloadTasks.append(downloadTask)
                }
            }
            return (dataTasks, uploadTasks, downloadTasks)
        }
    }

    public func getAllTasks(handler: ([URLSessionTask]) -> Void) {
        let allTasks = lock.withLock {
            Array(tasks.values)
        }
        handler(allTasks)
    }

    public var allTasks: [URLSessionTask] {
        get async {
            return lock.withLock {
                Array(tasks.values)
            }
        }
    }

    public func invalidateAndCancel() {
        guard identifier >= 0 else {
            return
        }
        lock.withLock {
            if tasks.isEmpty {
                invalidate()
            } else {
                invalidateOnCompletion = true
                for task in tasks.values {
                    do { task.cancel() } catch {}
                }
            }
        }
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
