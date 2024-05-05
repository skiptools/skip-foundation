// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias NSTimer = Timer
public typealias NSInvocation = Any
public typealias Selector = Any

public final class Timer : KotlinConverting<java.util.Timer> {
    internal let platformValue: java.util.Timer = java.util.Timer()

    @available(*, unavailable)
    public init(platformValue: java.util.Timer) {
        //self.platformValue = platformValue
    }

    public override func kotlin(nocopy: Bool = false) -> java.util.Timer {
        return platformValue
    }

    @available(*, unavailable)
    public init(timeInterval ti: TimeInterval, invocation: NSInvocation, repeats yesOrNo: Bool) {
        fatalError()
    }

    @available(*, unavailable)
    open class func scheduledTimer(timeInterval ti: TimeInterval, invocation: NSInvocation, repeats yesOrNo: Bool) -> Timer {
        fatalError()
    }

    @available(*, unavailable)
    public init(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) {
        fatalError()
    }

    @available(*, unavailable)
    open class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> Timer {
        fatalError()
    }

    @available(*, unavailable)
    public init(timeInterval interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) -> Timer {
        fatalError()
    }

    @available(*, unavailable)
    public convenience init(fire date: Date, interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    public init(fireAt date: Date, interval ti: TimeInterval, target t: Any, selector s: Selector, userInfo ui: Any?, repeats rep: Bool) {
        fatalError()
    }

    @available(*, unavailable)
    open func fire() {
        fatalError()
    }

    @available(*, unavailable)
    open var fireDate: Date {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var timeInterval: TimeInterval {
        fatalError()
    }

    @available(*, unavailable)
    open var tolerance: TimeInterval {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open func invalidate() {
        fatalError()
    }

    @available(*, unavailable)
    open var isValid: Bool {
        fatalError()
    }

    @available(*, unavailable)
    open var userInfo: Any? {
        get { fatalError() }
        set { fatalError() }
    }
}

#endif
