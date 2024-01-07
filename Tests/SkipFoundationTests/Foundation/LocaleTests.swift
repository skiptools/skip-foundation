// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

@available(macOS 13, iOS 16, watchOS 10, tvOS 16, *)
final class LocaleTests: XCTestCase {
    func testLanguageCodes() throws {
        let fr = Locale(identifier: "fr_FR")
        XCTAssertNotNil(fr)
        //logger.info("fr_FR: \(fr.identifier)")

        XCTAssertEqual("fr_FR", fr.identifier)

        XCTAssertEqual("€", Locale(identifier: "fr_FR").currencySymbol)
        XCTAssertEqual("€", Locale(identifier: "pt_PT").currencySymbol)
        #if SKIP
        //XCTAssertEqual("R", Locale(identifier: "pt_BR").currencySymbol)
        #else
        //XCTAssertEqual("R$", Locale(identifier: "pt_BR").currencySymbol)
        #endif

        XCTAssertEqual("¥", Locale(identifier: "jp_JP").currencySymbol)
        XCTAssertEqual("¤", Locale(identifier: "zh_ZH").currencySymbol)
        #if SKIP
        //XCTAssertEqual("", Locale(identifier: "en_US").currencySymbol)
        #else
        //XCTAssertEqual("$", Locale(identifier: "en_US").currencySymbol)
        #endif

        //XCTAssertEqual("fr", fr.languageCode)

        // TODO: Android emulator tests fail
        try failOnAndroid()

        #if SKIP
        // TODO: make it top-level "Test.plist"

        // “The method getResource() returns a URL for the resource. The URL (and its representation) is specific to the implementation and the JVM (that is, the URL obtained in one runtime instance may not work in another). Its protocol is usually specific to the ClassLoader loading the resource. If the resource does not exist or is not visible due to security considerations, the methods return null.”
        let resURL: java.net.URL = try XCTAssertNotNil(javaClass.getResource("Resources/Test.plist"))
        let contents = try resURL.getContent()

        let module = Bundle.module

        // “If the client code wants to read the contents of the resource as an InputStream, it can apply the openStream() method on the URL. This is common enough to justify adding getResourceAsStream() to Class and ClassLoader. getResourceAsStream() the same as calling getResource().openStream(), except that getResourceAsStream() catches IO exceptions returns a null InputStream.”
        let res = try XCTAssertNotNil(javaClass.getResourceAsStream("Resources/Test.plist"))
        res.close()
        #endif

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

        //XCTAssertEqual("Done", String(localized: "Done", table: nil, bundle: Bundle.module, locale: Locale(identifier: "en"), comment: nil)) // Type mismatch: inferred type is String but StringLocalizationValue was expected

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
                    "Recent": "حديثًا"
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
        XCTAssertNil(Bundle.module.url(forResource: "xx", withExtension: "lproj"))

        //let frURL = try XCTUnwrap(Bundle.module.url(forResource: "fr.lproj/", withExtension: ""), "could not locate fr.lproj in Bundle.module: \(String(describing: Bundle.module.resourceURL))")

        //let frBundle = try XCTUnwrap(Bundle(url: frURL), "cannot locate fr.lproj bundle resource")

        //XCTAssertEqual("Terminé", frBundle.localizedString(forKey: "Done", value: nil, table: nil))
        //XCTAssertEqual("Terminé X", String(localized: "Done \("X")", bundle: frBundle))
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
