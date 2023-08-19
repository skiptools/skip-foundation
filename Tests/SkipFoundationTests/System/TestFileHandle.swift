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
// Copyright (c) 2016, 2018, 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if !SKIP
import Dispatch
#endif
#if os(Windows)
import WinSDK
#endif

@available(macOS 10.15, iOS 13.4, watchOS 6.0, tvOS 13.0, *)
class TestFileHandle : XCTestCase {
    #if !SKIP
    var allHandles: [FileHandle] = []
    #endif
    var allTemporaryFileURLs: [URL] = []

    #if !SKIP
    let content: Data = {
        return """
        CHAPTER I.

        The Author gives some account of himself and family--His first
        inducements to travel--He is shipwrecked, and swims for his life--Gets
        safe on shore in the country of Lilliput--Is made a prisoner, and
        carried up the country

        CHAPTER II.

        The emperor of Lilliput, attended by several of the nobility, comes to
        see the Author in his confinement--The emperor's person and habits
        described--Learned men appointed to teach the Author their language--He
        gains favor by his mild disposition--His pockets are searched, and his
        sword and pistols taken from him

        CHAPTER III.

        The Author diverts the emperor, and his nobility of both sexes, in a
        very uncommon manner--The diversions of the court of Lilliput
        described--The Author has his liberty granted him upon certain
        conditions

        CHAPTER IV.

        Mildendo, the metropolis of Lilliput, described, together with the
        emperor's palace--A conversation between the Author and a principal
        secretary concerning the affairs of that empire--The Author's offers to
        serve the emperor in his wars

        CHAPTER V.

        The Author, by an extraordinary stratagem, prevents an invasion--A high
        title of honor is conferred upon him--Ambassadors arrive from the
        emperor of Blefuscu, and sue for peace
        """.data(using: String.Encoding.utf8)!
    }()
    #endif

    #if !SKIP
    func createTemporaryFile(containing data: Data = Data()) -> URL {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)

        allTemporaryFileURLs.append(url)

        expectDoesNotThrow({ try data.write(to: url) }, "Couldn't create file at \(url.path) for testing")

        return url
        #endif // !SKIP
    }
    #endif
    
    #if !SKIP
    func createFileHandle() -> FileHandle {
        let url = createTemporaryFile(containing: content)

        var fh: FileHandle?
        expectDoesNotThrow({ fh = try FileHandle(forReadingFrom: url) }, "Couldn't create file handle.")

        allHandles.append(fh!)
        return fh!
    }

    func createFileHandleForUpdating() -> FileHandle {
        let url = createTemporaryFile(containing: content)

        var fh: FileHandle!
        expectDoesNotThrow({ fh = try FileHandle(forUpdating: url) }, "Couldn't create file handle.")

        allHandles.append(fh)
        return fh
    }
    #endif // !SKIP

#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT
    func createFileHandleForSeekErrors() -> FileHandle {
        #if SKIP
        throw XCTSkip("TODO")
        #else
#if os(Windows)
        var hReadPipe: HANDLE? = INVALID_HANDLE_VALUE
        var hWritePipe: HANDLE? = INVALID_HANDLE_VALUE
        if !CreatePipe(&hReadPipe, &hWritePipe, nil, 0) {
          assert(false)
        }

        if !CloseHandle(hWritePipe) {
          assert(false)
        }

        return FileHandle(handle: hReadPipe!, closeOnDealloc: true)
#else
        var fds: [Int32] = [-1, -1]
        fds.withUnsafeMutableBufferPointer { (pointer) -> Void in
            pipe(pointer.baseAddress)
        }
        
        close(fds[1])
        
        let fh = FileHandle(fileDescriptor: fds[0], closeOnDealloc: true)
        allHandles.append(fh)
        return fh
#endif
        #endif // !SKIP
    }
#endif

    #if !SKIP
    let seekError = NSError(domain: NSCocoaErrorDomain, code: NSFileReadUnknownError, userInfo: [ NSUnderlyingErrorKey: NSError(domain: NSPOSIXErrorDomain, code: Int(ESPIPE), userInfo: [:])])
    #endif

    #if !SKIP
    func createFileHandleForReadErrors() -> FileHandle {
        // Create a file handle where calling read returns -1.
        // Accomplish this by creating one for a directory.
#if os(Windows)
        let hDirectory: HANDLE = ".".withCString(encodedAs: UTF16.self) {
            // NOTE(compnerd) we need the FILE_FLAG_BACKUP_SEMANTICS so that we
            // can create the handle to the directory.
            CreateFileW($0, GENERIC_READ,
                        DWORD(FILE_SHARE_DELETE | FILE_SHARE_READ | FILE_SHARE_WRITE),
                        nil, DWORD(OPEN_EXISTING),
                        DWORD(FILE_ATTRIBUTE_NORMAL | FILE_FLAG_BACKUP_SEMANTICS), nil)
        }
        if hDirectory == INVALID_HANDLE_VALUE {
          fatalError("unable to create handle to current directory")
        }
        let fd = _open_osfhandle(intptr_t(bitPattern: hDirectory), 0)
        if fd == -1 {
          fatalError("unable to associate file descriptor with handle")
        }
        let fh = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
#else
        let fd = open(".", O_RDONLY)
        expectTrue(fd > 0, "We must be able to open a fd to the current directory (.)")
        let fh = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
#endif
        allHandles.append(fh)
        return fh
    }
    #endif // !SKIP

#if !SKIP
#if os(Windows)
    let readError = NSError(domain: NSCocoaErrorDomain, code: NSFileReadUnknownError, userInfo: [ NSUnderlyingErrorKey: NSError(domain: "org.swift.Foundation.WindowsError", code: 1, userInfo: [:])])
#else
    let readError = NSError(domain: NSCocoaErrorDomain, code: NSFileReadUnknownError, userInfo: [ NSUnderlyingErrorKey: NSError(domain: NSPOSIXErrorDomain, code: Int(EISDIR), userInfo: [:])])
#endif
#endif

    override func tearDown() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for handle in allHandles {
            print("Closing \(handle)…")
            try? handle.close()
        }
        
        for url in allTemporaryFileURLs {
            print("Deleting \(url)…")
            try? FileManager.default.removeItem(at: url)
        }
        
        allHandles = []
        allTemporaryFileURLs = []
        #endif // !SKIP
    }

#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT
    func testHandleCreationAndCleanup() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        _ = createFileHandle()
        _ = createFileHandleForSeekErrors()
        _ = createFileHandleForReadErrors()
        #endif // !SKIP
    }
#endif

    func testReadUpToCount() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandle()
        
        // Zero:
        expectDoesNotThrow({
            let zeroData = try handle.read(upToCount: 0)
            expectEqual(zeroData, nil, "Data should be nil")
        }, "Must not throw while reading zero data")
        
        // Max:
        expectDoesNotThrow({
            let maxData = try handle.read(upToCount: Int.max)
            expectEqual(maxData, content, "Data should be equal to the content")
        }, "Must not throw while reading Int.max data")
        
        // EOF:
        expectDoesNotThrow({
            let eof = try handle.read(upToCount: Int.max)
            expectEqual(eof, nil, "EOF should return nil")
        }, "Must not throw while reading EOF")
        
        // One byte at a time
        let onesHandle = createFileHandle()
        expectDoesNotThrow({
            for index in content.indices {
                let oneByteData = try onesHandle.read(upToCount: 1)
                let expected = content[index ..< content.index(after: index)]
                expectEqual(oneByteData, expected, "Read incorrect data at index \(index)")
            }
        }, "Must not throw while reading one byte at a time")
        
        // EOF:
        expectDoesNotThrow({
            let eof = try handle.read(upToCount: 1)
            expectEqual(eof, nil, "EOF should return nil")
        }, "Must not throw while reading one-byte-at-a-time EOF")
        
        // Errors:
//        expectThrows(readError, {
//            _ = try createFileHandleForReadErrors().read(upToCount: 1)
//        }, "Must throw when encountering a read error")
        #endif // !SKIP
    }
    
    func testReadToEnd() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandle()
        
        // To end:
        expectDoesNotThrow({
            let maxData = try handle.readToEnd()
            expectEqual(maxData, content, "Data to end should equal what was written out")
        }, "Must not throw while reading to end")
        
        // EOF:
        expectDoesNotThrow({
            let eof = try handle.readToEnd()
            expectEqual(eof, nil, "EOF should return nil")
        }, "Must not throw while reading EOF")
        
        // Errors:
//        expectThrows(readError, {
//            _ = try createFileHandleForReadErrors().readToEnd()
//        }, "Must throw when encountering a read error")
        #endif // !SKIP
    }

    func testOffset() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT && !os(Windows)
        // One byte at a time:
        let handle = createFileHandle()
        var offset: UInt64 = 0
        
        for index in content.indices {
            expectDoesNotThrow({ offset = try handle.offset() }, "Reading the offset must not throw")
            expectEqual(offset, UInt64(index), "The offset must match")
            expectDoesNotThrow({ _ = try handle.read(upToCount: 1) }, "Advancing by reading must not throw")
        }
        
        expectDoesNotThrow({ offset = try handle.offset() }, "Reading the offset at EOF must not throw")
        expectEqual(offset, UInt64(content.count), "The offset at EOF must be at the end")
        
        // Error:
        expectThrows(seekError, {
            _ = try createFileHandleForSeekErrors().offset()
        }, "Must throw when encountering a seek error")
#endif
        #endif // !SKIP
    }

    func performWriteTest<T: DataProtocol>(with data: T, expecting expectation: Data? = nil) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url = createTemporaryFile()

        var maybeFH: FileHandle?
        expectDoesNotThrow({ maybeFH = try FileHandle(forWritingTo: url) }, "Opening write handle must succeed")
        guard let fh = maybeFH else { return }
        allHandles.append(fh)

        expectDoesNotThrow({ try fh.write(contentsOf: data) }, "Writing must succeed")

        expectDoesNotThrow({ try fh.close() }, "Closing write handle must succeed")

        var readData: Data?
        expectDoesNotThrow({ readData = try Data(contentsOf: url) }, "Must be able to read data")

        expectEqual(readData, expectation ?? content, "The content must be the same")
        #endif // !SKIP
    }
    
    func testWritingWithData() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        performWriteTest(with: content)
        #endif // !SKIP
    }
    
    func testWritingWithBuffer() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        content.withUnsafeBytes { (buffer) in
            performWriteTest(with: buffer)
        }
        #endif // !SKIP
    }
    
    func testWritingWithMultiregionData() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var expectation = Data()
        expectation.append(content)
        expectation.append(content)
        expectation.append(content)
        expectation.append(content)
        
        content.withUnsafeBytes { (buffer) in
            let data1 = DispatchData(bytes: buffer)
            let data2 = DispatchData(bytes: buffer)
            
            var multiregion1: DispatchData = .empty
            multiregion1.append(data1)
            multiregion1.append(data2)
            
            var multiregion2: DispatchData = .empty
            multiregion2.append(data1)
            multiregion2.append(data2)
            
            var longMultiregion: DispatchData = .empty
            longMultiregion.append(multiregion1)
            longMultiregion.append(multiregion2)
            
            expectTrue(longMultiregion.regions.count > 0, "The multiregion data must be actually composed of multiple regions")
            
            performWriteTest(with: longMultiregion, expecting: expectation)
        }
        #endif // !SKIP
    }

    func test_constants() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(FileHandle.readCompletionNotification.rawValue, "NSFileHandleReadCompletionNotification",
                       "\(FileHandle.readCompletionNotification.rawValue) is not equal to NSFileHandleReadCompletionNotification")
        #endif // !SKIP
    }

#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT
    func test_nullDevice() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let fh = FileHandle.nullDevice

        XCTAssertFalse(fh._isPlatformHandleValid)
        fh.closeFile()
        fh.seek(toFileOffset: 10)
        XCTAssertEqual(fh.offsetInFile, 0)
        XCTAssertEqual(fh.seekToEndOfFile(), 0)
        XCTAssertEqual(fh.readData(ofLength: 15).count, 0)
        fh.synchronizeFile()

        fh.write(Data([1,2]))
        fh.seek(toFileOffset: 0)
        XCTAssertEqual(fh.availableData.count, 0)
        fh.write(Data([1,2]))
        fh.seek(toFileOffset: 0)
        XCTAssertEqual(fh.readDataToEndOfFile().count, 0)
        #endif // !SKIP
    }
#endif

    func test_truncateFile() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let url: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: false)
        _ = FileManager.default.createFile(atPath: url.path, contents: Data())
        defer { _ = try? FileManager.default.removeItem(at: url) }

        let fh: FileHandle = FileHandle(forUpdatingAtPath: url.path)!

        fh.truncateFile(atOffset: 50)
        XCTAssertEqual(fh.offsetInFile, 50)

        fh.truncateFile(atOffset: 0)
        XCTAssertEqual(fh.offsetInFile, 0)

        fh.truncateFile(atOffset: 100)
        XCTAssertEqual(fh.offsetInFile, 100)

        fh.write(Data([1, 2]))
        XCTAssertEqual(fh.offsetInFile, 102)

        fh.seek(toFileOffset: 4)
        XCTAssertEqual(fh.offsetInFile, 4)

        (0..<20).forEach { fh.write(Data([$0])) }
        XCTAssertEqual(fh.offsetInFile, 24)

        fh.seekToEndOfFile()
        XCTAssertEqual(fh.offsetInFile, 102)

        fh.truncateFile(atOffset: 10)
        XCTAssertEqual(fh.offsetInFile, 10)

        fh.seek(toFileOffset: 0)
        XCTAssertEqual(fh.offsetInFile, 0)

        let data = fh.readDataToEndOfFile()
        XCTAssertEqual(data.count, 10)
        XCTAssertEqual(data, Data([0, 0, 0, 0, 0, 1, 2, 3, 4, 5]))
        #endif // !SKIP
    }

    func test_truncate() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // `func truncate(atOffset offset: UInt64) throws` is introduced in Swift 5.
        // See also https://bugs.swift.org/browse/SR-11922
        
        let fh = createFileHandleForUpdating()

        try fh.truncate(atOffset: 50)
        XCTAssertEqual(fh.offsetInFile, 50)

        try fh.truncate(atOffset: 0)
        XCTAssertEqual(fh.offsetInFile, 0)

        try fh.truncate(atOffset: 100)
        XCTAssertEqual(fh.offsetInFile, 100)

        fh.write(Data([1, 2]))
        XCTAssertEqual(fh.offsetInFile, 102)

        try fh.seek(toOffset: 4)
        XCTAssertEqual(fh.offsetInFile, 4)

        (0..<20).forEach { fh.write(Data([$0])) }
        XCTAssertEqual(fh.offsetInFile, 24)

        fh.seekToEndOfFile()
        XCTAssertEqual(fh.offsetInFile, 102)

        try fh.truncate(atOffset: 10)
        XCTAssertEqual(fh.offsetInFile, 10)

        try fh.seek(toOffset: 0)
        XCTAssertEqual(fh.offsetInFile, 0)

        let data = fh.readDataToEndOfFile()
        XCTAssertEqual(data.count, 10)
        XCTAssertEqual(data, Data([0, 0, 0, 0, 0, 1, 2, 3, 4, 5]))
        #endif // !SKIP
    }
    
    func test_readabilityHandlerCloseFileRace() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for _ in 0..<10 {
            let handle = createFileHandle()
            handle.readabilityHandler = { _ = $0.offsetInFile }
            handle.closeFile()
            Thread.sleep(forTimeInterval: 0.001)
        }
        #endif // !SKIP
    }
    
    func test_readabilityHandlerCloseFileRaceWithError() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for _ in 0..<10 {
            let handle = createFileHandle()
            handle.readabilityHandler = { _ = try? $0.offset() }
            try handle.close()
            Thread.sleep(forTimeInterval: 0.001)
        }
        #endif // !SKIP
    }

#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT
    func test_fileDescriptor() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandle()
        XCTAssertTrue(handle._isPlatformHandleValid, "File descriptor after opening should be valid")

        try handle.close()
        XCTAssertFalse(handle._isPlatformHandleValid, "File descriptor after closing should not be valid")
        #endif // !SKIP
    }
#endif

    func test_availableData() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandle()
        
        let availableData = handle.availableData
        XCTAssertEqual(availableData, content, "Available data should be the same as input")
        
        let eofData = handle.availableData
        XCTAssertTrue(eofData.isEmpty, "Should return empty data for EOF")
        #endif // !SKIP
    }
    
    func test_readToEndOfFileInBackgroundAndNotify() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandle()
        let done = expectation(forNotification: .NSFileHandleReadToEndOfFileCompletion, object: handle, notificationCenter: .default) { (notification) -> Bool in
            XCTAssertEqual(notification.userInfo as? [String: AnyHashable], [NSFileHandleNotificationDataItem: self.content], "User info was incorrect")
            return true
        }
        
        handle.readToEndOfFileInBackgroundAndNotify()
        
        wait(for: [done], timeout: 10)
        #endif // !SKIP
    }
    
    func test_readToEndOfFileAndNotify() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandle()
        var readSomeData = false
        
        let done = expectation(forNotification: FileHandle.readCompletionNotification, object: handle, notificationCenter: .default) { (notification) -> Bool in
            guard let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data else {
                XCTFail("Couldn't find the data in the user info: \(notification)")
                return true
            }
            
            if !data.isEmpty {
                readSomeData = true
                handle.readInBackgroundAndNotify()
                return false
            } else {
                return true
            }
        }
        
        handle.readInBackgroundAndNotify()
        
        wait(for: [done], timeout: 10)
        XCTAssertTrue(readSomeData, "At least some data must've been read")
        #endif // !SKIP
    }
    
    func test_readToEndOfFileAndNotify_readError() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandleForReadErrors()
        
        let done = expectation(forNotification: FileHandle.readCompletionNotification, object: handle, notificationCenter: .default) { (notification) -> Bool in
            guard let error = notification.userInfo?["NSFileHandleError"] as? NSNumber else {
                XCTFail("Couldn't find the data in the user info: \(notification)")
                return true
            }
            
            XCTAssertEqual(notification.userInfo?[NSFileHandleNotificationDataItem] as? Data, Data())
#if os(Windows)
            XCTAssertEqual(error, NSNumber(value: ERROR_DIRECTORY_NOT_SUPPORTED))
#else
            XCTAssertEqual(error, NSNumber(value: EISDIR))
#endif
            return true
        }
        
        handle.readInBackgroundAndNotify()
        
        wait(for: [done], timeout: 10)
        #endif // !SKIP
    }
    
    func test_waitForDataInBackgroundAndNotify() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let handle = createFileHandle()
        let done = expectation(forNotification: .NSFileHandleDataAvailable, object: handle, notificationCenter: .default) { (notification) in
            let count = notification.userInfo?.count ?? 0
            XCTAssertEqual(count, 0)
            return true
        }
        
        handle.waitForDataInBackgroundAndNotify()
        
        wait(for: [done], timeout: 10)
        #endif // !SKIP
    }
    
    func test_readWriteHandlers() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for _ in 0..<100 {
            let pipe = Pipe()
            let write = pipe.fileHandleForWriting
            let read = pipe.fileHandleForReading
            
            var notificationReceived = false
            let semaphore = DispatchSemaphore(value: 0)
            let count = content.count
            read.readabilityHandler = { (handle) in
                // Check that we can reentrantly set the handler:
                handle.readabilityHandler = { (handle2) in
                    if let readData = try? handle2.read(upToCount: count) {
                        XCTAssertEqual(readData.count, count, "Should have read as much data as was sent")
                        semaphore.signal()
                    } else {
                        // EOF:
                        handle2.readabilityHandler = nil
                    }
                }
                notificationReceived = true
                if let readData = try? handle.read(upToCount: count) {
                    XCTAssertEqual(readData.count, count, "Should have read as much data as was sent")
                }
            }
            
            write.writeabilityHandler = { (handle) in
                handle.writeabilityHandler = { (handle2) in
                    handle2.writeabilityHandler = nil
                    try? handle2.write(contentsOf: self.content)
                }
                try? handle.write(contentsOf: self.content)
            }
            
            let result = semaphore.wait(timeout: .now() + .seconds(30))
            XCTAssertEqual(result, .success, "Waiting on the semaphore should not have had time to time out")
            XCTAssertTrue(notificationReceived, "Notification should be sent")
        }
        #endif // !SKIP
    }

#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT && !os(Windows)
    func test_closeOnDealloc() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        try withTemporaryDirectory() { (url, path) in
            let data = try XCTUnwrap("hello".data(using: .utf8))

            // closeOnDealloc: true, 2nd write should throw.
            do {
                let fileUrl = url.appendingPathComponent("testfile")
                let fd = try FileHandle._openFileDescriptorForURL(fileUrl, flags: O_CREAT | O_RDWR, reading: false)
                do {
                    let fh = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
                    XCTAssertNoThrow(try fh.write(contentsOf: data))
                }
                let fh2 = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
                XCTAssertThrowsError(try fh2.write(contentsOf: data))
            }

            // closeOnDealloc: false, 2nd write should succeed.
            do {
                let fileUrl = url.appendingPathComponent("testfile2")
                let fd = try FileHandle._openFileDescriptorForURL(fileUrl, flags: O_CREAT | O_RDWR, reading: false)
                do {
                    let fh = FileHandle(fileDescriptor: fd, closeOnDealloc: false)
                    XCTAssertNoThrow(try fh.write(contentsOf: data))
                }
                // Close the file handle after this write, dont leave it open after this test.
                let fh2 = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
                XCTAssertNoThrow(try fh2.write(contentsOf: data))
            }
        }
        #endif // !SKIP
    }
#endif

    func testSynchronizeOnSpecialFile() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
//        // .synchronize() on a special file shouldnt fail
//#if os(Windows)
//        let fh = try XCTUnwrap(FileHandle(forWritingAtPath: "CON"))
//#else
//        // /opt/src/github/skiptools/skiphub/Tests/SkipFoundationTests/TestFileHandle.swift:623: error: -[SkipFoundationTests.TestFileHandle testSynchronizeOnSpecialFile] : XCTAssertNoThrow failed: threw error "Error Domain=NSCocoaErrorDomain Code=512 "The file couldn’t be saved." UserInfo={NSUnderlyingError=0x152e0bb10 {Error Domain=NSPOSIXErrorDomain Code=45 "Operation not supported"}}"
//
//        let fh = try XCTUnwrap(FileHandle(forWritingAtPath: "/dev/stdout"))
//#endif
//        XCTAssertNoThrow(try fh.synchronize())
        #endif // !SKIP
    }

}


