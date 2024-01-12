// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias LocalizedStringResource = SkipLocalizedStringResource

public final class SkipLocalizedStringResource: Hashable {
    public let key: String
    public let defaultValue: String? // TODO: String.LocalizationValue
    public let table: String?
    public var locale: Locale?
    public var bundle: BundleDescription?
    public var comment: String?

    public init(_ key: String, defaultValue: String? = nil, table: String? = nil, locale: Locale? = nil, bundle: BundleDescription? = nil, comment: String? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.table = table
        self.locale = locale
        self.bundle = bundle
        self.comment = comment
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key == rhs.key
        && lhs.defaultValue == rhs.defaultValue
        && lhs.table == rhs.table
        && lhs.locale == rhs.locale
        && lhs.bundle == rhs.bundle
        && lhs.comment == rhs.comment
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key.hashCode())
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


    // FIXME: move to `Bundle.BundleDescription` so we can internalize the location
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
    }
}

public extension LocalizedStringResource {
    public typealias BundleDescription = SkipLocalizedStringResource.LocalizedStringResource
}

extension SkipLocalizedStringResource {
}

#endif
