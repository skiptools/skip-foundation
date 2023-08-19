// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.LocalizedStringResource
@available(macOS 13, iOS 16, tvOS 16, watchOS 8, *)
internal typealias LocalizedStringResource = Foundation.LocalizedStringResource
#else
public typealias LocalizedStringResource = SkipLocalizedStringResource
#endif

// Override the Kotlin type to be public while keeping the Swift version internal:
// SKIP DECLARE: class SkipLocalizedStringResource
@available(macOS 13, iOS 16, tvOS 16, watchOS 8, *)
internal final class SkipLocalizedStringResource {
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

#if SKIP

public extension LocalizedStringResource {
    public typealias BundleDescription = SkipLocalizedStringResource.LocalizedStringResource
}

public func String(localized: LocalizedStringResource) -> String {
    fatalError("TODO: String(localized:)")
}

// //SKIP INSERT: public operator fun SkipLocalizedStringResource.Companion.invoke(contentsOf: URL): SkipLocalizedStringResource { return SkipLocalizedStringResource(TODO) }

extension SkipLocalizedStringResource {
}

#endif

