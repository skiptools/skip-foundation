// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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

    func testDocumentsDirectory() throws {
        let url = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        #if !SKIP
        XCTAssertEqual("Documents", url.lastPathComponent)
        #else
        // Robolectric:  /var/folders/zl/wkdjv4s1271fbm6w0plzknkh0000gn/T/robolectric-FileManagerTests_testFileLocations_SkipFoundation_debugUnitTest525656974178778848/skip.foundation.test-dataDir/files/
        // Emulator: /data/user/0/skip.foundation.test/files/
        XCTAssertEqual("files", url.lastPathComponent)
        #endif
    }

    func testCachesDirectory() throws {
        let url = try FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        #if !SKIP
        XCTAssertEqual("Caches", url.lastPathComponent)
        #else
        // Emulator: /data/user/0/skip.foundation.test/cache/
        XCTAssertEqual("cache", url.lastPathComponent)
        #endif
    }
}
