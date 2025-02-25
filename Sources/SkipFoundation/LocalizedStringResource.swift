// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public final class LocalizedStringResource: Hashable {
    public let keyAndValue: String.LocalizationValue
    public var defaultValue: String.LocalizationValue? = nil
    public var table: String? = nil
    public var locale: Locale? = nil
    public var bundle: BundleDescription? = nil
    public var comment: String? = nil

    /// The raw string used to create the keyAndValue `String.LocalizationValue`
    public var key: String {
        keyAndValue.patternFormat
    }

    public init(stringLiteral: String) {
        self.keyAndValue = String.LocalizationValue(stringLiteral)
        self.bundle = .main
    }

    public init(_ keyAndValue: String.LocalizationValue, defaultValue: String.LocalizationValue? = nil, table: String? = nil, locale: Locale? = nil, bundle: BundleDescription? = nil, comment: String? = nil) {
        self.keyAndValue = keyAndValue
        self.defaultValue = defaultValue
        self.table = table
        self.locale = locale
        self.bundle = bundle
        self.comment = comment
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.keyAndValue == rhs.keyAndValue
        && lhs.defaultValue == rhs.defaultValue
        && lhs.table == rhs.table
        && lhs.locale == rhs.locale
        && lhs.bundle == rhs.bundle
        && lhs.comment == rhs.comment
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyAndValue.hashCode())
        if let defaultValue = defaultValue {
            hasher.combine(defaultValue.hashCode())
        }
        if let table = table {
            hasher.combine(table.hashCode())
        }
        if let locale = locale {
            hasher.combine(locale.hashCode())
        }
        if let bundle = bundle {
            hasher.combine(bundle.hashCode())
        }
        if let comment = comment {
            hasher.combine(comment.hashCode())
        }
    }

    public enum BundleDescription: CustomStringConvertible, Hashable {
        case main
        case forClass(AnyClass)
        case atURL(URL)

        public var description: String {
            switch self {
            case .main: return "bundle: main"
            case .forClass(let c): return "bundle: \(c)"
            case .atURL(let url): return "bundle: \(url)"
            }
        }

        public var bundle: Bundle {
            Bundle(location: self)
        }
    }
}

#endif
