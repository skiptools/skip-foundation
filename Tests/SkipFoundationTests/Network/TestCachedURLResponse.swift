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
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestCachedURLResponse : XCTestCase {
    func test_copy() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let userInfo: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: storagePolicy)

        let copiedResponse = cachedResponse.copy() as! CachedURLResponse

        XCTAssertEqual(cachedResponse.response, copiedResponse.response)
        XCTAssertEqual(cachedResponse.data, copiedResponse.data)
        XCTAssertEqual(cachedResponse.userInfo?.keys, copiedResponse.userInfo?.keys)
        XCTAssertEqual(cachedResponse.storagePolicy, copiedResponse.storagePolicy)
        #endif // !SKIP
    }

    func test_initDefaultUserInfoAndStoragePolicy() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let cachedResponse = CachedURLResponse(response: response, data: data)

        XCTAssertEqual(response, cachedResponse.response)
        XCTAssertEqual(data, cachedResponse.data)
        XCTAssertNil(cachedResponse.userInfo)
        XCTAssertEqual(.allowed, cachedResponse.storagePolicy)
        #endif // !SKIP
    }

    func test_initDefaultUserInfo() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let storagePolicy = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse = CachedURLResponse(response: response, data: data, storagePolicy: storagePolicy)

        XCTAssertEqual(response, cachedResponse.response)
        XCTAssertEqual(data, cachedResponse.data)
        XCTAssertNil(cachedResponse.userInfo)
        XCTAssertEqual(storagePolicy, cachedResponse.storagePolicy)
        #endif // !SKIP
    }

    func test_initWithoutDefaults() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let userInfo: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: storagePolicy)

        XCTAssertEqual(response, cachedResponse.response)
        XCTAssertEqual(data, cachedResponse.data)
        XCTAssertEqual(userInfo.keys, cachedResponse.userInfo?.keys)
        XCTAssertEqual(storagePolicy, cachedResponse.storagePolicy)
        #endif // !SKIP
    }

    func test_equalWithTheSameInstance() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let userInfo: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: storagePolicy)

        XCTAssertTrue(cachedResponse.isEqual(cachedResponse))
        #endif // !SKIP
    }

    func test_equalWithUnrelatedObject() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let userInfo: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: storagePolicy)

        XCTAssertFalse(cachedResponse.isEqual(NSObject()))
        #endif // !SKIP
    }

    func test_equalCheckingResponse() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url1 = try XCTUnwrap(URL(string: "http://example.com/"))
        let response1 = URLResponse(url: url1, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let userInfo: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse1 = CachedURLResponse(response: response1, data: data, userInfo: userInfo, storagePolicy: storagePolicy)

        let url2 = try XCTUnwrap(URL(string: "http://example.com/second"))
        let response2 = URLResponse(url: url2, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let cachedResponse2 = CachedURLResponse(response: response2, data: data, userInfo: userInfo, storagePolicy: storagePolicy)

        let url3 = try XCTUnwrap(URL(string: "http://example.com/"))
        let response3 = URLResponse(url: url3, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let cachedResponse3 = CachedURLResponse(response: response3, data: data, userInfo: userInfo, storagePolicy: storagePolicy)

        XCTAssertFalse(cachedResponse1.isEqual(cachedResponse2))
        XCTAssertFalse(cachedResponse2.isEqual(cachedResponse1))
        //XCTAssertTrue(cachedResponse1.isEqual(cachedResponse3))
        //XCTAssertTrue(cachedResponse3.isEqual(cachedResponse1))
        #endif // !SKIP
    }

    func test_equalCheckingData() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes1: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data1 = Data(bytes: bytes1, count: bytes1.count)
        let userInfo: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse1 = CachedURLResponse(response: response, data: data1, userInfo: userInfo, storagePolicy: storagePolicy)

        let bytes2: [UInt8] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        let data2 = Data(bytes: bytes2, count: bytes2.count)
        let cachedResponse2 = CachedURLResponse(response: response, data: data2, userInfo: userInfo, storagePolicy: storagePolicy)

        let bytes3: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data3 = Data(bytes: bytes3, count: bytes3.count)
        let cachedResponse3 = CachedURLResponse(response: response, data: data3, userInfo: userInfo, storagePolicy: storagePolicy)

        XCTAssertFalse(cachedResponse1.isEqual(cachedResponse2))
        XCTAssertFalse(cachedResponse2.isEqual(cachedResponse1))
        //XCTAssertTrue(cachedResponse1.isEqual(cachedResponse3))
        //XCTAssertTrue(cachedResponse3.isEqual(cachedResponse1))
        #endif // !SKIP
    }

    func test_equalCheckingStoragePolicy() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = try XCTUnwrap(URL(string: "http://example.com/"))
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = Data(bytes: bytes, count: bytes.count)
        let userInfo: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy1 = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse1 = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: storagePolicy1)

        let storagePolicy2 = URLCache.StoragePolicy.notAllowed
        let cachedResponse2 = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: storagePolicy2)

        let storagePolicy3 = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse3 = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: storagePolicy3)

        XCTAssertFalse(cachedResponse1.isEqual(cachedResponse2))
        XCTAssertFalse(cachedResponse2.isEqual(cachedResponse1))
        //XCTAssertTrue(cachedResponse1.isEqual(cachedResponse3))
        //XCTAssertTrue(cachedResponse3.isEqual(cachedResponse1))
        #endif // !SKIP
    }

    func test_hash() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url1 = try XCTUnwrap(URL(string: "http://example.com/"))
        let response1 = URLResponse(url: url1, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes1: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data1 = Data(bytes: bytes1, count: bytes1.count)
        let userInfo1: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy1 = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse1 = CachedURLResponse(response: response1, data: data1, userInfo: userInfo1, storagePolicy: storagePolicy1)

        let url2 = try XCTUnwrap(URL(string: "http://example.com/"))
        let response2 = URLResponse(url: url2, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes2: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data2 = Data(bytes: bytes2, count: bytes2.count)
        let userInfo2: [AnyHashable: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let storagePolicy2 = URLCache.StoragePolicy.allowedInMemoryOnly
        let cachedResponse2 = CachedURLResponse(response: response2, data: data2, userInfo: userInfo2, storagePolicy: storagePolicy2)

        // Ideally, this cached response should have a different hash.
        let url3 = try XCTUnwrap(URL(string: "http://example.com/second"))
        let response3 = URLResponse(url: url3, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        let bytes3: [UInt8] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        let data3 = Data(bytes: bytes3, count: bytes3.count)
        let userInfo3: [AnyHashable: Any] = ["Key3": "Value3", "Key2": "Value2"]
        let storagePolicy3 = URLCache.StoragePolicy.notAllowed
        let cachedResponse3 = CachedURLResponse(response: response3, data: data3, userInfo: userInfo3, storagePolicy: storagePolicy3)

        //XCTAssertEqual(cachedResponse1.hash, cachedResponse2.hash)
        XCTAssertNotEqual(cachedResponse1.hash, cachedResponse3.hash)
        XCTAssertNotEqual(cachedResponse2.hash, cachedResponse3.hash)
        #endif // !SKIP
    }

}


