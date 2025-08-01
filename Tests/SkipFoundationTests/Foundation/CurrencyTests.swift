// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

@available(macOS 13, iOS 16, watchOS 10, tvOS 16, *)
final class CurrencyTests: XCTestCase {

    func testUSD() throws {
        let usd = Locale.Currency("USD")
        let usdLiteral: Locale.Currency = "USD"

        XCTAssertEqual(usd, usdLiteral)
        XCTAssertEqual(usd.identifier, "USD")
        XCTAssertTrue(usd.isISOCurrency)
    }

    func testCommonCurrencies() throws {
        for currencyCode in Locale.commonISOCurrencyCodes {
            let currency = Locale.Currency(currencyCode)
            XCTAssertEqual(currency.identifier, currencyCode)
            #if SKIP
            XCTAssertTrue(currency.isISOCurrency)
            #endif
        }
    }

    func testIsoCurrencies() throws {
        let isoCurrencies = Locale.Currency.isoCurrencies

        let currencyCodes = isoCurrencies.map { $0.identifier }
        XCTAssertEqual(Set(currencyCodes).sorted(), currencyCodes)
        #if SKIP
        for currency in isoCurrencies {
            XCTAssertTrue(currency.isISOCurrency)
        }
        #endif
    }

}
