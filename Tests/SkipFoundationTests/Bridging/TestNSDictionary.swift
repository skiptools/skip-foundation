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

class TestNSDictionary : XCTestCase {
    func test_BasicConstruction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict = NSDictionary()
        let dict2: NSDictionary = ["foo": "bar"]
        XCTAssertEqual(dict.count, 0)
        XCTAssertEqual(dict2.count, 1)
        #endif // !SKIP
    }
    

    func test_description() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let d1: NSDictionary = [ "foo": "bar", "baz": "qux"]
        XCTAssertTrue(d1.description == "{\n    baz = qux;\n    foo = bar;\n}" ||
                      d1.description == "{\n    foo = bar;\n    baz = qux;\n}")
        let d2: NSDictionary = ["1" : ["1" : ["1" : "1"]]]
        XCTAssertEqual(d2.description, "{\n    1 =     {\n        1 =         {\n            1 = 1;\n        };\n    };\n}")
        #endif // !SKIP
    }

    func test_HeterogeneousConstruction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict2: NSDictionary = [
            "foo": "bar",
            1 : 2
        ]
        XCTAssertEqual(dict2.count, 2)
        XCTAssertEqual(dict2["foo"] as? String, "bar")
        XCTAssertEqual(dict2[1] as? NSNumber, NSNumber(value: 2))
        #endif // !SKIP
    }
    
    func test_ArrayConstruction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let objects = ["foo", "bar", "baz"]
        let keys: [NSString] = ["foo", "bar", "baz"]
        let dict = NSDictionary(objects: objects, forKeys: keys)
        XCTAssertEqual(dict.count, 3)
        #endif // !SKIP
    }
    
    func test_enumeration() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict : NSDictionary = ["foo" : "bar", "whiz" : "bang", "toil" : "trouble"]
        let e = dict.keyEnumerator()
        var keys = Set<String>()
        keys.insert((e.nextObject()! as! String))
        keys.insert((e.nextObject()! as! String))
        keys.insert((e.nextObject()! as! String))
        XCTAssertNil(e.nextObject())
        XCTAssertNil(e.nextObject())
        XCTAssertEqual(keys, ["foo", "whiz", "toil"])
        
        let o = dict.objectEnumerator()
        var objs = Set<String>()
        objs.insert((o.nextObject()! as! String))
        objs.insert((o.nextObject()! as! String))
        objs.insert((o.nextObject()! as! String))
        XCTAssertNil(o.nextObject())
        XCTAssertNil(o.nextObject())
        XCTAssertEqual(objs, ["bar", "bang", "trouble"])
        #endif // !SKIP
    }
    
    func test_sequenceType() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict : NSDictionary = ["foo" : "bar", "whiz" : "bang", "toil" : "trouble"]
        var result = [String:String]()
        for (key, value) in dict {
            result[key as! String] = (value as! String)
        }
        XCTAssertEqual(result, ["foo" : "bar", "whiz" : "bang", "toil" : "trouble"])
        #endif // !SKIP
    }

    func test_equality() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict1 = NSDictionary(dictionary: [
            "foo":"bar",
            "whiz":"bang",
            "toil":"trouble",
        ])
        let dict2 = NSDictionary(dictionary: [
            "foo":"bar",
            "whiz":"bang",
            "toil":"trouble",
        ])
        let dict3 = NSDictionary(dictionary: [
            "foo":"bar",
            "whiz":"bang",
            "toil":"troubl",
        ])

        XCTAssertTrue(dict1 == dict2)
        XCTAssertTrue(dict1.isEqual(dict2))
        XCTAssertTrue(dict1.isEqual(to: [
            "foo":"bar",
            "whiz":"bang",
            "toil":"trouble",
        ]))
        XCTAssertEqual(dict1.hash, dict2.hash)
        XCTAssertEqual(dict1.hashValue, dict2.hashValue)

        XCTAssertFalse(dict1 == dict3)
        XCTAssertFalse(dict1.isEqual(dict3))
        XCTAssertFalse(dict1.isEqual(to:[
            "foo":"bar",
            "whiz":"bang",
            "toil":"troubl",
        ]))

        XCTAssertFalse(dict1.isEqual(nil))
        XCTAssertFalse(dict1.isEqual(NSObject()))

        let nestedDict1 = NSDictionary(dictionary: [
            "key.entities": [
                ["key": 0]
            ]
        ])
        let nestedDict2 = NSDictionary(dictionary: [
            "key.entities": [
                ["key": 1]
            ]
        ])
        XCTAssertFalse(nestedDict1 == nestedDict2)
        XCTAssertFalse(nestedDict1.isEqual(nestedDict2))
        XCTAssertFalse(nestedDict1.isEqual(to: [
            "key.entities": [
                ["key": 1]
            ]
        ]))
        #endif // !SKIP
    }

    func test_copying() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let inputDictionary : NSDictionary = ["foo" : "bar", "whiz" : "bang", "toil" : "trouble"]

        let copy: NSDictionary = inputDictionary.copy() as! NSDictionary
        XCTAssertTrue(inputDictionary === copy)

        let dictMutableCopy = inputDictionary.mutableCopy() as! NSMutableDictionary
        let dictCopy2 = dictMutableCopy.copy() as! NSDictionary
//        XCTAssertTrue(type(of: dictCopy2) === NSDictionary.self)
        XCTAssertFalse(dictMutableCopy === dictCopy2)
        XCTAssertTrue(dictMutableCopy == dictCopy2)
        #endif // !SKIP
    }

    func test_mutableCopying() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let inputDictionary : NSDictionary = ["foo" : "bar", "whiz" : "bang", "toil" : "trouble"]

        let dictMutableCopy1 = inputDictionary.mutableCopy() as! NSMutableDictionary
//        XCTAssertTrue(type(of: dictMutableCopy1) === NSMutableDictionary.self)
        XCTAssertFalse(inputDictionary === dictMutableCopy1)
        XCTAssertTrue(inputDictionary == dictMutableCopy1)

        let dictMutableCopy2 = dictMutableCopy1.mutableCopy() as! NSMutableDictionary
//        XCTAssertTrue(type(of: dictMutableCopy2) === NSMutableDictionary.self)
        XCTAssertFalse(dictMutableCopy2 === dictMutableCopy1)
        XCTAssertTrue(dictMutableCopy2 == dictMutableCopy1)
        #endif // !SKIP
    }

    func test_writeToFile() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        #if !os(iOS)
        let testFilePath = createTestFile("TestFileOut.txt", _contents: Data(capacity: 256))
        if let _ = testFilePath {
            let d1: NSDictionary = [ "foo": "bar", "baz": "qux"]
            let isWritten = d1.write(toFile: testFilePath!, atomically: true)
            if isWritten {
                do {
                    let plistDoc = try XMLDocument(contentsOf: URL(fileURLWithPath: testFilePath!, isDirectory: false), options: [])
                    XCTAssert(plistDoc.rootElement()?.name == "plist")
                    let plist = try PropertyListSerialization.propertyList(from: plistDoc.xmlData, options: [], format: nil) as! [String: Any]
                    XCTAssert((plist["foo"] as? String) == d1["foo"] as? String)
                    XCTAssert((plist["baz"] as? String) == d1["baz"] as? String)
                } catch {
                    XCTFail("Failed to read and parse XMLDocument")
                }
            } else {
                XCTFail("Write to file failed")
            }
            removeTestFile(testFilePath!)
        } else {
            XCTFail("Temporary file creation failed")
        }
        #endif
        #endif // !SKIP
    }
    
    func test_initWithContentsOfFile() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let testFilePath = createTestFile("TestFileOut.txt", _contents: Data(capacity: 256))
        if let _ = testFilePath {
            let d1: NSDictionary = ["Hello":["world":"again"]]
            let isWritten = d1.write(toFile: testFilePath!, atomically: true)
            if(isWritten) {
                let dict = NSDictionary(contentsOfFile: testFilePath!)
                XCTAssert(dict == d1)
            } else {
                XCTFail("Write to file failed")
            }
            removeTestFile(testFilePath!)
        } else {
            XCTFail("Temporary file creation failed")
        }
        #endif // !SKIP
    }

    func test_settingWithStringKey() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict = NSMutableDictionary()
        // has crashed in the past
        dict["stringKey"] = "value"
        #endif // !SKIP
    }
    
    func test_valueForKey() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict: NSDictionary = ["foo": "bar"]
        let result = dict.value(forKey: "foo")
        XCTAssertEqual(result as? String, "bar")
        #endif // !SKIP
    }
    
    func test_valueForKeyWithNestedDict() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let dict: NSDictionary = ["foo": ["bar": "baz"]]
        let result = dict.value(forKey: "foo")
        let expectedResult: NSDictionary = ["bar": "baz"]
        XCTAssertEqual(result as? NSDictionary, expectedResult)
        #endif // !SKIP
    }

    private func createTestFile(_ path: String, _contents: Data) -> String? {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let tempDir = NSTemporaryDirectory() + "TestFoundation_Playground_" + NSUUID().uuidString + "/"
        do {
            try FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: false, attributes: nil)
            if FileManager.default.createFile(atPath: tempDir + "/" + path, contents: _contents,
                                              attributes: nil) {
                return tempDir + path
            } else {
                return nil
            }
        } catch {
            return nil
        }
        #endif // !SKIP
    }
    
    private func removeTestFile(_ location: String) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        try? FileManager.default.removeItem(atPath: location)
        #endif // !SKIP
    }

    func test_sharedKeySets() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let keys: [NSCopying] = [ "a" as NSString, "b" as NSString, 1 as NSNumber, 2 as NSNumber ]
        let keySet = NSDictionary.sharedKeySet(forKeys: keys)
        
        let dictionary = NSMutableDictionary(sharedKeySet: keySet)
        dictionary["a" as NSString] = "w"
        XCTAssertEqual(dictionary["a" as NSString] as? String, "w")
        dictionary["b" as NSString] = "x"
        XCTAssertEqual(dictionary["b" as NSString] as? String, "x")
        dictionary[1 as NSNumber] = "y"
        XCTAssertEqual(dictionary[1 as NSNumber] as? String, "y")
        dictionary[2 as NSNumber] = "z"
        XCTAssertEqual(dictionary[2 as NSNumber] as? String, "z")
        
        // Keys not in the key set must be supported.
        dictionary["c" as NSString] = "h"
        XCTAssertEqual(dictionary["c" as NSString] as? String, "h")
        dictionary[3 as NSNumber] = "k"
        XCTAssertEqual(dictionary[3 as NSNumber] as? String, "k")
        #endif // !SKIP
    }
    
}


