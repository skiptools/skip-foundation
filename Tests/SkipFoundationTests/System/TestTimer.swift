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

class TestTimer : XCTestCase {
    
    func test_timerInit() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let fireDate = Date()
        let timeInterval: TimeInterval = 0.3

        let timer = Timer(fire: fireDate, interval: timeInterval, repeats: false) { _ in }
        XCTAssertEqual(timer.fireDate, fireDate)
        XCTAssertEqual(timer.timeInterval, 0, "Time interval should be 0 for a non repeating Timer")
        XCTAssert(timer.isValid)

        let repeatingTimer = Timer(fire: fireDate, interval: timeInterval, repeats: true) { _ in }
        XCTAssertEqual(repeatingTimer.fireDate, fireDate)
        XCTAssertEqual(repeatingTimer.timeInterval, timeInterval)
        XCTAssert(timer.isValid)
        #endif // !SKIP
    }
    
    func test_timerTickOnce() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var flag = false
        
        let dummyTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
            XCTAssertFalse(flag)

            flag = true
            timer.invalidate()
        }

        let runLoop = RunLoop.current
        runLoop.add(dummyTimer, forMode: .default)
        runLoop.run(until: Date(timeIntervalSinceNow: 0.05))
        
        XCTAssertTrue(flag)
        #endif // !SKIP
    }

//    func test_timerRepeats() {
//        var flag = 0
//        let interval = TimeInterval(0.1)
//        let numberOfRepeats = 3
//        var previousInterval = Date().timeIntervalSince1970
//
//        let dummyTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
//            XCTAssertEqual(timer.timeInterval, interval)
//
//            let currentInterval = Date().timeIntervalSince1970
//            XCTAssertEqual(currentInterval, previousInterval + interval, accuracy: 0.2)
//            previousInterval = currentInterval
//
//            flag += 1
//            if (flag == numberOfRepeats) {
//                timer.invalidate()
//            }
//        }
//
//        let runLoop = RunLoop.current
//        runLoop.add(dummyTimer, forMode: .default)
//        runLoop.run(until: Date(timeIntervalSinceNow: interval * Double(numberOfRepeats + 1)))
//
//        XCTAssertEqual(flag, numberOfRepeats)
//    }

    func test_timerInvalidate() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var flag = false
        
        let dummyTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            XCTAssertTrue(timer.isValid)
            XCTAssertFalse(flag) // timer should tick only once
            
            flag = true
            
            timer.invalidate()
            XCTAssertFalse(timer.isValid)
        }
        
        let runLoop = RunLoop.current
        runLoop.add(dummyTimer, forMode: .default)
        runLoop.run(until: Date(timeIntervalSinceNow: 0.05))
        
        XCTAssertTrue(flag)
        #endif // !SKIP
    }

}


