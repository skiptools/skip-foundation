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
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if SKIP
struct SwiftCustomNSError: CustomNSError {
}
#else
struct SwiftCustomNSError: Error, CustomNSError {
}
#endif

class TestNSError : XCTestCase {
    
    
    func test_LocalizedError_errorDescription() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        struct Error : LocalizedError {
            var errorDescription: String? { return "error description" }
        }

        let error = Error()
        XCTAssertEqual(error.localizedDescription, "error description")
        #endif // !SKIP
    }

    func test_NSErrorAsError_localizedDescription() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let nsError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Localized!"])
        let error = nsError as Error
        XCTAssertEqual(error.localizedDescription, "Localized!")
        #endif // !SKIP
    }
    
    func test_NSError_inDictionary() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let error = NSError(domain: "domain", code: 42, userInfo: nil)
        let nsdictionary = ["error": error] as NSDictionary
        let dictionary = nsdictionary as? Dictionary<String, Error>
        XCTAssertNotNil(dictionary)
        XCTAssertEqual(error, dictionary?["error"] as? NSError)
        #endif // !SKIP
    }

    func test_CustomNSError_domain() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let name = testBundleName()
//        XCTAssertEqual(SwiftCustomNSError.errorDomain, "\(name).SwiftCustomNSError")
        #endif // !SKIP
    }

    func test_CustomNSError_userInfo() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let userInfo = SwiftCustomNSError().errorUserInfo
        XCTAssertTrue(userInfo.isEmpty)
        #endif // !SKIP
    }

    func test_CustomNSError_errorCode() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        enum SwiftError : Error, CustomNSError {
            case zero
            case one
            case two
        }

        XCTAssertEqual(SwiftCustomNSError().errorCode, 1)

        XCTAssertEqual(SwiftError.zero.errorCode, 0)
        XCTAssertEqual(SwiftError.one.errorCode,  1)
        XCTAssertEqual(SwiftError.two.errorCode,  2)
        #endif // !SKIP
    }

    func test_CustomNSError_errorCodeRawInt() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        enum SwiftError : Int, Error, CustomNSError {
            case minusOne  = -1
            case fortyTwo = 42
        }

        XCTAssertEqual(SwiftError.minusOne.errorCode,  -1)
        XCTAssertEqual(SwiftError.fortyTwo.errorCode, 42)
        #endif // !SKIP
    }

    func test_CustomNSError_errorCodeRawUInt() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        enum SwiftError : UInt, Error, CustomNSError {
            case fortyTwo = 42
        }

        XCTAssertEqual(SwiftError.fortyTwo.errorCode, 42)
        #endif // !SKIP
    }

    func test_errorConvenience() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let error = CocoaError.error(.fileReadNoSuchFile, url: URL(fileURLWithPath: #file))

        if let nsError = error as? NSError {
            XCTAssertEqual(nsError._domain, NSCocoaErrorDomain)
            XCTAssertEqual(nsError._code, CocoaError.fileReadNoSuchFile.rawValue)
            if let filePath = nsError.userInfo[NSURLErrorKey] as? URL {
                XCTAssertEqual(filePath, URL(fileURLWithPath: #file))
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
        #endif // !SKIP
    }
    
    #if !canImport(ObjectiveC) || DARWIN_COMPATIBILITY_TESTS
    
    func test_ConvertErrorToNSError_domain() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        struct CustomSwiftError: Error {
        }
        XCTAssertTrue((CustomSwiftError() as NSError).domain.contains("CustomSwiftError"))
        #endif // !SKIP
    }
    
    func test_ConvertErrorToNSError_errorCode() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        enum SwiftError: Error {
            case zero
            case one
            case two
        }
        
        XCTAssertEqual((SwiftError.zero as NSError).code, 0)
        XCTAssertEqual((SwiftError.one as NSError).code, 1)
        XCTAssertEqual((SwiftError.two as NSError).code, 2)
        #endif // !SKIP
    }
    
    func test_ConvertErrorToNSError_errorCodeRawInt() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        enum SwiftError: Int, Error {
            case minusOne = -1
            case fortyTwo = 42
        }
        
        XCTAssertEqual((SwiftError.minusOne as NSError).code, -1)
        XCTAssertEqual((SwiftError.fortyTwo as NSError).code, 42)
        #endif // !SKIP
    }
    
    func test_ConvertErrorToNSError_errorCodeRawUInt() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        enum SwiftError: UInt, Error {
            case fortyTwo = 42
        }
        
        XCTAssertEqual((SwiftError.fortyTwo as NSError).code, 42)
        #endif // !SKIP
    }
    
    func test_ConvertErrorToNSError_errorCodeWithAssosiatedValue() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Default error code for enum case is based on EnumImplStrategy::getTagIndex
        enum SwiftError: Error {
            case one // 2
            case two // 3
            case three(String) // 0
            case four // 4
            case five(String) // 1
        }
        
        XCTAssertEqual((SwiftError.one as NSError).code, 2)
        XCTAssertEqual((SwiftError.two as NSError).code, 3)
        XCTAssertEqual((SwiftError.three("three") as NSError).code, 0)
        XCTAssertEqual((SwiftError.four as NSError).code, 4)
        XCTAssertEqual((SwiftError.five("five") as NSError).code, 1)
        #endif // !SKIP
    }
    
    #endif

}

class TestURLError: XCTestCase {

    static let testURL = URL(string: "https://swift.org")!
    #if !SKIP
    let userInfo: [String: Any] =  [
        NSURLErrorFailingURLErrorKey: TestURLError.testURL,
        NSURLErrorFailingURLStringErrorKey: TestURLError.testURL.absoluteString,
    ]
    #endif

    func test_errorCode() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = URLError(.unsupportedURL)
        XCTAssertEqual(e.errorCode, URLError.Code.unsupportedURL.rawValue)
        #endif // !SKIP
    }

    func test_failingURL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = URLError(.badURL, userInfo: userInfo)
        XCTAssertNotNil(e.failingURL)
        XCTAssertEqual(e.failingURL, e.userInfo[NSURLErrorFailingURLErrorKey] as? URL)
        #endif // !SKIP
    }

    func test_failingURLString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = URLError(.badURL, userInfo: userInfo)
        XCTAssertNotNil(e.failureURLString)
        XCTAssertEqual(e.failureURLString, e.userInfo[NSURLErrorFailingURLStringErrorKey] as? String)
        #endif // !SKIP
    }
}

class TestCocoaError: XCTestCase {

    static let testURL = URL(string: "file:///")!
    #if !SKIP
    let userInfo: [String: Any] =  [
        NSURLErrorKey: TestCocoaError.testURL,
        NSFilePathErrorKey: TestCocoaError.testURL.path,
        NSUnderlyingErrorKey: POSIXError(.EACCES),
        NSStringEncodingErrorKey: String.Encoding.utf16.rawValue,
    ]
    #endif

    func test_errorCode() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = CocoaError(.fileReadNoSuchFile)
        XCTAssertEqual(e.errorCode, CocoaError.Code.fileReadNoSuchFile.rawValue)
        XCTAssertEqual(e.isCoderError, false)
        XCTAssertEqual(e.isExecutableError, false)
        XCTAssertEqual(e.isFileError, true)
        XCTAssertEqual(e.isFormattingError, false)
        XCTAssertEqual(e.isPropertyListError, false)
        XCTAssertEqual(e.isUbiquitousFileError, false)
        XCTAssertEqual(e.isUserActivityError, false)
        XCTAssertEqual(e.isValidationError, false)
        XCTAssertEqual(e.isXPCConnectionError, false)
        #endif // !SKIP
    }

    func test_filePath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = CocoaError(.fileWriteNoPermission, userInfo: userInfo)
        XCTAssertNotNil(e.filePath)
        XCTAssertEqual(e.filePath, TestCocoaError.testURL.path)
        #endif // !SKIP
    }

    func test_url() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = CocoaError(.fileReadNoSuchFile, userInfo: userInfo)
        XCTAssertNotNil(e.url)
        XCTAssertEqual(e.url, TestCocoaError.testURL)
        #endif // !SKIP
    }

    func test_stringEncoding() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = CocoaError(.fileReadUnknownStringEncoding, userInfo: userInfo)
        XCTAssertNotNil(e.stringEncoding)
        XCTAssertEqual(e.stringEncoding, .utf16)
        #endif // !SKIP
    }

    func test_underlying() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let e = CocoaError(.fileWriteNoPermission, userInfo: userInfo)
        XCTAssertNotNil(e.underlying as? POSIXError)
        XCTAssertEqual(e.underlying as? POSIXError, POSIXError.init(.EACCES))
        #endif // !SKIP
    }
}


