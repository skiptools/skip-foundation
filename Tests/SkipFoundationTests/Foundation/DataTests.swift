// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
final class DataTests: XCTestCase {
    func testDataFile() throws {
        let hostsFile: URL = URL(fileURLWithPath: "/etc/hosts", isDirectory: false)

        let hostsData: Data = try Data(contentsOf: hostsFile)
        XCTAssertNotEqual(0, hostsData.count)
    }

    func testDataDownload() throws {
        try failOnAndroid() // no android.permission.INTERNET
        let url: URL = try XCTUnwrap(URL(string: "https://skip.dev"))

        let urlData: Data = try Data(contentsOf: url)

        //logger.log("downloaded url size: \(urlData.count)") // ~1256
        XCTAssertNotEqual(0, urlData.count)

        let url2 = try XCTUnwrap(URL(string: "docs", relativeTo: URL(string: "https://skip.dev")))
        let url2Data: Data = try Data(contentsOf: url2)

        //logger.log("downloaded url2 size: \(url2Data.count)") // ~1256
        XCTAssertNotEqual(0, url2Data.count)
    }

    func testStringEncoding() {
        do {
            let str = "𝄞𝕥𝟶𠂊"

            XCTAssertEqual("f09d849ef09d95a5f09d9fb6f0a0828a", str.data(using: .utf8)?.hex())

            XCTAssertEqual("fffe34d81edd35d865dd35d8f6df40d88adc", str.data(using: .utf16)?.hex())
            XCTAssertEqual("d834dd1ed835dd65d835dff6d840dc8a", str.data(using: .utf16BigEndian)?.hex())
            XCTAssertEqual("34d81edd35d865dd35d8f6df40d88adc", str.data(using: .utf16LittleEndian)?.hex())

            XCTAssertEqual("fffe00001ed1010065d50100f6d701008a000200", str.data(using: .utf32)?.hex())
            XCTAssertEqual("1ed1010065d50100f6d701008a000200", str.data(using: .utf32LittleEndian)?.hex())
            XCTAssertEqual("0001d11e0001d5650001d7f60002008a", str.data(using: .utf32BigEndian)?.hex())
        }

        do {
            let str = "\u{0065}\u{0301}" // eWithAcuteCombining

            XCTAssertEqual("65cc81", str.data(using: .utf8)?.hex())

            XCTAssertEqual("fffe65000103", str.data(using: .utf16)?.hex())
            XCTAssertEqual("65000103", str.data(using: .utf16LittleEndian)?.hex())
            XCTAssertEqual("00650301", str.data(using: .utf16BigEndian)?.hex())

            XCTAssertEqual("fffe00006500000001030000", str.data(using: .utf32)?.hex())
            XCTAssertEqual("6500000001030000", str.data(using: .utf32LittleEndian)?.hex())
            XCTAssertEqual("0000006500000301", str.data(using: .utf32BigEndian)?.hex())
        }
    }

    func testDataContains() throws {
        XCTAssertTrue(Data().contains(Data()))
        XCTAssertTrue(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data()))

        XCTAssertTrue(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data([UInt8(0x02)])))
        XCTAssertTrue(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data([UInt8(0x01), UInt8(0x02)])))
        XCTAssertTrue(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)])))
        XCTAssertTrue(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data([UInt8(0x02), UInt8(0x03)])))
        XCTAssertTrue(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data([UInt8(0x03)])))

        XCTAssertFalse(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data([UInt8(0x04)])))
        XCTAssertFalse(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)]).contains(Data([UInt8(0x01), UInt8(0x02), UInt8(0x03), UInt8(0x04)])))
        XCTAssertFalse(Data([UInt8(0x01)]).contains(Data([UInt8(0x02), UInt8(0x03), UInt8(0x04)])))
        XCTAssertFalse(Data([UInt8(0x01)]).contains(Data([UInt8(0x01), UInt8(0x02)])))
        XCTAssertFalse(Data([UInt8(0x01)]).contains(Data([UInt8(0x02)])))
        XCTAssertFalse(Data().contains(Data([UInt8(0x01)])))
    }

    func testBase64EncodedString() {
        let data = Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)])
        XCTAssertEqual("AQID", data.base64EncodedString())
        let data2 = Data(base64Encoded: "AQID")
        XCTAssertEqual(data, data2)
    }

    func testByteArrays() {
        let inbytes = [UInt8(8), UInt8(9), UInt8(10)]
        let data = Data(inbytes)
        let outbytes = [UInt8](data)
        XCTAssertEqual(outbytes, inbytes)

        let outbytes2: [UInt8] = .init(data)
        XCTAssertEqual(outbytes2, inbytes)
    }
}

extension Sequence where Element == UInt8 {
    /// Convert this sequence of bytes into a hex string
    public func hex() -> String { map { String(format: "%02x", $0) }.joined() }
}
