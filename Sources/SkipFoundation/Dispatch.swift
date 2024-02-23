// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

// Stubs that allow SkipModel to implement Publisher.receive(on:) for the main queue

public protocol Scheduler {
}

public struct RunLoop : Scheduler {
    public static let main = RunLoop()

    private init() {
    }
}

public struct DispatchQueue : Scheduler {
    public static let main = DispatchQueue()

    private init() {
    }

    @available(*, unavailable)
    init(label: String, qos: Any, attributes: Any, autoreleaseFrequency: Any, target: DispatchQueue?) {
    }

    @available(*, unavailable)
    public static func global(qos: Any) -> DispatchQueue {
        fatalError()
    }

    @available(*, unavailable)
    public func async(execute: () -> Void) {
    }

    @available(*, unavailable)
    public func asyncAfter(deadline: Any, execute: () -> Void) {
    }

    @available(*, unavailable)
    public func asyncAfter(deadline: Any, qos: Any, flags: Any, execute: () -> Void) {
    }

    @available(*, unavailable)
    public func asyncAfter(wallDeadline: Any, execute: () -> Void) {
    }

    @available(*, unavailable)
    public func asyncAfter(wallDeadline: Any, qos: Any, flags: Any, execute: () -> Void) {
    }

    @available(*, unavailable)
    public func sync(execute: () -> Void) {
    }

    @available(*, unavailable)
    public func sync(execute: () -> Any) -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func sync(flags: Any, execute: () -> Any) -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func asyncAndWait(execute: () -> Void) {
    }

    @available(*, unavailable)
    public static func concurrentPerform(iterations: Int, execute: (Int) -> Void) {
    }

    @available(*, unavailable)
    public func async(group: Any, execute: () -> Void) {
    }

    @available(*, unavailable)
    public func async(group: Any?, qos: Any, flags: Any, execute: () -> Void) {
    }

    @available(*, unavailable)
    public var label: String {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var qos: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public func setTarget(queue: Any?) {
    }

    @available(*, unavailable)
    public func setSpecific(key: Any, value: Any?) {
    }

    @available(*, unavailable)
    public func getSpecific(key: Any) -> Any? {
        fatalError()
    }

    @available(*, unavailable)
    public static func getSpecific(key: Any) -> Any? {
        fatalError()
    }

    @available(*, unavailable)
    public func dispatchMain() -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func schedule(options: Any?, _ operation: () -> Void) {
    }

    @available(*, unavailable)
    public func schedule(after: Any, tolerance: Any, options: Any?, _ operation: () -> Void) {
    }

    @available(*, unavailable)
    public func schedule(after: Any, interval: Any, tolerance: Any, options: Any?, _ operation: () -> Void) -> Any {
        fatalError()
    }
}

#endif
