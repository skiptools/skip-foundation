// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
final class FileManagerTests: XCTestCase {
    func testFileManager() throws {
        let tmp = NSTemporaryDirectory()
        //logger.log("temporary folder: \(tmp)")
        XCTAssertNotNil(tmp)
        XCTAssertNotEqual("", tmp)

        let fm = FileManager.default
        XCTAssertNotNil(fm)

        XCTAssertEqual("NSFileAppendOnly", FileAttributeKey.appendOnly.rawValue)
        XCTAssertEqual("NSFileCreationDate", FileAttributeKey.creationDate.rawValue)
        XCTAssertEqual("NSFileDeviceIdentifier", FileAttributeKey.deviceIdentifier.rawValue)
        XCTAssertEqual("NSFileExtensionHidden", FileAttributeKey.extensionHidden.rawValue)
        XCTAssertEqual("NSFileGroupOwnerAccountID", FileAttributeKey.groupOwnerAccountID.rawValue)
        XCTAssertEqual("NSFileGroupOwnerAccountName", FileAttributeKey.groupOwnerAccountName.rawValue)
        XCTAssertEqual("NSFileHFSCreatorCode", FileAttributeKey.hfsCreatorCode.rawValue)
        XCTAssertEqual("NSFileHFSTypeCode", FileAttributeKey.hfsTypeCode.rawValue)
        XCTAssertEqual("NSFileImmutable", FileAttributeKey.immutable.rawValue)
        XCTAssertEqual("NSFileModificationDate", FileAttributeKey.modificationDate.rawValue)
        XCTAssertEqual("NSFileOwnerAccountID", FileAttributeKey.ownerAccountID.rawValue)
        XCTAssertEqual("NSFileOwnerAccountName", FileAttributeKey.ownerAccountName.rawValue)
        XCTAssertEqual("NSFilePosixPermissions", FileAttributeKey.posixPermissions.rawValue)
        XCTAssertEqual("NSFileProtectionKey", FileAttributeKey.protectionKey.rawValue)
        XCTAssertEqual("NSFileReferenceCount", FileAttributeKey.referenceCount.rawValue)
        XCTAssertEqual("NSFileSystemFileNumber", FileAttributeKey.systemFileNumber.rawValue)
        XCTAssertEqual("NSFileSystemFreeNodes", FileAttributeKey.systemFreeNodes.rawValue)
        XCTAssertEqual("NSFileSystemFreeSize", FileAttributeKey.systemFreeSize.rawValue)
        XCTAssertEqual("NSFileSystemNodes", FileAttributeKey.systemNodes.rawValue)
        XCTAssertEqual("NSFileSystemNumber", FileAttributeKey.systemNumber.rawValue)
        XCTAssertEqual("NSFileSystemSize", FileAttributeKey.systemSize.rawValue)
        XCTAssertEqual("NSFileType", FileAttributeKey.type.rawValue)
        XCTAssertEqual("NSFileBusy", FileAttributeKey.busy.rawValue)

    }
}
