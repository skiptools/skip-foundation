// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
final class UUIDTests: XCTestCase {
    func testRandomUUID() throws {
        XCTAssertNotEqual(UUID(), UUID())
        XCTAssertNotEqual("", UUID().uuidString)
        //logger.log("UUID: \(UUID().uuidString)")
    }

    func testFixedUUID() throws {
        let uuid: UUID? = UUID(uuidString: "d500d1f7-ddb0-439b-ab90-22fdbe5b5790")
        XCTAssertEqual("D500D1F7-DDB0-439B-AB90-22FDBE5B5790", uuid?.uuidString)
    }

    func testUUIDFromBits() throws {
        #if SKIP // works, but would require import SkipFoundation.UUID
        XCTAssertEqual("00000000-0000-0000-0000-000000000000", UUID(mostSigBits: 0, leastSigBits: 0).uuidString)
        XCTAssertEqual("00000000-0000-0001-0000-000000000000", UUID(mostSigBits: 1, leastSigBits: 0).uuidString)
        XCTAssertEqual("00000000-0000-0000-0000-000000000001", UUID(mostSigBits: 0, leastSigBits: 1).uuidString)
        XCTAssertEqual("00000000-0000-0064-0000-000000000064", UUID(mostSigBits: 100, leastSigBits: 100).uuidString)
        XCTAssertEqual("112210F4-7DE9-8115-0DB4-DA5F49F8B478", UUID(mostSigBits: 1234567890123456789, leastSigBits: 987654321098765432).uuidString)
        XCTAssertEqual("00000000-0005-3D9D-0000-000151280C98", UUID(mostSigBits: 343453, leastSigBits: 5656546456).uuidString)

        // SKIP REPLACE: val mx = Long.MAX_VALUE
        let mx = Int64.max
        // SKIP REPLACE: val mn = Long.MIN_VALUE
        let mn = Int64.min

        XCTAssertEqual("7FFFFFFF-FFFF-FFFF-7FFF-FFFFFFFFFFFF", UUID(mostSigBits: mx, leastSigBits: mx).uuidString)
        XCTAssertEqual("7FFFFFFF-FFFF-FFFF-8000-000000000000", UUID(mostSigBits: mx, leastSigBits: mn).uuidString)
        XCTAssertEqual("80000000-0000-0000-8000-000000000000", UUID(mostSigBits: mn, leastSigBits: mn).uuidString)
        XCTAssertEqual("7FFFFFFF-FFFF-FFFF-8000-000000000000", UUID(mostSigBits: mx, leastSigBits: mn).uuidString)
        #endif
    }

    func test_UUIDEquality() {
        let uuidA = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
        let uuidB = UUID(uuidString: "e621e1f8-c36c-495a-93fc-0c247a3e6e5f")
//        let uuidC = UUID(uuid: (0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f))
        let uuidD = UUID()

        XCTAssertEqual(uuidA, uuidB, "String case must not matter.")
//        XCTAssertEqual(uuidA, uuidC, "A UUID initialized with a string must be equal to the same UUID initialized with its UnsafePointer<UInt8> equivalent representation.")
        XCTAssertNotEqual(uuidB, uuidD, "Two different UUIDs must not be equal.")
    }

    func test_UUIDInvalid() {
        let uuid = UUID(uuidString: "Invalid UUID")
        XCTAssertNil(uuid, "The convenience initializer `init?(uuidString string:)` must return nil for an invalid UUID string.")
    }

//    func test_UUIDuuidString() {
//        let uuid = UUID(uuid: (0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f))
//        XCTAssertEqual(uuid.uuidString, "E621E1F8-C36C-495A-93FC-0C247A3E6E5F", "The uuidString representation must be uppercase.")
//    }

    func test_UUIDdescription() {
        let uuid = UUID()
        XCTAssertEqual(uuid.description, uuid.uuidString, "The description must be the same as the uuidString.")
    }

}
