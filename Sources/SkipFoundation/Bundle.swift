// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class Bundle : Hashable {
    public static let main = Bundle(location: .main)

    private let location: SkipLocalizedStringResource.BundleDescription

    public init(location: SkipLocalizedStringResource.BundleDescription) {
        self.location = location
    }

    public convenience init?(path: String) {
        self.init(location: .atURL(URL(fileURLWithPath: path)))
    }

    public convenience init?(url: URL) {
        self.init(location: .atURL(url))
    }

    public init() {
        self.init(location: .forClass(Bundle.self))
    }

    public convenience init(for forClass: AnyClass) {
        self.init(location: .forClass(forClass))
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.location == rhs.location
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(location.hashCode())
    }

    public var description: String {
        return location.description
    }

    public var bundleURL: URL {
        let loc: SkipLocalizedStringResource.BundleDescription = location
        switch loc {
        case .atURL(let url):
            return url
        case.main, .forClass:
            return relativeBundleURL(Self.resourceIndexFileName)!
                .deletingLastPathComponent()
        }
    }

    public var resourceURL: URL? {
        return bundleURL // FIXME: this is probably not correct
    }

    /// Each package will generate its own `Bundle.module` extension to access the local bundle.
    static var module: Bundle {
        _bundleModule
    }
    private static let _bundleModule = Bundle(for: Bundle.self)

    /// Creates a relative path to the given bundle URL
    private func relativeBundleURL(path: String) -> URL? {
        let loc: SkipLocalizedStringResource.BundleDescription = location
        switch loc {
        case .main:
            let appContext = ProcessInfo.processInfo.androidContext
            let appClass = Class.forName(appContext.getApplicationInfo().className, true, appContext.getClassLoader())
            return relativeBundleURL(path: path, forClass: appClass)
        case .atURL(let url):
            return url.appendingPathComponent(path)
        case .forClass(let cls):
            return relativeBundleURL(path: path, forClass: cls.java)
        }
    }

    // SKIP DECLARE: private fun relativeBundleURL(path: String, forClass: Class<*>): URL?
    private func relativeBundleURL(path: String, forClass: Class<Any>) -> URL? {
        do {
            let rpath = "Resources/" + path
            let resURL = try forClass.getResource(rpath)
            return URL(platformValue: resURL)
        } catch {
            // getResource throws when it cannot find the resource, but it doesn't handle directories
            // such as .lproj folders; so manually scan the resources.lst elements, and if any
            // appear to be a directory, then just return that relative URL without validating its existance

            if path == Self.resourceIndexFileName {
                return nil // if the resources index itself is not found (which will be the case when the project has no resources), then do not try to load it
            }

            if self.resourcesIndex.contains(where: { $0.hasPrefix(path + "/") }) {
                return resourcesFolderURL?.appendingPathComponent(path, isDirectory: true)
            }
            return nil
        }
    }

    public var bundlePath: String {
        bundleURL.path
    }

    static let resourceIndexFileName = "resources.lst"

    /// The URL for the `resources.lst` resources index file that is created by the transpiler when converting resources files.
    private var resourcesIndexURL: URL? {
        url(forResource: Self.resourceIndexFileName)
    }

    /// The path to the base folder of the `Resources/` directory.
    ///
    /// In Robolectric, this will be a simple file system directory URL.
    /// On Android it will be something like `jar:file:/data/app/~~GrNJyKuGMG-gs4i97rlqHg==/skip.ui.test-5w0MhfIK6rNxUpG8yMuXgg==/base.apk!/skip/ui/Resources/`
    private var resourcesFolderURL: URL? {
        resourcesIndexURL?.deletingLastPathComponent()
    }

    /// Loads the resources index stored in the `resources.lst` file at the root of the resources folder.
    private lazy var resourcesIndex: [String] = {
        guard let resourceListURL = try self.resourcesIndexURL else {
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


    /// The localized strings tables for this bundle
    private var localizedTables: [String: [String: String]?] = [:]

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

    /// The individual loaded bundles by locale
    private var localizedBundles: [Locale: Bundle?] = [:]

    /// Looks up the Bundle for the given locale and returns it, caching the result in the process.
    public func localizedBundle(locale: Locale) -> Bundle {
        synchronized(self) {
            if let cached = self.localizedBundles[locale] {
                return cached ?? self
            }

            var locBundle: Bundle? = nil
            // for each identifier, attempt to load the Localizable.strings to see if it exists
            for localeid in locale.localeSearchTags {
                //print("trying localeid: \(localeid)")
                if locBundle == nil,
                   let locstrURL = self.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: localeid),
                   let locBundleLocal = try? Bundle(url: locstrURL.deletingLastPathComponent()) {
                    locBundle = locBundleLocal
                }
            }

            // cache the result of the lookup (even if it is nil)
            self.localizedBundles[locale] = locBundle

            // fall back to the top-level bundle, if available
            return locBundle ?? self
        }
    }
}

public func NSLocalizedString(_ key: String, tableName: String? = nil, bundle: Bundle? = nil, value: String? = nil, comment: String) -> String {
    return (bundle ?? Bundle.main).localizedString(forKey: key, value: value, table: tableName)
}

#endif
