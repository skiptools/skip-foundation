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

class TestPropertyListSerialization : XCTestCase {
    
    func test_BasicConstruction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict = NSMutableDictionary(capacity: 0)
//        dict["foo"] = "bar"
        var data: Data? = nil
        do {
            data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        } catch {
            
        }
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.count, 42, "empty dictionary should be 42 bytes")
        #endif // !SKIP
    }
    
    func test_decodeData() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var decoded: Any?
        var fmt = PropertyListSerialization.PropertyListFormat.binary
        let path = testBundle().url(forResource: "Test", withExtension: "plist")
        let data = try! Data(contentsOf: path!)
        do {
            decoded = try withUnsafeMutablePointer(to: &fmt) { (format: UnsafeMutablePointer<PropertyListSerialization.PropertyListFormat>) -> Any in
                return try PropertyListSerialization.propertyList(from: data, options: [], format: format)
            }
        } catch {
            
        }

        XCTAssertNotNil(decoded)
        let dict = decoded as! Dictionary<String, Any>
        XCTAssertEqual(dict.count, 3)
        let val = dict["Foo"]
        XCTAssertNotNil(val)
        if let str = val as? String {
            XCTAssertEqual(str, "Bar")
        } else {
            XCTFail("value stored is not a string")
        }
        #endif // !SKIP
    }

    func test_decodeStream() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var decoded: Any?
        var fmt = PropertyListSerialization.PropertyListFormat.binary
        let path = testBundle().url(forResource: "Test", withExtension: "plist")
        let stream = try XCTUnwrap(InputStream(url: XCTUnwrap(path)))
        stream.open()
        do {
            decoded = try withUnsafeMutablePointer(to: &fmt) { (format: UnsafeMutablePointer<PropertyListSerialization.PropertyListFormat>) -> Any in
                return try PropertyListSerialization.propertyList(with: stream, options: [], format: format)
            }
        } catch {

        }

        XCTAssertNotNil(decoded)
        let dict = decoded as! Dictionary<String, Any>
        XCTAssertEqual(dict.count, 3)
        let val = dict["Foo"]
        XCTAssertNotNil(val)
        if let str = val as? String {
            XCTAssertEqual(str, "Bar")
        } else {
            XCTFail("value stored is not a string")
        }
        #endif // !SKIP
    }

    func test_decodeEmptyData() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertThrowsError(try PropertyListSerialization.propertyList(from: Data(), format: nil)) { error in
            let nserror = error as! NSError
            XCTAssertEqual(nserror.domain, NSCocoaErrorDomain)
            XCTAssertEqual(CocoaError(_nsError: nserror).code, .propertyListReadCorrupt)
            XCTAssertEqual(nserror.userInfo[NSDebugDescriptionErrorKey] as? String, "Cannot parse a NULL or zero-length data")
	}

        #endif // !SKIP
    }
}


