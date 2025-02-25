// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// Stubs that allow SkipModel to implement Publisher.receive(on:) for the main queue

public protocol Scheduler {
}

public struct RunLoop : Scheduler {
    public static let main = RunLoop()

    public enum Mode: Int {
        case `default`, common, eventTracking, modalPanel, tracking
    }

    public struct SchedulerOptions {
    }

    private init() {
    }

    public func add(_ timer: Timer, forMode mode: Mode) {
        timer.start() // We don't yet support non-main run loops and timer always uses main
    }
}

public typealias DispatchWallTime = Double
public typealias DispatchTime = Double

// Mirror Double's cast functions, which typealiasing doesn't cover
public func DispatchWallTime(number: Number) -> DispatchWallTime {
    return Double(number: number)
}
public func DispatchWallTime(number: UInt8) -> DispatchWallTime {
    return Double(number: number)
}
public func DispatchWallTime(number: UInt16) -> DispatchWallTime {
    return Double(number: number)
}
public func DispatchWallTime(number: UInt32) -> DispatchWallTime {
    return Double(number: number)
}
public func DispatchWallTime(number: UInt64) -> DispatchWallTime {
    return Double(number: number)
}
public func DispatchWallTime(string: String) -> DispatchWallTime? {
    return Double(string: string)
}
public func DispatchTime(number: Number) -> DispatchTime {
    return Double(number: number)
}
public func DispatchTime(number: UInt8) -> DispatchTime {
    return Double(number: number)
}
public func DispatchTime(number: UInt16) -> DispatchTime {
    return Double(number: number)
}
public func DispatchTime(number: UInt32) -> DispatchTime {
    return Double(number: number)
}
public func DispatchTime(number: UInt64) -> DispatchTime {
    return Double(number: number)
}
public func DispatchTime(string: String) -> DispatchTime? {
    return Double(string: string)
}

extension Double {
    public static func now() -> Double {
        Double(System.currentTimeMillis()) / 1000.0
    }
}

public struct DispatchQueue : Scheduler {
    public static let main = DispatchQueue()

    private init() {
    }

    @available(*, unavailable)
    public init(label: String, qos: Any, attributes: Any, autoreleaseFrequency: Any, target: DispatchQueue?) {
    }

    @available(*, unavailable)
    public static func global(qos: Any) -> DispatchQueue {
        fatalError()
    }

    public func async(execute: () -> Void) {
        GlobalScope.launch(Dispatchers.Main) {
            execute()
        }
    }

    // SKIP DECLARE: fun asyncAfter(deadline: Double, unusedp: Nothing? = null, execute: () -> Unit)
    public func asyncAfter(deadline: DispatchTime, execute: () -> Void) {
        GlobalScope.launch(Dispatchers.Main) {
            delay(Int64(deadline * 1000.0) - System.currentTimeMillis())
            execute()
        }
    }

    @available(*, unavailable)
    public func asyncAfter(deadline: DispatchTime, qos: Any, flags: Any, execute: () -> Void) {
    }

    public func asyncAfter(wallDeadline: DispatchWallTime, execute: () -> Void) {
        GlobalScope.launch(Dispatchers.Main) {
            delay(Int64(wallDeadline * 1000.0) - System.currentTimeMillis())
            execute()
        }
    }

    @available(*, unavailable)
    public func asyncAfter(wallDeadline: DispatchWallTime, qos: Any, flags: Any, execute: () -> Void) {
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
