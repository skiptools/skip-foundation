// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.Bundle
internal typealias PlatformBundle = Foundation.Bundle
#else
public typealias PlatformBundle = AnyClass
#endif

public class Bundle {
    #if !SKIP
    public static let main = Bundle(platformValue: PlatformBundle.main)
    #else
    public static let main = Bundle(location: .main)
    #endif

    #if !SKIP
    internal let platformValue: PlatformBundle

    internal init(platformValue: PlatformBundle) {
        self.platformValue = platformValue
    }
    #else
    private let location: SkipLocalizedStringResource.BundleDescription

    public init(location: SkipLocalizedStringResource.BundleDescription) {
        self.location = location
    }
    #endif

    public convenience init?(path: String) {
        #if !SKIP
        guard let platformBundle = PlatformBundle(path: path) else {
            return nil
        }
        self.init(platformValue: platformBundle)
        #else
        self.init(location: .atURL(URL(fileURLWithPath: path)))
        #endif
    }

    public convenience init?(url: URL) {
        #if !SKIP
        guard let platformBundle = PlatformBundle(url: url.platformValue) else {
            return nil
        }
        self.init(platformValue: platformBundle)
        #else
        self.init(location: .atURL(url))
        #endif
    }

    public init() {
        #if !SKIP
        self.platformValue = PlatformBundle()
        #else
        self.init(location: .forClass(Bundle.self))
        #endif
    }

    public convenience init(for forClass: AnyClass) {
        #if !SKIP
        self.init(platformValue: PlatformBundle(for: forClass))
        #else
        self.init(location: .forClass(forClass))
        #endif
    }

    public var description: String {
        #if !SKIP
        return platformValue.description
        #else
        return location.description
        #endif
    }

    public var bundleURL: URL {
        #if !SKIP
        return URL(platformValue: platformValue.bundleURL)
        #else
        let loc: SkipLocalizedStringResource.BundleDescription = location
        switch loc {
        case .main:
            fatalError("Skip does not support .main bundle")
        case .atURL(let url):
            return url
        case .forClass(let cls):
            return relativeBundleURL("resources.lst")!
                .deletingLastPathComponent()
        }
        #endif
    }

    public var resourceURL: URL? {
        #if !SKIP
        return URL(platformValue: platformValue.bundleURL)
        #else
        return bundleURL // FIXME: this is probably not correct
        #endif
    }

}

#if SKIP

public func NSLocalizedString(_ key: String, tableName: String? = nil, bundle: Bundle? = nil, value: String = "", comment: String) -> String {
    return (bundle ?? Bundle.main).localizedString(forKey: key, value: value, table: tableName)
}

extension Bundle {
    /// Access this module's bundle. External modules will generate their own `Bundle.module` extensions. 
    static var module: Bundle {
        return Bundle(for: Bundle.self)
    }

    /// Creates a relative path to the given bundle URL
    private func relativeBundleURL(path: String) -> URL? {
        let loc: SkipLocalizedStringResource.BundleDescription = location
        switch loc {
        case .main:
            fatalError("Skip does not support .main bundle")
        case .atURL(let url):
            return url.appendingPathComponent(path)
        case .forClass(let cls):
            do {
                let resURL = cls.java.getResource("Resources/" + path)
                return URL(platformValue: resURL)
            } catch {
                // getResource throws when it cannot find the resource
                return nil
            }
        }
    }

    public var bundlePath: String {
        bundleURL.path
    }

    /// Loads the resources index stored in the `resources.lst` file at the root of the resources folder.
    private lazy var resourcesIndex: [String] = {
        guard let resourceListURL = try url(forResource: "resources.lst") else {
            return []
        }
        let resourceList = try Data(contentsOf: resourceListURL)
        guard let resourceListString = String(data: resourceList, encoding: String.Encoding.utf8) else {
            return []
        }
        let resourcePaths = resourceListString.components(separatedBy: "\n")
        return resourcePaths
    }()

    /// We default to en as the development localization
    public var developmentLocalization: String { "en" }

    /// Identify the Bundle's localizations by the presence of a `LOCNAME.lproj/` folder in index of the root of the resources folder
    public lazy var localizations: [String] = {
        resourcesIndex
            .compactMap({ $0.components(separatedBy: "/").first })
            .filter({ $0.hasSuffix(".lproj") })
            .map({ $0.dropLast(".lproj".count) })
    }()

    public func path(forResource: String? = nil, ofType: String? = nil, inDirectory: String? = nil, forLocalization: String? = nil) -> String? {
        url(forResource: forResource, withExtension: ofType, subdirectory: inDirectory, localization: forLocalization)?.path
    }

    public func url(forResource: String? = nil, withExtension: String? = nil, subdirectory: String? = nil, localization: String? = nil) -> URL? {
        // similar behavior to: https://github.com/apple/swift-corelibs-foundation/blob/69ab3975ea636d1322ad19bbcea38ce78b65b26a/CoreFoundation/PlugIn.subproj/CFBundle_Resources.c#L1114
        var res = forResource ?? ""
        if let withExtension = withExtension, !withExtension.isEmpty {
            // TODO: If `forResource` is nil, we are expected to find the first file in the bundle whose extension matches
            res += "." + withExtension
        } else {
            if res.isEmpty {
                return nil
            }
        }
        if let localization = localization {
            //let lprojExtension = "lproj" // _CFBundleLprojExtension
            var lprojExtensionWithDot = ".lproj" // _CFBundleLprojExtensionWithDot
            res = localization + lprojExtensionWithDot + "/" + res
        }
        if let subdirectory = subdirectory {
            res = subdirectory + "/" + res
        }

        return relativeBundleURL(path: res)
    }

    public func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        synchronized(self) {
            let table = tableName ?? "Localizable"
            if let localizedTable = localizedTables[table] {
                return localizedTable?[key] ?? value ?? key
            } else {
                let resURL = url(forResource: table, withExtension: "strings")
                let locTable = resURL == nil ? nil : try? PropertyListSerialization.propertyList(from: Data(contentsOf: resURL!), format: nil)
                localizedTables[key] = locTable
                return locTable?[key] ?? value ?? key
            }
        }
    }

    /// The localized strings tables for this bundle
    private var localizedTables: [String: [String: String]?] = [:]

}

#endif
