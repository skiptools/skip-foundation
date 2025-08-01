// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:

// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


class TestNumberFormatter: XCTestCase {

    // SKIP REPLACE: val currencySpacing = "\u00A0" // no Skip support for unicode constants
    let currencySpacing = "\u{00A0}"

    func test_defaultPropertyValues() {
        let numberFormatter = NumberFormatter()
        XCTAssertEqual(numberFormatter.numberStyle, NumberFormatter.Style.none)
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 0)
        #if !SKIP // Skip unsupported NumberFormatter properties
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        XCTAssertNil(numberFormatter.multiplier)
        XCTAssertFalse(numberFormatter.usesGroupingSeparator)
        #endif // !SKIP
        XCTAssertEqual(numberFormatter.groupingSize, 0)
    }

    func test_defaultDecimalPropertyValues() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 3)
        #if !SKIP // Skip unsupported NumberFormatter properties
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        XCTAssertNil(numberFormatter.multiplier)
        #endif
//        XCTAssertEqual(numberFormatter.format, "#,##0.###;0;#,##0.###")
//        XCTAssertEqual(numberFormatter.positiveFormat, "#,##0.###")
//        XCTAssertEqual(numberFormatter.negativeFormat, "#,##0.###")
        XCTAssertTrue(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 3)
    }

    func test_defaultCurrencyPropertyValues() {
        let numberFormatter = NumberFormatter()
        let currency = Locale.current.currencySymbol ?? ""
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 2)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 2)
        #if !SKIP // Skip unsupported NumberFormatter properties
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
//        XCTAssertEqual(numberFormatter.format, "¤#,##0.00;\(currency)0.00;¤#,##0.00")
//        XCTAssertEqual(numberFormatter.positiveFormat, "¤#,##0.00")
//        XCTAssertEqual(numberFormatter.negativeFormat, "¤#,##0.00")
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        XCTAssertNil(numberFormatter.multiplier)
        #endif // !SKIP
        XCTAssertTrue(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 3)
    }

    func test_defaultPercentPropertyValues() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.percent
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 0)
        #if !SKIP // Skip unsupported NumberFormatter properties
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        #endif // !SKIP
//        XCTAssertEqual(numberFormatter.format, "#,##0%;0%;#,##0%")
//        XCTAssertEqual(numberFormatter.positiveFormat, "#,##0%")
//        XCTAssertEqual(numberFormatter.negativeFormat, "#,##0%")
        XCTAssertEqual(numberFormatter.multiplier, NSNumber(100))
        XCTAssertTrue(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 3)
    }

    func test_defaultScientificPropertyValues() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.scientific
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
#if !SKIP // Skip unsupported NumberFormatter properties
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.maximumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
#if false && !DARWIN_COMPATIBILITY_TESTS
//        XCTAssertEqual(numberFormatter.format, "#E0;0E0;#E0")
#else
//        XCTAssertEqual(numberFormatter.format, "#E0;1E-100;#E0")
#endif
        XCTAssertEqual(numberFormatter.positiveFormat, "#E0")
        XCTAssertEqual(numberFormatter.negativeFormat, "#E0")
        XCTAssertNil(numberFormatter.multiplier)
        XCTAssertFalse(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 0)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        #endif
    }

    func test_defaultSpelloutPropertyValues() {
        #if SKIP
        throw XCTSkip("Skip SpellOut style")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 0)
        XCTAssertEqual(numberFormatter.maximumIntegerDigits, 0)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, 0)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, 0)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, 0)
#if false && !DARWIN_COMPATIBILITY_TESTS
//        XCTAssertEqual(numberFormatter.format, "(null);zero;(null)")
#else
//        XCTAssertEqual(numberFormatter.format, "(null);zero point zero;(null)")
#endif
        XCTAssertEqual(numberFormatter.positiveFormat, nil)
        XCTAssertEqual(numberFormatter.negativeFormat, nil)
        XCTAssertNil(numberFormatter.multiplier)
        XCTAssertFalse(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 0)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        #endif // !SKIP
    }

    func test_defaultOrdinalPropertyValues() {
        #if SKIP
        throw XCTSkip("Skip Ordinal Style")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.ordinal
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 0)
        XCTAssertEqual(numberFormatter.maximumIntegerDigits, 0)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, 0)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, 0)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, 0)
//        XCTAssertEqual(numberFormatter.format, "(null);0th;(null)")
        XCTAssertEqual(numberFormatter.positiveFormat, nil)
        XCTAssertEqual(numberFormatter.negativeFormat, nil)
        XCTAssertNil(numberFormatter.multiplier)
        XCTAssertFalse(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 0)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        #endif // !SKIP
    }

    func test_defaultCurrencyISOCodePropertyValues() {
        #if SKIP
        throw XCTSkip("Skip CurrencyISO style")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyISOCode
        numberFormatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale(identifier: "en_US"))
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.maximumIntegerDigits, 2_000_000_000)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 2)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 2)
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
//        XCTAssertEqual(numberFormatter.format, "¤¤#,##0.00;USD\(currencySpacing)0.00;¤¤#,##0.00")
        XCTAssertEqual(numberFormatter.positiveFormat, "¤¤#,##0.00")
        XCTAssertEqual(numberFormatter.negativeFormat, "¤¤#,##0.00")
        XCTAssertNil(numberFormatter.multiplier)
        XCTAssertTrue(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 3)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        XCTAssertEqual(numberFormatter.string(from: NSNumber(1234567890)), "USD\(currencySpacing)1,234,567,890.00")
        #endif // !SKIP
    }

    func test_defaultCurrencyPluralPropertyValues() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyPlural
        numberFormatter.locale = Locale(identifier: "en_GB")
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale(identifier: "en_GB"))
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 0)
        XCTAssertEqual(numberFormatter.maximumIntegerDigits, 0)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, 0)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, 0)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, 0)
//        XCTAssertEqual(numberFormatter.format, "(null);0.00 British pounds;(null)")
        XCTAssertEqual(numberFormatter.positiveFormat, nil)
        XCTAssertEqual(numberFormatter.negativeFormat, nil)
        XCTAssertNil(numberFormatter.multiplier)
        XCTAssertFalse(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 0)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        #endif // !SKIP
    }

    func test_defaultCurrenyAccountingPropertyValues() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
        numberFormatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.maximumIntegerDigits, 2_000_000_000)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 2)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 2)
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
//        XCTAssertEqual(numberFormatter.format, "¤#,##0.00;$0.00;(¤#,##0.00)")
//        XCTAssertEqual(numberFormatter.positiveFormat, "¤#,##0.00")
//        XCTAssertEqual(numberFormatter.negativeFormat, "(¤#,##0.00)")
        XCTAssertNil(numberFormatter.multiplier)
        XCTAssertTrue(numberFormatter.usesGroupingSeparator)
        XCTAssertEqual(numberFormatter.groupingSize, 3)
        XCTAssertEqual(numberFormatter.secondaryGroupingSize, 0)
        #endif // !SKIP
    }

    func test_currencyCode() {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_GB")
        numberFormatter.numberStyle = NumberFormatter.Style.currency
//        XCTAssertEqual(numberFormatter.format, "¤#,##0.00;£0.00;¤#,##0.00")
        XCTAssertEqual(numberFormatter.string(from: 1.1), "£1.10")
        XCTAssertEqual(numberFormatter.string(from: 0), "£0.00")
        XCTAssertEqual(numberFormatter.string(from: -1.1), "-£1.10")

        numberFormatter.currencyCode = "T"
        XCTAssertEqual(numberFormatter.currencyCode, "T")
        XCTAssertEqual(numberFormatter.currencySymbol, "£")
//        XCTAssertEqual(numberFormatter.format, "¤#,##0.00;£0.00;¤#,##0.00")
        numberFormatter.currencyDecimalSeparator = "_"
//        XCTAssertEqual(numberFormatter.format, "¤#,##0.00;£0_00;¤#,##0.00")

        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "£42_00")

        // Check that the currencyCode is preferred over the locale when no currencySymbol is set
        let codeFormatter = NumberFormatter()
        codeFormatter.numberStyle = NumberFormatter.Style.currency
        codeFormatter.locale = Locale(identifier: "en_US")
        codeFormatter.currencyCode = "GBP"
        #if !SKIP
        XCTAssertEqual(codeFormatter.string(from: 3.02), "£3.02")
        #endif
    }

    func test_decimalSeparator() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
//        XCTAssertEqual(numberFormatter.format, "#,##0.###;0;#,##0.###")

        let separator = "-"
        numberFormatter.decimalSeparator = separator
//        XCTAssertEqual(numberFormatter.format, "#,##0.###;0;#,##0.###")
        XCTAssertEqual(numberFormatter.decimalSeparator, separator)

        let formattedString = numberFormatter.string(from: 42.42)
        XCTAssertEqual(formattedString, "42-42")
    }

    func test_currencyDecimalSeparator() {
        let numberFormatter = NumberFormatter()
        #if !SKIP
        numberFormatter.locale = Locale(identifier: "fr_FR")
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencyDecimalSeparator = "-"
        numberFormatter.currencyCode = "T"
//        XCTAssertEqual(numberFormatter.format, "#,##0.00 ¤;0-00\(currencySpacing)€;#,##0.00 ¤")
        let formattedString = numberFormatter.string(from: 42.42)
        XCTAssertEqual(formattedString, "42-42\(currencySpacing)€")
        #endif
    }
    
    func test_alwaysShowDecimalSeparator() {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "-"
        numberFormatter.alwaysShowsDecimalSeparator = true
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "42-")
    }
    
    func test_groupingSeparator() {
        let decFormatter1 = NumberFormatter()
        XCTAssertEqual(decFormatter1.groupingSize, 0)
        decFormatter1.numberStyle = NumberFormatter.Style.decimal
        #if !SKIP
        XCTAssertEqual(decFormatter1.groupingSize, 3)
        #endif
//        XCTAssertEqual(decFormatter1.format, "#,##0.###;0;#,##0.###")

        let decFormatter2 = NumberFormatter()
        XCTAssertEqual(decFormatter2.groupingSize, 0)
        decFormatter2.groupingSize = 1
        decFormatter2.numberStyle = NumberFormatter.Style.decimal
        #if !SKIP
        XCTAssertEqual(decFormatter2.groupingSize, 1)
        #endif
//        XCTAssertEqual(decFormatter2.format, "#,0.###;0;#,0.###")

        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = "_"
//        XCTAssertEqual(numberFormatter.groupingSize, 0)
        numberFormatter.groupingSize = 3

        let formattedString = numberFormatter.string(from: 42_000)
        XCTAssertEqual(formattedString, "42_000")
    }
    
    func test_percentSymbol() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.percent
        numberFormatter.percentSymbol = "💯"
        let formattedString = numberFormatter.string(from: 0.42)
        #if SKIP
        // java.text.DecimalFormatSymbols's percentSymbol is limited to a single `char`
        throw XCTSkip("Skip shortcoming: percentSymbol")
        #endif
        XCTAssertEqual(formattedString, "42💯")
    }
    
    func test_zeroSymbol() {
        let numberFormatter = NumberFormatter()
        XCTAssertEqual(numberFormatter.numberStyle, NumberFormatter.Style.none)
        XCTAssertEqual(numberFormatter.generatesDecimalNumbers, false)
//        XCTAssertEqual(numberFormatter.localizesFormat, true)
        XCTAssertEqual(numberFormatter.locale, Locale.current)
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        XCTAssertEqual(numberFormatter.minimumFractionDigits, 0)
        XCTAssertEqual(numberFormatter.maximumFractionDigits, 0)
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(numberFormatter.minimumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        XCTAssertEqual(numberFormatter.usesSignificantDigits, false)
        XCTAssertEqual(numberFormatter.formatWidth, -1)
        numberFormatter.zeroSymbol = "⚽️"

        let formattedString = numberFormatter.string(from: 0)
        XCTAssertEqual(formattedString, "⚽️")
        #endif // !SKIP
    }
    var unknownZero: Int = 0
    
    func test_notANumberSymbol() {
        let numberFormatter = NumberFormatter()
        numberFormatter.notANumberSymbol = "👽"
        let number: Double = -42.0
        let numberObject = NSNumber(value: sqrt(number))
        let formattedString = numberFormatter.string(from: numberObject)
        // different on some Android emulators ("-👽")
        if !isAndroid {
            XCTAssertEqual(formattedString, "👽")
        }
    }
    
    func test_positiveInfinitySymbol() {
        let numberFormatter = NumberFormatter()
        numberFormatter.positiveInfinitySymbol = "🚀"

        let numberObject = NSNumber(value: Double(42.0) / Double(0))
        let formattedString = numberFormatter.string(from: numberObject)
        XCTAssertEqual(formattedString, "🚀")
    }
    
    func test_minusSignSymbol() {
        let numberFormatter = NumberFormatter()
        numberFormatter.minusSign = "👎"
        let formattedString = numberFormatter.string(from: -42)

        #if SKIP
        // java.text.DecimalFormatSymbols's minusSign is a single `char`, which seems to be a problem for this emoji
        // testSkipModule(): java.lang.AssertionError: ?42 != 👎42
        throw XCTSkip("Skip shortcoming: minusSign")
        #endif
        XCTAssertEqual(formattedString, "👎42")

    }
    
    func test_plusSignSymbol() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // ex. 1.0E+1 in scientific notation
        let numberFormatter = NumberFormatter()
        let format = "#E+0"
//        numberFormatter.format = format
//        XCTAssertEqual(numberFormatter.positiveFormat, "#E+0")
//        XCTAssertEqual(numberFormatter.negativeFormat, "-#E+0")
//#if false && !DARWIN_COMPATIBILITY_TESTS
//        XCTAssertEqual(numberFormatter.zeroSymbol, "0E+0")
//        XCTAssertEqual(numberFormatter.format, "#E+0;0E+0;-#E+0")
//        XCTAssertEqual(numberFormatter.string(from: 0), "0E+0")
//#else
//        XCTAssertEqual(numberFormatter.zeroSymbol, "1E-100")
//        XCTAssertEqual(numberFormatter.format, "#E+0;1E-100;-#E+0")
//        XCTAssertEqual(numberFormatter.string(from: 0), "1E-100")
//#endif
//        XCTAssertEqual(numberFormatter.plusSign, "+")
//        let sign = "👍"
//        numberFormatter.plusSign = sign
//        XCTAssertEqual(numberFormatter.plusSign, sign)
//
//        let formattedString = numberFormatter.string(from: 420000000000000000)
//        XCTAssertNotNil(formattedString)
//        XCTAssertEqual(formattedString, "4.2E👍17")
//
//        // Verify a negative exponent does not have the 👍
//        let noPlusString = numberFormatter.string(from: -0.420)
//        XCTAssertNotNil(noPlusString)
//        if let fmt = noPlusString {
//            let contains: Bool = fmt.contains(sign)
//            XCTAssertFalse(contains, "Expected format of -0.420 (-4.2E-1) shouldn't have a plus sign which was set as \(sign)")
//        }
        #endif // !SKIP
    }

    func test_currencySymbol() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencySymbol = "🍯"
        numberFormatter.currencyDecimalSeparator = "_"
//        XCTAssertEqual(numberFormatter.format, "¤#,##0.00;🍯0_00;¤#,##0.00")
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "🍯42_00")
    }
    
    func test_exponentSymbol() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.scientific
        numberFormatter.exponentSymbol = "⬆️"
#if true || DARWIN_COMPATIBILITY_TESTS
//        XCTAssertEqual(numberFormatter.format, "#E0;1⬆️-100;#E0")
#else
//        XCTAssertEqual(numberFormatter.format, "#E0;0⬆️0;#E0")
#endif
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "4.2⬆️1")
    }
    
    func test_decimalMinimumIntegerDigits() {
        let numberFormatter1 = NumberFormatter()
        XCTAssertEqual(numberFormatter1.minimumIntegerDigits, 1)
        numberFormatter1.minimumIntegerDigits = 3
        numberFormatter1.numberStyle = NumberFormatter.Style.decimal
        #if SKIP
        numberFormatter1.minimumIntegerDigits = 3
        #endif
        XCTAssertEqual(numberFormatter1.minimumIntegerDigits, 3)

        let numberFormatter = NumberFormatter()
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        #if SKIP
        numberFormatter.minimumIntegerDigits = 1
        #endif
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 1)
        numberFormatter.minimumIntegerDigits = 3
        var formattedString = numberFormatter.string(from: 0)
        XCTAssertEqual(formattedString, "000")

        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        #if SKIP
        numberFormatter.minimumIntegerDigits = 3
        #endif
        XCTAssertEqual(numberFormatter.minimumIntegerDigits, 3)
        formattedString = numberFormatter.string(from: 0.1)
        XCTAssertEqual(formattedString, "000.1")
    }

    func test_currencyMinimumIntegerDigits() {
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.currency
        #if SKIP
        formatter.minimumIntegerDigits = 0
        #endif
        XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        formatter.locale = Locale(identifier: "en_US")
        #if !SKIP // currency not showig up for some reason
        XCTAssertEqual(formatter.string(from: 0), "$.00")
        XCTAssertEqual(formatter.string(from: 1.23), "$1.23")
        XCTAssertEqual(formatter.string(from: 123.4), "$123.40")
        #endif

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        formatter2.locale = Locale(identifier: "en_GB")
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.currency
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.locale = Locale(identifier: "en_US")
        #if !SKIP // currency not showig up for some reason
        XCTAssertEqual(formatter2.string(from: 0.001), "$0.00")
        XCTAssertEqual(formatter2.string(from: 1.234), "$1.23")
        XCTAssertEqual(formatter2.string(from: 123456.7), "$123,456.70")
        #endif
    }

    func test_percentMinimumIntegerDigits() {
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.percent
        #if SKIP
        formatter.minimumIntegerDigits = 0
        #endif
        //XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        formatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter.string(from: 0), "0%")
        XCTAssertEqual(formatter.string(from: 1.234), "123%")
        XCTAssertEqual(formatter.string(from: 123.4), "12,340%")

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.percent
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter2.string(from: 0.01), "1%")
        XCTAssertEqual(formatter2.string(from: 1.234), "123%")
        XCTAssertEqual(formatter2.string(from: 123456.7), "12,345,670%")
    }

    func test_scientificMinimumIntegerDigits() {
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.scientific
        #if !SKIP
        XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        #endif
        formatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter.string(from: 0), "0E0")
        XCTAssertEqual(formatter.string(from: 1.23), "1.23E0")
        XCTAssertEqual(formatter.string(from: 123.4), "1.234E2")

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.scientific
#if !SKIP
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
#endif
        formatter2.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter2.string(from: 0.01), "1E-2")
        XCTAssertEqual(formatter2.string(from: 1.234), "1.234E0")
        XCTAssertEqual(formatter2.string(from: 123456.7), "1.234567E5")
    }

    func test_spellOutMinimumIntegerDigits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        formatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter.string(from: 0), "zero")
        XCTAssertEqual(formatter.string(from: 1.23), "one point two three")
        XCTAssertEqual(formatter.string(from: 123.4), "one hundred twenty-three point four")

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(formatter2.minimumIntegerDigits, 0)
        formatter2.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter2.string(from: 0.01), "zero point zero one")
        XCTAssertEqual(formatter2.string(from: 1.234), "one point two three four")
        XCTAssertEqual(formatter2.string(from: 123456.7), "one hundred twenty-three thousand four hundred fifty-six point seven")
        #endif // !SKIP
    }

    func test_ordinalMinimumIntegerDigits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.ordinal
        XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        formatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter.string(from: 0), "0th")
        XCTAssertEqual(formatter.string(from: 1.23), "1st")
        XCTAssertEqual(formatter.string(from: 123.4), "123rd")

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.ordinal
        XCTAssertEqual(formatter2.minimumIntegerDigits, 0)
        formatter2.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter2.string(from: 0.01), "0th")
        XCTAssertEqual(formatter2.string(from: 4.234), "4th")
        XCTAssertEqual(formatter2.string(from: 42), "42nd")
        #endif // !SKIP
    }

    func test_currencyPluralMinimumIntegerDigits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.currencyPlural
        XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        formatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter.string(from: 0), "0.00 US dollars")
        XCTAssertEqual(formatter.string(from: 1.23), "1.23 US dollars")
        XCTAssertEqual(formatter.string(from: 123.4), "123.40 US dollars")

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.currencyPlural
        XCTAssertEqual(formatter2.minimumIntegerDigits, 0)
        formatter2.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter2.string(from: 0.01), "0.01 US dollars")
        XCTAssertEqual(formatter2.string(from: 1.234), "1.23 US dollars")
        XCTAssertEqual(formatter2.string(from: 123456.7), "123,456.70 US dollars")
        #endif // !SKIP
    }

    func test_currencyISOCodeMinimumIntegerDigits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.currencyISOCode
        XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        formatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter.string(from: 0), "USD.00")
        XCTAssertEqual(formatter.string(from: 1.23), "USD\(currencySpacing)1.23")
        XCTAssertEqual(formatter.string(from: 123.4), "USD\(currencySpacing)123.40")

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.currencyISOCode
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter2.string(from: 0.01), "USD\(currencySpacing)0.01")
        XCTAssertEqual(formatter2.string(from: 1.234), "USD\(currencySpacing)1.23")
        XCTAssertEqual(formatter2.string(from: 123456.7), "USD\(currencySpacing)123,456.70")
        #endif // !SKIP
    }

    func test_currencyAccountingMinimumIntegerDigits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // If .minimumIntegerDigits is set to 0 before .numberStyle change, preserve the value
        let formatter = NumberFormatter()
        XCTAssertEqual(formatter.minimumIntegerDigits, 1)
        formatter.minimumIntegerDigits = 0
        formatter.numberStyle = NumberFormatter.Style.currencyAccounting
        XCTAssertEqual(formatter.minimumIntegerDigits, 0)
        formatter.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter.string(from: 0), "$.00")
        XCTAssertEqual(formatter.string(from: 1.23), "$1.23")
        XCTAssertEqual(formatter.string(from: 123.4), "$123.40")

        // If .minimumIntegerDigits is not set before .numberStyle change, update the value
        let formatter2 = NumberFormatter()
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.numberStyle = NumberFormatter.Style.currencyAccounting
        XCTAssertEqual(formatter2.minimumIntegerDigits, 1)
        formatter2.locale = Locale(identifier: "en_US")
        XCTAssertEqual(formatter2.string(from: 0), "$0.00")
        XCTAssertEqual(formatter2.string(from: 1.23), "$1.23")
        XCTAssertEqual(formatter2.string(from: 123.4), "$123.40")
        #endif // !SKIP
    }

    func test_maximumIntegerDigits() {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumIntegerDigits = 3
        numberFormatter.minimumIntegerDigits = 3
        let formattedString = numberFormatter.string(from: 1_000)
        XCTAssertEqual(formattedString, "000")
    }
    
    func test_minimumFractionDigits() {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 3
        numberFormatter.decimalSeparator = "-"
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "42-000")
    }
    
    func test_maximumFractionDigits() {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 3
        numberFormatter.decimalSeparator = "-"
        let formattedString = numberFormatter.string(from: 42.4242)
        XCTAssertEqual(formattedString, "42-424")
    }
    
    func test_groupingSize() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        XCTAssertEqual(numberFormatter.groupingSize, 0)
        numberFormatter.groupingSize = 4
        numberFormatter.groupingSeparator = "_"
        numberFormatter.usesGroupingSeparator = true
        let formattedString = numberFormatter.string(from: 42_000)
        XCTAssertEqual(formattedString, "4_2000")
        #endif // !SKIP
    }
    
    func test_secondaryGroupingSize() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSize = 3
        numberFormatter.secondaryGroupingSize = 2
        numberFormatter.groupingSeparator = "_"
        numberFormatter.usesGroupingSeparator = true
        let formattedString = numberFormatter.string(from: 42_000_000)
        XCTAssertEqual(formattedString, "4_20_00_000")
        #endif // !SKIP
    }
    
    func test_roundingMode() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.roundingMode = .ceiling
        let formattedString = numberFormatter.string(from: 41.0001)
        XCTAssertEqual(formattedString, "42")
        #endif // !SKIP
    }
    
    func test_roundingIncrement() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.roundingIncrement = 0.2
        let formattedString = numberFormatter.string(from: 4.25)
        XCTAssertEqual(formattedString, "4.2")
        #endif // !SKIP
    }
    
    func test_formatWidth() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.paddingCharacter = "_"
        numberFormatter.formatWidth = 5
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "___42")
        #endif // !SKIP
    }
    
    func test_formatPosition() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.paddingCharacter = "_"
        numberFormatter.formatWidth = 5
        numberFormatter.paddingPosition = .afterPrefix
        let formattedString = numberFormatter.string(from: -42)
        XCTAssertEqual(formattedString, "-__42")
        #endif // !SKIP
    }
    
    func test_multiplier() {
        let numberFormatter = NumberFormatter()
        numberFormatter.multiplier = 2 as NSNumber
        let formattedString = numberFormatter.string(from: 21)
        XCTAssertEqual(formattedString, "42")
    }
    
    func test_positivePrefix() {
        let numberFormatter = NumberFormatter()
        numberFormatter.positivePrefix = "👍"
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "👍42")
    }
    
    func test_positiveSuffix() {
        let numberFormatter = NumberFormatter()
        numberFormatter.positiveSuffix = "👍"
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "42👍")
    }
    
    func test_negativePrefix() {
        let numberFormatter = NumberFormatter()
        numberFormatter.negativePrefix = "👎"
        let formattedString = numberFormatter.string(from: -42)
        XCTAssertEqual(formattedString, "👎42")
    }
    
    func test_negativeSuffix() {
        let numberFormatter = NumberFormatter()
        numberFormatter.negativeSuffix = "👎"
        let formattedString = numberFormatter.string(from: -42)
        XCTAssertEqual(formattedString, "-42👎")
    }
    
    func test_internationalCurrencySymbol() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // What does internationalCurrencySymbol actually do?
#if false
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyPlural
        numberFormatter.internationalCurrencySymbol = "💵"
        numberFormatter.currencyDecimalSeparator = "_"
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "💵42_00")
#endif
        #endif // !SKIP
    }
    
    func test_currencyGroupingSeparator() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_GB")
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencyGroupingSeparator = "_"
        numberFormatter.currencyCode = "T"
        numberFormatter.currencyDecimalSeparator = "/"
        let formattedString = numberFormatter.string(from: 42_000)
        XCTAssertEqual(formattedString, "£42_000/00")

        #endif // !SKIP
    }

    func test_lenient() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        // Not lenient by default
        XCTAssertFalse(numberFormatter.isLenient)

        // Lenient allows wrong style -- not lenient here
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.numberStyle, .spellOut)
//        let nilNumber = numberFormatter.number(from: "2.22")
        // FIXME: Not nil on Linux?
        //XCTAssertNil(nilNumber)
        // Lenient allows wrong style
        numberFormatter.isLenient = true
        XCTAssertTrue(numberFormatter.isLenient)
        let number = numberFormatter.number(from: "2.22")
        XCTAssertEqual(number, 2.22)

        // TODO: Add some tests with currency after [SR-250] resolved
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.isLenient = false
        let nilNumberBeforeLenient = numberFormatter.number(from: "42")

        XCTAssertNil(nilNumberBeforeLenient)
        numberFormatter.isLenient = true
        let numberAfterLenient = numberFormatter.number(from: "42.42")
        XCTAssertEqual(numberAfterLenient, 42.42)
        #endif // !SKIP
    }
    
    func test_minimumSignificantDigits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, -1)
        numberFormatter.minimumSignificantDigits = 3
        XCTAssertEqual(numberFormatter.maximumSignificantDigits, 999)
        let formattedString = numberFormatter.string(from: 42)
        XCTAssertEqual(formattedString, "42.0")
        #endif // !SKIP
    }
    
    func test_maximumSignificantDigits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        var formattedString = numberFormatter.string(from: 987654321)
        XCTAssertEqual(formattedString, "987,654,321")
        
        numberFormatter.usesSignificantDigits = true
        numberFormatter.maximumSignificantDigits = 3
        formattedString = numberFormatter.string(from: 42.42424242)
        XCTAssertEqual(formattedString, "42.4")
        #endif // !SKIP
    }

    func test_stringFor() {
        let numberFormatter = NumberFormatter()
        XCTAssertEqual(numberFormatter.string(for: 10)!, "10")
        XCTAssertEqual(numberFormatter.string(for: 3.14285714285714)!, "3")
        XCTAssertEqual(numberFormatter.string(for: true)!, "1")
        XCTAssertEqual(numberFormatter.string(for: false)!, "0")
        XCTAssertNil(numberFormatter.string(for: [1,2]))
        XCTAssertEqual(numberFormatter.string(for: NSNumber(value: 99.1))!, "99")
        XCTAssertNil(numberFormatter.string(for: "NaN"))
        XCTAssertNil(numberFormatter.string(for: NSString(string: "NaN")))

        #if SKIP
        throw XCTSkip("TODO: NumberFormatter.numberStyle = .spellOut")
        #else
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.string(for: 234), "two hundred thirty-four")
        XCTAssertEqual(numberFormatter.string(for: 2007), "two thousand seven")
        XCTAssertEqual(numberFormatter.string(for: 3), "three")
        XCTAssertEqual(numberFormatter.string(for: 0.3), "zero point three")

        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        XCTAssertEqual(numberFormatter.string(for: 234.5678), "234.568")
        
        numberFormatter.locale = Locale(identifier: "zh_CN")
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.string(from: 11.4), "十一点四")

        numberFormatter.locale = Locale(identifier: "fr_FR")
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.string(from: 11.4), "onze virgule quatre")

        #endif // !SKIP
    }

    func test_numberFrom() {
        let numberFormatter = NumberFormatter()
        #if SKIP
        XCTAssertEqual(numberFormatter.number(from: "10"), 10.toLong())
        #else
        XCTAssertEqual(numberFormatter.number(from: "10"), 10)
        #endif

        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(numberFormatter.number(from: "3.14"), 3.14)
        XCTAssertEqual(numberFormatter.number(from: "0.01"), 0.01)
        XCTAssertEqual(numberFormatter.number(from: ".01"), 0.01)
        // These don't work unless lenient/style set
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        XCTAssertEqual(numberFormatter.number(from: "1,001"), 1001)
        XCTAssertEqual(numberFormatter.number(from: "1,050,001"), 1050001)

        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.number(from: "two thousand and seven"), 2007)
        XCTAssertEqual(numberFormatter.number(from: "one point zero"), 1.0)
        XCTAssertEqual(numberFormatter.number(from: "one hundred million"), 1E8)

        numberFormatter.locale = Locale(identifier: "zh_CN")
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.number(from: "十一点四"), 11.4)

        numberFormatter.locale = Locale(identifier: "fr_FR")
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        XCTAssertEqual(numberFormatter.number(from: "onze virgule quatre"), 11.4)
        #endif // !SKIP
    }

    func test_en_US_initialValues() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Symbols should be extractable
        // At one point, none of this passed!

        let numberFormatter = NumberFormatter();
        numberFormatter.locale = Locale(identifier: "en_US")

        // TODO: Check if this is true for all versions...

        XCTAssertEqual(numberFormatter.plusSign, "+")
        XCTAssertEqual(numberFormatter.minusSign, "-")
        XCTAssertEqual(numberFormatter.decimalSeparator, ".")
        XCTAssertEqual(numberFormatter.groupingSeparator, ",")
        XCTAssertEqual(numberFormatter.nilSymbol, "")
        XCTAssertEqual(numberFormatter.notANumberSymbol, "NaN")
        XCTAssertEqual(numberFormatter.positiveInfinitySymbol, "+∞")
        XCTAssertEqual(numberFormatter.negativeInfinitySymbol, "-∞")
        XCTAssertEqual(numberFormatter.positivePrefix, "")
        XCTAssertEqual(numberFormatter.negativePrefix, "-")
        XCTAssertEqual(numberFormatter.positiveSuffix, "")
        XCTAssertEqual(numberFormatter.negativeSuffix, "")
        XCTAssertEqual(numberFormatter.percentSymbol, "%")
        XCTAssertEqual(numberFormatter.perMillSymbol, "‰")
        XCTAssertEqual(numberFormatter.exponentSymbol, "E")
        XCTAssertEqual(numberFormatter.groupingSeparator, ",")
        XCTAssertEqual(numberFormatter.paddingCharacter, " ")
        XCTAssertEqual(numberFormatter.currencyCode, "USD")
        XCTAssertEqual(numberFormatter.currencySymbol, "$")
        XCTAssertEqual(numberFormatter.currencyDecimalSeparator, ".")
        XCTAssertEqual(numberFormatter.currencyGroupingSeparator, ",")
        XCTAssertEqual(numberFormatter.internationalCurrencySymbol, "USD")
        XCTAssertNil(numberFormatter.zeroSymbol)
        #endif // !SKIP
    }

    func test_pt_BR_initialValues() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let numberFormatter = NumberFormatter();
        numberFormatter.locale = Locale(identifier: "pt_BR")

        XCTAssertEqual(numberFormatter.plusSign, "+")
        XCTAssertEqual(numberFormatter.minusSign, "-")
        XCTAssertEqual(numberFormatter.decimalSeparator, ",")
        XCTAssertEqual(numberFormatter.groupingSeparator, ".")
        XCTAssertEqual(numberFormatter.nilSymbol, "")
        XCTAssertEqual(numberFormatter.notANumberSymbol, "NaN")
        XCTAssertEqual(numberFormatter.positiveInfinitySymbol, "+∞")
        XCTAssertEqual(numberFormatter.negativeInfinitySymbol, "-∞")
        XCTAssertEqual(numberFormatter.positivePrefix, "")
        XCTAssertEqual(numberFormatter.negativePrefix, "-")
        XCTAssertEqual(numberFormatter.positiveSuffix, "")
        XCTAssertEqual(numberFormatter.negativeSuffix, "")
        XCTAssertEqual(numberFormatter.percentSymbol, "%")
        XCTAssertEqual(numberFormatter.perMillSymbol, "‰")
        XCTAssertEqual(numberFormatter.exponentSymbol, "E")
        XCTAssertEqual(numberFormatter.groupingSeparator, ".")
        XCTAssertEqual(numberFormatter.paddingCharacter, " ")
        XCTAssertEqual(numberFormatter.currencyCode, "BRL")
        XCTAssertEqual(numberFormatter.currencySymbol, "R$")
        XCTAssertEqual(numberFormatter.currencyDecimalSeparator, ",")
        XCTAssertEqual(numberFormatter.currencyGroupingSeparator, ".")
        XCTAssertEqual(numberFormatter.internationalCurrencySymbol, "BRL")
        XCTAssertNil(numberFormatter.zeroSymbol)
        #endif // !SKIP
    }

    func test_changingLocale() {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "fr_FR")

        XCTAssertEqual(numberFormatter.currencyCode, "EUR")
        XCTAssertEqual(numberFormatter.currencySymbol, "€")
        numberFormatter.currencySymbol = "E"
        XCTAssertEqual(numberFormatter.currencySymbol, "E")

        numberFormatter.locale = Locale(identifier: "fr_FR")
        #if !SKIP
        XCTAssertEqual(numberFormatter.currencySymbol, "E")
        #endif
        numberFormatter.locale = Locale(identifier: "en_GB")

        XCTAssertEqual(numberFormatter.currencyCode, "GBP")
        #if !SKIP
        XCTAssertEqual(numberFormatter.currencySymbol, "E")
        numberFormatter.currencySymbol = nil
        XCTAssertEqual(numberFormatter.currencySymbol, "£")
        #endif
    }

    func test_settingFormat() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let formatter = NumberFormatter()
#if !os(iOS)

        XCTAssertEqual(formatter.format, "#########################################0;0;#########################################0")
        XCTAssertEqual(formatter.positiveFormat, "#########################################0")
        XCTAssertEqual(formatter.zeroSymbol, nil)
        XCTAssertEqual(formatter.negativeFormat, "#########################################0")

        formatter.positiveFormat = "#"
        XCTAssertEqual(formatter.format, "#;0;0")
        XCTAssertEqual(formatter.positiveFormat, "#")
        XCTAssertEqual(formatter.zeroSymbol, nil)
        XCTAssertEqual(formatter.negativeFormat, "0")

        formatter.positiveFormat = "##.##"
        XCTAssertEqual(formatter.format, "##.##;0;0.##")
        XCTAssertEqual(formatter.positiveFormat, "##.##")
        XCTAssertEqual(formatter.zeroSymbol, nil)
        XCTAssertEqual(formatter.negativeFormat, "0.##")

        formatter.positiveFormat = "##;##"
        XCTAssertEqual(formatter.format, "##;##;0;0")
        XCTAssertEqual(formatter.positiveFormat, "##;##")
        XCTAssertEqual(formatter.zeroSymbol, nil)
        XCTAssertEqual(formatter.negativeFormat, "0")

        formatter.positiveFormat = "+#.#########"
//        XCTAssertEqual(formatter.format, "+#.#########;+0;+0.#########")
        XCTAssertEqual(formatter.positiveFormat, "+#.#########")
        XCTAssertEqual(formatter.zeroSymbol, nil)
//        XCTAssertEqual(formatter.negativeFormat, "+0.#########")

        formatter.negativeFormat = "-#.#########"
        XCTAssertEqual(formatter.format, "+#.#########;+0;-#.#########")
        XCTAssertEqual(formatter.positiveFormat, "+#.#########")
        XCTAssertEqual(formatter.zeroSymbol, nil)
        XCTAssertEqual(formatter.negativeFormat, "-#.#########")

        formatter.format = "+++#;000;---#.##"
        XCTAssertEqual(formatter.format, "+++#;000;---#.##")
        XCTAssertEqual(formatter.positiveFormat, "+++#")
        XCTAssertEqual(formatter.zeroSymbol, "000")
        XCTAssertEqual(formatter.negativeFormat, "---#.##")

        formatter.positiveFormat = nil
        XCTAssertEqual(formatter.positiveFormat, "0")
        XCTAssertEqual(formatter.format, "0;000;---#.##")

        formatter.zeroSymbol = "00"
        formatter.positiveFormat = "+++#.#"
        XCTAssertEqual(formatter.format, "+++#.#;00;---#.##")
        XCTAssertEqual(formatter.positiveFormat, "+++#.#")
        XCTAssertEqual(formatter.zeroSymbol, "00")
        XCTAssertEqual(formatter.negativeFormat, "---#.##")

        formatter.negativeFormat = "---#.#"
        XCTAssertEqual(formatter.format, "+++#.#;00;---#.#")
        XCTAssertEqual(formatter.positiveFormat, "+++#.#")
        XCTAssertEqual(formatter.zeroSymbol, "00")
        XCTAssertEqual(formatter.negativeFormat, "---#.#")

        // Test setting only first 2 parts
        formatter.format = "+##.##;0.00"
#if false && !DARWIN_COMPATIBILITY_TESTS
        XCTAssertEqual(formatter.format, "+##.##;00;0.00")
        XCTAssertEqual(formatter.zeroSymbol, "00")
#else
        XCTAssertEqual(formatter.format, "+##.##;+0;0.00")
        XCTAssertEqual(formatter.zeroSymbol, "+0")
#endif
        XCTAssertEqual(formatter.positiveFormat, "+##.##")
        XCTAssertEqual(formatter.negativeFormat, "0.00")

        formatter.format = "+##.##;+0;0.00"
        XCTAssertEqual(formatter.format, "+##.##;+0;0.00")
        XCTAssertEqual(formatter.positiveFormat, "+##.##")
        XCTAssertEqual(formatter.zeroSymbol, "+0")
        XCTAssertEqual(formatter.negativeFormat, "0.00")

        formatter.format = "#;0;#"
        formatter.positiveFormat = "1"
        XCTAssertEqual(formatter.format, "1;0;#")
        XCTAssertEqual(formatter.positiveFormat, "1")
        XCTAssertEqual(formatter.zeroSymbol, "0")
        XCTAssertEqual(formatter.negativeFormat, "#")

        formatter.format = "1"
        XCTAssertEqual(formatter.format, "1;0;-1")
        XCTAssertEqual(formatter.positiveFormat, "1")
        XCTAssertEqual(formatter.zeroSymbol, "0")
        XCTAssertEqual(formatter.negativeFormat, "-1")

        formatter.format = "1;2;3"
        XCTAssertEqual(formatter.format, "1;2;3")
        XCTAssertEqual(formatter.positiveFormat, "1")
        XCTAssertEqual(formatter.zeroSymbol, "2")
        XCTAssertEqual(formatter.negativeFormat, "3")

        formatter.format = ""
        XCTAssertEqual(formatter.format, ";0;-")
        XCTAssertEqual(formatter.zeroSymbol, "0")
        XCTAssertEqual(formatter.positiveFormat, "")
        XCTAssertEqual(formatter.negativeFormat, "-")
#endif
        #endif // !SKIP
    }

    func test_usingFormat() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var formatter = NumberFormatter()

//        formatter.format = "+++#.#;00;-+-#.#"
//        XCTAssertEqual(formatter.string(from: 1), "+++1")
//        XCTAssertEqual(formatter.string(from: Int.max as NSNumber), "+++9223372036854775807")
//        XCTAssertEqual(formatter.string(from: 0), "00")
//        XCTAssertEqual(formatter.string(from: -1), "-+-1")
//        XCTAssertEqual(formatter.string(from: Int.min as NSNumber), "-+-9223372036854775808")
//
//
//        formatter.format = "+#.##;0.00;-#.##"
//        XCTAssertEqual(formatter.string(from: 0.5), "+0.5")
//        XCTAssertEqual(formatter.string(from: 0), "0.00")
//        XCTAssertEqual(formatter.string(from: -0.2), "-0.2")
//
//        formatter.positiveFormat = "#.##"
//        formatter.negativeFormat = "-#.##"
//        XCTAssertEqual(formatter.string(from: NSNumber(value: Double.pi)), "3.14")
//        XCTAssertEqual(formatter.string(from: NSNumber(value: -Double.pi)), "-3.14")
//
//        formatter = NumberFormatter()
//        formatter.negativeFormat = "--#.##"
//        XCTAssertEqual(formatter.string(from: NSNumber(value: -Double.pi)), "--3")
//        formatter.positiveFormat = "#.###"
//        XCTAssertEqual(formatter.string(from: NSNumber(value: Double.pi)), "3.142")
//
//        formatter.positiveFormat = "#.####"
//        XCTAssertEqual(formatter.string(from: NSNumber(value: Double.pi)), "3.1416")
//
//        formatter.positiveFormat = "#.#####"
//        XCTAssertEqual(formatter.string(from: NSNumber(value: Double.pi)), "3.14159")
//
//        formatter = NumberFormatter()
//        formatter.positiveFormat = "#.#########"
//        formatter.negativeFormat = "#.#########"
//        XCTAssertEqual(formatter.string(from: NSNumber(value: 0.5)), "0.5")
//        XCTAssertEqual(formatter.string(from: NSNumber(value: -0.5)), "0.5")
//        formatter.negativeFormat = "-#.#########"
//        XCTAssertEqual(formatter.string(from: NSNumber(value: -0.5)), "-0.5")
        #endif // !SKIP
    }

    func test_propertyChanges() {
        let formatter = NumberFormatter()
        #if !SKIP
        XCTAssertNil(formatter.multiplier)
        #endif
        formatter.numberStyle = NumberFormatter.Style.percent
        XCTAssertEqual(formatter.multiplier, NSNumber(100))
        formatter.numberStyle = NumberFormatter.Style.decimal
        #if !SKIP
        XCTAssertNil(formatter.multiplier)
        #endif
        formatter.multiplier = NSNumber(1)
        formatter.numberStyle = NumberFormatter.Style.percent
        #if !SKIP
        XCTAssertEqual(formatter.multiplier, NSNumber(1))
        #endif
        formatter.multiplier = NSNumber(27)
        formatter.numberStyle = NumberFormatter.Style.decimal
        #if !SKIP
        XCTAssertEqual(formatter.multiplier, NSNumber(27))
        #endif
    }

    func test_scientificStrings() {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.scientific
        formatter.positiveInfinitySymbol = ".inf"
        #if !SKIP
        // Android DecimalFormatSymbols only has positive infinity
        formatter.negativeInfinitySymbol = "-.inf"
        #endif
        formatter.notANumberSymbol = ".nan"
        #if SKIP
        // XCTAssertEqual(formatter.string(for: Double.infinity), ".infE0") // ".infE0" on Robolectric, ".inf" on Android
        #else
        XCTAssertEqual(formatter.string(for: Double.infinity), ".inf")
        #endif
        #if !SKIP
        XCTAssertEqual(formatter.string(for: -1 * Double.infinity), "-.inf")
        #endif
        #if SKIP
        //XCTAssertEqual(formatter.string(for: Double.nan), ".nanE0")
        #else
        XCTAssertEqual(formatter.string(for: Double.nan), ".nan")
        #endif
#if (arch(i386) || arch(x86_64)) && !(os(Android) || os(Windows))
        XCTAssertNil(formatter.string(for: Float80.infinity))
#endif
    }

    func test_copy() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let original = NumberFormatter()
        let copied = try XCTUnwrap(original.copy() as? NumberFormatter)
        XCTAssertFalse(original === copied)

        func __assert<T>(_ property: KeyPath<NumberFormatter, T>,
                         original expectedValueOfOriginalFormatter: T,
                         copy expectedValueOfCopiedFormatter: T,
                         file: StaticString = #file,
                         line: UInt = #line) where T: Equatable {
            XCTAssertEqual(original[keyPath: property], expectedValueOfOriginalFormatter,
                           "Unexpected value in `original`.", file: file, line: line)
            XCTAssertEqual(copied[keyPath: property], expectedValueOfCopiedFormatter,
                           "Unexpected value in `copied`.", file: file, line: line)
        }

        copied.numberStyle = NumberFormatter.Style.decimal
        __assert(\.numberStyle, original: .none, copy: .decimal)
        __assert(\.maximumIntegerDigits, original: 42, copy: 2_000_000_000)
        __assert(\.maximumFractionDigits, original: 0, copy: 3)
        __assert(\.groupingSize, original: 0, copy: 3)

        original.numberStyle = NumberFormatter.Style.percent
        original.percentSymbol = "％"
        __assert(\.numberStyle, original: .percent, copy: .decimal)
//        __assert(\.format, original: "#,##0%;0％;#,##0%", copy: "#,##0.###;0;#,##0.###")
        #endif // !SKIP
    }

    func testStaticLocalizedString() {
        //XCTAssertEqual("12346", NumberFormatter.localizedString(from: 12345.678 as NSNumber, number: .none))
        XCTAssertEqual("12,345.678", NumberFormatter.localizedString(from: 12345.678 as NSNumber, number: .decimal))
        XCTAssertEqual("1,234,568%", NumberFormatter.localizedString(from: 12345.678 as NSNumber, number: .percent))
        XCTAssertEqual("$12,345.68", NumberFormatter.localizedString(from: 12345.678 as NSNumber, number: .currency))
        XCTAssertEqual("1.2345678E4", NumberFormatter.localizedString(from: 12345.678 as NSNumber, number: .scientific))
        //XCTAssertEqual("", NumberFormatter.localizedString(from: 12.345 as NSNumber, number: .spellOut))
        //XCTAssertEqual("", NumberFormatter.localizedString(from: 12.345 as NSNumber, number: .ordinal))
    }
}


