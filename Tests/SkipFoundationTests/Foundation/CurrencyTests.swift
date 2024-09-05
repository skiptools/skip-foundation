// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
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
            XCTAssertTrue(currency.isISOCurrency)
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
