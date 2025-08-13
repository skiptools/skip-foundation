// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

#if !SKIP // disabled for to reduce test count and avoid io.grpc.StatusRuntimeException: RESOURCE_EXHAUSTED: gRPC message exceeds maximum size

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestHTTPCookie: XCTestCase {


    func test_BasicConstruction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let invalidVersionZeroCookie = HTTPCookie(properties: [
            .name: "TestCookie",
            .value: "Test value @#$%^$&*",
            .path: "/"
        ])
        XCTAssertNil(invalidVersionZeroCookie)

        let minimalVersionZeroCookie = HTTPCookie(properties: [
            .name: "TestCookie",
            .value: "Test value @#$%^$&*",
            .path: "/",
            .domain: "apple.com"
        ])
        XCTAssertNotNil(minimalVersionZeroCookie)
        XCTAssert(minimalVersionZeroCookie?.name == "TestCookie")
        XCTAssert(minimalVersionZeroCookie?.value == "Test value @#$%^$&*")
        XCTAssert(minimalVersionZeroCookie?.path == "/")
        XCTAssert(minimalVersionZeroCookie?.domain == "apple.com")

        let versionZeroCookieWithOriginURL = HTTPCookie(properties: [
            .name: "TestCookie",
            .value: "Test value @#$%^$&*",
            .path: "/",
            .originURL: URL(string: "https://apple.com")!
        ])
        XCTAssert(versionZeroCookieWithOriginURL?.domain == "apple.com")

        // Domain takes precedence over originURL inference
        let versionZeroCookieWithDomainAndOriginURL = HTTPCookie(properties: [
            .name: "TestCookie",
            .value: "Test value @#$%^$&*",
            .path: "/",
            .domain: "apple.com",
            .originURL: URL(string: "https://apple.com")!
        ])
        XCTAssert(versionZeroCookieWithDomainAndOriginURL?.domain == "apple.com")

        // This is implicitly a v0 cookie. Properties that aren't valid for v0 should fail.
        let versionZeroCookieWithInvalidVersionOneProps = HTTPCookie(properties: [
            .name: "TestCookie",
            .value: "Test value @#$%^$&*",
            .path: "/",
            .domain: "apple.com",
            .originURL: URL(string: "https://apple.com")!,
            .comment: "This comment should be nil since this is a v0 cookie.",
            .commentURL: "https://apple.com",
            .discard: "TRUE",
            .expires: Date(timeIntervalSince1970: 1000),
            .maximumAge: "2000",
            .port: "443,8443",
            .secure: "YES"
        ])
        XCTAssertEqual(versionZeroCookieWithInvalidVersionOneProps?.version, 0)
        XCTAssertNotNil(versionZeroCookieWithInvalidVersionOneProps?.comment)
        XCTAssertNotNil(versionZeroCookieWithInvalidVersionOneProps?.commentURL)
        XCTAssert(versionZeroCookieWithInvalidVersionOneProps?.isSessionOnly == true)

        // v0 should never use NSHTTPCookieMaximumAge
        XCTAssertNil(versionZeroCookieWithInvalidVersionOneProps?.expiresDate?.timeIntervalSince1970)

        XCTAssertEqual(versionZeroCookieWithInvalidVersionOneProps?.portList, [NSNumber(value: 443)])
        XCTAssert(versionZeroCookieWithInvalidVersionOneProps?.isSecure == true)
        XCTAssert(versionZeroCookieWithInvalidVersionOneProps?.version == 0)
        #endif // !SKIP
    }

    func test_RequestHeaderFields() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let noCookies: [HTTPCookie] = []
        XCTAssertNil(HTTPCookie.requestHeaderFields(with: noCookies)["Cookie"])

        let basicCookies: [HTTPCookie] = [
            HTTPCookie(properties: [
                .name: "TestCookie1",
                .value: "testValue1",
                .path: "/",
                .originURL: URL(string: "https://apple.com")!
                ])!,
            HTTPCookie(properties: [
                .name: "TestCookie2",
                .value: "testValue2",
                .path: "/",
                .originURL: URL(string: "https://apple.com")!
                ])!,
        ]

        let basicCookieString = HTTPCookie.requestHeaderFields(with: basicCookies)["Cookie"]
        XCTAssertEqual(basicCookieString, "TestCookie1=testValue1; TestCookie2=testValue2")
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeader1cookie() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["header1":"value1",
                      "Set-Cookie": "fr=anjd&232; Max-Age=7776000; path=/; domain=.example.com; secure; httponly",
                      "header2":"value2",
                      "header3":"value3"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: URL(string: "https://example.com")!)
        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].name, "fr")
        XCTAssertEqual(cookies[0].value, "anjd&232")
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeader0cookies() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["header1":"value1", "header2":"value2", "header3":"value3"]
        let cookies =  HTTPCookie.cookies(withResponseHeaderFields: header, for: URL(string: "http://example.com")!)
        XCTAssertEqual(cookies.count, 0)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeader2cookies() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["header1":"value1",
                      "Set-Cookie": "fr=a&2@#; Max-Age=1186000; path=/; domain=.example.com; secure, xd=plm!@#;path=/;domain=.example2.com", 
                      "header2":"value2",
                      "header3":"value3"]
        let cookies =  HTTPCookie.cookies(withResponseHeaderFields: header, for: URL(string: "https://example.com")!)
        XCTAssertEqual(cookies.count, 2)
        XCTAssertTrue(cookies[0].isSecure)
        XCTAssertFalse(cookies[1].isSecure)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderNoDomain() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header =  ["header1":"value1",
                       "Set-Cookie": "fr=anjd&232; expires=Wed, 21 Sep 2016 05:33:00 GMT; path=/; secure; httponly",
                       "header2":"value2",
                       "header3":"value3"]
        let cookies =  HTTPCookie.cookies(withResponseHeaderFields: header, for: URL(string: "https://example.com")!)
        XCTAssertEqual(cookies[0].version, 0)
        XCTAssertEqual(cookies[0].domain, "example.com")
        XCTAssertNotNil(cookies[0].expiresDate)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss O"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        if let expiresDate = formatter.date(from: "Wed, 21 Sep 2016 05:33:00 GMT") {
            XCTAssertTrue(expiresDate.compare(cookies[0].expiresDate!) == .orderedSame)
        } else {
            XCTFail("Unable to parse the given date from the formatter")
        }
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderNoPathNoDomain() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["header1":"value1",
                      "Set-Cookie": "fr=tx; expires=Wed, 21-Sep-2016 05:33:00 GMT; Max-Age=7776000; secure; httponly", 
                      "header2":"value2",
                      "header3":"value3"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: URL(string: "https://example.com")!)
        XCTAssertEqual(cookies[0].domain, "example.com")
        XCTAssertEqual(cookies[0].path, "/")
        #endif // !SKIP
    }
    
    func test_cookiesWithResponseHeaderNoNameValue() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": ";attr1=value1"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 0)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderNoName() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "=value1;attr2=value2"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 0)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderEmptyName() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "   =value1;attr2=value2"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 0)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderNoValue() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "name;attr2=value2"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 0)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderAttributeWithoutNameIsIgnored() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "name=value;Comment=value1;   =value2;CommentURL=value3"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].name, "name")
        XCTAssertEqual(cookies[0].value, "value")
        XCTAssertEqual(cookies[0].comment, "value1")
//        XCTAssertEqual(cookies[0].commentURL, try XCTUnwrap(URL(string: "value3")))
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderValuelessAttributes() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "name=value;Secure;Comment;Discard;CommentURL;HttpOnly"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].name, "name")
        XCTAssertEqual(cookies[0].value, "value")
        XCTAssertTrue(cookies[0].isSecure)
        XCTAssertTrue(cookies[0].isSessionOnly)
//        XCTAssertNil(cookies[0].comment)
//        XCTAssertNil(cookies[0].commentURL)
        XCTAssertTrue(cookies[0].isHTTPOnly)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderValuedAttributes() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // The attributes that do not need value will be ignored if they have
        // a value.
        let header = ["Set-Cookie": "name=value;Secure=1;Discard=TRUE;HttpOnly=Yes"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].name, "name")
        XCTAssertEqual(cookies[0].value, "value")
//        XCTAssertFalse(cookies[0].isSecure)
//        XCTAssertFalse(cookies[0].isSessionOnly)
//        XCTAssertFalse(cookies[0].isHTTPOnly)
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderInvalidPath() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "name=value;Path=This/is/not/a/valid/path"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 1)
//        XCTAssertEqual(cookies[0].path, "/")
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderWithEqualsInValue() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "name=v=a=l=u=e;attr1=value1;attr2=value2"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].name, "name")
        XCTAssertEqual(cookies[0].value, "v=a=l=u=e")
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderSecondCookieInvalidToken() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let header = ["Set-Cookie": "n=v; Comment=real value, tok@en=second; CommentURL=https://example.com/second"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: try XCTUnwrap(URL(string: "https://example.com")))
//        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].name, "n")
        XCTAssertEqual(cookies[0].value, "v")
//        XCTAssertEqual(cookies[0].comment, "real value, tok@en=second")
//        XCTAssertEqual(cookies[0].commentURL, try XCTUnwrap(URL(string: "https://example.com/second")))
        #endif // !SKIP
    }

    func test_cookiesWithExpiresAsLastAttribute() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: [
            "Set-Cookie": "AAA=111; path=/; domain=.example.com; expires=Sun, 16-Aug-2025 22:39:54 GMT, BBB=222; path=/; domain=.example.com; HttpOnly; expires=Sat, 15-Feb-2014 22:39:54 GMT"
        ], for: try XCTUnwrap(URL(string: "http://www.example.com/")))
        XCTAssertEqual(cookies.count, 2)
        XCTAssertEqual(cookies[0].name, "AAA")
        XCTAssertEqual(cookies[0].value, "111")
        XCTAssertEqual(cookies[1].name, "BBB")
        XCTAssertEqual(cookies[1].value, "222")
        #endif // !SKIP
    }

    func test_cookiesWithResponseHeaderTrimsNames() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        do {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: [
                "Set-Cookie": "AAA =1; path=/; domain=.example.com; expires=Sun, 16-Aug-2025 22:39:54 GMT, BBB=2; path=/; domain=.example.com; HttpOnly; expires=Sat, 15-Feb-2014 22:39:54 GMT"
            ], for: try XCTUnwrap(URL(string: "http://www.example.com/")))
            XCTAssertEqual(cookies.count, 2)
            XCTAssertEqual(cookies[0].name, "AAA")
            XCTAssertEqual(cookies[0].value, "1")
            XCTAssertEqual(cookies[1].name, "BBB")
            XCTAssertEqual(cookies[1].value, "2")
        }

        do {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: [
                "Set-Cookie": " AAA=1; path=/; domain=.example.com; expires=Sun, 16-Aug-2025 22:39:54 GMT, BBB=2; path=/; domain=.example.com; HttpOnly; expires=Sat, 15-Feb-2014 22:39:54 GMT"
            ], for: try XCTUnwrap(URL(string: "http://www.example.com/")))
            XCTAssertEqual(cookies.count, 2)
            XCTAssertEqual(cookies[0].name, "AAA")
            XCTAssertEqual(cookies[0].value, "1")
            XCTAssertEqual(cookies[1].name, "BBB")
            XCTAssertEqual(cookies[1].value, "2")
        }
        #endif // !SKIP
    }

    func test_cookieDomainCanonicalization() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        do {
            let headers = [
                "Set-Cookie": "PREF=a=b; expires=\(formattedCookieTime(sinceNow: 100))); path=/; domain=eXample.com"
            ]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: try XCTUnwrap(URL(string: "http://eXample.com")))
            XCTAssertEqual(cookies.count, 1)
            XCTAssertEqual(cookies.first?.domain, ".example.com")
        }

        do {
            let headers = [
                "Set-Cookie": "PREF=a=b; expires=\(formattedCookieTime(sinceNow: 100))); path=/; domain=.eXample.com"
            ]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: try XCTUnwrap(URL(string: "http://eXample.com")))
            XCTAssertEqual(cookies.count, 1)
            XCTAssertEqual(cookies.first?.domain, ".example.com")
        }

        do {
            let headers = [
                "Set-Cookie": "PREF=a=b; expires=\(formattedCookieTime(sinceNow: 100))); path=/; domain=a.eXample.com"
            ]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: try XCTUnwrap(URL(string: "http://a.eXample.com")))
            XCTAssertEqual(cookies.count, 1)
            XCTAssertEqual(cookies.first?.domain, ".a.example.com")
        }

        do {
            let headers = [
                "Set-Cookie": "PREF=a=b; expires=\(formattedCookieTime(sinceNow: 100))); path=/"
            ]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: try XCTUnwrap(URL(string: "http://a.eXample.com")))
            XCTAssertEqual(cookies.count, 1)
            XCTAssertEqual(cookies.first?.domain, "a.example.com")
        }

        do {
            let headers = [
                "Set-Cookie": "PREF=a=b; expires=\(formattedCookieTime(sinceNow: 100))); path=/; domain=1.2.3.4"
            ]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: try XCTUnwrap(URL(string: "http://eXample.com")))
            XCTAssertEqual(cookies.count, 1)
            XCTAssertEqual(cookies.first?.domain, "1.2.3.4")
        }
        #endif // !SKIP
    }

    func test_cookieExpiresDateFormats() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let testDate = Date(timeIntervalSince1970: 1577881800)
        let cookieString =
            """
            format1=true; expires=Wed, 01 Jan 2020 12:30:00 GMT; path=/; domain=swift.org; secure; httponly,
            format2=true; expires=Wed Jan 1 12:30:00 2020; path=/; domain=swift.org; secure; httponly,
            format3=true; expires=Wed, 01-Jan-2020 12:30:00 GMT; path=/; domain=swift.org; secure; httponly
            """

        let header = ["header1":"value1",
                      "Set-Cookie": cookieString,
                      "header2":"value2",
                      "header3":"value3"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: URL(string: "https://swift.org")!)
//        XCTAssertEqual(cookies.count, 3)
        cookies.forEach { cookie in
            XCTAssertEqual(cookie.expiresDate, testDate)
            XCTAssertEqual(cookie.domain, ".swift.org")
            XCTAssertEqual(cookie.path, "/")
        }
        #endif // !SKIP
    }

    func test_httpCookieWithSubstring() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let cookie = HTTPCookie(properties: [.domain: ".", .path: "/", .name: "davesy".dropLast(), .value: "Jonesy".dropLast()])
        if let cookie = cookie {
            XCTAssertEqual(cookie.name, "daves")
        } else {
            XCTFail("Unable to create cookie with substring")
        }
        #endif // !SKIP
    }

    private func formattedCookieTime(sinceNow seconds: TimeInterval) -> String {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "GMT")
        f.dateFormat = "EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z"
        return f.string(from: Date(timeIntervalSinceNow: seconds))
        #endif // !SKIP
    }
}


#endif

