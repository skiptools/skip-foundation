// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

// SKIP INSERT: @org.junit.runner.RunWith(androidx.test.ext.junit.runners.AndroidJUnit4::class)
// SKIP INSERT: @org.robolectric.annotation.Config(manifest=org.robolectric.annotation.Config.NONE, sdk = [33])
@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 8, *)
final class URLTests: XCTestCase {
    func testURLs() throws {
        let url: URL? = URL(string: "https://github.com/skiptools/skip.git")
        XCTAssertEqual("https://github.com/skiptools/skip.git", url?.absoluteString)
        XCTAssertEqual("/skiptools/skip.git", url?.path)
        XCTAssertEqual("github.com", url?.host)
        XCTAssertEqual("git", url?.pathExtension)
        XCTAssertEqual("skip.git", url?.lastPathComponent)
        XCTAssertEqual(false, url?.isFileURL)
    }

    func testDefaultURLSessionConfiguration() {
        let config = URLSessionConfiguration.default
        XCTAssertEqual(nil, config.identifier)
        XCTAssertEqual(60.0, config.timeoutIntervalForRequest)
        XCTAssertEqual(604800.0, config.timeoutIntervalForResource)
        XCTAssertEqual(true, config.allowsCellularAccess)
        //XCTAssertEqual(true, config.allowsExpensiveNetworkAccess)
        XCTAssertEqual(true, config.allowsConstrainedNetworkAccess)
        XCTAssertEqual(false, config.waitsForConnectivity)
        XCTAssertEqual(false, config.isDiscretionary)
        XCTAssertEqual(nil, config.sharedContainerIdentifier)
        XCTAssertEqual(false, config.sessionSendsLaunchEvents)
        //XCTAssertEqual(nil, config.connectionProxyDictionary)
        XCTAssertEqual(false, config.httpShouldUsePipelining)
        XCTAssertEqual(true, config.httpShouldSetCookies)
        //XCTAssertEqual(nil, config.httpAdditionalHeaders)
        XCTAssertEqual(6, config.httpMaximumConnectionsPerHost)
        XCTAssertEqual(false, config.shouldUseExtendedBackgroundIdleMode)
    }

    func testEphemeralURLSessionConfiguration() {
        let config = URLSessionConfiguration.ephemeral
        XCTAssertEqual(nil, config.identifier)
        XCTAssertEqual(60.0, config.timeoutIntervalForRequest)
        XCTAssertEqual(604800.0, config.timeoutIntervalForResource)
        XCTAssertEqual(true, config.allowsCellularAccess)
        //XCTAssertEqual(true, config.allowsExpensiveNetworkAccess)
        XCTAssertEqual(true, config.allowsConstrainedNetworkAccess)
        XCTAssertEqual(false, config.waitsForConnectivity)
        XCTAssertEqual(false, config.isDiscretionary)
        XCTAssertEqual(nil, config.sharedContainerIdentifier)
        XCTAssertEqual(false, config.sessionSendsLaunchEvents)
        //XCTAssertEqual(nil, config.connectionProxyDictionary)
        XCTAssertEqual(false, config.httpShouldUsePipelining)
        XCTAssertEqual(true, config.httpShouldSetCookies)
        //XCTAssertEqual(nil, config.httpAdditionalHeaders)
        XCTAssertEqual(6, config.httpMaximumConnectionsPerHost)
        XCTAssertEqual(false, config.shouldUseExtendedBackgroundIdleMode)
    }

    let testURL = URL(string: "https://raw.githubusercontent.com/w3c/activitypub/1a6e82e77da5f36a17e3ebd4be3f7b42a33f82da/w3c.json")!

    func testFetchURLAsync() async throws {
        let (data, response) = try await URLSession.shared.data(from: testURL)

        let HTTPResponse = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual("text/plain", HTTPResponse.mimeType)
        XCTAssertEqual("utf-8", HTTPResponse.textEncodingName)
        XCTAssertEqual(104, HTTPResponse.expectedContentLength)

        XCTAssertEqual(104, data.count)
        XCTAssertEqual(String(data: data, encoding: String.Encoding.utf8), """
        {
          "group": 72531,
          "contacts": [
            "plehegar"
          ],
          "policy": "open",
          "repo-type": "rec-track"
        }
        """)
    }

    func testDownloadURLAsync() async throws {
        let (localURL, response) = try await URLSession.shared.download(from: testURL)
        let HTTPResponse = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual("text/plain", HTTPResponse.mimeType)
        XCTAssertEqual("utf-8", HTTPResponse.textEncodingName)
        XCTAssertEqual(104, HTTPResponse.expectedContentLength)

        let data = try Data(contentsOf: localURL)
        XCTAssertEqual(104, data.count)
        XCTAssertEqual(String(data: data, encoding: String.Encoding.utf8), """
        {
          "group": 72531,
          "contacts": [
            "plehegar"
          ],
          "policy": "open",
          "repo-type": "rec-track"
        }
        """)
    }

    func testAsyncBytes() async throws {
        let (bytes, response) = try await URLSession.shared.bytes(from: testURL)
        let HTTPResponse = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual("text/plain", HTTPResponse.mimeType)
        XCTAssertEqual("utf-8", HTTPResponse.textEncodingName)
        XCTAssertEqual(104, HTTPResponse.expectedContentLength)

        //let data = try await bytes.reduce(into: Data(), { dat, byte in
        //    var d: Data = dat // Unresolved reference with inout
        //    var b: [UInt8] = [byte]
        //    dat.append(contentsOf: [byte])
        //})

        //XCTAssertEqual(String(data: data, encoding: String.Encoding.utf8), """
        //{
        //  "group": 72531,
        //  "contacts": [
        //    "plehegar"
        //  ],
        //  "policy": "open",
        //  "repo-type": "rec-track"
        //}
        //""")
    }

    func testAsyncStream() async throws {
        #if SKIP
        throw XCTSkip("TODO: SkipAsyncStream")
        #else
        var numbers = (1...10).makeIterator()
        let stream = AsyncStream(unfolding: { numbers.next() }, onCancel: nil)
        // TODO: implement `for await number in stream { … }`
        let sum = await stream.reduce(0, +)
        XCTAssertEqual(55, sum)
        #endif
    }
}
