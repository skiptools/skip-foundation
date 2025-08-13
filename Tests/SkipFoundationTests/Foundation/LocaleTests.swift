// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

#if SKIP || canImport(Darwin)

@available(macOS 13, iOS 16, watchOS 10, tvOS 16, *)
final class LocaleTests: XCTestCase {
    func testLanguageCodes() throws {
        let fr = Locale(identifier: "fr_FR")
        XCTAssertNotNil(fr)
        //logger.info("fr_FR: \(fr.identifier)")

        XCTAssertEqual("fr_FR", fr.identifier)

        XCTAssertEqual("€", Locale(identifier: "fr_FR").currencySymbol)
        XCTAssertEqual("EUR", Locale(identifier: "fr_FR").currency?.identifier)

        XCTAssertEqual("€", Locale(identifier: "pt_PT").currencySymbol)
        #if SKIP
        //XCTAssertEqual("R", Locale(identifier: "pt_BR").currencySymbol)
        #else
        //XCTAssertEqual("R$", Locale(identifier: "pt_BR").currencySymbol)
        #endif

        XCTAssertEqual("¥", Locale(identifier: "jp_JP").currencySymbol)
        XCTAssertEqual("JPY", Locale(identifier: "jp_JP").currency?.identifier)

        XCTAssertEqual("¤", Locale(identifier: "zh_ZH").currencySymbol)
        // XCTAssertEqual(nil, Locale(identifier: "zh_ZH").currency?.identifier) // nil on Darwin, "XXX" on Java

        #if SKIP
        //XCTAssertEqual("", Locale(identifier: "en_US").currencySymbol)
        #else
        //XCTAssertEqual("$", Locale(identifier: "en_US").currencySymbol)
        #endif

        //XCTAssertEqual("fr", fr.languageCode)

        XCTAssertEqual("anglais", fr.localizedString(forLanguageCode: "en"))
        XCTAssertEqual("français", fr.localizedString(forLanguageCode: "fr"))
        XCTAssertEqual("chinois", fr.localizedString(forLanguageCode: "zh"))

        let zh = Locale(identifier: "zh_HK")
        //logger.info("zh_HK: \(zh.identifier)")
        XCTAssertNotNil(zh)

        XCTAssertEqual("zh_HK", zh.identifier)

        //XCTAssertEqual("zh_HK", zh.identifier)
        //XCTAssertEqual("zh", zh.languageCode)

        //XCTAssertEqual("法文", zh.localizedString(forLanguageCode: "fr"))
        //XCTAssertEqual("英文", zh.localizedString(forLanguageCode: "en"))
        //XCTAssertEqual("中文", zh.localizedString(forLanguageCode: "zh"))

        //XCTAssertEqual(["en", "fr"], Bundle.module.localizations.sorted())

        //let foundationBundle = Bundle.module

        //let localeIdentifiers = foundationBundle.localizations.sorted()

        #if !SKIP
        //XCTAssertEqual(["ar", "ca", "cs", "da", "de", "el", "en", "en_AU", "en_GB", "es", "es_419", "fa", "fi", "fr", "fr_CA", "he", "hi", "hr", "hu", "id", "it", "ja", "ko", "ms", "nl", "no", "pl", "pt", "pt_PT", "ro", "ru", "sk", "sv", "th", "tr", "uk", "vi", "zh-Hans", "zh-Hant"], localeIdentifiers)
        #endif
    }

    func testLocalizableStringsParsing() throws {
        let locstr = #"""
        /* French Localizable.strings */

        "Yes" = "Oui";
        "The \"same\" text in English" = "Le \"même\" texte en anglais";

        "welcome_message" = "Bienvenue dans notre application!";
        "app_description" = "Une application géniale pour votre quotidien.";

        "error_title" = "Erreur";
        "error_message" = "Une erreur est survenue. Veuillez réessayer plus tard.";

        "multiline_text" = "Ceci est une ligne.\nEt voici une autre ligne.\nUne troisième ligne ici.";

        "quoted_strings" = "C'est une \"chaîne\" avec des guillemets.";
        /* "escaped_quotes" = "Ceci a des guillemets simples \\'et doubles \\"; */

        "parameter_example" = "Bonjour, %@! Aujourd'hui est le %@.";

        "parameter_order" = "Le %@ est dans l'ordre.";

        /* "unicode_example" = "Voici quelques caractères Unicode : \u{1F604} \u{2764}"; */

        "nested_parameters" = "Bienvenue, %@! Vous êtes dans %@.";
        """#

        let data = try XCTUnwrap(locstr.data(using: String.Encoding.utf8, allowLossyConversion: false))
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)

        // SKIP NOWARN
        let dict = try XCTUnwrap(plist as? Dictionary<String, String>)

        XCTAssertEqual(11, dict.count)

        XCTAssertEqual(dict, [
            "Yes": "Oui",
            "The \"same\" text in English": "Le \"même\" texte en anglais",

            "welcome_message": "Bienvenue dans notre application!",
            "app_description": "Une application géniale pour votre quotidien.",

            "error_title": "Erreur",
            "error_message": "Une erreur est survenue. Veuillez réessayer plus tard.",

            "multiline_text": "Ceci est une ligne.\nEt voici une autre ligne.\nUne troisième ligne ici.",

            "quoted_strings": "C'est une \"chaîne\" avec des guillemets.",
            //"escaped_quotes": "Ceci a des guillemets simples \\'et doubles \\",

            "parameter_example": "Bonjour, %@! Aujourd'hui est le %@.",

            "parameter_order": "Le %@ est dans l'ordre.",

            //"unicode_example": "Voici quelques caractères Unicode : \u{1F604} \u{2764}",

            "nested_parameters": "Bienvenue, %@! Vous êtes dans %@.",
        ])
    }

    func testLocaleFormats() throws {
        #if !SKIP
        // TODO
        XCTAssertEqual("$0.40", 0.4.formatted(.currency(code: "USD")))
        XCTAssertEqual("€1,234,567.89", 1234567.89.formatted(.currency(code: "EUR")))
        XCTAssertEqual("1,234", 1234.formatted(.number))

        XCTAssertEqual("1 kB", 1234.formatted(.byteCount(style: .binary)))
        XCTAssertEqual("123 kB", 123456.formatted(.byteCount(style: .decimal)))
        XCTAssertEqual("1.2 MB", 1234567.formatted(.byteCount(style: .file)))
        XCTAssertEqual("1.15 GB", 1234567890.formatted(.byteCount(style: .memory)))

        XCTAssertEqual("Zero kB", 0.formatted(.byteCount(style: .binary, spellsOutZero: true)))
        XCTAssertEqual("1 kB (1,234 bytes)", 1234.formatted(.byteCount(style: .binary, allowedUnits: .kb, spellsOutZero: true, includesActualByteCount: true)))

        XCTAssertEqual("1,234", 1234.formatted(.number))
        XCTAssertEqual("45.678%", 0.45678.formatted(.percent))

        XCTAssertEqual("1 234", 1234.formatted(.number.locale(Locale(identifier: "fr"))))
        XCTAssertEqual("1 234,567", 1234.567.formatted(.number.locale(Locale(identifier: "fr"))))

        XCTAssertEqual("1,234", 1234.formatted(.number.locale(Locale(identifier: "en_US"))))
        XCTAssertEqual("1,234.567", 1234.567.formatted(.number.locale(Locale(identifier: "en_US"))))

        XCTAssertEqual("A, B, and C", ["A", "B", "C"].formatted())
        XCTAssertEqual("1, 2.3 et 3.4567", [1, 2.3, 3.4567].formatted(.list(memberStyle: .number, type: .and).locale(Locale(identifier: "fr"))))
        XCTAssertEqual("1、2.3、3.4567", [1, 2.3, 3.4567].formatted(.list(memberStyle: .number, type: .and).locale(Locale(identifier: "ja"))))
        XCTAssertEqual("A, B, or C", ["A", "B", "C"].formatted(.list(type: .or)))
        XCTAssertEqual("A, B ou C", ["A", "B", "C"].formatted(.list(type: .or).locale(Locale(identifier: "fr"))))

        XCTAssertEqual("A、B、またはC", ["A", "B", "C"].formatted(.list(type: .or).locale(Locale(identifier: "ja"))))
        XCTAssertEqual("A、B、C", ["A", "B", "C"].formatted(.list(type: .and).locale(Locale(identifier: "ja"))))

        // inconsistent due to different time zones in CI runner

        //XCTAssertEqual("15:00", (Date(timeIntervalSince1970: 100)..<Date(timeIntervalSince1970: 1000)).formatted(.timeDuration))
        //
        //XCTAssertEqual("12/31/1969, 19:01", Date(timeIntervalSince1970: 100).formatted())
        //XCTAssertEqual("Dec 31, 1969", Date(timeIntervalSince1970: 100).formatted(date: .abbreviated, time: .omitted))
        //
        //XCTAssertEqual("Wednesday, December 31, 1969", Date(timeIntervalSince1970: 100).formatted(date: .complete, time: .omitted))
        //XCTAssertEqual("December 31, 1969", Date(timeIntervalSince1970: 100).formatted(date: .long, time: .omitted))
        //XCTAssertEqual("12/31/1969", Date(timeIntervalSince1970: 100).formatted(date: .numeric, time: .omitted))
        //XCTAssertEqual("Dec 31, 1969", Date(timeIntervalSince1970: 100).formatted(date: .abbreviated, time: .omitted))
        //
        //XCTAssertEqual("19:01:40 EST", Date(timeIntervalSince1970: 100).formatted(date: .omitted, time: .complete))
        //XCTAssertEqual("19:01", Date(timeIntervalSince1970: 100).formatted(date: .omitted, time: .shortened))
        //XCTAssertEqual("19:01:40", Date(timeIntervalSince1970: 100).formatted(date: .omitted, time: .standard))
        //
        //XCTAssertEqual("12/31/1969, 19:01、12/31/1969, 19:16", [Date(timeIntervalSince1970: 100), Date(timeIntervalSince1970: 1_000)].formatted(.list(memberStyle: .dateTime, type: .and).locale(Locale(identifier: "ja"))))
        //XCTAssertEqual("31/12/1969 19:01 et 31/12/1969 19:16", [Date(timeIntervalSince1970: 100), Date(timeIntervalSince1970: 1_000)].formatted(.list(memberStyle: .dateTime.locale(Locale(identifier: "fr")), type: .and).locale(Locale(identifier: "fr"))))
        //XCTAssertEqual("31/12/1969 19:01和31/12/1969 19:16", [Date(timeIntervalSince1970: 100), Date(timeIntervalSince1970: 1_000)].formatted(.list(memberStyle: .dateTime.locale(Locale(identifier: "fr")), type: .and).locale(Locale(identifier: "zh"))))
        #endif
    }

    func testLocalizableStringsDictionary() throws {
        // Due to .process rules, Localizable.xcstrings is processed into indvidual Localizable.strings files during resource preparation; in order to test the actual xcstrings parser, we have a link to it with the suffix "xcstringsjson", which will get embedded direcly in the resources so we can test it here
        // let locURL = try XCTUnwrap(Bundle.module.url(forResource: "Localizable", withExtension: "xcstrings"))
        // let locData = try Data(contentsOf: locURL)

        let locData = xcstringsSample.data(using: .utf8)!
        let locStrings = try JSONDecoder().decode(LocalizableStringsDictionary.self, from: locData)

        XCTAssertEqual("完成", locStrings.strings["Done"]?.localizations?["zh-Hans"]?.stringUnit?.value)
        XCTAssertEqual("完了", locStrings.strings["Done"]?.localizations?["ja"]?.stringUnit?.value)

        XCTAssertEqual("Bonjour，%@", locStrings.strings["Hello, %@"]?.localizations?["fr"]?.stringUnit?.value)
        XCTAssertEqual("你好，%@", locStrings.strings["Hello, %@"]?.localizations?["zh-Hans"]?.stringUnit?.value)

        XCTAssertEqual("Done", String(localized: "Done", table: nil, bundle: Bundle.module, locale: Locale(identifier: "en"), comment: nil)) // Type mismatch: inferred type is String but StringLocalizationValue was expected

        XCTAssertEqual("Done", String(localized: String.LocalizationValue(stringLiteral: "Done"), table: nil, bundle: Bundle.module, locale: Locale(identifier: "en"), comment: nil))

        /// Peek inside the String.LocalizationValue to see how strings are converted into localization format patterns
        func pat(value: String.LocalizationValue) throws -> String? { try value.patternFormat }

        XCTAssertEqual("%@", try pat(value: "\("X")")) // Type mismatch: inferred type is String but StringLocalizationValue was expected
        XCTAssertEqual(" %@ ", try pat(value: " \("X") "))
        XCTAssertEqual("%@ %@ %@", try pat(value: "\("X") \("X") \("X")"))

        XCTAssertEqual("%lld", try pat(value: "\(1)"))
        XCTAssertEqual("%lld", try pat(value: "\(123)"))
        XCTAssertEqual("%lf", try pat(value: "\(123.45)"))
        //XCTAssertEqual("%lf", try pat(value: "\(CLongDouble(123.4567890))"))
        XCTAssertEqual("%lf %@ %lld %lf %@", try pat(value: "\(123.45) \("ABC") \(0) \(0.0) \("QRS")"))

        XCTAssertEqual("PATTERN: %llu", try pat(value: "PATTERN: \(UInt(123))"))

        XCTAssertEqual("PATTERN: %@", try pat(value: "PATTERN: \("X")"))
        XCTAssertEqual("PATTERN: %lld", try pat(value: "PATTERN: \(Int(0))"))
        XCTAssertEqual("PATTERN: %d", try pat(value: "PATTERN: \(Int16(0))"))
        // XCTAssertEqual("PATTERN: %d", try pat(value: "PATTERN: \(Int32(0))")) // FIXME: Int32=Int in Kotlin, but expected pattern in Swift is different
        XCTAssertEqual("PATTERN: %lld", try pat(value: "PATTERN: \(Int64(0))"))
        XCTAssertEqual("PATTERN: %llu", try pat(value: "PATTERN: \(UInt(0))"))
        XCTAssertEqual("PATTERN: %u", try pat(value: "PATTERN: \(UInt16(0))"))
        //XCTAssertEqual("PATTERN: %u", try pat(value: "PATTERN: \(UInt32(0))"))
        XCTAssertEqual("PATTERN: %llu", try pat(value: "PATTERN: \(UInt64(0))"))
        XCTAssertEqual("PATTERN: %lf", try pat(value: "PATTERN: \(Double(0))"))
        XCTAssertEqual("PATTERN: %f", try pat(value: "PATTERN: \(Float(0))"))

        XCTAssertEqual("Done ABC", String(localized: "Done \("ABC")"))
        // XCTAssertEqual("Done %%@ ABC", String(localized: "Done %%@ \("ABC")")) // escaped pattern
        XCTAssertEqual("Done 123", String(localized: "Done \(123)"))

        XCTAssertEqual("PRE123.450000SUF", String(localized: "PRE\(123.45)SUF"))
    }

    func testLocalizableStrings() throws {
        let localizations = Bundle.module.localizations
        let isSPM = localizations == ["en"] // SwiftPM builds don't process the strings dictionary
        if isSPM {
            // This only works when running from Xcode or Skip, since the `.process("Resources")` rule will convert the Localizable.xcstrings into ar.lproj/Localizable.strings
            throw XCTSkip("SwiftPM does not process Localizable.xcstrings")
        }

        XCTAssertEqual(["ar", "en", "fr", "he", "ja", "pt-BR", "ru", "sv", "uk", "zh-Hans"], localizations.sorted())

        #if !SKIP
        let devloc = Bundle.module.developmentLocalization
        XCTAssertEqual("en", devloc)
        #else
        let devloc = "en"
        #endif

        for lang in localizations.filter({ $0 != devloc }) {
            //NSLocalizedString("Hello", tableName: "Localizable", bundle: Bundle(url: Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: lang)!) ?? Bundle.module, comment: "")
            //let isDevloc = lang == devloc
            let isDevloc = false

            let locstrs = try XCTUnwrap(Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: isDevloc ? nil : lang + ".lproj", localization: nil), "missing Localizable.strings for localization: \(lang)")
            // another way to express the same thing
            let locstrs2 = try XCTUnwrap(Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: isDevloc ? nil : lang), "missing Localizable.strings for localization: \(lang)")

            XCTAssertEqual(locstrs, locstrs2)

            let lb = try XCTUnwrap(Bundle(url: locstrs.deletingLastPathComponent())) 

            if lang == "ar" {
                // https://github.com/skiptools/skip/issues/64
                #if !SKIP
                XCTAssertEqual("تم", String(localized: "Done", bundle: lb))
                #endif

                XCTAssertEqual("تم", String(localized: String.LocalizationValue(stringLiteral: "Done"), bundle: lb))
                //XCTAssertEqual("تم⁨X⁩", String(localized: "Done \("X")", bundle: lb)) // java.lang.AssertionError: تم⁨X⁩ != تمX

                // SKIP NOWARN
                XCTAssertEqual(try PropertyListSerialization.propertyList(from: Data(contentsOf: locstrs), format: nil) as? Dictionary<String, String>, [
                    "Done %@": "تم%@",
                    "Done": "تم",
                ])
            } else if lang == "fr" {
                XCTAssertEqual("Terminé", String(localized: String.LocalizationValue(stringLiteral: "Done"), bundle: lb))
                XCTAssertEqual("Terminé X", String(localized: "Done \("X")", bundle: lb))

                XCTAssertEqual("""
                Chaîne multi-ligne !
                Avec un peu de texte « entre guillemets ».
                """, NSLocalizedString("""
                Multi-Line String!
                With some "quoted" text.
                """, bundle: lb, comment: ""))

                // SKIP NOWARN
                XCTAssertEqual(try PropertyListSerialization.propertyList(from: Data(contentsOf: locstrs), format: nil) as? Dictionary<String, String>, [
                    "Done %@": "Terminé %@",
                    "Done": "Terminé",
                    "Multi-Line String!\nWith some \"quoted\" text.": "Chaîne multi-ligne !\nAvec un peu de texte « entre guillemets »."
                ])

            }
        }
    }

    func testLocalizedBundles() throws {
        if isMacOS && !isJava {
            // note that this *does* work when running from Xcode but not SwiftPM; always works on iOS some tests needs to be run through the Xcode toolchain
            throw XCTSkip("does not work when run from SwiftPM because the Localizable.xcstrings file is not converted to strings")
        }

        let frURL = try XCTUnwrap(Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "fr"), "could not locate fr.lproj in Bundle.module: \(String(describing: Bundle.module.resourceURL))")

        let frBundle = try XCTUnwrap(Bundle(url: frURL.deletingLastPathComponent()), "cannot locate fr.lproj bundle resource")

        XCTAssertEqual("Terminé", frBundle.localizedString(forKey: "Done", value: nil, table: nil))
        XCTAssertEqual("Terminé X", String(localized: "Done \("X")", bundle: frBundle))
    }

    func testLocaleIdentifiers() throws {
        // A BCP-47 language identifier such as en_US or en-u-nu-thai-ca-buddhist, or an ICU-style identifier such as en@calendar=buddhist;numbers=thai.
        let en_US = Locale(identifier: "en-US")
        XCTAssertEqual("English (United States)", Locale(identifier: "en_US").localizedString(forIdentifier: "en_US"))

        XCTAssertEqual("English (United States)", en_US.localizedString(forIdentifier: "en-US"))
        XCTAssertEqual("English (Canada)", en_US.localizedString(forIdentifier: "en-CA"))
        XCTAssertEqual("English (United Kingdom)", en_US.localizedString(forIdentifier: "en-GB"))

        XCTAssertEqual("English", en_US.localizedString(forLanguageCode: "en"))
        XCTAssertEqual("United States", en_US.localizedString(forRegionCode: "US"))
        XCTAssertEqual(isJava && !isAndroid ? "Simplified" : "Simplified Han", en_US.localizedString(forScriptCode: "Hans"))
        XCTAssertEqual(isJava && !isAndroid ? "Traditional" : "Traditional Han", en_US.localizedString(forScriptCode: "Hant"))

        XCTAssertEqual("English (Canada)", en_US.localizedString(forIdentifier: "en-CA"))
        XCTAssertEqual("English (United Kingdom)", en_US.localizedString(forIdentifier: "en-GB"))

        XCTAssertEqual(isAndroid ? "Chinese (Simplified Han)" : isJava ? "Chinese (Simplified)" : "Chinese, Simplified", en_US.localizedString(forIdentifier: "zh_Hans"))
        XCTAssertEqual(isAndroid ? "Chinese (Traditional Han)" : isJava ? "Chinese (Traditional)" : "Chinese, Traditional", en_US.localizedString(forIdentifier: "zh_Hant"))
        XCTAssertEqual(isAndroid ? "Chinese (Hong Kong)" : isJava ? "Chinese (Hong Kong SAR China)" : "Chinese (Hong Kong)", en_US.localizedString(forIdentifier: "zh_HK"))

        let zh_Hans = Locale(identifier: "zh_Hans")
        XCTAssertEqual(isAndroid ? "中文 (简体中文)" : isJava ? "中文 (简体)" : "简体中文", zh_Hans.localizedString(forIdentifier: "zh_Hans"))
        XCTAssertEqual(isAndroid ? "中文 (繁体中文)" : isJava ? "中文 (繁体)" : "繁体中文", zh_Hans.localizedString(forIdentifier: "zh_Hant"))
        XCTAssertEqual(isAndroid ? "中文 (香港)" : isJava ? "中文 (中国香港特别行政区)" : "中文（香港）", zh_Hans.localizedString(forIdentifier: "zh_HK"))

        XCTAssertEqual("中文", zh_Hans.localizedString(forLanguageCode: "zh"))
        XCTAssertEqual(isJava ? "美国" : "美国", zh_Hans.localizedString(forRegionCode: "US"))
        XCTAssertEqual(isJava && !isAndroid ? "简体" : "简体中文", zh_Hans.localizedString(forScriptCode: "Hans"))
        XCTAssertEqual(isJava && !isAndroid ? "繁体" : "繁体中文", zh_Hans.localizedString(forScriptCode: "Hant"))


        let zh_Hant = Locale(identifier: "zh_Hant")
        XCTAssertEqual(isAndroid ? "中文 (簡體中文)" : isJava ? "中文 (簡體)" : "簡體中文", zh_Hant.localizedString(forIdentifier: "zh_Hans"))
        XCTAssertEqual(isAndroid ? "中文 (繁體中文)" : isJava ? "中文 (繁體)" : "繁體中文", zh_Hant.localizedString(forIdentifier: "zh_Hant"))
        XCTAssertEqual(isAndroid ? "中文 (香港)" : isJava ? "中文 (中國香港特別行政區)" : "中文（香港）", zh_Hant.localizedString(forIdentifier: "zh_HK"))

        XCTAssertEqual("中文", zh_Hant.localizedString(forLanguageCode: "zh"))
        XCTAssertEqual("美國", zh_Hant.localizedString(forRegionCode: "US"))
        XCTAssertEqual(isAndroid ? "簡體中文" : isJava ? "簡體" : "簡體中文", zh_Hant.localizedString(forScriptCode: "Hans"))
        XCTAssertEqual(isAndroid ? "繁體中文" : isJava ? "繁體" : "繁體中文", zh_Hant.localizedString(forScriptCode: "Hant"))

        let zh_HK = Locale(identifier: "zh_HK")
        XCTAssertEqual(isAndroid ? "中文 (簡體中文)" : isJava ? "中文 (簡體字)" : "簡體中文", zh_HK.localizedString(forIdentifier: "zh_Hans"))
        XCTAssertEqual(isAndroid ? "中文 (繁體中文)" : isJava ? "中文 (繁體字)" : "繁體中文", zh_HK.localizedString(forIdentifier: "zh_Hant"))
        XCTAssertEqual(isAndroid ? "中文 (香港)" : isJava ? "中文 (中國香港特別行政區)" : "中文（香港）", zh_HK.localizedString(forIdentifier: "zh_HK"))

        XCTAssertEqual("中文", zh_HK.localizedString(forLanguageCode: "zh"))
        XCTAssertEqual("美國", zh_HK.localizedString(forRegionCode: "US"))
        XCTAssertEqual(isJava && !isAndroid ? "簡體字" : "簡體中文", zh_HK.localizedString(forScriptCode: "Hans"))
        XCTAssertEqual(isJava && !isAndroid ? "繁體字" : "繁體中文", zh_HK.localizedString(forScriptCode: "Hant"))

    }

    func testLocaleVariants() throws {
        do {
            // Chinese (Simplified) as used in Singapore
            let locale = Locale(identifier: "zh-Hans-SG")
            XCTAssertEqual("zh", locale.language.languageCode?.identifier)
            XCTAssertEqual("Hans", locale.language.script?.identifier)
            XCTAssertEqual("SG", locale.language.region?.identifier)
        }

        do {
            // Serbian in Latin script for Montenegro
            let locale = Locale(identifier: "sr-Latn-ME")
            XCTAssertEqual("sr", locale.language.languageCode?.identifier)
            XCTAssertEqual("Latn", locale.language.script?.identifier)
            XCTAssertEqual("ME", locale.language.region?.identifier)
        }

        do {
            // Spanish as spoken in Latin America with a traditional orthography variant
            let locale = Locale(identifier: "es-419-TRADITIONAL")
            XCTAssertEqual("es", locale.language.languageCode?.identifier)
            XCTAssertEqual("419", locale.language.region?.identifier)
            //XCTAssertEqual("TRADITIONAL", locale.variant?.identifier)
        }

        do {
            // German in Switzerland with a reformed orthography variant
            let locale = Locale(identifier: "de-CH-1901")
            XCTAssertEqual("de", locale.language.languageCode?.identifier)
            XCTAssertEqual("CH", locale.language.region?.identifier)
            //XCTAssertEqual("1901", locale.variant?.identifier)
        }

        do {
            // French in Belgium with a script variant
            let locale = Locale(identifier: "fr-BE-Latn")
            XCTAssertEqual("fr", locale.language.languageCode?.identifier)
            XCTAssertEqual("BE", locale.language.region?.identifier)
            //XCTAssertEqual("Latn", locale.language.script?.identifier)
        }
    }

    func testKnownLanguageCodes() throws {
        // generated with:
        for sourceID in Self.checkLocaleCodes.sorted() {
            let sourceLocale = Locale(identifier: sourceID)
            let vname = sourceID.replacingOccurrences(of: "-", with: "_")
            //print("\nlet \(vname) = Locale(identifier: \"\(sourceID)\")")
            for destID in Self.checkLocaleCodes.sorted() {
                if let languageName = sourceLocale.localizedString(forLanguageCode: destID) {
                    if ["en-US", "fr", "nb", "ko", "ja", "zh-Hans", "zh-Hant"].contains(destID) {
                        let destLangID = destID.split(separator: "_").first?.description ?? destID
                        //print("XCTAssertEqual(\"\(languageName)\", \(vname).localizedString(forLanguageCode: \"\(destLangID)\"))")
                    }
                }
            }
        }

        let ar = Locale(identifier: "ar")
        XCTAssertEqual("الإنجليزية", ar.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("اليابانية", ar.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("الكورية", ar.localizedString(forLanguageCode: "ko"))
        XCTAssertEqual("النرويجية بوكمال", ar.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("الصينية", ar.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("الصينية", ar.localizedString(forLanguageCode: "zh-Hant"))

        let ca = Locale(identifier: "ca")
        XCTAssertEqual("anglès", ca.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japonès", ca.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coreà", ca.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("noruec bokmål", ca.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("xinès", ca.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("xinès", ca.localizedString(forLanguageCode: "zh-Hant"))

        let cs = Locale(identifier: "cs")
        XCTAssertEqual("angličtina", cs.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japonština", cs.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("korejština", cs.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norština (bokmål)", cs.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("čínština", cs.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("čínština", cs.localizedString(forLanguageCode: "zh-Hant"))

        let da = Locale(identifier: "da")
        XCTAssertEqual("engelsk", da.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japansk", da.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("koreansk", da.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual(isJava ? "bokmål" : "norsk bokmål", da.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("kinesisk", da.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("kinesisk", da.localizedString(forLanguageCode: "zh-Hant"))

        let de = Locale(identifier: "de")
        XCTAssertEqual("Englisch", de.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Japanisch", de.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Koreanisch", de.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Norwegisch (Bokmål)", de.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Chinesisch", de.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Chinesisch", de.localizedString(forLanguageCode: "zh-Hant"))

        let el = Locale(identifier: "el")
        XCTAssertEqual("Αγγλικά", el.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Ιαπωνικά", el.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Κορεατικά", el.localizedString(forLanguageCode: "ko"))
        XCTAssertEqual("Νορβηγικά Μποκμάλ", el.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Κινεζικά", el.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Κινεζικά", el.localizedString(forLanguageCode: "zh-Hant"))

        let en_AU = Locale(identifier: "en-AU")
        XCTAssertEqual("English", en_AU.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Japanese", en_AU.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Korean", en_AU.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Norwegian Bokmål", en_AU.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Chinese", en_AU.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Chinese", en_AU.localizedString(forLanguageCode: "zh-Hant"))

        let en_GB = Locale(identifier: "en-GB")
        XCTAssertEqual("English", en_GB.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Japanese", en_GB.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Korean", en_GB.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Norwegian Bokmål", en_GB.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Chinese", en_GB.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Chinese", en_GB.localizedString(forLanguageCode: "zh-Hant"))

        let en_IN = Locale(identifier: "en-IN")
        XCTAssertEqual("English", en_IN.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Japanese", en_IN.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Korean", en_IN.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Norwegian Bokmål", en_IN.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Chinese", en_IN.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Chinese", en_IN.localizedString(forLanguageCode: "zh-Hant"))

        let en_US = Locale(identifier: "en-US")
        XCTAssertEqual("English", en_US.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Japanese", en_US.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Korean", en_US.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Norwegian Bokmål", en_US.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Chinese", en_US.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Chinese", en_US.localizedString(forLanguageCode: "zh-Hant"))

        let es = Locale(identifier: "es")
        XCTAssertEqual("inglés", es.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japonés", es.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coreano", es.localizedString(forLanguageCode: "ko"))
        XCTAssertEqual("noruego bokmal", es.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("chino", es.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("chino", es.localizedString(forLanguageCode: "zh-Hant"))

        let es_419 = Locale(identifier: "es-419")
        XCTAssertEqual("inglés", es_419.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japonés", es_419.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coreano", es_419.localizedString(forLanguageCode: "ko"))
        XCTAssertEqual("noruego bokmal", es_419.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("chino", es_419.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("chino", es_419.localizedString(forLanguageCode: "zh-Hant"))

        let fi = Locale(identifier: "fi")
        XCTAssertEqual("englanti", fi.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japani", fi.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("korea", fi.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norjan bokmål", fi.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("kiina", fi.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("kiina", fi.localizedString(forLanguageCode: "zh-Hant"))

        let fr_CA = Locale(identifier: "fr-CA")
        XCTAssertEqual("anglais", fr_CA.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japonais", fr_CA.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coréen", fr_CA.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norvégien bokmål", fr_CA.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("chinois", fr_CA.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("chinois", fr_CA.localizedString(forLanguageCode: "zh-Hant"))

        let he = Locale(identifier: "he")
        XCTAssertEqual("אנגלית", he.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("יפנית", he.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("קוריאנית", he.localizedString(forLanguageCode: "ko"))
        XCTAssertEqual("נורווגית ספרותית", he.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("סינית", he.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("סינית", he.localizedString(forLanguageCode: "zh-Hant"))

        let hr = Locale(identifier: "hr")
        XCTAssertEqual("engleski", hr.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japanski", hr.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("korejski", hr.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norveški bokmål", hr.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("kineski", hr.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("kineski", hr.localizedString(forLanguageCode: "zh-Hant"))

        let id = Locale(identifier: "id")
        XCTAssertEqual("Inggris", id.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Jepang", id.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Korea", id.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual(isJava ? "Bokmål Norwegia" : "Bokmål Norsk", id.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Tionghoa", id.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Tionghoa", id.localizedString(forLanguageCode: "zh-Hant"))

        let it = Locale(identifier: "it")
        XCTAssertEqual("inglese", it.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("giapponese", it.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coreano", it.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norvegese bokmål", it.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("cinese", it.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("cinese", it.localizedString(forLanguageCode: "zh-Hant"))

        let ja = Locale(identifier: "ja")
        XCTAssertEqual("英語", ja.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("日本語", ja.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("韓国語", ja.localizedString(forLanguageCode: "ko"))
        XCTAssertEqual(isJava ? "ノルウェー語(ブークモール)" : "ノルウェー語（ブークモール）", ja.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("中国語", ja.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("中国語", ja.localizedString(forLanguageCode: "zh-Hant"))

        let ko = Locale(identifier: "ko")
        XCTAssertEqual("영어", ko.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("일본어", ko.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("한국어", ko.localizedString(forLanguageCode: "ko"))
        XCTAssertEqual("노르웨이어(보크말)", ko.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("중국어", ko.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("중국어", ko.localizedString(forLanguageCode: "zh-Hant"))

        let ms = Locale(identifier: "ms")
        XCTAssertEqual("Inggeris", ms.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Jepun", ms.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Korea", ms.localizedString(forLanguageCode: "ko"))
        // XCTAssertEqual(isJava ? "Bokmål Norway" : "Bokmal Norway", ms.localizedString(forLanguageCode: "nb")) // different on CI, maybe due to different JVM vendor
        XCTAssertEqual("Cina", ms.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Cina", ms.localizedString(forLanguageCode: "zh-Hant"))

        let nb = Locale(identifier: "nb")
        XCTAssertEqual("engelsk", nb.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japansk", nb.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("koreansk", nb.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norsk bokmål", nb.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("kinesisk", nb.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("kinesisk", nb.localizedString(forLanguageCode: "zh-Hant"))

        let nl = Locale(identifier: "nl")
        XCTAssertEqual("Engels", nl.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Japans", nl.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Koreaans", nl.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Noors - Bokmål", nl.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Chinees", nl.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Chinees", nl.localizedString(forLanguageCode: "zh-Hant"))

        let pl = Locale(identifier: "pl")
        XCTAssertEqual("angielski", pl.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japoński", pl.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("koreański", pl.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norweski (bokmål)", pl.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("chiński", pl.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("chiński", pl.localizedString(forLanguageCode: "zh-Hant"))

        let pt_BR = Locale(identifier: "pt-BR")
        XCTAssertEqual("inglês", pt_BR.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japonês", pt_BR.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coreano", pt_BR.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("bokmål norueguês", pt_BR.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("chinês", pt_BR.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("chinês", pt_BR.localizedString(forLanguageCode: "zh-Hant"))

        let pt_PT = Locale(identifier: "pt-PT")
        XCTAssertEqual("inglês", pt_PT.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japonês", pt_PT.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coreano", pt_PT.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norueguês bokmål", pt_PT.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("chinês", pt_PT.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("chinês", pt_PT.localizedString(forLanguageCode: "zh-Hant"))

        let ro = Locale(identifier: "ro")
        XCTAssertEqual("engleză", ro.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japoneză", ro.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("coreeană", ro.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norvegiană bokmål", ro.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("chineză", ro.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("chineză", ro.localizedString(forLanguageCode: "zh-Hant"))

        let ru = Locale(identifier: "ru")
        XCTAssertEqual("английский", ru.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("японский", ru.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("корейский", ru.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("норвежский букмол", ru.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("китайский", ru.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("китайский", ru.localizedString(forLanguageCode: "zh-Hant"))

        let sk = Locale(identifier: "sk")
        XCTAssertEqual("angličtina", sk.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japončina", sk.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("kórejčina", sk.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("nórčina (bokmal)", sk.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("čínština", sk.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("čínština", sk.localizedString(forLanguageCode: "zh-Hant"))

        let sv = Locale(identifier: "sv")
        XCTAssertEqual("engelska", sv.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("japanska", sv.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("koreanska", sv.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("norskt bokmål", sv.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("kinesiska", sv.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("kinesiska", sv.localizedString(forLanguageCode: "zh-Hant"))

        let th = Locale(identifier: "th")
        XCTAssertEqual("อังกฤษ", th.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("ญี่ปุ่น", th.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("เกาหลี", th.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("นอร์เวย์บุคมอล", th.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("จีน", th.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("จีน", th.localizedString(forLanguageCode: "zh-Hant"))

        let tr = Locale(identifier: "tr")
        XCTAssertEqual("İngilizce", tr.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Japonca", tr.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Korece", tr.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Norveççe Bokmål", tr.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Çince", tr.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Çince", tr.localizedString(forLanguageCode: "zh-Hant"))

        let uk = Locale(identifier: "uk")
        XCTAssertEqual("англійська", uk.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("японська", uk.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("корейська", uk.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("норвезька (букмол)", uk.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("китайська", uk.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("китайська", uk.localizedString(forLanguageCode: "zh-Hant"))

        let vi = Locale(identifier: "vi")
        XCTAssertEqual("Tiếng Anh", vi.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("Tiếng Nhật", vi.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("Tiếng Hàn", vi.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("Tiếng Na Uy (Bokmål)", vi.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("Tiếng Trung", vi.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("Tiếng Trung", vi.localizedString(forLanguageCode: "zh-Hant"))

        let zh_Hans = Locale(identifier: "zh-Hans")
        XCTAssertEqual("英语", zh_Hans.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("日语", zh_Hans.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("韩语", zh_Hans.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("书面挪威语", zh_Hans.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("中文", zh_Hans.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("中文", zh_Hans.localizedString(forLanguageCode: "zh-Hant"))

        let zh_HK = Locale(identifier: "zh-HK")
        XCTAssertEqual("英文", zh_HK.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("日文", zh_HK.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("韓文", zh_HK.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("巴克摩挪威文", zh_HK.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("中文", zh_HK.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("中文", zh_HK.localizedString(forLanguageCode: "zh-Hant"))

        let zh_Hant = Locale(identifier: "zh-Hant")
        XCTAssertEqual("英文", zh_Hant.localizedString(forLanguageCode: "en-US"))
        XCTAssertEqual("日文", zh_Hant.localizedString(forLanguageCode: "ja"))
        XCTAssertEqual("韓文", zh_Hant.localizedString(forLanguageCode: "ko"))
//        XCTAssertEqual("巴克摩挪威文", zh_Hant.localizedString(forLanguageCode: "nb"))
        XCTAssertEqual("中文", zh_Hant.localizedString(forLanguageCode: "zh-Hans"))
        XCTAssertEqual("中文", zh_Hant.localizedString(forLanguageCode: "zh-Hant"))
    }

    static let checkLocaleCodes: [String] = [
        "ar", "ca", "zh-HK", "zh-Hant", "zh-Hans", "hr", "cs", "da", "nl", "en-US", "en-AU", "en-IN", "en-GB", "fi", "fr-CA", "de", "el", "he", "id", "it", "ja", "ko", "ms", "nb", "pl", "pt-BR", "pt-PT", "ro", "ru", "sk", "es", "es-419", "sv", "th", "tr", "uk", "vi"
    ]

    func testCommonISOCurrencyCodes() throws {
        let commonISOCurrencyCodes = Locale.commonISOCurrencyCodes
        let checkCurrencyCodes = Self.checkCurrencyCodes

        XCTAssertFalse(commonISOCurrencyCodes.isEmpty)
        XCTAssertEqual(Set(commonISOCurrencyCodes).sorted(), commonISOCurrencyCodes)
        #if SKIP
        XCTAssertTrue(Set(commonISOCurrencyCodes).isSubset(of: Set(checkCurrencyCodes)))
        #endif
    }

    // Common ISO currency codes to check.
    static let checkCurrencyCodes: [String] = ["AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", "BGN", "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BTN", "BWP", "BYN", "BZD", "CAD", "CDF", "CHF", "CLP", "CNY", "COP", "CRC", "CUC", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ERN", "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GHS", "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JMD", "JOD", "JPY", "KES", "KGS", "KHR", "KMF", "KPW", "KRW", "KWD", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD", "LSL", "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MNT", "MOP", "MRU", "MUR", "MVR", "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON", "RSD", "RUB", "RWF", "SAR", "SBD", "SCR", "SDG", "SEK", "SGD", "SHP", "SLE", "SLL", "SOS", "SRD", "SSP", "STN", "SYP", "SZL", "THB", "TJS", "TMT", "TND", "TOP", "TRY", "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VEF", "VES", "VND", "VUV", "WST", "XAF", "XCD", "XOF", "XPF", "YER", "ZAR", "ZMW"]

    func testCurrencyCodes() throws {
        for localeCode in Self.checkLocaleCodes {
            let locale = Locale(identifier: localeCode)

            XCTAssertNil(locale.localizedString(forCurrencyCode: "INVALID"))

            for currencyCode in Locale.commonISOCurrencyCodes {
                let localizedString = locale.localizedString(forCurrencyCode: currencyCode)
                let localizedStringLowercased = locale.localizedString(forCurrencyCode: currencyCode.lowercased())

                XCTAssertNotNil(localizedString)
                XCTAssertEqual(localizedString, localizedStringLowercased)
            }
        }
    }

    func testLocalizedStringResource() throws {
        if isMacOS && !isJava {
            // note that this *does* work when running from Xcode but not SwiftPM; always works on iOS some tests needs to be run through the Xcode toolchain
            if Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en") == nil {
                throw XCTSkip("does not work when run from SwiftPM because the Localizable.xcstrings file is not converted to strings")
            }
        }

        XCTAssertEqual("XYZ", String(localized: LocalizedStringResource(stringLiteral: "XYZ")))
        XCTAssertEqual("ABC", String(localized: LocalizedStringResource(String.LocalizationValue("ABC"), table: nil, locale: Locale.current, bundle: LocalizedStringResource.BundleDescription.main, comment: nil)))
        XCTAssertEqual("LMN", String(localized: LocalizedStringResource("QRS", defaultValue: String.LocalizationValue("LMN"), table: nil, locale: Locale(identifier: "fr"), bundle: LocalizedStringResource.BundleDescription.main, comment: "comment")))

        #if SKIP
        // check that both "en" and the auto-generated "base" locales exist and perform the correct lookups
        let baseLocaleNames = ["en", "base"]
        #else
        let baseLocaleNames = ["en"]
        #endif
        for localeName in baseLocaleNames {
            let bundleURL = try XCTUnwrap(Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: localeName), "could not locate \(localeName).lproj in Bundle.module: \(String(describing: Bundle.module.resourceURL))")

            let bundle = try XCTUnwrap(Bundle(url: bundleURL.deletingLastPathComponent()), "cannot locate en.lproj bundle resource")
            let bundleDescription = LocalizedStringResource.BundleDescription.atURL(bundleURL.deletingLastPathComponent())

            XCTAssertEqual("UPPER-CASE", String(localized: LocalizedStringResource("lower-case", bundle: bundleDescription)))
            let abc = "abc"
            XCTAssertEqual("UPPER-CASE abc STRING", String(localized: LocalizedStringResource("lower-case \(abc) string", bundle: bundleDescription)))
        }

        if !isJava {
            // the remaining tests only seem to work for Skip; Cocoa doesn't seem to work (although it should)
            return
        }
        let moduleBundle = LocalizedStringResource.BundleDescription.forClass(Self.self)

        XCTAssertEqual("UPPER-CASE", String(localized: LocalizedStringResource("lower-case", bundle: moduleBundle)))

        // tests the behavior of fallbacks: "en" defines "lower-case" as "UPPER-CASE"
        XCTAssertEqual("UPPER-CASE", String(localized: LocalizedStringResource("lower-case", locale: Locale(identifier: "en"), bundle: moduleBundle)))
        // "fr" has some localizations by does not translate "lower-case", so the expected behavior is to just return the key name
        //XCTAssertEqual("lower-case", String(localized: LocalizedStringResource("lower-case", locale: Locale(identifier: "fr"), bundle: moduleBundle)))
        // "sk" is not localized at all, so the expected behavior is to fall back to base.lproj, which is en, and so "lower-case" will be translated as "UPPER-CASE"
        XCTAssertEqual("UPPER-CASE", String(localized: LocalizedStringResource("lower-case", locale: Locale(identifier: "sk"), bundle: moduleBundle)))
    }
}

#if !SKIP
extension String.LocalizationValue {
    /// Returns the underlying pattern format represented by this `LocalizationValue`
    /// Note that in Skip, this is already implemented
    var patternFormat: String? {
        get throws {
            let jsonData = try JSONEncoder().encode(self)
            // String.LocalizationValue is encoded like: {"key":"%@","arguments":[{"string":{"_0":"X"}}]}
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                // the "key" property is the format of the string
                return jsonDict["key"] as? String
            } else {
                return nil
            }
        }
    }
}
#endif


/// The contents of a `Localizable.xcstrings` file.
public struct LocalizableStringsDictionary : Decodable {
    public let version: String
    public let sourceLanguage: String
    public let strings: [String: StringsEntry]

    public struct StringsEntry : Decodable {
        public let extractionState: String? // e.g., "stale"
        public let comment: String?
        public let localizations: [String: TranslationSet]?
    }

    public struct TranslationSet : Decodable {
        public let stringUnit: StringUnit?
    }

    public struct StringUnit: Decodable {
        public let state: String? // e.g., "translated"
        // workaround for Kotlin not liking like "value" (https://github.com/skiptools/skip/issues/62)
        private let _value: String?
        public var value: String? { _value }

        public enum CodingKeys : String, CodingKey {
            case state = "state"
            case _value = "value"
        }
    }
}

let xcstringsSample = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "%@" : {

    },
    "%@ %@" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "new",
            "value" : "@"
          }
        }
      }
    },
    "❄️" : {

    },
    "🌞" : {

    },
    "Done" : {
      "localizations" : {
        "ar" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "تم"
          }
        },
        "fr" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Terminé"
          }
        },
        "he" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "סיום"
          }
        },
        "ja" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "完了"
          }
        },
        "pt-BR" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "OK"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Готово"
          }
        },
        "sv" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Klar"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Готово"
          }
        },
        "zh-Hans" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "完成"
          }
        }
      }
    },
    "Hello, %@" : {
     "localizations" : {
      "ar" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "مرحبا، %@"
        }
      },
      "fr" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Bonjour，%@"
        }
      },
      "he" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "שלום، %@"
        }
      },
      "ja" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "こんにちは，%@"
        }
      },
      "pt-BR" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Olá，%@"
        }
      },
      "ru" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Привет，%@"
        }
      },
      "sv" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Hej，%@"
        }
      },
      "uk" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "Привіт，%@"
        }
      },
      "zh-Hans" : {
        "stringUnit" : {
          "state" : "translated",
          "value" : "你好，%@"
        }
      }
     }
    },

    "Recent" : {
      "extractionState" : "stale",
      "localizations" : {
        "ar" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "حديثًا"
          }
        },
        "he" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "אחרונות"
          }
        },
        "ja" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "履歴"
          }
        },
        "pt-BR" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Recentes"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Недавние"
          }
        },
        "sv" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Senaste"
          }
        },
        "uk" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Недавно"
          }
        },
        "zh-Hans" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "最近造访"
          }
        }
      }
    },
    "Settings" : {

    }
  },
  "version" : "1.0"
}

"""
#endif

