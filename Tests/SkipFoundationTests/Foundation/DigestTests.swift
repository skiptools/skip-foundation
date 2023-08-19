// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP
@testable import SkipFoundation
#endif
import Foundation
import XCTest

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
final class DigestTests: XCTestCase {
    func testSHA256() {
        //XCTAssertEqual("Hello World".utf8.sha256().hex(), "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e")
        XCTAssertEqual(Data("Hello World".utf8).sha256().hex(), "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e")
    }

    func testDigestHashSHA256() {
        let inputData = Data("Hello World".utf8)
        let hashedData: SHA256Digest = SHA256.hash(data: inputData)
        XCTAssertEqual("SHA256 digest: a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e", hashedData.description)
        XCTAssertEqual("SHA256 digest: db67b0f5582ae32b540e43ab326f582a1f43803e9dfb856206e87b66e3137660", SHA256.hash(data: Data("ZZ Top".utf8)).description)
    }

    func testDigestHashSHA384() {
        let inputData = Data("Hello World".utf8)
        let hashedData = SHA384.hash(data: inputData)
        XCTAssertEqual("SHA384 digest: 99514329186b2f6ae4a1329e7ee6c610a729636335174ac6b740f9028396fcc803d0e93863a7c3d90f86beee782f4f3f", hashedData.description)
        XCTAssertEqual("SHA384 digest: acfccf00f321f7ae0fcd2352ec0053f06519dcc2084a2b08fb340cce844c0654abf416c23a0ea94483ab2cee21359184", SHA384.hash(data: Data("ZZ Top".utf8)).description)
    }

    func testDigestHashSHA512() {
        let inputData = Data("Hello World".utf8)
        let hashedData = SHA512.hash(data: inputData)
        XCTAssertEqual("SHA512 digest: 2c74fd17edafd80e8447b0d46741ee243b7eb74dd2149a0ab1b9246fb30382f27e853d8585719e0e67cbda0daa8f51671064615d645ae27acb15bfb1447f459b", hashedData.description)
        XCTAssertEqual("SHA512 digest: 5a293a75e255fbdc85d826483fb1dc05519a750b98e76dfe2922a513df5a4aec2c9daa07cd3abcb0156bdeba3e41897bd0b8f06a3e1df4dd0ec1d0ffefc8abe1", SHA512.hash(data: Data("ZZ Top".utf8)).description)
    }

    func testDigestHashMD5() {
        let inputData = Data("Hello World".utf8)
        let hashedData: Insecure.MD5Digest = Insecure.MD5.hash(data: inputData)
        XCTAssertEqual("MD5 digest: b10a8db164e0754105b7a99be72e3fe5", hashedData.description)
        XCTAssertEqual("MD5 digest: 5f17026cffec9e27c6657f2f2a54e655", Insecure.MD5.hash(data: Data("ZZ Top".utf8)).description)
    }

    func testDigestHashSHA1() {
        let inputData = Data("Hello World".utf8)
        let hashedData: Insecure.SHA1Digest = Insecure.SHA1.hash(data: inputData)
        XCTAssertEqual("SHA1 digest: 0a4d55a8d778e5022fab701977c5d840bbc486d0", hashedData.description)
        XCTAssertEqual("SHA1 digest: 962f927d8fb5f84a01d2c7c7a2bdefff151dff09", Insecure.SHA1.hash(data: Data("ZZ Top".utf8)).description)
    }

    #if !SKIP
    // this currently isn't possible in Skip since Kotlin can't access the generic type from a static context (to get the algorithm name)
    func testHMACSignSHA256() {
        let message = "Your message to sign"
        let secret = "your-secret-key"
        let signature = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: SymmetricKey(data: Data(secret.utf8)))
        XCTAssertEqual("mUohryR4fJJFBXxnYup30d7IcYsG+o9Oyke/Nz87bfs=", Data(signature).base64EncodedString())
    }
    #endif

    func testHMACSigning() {
        XCTAssertEqual("U1V0aL+omPKt3L1+Fso3cA==", Data(HMACMD5.authenticationCode(for: Data("Your message to sign".utf8), using: SymmetricKey(data: Data("your-secret-key".utf8)))).base64EncodedString())
        XCTAssertEqual("6FxBqkItAuJRW8qmco9PnY0gWqY=", Data(HMACSHA1.authenticationCode(for: Data("Your message to sign".utf8), using: SymmetricKey(data: Data("your-secret-key".utf8)))).base64EncodedString())
        XCTAssertEqual("mUohryR4fJJFBXxnYup30d7IcYsG+o9Oyke/Nz87bfs=", Data(HMACSHA256.authenticationCode(for: Data("Your message to sign".utf8), using: SymmetricKey(data: Data("your-secret-key".utf8)))).base64EncodedString())
        XCTAssertEqual("svisOwCPCKT+Z+hn2vSONxsxn0M40URfq1mHKJ4QfAYVTwX58g4BZ8hhSmK20RKD", Data(HMACSHA384.authenticationCode(for: Data("Your message to sign".utf8), using: SymmetricKey(data: Data("your-secret-key".utf8)))).base64EncodedString())
        XCTAssertEqual("TrfwQeSZQ8gTfY7U+NQY+CDxexfk6hHVDJ2pevtMM2OXmxY9X/60uWhsXnMym1+vzg7XGgO729yGQgsPdAY19A==", Data(HMACSHA512.authenticationCode(for: Data("Your message to sign".utf8), using: SymmetricKey(data: Data("your-secret-key".utf8)))).base64EncodedString())
    }
}
