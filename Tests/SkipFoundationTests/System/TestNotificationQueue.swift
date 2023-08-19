// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestNotificationQueue : XCTestCase {

    func test_defaultQueue() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let defaultQueue1 = NotificationQueue.default
        let defaultQueue2 = NotificationQueue.default
        XCTAssertEqual(defaultQueue1, defaultQueue2)

        executeInBackgroundThread() {
            let defaultQueueForBackgroundThread = NotificationQueue.default
            XCTAssertEqual(defaultQueueForBackgroundThread, NotificationQueue.default)
            XCTAssertNotEqual(defaultQueueForBackgroundThread, defaultQueue1)
        }
        #endif // !SKIP
    }

    func test_postNowToDefaultQueueWithoutCoalescing() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let notificationName = Notification.Name(rawValue: "test_postNowWithoutCoalescing")
        let dummyObject = NSObject()
        let notification = Notification(name: notificationName, object: dummyObject)
        var numberOfCalls = 0
        let obs = NotificationCenter.default.addObserver(forName: notificationName, object: dummyObject, queue: nil) { notification in
            numberOfCalls += 1
        }
        let queue = NotificationQueue.default
        queue.enqueue(notification, postingStyle: .now)
        XCTAssertEqual(numberOfCalls, 1)
        NotificationCenter.default.removeObserver(obs)
        #endif // !SKIP
    }

    func test_postNowToDefaultQueueWithCoalescing() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let notificationName = Notification.Name(rawValue: "test_postNowToDefaultQueueWithCoalescingOnName")
        let dummyObject = NSObject()
        let notification = Notification(name: notificationName, object: dummyObject)
        var numberOfCalls = 0
        let obs = NotificationCenter.default.addObserver(forName: notificationName, object: dummyObject, queue: nil) { notification in
            numberOfCalls += 1
        }
        let queue = NotificationQueue.default
        queue.enqueue(notification, postingStyle: .now)
        queue.enqueue(notification, postingStyle: .now)
        queue.enqueue(notification, postingStyle: .now)
        // Coalescing doesn't work for the NSPostingStyle.PostNow. That is why we expect 3 calls here
        XCTAssertEqual(numberOfCalls, 3)
        NotificationCenter.default.removeObserver(obs)
        #endif // !SKIP
    }

    func test_postNowToCustomQueue() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let notificationName = Notification.Name(rawValue: "test_postNowToCustomQueue")
        let dummyObject = NSObject()
        let notification = Notification(name: notificationName, object: dummyObject)
        var numberOfCalls = 0
        let notificationCenter = NotificationCenter()
        let obs = notificationCenter.addObserver(forName: notificationName, object: dummyObject, queue: nil) { notification in
            numberOfCalls += 1
        }
        let notificationQueue = NotificationQueue(notificationCenter: notificationCenter)
        notificationQueue.enqueue(notification, postingStyle: .now)
        XCTAssertEqual(numberOfCalls, 1)
        NotificationCenter.default.removeObserver(obs)
        #endif // !SKIP
    }

    func test_postNowForDefaultRunLoopMode() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let notificationName = Notification.Name(rawValue: "test_postNowToDefaultQueueWithCoalescingOnName")
        let dummyObject = NSObject()
        let notification = Notification(name: notificationName, object: dummyObject)
        var numberOfCalls = 0
        let obs = NotificationCenter.default.addObserver(forName: notificationName, object: dummyObject, queue: nil) { notification in
            numberOfCalls += 1
        }
        let queue = NotificationQueue.default

        let runLoop = RunLoop.current
        let endDate = Date(timeInterval: TimeInterval(0.05), since: Date())

        let dummyTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            guard let runLoopMode = runLoop.currentMode else {
                return
            }

            // post 2 notifications for the RunLoop.Mode.default mode
            queue.enqueue(notification, postingStyle: .now, coalesceMask: [], forModes: [runLoopMode])
            queue.enqueue(notification, postingStyle: .now)
            // here we post notification for the RunLoop.Mode.common. It shouldn't have any affect, because the timer is scheduled in RunLoop.Mode.default.
            // The notification queue will only post the notification to its notification center if the run loop is in one of the modes provided in the array.
            queue.enqueue(notification, postingStyle: .now, coalesceMask: [], forModes: [.common])
        }
        runLoop.add(dummyTimer, forMode: .default)
        let _ = runLoop.run(mode: .default, before: endDate)
//        XCTAssertEqual(numberOfCalls, 2)
        NotificationCenter.default.removeObserver(obs)
        #endif // !SKIP
    }

    func test_postAsapToDefaultQueue() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let notificationName = Notification.Name(rawValue: "test_postAsapToDefaultQueue")
        let dummyObject = NSObject()
        let notification = Notification(name: notificationName, object: dummyObject)
        var numberOfCalls = 0
        let obs = NotificationCenter.default.addObserver(forName: notificationName, object: dummyObject, queue: nil) { notification in
            numberOfCalls += 1
        }
        let queue = NotificationQueue.default
        queue.enqueue(notification, postingStyle: .asap)

        scheduleTimer(withInterval: 0.001) // run timer trigger the notifications
        XCTAssertEqual(numberOfCalls, 1)
        NotificationCenter.default.removeObserver(obs)
        #endif // !SKIP
    }

    func test_postAsapToDefaultQueueWithCoalescingOnNameAndSender() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Check coalescing on name and object
        let notificationName = Notification.Name(rawValue: "test_postAsapToDefaultQueueWithCoalescingOnNameAndSender")
        let notification = Notification(name: notificationName, object: NSObject())
        var numberOfCalls = 0
        let obs = NotificationCenter.default.addObserver(forName: notificationName, object: notification.object, queue: nil) { notification in
            numberOfCalls += 1
        }
        let queue = NotificationQueue.default
        queue.enqueue(notification, postingStyle: .asap)
        queue.enqueue(notification, postingStyle: .asap)
        queue.enqueue(notification, postingStyle: .asap)

        scheduleTimer(withInterval: 0.001)
        XCTAssertEqual(numberOfCalls, 1)
        NotificationCenter.default.removeObserver(obs)
        #endif // !SKIP
    }

    func test_postAsapToDefaultQueueWithCoalescingOnNameOrSender() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Check coalescing on name or sender
        let notificationName = Notification.Name(rawValue: "test_postAsapToDefaultQueueWithCoalescingOnNameOrSender")
        let notification1 = Notification(name: notificationName, object: NSObject())
        var numberOfNameCoalescingCalls = 0
        let obs1 = NotificationCenter.default.addObserver(forName: notificationName, object: notification1.object, queue: nil) { notification in
            numberOfNameCoalescingCalls += 1
        }
        let notification2 = Notification(name: notificationName, object: NSObject())
        var numberOfObjectCoalescingCalls = 0
        let obs2 = NotificationCenter.default.addObserver(forName: notificationName, object: notification2.object, queue: nil) { notification in
            numberOfObjectCoalescingCalls += 1
        }

        let queue = NotificationQueue.default
        // #1
        queue.enqueue(notification1, postingStyle: .asap,  coalesceMask: .onName, forModes: nil)
        // #2
        queue.enqueue(notification2, postingStyle: .asap,  coalesceMask: .onSender, forModes: nil)
        // #3, coalesce with 1 & 2
        queue.enqueue(notification1, postingStyle: .asap,  coalesceMask: .onName, forModes: nil)
        // #4, coalesce with #3
        queue.enqueue(notification2, postingStyle: .asap,  coalesceMask: .onName, forModes: nil)
        // #5
        queue.enqueue(notification1, postingStyle: .asap,  coalesceMask: .onSender, forModes: nil)
        scheduleTimer(withInterval: 0.001)
        // check that we received notifications #4 and #5
        XCTAssertEqual(numberOfNameCoalescingCalls, 1)
//        XCTAssertEqual(numberOfObjectCoalescingCalls, 1)
        NotificationCenter.default.removeObserver(obs1)
        NotificationCenter.default.removeObserver(obs2)
        #endif // !SKIP
    }


    func test_postIdleToDefaultQueue() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let notificationName = Notification.Name(rawValue: "test_postIdleToDefaultQueue")
        let dummyObject = NSObject()
        let notification = Notification(name: notificationName, object: dummyObject)
        var numberOfCalls = 0

        let obs = NotificationCenter.default.addObserver(forName: notificationName, object: dummyObject, queue: nil) { notification in
            numberOfCalls += 1
        }
        NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle)
        // add a timer to wakeup the runloop, process the timer and call the observer awaiting for any input sources/timers
        scheduleTimer(withInterval: 0.001)
        XCTAssertEqual(numberOfCalls, 1)
        NotificationCenter.default.removeObserver(obs)
        #endif // !SKIP
    }

    func test_notificationQueueLifecycle() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // check that notificationqueue is associated with current thread. when the thread is destroyed, the queue should be deallocated as well
        weak var notificationQueue: NotificationQueue?

        self.executeInBackgroundThread() {
            let nq = NotificationQueue(notificationCenter: NotificationCenter())
            notificationQueue = nq
            XCTAssertNotNil(nq)
        }
        
        XCTAssertNil(notificationQueue)
        #endif // !SKIP
    }

    // MARK: Private

    private func scheduleTimer(withInterval interval: TimeInterval) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = expectation(description: "Timer")
        let dummyTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            e.fulfill()
        }
        RunLoop.current.add(dummyTimer, forMode: .default)
        waitForExpectations(timeout: 0.1)
        #endif // !SKIP
    }

    private func executeInBackgroundThread(_ operation: @escaping () -> Void) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = expectation(description: "Background Execution")
        let bgThread = Thread() {
            operation()
            e.fulfill()
        }
        bgThread.start()

        waitForExpectations(timeout: 0.2)

        // There is a small time gap between "e.fulfill()"
        // and actuall thread termination.
        // We need a little delay to allow bgThread actually die.
        // Callers of this function are assuming thread is
        // deallocated after call.
        Thread.sleep(forTimeInterval: 0.05)
        #endif // !SKIP
    }
}


