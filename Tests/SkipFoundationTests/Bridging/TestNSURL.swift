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
// Copyright (c) 2014 - 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestNSURL: XCTestCase {

    func test_absoluteString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder", isDirectory: true).absoluteString, "file:///path/to/folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder/", isDirectory: true).absoluteString, "file:///path/to/folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../folder", isDirectory: true).absoluteString, "file:///path/../folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./folder/..", isDirectory: true).absoluteString, "file:///path/to/./folder/../")

        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/.file", isDirectory: false).absoluteString, "file:///path/to/.file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/file/", isDirectory: false).absoluteString, "file:///path/to/file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../file", isDirectory: false).absoluteString, "file:///path/../file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./file/..", isDirectory: false).absoluteString, "file:///path/to/./file/..")
        #endif // !SKIP
    }

    func test_pathComponents() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder", isDirectory: true).pathComponents, ["/", "path", "to", "folder"])
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder/", isDirectory: true).pathComponents, ["/", "path", "to", "folder"])
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../folder", isDirectory: true).pathComponents, ["/", "path", "..", "folder"])
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../folder", isDirectory: true).standardized?.pathComponents, ["/", "folder"])
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./folder/..", isDirectory: true).pathComponents, ["/", "path", "to", ".", "folder", ".."])

        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/.file", isDirectory: false).pathComponents, ["/", "path", "to", ".file"])
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/file/", isDirectory: false).pathComponents, ["/", "path", "to", "file"])
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../file", isDirectory: false).pathComponents, ["/", "path", "..", "file"])
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./file/..", isDirectory: false).pathComponents, ["/", "path", "to", ".", "file", ".."])
        #endif // !SKIP
    }

    func test_standardized() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder", isDirectory: true).standardized?.absoluteString, "file:///path/to/folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder/", isDirectory: true).standardized?.absoluteString, "file:///path/to/folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../folder", isDirectory: true).standardized?.absoluteString, "file:///folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./folder/..", isDirectory: true).standardized?.absoluteString, "file:///path/to/")

        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/.file", isDirectory: false).standardized?.absoluteString, "file:///path/to/.file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/file/", isDirectory: false).standardized?.absoluteString, "file:///path/to/file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../file", isDirectory: false).standardized?.absoluteString, "file:///file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./file/..", isDirectory: false).standardized?.absoluteString, "file:///path/to")
        #endif // !SKIP
    }

    func test_standardizingPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder", isDirectory: true).standardizingPath?.absoluteString, "file:///path/to/folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder/", isDirectory: true).standardizingPath?.absoluteString, "file:///path/to/folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../folder", isDirectory: true).standardizingPath?.absoluteString, "file:///folder/")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./folder/..", isDirectory: true).standardizingPath?.absoluteString, "file:///path/to/")

        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/.file", isDirectory: false).standardizingPath?.absoluteString, "file:///path/to/.file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/file/", isDirectory: false).standardizingPath?.absoluteString, "file:///path/to/file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../file", isDirectory: false).standardizingPath?.absoluteString, "file:///file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./file/..", isDirectory: false).standardizingPath?.absoluteString, "file:///path/to")
        #endif // !SKIP
    }

    func test_resolvingSymlinksInPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder", isDirectory: true).resolvingSymlinksInPath?.absoluteString, "file:///path/to/folder")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/folder/", isDirectory: true).resolvingSymlinksInPath?.absoluteString, "file:///path/to/folder")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../folder", isDirectory: true).resolvingSymlinksInPath?.absoluteString, "file:///folder")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./folder/..", isDirectory: true).resolvingSymlinksInPath?.absoluteString, "file:///path/to")

        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/.file", isDirectory: false).resolvingSymlinksInPath?.absoluteString, "file:///path/to/.file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/file/", isDirectory: false).resolvingSymlinksInPath?.absoluteString, "file:///path/to/file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/../file", isDirectory: false).resolvingSymlinksInPath?.absoluteString, "file:///file")
        XCTAssertEqual(NSURL(fileURLWithPath: "/path/to/./file/..", isDirectory: false).resolvingSymlinksInPath?.absoluteString, "file:///path/to")
        #endif // !SKIP
    }

}


