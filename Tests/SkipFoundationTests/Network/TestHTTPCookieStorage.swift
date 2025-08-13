// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

#if !SKIP // disabled for to reduce test count and avoid io.grpc.StatusRuntimeException: RESOURCE_EXHAUSTED: gRPC message exceeds maximum size

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

import Dispatch

class TestHTTPCookieStorage: XCTestCase {

    enum StorageType {
        case shared
        case groupContainer(String)
    }

    override func setUp() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Delete any cookies in the storage
        cookieStorage(for: .shared).removeCookies(since: Date(timeIntervalSince1970: 0))
        cookieStorage(for: .groupContainer("test")).removeCookies(since: Date(timeIntervalSince1970: 0))
        #endif // !SKIP
    }

    func test_sharedCookieStorageAccessedFromMultipleThreads() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let q = DispatchQueue.global()
        let syncQ = DispatchQueue(label: "TestHTTPCookieStorage.syncQ")
        var allCookieStorages: [HTTPCookieStorage] = []
        let g = DispatchGroup()
        for _ in 0..<64 {
            g.enter()
            q.async {
                let mySharedCookieStore = HTTPCookieStorage.shared
                syncQ.async {
                    allCookieStorages.append(mySharedCookieStore)
                    g.leave()
                }
            }
        }
        g.wait()
        let cookieStorages = syncQ.sync { allCookieStorages }
        let mySharedCookieStore = HTTPCookieStorage.shared
        XCTAssertTrue(cookieStorages.reduce(true, { $0 && $1 === mySharedCookieStore }), "\(cookieStorages)")
        #endif // !SKIP
    }

    func test_BasicStorageAndRetrieval() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        basicStorageAndRetrieval(with: .shared)
        basicStorageAndRetrieval(with: .groupContainer("test"))
        #endif // !SKIP
    }

    func test_deleteCookie() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        deleteCookie(with: .shared)
        deleteCookie(with: .groupContainer("test"))
        #endif // !SKIP
    }

    func test_removeCookies() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        removeCookies(with: .shared)
        removeCookies(with: .groupContainer("test"))
        #endif // !SKIP
    }

    func test_cookiesForURL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        setCookiesForURL(with: .shared)
        checkCookiesForURL(with: .shared)

        setCookiesForURL(with: .groupContainer("test"))
        checkCookiesForURL(with: .groupContainer("test"))
        #endif // !SKIP
    }

    func test_cookiesForURLWithMainDocumentURL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        setCookiesForURLWithMainDocumentURL(with: .shared)
        setCookiesForURLWithMainDocumentURL(with: .groupContainer("test"))
        #endif // !SKIP
    }

    func test_descriptionCookie() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        checkCookieDescription(for: .shared)
        checkCookieDescription(for: .groupContainer("test"))
        #endif // !SKIP
    }

    func test_cookieDomainMatching() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        checkCookieDomainMatching(for: .shared)
        checkCookieDomainMatching(for: .groupContainer("test"))
        #endif // !SKIP
    }

    func cookieStorage(for type: StorageType) -> HTTPCookieStorage {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        switch type {
        case .shared:
            return HTTPCookieStorage.shared
        case .groupContainer(let identifier):
            return HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: identifier)
        }
        #endif // !SKIP
    }

    func basicStorageAndRetrieval(with storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)

        let simpleCookie = HTTPCookie(properties: [
           .name: "TestCookie1",
           .value: "Test value @#$%^$&*99",
           .path: "/",
           .domain: "swift.org",
           .expires: Date(timeIntervalSince1970: 1475767775) //expired cookie
        ])!

        storage.setCookie(simpleCookie)
        XCTAssertEqual(storage.cookies!.count, 0)

        let simpleCookie0 = HTTPCookie(properties: [   //no expiry date
           .name: "TestCookie1",
           .value: "Test @#$%^$&*99",
           .path: "/",
           .domain: "swift.org",
        ])!

        storage.setCookie(simpleCookie0)
        XCTAssertEqual(storage.cookies!.count, 1)

        let simpleCookie1 = HTTPCookie(properties: [
           .name: "TestCookie1",
           .value: "Test @#$%^$&*99",
           .path: "/",
           .domain: "swift.org",
        ])!

        storage.setCookie(simpleCookie1)
        XCTAssertEqual(storage.cookies!.count, 1) //test for replacement

        let simpleCookie2 = HTTPCookie(properties: [
           .name: "TestCookie1",
           .value: "Test @#$%^$&*99",
           .path: "/",
           .domain: "example.com",
        ])!

        storage.setCookie(simpleCookie2)
        XCTAssertEqual(storage.cookies!.count, 2)
        #endif // !SKIP
    }

    func deleteCookie(with storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)

        let simpleCookie2 = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test @#$%^$&*99",
            .path: "/",
            .domain: "example.com",
            ])!

        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test value @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
            ])!
        storage.setCookie(simpleCookie)
        storage.setCookie(simpleCookie2)
        XCTAssertEqual(storage.cookies!.count, 2)

        storage.deleteCookie(simpleCookie)
        XCTAssertEqual(storage.cookies!.count, 1)
        storage.deleteCookie(simpleCookie2)
        XCTAssertEqual(storage.cookies!.count, 0)
        #endif // !SKIP
    }

    func removeCookies(with storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)
        let past = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate - 120)
        let future = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate + 120)
        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test value @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
            ])!
        storage.setCookie(simpleCookie)
        XCTAssertEqual(storage.cookies!.count, 1)
        storage.removeCookies(since: future)
        XCTAssertEqual(storage.cookies!.count, 1)
        storage.removeCookies(since: past)
        XCTAssertEqual(storage.cookies!.count, 0)
        #endif // !SKIP
    }

    func setCookiesForURL(with storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)
        let url = URL(string: "https://swift.org")
        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test @#$%^$&*99",
            .path: "/",
            .domain: "example.com",
        ])!

        let simpleCookie1 = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test value @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
        ])!

        storage.setCookies([simpleCookie, simpleCookie1], for: url, mainDocumentURL: nil)
        XCTAssertEqual(storage.cookies!.count, 1)
        #endif // !SKIP
    }

    func checkCookiesForURL(with storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)
        let url = URL(string: "https://swift.org")
        XCTAssertEqual(storage.cookies(for: url!)!.count, 1)
        #endif // !SKIP
    }

    func setCookiesForURLWithMainDocumentURL(with storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)
        storage.cookieAcceptPolicy = .onlyFromMainDocumentDomain
        let url = URL(string: "https://swift.org/downloads")
        let mainUrl = URL(string: "http://ci.swift.org")
        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie2",
            .value: "Test@#$%^$&*99khnia",
            .path: "/",
            .domain: "swift.org",
        ])!
        storage.setCookies([simpleCookie], for: url, mainDocumentURL: mainUrl)
        XCTAssertEqual(storage.cookies(for: url!)!.count, 1)

        let url1 = URL(string: "https://dt.swift.org/downloads")
        let simpleCookie1 = HTTPCookie(properties: [
            .name: "TestCookie3",
            .value: "Test@#$%^$&*999189",
            .path: "/",
            .domain: "swift.org",
        ])!
        storage.setCookies([simpleCookie1], for: url1, mainDocumentURL: mainUrl)
        XCTAssertEqual(storage.cookies(for: url1!)!.count, 0)
        #endif // !SKIP
    }

    func checkCookieDescription(for storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)
        guard let cookies = storage.cookies else {
            XCTFail("No cookies")
            return
        }
        XCTAssertEqual(storage.description, "<NSHTTPCookieStorage cookies count:\(cookies.count)>")

        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test value @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
            ])!
        storage.setCookie(simpleCookie)
        guard let cookies0 = storage.cookies else {
            XCTFail("No cookies")
            return
        }
        XCTAssertEqual(storage.description, "<NSHTTPCookieStorage cookies count:\(cookies0.count)>")

        storage.deleteCookie(simpleCookie)
        guard let cookies1 = storage.cookies else {
            XCTFail("No cookies")
            return
        }
        XCTAssertEqual(storage.description, "<NSHTTPCookieStorage cookies count:\(cookies1.count)>")
        #endif // !SKIP
    }

    func checkCookieDomainMatching(for storageType: StorageType) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = cookieStorage(for: storageType)

        let simpleCookie1 = HTTPCookie(properties: [   // swift.org domain only
           .name: "TestCookie1",
           .value: "TestValue1",
           .path: "/",
           .domain: "swift.org",
        ])!

        storage.setCookie(simpleCookie1)

        let simpleCookie2 = HTTPCookie(properties: [   // *.swift.org
           .name: "TestCookie2",
           .value: "TestValue2",
           .path: "/",
           .domain: ".SWIFT.org",
        ])!

        storage.setCookie(simpleCookie2)

        let simpleCookie3 = HTTPCookie(properties: [   // bugs.swift.org
           .name: "TestCookie3",
           .value: "TestValue3",
           .path: "/",
           .domain: "bugs.swift.org",
        ])!

        storage.setCookie(simpleCookie3)
        XCTAssertEqual(storage.cookies!.count, 3)

        let swiftOrgUrl = URL(string: "https://swift.ORG")!
        let ciSwiftOrgUrl = URL(string: "https://CI.swift.ORG")!
        let bugsSwiftOrgUrl = URL(string: "https://BUGS.swift.org")!
        let exampleComUrl = URL(string: "http://www.example.com")!
        let superSwiftOrgUrl = URL(string: "https://superswift.org")!
        XCTAssertEqual(Set(storage.cookies(for: swiftOrgUrl)!), Set([simpleCookie1, simpleCookie2]))
        XCTAssertEqual(storage.cookies(for: ciSwiftOrgUrl)!, [simpleCookie2])
        XCTAssertEqual(Set(storage.cookies(for: bugsSwiftOrgUrl)!), Set([simpleCookie2, simpleCookie3]))
        XCTAssertEqual(storage.cookies(for: exampleComUrl)!, [])
        XCTAssertEqual(storage.cookies(for: superSwiftOrgUrl)!, [])
        #endif // !SKIP
    }

    func test_cookieInXDGSpecPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
#if XXX && !os(Android) && !DARWIN_COMPATIBILITY_TESTS && !os(Windows)// No XDG on native Foundation
        //Test without setting the environment variable
        let testCookie = HTTPCookie(properties: [
           .name: "TestCookie0",
           .value: "Test @#$%^$&*99mam",
           .path: "/",
           .domain: "sample.com",
        ])!
        let storage = HTTPCookieStorage.shared
        storage.setCookie(testCookie)
        XCTAssertEqual(storage.cookies!.count, 1)
        let destPath: String
        let bundleName = "/" + testBundleName()
        if let xdg_data_home = getenv("XDG_DATA_HOME") {
            destPath = String(utf8String: xdg_data_home)! + bundleName + "/.cookies.shared"
        } else {
            destPath = NSHomeDirectory() + "/.local/share" + bundleName + "/.cookies.shared"
        }
        let fm = FileManager.default
        var isDir: ObjCBool = false
        let exists = fm.fileExists(atPath: destPath, isDirectory: &isDir)
        XCTAssertTrue(exists)

        // Test by setting the environmental variable
        let task = Process()
        task.executableURL = xdgTestHelperURL()
        task.arguments = ["--xdgcheck"]
        var environment = ProcessInfo.processInfo.environment
        let testPath = NSHomeDirectory() + "/TestXDG"
        environment["XDG_DATA_HOME"] = testPath
        task.environment = environment

        // Launch the task
        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus
        XCTAssertEqual(status, 0)
        let terminationReason = task.terminationReason
        XCTAssertEqual(terminationReason, Process.TerminationReason.exit)
        try? fm.removeItem(atPath: testPath)
#endif
        #endif // !SKIP
    }
    
    func test_sorting() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = HTTPCookieStorage.shared
        let url = URL(string: "https://swift.org")
        let cookie = HTTPCookie(properties: [
            .name: "A",
            .value: "3",
            .path: "/1",
            .domain: "swift.org",
        ])!
        
        let cookie2 = HTTPCookie(properties: [
            .name: "B",
            .value: "2",
            .path: "/2",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
        ])!

        let cookie3 = HTTPCookie(properties: [
            .name: "C",
            .value: "1",
            .path: "/2",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 2000)
        ])!
        
        storage.setCookies([cookie, cookie2, cookie3], for: url, mainDocumentURL: url)
        let result = storage.sortedCookies(using: [
            NSSortDescriptor(keyPath: \HTTPCookie.path, ascending: true),
            NSSortDescriptor(keyPath: \HTTPCookie.name, ascending: false),
        ])
        
        XCTAssertEqual(result, [cookie, cookie3, cookie2])
        #endif // !SKIP
    }
    

}


#endif

