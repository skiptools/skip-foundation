// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public func OSAllocatedUnfairLock() -> OSAllocatedUnfairLock {
    return OSAllocatedUnfairLock(uncheckedState: ())
}

public struct OSAllocatedUnfairLock<State> : Sendable {
    private var state: State
    private let lock: java.util.concurrent.locks.Lock = java.util.concurrent.locks.ReentrantLock()

    public init(initialState: State) {
        self.state = initialState
    }

    public init(uncheckedState initialState: State) {
        self.state = initialState
    }
    
    public func lock() {
        lock.lock()
    }
   
    public func unlock() {
        lock.unlock()
    }

    public func lockIfAvailable() -> Bool {
        return lock.tryLock()
    }

    public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        return withLock(body)
    }

    public func withLockUnchecked<R>(_ body: () throws -> R) rethrows -> R {
        return withLock(body)
    }

    public func withLock<R>(_ body: (inout State) throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return body(&state)
    }

    public func withLock<R>(_ body: () throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    public func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R? {
        return withLockIfAvailable(body)
    }

    public func withLockIfAvailableUnchecked<R>(_ body: () throws -> R) rethrows -> R? {
        return withLockIfAvailable(body)
    }

    public func withLockIfAvailable<R>(_ body: @Sendable (inout State) throws -> R) rethrows -> R? {
        guard lock.tryLock() else {
            return nil
        }
        defer { lock.unlock() }
        return body(&state)
    }

    public func withLockIfAvailable<R>(_ body: () throws -> R) rethrows -> R? {
        guard lock.tryLock() else {
            return nil
        }
        defer { lock.unlock() }
        return body()
    }

    @available(*, unavailable)
    public func precondition(_ condition: Any) {
    }
}

#endif
