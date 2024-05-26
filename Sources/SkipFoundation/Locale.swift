// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

internal typealias NSLocale = Locale

public struct Locale : Hashable {
    internal let platformValue: java.util.Locale

    public static var availableIdentifiers: [String] {
        return Array(java.util.Locale.getAvailableLocales().map({ $0.toString() }))
    }

    public init(platformValue: java.util.Locale) {
        self.platformValue = platformValue
    }

    public init(identifier: String) {
        // Returns a locale for the specified IETF BCP 47 language tag string.
        self.platformValue = java.util.Locale.forLanguageTag(identifier.replace("_", "-"))
    }

    /// Construct an identifier that conforms to the expected Foundation identifiers
    public var identifier: String {
        // Returns a string representation of this Locale object, consisting of language, country, variant, script, and extensions as below: language + "_" + country + "_" + (variant + "_#" | "#") + script + "-" + extensions Language is always lower case, country is always upper case, script is always title case, and extensions are always lower case.
        //return platformValue.toString()

        // To represent a Locale as a String for interchange purposes, use toLanguageTag().
        return platformValue.toLanguageTag().replace("-", "_")
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.platformValue == rhs.platformValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(platformValue.hashCode())
    }

    public static var current: Locale {
        return Locale(platformValue: java.util.Locale.getDefault())
    }

    public static var system: Locale {
        return Locale(platformValue: java.util.Locale.getDefault()) // FIXME: not the same as .system: “Use the system locale when you don’t want any localizations”
    }

    /// Returns an array of tags to search for a locale identifier, from most specific to least specific
    var localeSearchTags: [String] {
        // for an identifier like "fr_FR", seek "fr-FR.lproj" and "fr.lproj"
        // for an identifier like "zh_Hant", seek "zh-Hant.lproj" and "zh.lproj"
        // for an identifier like "fr_CA_QC", seek "fr-QC-CA.lproj" and "fr-CA.lproj" and "fr.lproj"
        var identifiers = [self.canonicalIdentifier]
        let languageCode = self.languageCode ?? ""
        if let regionCode = self.regionCode, !regionCode.isEmpty {
            if let variantCode = self.variantCode, !variantCode.isEmpty {
                identifiers.append(languageCode + "-" + variantCode + "-" + regionCode)
                identifiers.append(languageCode + "-" + variantCode)
                identifiers.append(languageCode + "-" + regionCode)
            } else {
                identifiers.append(languageCode + "-" + regionCode)
            }
        } else if let variantCode = self.variantCode, !variantCode.isEmpty {
            identifiers.append(languageCode + "-" + variantCode)
        }
        // special case: un-specified "zh" should fall back to zh-Hans
        if languageCode == "zh" {
            identifiers.append("zh-Hans")
        }
        identifiers.append(languageCode)

        return identifiers
    }

    /// The identifier that matches the default ID used for xcstrings dictionary keys
    public var canonicalIdentifier: String {
        return platformValue.toLanguageTag()

        let languageCode = languageCode ?? "en"
        if let regionCode = regionCode, !regionCode.isEmpty {
            if let variantCode = variantCode, !variantCode.isEmpty {
                return languageCode + "-" + variantCode + "-" + regionCode
            } else {
                return languageCode + "-" + regionCode
            }
        } else if let variantCode = variantCode, !variantCode.isEmpty {
            return languageCode + "-" + variantCode
        } else {
            return languageCode
        }
    }

    public var currency: Currency? {
        guard let currency = java.text.NumberFormat.getCurrencyInstance(platformValue)?.currency else { return nil }
        return Locale.Currency(platformValue: currency)
    }

    public var currencySymbol: String? {
        return currency?.symbol
    }

    public var language: Language {
        Locale.Language(platformValue: platformValue)
    }

    public var languageCode: String? {
        return language?.languageCode?.identifier
    }

    public var scriptCode: String? {
        return language?.script.identifier
    }

    public var regionCode: String? {
        return language.region?.identifier
    }

    public var variant: Variant? {
        Locale.Variant(platformValue: platformValue)
    }

    public var variantCode: String? {
        return variant?.identifier
    }

    public func localizedString(forIdentifier targetIdentifier: String) -> String? {
        return Locale(identifier: targetIdentifier).platformValue.getDisplayName(platformValue)
    }

    public func localizedString(forLanguageCode: String) -> String? {
        // malformed languages like "en-AU" throw an exception in Java, but no in Cocoa; so we ignore exceptions and fallback to attempting to create the Locale directly
        let locale = try? java.util.Locale.Builder().setLanguage(forLanguageCode).build()
        return (locale ?? Locale(identifier: forLanguageCode).platformValue).getDisplayLanguage(platformValue)
    }

    public func localizedString(forRegionCode: String) -> String? {
        let locale = try? java.util.Locale.Builder().setRegion(forRegionCode).build()
        return (locale ?? Locale(identifier: forRegionCode).platformValue).getDisplayCountry(platformValue)
    }

    public func localizedString(forScriptCode: String) -> String? {
        let locale = try? java.util.Locale.Builder().setScript(forScriptCode).build()
        return (locale ?? Locale(identifier: forScriptCode).platformValue).getDisplayScript(platformValue)
    }

//    public func localizedString(forVariantCode: String) -> String? {
//        let locale = try? java.util.Locale.Builder().setScript(forScriptCode).build()
//        return (locale ?? Locale(identifier: forScriptCode).platformValue).getDisplayScript(platformValue)
//    }

    public func localize(key: String, value: String?, bundle: Bundle?, tableName: String?) -> String? {
        return bundle?.localizedBundle(locale: self).localizedString(forKey: key, value: value, table: tableName)
    }

    public struct Currency : Hashable {
        internal let platformValue: java.util.Currency

        public init(platformValue: java.util.Currency) {
            self.platformValue = platformValue
        }

        public var identifier: String {
            platformValue.getCurrencyCode()
        }

        public var symbol: String {
            platformValue.getSymbol()
        }
    }

    public struct Language : Hashable {
        internal let platformValue: java.util.Locale

        public init(platformValue: java.util.Locale) {
            self.platformValue = platformValue
        }

        public var languageCode: LanguageCode {
            LanguageCode(platformValue: platformValue)
        }

        public var script: Script {
            Script(platformValue: platformValue)
        }

        public var region: Region? {
            Region(platformValue: platformValue)
        }
    }

    public struct LanguageCode : Hashable {
        internal let platformValue: java.util.Locale

        public init(platformValue: java.util.Locale) {
            self.platformValue = platformValue
        }

        public var identifier: String {
            platformValue.getLanguage()
        }
    }

    public struct Variant : Hashable {
        internal let platformValue: java.util.Locale

        public init(platformValue: java.util.Locale) {
            self.platformValue = platformValue
        }

        public var identifier: String {
            platformValue.getVariant()
        }
    }

    public struct Region : Hashable {
        internal let platformValue: java.util.Locale

        public init(platformValue: java.util.Locale) {
            self.platformValue = platformValue
        }

        public var identifier: String {
            platformValue.getCountry()
        }
    }

    public struct Script : Hashable {
        internal let platformValue: java.util.Locale

        public init(platformValue: java.util.Locale) {
            self.platformValue = platformValue
        }

        public var identifier: String {
            platformValue.getScript()
        }
    }

}

extension Locale: KotlinConverting<java.util.Locale> {
    public override func kotlin(nocopy: Bool = false) -> java.util.Locale {
        return nocopy ? platformValue : platformValue.clone() as java.util.Locale
    }
}

#endif
