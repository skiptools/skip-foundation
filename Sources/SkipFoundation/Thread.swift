// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public typealias NSThread = Thread

public struct Thread : Hashable, Sendable, KotlinConverting<java.lang.Thread> {
    internal var platformValue: java.lang.Thread

    /// Re-initialized from `ProcessInfo.launch(context:)`
    public internal(set) static var main: Thread = Thread.current

    public static var isMainThread: Bool {
        Thread.current == Thread.main
    }

    public var isMainThread: Bool {
        self == Thread.main
    }

    public static var current: Thread {
        return Thread(platformValue: java.lang.Thread.currentThread())
    }

    public var isExecuting: Bool {
        self == Thread.current
    }

    public static var callStackSymbols: [String] {
        Array(Thread.current.platformValue.getStackTrace().map({ $0.toString() }))
    }

    public static func sleep(forTimeInterval: TimeInterval) {
        java.lang.Thread.sleep(Long(forTimeInterval * 1000.0))
    }

    public static func sleep(until date: Date) {
        sleep(forTimeInterval: date.timeIntervalSince(Date.now))
    }

    public override func kotlin(nocopy: Bool = false) -> java.lang.Thread {
        return platformValue
    }

    public func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Thread else {
            return false
        }
        return self.platformValue == other.platformValue
    }

    public static func ==(lhs: Thread, rhs: Thread) -> Bool {
        return lhs.platformValue == rhs.platformValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(platformValue)
    }
}

#endif
