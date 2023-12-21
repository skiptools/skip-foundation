// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias LocalizedStringResource = SkipLocalizedStringResource

public final class SkipLocalizedStringResource {
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

    // FIXME: move to `Bundle.BundleDescription` so we can internalize the location
    public enum BundleDescription: CustomStringConvertible {
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
