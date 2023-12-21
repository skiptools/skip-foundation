// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

internal typealias NSLocale = Locale

public struct Locale : Hashable {
    internal let platformValue: java.util.Locale

    internal init(platformValue: java.util.Locale) {
        self.platformValue = platformValue
    }

    public static var availableIdentifiers: [String] {
        return Array(java.util.Locale.getAvailableLocales().map({ $0.toString() }))
    }

    public init(identifier: String) {
        //self.platformValue = PlatformLocale(identifier)
        //self.platformValue = PlatformLocale.forLanguageTag(identifier)
        let parts = Array(identifier.split(separator: "_"))
        if parts.count >= 2 {
            // turn fr_FR into the language/country form
            self.platformValue = java.util.Locale(parts.first, parts.last)
        } else {
            // language only
            self.platformValue = java.util.Locale(identifier)
        }
    }

    public static var current: Locale {
        return Locale(platformValue: java.util.Locale.getDefault())
    }

    public static var system: Locale {
        return Locale(platformValue: java.util.Locale.getDefault()) // FIXME: not the same as .system: “Use the system locale when you don’t want any localizations”
    }

    public var identifier: String {
        return platformValue.toString()
    }

    public var languageCode: String? {
        return platformValue.getLanguage()
    }

    public func localizedString(forLanguageCode languageCode: String) -> String? {
        return java.util.Locale(languageCode).getDisplayLanguage(platformValue)
    }

    public var currencySymbol: String? {
        java.text.NumberFormat.getCurrencyInstance(platformValue).currency?.symbol
    }
}

extension Locale {
    public func kotlin(nocopy: Bool = false) -> java.util.Locale {
        return nocopy ? platformValue : platformValue.clone() as java.util.Locale
    }
}

extension java.util.Locale {
    public func swift(nocopy: Bool = false) -> Locale {
        let platformValue = nocopy ? self : clone() as java.util.Locale
        return Locale(platformValue: platformValue)
    }
}

#endif
