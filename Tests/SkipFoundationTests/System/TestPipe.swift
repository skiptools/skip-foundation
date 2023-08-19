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
// Copyright (c) 2014 - 2016. 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


@available(macOS 10.15, iOS 13.4, watchOS 6.0, tvOS 13.0, *)
class TestPipe: XCTestCase {
    

#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT
    func test_MaxPipes() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Try and create enough pipes to exhaust the process's limits. 1024 is a reasonable
        // hard limit for the test. This is reached when testing on Linux (at around 488 pipes)
        // but not on macOS.

        var pipes: [Pipe] = []
        let maxPipes = 1024
        pipes.reserveCapacity(maxPipes)
        for _ in 1...maxPipes {
            let pipe = Pipe()
            if !pipe.fileHandleForReading._isPlatformHandleValid {
#if os(Windows)
                XCTAssertEqual(pipe.fileHandleForReading._handle, pipe.fileHandleForWriting._handle)
#else
                XCTAssertEqual(pipe.fileHandleForReading.fileDescriptor, pipe.fileHandleForWriting.fileDescriptor)
#endif
                break
            }
            pipes.append(pipe)
        }
        pipes = []
        #endif // !SKIP
    }
#endif

    func test_Pipe() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let aPipe = Pipe()
        let text = "test-pipe"
        
        // First write some data into the pipe
        let stringAsData = try XCTUnwrap(text.data(using: .utf8))
        try aPipe.fileHandleForWriting.write(contentsOf: stringAsData)

        // SR-10240 - Check empty Data() can be written without crashing
        aPipe.fileHandleForWriting.write(Data())

        // Then read it out again
        let data = try XCTUnwrap(aPipe.fileHandleForReading.read(upToCount: stringAsData.count))
        
        // Confirm that we did read data
        XCTAssertEqual(data.count, stringAsData.count, "Expected to read \(String(describing:stringAsData.count)) from pipe but read \(data.count) instead")
        
        // Confirm the data can be converted to a String
        let convertedData = String(data: data, encoding: .utf8)
        XCTAssertNotNil(convertedData)
        
        // Confirm the data written in is the same as the data we read
        XCTAssertEqual(text, convertedData)
        #endif // !SKIP
    }
}


