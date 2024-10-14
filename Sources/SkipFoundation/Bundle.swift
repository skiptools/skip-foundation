// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class Bundle : Hashable {
    public static let main = Bundle(location: .main)

    /// Each package will generate its own `Bundle.module` extension to access the local bundle.
    static var module: Bundle {
        _bundleModule
    }
    private static let _bundleModule = Bundle(for: Bundle.self)

    private let location: LocalizedStringResource.BundleDescription

    public init(location: LocalizedStringResource.BundleDescription) {
        self.location = location
    }

    public convenience init?(path: String) {
        self.init(location: .atURL(URL(fileURLWithPath: path)))
    }

    public convenience init?(url: URL) {
        self.init(location: .atURL(url))
    }

    public convenience init(for forClass: AnyClass) {
        self.init(location: .forClass(forClass))
    }

    public init() {
        self.init(location: .forClass(Bundle.self))
    }

    @available(*, unavailable)
    public convenience init?(identifier: String) {
        self.init(location: .main)
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

    @available(*, unavailable)
    public static var allBundles: [Bundle] {
        fatalError()
    }

    @available(*, unavailable)
    public static var allFrameworks: [Bundle] {
        fatalError()
    }

    @available(*, unavailable)
    public func load() -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var isLoaded: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func unload() -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func preflight() throws {
    }

    @available(*, unavailable)
    public func loadAndReturnError() throws {
    }

    public var bundleURL: URL {
        let loc: LocalizedStringResource.BundleDescription = location
        switch loc {
        case .atURL(let url):
            return url
        case.main, .forClass:
            return relativeBundleURL(Self.resourceIndexFileName)!
                .deletingLastPathComponent()
        }
    }

    /// Creates a relative path to the given bundle URL
    private func relativeBundleURL(path: String) -> URL? {
        let loc: LocalizedStringResource.BundleDescription = location
        switch loc {
        case .main:
            let appContext = ProcessInfo.processInfo.androidContext
            let className = appContext.getApplicationInfo().className
            // className can be null when running in emulator unit tests
            if className == nil {
                return nil
            }
            // ClassLoader will be something like: dalvik.system.PathClassLoader[DexPathList[[zip file "/data/app/~~TsW3puiwg61p2gVvq_TiHQ==/skip.ui.test-6R4Fcu0a4CkedPWcML2mGA==/base.apk"],nativeLibraryDirectories=[/data/app/~~TsW3puiwg61p2gVvq_TiHQ==/skip.ui.test-6R4Fcu0a4CkedPWcML2mGA==/lib/arm64, /system/lib64, /system_ext/lib64]]]
            let appClass = Class.forName(className, true, appContext.getClassLoader() ?? Thread.currentThread().getContextClassLoader())
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
            return URL(platformValue: resURL.toURI())
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

    public var resourceURL: URL? {
        return bundleURL // FIXME: this is probably not correct
    }

    @available(*, unavailable)
    public var executableURL: URL? {
        fatalError()
    }

    @available(*, unavailable)
    open func url(forAuxiliaryExecutable executableName: String) -> URL? {
        fatalError()
    }

    @available(*, unavailable)
    open var privateFrameworksURL: URL? {
        fatalError()
    }

    @available(*, unavailable)
    open var sharedFrameworksURL: URL? {
        fatalError()
    }

    @available(*, unavailable)
    open var sharedSupportURL: URL? {
        fatalError()
    }

    @available(*, unavailable)
    open var builtInPlugInsURL: URL? {
        fatalError()
    }

    @available(*, unavailable)
    open var appStoreReceiptURL: URL? {
        fatalError()
    }

    public var bundlePath: String {
        bundleURL.path
    }

    public var resourcePath: String? {
        resourceURL?.path
    }

    @available(*, unavailable)
    public var executablePath: String? {
        fatalError()
    }

    @available(*, unavailable)
    public func path(forAuxiliaryExecutable executableName: String) -> String? {
        fatalError()
    }

    @available(*, unavailable)
    public var privateFrameworksPath: String? {
        fatalError()
    }

    @available(*, unavailable)
    public var sharedFrameworksPath: String? {
        fatalError()
    }

    @available(*, unavailable)
    public var sharedSupportPath: String? {
        fatalError()
    }

    @available(*, unavailable)
    public var builtInPlugInsPath: String? {
        fatalError()
    }

    @available(*, unavailable)
    public static func url(forResource name: String?, withExtension ext: String? = nil, subdirectory subpath: String? = nil, in bundleURL: URL) -> URL? {
        fatalError()
    }

    public func url(forResource: String? = nil, withExtension: String? = nil, subdirectory: String? = nil, localization: String? = nil) -> URL? {
        // similar behavior to: https://github.com/apple/swift-corelibs-foundation/blob/69ab3975ea636d1322ad19bbcea38ce78b65b26a/CoreFoundation/PlugIn.subproj/CFBundle_Resources.c#L1114
        var res = forResource ?? ""
        if let withExtension = withExtension, !withExtension.isEmpty {
            // TODO: If `forResource` is nil, we are expected to find the first file in the bundle whose extension matches
            if !withExtension.hasPrefix(".") {
                res += "."
            }
            res += withExtension
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

    @available(*, unavailable)
    public func urls(forResourcesWithExtension ext: String?, subdirectory subpath: String? = nil, localization localizationName: String? = nil) -> [URL]? {
        fatalError()
    }

    @available(*, unavailable)
    public static func path(forResource name: String?, ofType ext: String?, inDirectory bundlePath: String) -> String? {
        fatalError()
    }

    @available(*, unavailable)
    public static func paths(forResourcesOfType ext: String?, inDirectory bundlePath: String) -> [String] {
        fatalError()
    }

    public func path(forResource: String? = nil, ofType: String? = nil, inDirectory: String? = nil, forLocalization: String? = nil) -> String? {
        url(forResource: forResource, withExtension: ofType, subdirectory: inDirectory, localization: forLocalization)?.path
    }

    @available(*, unavailable)
    public func paths(forResourcesOfType ext: String?, inDirectory subpath: String? = nil, forLocalization localizationName: String? = nil) -> [String] {
        fatalError()
    }

    private static let resourceIndexFileName = "resources.lst"

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
    public lazy var resourcesIndex: [String] = {
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

    /// The localized strings tables for this bundle
    private var localizedTables: MutableMap<String, MutableMap<String, Triple<String, String, MarkdownNode?>>> = mutableMapOf()

    public func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return localizedInfo(forKey: key, value: value, table: tableName).first
    }

    /// Localize the given string, returning a string suitable for Kotlin/Java formatting rather than Swift formatting.
    public func localizedInfo(forKey key: String, value: String?, table tableName: String?) -> Triple<String, String, MarkdownNode?> {
        synchronized(self) {
            let table = tableName ?? "Localizable"
            var locTable = localizedTables[table]
            if locTable == nil {
                let resURL = url(forResource: table, withExtension: "strings")
                let resTable = resURL == nil ? nil : try? PropertyListSerialization.propertyList(from: Data(contentsOf: resURL!), format: nil)
                locTable = Self.stringFormatsTable(from: resTable)
                localizedTables[table] = locTable!
            }
            if let formats = locTable?[key] {
                return formats
            }

            if let value {
                // We can't cache this in case different values are passed on different calls
                return Triple(value, value.kotlinFormatString, MarkdownNode.from(string: value))
            } else {
                let formats = Triple(key, key.kotlinFormatString, MarkdownNode.from(string: key))
                locTable![key] = formats
                return formats
            }
        }
    }

    private static func stringFormatsTable(from table: [String: String]?) -> MutableMap<String, Triple<String, String, MarkdownNode?>> {
        guard let table else {
            return mutableMapOf()
        }
        // We cache both the format string and its Kotlin-ized and parsed markdown version so that `localizedKotlinFormatInfo`
        // doesn't have to do the conversion each time and is fast for use in `SwiftUI.Text` implicit localization
        let formatsTable = mutableMapOf<String, Triple<String, String, MarkdownNode?>>()
        for (key, value) in table {
            formatsTable[key] = Triple(value, value.kotlinFormatString, MarkdownNode.from(string: value))
        }
        return formatsTable
    }

    /// The individual loaded bundles by locale
    private var localizedBundles: MutableMap<Locale, Bundle> = mutableMapOf()

    /// Looks up the Bundle for the given locale and returns it, caching the result in the process.
    public func localizedBundle(locale: Locale) -> Bundle {
        synchronized(self) {
            if let cached = self.localizedBundles[locale] {
                return cached
            }

            var locBundle: Bundle? = nil
            // for each identifier, attempt to load the Localizable.strings to see if it exists
            for localeid in locale.localeSearchTags {
                //print("trying localeid: \(localeid)")
                if locBundle == nil, let locstrURL = self.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: localeid), let locBundleLocal = try? Bundle(url: locstrURL.deletingLastPathComponent()) {
                    locBundle = locBundleLocal
                }
            }

            // cache the result of the lookup
            let resBundle = locBundle ?? self
            self.localizedBundles[locale] = resBundle
            return resBundle
        }
    }

    @available(*, unavailable)
    public var preferredLocalizations: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public static func preferredLocalizations(from localizationsArray: [String], forPreferences preferencesArray: [String]? = nil) -> [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var bundleIdentifier: String? {
        fatalError()
    }

    @available(*, unavailable)
    public var infoDictionary: [String : Any]? {
        fatalError()
    }

    @available(*, unavailable)
    public var localizedInfoDictionary: [String : Any]? {
        fatalError()
    }

    @available(*, unavailable)
    public func object(forInfoDictionaryKey key: String) -> Any? {
        fatalError()
    }

    @available(*, unavailable)
    public func classNamed(_ className: String) -> AnyClass? {
        fatalError()
    }

    @available(*, unavailable)
    public var principalClass: AnyClass? {
        fatalError()
    }

    @available(*, unavailable)
    public var executableArchitectures: [NSNumber]? {
        fatalError()
    }
}

public func NSLocalizedString(_ key: String, tableName: String? = nil, bundle: Bundle? = Bundle.main, value: String? = nil, comment: String) -> String {
    let localBundle = (bundle ?? Bundle.main).localizedBundle(locale: .current)
    let value = localBundle.localizedString(forKey: key, value: value, table: tableName)
    return value
}

/// A localized string bundle with the key, the kotlin format, and optionally a markdown node
public struct LocalizedStringInfo {
    public let string: String
    public let kotlinFormat: String
    public let markdownNode: MarkdownNode?
}

#endif
