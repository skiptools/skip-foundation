// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

import android.os.Looper
import java.util.LinkedHashMap
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

public class NotificationCenter {
    private var registries: MutableMap<String?, Registry> = mutableMapOf()

    public static let `default` = NotificationCenter()

    public func addObserver(forName name: Notification.Name?, object: Any?, queue: OperationQueue?, using block: (Notification) -> Void) -> Any {
        let observer = Observer(forObject: object, queue: queue, block: block)
        let registry: Registry
        synchronized(self) {
            var r = registries[name?.rawValue]
            if r == nil {
                r = Registry(name: name?.rawValue)
                registries[name?.rawValue] = r
            }
            registry = r!
        }
        return registry.register(observer)
    }

    @available(*, unavailable)
    public func addObserver(_ observer: Any, selector: Any, name: Notification.Name?, object: Any?) {
    }

    @available(*, unavailable)
    public func removeObserver(_ observer: Any, name: Notification.Name?, object: Any?) {
    }

    public func removeObserver(_ observer: Any) {
        guard let observerId = observer as? ObserverId else {
            return
        }
        let registry: Registry?
        synchronized(self) {
            registry = registries[observerId.name]
        }
        registry?.unregister(observerId)
    }

    public func post(_ notification: Notification) {
        let allRegistry: Registry?
        let registry: Registry?
        synchronized(self) {
            allRegistry = registries[nil]
            registry = registries[notification.name.rawValue]
        }
        allRegistry?.post(notification)
        registry?.post(notification)
    }

    public func post(name: Notification.Name, object: Any?, userInfo: [AnyHashable: Any]? = nil) {
        post(Notification(name: name, object: object, userInfo: userInfo))
    }

    @available(*, unavailable)
    public func notifications(named: Notification.Name, object: AnyObject? = nil) -> Any {
        fatalError()
    }

    private struct Observer {
        let forObject: Any?
        let queue: OperationQueue?
        let block: (Notification) -> Void
    }

    private struct ObserverId : Hashable {
        let name: String?
        let id: Int
    }

    private class Registry {
        let name: String?
        let observers: LinkedHashMap<Int, Observer> = LinkedHashMap<Int, Observer>()
        var nextId = 0

        init(name: String?) {
            self.name = name
        }

        func register(_ observer: Observer) -> ObserverId {
            let id: Int
            synchronized(self) {
                id = nextId
                nextId += 1
                observers[id] = observer
            }
            return ObserverId(name: name, id: id)
        }

        func unregister(_ observerId: ObserverId) {
            synchronized(self) {
                observers.remove(observerId.id)
            }
        }

        // SKIP INSERT: @OptIn(DelicateCoroutinesApi::class)
        func post(_ notification: Notification) {
            let matches: List<Observer>
            synchronized(self) {
                matches = observers.values.mapNotNull { observer in
                    guard observer.forObject == nil || observer.forObject == notification.object else {
                        return nil
                    }
                    return observer
                }
            }
            for match in matches {
                if match.queue == OperationQueue.main && Looper.myLooper() != Looper.getMainLooper() {
                    GlobalScope.launch {
                        withContext(Dispatchers.Main) {
                            match.block(notification)
                        }
                    }
                } else {
                    match.block(notification)
                }
            }
        }
    }
}

public struct Notification {
    public var name: Notification.Name
    public var object: Any?
    public var userInfo: [AnyHashable: Any]?

    public init(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        self.name = name
        self.object = object
        self.userInfo = userInfo
    }

    public struct Name: RawRepresentable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ value: String) {
            self.rawValue = value
        }
    }
}

#endif
