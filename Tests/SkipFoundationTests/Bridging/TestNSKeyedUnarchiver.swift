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

class TestNSKeyedUnarchiver : XCTestCase {
    
    private enum SecureTest {
        case skip
        case performWithDefaultClass
        case performWithClasses([AnyClass])
    }
    
    private func test_unarchive_from_file(_ filename : String, _ expectedObject : NSObject, _ secureTest: SecureTest = .skip) throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        guard let testFilePath = testBundle().path(forResource: filename, ofType: "plist") else {
            XCTFail("Could not find \(filename)")
            return
        }
        do {
            // Use the path method:
            let object = NSKeyedUnarchiver.unarchiveObject(withFile: testFilePath) as? NSObject
            if let obj = object {
                if expectedObject != obj {
                    print("\(expectedObject) != \(obj)")
                }
            }
            
            XCTAssertEqual(expectedObject, object)
        }
        
        let classes: [AnyClass]
        
        switch secureTest {
        case .skip:
            classes = []
        case .performWithDefaultClass:
            classes = [ (expectedObject as! NSObject).classForCoder ]
        case .performWithClasses(let specifiedClasses):
            classes = specifiedClasses
        }

        if !classes.isEmpty {
            // Use the secure method:
            let data = try Data(contentsOf: URL(fileURLWithPath: testFilePath))
            
            let object = try NSKeyedUnarchiver.unarchivedObject(ofClasses: classes, from: data) as? NSObject
            if let obj = object {
                if expectedObject != obj {
                    print("\(expectedObject) != \(obj)")
                }
            }
            
            XCTAssertEqual(expectedObject, object)
        }
        #endif // !SKIP
    }

    func test_unarchive_array() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let array = NSArray(array: ["baa", "baa", "black", "sheep"])
        try test_unarchive_from_file("NSKeyedUnarchiver-ArrayTest", array)
        #endif // !SKIP
    }
    
    func test_unarchive_complex() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let uuid = NSUUID(uuidString: "71DC068E-3420-45FF-919E-3A267D55EC22")!
        let url = URL(string: "index.xml", relativeTo: URL(string: "https://www.swift.org"))!
        let array = NSArray(array: [ NSNull(), NSString(string: "hello"), NSNumber(value: 34545), NSDictionary(dictionary: ["key" : "val"])])
        let dict : Dictionary<AnyHashable, Any> = [
            "uuid" : uuid,
            "url" : url,
            "string" : "hello",
            "array" : array
        ]
        try test_unarchive_from_file("NSKeyedUnarchiver-ComplexTest", NSDictionary(dictionary: dict), .performWithClasses([NSDictionary.self, NSArray.self, NSURL.self, NSUUID.self, NSNull.self]))
        #endif // !SKIP
    }
    
    func test_unarchive_concrete_value() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let array: Array<Int32> = [1, 2, 3]
        let objctype = "[3i]"
        try array.withUnsafeBufferPointer { cArray in
            let concrete = NSValue(bytes: cArray.baseAddress!, objCType: objctype)
            try test_unarchive_from_file("NSKeyedUnarchiver-ConcreteValueTest", concrete, .skip)
        }
        #endif // !SKIP
    }

//    func test_unarchive_notification() throws {
//        let notification = Notification(name: Notification.Name(rawValue:"notification-name"), object: "notification-object".bridge(),
//                                          userInfo: ["notification-key": "notification-val"])
//        try test_unarchive_from_file("NSKeyedUnarchiver-NotificationTest", notification)
//    }
    
    func test_unarchive_nsedgeinsets_value() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
//        let edgeinsets = NSEdgeInsets(top: CGFloat(1.0), left: CGFloat(2.0), bottom: CGFloat(3.0), right: CGFloat(4.0))
//        try test_unarchive_from_file("NSKeyedUnarchiver-EdgeInsetsTest", NSValue(edgeInsets: edgeinsets))
        #endif // !SKIP
    }
    
    func test_unarchive_nsrange_value() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let range = NSRange(location: 97345, length: 98345)
        try test_unarchive_from_file("NSKeyedUnarchiver-RangeTest", NSValue(range: range))
        #endif // !SKIP
    }
    
    func test_unarchive_nsrect_value() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
//        let origin = NSPoint(x: CGFloat(400.0), y: CGFloat(300.0))
//        let size = NSSize(width: CGFloat(200.0), height: CGFloat(300.0))
//        let rect = NSRect(origin: origin, size: size)
//        try test_unarchive_from_file("NSKeyedUnarchiver-RectTest", NSValue(rect: rect))
        #endif // !SKIP
    }
    
    func test_unarchive_ordered_set() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: ["valgeir", "nico", "puzzle"])
        try test_unarchive_from_file("NSKeyedUnarchiver-OrderedSetTest", set)
        #endif // !SKIP
    }
    
    func test_unarchive_url() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = NSURL(string: "foo.xml", relativeTo: URL(string: "https://www.example.com"))
        try test_unarchive_from_file("NSKeyedUnarchiver-URLTest", url!)
        #endif // !SKIP
    }
    
    func test_unarchive_uuid() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let uuid = NSUUID(uuidString: "0AD863BA-7584-40CF-8896-BD87B3280C34")
        try test_unarchive_from_file("NSKeyedUnarchiver-UUIDTest", uuid!)
        #endif // !SKIP
    }
}


