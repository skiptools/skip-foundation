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

class TestNotification : XCTestCase {


    func test_customReflection() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let someName = "somenotifname"
        let targetObject = NSObject()
        let userInfo = ["hello": "world", "indexThis": 350] as [AnyHashable: Any]
        let notif = Notification(name: Notification.Name(rawValue: someName), object: targetObject, userInfo: userInfo)
        let mirror = notif.customMirror

        XCTAssertEqual(mirror.displayStyle, .class)
        XCTAssertNil(mirror.superclassMirror)

        var children = Array(mirror.children).makeIterator()
        let firstChild = children.next()
        let secondChild = children.next()
        let thirdChild = children.next()
        XCTAssertEqual(firstChild?.label, "name")
        XCTAssertEqual(firstChild?.value as? String, someName)

        XCTAssertEqual(secondChild?.label, "object")
        XCTAssertEqual(secondChild?.value as? NSObject, targetObject)

        XCTAssertEqual(thirdChild?.label, "userInfo")
        XCTAssertEqual((thirdChild?.value as? [AnyHashable: Any])?["hello"] as? String, "world")
        XCTAssertEqual((thirdChild?.value as? [AnyHashable: Any])?["indexThis"] as? Int, 350)

        #endif // !SKIP
    }

    func test_NotificationNameInit() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let name = "TestNotificationNameInit"
        XCTAssertEqual(Notification.Name(name), Notification.Name(rawValue: name))
        #endif // !SKIP
    }
}


