// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
final class DataTests: XCTestCase {
    func testData() throws {
        let hostsFile: URL = URL(fileURLWithPath: "/etc/hosts", isDirectory: false)

        let hostsData: Data = try Data(contentsOf: hostsFile)
        XCTAssertNotEqual(0, hostsData.count)

        let url: URL = try XCTUnwrap(URL(string: "https://www.example.com"))
        let urlData: Data = try Data(contentsOf: url)

        //logger.log("downloaded url size: \(urlData.count)") // ~1256
        XCTAssertNotEqual(0, urlData.count)

        let url2 = try XCTUnwrap(URL(string: "domains/reserved", relativeTo: URL(string: "https://www.iana.org")))
        let url2Data: Data = try Data(contentsOf: url2)

        //logger.log("downloaded url2 size: \(url2Data.count)") // ~1256
        XCTAssertNotEqual(0, url2Data.count)
    }
}
