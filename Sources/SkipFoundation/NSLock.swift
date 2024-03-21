// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
public protocol NSLocking {
    func lock()
    func unlock()
}

extension NSLocking {
    public func withLock<R>(_ body: () -> R) -> R {
        lock()
        defer { unlock() }
        return body()
    }
}

public final class NSLock: NSLocking, KotlinConverting<java.util.concurrent.Semaphore> {
    public let platformValue: java.util.concurrent.Semaphore

    public init() {
        platformValue = java.util.concurrent.Semaphore(1)
    }

    public init(platformValue: java.util.concurrent.Semaphore) {
        self.platformValue = platformValue
    }

    public var name: String? = nil

    public func lock() {
        platformValue.acquireUninterruptibly()
    }

    public func unlock() {
        platformValue.release()
    }

    public func `try`() -> Bool {
        return platformValue.tryAcquire()
    }

    public func lock(before: Date) -> Bool {
        let millis = before.currentTimeMillis - Date.now.currentTimeMillis
        return platformValue.tryAcquire(millis, java.util.concurrent.TimeUnit.MILLISECONDS)
    }

    public override func kotlin(nocopy: Bool = false) -> java.util.concurrent.Semaphore {
        return platformValue
    }
}

public final class NSRecursiveLock: NSLocking, KotlinConverting<java.util.concurrent.locks.Lock> {
    public let platformValue: java.util.concurrent.locks.Lock

    public init() {
        platformValue = java.util.concurrent.locks.ReentrantLock()
    }

    public init(platformValue: java.util.concurrent.locks.Lock) {
        self.platformValue = platformValue
    }

    public var name: String? = nil

    public func lock() {
        platformValue.lock()
    }

    public func unlock() {
        platformValue.unlock()
    }

    public func `try`() -> Bool {
        return platformValue.tryLock()
    }

    public func lock(before: Date) -> Bool {
        let millis = before.currentTimeMillis - Date.now.currentTimeMillis
        return platformValue.tryLock(millis, java.util.concurrent.TimeUnit.MILLISECONDS)
    }

    public override func kotlin(nocopy: Bool = false) -> java.util.concurrent.locks.Lock {
        return platformValue
    }
}
#endif
