// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

public typealias NSTimer = Timer

public final class Timer : KotlinConverting<java.util.Timer?> {
    private var timer: java.util.Timer?
    private var repeats = false
    private var block: ((Timer) -> Void)?
    private var invalidated = false

    public init(platformValue: java.util.Timer) {
        self.timer = platformValue
    }

    public override func kotlin(nocopy: Bool = false) -> java.util.Timer? {
        return timer
    }

    @available(*, unavailable)
    public init(timeInterval ti: TimeInterval, invocation: Any, repeats: Bool) {
        fatalError()
    }

    @available(*, unavailable)
    open class func scheduledTimer(timeInterval ti: TimeInterval, invocation: Any, repeats: Bool) -> Timer {
        fatalError()
    }

    @available(*, unavailable)
    public init(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Any, userInfo: Any?, repeats: Bool) {
        fatalError()
    }

    @available(*, unavailable)
    open class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Any, userInfo: Any?, repeats: Bool) -> Timer {
        fatalError()
    }

    public init(timeInterval: TimeInterval, repeats: Bool, block: (Timer) -> Void) {
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.block = block
    }

    public static func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: (Timer) -> Void) -> Timer {
        let timer = Timer(timeInterval: interval, repeats: repeats, block: block)
        timer.start()
        return timer
    }

    @available(*, unavailable)
    public convenience init(fire date: Date, interval: TimeInterval, repeats: Bool, block: (Timer) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    public init(fireAt date: Date, interval ti: TimeInterval, target t: Any, selector s: Any, userInfo ui: Any?, repeats rep: Bool) {
        fatalError()
    }

    @available(*, unavailable)
    public func fire() {
        fatalError()
    }

    @available(*, unavailable)
    public var fireDate: Date {
        get { fatalError() }
        set { fatalError() }
    }

    public private(set) var timeInterval: TimeInterval = 0.0

    @available(*, unavailable)
    public var tolerance: TimeInterval {
        get { fatalError() }
        set { fatalError() }
    }

    public func invalidate() {
        synchronized(self) {
            timer?.cancel()
            timer = nil
            block = nil
            invalidated = true
        }
    }

    public var isValid: Bool {
        synchronized(self) {
            return !invalidated
        }
    }

    public var userInfo: Any?

    /// Used by the run loop to start the timer.
    public func start() {
        synchronized(self) {
            guard !invalidated && block != nil else {
                return
            }
            let block = self.block
            let timerTask = Task { block?(self) }
            timer = java.util.Timer(true)
            let delayms = Int64(timeInterval * 1000.0)
            if repeats {
                timer?.schedule(timerTask, delayms, delayms)
            } else {
                timer?.schedule(timerTask, delayms)
            }
        }
    }

    private final class Task: java.util.TimerTask {
        let task: () -> Void

        init(task: () -> Void) {
            self.task = task
        }

        override func run() {
            GlobalScope.launch(Dispatchers.Main) {
                task()
            }
        }
    }
}

#endif
