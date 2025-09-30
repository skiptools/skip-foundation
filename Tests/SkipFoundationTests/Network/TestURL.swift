// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

// TODO: remove '// API marked unavailable for Skip:' portions as we make more API available

#if SKIP

fileprivate func NSURL(string: String, relativeTo: URL? = nil) -> URL? {
    return URL(string: string, relativeTo: relativeTo)
}

fileprivate extension URL {
    var fileSystemRepresentation: String {
        return path
    }

    func copy() -> NSURL {
        URL(self)
    }

    func isEqual(_ other: NSURL) -> Bool {
        return self == other
    }
}

extension String {
    func appendingPathComponent(_ path: String) -> NSString {
        return self + "/" + path
    }
}

fileprivate var errno: Int32 = 0

fileprivate func strerror(_ errno: Int32) -> String? {
    ""
}

fileprivate func String(cString: String) -> String {
    return cString
}
#endif


// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:

// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

let kURLTestParsingTestsKey = "ParsingTests"

let kURLTestTitleKey = "In-Title"
let kURLTestUrlKey = "In-Url"
let kURLTestBaseKey = "In-Base"
let kURLTestURLCreatorKey = "In-URLCreator"
let kURLTestPathComponentKey = "In-PathComponent"
let kURLTestPathExtensionKey = "In-PathExtension"

let kURLTestCFResultsKey = "Out-CFResults"
let kURLTestNSResultsKey = "Out-NSResults"

let kNSURLWithStringCreator = "NSURLWithString"
let kCFURLCreateWithStringCreator = "CFURLCreateWithString"
let kCFURLCreateWithBytesCreator = "CFURLCreateWithBytes"
let kCFURLCreateAbsoluteURLWithBytesCreator = "CFURLCreateAbsoluteURLWithBytes"

let kNullURLString = "<null url>"
let kNullString = "<null>"

/// Reads the test data plist file and returns the list of objects
private func getTestData() -> [Any]? {
    #if SKIP
    // in order to implement this, XML plist parsing will need to be implemented
    throw XCTSkip("TODO")
    #else
    let testFilePath = testBundle().url(forResource: "NSURLTestData", withExtension: "plist")
    let data = try! Data(contentsOf: testFilePath!)
    guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
        XCTFail("Unable to deserialize property list data")
        return nil
    }
    guard let testRoot = plist as? [String : Any] else {
        XCTFail("Unable to deserialize property list data")
        return nil
    }
    guard let parsingTests = testRoot[kURLTestParsingTestsKey] as? [Any] else {
        XCTFail("Unable to create the parsingTests dictionary")
        return nil
    }
    return parsingTests
    #endif
}

class TestURL : XCTestCase {

    func test_fileURLWithPath_relativeTo() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let homeDirectory = NSHomeDirectory()
        let homeURL = URL(fileURLWithPath: homeDirectory, isDirectory: true)
        XCTAssertEqual(homeDirectory, homeURL.path)

        #if os(macOS)
        let baseURL = URL(fileURLWithPath: homeDirectory, isDirectory: true)
        let relativePath = "Documents"
        #elseif os(Android)
        let baseURL = URL(fileURLWithPath: "/data", isDirectory: true)
        let relativePath = "local"
        #elseif os(Linux) || os(OpenBSD)
        let baseURL = URL(fileURLWithPath: "/usr", isDirectory: true)
        let relativePath = "include"
        #endif
        #if !os(iOS)
        // we're telling fileURLWithPath:isDirectory:relativeTo: Documents is a directory
        let url1 = URL(fileURLWithFileSystemRepresentation: relativePath, isDirectory: true, relativeTo: baseURL)
        // we're letting fileURLWithPath:relativeTo: determine Documents is a directory with I/O
        let url2 = URL(fileURLWithPath: relativePath, relativeTo: baseURL)
        XCTAssertEqual(url1, url2, "\(url1) was not equal to \(url2)")
        // we're telling fileURLWithPath:relativeTo: Documents is a directory with a trailing slash
        let url3 = URL(fileURLWithPath: relativePath + "/", relativeTo: baseURL)
        XCTAssertEqual(url1, url3, "\(url1) was not equal to \(url3)")
        #endif
        #endif
    }

    func test_relativeFilePath() {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        let url1 = URL(fileURLWithPath: "/this/is/absolute", relativeTo: nil)
        XCTAssertNil(url1.baseURL, "Absolute URLs should have no base URL")
        // API marked unavailable for Skip: XCTAssertEqual(url1.path, url1.relativePath, "URLs without base path should have equal path and relativePath")

        let url2 = URL(fileURLWithPath: "this/is/relative", relativeTo: nil)
        XCTAssertNotNil(url2.baseURL, "Relative URLs should have base URL assigned")
        // API marked unavailable for Skip: XCTAssertNotEqual(url2.path, url2.relativePath, "URLs without base path should have different path and relativePath")
    }

    /// Returns a URL from the given url string and base
    private func URLWithString(_ urlString : String, baseString : String?) -> URL? {
        if let baseString = baseString {
            let baseURL = URL(string: baseString)
            return URL(string: urlString, relativeTo: baseURL)
        } else {
            return URL(string: urlString)
        }
    }

    fileprivate func generateResults(_ url: URL, pathComponent: String?, pathExtension : String?) -> [String : Any] {
        var result = Dictionary<String, Any>()
        if let pathComponent = pathComponent {
            let newFileURL = url.appendingPathComponent(pathComponent, isDirectory: false)
            result["appendingPathComponent-File"] = newFileURL.relativeString
            result["appendingPathComponent-File-BaseURL"] = newFileURL.baseURL?.relativeString ?? kNullString

            let newDirURL = url.appendingPathComponent(pathComponent, isDirectory: true)
            result["appendingPathComponent-Directory"] = newDirURL.relativeString
            result["appendingPathComponent-Directory-BaseURL"] = newDirURL.baseURL?.relativeString ?? kNullString
        } else if let pathExtension = pathExtension {
            let newURL = url.appendingPathExtension(pathExtension)
            result["appendingPathExtension"] = newURL.relativeString
            result["appendingPathExtension-BaseURL"] = newURL.baseURL?.relativeString ?? kNullString
        } else {
            result["relativeString"] = url.relativeString
            result["baseURLString"] = url.baseURL?.relativeString ?? kNullString
            result["absoluteString"] = url.absoluteString
            result["absoluteURLString"] = url.absoluteURL.relativeString
            result["scheme"] = url.scheme ?? kNullString
            result["host"] = url.host ?? kNullString

            result["port"] = url.port ?? kNullString
            // API marked unavailable for Skip: result["user"] = url.user ?? kNullString
            // API marked unavailable for Skip: result["password"] = url.password ?? kNullString
            result["path"] = url.path
            result["query"] = url.query ?? kNullString
            result["fragment"] = url.fragment ?? kNullString
            result["relativePath"] = url.relativePath
            result["isFileURL"] = url.isFileURL ? "YES" : "NO"
            result["standardizedURL"] = url.standardized.relativeString

            result["pathComponents"] = url.pathComponents
            result["lastPathComponent"] = url.lastPathComponent
            result["pathExtension"] = url.pathExtension
            result["deletingLastPathComponent"] = url.deletingLastPathComponent().relativeString
            result["deletingLastPathExtension"] = url.deletingPathExtension().relativeString
        }
        return result
    }

    #if !SKIP
    // TODO: plist parsing

    fileprivate func compareResults(_ url : URL, expected : [String : Any], got : [String : Any]) -> (Bool, [String]) {
        var differences = Array<String>()
        for (key, expectation) in expected {
            // Skip non-string expected results
            if ["port", "standardizedURL", "pathComponents"].contains(key) {
                continue
            }
            var obj: Any? = expectation
            if obj as? String == kNullString {
                obj = nil
            }
            if let expectedValue = obj as? String {
                if let testedValue = got[key] as? String {
                    if expectedValue != testedValue {
                        differences.append(" \(key)  Expected = '\(expectedValue)',  Got = '\(testedValue)'")
                    }
                } else {
                    differences.append(" \(key)  Expected = '\(expectedValue)',  Got = '\(String(describing: got[key]))'")
                }
            } else if let expectedValue = obj as? [String] {
                if let testedValue = got[key] as? [String] {
                    if expectedValue != testedValue {
                        differences.append(" \(key)  Expected = '\(expectedValue)',  Got = '\(testedValue)'")
                    }
                } else {
                    differences.append(" \(key)  Expected = '\(expectedValue)',  Got = '\(String(describing: got[key]))'")
                }
            } else if let expectedValue = obj as? Int {
                if let testedValue = got[key] as? Int {
                    if expectedValue != testedValue {
                        differences.append(" \(key)  Expected = '\(expectedValue)',  Got = '\(testedValue)'")
                    }
                } else {
                    differences.append(" \(key)  Expected = '\(expectedValue)',  Got = '\(String(describing: got[key]))'")
                }
            } else if obj == nil {
                if got[key] != nil && got[key] as? String != kNullString {
                    differences.append(" \(key)  Expected = '\(String(describing: obj))',  Got = '\(String(describing: got[key]))'")
                }
            }

        }
        for (key, obj) in got {
            if expected[key] == nil {
                differences.append(" \(key)  Expected = 'nil',  Got = '\(obj)'")
            }
        }
        if differences.count > 0 {
            differences.sort()
            differences.insert(" url:  '\(url)' ", at: 0)
            return (false, differences)
        } else {
            return (true, [])
        }
    }
    #endif

    func test_URLStrings() {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #else
        for obj in getTestData()! {
            let testDict = obj as! [String: Any]
            let title = testDict[kURLTestTitleKey] as! String
            let inURL = testDict[kURLTestUrlKey]! as! String
            let inBase = testDict[kURLTestBaseKey] as! String?
            let inPathComponent = testDict[kURLTestPathComponentKey] as! String?
            let inPathExtension = testDict[kURLTestPathExtensionKey] as! String?
            let expectedNSResult = testDict[kURLTestNSResultsKey]!
            var url : URL? = nil

            switch (testDict[kURLTestURLCreatorKey]! as! String) {
            case kNSURLWithStringCreator:
                url = URLWithString(inURL, baseString: inBase)
            case kCFURLCreateWithStringCreator, kCFURLCreateWithBytesCreator, kCFURLCreateAbsoluteURLWithBytesCreator:
                // TODO: Not supported right now
                continue
            default:
                XCTFail()
            }

            func passesRecentDarwinVersions() -> Bool {
                // special-cases URLs that are permitted on iOS and recent macOS versions that aren't allowed on other platforms
                if url?.absoluteString == "http://test.com/unescaped%20space" { return true }
                if url?.absoluteString == "http://test.com/unescaped%7Cpipe" { return true }
                if url?.absoluteString == "http://test.com/" { return true }
                if url?.absoluteString == "http://www.cnn.com/%20/interactive/world/0207/gallery.pope.tour/frameset.exclude.html" { return true }
                return false
            }

            #if os(iOS)
            if passesRecentDarwinVersions() {
                continue
            }
            #elseif os(macOS)
            if #available(macOS 14, *) {
                if passesRecentDarwinVersions() {
                    continue
                }
            }
            #endif

            // On other platforms, pipes are not valid
            //
            // Skip the test which expects pipes to be valid
            let skippedPipeTest = "NSURLWithString-parse-absolute-escape-006-pipe-valid"

            let skippedTests = [
                "NSURLWithString-parse-ambiguous-url-001", // TODO: Fix Test
                skippedPipeTest,
            ]
            if skippedTests.contains(title) { continue }

            if let url = url {
                let results = generateResults(url, pathComponent: inPathComponent, pathExtension: inPathExtension)
                if let expected = expectedNSResult as? [String: Any] {
                    let (isEqual, differences) = compareResults(url, expected: expected, got: results)
                    // API marked unavailable for Skip: XCTAssertTrue(isEqual, "\(title): \(differences.joined(separator: "\n"))")
                } else {
                    XCTFail("\(url) should not be a valid url")
                }
            } else {
                XCTAssertEqual(expectedNSResult as? String, kNullURLString)
            }
        }
        #endif
    }

    static let gBaseTemporaryDirectoryPath: String = (NSTemporaryDirectory() as NSString).appendingPathComponent("org.swift.foundation.TestFoundation.TestURL.\(ProcessInfo.processInfo.processIdentifier)")
    static var gBaseCurrentWorkingDirectoryPath : String {
        return FileManager.default.currentDirectoryPath
    }
    static var gSavedPath: String = ""
    static var gRelativeOffsetFromBaseCurrentWorkingDirectory: UInt = UInt(0)
    static let gFileExistsName: String = "TestCFURL_file_exists\(ProcessInfo.processInfo.globallyUniqueString)"
    static let gFileDoesNotExistName: String = "TestCFURL_file_does_not_exist"
    static let gDirectoryExistsName: String = "TestCFURL_directory_exists\(ProcessInfo.processInfo.globallyUniqueString)"
    static let gDirectoryDoesNotExistName: String = "TestCFURL_directory_does_not_exist"
    static let gFileExistsPath: String = gBaseTemporaryDirectoryPath + gFileExistsName
    static let gFileDoesNotExistPath: String = gBaseTemporaryDirectoryPath + gFileDoesNotExistName
    static let gDirectoryExistsPath: String = gBaseTemporaryDirectoryPath + gDirectoryExistsName
    static let gDirectoryDoesNotExistPath: String = gBaseTemporaryDirectoryPath + gDirectoryDoesNotExistName

    #if !SKIP
    override class func tearDown() {
        let path = TestURL.gBaseTemporaryDirectoryPath
        if (try? FileManager.default.attributesOfItem(atPath: path)) != nil {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                NSLog("Could not remove test directory at path \(path): \(error)")
            }
        }

        super.tearDown()
    }
    #endif

    static func setup_test_paths() -> Bool {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        let _ = FileManager.default.createFile(atPath: gFileExistsPath, contents: nil)

        do {
          try FileManager.default.removeItem(atPath: gFileDoesNotExistPath)
        } catch {
          #if !SKIP
          // The error code is a CocoaError
          if (error as? NSError)?.code != CocoaError.fileNoSuchFile.rawValue {
            return false
          }
          #endif
        }

        do {
          try FileManager.default.createDirectory(atPath: gDirectoryExistsPath, withIntermediateDirectories: false)
        } catch {
            #if !SKIP
            // The error code is a CocoaError
            if (error as? NSError)?.code != CocoaError.fileWriteFileExists.rawValue {
                return false
            }
            #endif
        }

        do {
          try FileManager.default.removeItem(atPath: gDirectoryDoesNotExistPath)
        } catch {
            #if !SKIP
            // The error code is a CocoaError
            if (error as? NSError)?.code != CocoaError.fileNoSuchFile.rawValue {
                return false
            }
            #endif
        }

        TestURL.gSavedPath = FileManager.default.currentDirectoryPath
        //FileManager.default.changeCurrentDirectoryPath(NSTemporaryDirectory())

        let cwd = FileManager.default.currentDirectoryPath
        let cwdURL = URL(fileURLWithPath: cwd, isDirectory: true)
        // 1 for path separator
        #if !SKIP
        cwdURL.withUnsafeFileSystemRepresentation {
            gRelativeOffsetFromBaseCurrentWorkingDirectory = UInt(strlen($0!) + 1)
        }
        #endif

        return true
    }

    func test_fileURLWithPath() {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        if !TestURL.setup_test_paths() {
            let error = strerror(errno)!
            XCTFail("Failed to set up test paths: \(String(cString: error))")
        }
        //defer { FileManager.default.changeCurrentDirectoryPath(TestURL.gSavedPath) }

        // test with file that exists
        var path = TestURL.gFileExistsPath
        var url = NSURL(fileURLWithPath: path)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with file that doesn't exist
        path = TestURL.gFileDoesNotExistPath
        url = NSURL(fileURLWithPath: path)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with directory that exists
        path = TestURL.gDirectoryExistsPath
        url = NSURL(fileURLWithPath: path)
        XCTAssertTrue(url.hasDirectoryPath, "expected URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with directory that doesn't exist
        path = TestURL.gDirectoryDoesNotExistPath
        url = NSURL(fileURLWithPath: path)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with name relative to current working directory
        path = TestURL.gFileDoesNotExistName
        url = NSURL(fileURLWithPath: path)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        let fileSystemRep = url.fileSystemRepresentation
        let actualLength = strlen(fileSystemRep)
        // 1 for path separator
        let expectedLength = UInt(strlen(TestURL.gFileDoesNotExistName)) + TestURL.gRelativeOffsetFromBaseCurrentWorkingDirectory
        XCTAssertEqual(UInt(actualLength), expectedLength, "fileSystemRepresentation was too short")

        #if SKIP
        throw XCTSkip("TODO: port test")
        #else
        XCTAssertTrue(strncmp(TestURL.gBaseCurrentWorkingDirectoryPath, fileSystemRep, Int(strlen(TestURL.gBaseCurrentWorkingDirectoryPath))) == 0, "fileSystemRepresentation of base path is wrong")
        let lengthOfRelativePath = Int(strlen(TestURL.gFileDoesNotExistName))
        let relativePath = fileSystemRep.advanced(by: Int(TestURL.gRelativeOffsetFromBaseCurrentWorkingDirectory))
        XCTAssertTrue(strncmp(TestURL.gFileDoesNotExistName, relativePath, lengthOfRelativePath) == 0, "fileSystemRepresentation of file path is wrong")

        // SR-12366
        let url1 = URL(fileURLWithPath: "/path/to/b/folder", isDirectory: true).standardizedFileURL.absoluteString
        let url2 = URL(fileURLWithPath: "/path/to/b/folder", isDirectory: true).absoluteString
        XCTAssertEqual(url1, url2)
        #endif
    }

    func test_fileURLWithPath_isDirectory() {
        if !TestURL.setup_test_paths() {
            let error = strerror(errno)!
            XCTFail("Failed to set up test paths: \(String(cString: error))")
        }
        //defer { FileManager.default.changeCurrentDirectoryPath(TestURL.gSavedPath) }

        // test with file that exists
        var path = TestURL.gFileExistsPath
        var url = NSURL(fileURLWithPath: path, isDirectory: true)
        XCTAssertTrue(url.hasDirectoryPath, "expected URL with directory path: \(url)")
        url = NSURL(fileURLWithPath: path, isDirectory: false)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with file that doesn't exist
        path = TestURL.gFileDoesNotExistPath
        url = NSURL(fileURLWithPath: path, isDirectory: true)
        XCTAssertTrue(url.hasDirectoryPath, "expected URL with directory path: \(url)")
        url = NSURL(fileURLWithPath: path, isDirectory: false)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with directory that exists
        path = TestURL.gDirectoryExistsPath
        url = NSURL(fileURLWithPath: path, isDirectory: false)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        url = NSURL(fileURLWithPath: path, isDirectory: true)
        XCTAssertTrue(url.hasDirectoryPath, "expected URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with directory that doesn't exist
        path = TestURL.gDirectoryDoesNotExistPath
        url = NSURL(fileURLWithPath: path, isDirectory: false)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        url = NSURL(fileURLWithPath: path, isDirectory: true)
        XCTAssertTrue(url.hasDirectoryPath, "expected URL with directory path: \(url)")
        XCTAssertEqual(path, url.path, "path from file path URL is wrong")

        // test with name relative to current working directory
        path = TestURL.gFileDoesNotExistName
        url = NSURL(fileURLWithPath: path, isDirectory: false)
        XCTAssertFalse(url.hasDirectoryPath, "did not expect URL with directory path: \(url)")
        url = NSURL(fileURLWithPath: path, isDirectory: true)
        XCTAssertTrue(url.hasDirectoryPath, "expected URL with directory path: \(url)")
        let fileSystemRep = url.fileSystemRepresentation
        let actualLength = UInt(strlen(fileSystemRep))
        // 1 for path separator
        let expectedLength = UInt(strlen(TestURL.gFileDoesNotExistName)) + TestURL.gRelativeOffsetFromBaseCurrentWorkingDirectory
        XCTAssertEqual(actualLength, expectedLength, "fileSystemRepresentation was too short")
        #if SKIP
        throw XCTSkip("TODO: port test")
        #else
        XCTAssertTrue(strncmp(TestURL.gBaseCurrentWorkingDirectoryPath, fileSystemRep, Int(strlen(TestURL.gBaseCurrentWorkingDirectoryPath))) == 0, "fileSystemRepresentation of base path is wrong")
        let lengthOfRelativePath = Int(strlen(TestURL.gFileDoesNotExistName))
        let relativePath = fileSystemRep.advanced(by: Int(TestURL.gRelativeOffsetFromBaseCurrentWorkingDirectory))
        XCTAssertTrue(strncmp(TestURL.gFileDoesNotExistName, relativePath, lengthOfRelativePath) == 0, "fileSystemRepresentation of file path is wrong")
        #endif
    }

    func test_URLByResolvingSymlinksInPathShouldRemoveDuplicatedPathSeparators() {
        let url = URL(fileURLWithPath: "//foo///bar////baz/")
        let result = url.resolvingSymlinksInPath()
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        //XCTAssertEqual(result, URL(fileURLWithPath: "/foo/bar/baz")) // changed in iOS26
    }

    func test_URLByResolvingSymlinksInPathShouldRemoveSingleDotsBetweenSeparators() {
        let url = URL(fileURLWithPath: "/./foo/./.bar/./baz/./")
        let result = url.resolvingSymlinksInPath()
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        //XCTAssertEqual(result, URL(fileURLWithPath: "/foo/.bar/baz")) // changed in iOS26
    }

    func test_URLByResolvingSymlinksInPathShouldCompressDoubleDotsBetweenSeparators() {
        let url = URL(fileURLWithPath: "/foo/../..bar/../baz/")
        let result = url.resolvingSymlinksInPath()
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        //XCTAssertEqual(result, URL(fileURLWithPath: "/baz")) // changed in iOS26
    }

    func test_URLByResolvingSymlinksInPathShouldUseTheCurrentDirectory() throws {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: writableTestDirectoryURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: writableTestDirectoryURL) }
        let previousCurrentDirectory = fileManager.currentDirectoryPath
        #if SKIP
        throw XCTSkip("TODO: port test")
        #elseif false // these tests are disabled because they rely on chaning the current working directory, which breaks when testing in parallel

        // unavailable in Skip
        fileManager.changeCurrentDirectoryPath(writableTestDirectoryURL.path)
        defer { fileManager.changeCurrentDirectoryPath(previousCurrentDirectory) }

        // In Darwin, because temporary directory is inside /private,
        // writableTestDirectoryURL will be something like /var/folders/...,
        // but /var points to /private/var, which is only removed if the
        // destination exists, so we create the destination to avoid having to
        // compare against /private in Darwin.
        try fileManager.createDirectory(at: writableTestDirectoryURL.appendingPathComponent("foo/bar"), withIntermediateDirectories: true)
        try "".write(to: writableTestDirectoryURL.appendingPathComponent("foo/bar/baz"), atomically: true, encoding: String.Encoding.utf8)

        let url = URL(fileURLWithPath: "foo/bar/baz")
        let result = url.resolvingSymlinksInPath()
        XCTAssertEqual(result, URL(fileURLWithPath: writableTestDirectoryURL.path + "/foo/bar/baz").resolvingSymlinksInPath())
        #endif
    }

    func test_resolvingSymlinksInPathShouldAppendTrailingSlashWhenExistingDirectory() throws {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: writableTestDirectoryURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: writableTestDirectoryURL) }

        var path = writableTestDirectoryURL.path
        #if SKIP
        throw XCTSkip("TODO: port test")
        #else
        if path.hasSuffix("/") {
            path.remove(at: path.index(path.endIndex, offsetBy: -1))
        }
        let url = URL(fileURLWithPath: path)
        let result = url.resolvingSymlinksInPath()
        XCTAssertEqual(result, URL(fileURLWithPath: path + "/").resolvingSymlinksInPath())
        #endif
    }

    func test_resolvingSymlinksInPathShouldResolveSymlinks() throws {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        // NOTE: this test only works on file systems that support symlinks.
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: writableTestDirectoryURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: writableTestDirectoryURL) }

        let symbolicLink = writableTestDirectoryURL.appendingPathComponent("origin")
        let destination = writableTestDirectoryURL.appendingPathComponent("destination")
        try "".write(to: destination, atomically: true, encoding: String.Encoding.utf8)
        try fileManager.createSymbolicLink(at: symbolicLink, withDestinationURL: destination)

        let result = symbolicLink.resolvingSymlinksInPath()
        XCTAssertEqual(result, URL(fileURLWithPath: writableTestDirectoryURL.path + "/destination").resolvingSymlinksInPath())
    }

    func test_resolvingSymlinksInPathShouldRemovePrivatePrefix() {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        // NOTE: this test only works on Darwin, since the code that removes
        // /private relies on /private/tmp existing.
        let url = URL(fileURLWithPath: "/private/tmp")
        let result = url.resolvingSymlinksInPath()
        //XCTAssertEqual(result, URL(fileURLWithPath: "/tmp")) // changed in iOS26
    }

    func test_resolvingSymlinksInPathShouldNotRemovePrivatePrefixIfOnlyComponent() {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        // NOTE: this test only works on Darwin, since only there /tmp is
        // symlinked to /private/tmp.
        let url = URL(fileURLWithPath: "/tmp/..")
        let result = url.resolvingSymlinksInPath()
        XCTAssertEqual(result, URL(fileURLWithPath: "/private"))
    }

    func test_resolvingSymlinksInPathShouldNotChangeNonFileURLs() throws {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        let url = try XCTUnwrap(URL(string: "myscheme://server/foo/bar/baz"))
        let result = url.resolvingSymlinksInPath().absoluteString
        XCTAssertEqual(result, "myscheme://server/foo/bar/baz")
    }

    func test_resolvingSymlinksInPathShouldNotChangePathlessURLs() throws {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        let url = try XCTUnwrap(URL(string: "file://"))
        let result = url.resolvingSymlinksInPath().absoluteString
        XCTAssertEqual(result, "file://")
    }

    func test_reachable() {
        #if os(Android)
        var url = URL(fileURLWithPath: "/data")
        #else
        var url = URL(fileURLWithPath: "/usr")
        #endif
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
        XCTAssertEqual(true, try? url.checkResourceIsReachable())

        url = URL(string: "https://www.swift.org")!
        do {
            let _ = try url.checkResourceIsReachable()
            XCTFail()
        } catch let error as NSError {
            #if !SKIP
            XCTAssertEqual(NSCocoaErrorDomain, error.domain)
            XCTAssertEqual(CocoaError.Code.fileReadUnsupportedScheme.rawValue, error.code)
            #endif
        } catch {
            XCTFail()
        }

        url = URL(fileURLWithPath: "/some_random_path")
        do {
            let _ = try url.checkResourceIsReachable()
            XCTFail()
        } catch let error as NSError {
            #if !SKIP
            XCTAssertEqual(NSCocoaErrorDomain, error.domain)
            XCTAssertEqual(CocoaError.Code.fileReadNoSuchFile.rawValue, error.code)
            #endif
        } catch {
            XCTFail()
        }

        #if os(Android)
        var nsURL = NSURL(fileURLWithPath: "/data")
        #elseif os(Windows)
        var nsURL = NSURL(fileURLWithPath: NSHomeDirectory())
        #else
        var nsURL = NSURL(fileURLWithPath: "/usr")
        #endif
        XCTAssertEqual(true, try? (nsURL as URL).checkResourceIsReachable())

        nsURL = NSURL(string: "https://www.swift.org")!
        do {
            let _ = try (nsURL as URL).checkResourceIsReachable()
            XCTFail()
        } catch let error as NSError {
            #if !SKIP
            XCTAssertEqual(NSCocoaErrorDomain, error.domain)
            XCTAssertEqual(CocoaError.Code.fileReadUnsupportedScheme.rawValue, error.code)
            #endif
        } catch {
            XCTFail()
        }

        nsURL = NSURL(fileURLWithPath: "/some_random_path")
        do {
            let _ = try (nsURL as URL).checkResourceIsReachable()
            XCTFail()
        } catch let error as NSError {
            #if !SKIP
            XCTAssertEqual(NSCocoaErrorDomain, error.domain)
            XCTAssertEqual(CocoaError.Code.fileReadNoSuchFile.rawValue, error.code)
            #endif
        } catch {
            XCTFail()
        }
    }

    func test_copy() {
        let url = NSURL(string: "https://www.swift.org")
        let urlCopy = url!.copy() as! NSURL
        XCTAssertTrue(url!.isEqual(urlCopy))

        #if SKIP
        throw XCTSkip("TODO: port test")
        #else
        let queryItem = NSURLQueryItem(name: "id", value: "23")
        let queryItemCopy = queryItem.copy() as! NSURLQueryItem
        XCTAssertTrue(queryItem.isEqual(queryItemCopy))
        #endif
    }

    func test_dataRepresentation() {
        let url = NSURL(fileURLWithPath: "/tmp/foo")
        #if SKIP
        throw XCTSkip("TODO: port test")
        #else
        let url2 = NSURL(dataRepresentation: url.dataRepresentation,
            relativeTo: nil)
        XCTAssertEqual(url, url2)
        #endif
    }

   func test_description() {
        let url = URL(string: "http://amazon.in")!
        XCTAssertEqual(url.description, "http://amazon.in")
        #if SKIP
        throw XCTSkip("TODO: port test")
        #else
        var urlComponents = URLComponents()
        urlComponents.port = 8080
        urlComponents.host = "amazon.in"
        urlComponents.password = "abcd"
        let relativeURL = urlComponents.url(relativeTo: url)
        XCTAssertEqual(relativeURL?.description, "//:abcd@amazon.in:8080 -- http://amazon.in")
       #endif
    }

    func test_appendingPathComponent() {
        let appendComponent = "foo"
        let urlsExpected = [
            ("www.swift.org", "www.swift.org/\(appendComponent)"),
            ("https://www.swift.org/", "https://www.swift.org/\(appendComponent)"),
            ("https://www.swift.org/a+b#hash", "https://www.swift.org/a+b/\(appendComponent)#hash"),
            ("https://www.swift.org/a%20b/#hash?q", "https://www.swift.org/a%20b/\(appendComponent)#hash?q"),
        ]
        for (urlString, expected) in urlsExpected {
            let url = URL(string: urlString)!
            XCTAssertEqual(url.appendingPathComponent(appendComponent).absoluteString, expected)
        }
        #if SKIP
        XCTAssertEqual(URL(string: "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/")!.appendingPathComponent("Localizable").absoluteString, "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/Localizable")
        #endif
    }

    func test_appendingPathExtension() {
        let ext = "foo"
        let dotExt = ".\(ext)"
        let urlsExpected = [
            ("www.swift.org", "www.swift.org\(dotExt)"),
            ("https://www.swift.org/", "https://www.swift.org/\(dotExt)"),
            ("https://www.swift.org/a+b#hash", "https://www.swift.org/a+b\(dotExt)#hash"),
            ("https://www.swift.org/a%20b/c/#hash?q", "https://www.swift.org/a%20b/c\(dotExt)/#hash?q"),
        ]
        for (urlString, expected) in urlsExpected {
            let url = URL(string: urlString)!
            XCTAssertEqual(url.appendingPathExtension(ext).absoluteString, expected)
        }
        #if SKIP
        XCTAssertEqual(URL(string: "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/Localizable")!.appendingPathExtension("strings").absoluteString, "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/Localizable.strings")
        #endif
    }

    func test_deletingLastPathComponent() {
        let urlsExpected = [ // TODO: support relative paths
            // ("www.swift.org", "./"),
            // ("https://www.swift.org/", "https://www.swift.org/../"),
            ("https://www.swift.org/a", "https://www.swift.org/"),
            ("https://www.swift.org/a/", "https://www.swift.org/"),
            ("https://www.swift.org/a/b#hash", "https://www.swift.org/a/#hash"),
            ("https://www.swift.org/a/b/#hash?q", "https://www.swift.org/a/#hash?q"),
        ]
        for (urlString, expected) in urlsExpected {
            let url = URL(string: urlString)!
            XCTAssertEqual(url.deletingLastPathComponent().absoluteString, expected)
        }
        #if SKIP
        XCTAssertEqual(URL(string: "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/Localizable.strings")!.deletingLastPathComponent().absoluteString, "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/")
        #endif
    }

    func test_deletingPathExtension() {
        let urlsExpected = [
            ("https://www.swift.org/", "https://www.swift.org/"),
            ("https://www.swift.org/.", "https://www.swift.org/."),
            ("https://www.swift.org/foo.", "https://www.swift.org/foo."),
            ("https://www.swift.org/a..b", "https://www.swift.org/a."),
            ("https://www.swift.org/.a.b", "https://www.swift.org/.a"),
            // ("https://www.swift.org/..b", "https://www.swift.org/..b"), // iOS<18,macOS<15 return "https://www.swift.org/."
            ("https://www.swift.org/.hidden", "https://www.swift.org/.hidden"),
            ("https://www.swift.org/a", "https://www.swift.org/a"),
            ("https://www.swift.org/a.ext/", "https://www.swift.org/a/"),
            //("https://www.swift.org/a.ext//", "https://www.swift.org/a.ext//"), // changed in iOS26
            ("https://www.swift.org/a.ext/b", "https://www.swift.org/a.ext/b"),
            ("https://www.swift.org/a/b.ext/#hash?q", "https://www.swift.org/a/b/#hash?q"),
            ("https://www.swift.org/a/b.ext#hash?q", "https://www.swift.org/a/b#hash?q"),
        ]
        for (urlString, expected) in urlsExpected {
            let url = URL(string: urlString)!
            XCTAssertEqual(url.deletingPathExtension().absoluteString, expected)
        }
        #if SKIP
        XCTAssertEqual(URL(string: "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/Localizable.strings")!.deletingPathExtension().absoluteString, "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/Localizable")
        #endif
    }

    func test_pathComponents() {
        let urlsExpected = [
            ("https://www.swift.org", []),
            ("https://www.swift.org/", ["/"]),
            ("https://www.swift.org//", ["/"]),
            //("https://www.swift.org///", ["/", "/"]), // changed in iOS26
            ("https://www.swift.org/bar.ext/#hash?q", ["/", "bar.ext"]),
            //("https://www.swift.org/a%2Fb/c%20d/", ["/", "a", "b", "c d"]), // changed in iOS26
            ("//foo///bar////baz/", ["/", "bar", "baz"]),
        ]
        for (urlString, expected) in urlsExpected {
            let url = URL(string: urlString)!
            XCTAssertEqual(url.pathComponents, expected)
        }
        #if SKIP
        XCTAssertEqual(URL(string: "jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/")!.pathComponents, Array<String>()) // Path components will always be empty because `platformValue.path` returns null for invalid urls like the "jar:file:" scheme
        #endif
    }

    // MARK: Resource values.

    func test_URLResourceValues() throws {
        #if SKIP
        throw XCTSkip("TODO: port test")
        #endif
//        do {
            try FileManager.default.createDirectory(at: writableTestDirectoryURL, withIntermediateDirectories: true)
            var a = writableTestDirectoryURL.appendingPathComponent("a")
            #if SKIP
            throw XCTSkip("TODO: port test")
            #else
            try Data().write(to: a)

            // Not all OSes support fractions of a second; remove the fractional part.
            let (roughlyAYearFromNowInterval, _) = modf(Date(timeIntervalSinceNow: 1 * 365 * 24 * 60 * 60).timeIntervalSinceReferenceDate)
            let roughlyAYearFromNow = Date(timeIntervalSinceReferenceDate: roughlyAYearFromNowInterval)

            var values = URLResourceValues()
            values.contentModificationDate = roughlyAYearFromNow

            try a.setResourceValues(values)

            let keys: Set<URLResourceKey> = [
                .contentModificationDateKey,
            ]

            func assertRelevantValuesAreEqual(in newValues: URLResourceValues) {
                XCTAssertEqual(values.contentModificationDate, newValues.contentModificationDate)
            }

            do {
                let newValues = try a.resourceValues(forKeys: keys)
                assertRelevantValuesAreEqual(in: newValues)
            }

            do {
                a.removeAllCachedResourceValues()
                let newValues = try a.resourceValues(forKeys: keys)
                assertRelevantValuesAreEqual(in: newValues)
            }

            do {
                let separateA = writableTestDirectoryURL.appendingPathComponent("a")
                let newValues = try separateA.resourceValues(forKeys: keys)
                assertRelevantValuesAreEqual(in: newValues)
            }
            #endif
//        } catch {
//            #if !SKIP
//            if let error = error as? NSError {
//                print("error: \(error.description) - \(error.userInfo)")
//            } else {
//                print("error: \(error)")
//            }
//            #endif
//            throw error
//        }
    }

    // MARK: -

    fileprivate var writableTestDirectoryURL: URL = URL(fileURLWithPath: NSTemporaryDirectory()) // need a default value for Kotlin, but this will be replaced in setUp()

    override func setUp() {
        super.setUp()

        let pid = ProcessInfo.processInfo.processIdentifier
        writableTestDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("org.swift.TestFoundation.TestURL.resourceValues.\(pid)")
    }

    override func tearDown() {
        if let directoryURL = (writableTestDirectoryURL as URL?),
            (try? FileManager.default.attributesOfItem(atPath: directoryURL.path)) != nil {
            do {
                try FileManager.default.removeItem(at: directoryURL)
            } catch {
                NSLog("Could not remove test directory at URL \(directoryURL): \(error)")
            }
        }

        super.tearDown()
    }

}

