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
#if os(Windows)
import WinSDK
#endif

//class TestPortDelegateWithBlock: NSObject, PortDelegate {
//    let block: (PortMessage) -> Void
//    
//    init(block: @escaping (PortMessage) -> Void) {
//        self.block = block
//    }
//    
//    func handle(_ message: PortMessage) {
//        block(message)
//    }
//}

class TestSocketPort : XCTestCase {

    func tcpOrUdpPort(of socketPort: SocketPort) -> Int? {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let data = socketPort.address
        
        #if canImport(Darwin) || os(FreeBSD) || os(OpenBSD)
        let familyOffset = 1
        #else
        let familyOffset = 0
        #endif
        
        if data[data.startIndex + familyOffset] == AF_INET {
            return data.withUnsafeBytes { (buffer) in
                var sin = sockaddr_in()
                withUnsafeMutableBytes(of: &sin) {
                    $0.copyMemory(from: buffer)
                }
                
                return Int(sin.sin_port.bigEndian)
            }
        } else if data[data.startIndex + familyOffset] == AF_INET6 {
            return data.withUnsafeBytes { (buffer) in
                var sin = sockaddr_in6()
                withUnsafeMutableBytes(of: &sin) {
                    $0.copyMemory(from: buffer)
                }
                
                return Int(sin.sin6_port.bigEndian)
            }
        } else {
            return nil
        }
        #endif // !SKIP
    }
    
    func testRemoteSocketPortsAreUniqued() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let a = SocketPort(remoteWithTCPPort: 10000, host: "localhost")
        let b = SocketPort(remoteWithTCPPort: 10000, host: "localhost")
        XCTAssertEqual(a, b)
        #endif // !SKIP
    }
    
    func testInitPicksATCPPort() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let local = try XCTUnwrap(SocketPort(tcpPort: 0))
        defer { local.invalidate() }
        
        let port = try XCTUnwrap(tcpOrUdpPort(of: local))
        XCTAssertNotEqual(port, 0)
        XCTAssert(port >= 1024)
        #endif // !SKIP
    }
    
    func testSendingOneMessageRemoteToLocal() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
//        let local = try XCTUnwrap(SocketPort(tcpPort: 0))
//        defer { local.invalidate() }
//                        
//        let tcpPort = try UInt16(XCTUnwrap(tcpOrUdpPort(of: local)))
//        
//        let remote = try XCTUnwrap(SocketPort(remoteWithTCPPort: tcpPort, host: "localhost"))
//        defer { remote.invalidate() }
//        
//        let data = Data("I cannot weave".utf8)
//
//        let received = expectation(description: "Message received")
//        let delegate = TestPortDelegateWithBlock { message in
//            XCTAssertEqual(message.components as? [AnyHashable], [data as NSData])
//            received.fulfill()
//        }
//        
//        withExtendedLifetime(delegate) {
//            local.setDelegate(delegate)
//            local.schedule(in: .main, forMode: .default)
//            remote.schedule(in: .main, forMode: .default)
//            
//            defer {
//                local.setDelegate(nil)
//                local.remove(from: .main, forMode: .default)
//                remote.remove(from: .main, forMode: .default)
//            }
//            
//            let sent = remote.send(before: Date(timeIntervalSinceNow: 5), components: NSMutableArray(array: [data]), from: nil, reserved: 0)
//            XCTAssertTrue(sent)
//            
//            waitForExpectations(timeout: 5.5)
//        }
        #endif // !SKIP
    }
    
}


