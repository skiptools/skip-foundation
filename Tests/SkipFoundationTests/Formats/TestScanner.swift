// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

fileprivate func withScanner(for string: String, invoking block: ((Scanner) throws -> Void)? = nil) rethrows {
        #if SKIP
        throw XCTSkip("TODO")
        #else
    let scanner = Scanner(string: string)
    scanner.locale = Locale(identifier: "en_US_POSIX")
    try block?(scanner)
        #endif // !SKIP
}

#if !SKIP
extension CharacterSet {
    fileprivate init(unicodeScalarsIn string: String) {
        // Needed because: rdar://47615913
        var set = CharacterSet()
        for character in string {
            for scalar in character.unicodeScalars {
                set.insert(scalar)
            }
        }
        
        self = set
    }
}
#endif

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class TestScanner : XCTestCase {
    func testScanFloatingPoint() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Leading whitespace:
        withScanner(for: "    1.2345") {
            expectEqual($0.scanFloat(), 1.2345 as Float, within: 0.0001 as Float, "Parsing with leading whitespace should work")
        }
        
        // Test all digits and numbers 0..9 + - E e:
        withScanner(for: "-1.23456789E123") {
            expectEqual($0.scanDouble(), atof("-1.23456789E123"), within: 0.00000001e123, "Parsing double with uppercase exponential notation")
        }
        
        withScanner(for: "+1.23456789e0") {
            expectEqual($0.scanDouble(), atof("+1.23456789e0"), within: 0.000000001, "Parsing double with lowercase exponential notation")
        }
        
        // Large magnitude:
        let largeA = "1234567890123456789012345678901234567890123456789012345678901234"
        withScanner(for: largeA) {
            expectEqual($0.scanDouble(), atof(largeA), within: 0.0000000000000001e64, "Parsing large magnitude double")
            
        }
        
        let largeB = "\(largeA)\(largeA)"
        withScanner(for: largeB) {
            expectEqual($0.scanDouble(), atof(largeB), within: 0.0000000000000001e128, "Parsing large magnitude double")
            
        }
        
        // Doubles and ints:
        withScanner(for: " 3.14   -89.1 0.0 0.0 -4.E-4 128 100.99  ") {
            expectEqual($0.scanDouble(), atof("3.14"), "Doubles and ints: 1")
            expectEqual($0.scanDouble(), atof("-89.1"), "Doubles and ints: 2")
            expectEqual($0.scanDouble(), atof("0.0"), "Doubles and ints: 3")
            expectEqual($0.scanDouble(), atof("0.0"), "Doubles and ints: 4")
            expectEqual($0.scanDouble(), atof("-4.E-4"), "Doubles and ints: 5")
            expectEqual($0.scanDouble(), atof("128"), "Doubles and ints: 6")
            expectEqual($0.scanInt(), 100, "Doubles and ints: 7") // Make sure scanning ints does not consume the decimal separator
            expectEqual($0.scanDouble(), atof(".99"), "Doubles and ints: 8")
        }
        
        // Roundtrip:
        withScanner(for: String(format: " %3.5f %3.5f ", 3.14 as Double, -100.00 as Double)) {
            expectEqual($0.scanDouble(), atof("3.14"), "Roundtrip: 1")
            expectEqual($0.scanDouble(), atof("-100"), "Roundtrip: 2")
        }

        withScanner(for: "0.5 bla 0. .1 . 1e2 e+3 e4") {
            expectEqual($0.scanDouble(), 0.5, "Parse '0.5' as Double")
            expectEqual($0.scanDouble(), nil, "Dont parse 'bla' as a Double")     // "bla" doesnt parse as Double
            expectEqual($0.scanString("bla"), "bla", "Consume the 'bla'")
            expectEqual($0.scanDouble(), 0, "Parse '0.' as a Double")
            expectEqual($0.scanDouble(), 0.1, "Parse '.1' as a Double")
            expectEqual($0.scanDouble(), nil, "Dont parse '.' as a Double")
            expectEqual($0.scanString("."), ".", "Consue '.'")
            expectEqual($0.scanDouble(), 100, "Parse '1e2' as a Double")
            expectEqual($0.scanDouble(), nil, "Dont parse 'e+3' as a Double")     // "e+3" doesnt parse as Double
            expectEqual($0.scanString("e+3"), "e+3", "Consume the 'e+3'")
            expectEqual($0.scanDouble(), nil, "Dont parse 'e4' as a Double'")     // "e3" doesnt parse as Double
            expectEqual($0.scanString("e4"), "e4", "Consume the 'e4'")
        }
        #endif // !SKIP
    }
    
    func testHexRepresentation() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Long sequence:
        withScanner(for: " 9 F 0xF 98 0x98 0x00098 0x980000000 0x980000000 acdcg0xacdcg0XACDCg0xg fFfffffE 0?777\t\n 004321X ") {
            expectEqual($0.scanInt32(representation: .hexadecimal), 9, "Same as decimal")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0xF, "Single digit")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0xF, "Single digit with 0x prefix")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0x98, "Two digits")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0x98, "Two digits with 0x prefix")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0x98, "Two digits with 0x prefix and leading zeros")
            
            expectEqual($0.scanInt32(representation: .hexadecimal), Int32.max, "Overflow")
            expectEqual($0.scanUInt64(representation: .hexadecimal), 0x980000000 as UInt64, "Unsigned 64-bit")
            
            expectEqual($0.scanInt32(representation: .hexadecimal), 0xacdc, "Followed by non-hex-digit without space")
            expectEqual($0.scanString("g"), "g", "Consume non-hex-digit")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0xacdc, "Followed by non-hex-digit without space, with 0x prefix")
            expectEqual($0.scanString("g"), "g", "Consume non-hex-digit (2)")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0xacdc, "Followed by non-hex-digit without space, with 0X prefix")
            expectEqual($0.scanString("g"), "g", "Consume non-hex-digit (3)")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0, "'0x' followed by non-hex-digit without space")
            expectEqual($0.scanInt32(representation: .hexadecimal), nil, "'x' (after trying to parse '0xg' as hexadecimal) isn't parsed as hex int itself")
            expectEqual($0.scanString("xg"), "xg", "Consume non-hex-digits (4)")
            
            expectEqual($0.scanInt64(representation: .hexadecimal), 0xfffffffe, "Mixed case, 64-bit")
            
            expectEqual($0.scanInt32(representation: .hexadecimal), 0, "0 prefixing complex whitespace sequence")
            expectEqual($0.scanString("?"), "?", "Consume complex whitespace sequence (1)")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0x777, "777 inside complex whitespace sequence")
            expectEqual($0.scanInt32(representation: .hexadecimal), 0x4321, "4321 with leading zeros inside complex whitespace sequence")
            expectFalse($0.isAtEnd, "The X was not consumed")
            expectEqual($0.scanString("X"), "X", "Consume the X")
            expectTrue($0.isAtEnd, "The X was not consumed")
        }
        #endif // !SKIP
    }

    func testHexFloatingPoint() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        withScanner(for: "0xAA 3.14 0.1x 1g 3xx .F00x 1e00 . -0xabcdef.02") {
            expectEqual($0.scanDouble(representation: .hexadecimal), 0xAA, "Integer as Double")
//            expectEqual($0.scanDouble(representation: .hexadecimal), 3.078125, "Double")
//            expectEqual($0.scanDouble(representation: .hexadecimal), 0.0625, "Double")
//            expectEqual($0.scanString("x"), "x", "Consume non-hex-digit")
//            expectEqual($0.scanDouble(representation: .hexadecimal), Double(1), "Double")
//            expectEqual($0.scanString("g"), "g", "Consume non-hex-digit")
//            expectEqual($0.scanDouble(representation: .hexadecimal), Double(3), "Double")
//            expectEqual($0.scanString("xx"), "xx", "Consume non-hex-digits")
//            expectEqual($0.scanDouble(representation: .hexadecimal), 0.9375, "Double")
//            expectEqual($0.scanString("x"), "x", "Consume non-hex-digit")
//            expectEqual($0.scanDouble(representation: .hexadecimal), 0x1E00, "E is not for exponent")
//            expectEqual($0.scanDouble(), nil, "Dont parse '.' as a Double")
//            expectEqual($0.scanString("."), ".", "Consue '.'")
//            expectEqual($0.scanDouble(representation: .hexadecimal), -11259375.0078125, "negative decimal")
        }
        #endif // !SKIP
    }
    
    func testUInt64() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // UInt64 long sequence:
        withScanner(for: String(format: "%llu %llu %llu 42 + 42 0 %llu", UInt64.max / 10, UInt64.max - 1, UInt64.max, UInt64.max)) {
            expectEqual($0.scanUInt64(), UInt64.max / 10, "Order of magnitude close to max")
            expectEqual($0.scanUInt64(), UInt64.max - 1, "One less than max")
            expectEqual($0.scanUInt64(), UInt64.max, "Max")
            expectEqual($0.scanUInt64(), 42 as UInt64, "Short-sized integer")
            expectEqual($0.scanUInt64(), 42 as UInt64, "Short-sized integer, with sign, ignoring whitespace")
            expectEqual($0.scanUInt64(), 0 as UInt64, "Zero")
            expectEqual($0.scanUInt64(), UInt64.max, "Max again after zero (ignoring prefix whitespace without merging this with the zero)")
        }
        
        // Overflow:
        withScanner(for: "\(UInt64.max)0") {
            expectEqual($0.scanUInt64(), UInt64.max, "Overflow")
        }
        #endif // !SKIP
    }
    
    func testInt64() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Int64 long sequence:
        withScanner(for: String(format: "%lld %lld %lld 42 - 42 0 -1 -1 %lld %lld", Int64.max / 10, Int64.max - 1, Int64.max, Int64.min, Int64.max)) {
            expectEqual($0.scanInt64(), Int64.max / 10, "Order of magnitude close to max")
            expectEqual($0.scanInt64(), Int64.max - 1, "One less than max")
            expectEqual($0.scanInt64(), Int64.max, "Max")
            expectEqual($0.scanInt64(), 42 as Int64, "Short-sized integer")
            expectEqual($0.scanInt64(), -42 as Int64, "Short-sized integer, with sign, ignoring whitespace")
            expectEqual($0.scanInt64(), 0 as Int64, "Zero")
            expectEqual($0.scanInt64(), -1 as Int64, "Minus one")
            expectEqual($0.scanInt64(), -1 as Int64, "Minus one after whitespace")
            expectEqual($0.scanInt64(), Int64.min, "Min")
            expectEqual($0.scanInt64(), Int64.max, "Max again after min (no joining it with preceding min even with ignroed whitespace)")
        }
        
        // Overflow:
        withScanner(for: "\(Int64.max)0") {
            expectEqual($0.scanInt64(), Int64.max, "Overflow")
        }
        #endif // !SKIP
    }
    
    func testInt32() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Int32 long sequence:
        withScanner(for: String(format: "%d %d %d 42 - 42 0 -1 -1 %d %d", Int32.max / 10, Int32.max - 1, Int32.max, Int32.min, Int32.max)) {
            expectEqual($0.scanInt32(), Int32.max / 10, "Order of magnitude close to max")
            expectEqual($0.scanInt32(), Int32.max - 1, "One less than max")
            expectEqual($0.scanInt32(), Int32.max, "Max")
            expectEqual($0.scanInt32(), 42 as Int32, "Short-sized integer")
            expectEqual($0.scanInt32(), -42 as Int32, "Short-sized integer, with sign, ignoring whitespace")
            expectEqual($0.scanInt32(), 0 as Int32, "Zero")
            expectEqual($0.scanInt32(), -1 as Int32, "Minus one")
            expectEqual($0.scanInt32(), -1 as Int32, "Minus one after whitespace")
            expectEqual($0.scanInt32(), Int32.min, "Min")
            expectEqual($0.scanInt32(), Int32.max, "Max again after min (no joining it with preceding min even with ignroed whitespace)")
        }
        
        // Overflow:
        withScanner(for: "\(Int32.max)0") {
            expectEqual($0.scanInt32(), Int32.max, "Overflow")
        }
        #endif // !SKIP
    }
    
    func testScanCharacter() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        withScanner(for: " hello ") {
            expectEqual($0.scanCharacter(), "h", "Hello! (h)")
            expectEqual($0.scanCharacter(), "e", "Hello! (e)")
            expectEqual($0.scanCharacter(), "l", "Hello! (l)")
            expectEqual($0.scanCharacter(), "l", "Hello! (l)")
            expectFalse($0.isAtEnd, "Not at end yet")
            expectEqual($0.scanCharacter(), "o", "Hello! (o)")
            expectTrue($0.isAtEnd, "At end (ignores trailing whitespace)")
        }
        
        withScanner(for: " \tde\u{0301}mode\u{0301}\n\t\n ") {
            expectEqual($0.scanCharacter(), "d", "Démodé! (d)")
            expectEqual($0.scanCharacter(), "é", "Démodé! (é)") // Two code points in original, comparing to é (single code point)
            expectEqual($0.scanCharacter(), "m", "Démodé! (m)")
            expectEqual($0.scanCharacter(), "o", "Démodé! (o)")
            expectEqual($0.scanCharacter(), "d", "Démodé! (d)")
            expectFalse($0.isAtEnd, "Not at end yet")
            expectEqual($0.scanCharacter(), "é", "Démodé! (é)") // Two code points in original, comparing to é (single code point)
            expectTrue($0.isAtEnd, "At end (ignores trailing whitespace)")
        }
        
        withScanner(for: "  \t\n❤️   \t\t\n") {
            expectFalse($0.isAtEnd, "Not at end yet")
            expectEqual($0.scanCharacter(), "❤️", "Scan single grapheme (made of single code point)")
            expectTrue($0.isAtEnd, "At end (ignores trailing whitespace)")
        }
        
        withScanner(for: " \t👩‍👩‍👧‍👧\n\t\n ") {
            expectFalse($0.isAtEnd, "Not at end yet")
            expectEqual($0.scanCharacter(), "👩‍👩‍👧‍👧", "Scan single grapheme (made of multiple code points)")
            expectTrue($0.isAtEnd, "At end (ignores trailing whitespace)")
        }
        
        // Unicode 10.0 emoji:
        withScanner(for: " \t\u{1f9db}\u{200d}\u{2640}\u{fe0f}\n\t\n ") { // VAMPIRE, ZERO-WIDTH JOINER, FEMALE SIGN, VARIATION SELECTOR-16
            expectFalse($0.isAtEnd, "Not at end yet")
            expectEqual($0.scanCharacter(), "🧛‍♀️", "Scan single grapheme (made of multiple code points)")
            expectTrue($0.isAtEnd, "At end (ignores trailing whitespace)")
        }
        #endif // !SKIP
    }
    
    func testScanString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Scan skipping whitespace:
        withScanner(for: "h el lo ") {
            expectEqual($0.scanString("hello"), nil, "Split 'hello': Cannot scan the whole word in one go")
            expectEqual($0.scanString("h"), "h",   "Split 'hello' (h)")
            expectEqual($0.scanString("el"), "el", "Split 'hello' (el)")
            expectEqual($0.scanString("lo"), "lo", "Split 'hello' (lo)")
            expectTrue($0.isAtEnd, "Split 'hello': should be at end.")
        }
        
        // Scan without whitespace to skip:
        withScanner(for: "hello ") {
            expectEqual($0.scanString("hello"), "hello", "Joined 'hello': Can scan the whole word in one go")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanString("h"), "h",   "Joined 'hello' (h)")
            expectEqual($0.scanString("el"), "el", "Joined 'hello' (el)")
            expectEqual($0.scanString("lo"), "lo", "Joined 'hello' (lo)")
            expectTrue($0.isAtEnd, "Joined 'hello': should be at end.")
        }
        
        // Scan without skipping whitespace:
        withScanner(for: "h el lo ") {
            $0.charactersToBeSkipped = nil
            expectEqual($0.scanString("h"), "h",   "Split 'hello', without skipping whitespace (h)")
            expectEqual($0.scanString("el"), nil,  "Split 'hello', without skipping whitespace (el can't be scanned without consuming whitespace)")
            expectEqual($0.scanString(" "),  " ",  "Split 'hello', without skipping whitespace (consume whitespace 1)")
            expectEqual($0.scanString("el"), "el", "Split 'hello', without skipping whitespace (el)")
            expectEqual($0.scanString("lo"), nil,  "Split 'hello', without skipping whitespace (lo can't be scanned without consuming whitespace)")
            expectEqual($0.scanString(" "),  " ",  "Split 'hello', without skipping whitespace (consume whitespace 2)")
            expectEqual($0.scanString("lo"), "lo", "Split 'hello', without skipping whitespace (lo)")
            expectFalse($0.isAtEnd, "Split 'hello', without skipping whitespace: should not be at end without consuming trailing whitespace")
            expectEqual($0.scanString(" "),  " ",  "Split 'hello', without skipping whitespace (consume whitespace 3)")
            expectTrue($0.isAtEnd, "Split 'hello', without skipping whitespace: should be at end")
        }
        
        // Case-insensitive scanning:
        withScanner(for: "H eL lO ") {
            $0.caseSensitive = false
            expectEqual($0.scanString("h"), "H",   "Case-insensitive split 'hello' (h)")
            expectEqual($0.scanString("el"), "eL", "Case-insensitive split 'hello' (el)")
            expectEqual($0.scanString("lo"), "lO", "Case-insensitive split 'hello' (lo)")
            expectTrue($0.isAtEnd, "Case-insensitive split 'hello': should be at end.")
        }
        
        // Equivalent graphemes:
        withScanner(for: "e\u{0300}") { // 'e' with a combining grave accent, two code points
            expectEqual($0.scanString("\u{00E8}" /* U+00E8 LATIN SMALL LETTER E WITH GRAVE, one code point */), $0.string, "Can scan different string to get original as long as all graphemes are equivalent")
        }
        
        // Partial graphemes:
        withScanner(for: "e\u{0301}\u{031A}\u{032B}") {
            // We do not assert here that the legacy methods don't work because they behave inconsistently wrt graphemes, and are able to actually discern that a combination code point plus a sequence of combining diacriticals is actually not OK to scan. Check just the newer behavior here.
            expectEqual($0.scanString("e"), nil, "New method must not split graphemes while scanning")
            expectEqual($0.scanString("e\u{0301}"), nil, "New method must not split graphemes while scanning")
            expectEqual($0.scanString("e\u{0301}\u{031A}"), nil, "New method must not split graphemes while scanning")
            expectEqual($0.scanString("e\u{0301}\u{031A}\u{032B}"), "e\u{0301}\u{031A}\u{032B}", "New method must not split graphemes while scanning")
        }
        
        withScanner(for: "Lily is a 👩🏻‍💻") { // That's: [ U+1F469 WOMAN, U+1F3FB EMOJI MODIFIER FITZPATRICK SCALE 1-2, U+200D ZERO-WIDTH JOINER, U+1F4BB PERSONAL COMPUTER ]
            // The deprecated API can scan a string that's a prefix of the code point sequence of this string, but the new method cannot do so if it would split the final character.
            // .scanString(_:into:) interacts inconsistently with emoji. U+1F469 WOMAN will not scan by itself, but U+1F469 WOMAN, U+1F3FB EMOJI MODIFIER FITZPATRICK SCALE 1-2 will scan even though it's only part of a grapheme.
            // .scanString() is designed to work on graphemes, so it will not scan either of these sequences.
            expectEqual($0.scanString("Lily is a \u{1F469}\u{1F3FB}", into: nil), true, "Legacy method can split graphemes while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanString("Lily is a \u{1F469}\u{1F3FB}"), nil,             "New method must not split graphemes while scanning")
            expectEqual($0.scanString("Lily is a \u{1F469}\u{1F3FB}\u{200D}"), nil,     "New method must not split graphemes while scanning")
            
            expectEqual($0.scanString("Lily is a \u{1F469}\u{1F3FB}\u{200D}\u{1F4BB}"), "Lily is a 👩🏻‍💻", "New method must work if graphemes would not be split while scanning")
            expectTrue($0.isAtEnd, "After scanning the last grapheme, we are at end")
        }
        
        // Legacy method interaction with partial grapheme scanning:
        withScanner(for: "Lily is a 👩🏻‍💻!") {
            expectEqual($0.scanString("Lily is a \u{1F469}\u{1F3FB}", into: nil), true, "Legacy method can split graphemes while scanning")
            expectEqual(String($0.string[$0.currentIndex...]), "!", "The index to scan from is the one after the end of the grapheme")
            expectEqual($0.scanString("!"), "!", "Scanning starts correctly from there")
        }
        
        withScanner(for: "Lily is a 👩🏻‍💻") {
            expectEqual($0.scanString("Lily is a \u{1F469}\u{1F3FB}", into: nil), true, "Legacy method can split graphemes while scanning")
            expectFalse($0.isAtEnd, "The scanner can scan more using legacy methods, even though no whole graphemes are left to scan. This can only happen when legacy methods are invoked or the deprecated .scanLocation property is set directly.")
            expectEqual($0.currentIndex, $0.string.endIndex, "The Swift.String.Index we will resume scanning from for new methods is correctly pointing to the end of the string")
        }
        #endif // !SKIP
    }
    
    func testScanUpToString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Scan skipping whitespace:
        withScanner(for: "  hel lo") {
            expectEqual($0.scanUpToString("lo"), "hel ", "Leading whitespace is skipped but not trailing whitespace before the stop point")
            expectEqual($0.scanString("lo"), "lo", "The up-to string can be scanned immediately afterwards")
        }
        
        // Scan without skipping whitespace:
        withScanner(for: "  hel lo") {
            $0.charactersToBeSkipped = nil
            expectEqual($0.scanUpToString("lo"), "  hel ", "No whitespace is skipped")
            expectEqual($0.scanString("lo"), "lo", "The up-to string can be scanned immediately afterwards")
        }
        
        // Case-insensitive:
        withScanner(for: "  hel LOo!") {
            $0.caseSensitive = false
            expectEqual($0.scanUpToString("lo"), "hel ", "Leading whitespace is skipped but not trailing whitespace before the stop point")
            expectEqual($0.scanString("lo"), "LO", "The up-to string can be scanned immediately afterwards (and actual case is returned)")
        }
        
        // Equivalent graphemes:
        withScanner(for: "wow e\u{0300}") { // 'e' with a combining grave accent, two code points
            expectEqual($0.scanUpToString("\u{00E8}" /* U+00E8 LATIN SMALL LETTER E WITH GRAVE, one code point */), "wow ", "Can scan different string to get original as long as all graphemes are equivalent")
            expectEqual($0.scanString("\u{00E8}"), "e\u{0300}", "The up-to string can be scanned immediately afterwards (and actual source form is returned)")
        }
        
        // Partial graphemes (diacritics):
        withScanner(for: "wow e\u{0301}\u{031A}\u{032B} NOT FOUND") {
            // We do not assert here that the legacy methods don't work because they behave inconsistently wrt graphemes, and are able to actually discern that a combination code point plus a sequence of combining diacriticals is actually not OK to scan. Check just the newer behavior here.
            // The correct failure mode here is that the whole string should be returned on failure to match — the partial grapheme match won't stop scanUpToString(_:), which will keep looking later. This means that on failure to find, the methods will succeed -- this is why we reset .currentIndex after every invocation.
            expectEqual($0.scanUpToString("e"), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToString("e\u{0301}"), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToString("e\u{0301}\u{031A}"), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToString("e\u{0301}\u{031A}\u{032B}"), "wow ", "New method must match a full grapheme and stop there")
            expectEqual($0.scanString("e\u{0301}\u{031A}\u{032B}"), "e\u{0301}\u{031A}\u{032B}", "The up-to string can be scanned immediately afterwards")
        }
        
        // Partial graphemes (emoji):
        withScanner(for: "Lily is a 👩🏻‍💻 NOT FOUND") { // That's: [ U+1F469 WOMAN, U+1F3FB EMOJI MODIFIER FITZPATRICK SCALE 1-2, U+200D ZERO-WIDTH JOINER, U+1F4BB PERSONAL COMPUTER ]
            expectEqual($0.scanUpToString("\u{1F469}"), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToString("\u{1F469}\u{1F3FB}"), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToString("\u{1F469}\u{1F3FB}\u{200D}"), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToString("\u{1F469}\u{1F3FB}\u{200D}\u{1F4BB}"), "Lily is a ", "New method must work if graphemes would not be split while scanning")
            expectEqual($0.scanString("👩🏻‍💻"), "👩🏻‍💻", "The up-to string can be scanned immediately afterwards")
        }
        #endif // !SKIP
    }
    
    func testScanCharactersFromSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Scan skipping whitespace:
        withScanner(for: "   doremifasol123 whoa") {
            expectEqual($0.scanCharacters(from: .alphanumerics), "doremifasol123", "Skip leading whitespace, but do stop when new whitespace occurs")
        }
        
        // Scan without skipping whitespace:
        withScanner(for: "   doremifasol123 !!") {
            $0.charactersToBeSkipped = nil
            expectEqual($0.scanCharacters(from: .alphanumerics), nil, "Do not skip leading whitespace")
            let combined = CharacterSet.alphanumerics.union(.whitespaces)
            expectEqual($0.scanCharacters(from: combined), "   doremifasol123 ", "Pick up whitespace when explicitly requested, including trailing whitespace, and stop before the final characters outside the set")
        }
        
        // Case sensitivity does not impact .scanCharacters(from:)
        withScanner(for: "wowWOW") {
            $0.caseSensitive = false
            expectEqual($0.scanCharacters(from: CharacterSet(charactersIn: "wo")), "wow", ".caseSensitive does not change which characters are found by scanCharacters(from:)")
        }
        
        // Scan only full graphemes (diacritics):
        withScanner(for: " e\u{0301}\u{031A}\u{032B} wow") {
            expectEqual($0.scanCharacters(from: CharacterSet(charactersIn: "e")), nil, "Cannot scan a grapheme that contains one or more code points not in the set")
            expectEqual($0.scanCharacters(from: CharacterSet(charactersIn: "e\u{0301}")), nil, "Cannot scan a grapheme that contains one or more code points not in the set")
            expectEqual($0.scanCharacters(from: CharacterSet(charactersIn: "e\u{0301}\u{031A}")), nil, "Cannot scan a grapheme that contains one or more code points not in the set")
            expectEqual($0.scanCharacters(from: CharacterSet(charactersIn: "e\u{0301}\u{031A}\u{032B}")), "e\u{0301}\u{031A}\u{032B}", "Can scan a grapheme if all of its code points are in the character set")
        }
        
        // Scan only full graphemes (emoji):
        withScanner(for: "Lily is a 👩🏻‍💻") { // That's: [ U+1F469 WOMAN, U+1F3FB EMOJI MODIFIER FITZPATRICK SCALE 1-2, U+200D ZERO-WIDTH JOINER, U+1F4BB PERSONAL COMPUTER ]
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanCharacters(from: CharacterSet(unicodeScalarsIn: "Lily is a \u{1F469}")), "Lily is a ", "Cannot scan a grapheme that contains one or more code points not in the set")
            
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanCharacters(from: CharacterSet(unicodeScalarsIn: "Lily is a \u{1F469}\u{1F3FB}")), "Lily is a ", "Cannot scan a grapheme that contains one or more code points not in the set")
            
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanCharacters(from: CharacterSet(unicodeScalarsIn: "Lily is a \u{1F469}\u{1F3FB}\u{200D}")), "Lily is a ","Cannot scan a grapheme that contains one or more code points not in the set")
            
            $0.currentIndex = $0.string.startIndex
            let set = CharacterSet(unicodeScalarsIn: "Lily is a \u{1F469}\u{1F3FB}\u{200D}\u{1F4BB}")
            expectEqual($0.scanCharacters(from: set), "Lily is a 👩🏻‍💻", "Can scan a grapheme if all of its code points are in the character set")
        }
        #endif // !SKIP
    }
    
    func testScanUpToCharactersFromSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Scan skipping whitespace:
        withScanner(for: "   hel- lo ") {
            let hyphen = CharacterSet(unicodeScalarsIn: "-")
            
            expectEqual($0.scanUpToCharacters(from: .alphanumerics), nil, "Whitespace should be skipped, and we should already be at a place where alphanumerics match 'hel'")
            expectEqual($0.scanUpToCharacters(from: hyphen), "hel", "Whitespace should be skipped, and the rest captured until the separator")
            expectEqual($0.scanCharacters(from: hyphen), "-", "You should be able to scan the up-to string immediately")
            expectEqual($0.scanUpToCharacters(from: .alphanumerics), nil, "Whitespace should be skipped, and we should already be at a place where alphanumerics match 'lo'")
        }
        
        // Scan without skipping whitespace:
        withScanner(for: "   hel- lo ") {
            let hyphen = CharacterSet(unicodeScalarsIn: "-")
            $0.charactersToBeSkipped = nil
            
            expectEqual($0.scanUpToCharacters(from: .alphanumerics), "   ", "Whitespace should not be skipped.")
            expectEqual($0.scanUpToCharacters(from: hyphen), "hel", "Move to the hyphen and scan the 'hel' in the process")
            expectEqual($0.scanUpToCharacters(from: .whitespaces), "-", "Scan hyphen, to the whitespace")
            expectEqual($0.scanUpToCharacters(from: .alphanumerics), " ", "Whitespace should not be skipped, and we should move at a place where alphanumerics match 'lo'")
            expectEqual($0.scanString("lo"), "lo", "Consume the 'lo'")
        }
        
        withScanner(for: "so, HELLO") {
            $0.caseSensitive = false
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "h")), "so, HELLO", ".caseSensitive should not affect .scanUpToCharacters(from:); a set of only 'h' should not match 'H'")
        }
        
        // Equivalent graphemes:
        withScanner(for: "wow e\u{0300}") { // 'e' with a combining grave accent, two code points
            let set = CharacterSet(unicodeScalarsIn: "\u{00E8}" /* U+00E8 LATIN SMALL LETTER E WITH GRAVE, one code point */)
            expectEqual($0.scanUpToCharacters(from: set), "wow e\u{0300}", "Scanning using a character set should only match graphemes if the specific code points they are composed of are in the character set. 'e' + combining accent is not matched by a set with just 'è', even though they make equivalent graphemes")
            
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "e\u{0300}")), "wow ", "Scanning does match if the specific code points are in the set")
            
        }
        
        // Partial graphemes (diacritics):
        withScanner(for: "wow e\u{0301}\u{031A}\u{032B} NOT FOUND") {
            // The correct failure mode here is that the whole string should be returned on failure to match — the partial grapheme match won't stop scanUpToCharacters(from:), which will keep looking later. This means that on failure to find, the methods will succeed -- this is why we reset .currentIndex after every invocation.
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "e")), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "e\u{0301}")), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "e\u{0301}\u{031A}")), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "e\u{0301}\u{031A}\u{032B}")), "wow ", "Scanning does match if the specific code points are in the set")
            expectEqual($0.scanCharacters(from: CharacterSet(unicodeScalarsIn: "e\u{0301}\u{031A}\u{032B}")), "e\u{0301}\u{031A}\u{032B}", "The up-to character set can be scanned immediately afterwards")
        }
        
        // Partial graphemes (emoji):
        withScanner(for: "Lily is a 👩🏻‍💻 NOT FOUND") { // That's: [ U+1F469 WOMAN, U+1F3FB EMOJI MODIFIER FITZPATRICK SCALE 1-2, U+200D ZERO-WIDTH JOINER, U+1F4BB PERSONAL COMPUTER ]
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "\u{1F469}")), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "\u{1F469}\u{1F3FB}")), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            $0.currentIndex = $0.string.startIndex
            expectEqual($0.scanUpToCharacters(from: CharacterSet(unicodeScalarsIn: "\u{1F469}\u{1F3FB}\u{200D}")), $0.string, "New method must go past graphemes that match part of the scan-up-to string while scanning")
            
            $0.currentIndex = $0.string.startIndex
            let finalSet = CharacterSet(unicodeScalarsIn: "\u{1F469}\u{1F3FB}\u{200D}\u{1F4BB}")
            expectEqual($0.scanUpToCharacters(from: finalSet), "Lily is a ", "New method must work if graphemes would not be split while scanning")
            expectEqual($0.scanCharacters(from: finalSet), "👩🏻‍💻", "The up-to character set can be scanned immediately afterwards")
        }
        #endif // !SKIP
    }

    func testLocalizedScanner() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ds = Locale.current.decimalSeparator ?? "."
        let string = "123\(ds)456"
        let scanner = try XCTUnwrap((Scanner.localizedScanner(with: string) as? Scanner))
        XCTAssertNotNil(scanner.locale)
        var value: Decimal = 0
        XCTAssertTrue(scanner.scanDecimal(&value))
        XCTAssertEqual(value.description, "123.456")

        // Check a normal scanner has no locale set
        XCTAssertNil(Scanner(string: "foo").locale)
        #endif // !SKIP
    }

}


