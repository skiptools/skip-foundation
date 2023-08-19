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


class DataURLTestDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {

    #if !SKIP
    var callbacks: [String] = []
    let expectation: XCTestExpectation?
    var data: Data?
    var error: Error?
    var response: URLResponse?
    #endif

    #if !SKIP
    init(expectation: XCTestExpectation?) {
        self.expectation = expectation
    }
    #else
    init() {
    }
    #endif
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        callbacks.append(#function)
        self.error = error
        expectation?.fulfill()
        #endif // !SKIP
    }

    // testProjectGradle():  The following declarations have the same JVM signature (urlSession$SkipFoundation(Lskip/foundation/URLSession;Lskip/lib/Error;)V):
    //func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    //    #if SKIP
    //    throw XCTSkip("TODO")
    //    #else
    //    callbacks.append(#function)
    //    self.error = error
    //    #endif // !SKIP
    //}

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        callbacks.append(#function)
        self.data = data
        #endif // !SKIP
    }

    #if !SKIP
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        callbacks.append(#function)
        self.response = response
        completionHandler(.allow)
        #endif // !SKIP
    }
    #endif
    
    func urlSession(_ session: URLSession, didFailWithError error: Error) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        callbacks.append(#function)
        self.error = error
        #endif // !SKIP
    }
}


class TestDataURLProtocol: XCTestCase {

    #if !SKIP
    typealias ResponseProperties = (expectedContentLength: Int64, mimeType: String?, textEncodingName: String?)
    #endif

    private func run(with url: URL) -> DataURLTestDelegate {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let expect = expectation(description: url.absoluteString)
        let delegate = DataURLTestDelegate(expectation: expect)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 100000
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: url)
        task.resume()
        wait(for: [expect], timeout: 200000)
        return delegate
        #endif // !SKIP
    }

    func test_validURIs() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let tests: [(String, String, ResponseProperties)] = [
            ("data:,123", "123", (expectedContentLength: 3, mimeType: "text/plain", textEncodingName: nil)),
            ("data:;charset=utf-8;base64,8J+RqOKAjfCfkajigI3wn5Gn4oCN8J+Rpw==", "👨‍👨‍👧‍👧", (expectedContentLength: 25, mimeType: "text/plain", textEncodingName: "utf-8")),
            ("data:text/plain;charset=utf-8,%f0%9f%91%a8%e2%80%8d%f0%9f%91%a8%e2%80%8d%f0%9f%91%a7%e2%80%8d%f0%9f%91%a7", "👨‍👨‍👧‍👧", (expectedContentLength: 25, mimeType: "text/plain", textEncodingName: "utf-8")),

            // utf-16 is utf016BE
            ("data:;charset=utf-16;base64,2D3caCAN2D3caCAN2D3cZyAN2D3cZw==", "👨‍👨‍👧‍👧", (expectedContentLength: 22, mimeType: "text/plain", textEncodingName: "utf-16")),
            ("data:;charset=utf-16le;base64,Pdho3A0gPdho3A0gPdhn3A0gPdhn3A==", "👨‍👨‍👧‍👧", (expectedContentLength: 22, mimeType: "text/plain", textEncodingName: "utf-16le")),
            ("data:;charset=utf-16be;base64,2D3caCAN2D3caCAN2D3cZyAN2D3cZw==", "👨‍👨‍👧‍👧", (expectedContentLength: 22, mimeType: "text/plain", textEncodingName: "utf-16be")),
            ("data:application/json;charset=iso-8859-1;key=value,,123", ",123", (expectedContentLength: 4, mimeType: "application/json", textEncodingName: "iso-8859-1")),
            ("data:;charset=utf-8;charset=utf-16;image/png,abc", "abc", (expectedContentLength: 3, mimeType: "text/plain", textEncodingName: "utf-8")),
            ("data:a/b;key=value;charset=macroman,blahblah", "blahblah", (expectedContentLength: 8, mimeType: "a/b", textEncodingName: "macroman")),
        ]

        let callbacks = [
            "urlSession(_:dataTask:didReceive:completionHandler:)",
            "urlSession(_:dataTask:didReceive:)",
            "urlSession(_:task:didCompleteWithError:)",
        ]

        let encodings: [String: String.Encoding] = [
            "us-ascii":   .ascii,
            "utf-8":      .utf8,
            "utf-16":     .utf16,
            "utf-16be":   .utf16BigEndian,
            "utf-16le":   .utf16LittleEndian,
            "utf-32":     .utf32,
            "utf-32be":   .utf32BigEndian,
            "utf-32le":   .utf32LittleEndian,
            "iso-8859-1": .isoLatin1,
        ]

        for (urlString, body, responseProperties) in tests {
            let url = try XCTUnwrap(URL(string: urlString))
            let delegate = run(with: url)

            XCTAssertNil(delegate.error, "\(urlString) returned errors")
            XCTAssertNotNil(delegate.data, "\(urlString) had no data")
            XCTAssertEqual(delegate.callbacks.count, 3, "\(urlString) has wrong callback count")
            XCTAssertEqual(callbacks, delegate.callbacks, "\(urlString) has wrong callbacks")

            if let response = delegate.response {
                let expectedProperties = responseProperties
                XCTAssertEqual(url, response.url)
                XCTAssertEqual(urlString, response.url?.absoluteString)
                XCTAssertEqual(expectedProperties.expectedContentLength, response.expectedContentLength, "\(urlString) has incorrect content Length")
                XCTAssertEqual(expectedProperties.mimeType, response.mimeType, "\(urlString) has incorrect mime type")
                XCTAssertEqual(expectedProperties.textEncodingName, response.textEncodingName, "\(urlString) has incorrect encoding")
                XCTAssertEqual("Unknown", response.suggestedFilename)

                let encoding = encodings[response.textEncodingName ?? "us-ascii"] ?? .ascii
                if let data = delegate.data, let string = String(data: data, encoding: encoding) {
                    XCTAssertEqual(body, string, "\(urlString) has wrong body string")
                } else {
                    XCTFail("Cant convert data to string for \(urlString)")
                }

            } else {
                XCTFail("\(urlString) missing URLResponse")
            }
        }
        #endif // !SKIP
    }

    func test_invalidURIs() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let tests = [
            "data://blah",
            "data:%2c123",
            "data:application_json;charset=iso-8859-%31;key=value,123,",
            "data:appli/cation/json%3bcharset=ISO-8859-1;key=value,,123,"
        ]

        for urlString in tests {
            let url = try XCTUnwrap(URL(string: urlString))
            let delegate = run(with: url)
//            XCTAssertNotNil(delegate.error, "Expected errors for \(urlString)")
//            XCTAssertEqual(delegate.callbacks.count, 1, "Incorrect error count for \(urlString)")
//            XCTAssertEqual(["urlSession(_:task:didCompleteWithError:)"], delegate.callbacks)
//            XCTAssertNil(delegate.response, "Unexpected URLResponse for \(urlString)")
        }
        #endif // !SKIP
    }

}


