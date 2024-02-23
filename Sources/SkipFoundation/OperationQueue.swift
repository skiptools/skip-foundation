// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class OperationQueue {
    /// Stub representing the main queue.
    public static let main = OperationQueue()

    @available(*, unavailable)
    public static var current: OperationQueue? {
        return nil
    }

    @available(*, unavailable)
    public func addOperation(_ operation: Operation) {
    }

    @available(*, unavailable)
    public func addOperations(_ operations: [Operation], waitUntilFinished: Bool) {
    }

    @available(*, unavailable)
    public func addOperation(_ value: () -> Void) {
    }

    @available(*, unavailable)
    public func addBarrierBlock(_ value: () -> Void) {
    }

    @available(*, unavailable)
    public func cancelAllOperations() {
    }

    @available(*, unavailable)
    public func waitUntilAllOperationsAreFinished() {
    }

    @available(*, unavailable)
    public var operations: [Operation] {
        fatalError()
    }

    @available(*, unavailable)
    public var operationCount: Int {
        fatalError()
    }

    @available(*, unavailable)
    public var qualityOfService: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var maxConcurrentOperationCount: Int {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public static var defaultMaxConcurrentOperationCount: Int {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var progress: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var isSuspended: Bool {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var name: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var underlyingQueue: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public func schedule(after: Any, tolerance: Any, options: Any?, _ operation: () -> Void) {
    }

    @available(*, unavailable)
    public func schedule(after: Any, interval: Any, tolerance: Any, options: Any?, _ operation: () -> Void) -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func schedule(options: Any?, _ operation: () -> Void) {
    }

    @available(*, unavailable)
    public var now: Any {
        fatalError()
    }

    @available(*, unavailable)
    public var minimumTolerance: Any? {
        get {
            fatalError()
        }
        set {
        }
    }
}

public class Operation {
    @available(*, unavailable)
    public init() {
    }

    @available(*, unavailable)
    public func start() {
    }

    @available(*, unavailable)
    public func main() {
    }

    @available(*, unavailable)
    public var completionBlock: (() -> Void)? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public func cancel() {
    }

    @available(*, unavailable)
    public var isCancelled: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var isExecuting: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var isFinished: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var isConcurrent: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var isAsynchronous: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var isReady: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var name: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public func addDependency(_ operation: Operation) {
        fatalError()
    }

    @available(*, unavailable)
    public func removeDependency(_ operation: Operation) {
        fatalError()
    }

    @available(*, unavailable)
    public var dependencies: [Operation] {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var qualityOfService: QualityOfService {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var queuePriority: Operation.QueuePriority {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public func waitUntilFinished() {
    }

    public enum QueuePriority: Int {
        case veryLow, low, normal, high, veryHigh
    }
}

public enum QualityOfService: Int {
    case userInteractive, userInitiated, utility, background, `default`
}

#endif
