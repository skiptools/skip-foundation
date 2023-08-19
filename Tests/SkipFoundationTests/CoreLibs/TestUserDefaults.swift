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
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestUserDefaults : XCTestCase {

	func test_createUserDefaults() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		defaults.set(4, forKey: "ourKey")
        #endif
	}
	
	func test_getRegisteredDefaultItem() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		defaults.register(defaults: ["test_getRegisteredDefaultItem": NSNumber(value: Int(5))])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem")

		XCTAssertEqual(defaults.integer(forKey: "test_getRegisteredDefaultItem"), 5)
        #endif
	}
	
	func test_getRegisteredDefaultItem_NSString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register a NSString value. UserDefaults.string(forKey:) is supposed to return the NSString as a String
		defaults.register(defaults: ["test_getRegisteredDefaultItem_NSString": "hello" as NSString])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_NSString")

		XCTAssertEqual(defaults.string(forKey: "test_getRegisteredDefaultItem_NSString"), "hello")
        #endif
	}

	func test_getRegisteredDefaultItem_String() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register a String value. UserDefaults.string(forKey:) is supposed to return the String
		defaults.register(defaults: ["test_getRegisteredDefaultItem_String": "hello"])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_String")

		XCTAssertEqual(defaults.string(forKey: "test_getRegisteredDefaultItem_String"), "hello")
        #endif
	}

	func test_getRegisteredDefaultItem_NSURL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register an NSURL value. UserDefaults.url(forKey:) is supposed to return the URL
		defaults.register(defaults: ["test_getRegisteredDefaultItem_NSURL": NSURL(fileURLWithPath: "/hello/world")])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_NSURL")

		XCTAssertEqual(defaults.url(forKey: "test_getRegisteredDefaultItem_NSURL"), URL(fileURLWithPath: "/hello/world"))
        #endif
	}

	func test_getRegisteredDefaultItem_URL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register an URL value. UserDefaults.url(forKey:) is supposed to return the URL
		defaults.register(defaults: ["test_getRegisteredDefaultItem_URL": URL(fileURLWithPath: "/hello/world")])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_URL")

		XCTAssertEqual(defaults.url(forKey: "test_getRegisteredDefaultItem_URL"), URL(fileURLWithPath: "/hello/world"))
        #endif
	}

	func test_getRegisteredDefaultItem_NSData() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		let bytes = [0, 1, 2, 3, 4] as [UInt8]
		
		// Register an NSData value. UserDefaults.data(forKey:) is supposed to return the Data
		defaults.register(defaults: ["test_getRegisteredDefaultItem_NSData": NSData(bytes: bytes, length: bytes.count)])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_NSData")

		XCTAssertEqual(defaults.data(forKey: "test_getRegisteredDefaultItem_NSData"), Data(bytes))
        #endif
	}
	
	func test_getRegisteredDefaultItem_Data() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		let bytes = [0, 1, 2, 3, 4] as [UInt8]
		
		// Register a Data value. UserDefaults.data(forKey:) is supposed to return the Data
		defaults.register(defaults: ["test_getRegisteredDefaultItem_Data": Data(bytes)])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_Data")

		XCTAssertEqual(defaults.data(forKey: "test_getRegisteredDefaultItem_Data"), Data(bytes))
        #endif
	}

	func test_getRegisteredDefaultItem_BoolFromString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register a boolean default value as a string. UserDefaults.bool(forKey:) is supposed to return the parsed Bool value
		defaults.register(defaults: ["test_getRegisteredDefaultItem_BoolFromString": "YES"])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_BoolFromString")

		XCTAssertEqual(defaults.bool(forKey: "test_getRegisteredDefaultItem_BoolFromString"), true)
        #endif
	}
	
	func test_getRegisteredDefaultItem_IntFromString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register an int default value as a string. UserDefaults.integer(forKey:) is supposed to return the parsed Int value
		defaults.register(defaults: ["test_getRegisteredDefaultItem_IntFromString": "1234"])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_IntFromString")

		XCTAssertEqual(defaults.integer(forKey: "test_getRegisteredDefaultItem_IntFromString"), 1234)
        #endif
	}
	
	func test_getRegisteredDefaultItem_DoubleFromString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register a double default value as a string. UserDefaults.double(forKey:) is supposed to return the parsed Double value
		defaults.register(defaults: ["test_getRegisteredDefaultItem_DoubleFromString": "12.34"])

		//make sure we don't have anything in the saved plist.
		defaults.removeObject(forKey: "test_getRegisteredDefaultItem_DoubleFromString")

		XCTAssertEqual(defaults.double(forKey: "test_getRegisteredDefaultItem_DoubleFromString"), 12.34)
        #endif
	}
	
	func test_setValue_NSString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Set a NSString value. UserDefaults.string(forKey:) is supposed to return the NSString as a String
		defaults.set("hello" as NSString, forKey: "test_setValue_NSString")

		XCTAssertEqual(defaults.string(forKey: "test_setValue_NSString"), "hello")
        #endif
	}
	
	func test_setValue_String() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register a String value. UserDefaults.string(forKey:) is supposed to return the String
		defaults.set("hello", forKey: "test_setValue_String")

		XCTAssertEqual(defaults.string(forKey: "test_setValue_String"), "hello")
        #endif
	}

	func test_setValue_NSURL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Set a NSURL value. UserDefaults.url(forKey:) is supposed to return the NSURL as a URL
//		defaults.set(NSURL(fileURLWithPath: "/hello/world"), forKey: "test_setValue_NSURL")

//		XCTAssertEqual(defaults.url(forKey: "test_setValue_NSURL"), URL(fileURLWithPath: "/hello/world"))
        #endif
	}

	func test_setValue_URL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Set a URL value. UserDefaults.url(forKey:) is supposed to return the URL
		defaults.set(URL(fileURLWithPath: "/hello/world"), forKey: "test_setValue_URL")

		XCTAssertEqual(defaults.url(forKey: "test_setValue_URL"), URL(fileURLWithPath: "/hello/world"))
        #endif
	}

	func test_setValue_NSData() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		let bytes = [0, 1, 2, 3, 4] as [UInt8]
		
		// Set a NSData value. UserDefaults.data(forKey:) is supposed to return the Data
		defaults.set(NSData(bytes: bytes, length: bytes.count), forKey: "test_setValue_NSData")

		XCTAssertEqual(defaults.data(forKey: "test_setValue_NSData"), Data(bytes))
        #endif
	}
	
	func test_setValue_Data() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		let bytes = [0, 1, 2, 3, 4] as [UInt8]
		
		// Set a Data value. UserDefaults.data(forKey:) is supposed to return the Data
		defaults.set(Data(bytes), forKey: "test_setValue_Data")

		XCTAssertEqual(defaults.data(forKey: "test_setValue_Data"), Data(bytes))
        #endif
	}

	func test_setValue_BoolFromString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register a boolean default value as a string. UserDefaults.bool(forKey:) is supposed to return the parsed Bool value
		defaults.set("YES", forKey: "test_setValue_BoolFromString")

		XCTAssertEqual(defaults.bool(forKey: "test_setValue_BoolFromString"), true)
        #endif
	}
	
	func test_setValue_IntFromString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register an int default value as a string. UserDefaults.integer(forKey:) is supposed to return the parsed Int value
		defaults.set("1234", forKey: "test_setValue_IntFromString")

		XCTAssertEqual(defaults.integer(forKey: "test_setValue_IntFromString"), 1234)
        #endif
	}
	
	func test_setValue_DoubleFromString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let defaults = UserDefaults.standard
		
		// Register a double default value as a string. UserDefaults.double(forKey:) is supposed to return the parsed Double value
		defaults.set("12.34", forKey: "test_setValue_DoubleFromString")

		XCTAssertEqual(defaults.double(forKey: "test_setValue_DoubleFromString"), 12.34)
        #endif
	}
	
	func test_volatileDomains() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let dateKey = "A Date",
		stringKey = "A String",
		arrayKey = "An Array",
		dictionaryKey = "A Dictionary",
		dataKey = "Some Data",
		boolKey = "A Bool"
		
		let defaultsIn: [String: Any] = [
			dateKey: Date(),
			stringKey: "The String",
			arrayKey: [1, 2, 3],
			dictionaryKey: ["Swift": "Imperative", "Haskell": "Functional", "LISP": "LISP", "Today": Date()],
			dataKey: "The Data".data(using: .utf8)!,
			boolKey: true
		]
		
		let domainName = "TestDomain"
		
		let defaults = UserDefaults(suiteName: nil)!
		XCTAssertFalse(defaults.volatileDomainNames.contains(domainName))
		
		defaults.setVolatileDomain(defaultsIn, forName: domainName)
		let defaultsOut = defaults.volatileDomain(forName: domainName)
		
		XCTAssertEqual(defaultsIn.count, defaultsOut.count)
		XCTAssertEqual(defaultsIn[dateKey] as! Date, defaultsOut[dateKey] as! Date)
		XCTAssertEqual(defaultsIn[stringKey] as! String, defaultsOut[stringKey] as! String)
		XCTAssertEqual(defaultsIn[arrayKey] as! [Int], defaultsOut[arrayKey] as! [Int])
		XCTAssertEqual(defaultsIn[dictionaryKey] as! [String: AnyHashable], defaultsOut[dictionaryKey] as! [String: AnyHashable])
		XCTAssertEqual(defaultsIn[dataKey] as! Data, defaultsOut[dataKey] as! Data)
		XCTAssertEqual(defaultsIn[boolKey] as! Bool, defaultsOut[boolKey] as! Bool)
        #endif
	}
	
	func test_persistentDomain() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
		let int = (key: "An Integer", value: 1234)
		let double = (key: "A Double", value: 5678.1234)
		let string = (key: "A String", value: "Some string")
		let array = (key: "An Array", value: [ 1, 2, 3, 4, "Surprise" ] as [AnyHashable])
		let dictionary = (key: "A Dictionary", value: [ "Swift": "Imperative", "Haskell": "Functional", "LISP": "LISP", "Today": Date() ] as [String: AnyHashable])
		
		let domainName = "org.swift.Foundation.TestPersistentDomainName"

		let done = expectation(description: "All notifications have fired.")
		
		var countOfFiredNotifications = 0
		let expectedNotificationCount = 3
		
		let observer = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { (_) in
			countOfFiredNotifications += 1
			
			if countOfFiredNotifications == expectedNotificationCount {
				done.fulfill()
			} else if countOfFiredNotifications > expectedNotificationCount {
				XCTFail("Too many UserDefaults.didChangeNotification notifications posted.")
			}
		}
		
		let defaults1 = UserDefaults(suiteName: nil)!
		
		defaults1.removePersistentDomain(forName: domainName)
		if let domain = defaults1.persistentDomain(forName: domainName) {
			XCTAssertEqual(domain.count, 0)
		} // else it's nil, which is also OK.
		
		let defaultsIn: [String : Any] =
			[ int.key: int.value,
			  double.key: double.value,
			  string.key: string.value,
			  array.key: array.value,
			  dictionary.key: dictionary.value ]
		
		defaults1.setPersistentDomain(defaultsIn, forName: domainName)
		
		let defaults2 = UserDefaults(suiteName: nil)!
		let returned = defaults2.persistentDomain(forName: domainName)
		XCTAssertNotNil(returned)
		
		if let returned = returned {
			XCTAssertEqual(returned.count, defaultsIn.count)
			XCTAssertEqual(returned[int.key] as? Int, int.value)
			XCTAssertEqual(returned[double.key] as? Double, double.value)
			XCTAssertEqual(returned[string.key] as? String, string.value)
			XCTAssertEqual(returned[array.key] as? [AnyHashable], array.value)
			XCTAssertEqual(returned[dictionary.key] as? [String: AnyHashable], dictionary.value)
		}
		
		defaults2.removePersistentDomain(forName: domainName)
		
		let defaults3 = UserDefaults(suiteName: nil)!
		if let domain = defaults3.persistentDomain(forName: domainName) {
			XCTAssertEqual(domain.count, 0)
		} // else it's nil, which is also OK.
		
		waitForExpectations(timeout: 10)
		
		NotificationCenter.default.removeObserver(observer)
        #endif
	}
}
