// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class Bundle : Hashable, SwiftCustomBridged {
    public static let main = Bundle(location: .main)

    /// Each package will generate its own `Bundle.module` extension to access the local bundle.
    static var module: Bundle {
        _bundleModule
    }
    private static let _bundleModule = Bundle(for: Bundle.self)
    private static let lprojExtension = ".lproj" // _CFBundleLprojExtensionWithDot

    private let location: LocalizedStringResource.BundleDescription
    public let bundleURL: URL
    public let bundleIdentifier: String?


    internal var isLocalizedBundle: Bool {
        bundleURL.absoluteString.hasSuffix(Self.lprojExtension + "/")
    }

    public var description: String {
        return location.description
    }

    public init(location: LocalizedStringResource.BundleDescription) {
        self.location = location
        AssetURLProtocol.register() // ensure that we can handle the "asset:/" URL protocol
        switch location {
        case .atURL(let url):
            self.bundleURL = url
            self.bundleIdentifier = nil
        case .main:
            let identifer = Self.packageName(forClassName: applicationInfo.className)
            self.bundleIdentifier = identifer
            self.bundleURL = Self.createBundleURL(forPackage: identifer)
        case .forClass(let cls):
            let identifer = Self.packageName(forClassName: cls.java.name)
            self.bundleIdentifier = identifer
            self.bundleURL = Self.createBundleURL(forPackage: identifer)
        }
    }

    public var resourceURL: URL? {
        return bundleURL // note: this isn't how traditional bundles work
    }

    /// Convert `showcase.module.AndroidAppMain` into `showcase.module`
    private static func packageName(forClassName: String?) -> String {
        // applicationInfo.className is nil when testing on the Android emulator
        let className = forClassName ?? "skip.foundation.Bundle"
        return className.split(separator: ".").dropLast().joined(separator: ".")
    }

    /// Convert `showcase.module` into `asset:/showcase/module/Resources`
    private static func createBundleURL(forPackage packageName: String) -> URL {
        let parts = packageName.replace(".", "/")
        let url = URL(string: AssetURLProtocol.scheme + ":/" + parts + "/Resources")!
        return url
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

    /// Creates a relative path to the given bundle URL
    private func relativeBundleURL(path: String, validate: Bool) -> URL? {
        let relativeURL = resourceURL?.appendingPathComponent(path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? path)
        if validate, let relativeURL {
            if relativeURL.scheme == AssetURLProtocol.scheme {
                // check the AssetManager to see if the URL exists
                let assets = ProcessInfo.processInfo.androidContext.resources.assets
                guard let assetDir = relativeURL.deletingLastPathComponent().path.removingPercentEncoding?.trim("/"[0]) else {
                    return nil
                }
                guard let assetBasename = relativeURL.lastPathComponent.removingPercentEncoding else {
                    return nil
                }
                guard let elements = assets.list(assetDir), elements.count() > 0 else {
                    return nil
                }
                if !elements.contains(assetBasename) {
                    // if the parent folder does not contain the basename, then the asset is not present
                    return nil
                }
            } else if relativeURL.isFileURL {
                if !FileManager.default.fileExists(atPath: relativeURL.path) {
                    return nil // the file or directory does not exist
                }
            } else {
                // unknown protocol … what to do?
            }
        }
        return relativeURL
    }

    public static func url(forResource name: String?, withExtension ext: String? = nil, subdirectory subpath: String? = nil, in bundleURL: URL) -> URL? {
        return Bundle(url: bundleURL)?.url(forResource: name, withExtension: ext, subdirectory: subpath)
    }

    public static func urls(forResourcesWithExtension ext: String?, subdirectory subpath: String?, in bundleURL: URL) -> [URL]? {
        return Bundle(url: bundleURL)?.urls(forResourcesWithExtension: ext, subdirectory: subpath)
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
            res = localization + Self.lprojExtension + "/" + res
        }
        if let subdirectory = subdirectory {
            res = subdirectory + "/" + res
        }

        return relativeBundleURL(path: res, validate: true)
    }

    public func urls(forResourcesWithExtension ext: String?, subdirectory subpath: String? = nil, localization localizationName: String? = nil) -> [URL]? {
        var filteredResources = resourcesIndex
        if let localization = localizationName {
            filteredResources = filteredResources.filter { $0.hasPrefix("\(localization)\(Self.lprojExtension)/") }
        }
        if let subpath {
            filteredResources = filteredResources.filter { $0.hasPrefix("\(subpath)/") }
        }
        if let ext {
            let extWithDot = ext.hasPrefix(".") ? ext : ".\(ext)"
            filteredResources = filteredResources.filter { $0.hasSuffix(extWithDot) }
        }
        let resourceURLs = filteredResources.compactMap { relativeBundleURL(path: $0, validate: true) }
        return resourceURLs.isEmpty ? nil : resourceURLs
    }

    public static func path(forResource name: String?, ofType ext: String?, inDirectory bundlePath: String) -> String? {
        return Bundle(path: bundlePath)?.path(forResource: name, ofType: ext)
    }

    public static func paths(forResourcesOfType ext: String?, inDirectory bundlePath: String) -> [String] {
        return Bundle(path: bundlePath)?.paths(forResourcesOfType: ext) ?? []
    }

    public func path(forResource: String? = nil, ofType: String? = nil, inDirectory: String? = nil, forLocalization: String? = nil) -> String? {
        url(forResource: forResource, withExtension: ofType, subdirectory: inDirectory, localization: forLocalization)?.path
    }

    public func paths(forResourcesOfType ext: String?, inDirectory subpath: String? = nil, forLocalization localizationName: String? = nil) -> [String] {
        return urls(forResourcesWithExtension: ext, subdirectory: subpath, localization: localizationName)?
            .compactMap { $0.path } ?? []
    }

    /// An index of all the assets in the AssetManager relative to the resourceURL for the AssetManager
    public lazy var resourcesIndex: [String] = {
        let basePath = (resourceURL?.path ?? "").trim("/"[0]) // AssetManager paths are relative, not absolute
        let resourcePaths = Self.listAssets(in: basePath, recursive: true)
        let resourceIndexPaths = resourcePaths.map { $0.dropFirst(basePath.count + 1) }
        return resourceIndexPaths
    }()

    static func listAssets(in folderName: String, recursive: Bool) -> [String] {
        let am = ProcessInfo.processInfo.androidContext.resources.assets
        guard let contents = am.list(folderName) else { return [] }
        let contentArray = Array(contents.toList()).map({ folderName + "/" + $0})
        if !recursive { return contentArray }
        return contentArray + contentArray.flatMap({ listAssets(in: $0, recursive: recursive) })
    }

    /// We default to en as the development localization
    public var developmentLocalization: String { "en" }

    /// Identify the Bundle's localizations by the presence of a `LOCNAME.lproj/` folder in index of the root of the resources folder
    public lazy var localizations: [String] = {
        return resourcesIndex
            .compactMap({ $0.components(separatedBy: "/").first })
            .filter({ $0.hasSuffix(Self.lprojExtension) })
            .filter({ $0 != "base.lproj" })
            .map({ $0.dropLast(Self.lprojExtension.count) })
            .distinctValues()
    }()

    /// The localized strings tables for this bundle
    private var localizedTables: MutableMap<String, MutableMap<String, Triple<String, String, MarkdownNode?>>> = mutableMapOf()

    public func localizedString(forKey key: String, value: String?, table tableName: String?, locale: Locale? = nil) -> String {
        return localizedInfo(forKey: key, value: value, table: tableName, locale: locale)?.first ?? value ?? key
    }

    /// Check for the localized key for the given Locale's localized bundle, falling back to the "base.lproj" bundle and then just checking the top-level bundle.
    /// The result will be cached for future lookup.
    public func localizedInfo(forKey key: String, value: String?, table tableName: String?, locale: Locale?) -> Triple<String, String, MarkdownNode?> {
        if self.isLocalizedBundle {
            // when the bundle is itself already a localized Bundle (e.g., from a top-level bundle the use gets "fr.lproj", then we ignore the local parameter and instead look it up directly in the current bundle
            if let info = self.lookupLocalizableString(forKey: key, value: value, table: tableName, fallback: true) {
                return info
            }
        }

        // attempt to get the given locale's bundle, fall back to the "base.lproj" locale, and then fall back to self
        if let info = localizedBundle(locale: locale ?? Locale.current)?.lookupLocalizableString(forKey: key, value: value, table: tableName) {
            return info
        }

        // attempt to look up the string in the baseLocale ("base.lproj"), and fall back to the current bundle if it is not present
        if let info = (localizedBundle(locale: Locale.baseLocale) ?? self).lookupLocalizableString(forKey: key, value: value, table: tableName) {
            return info
        }

        // create a fallback key if it could not be found in any of the localized bundles
        let info = self.lookupLocalizableString(forKey: key, value: value, table: tableName, fallback: true)!
        return info
    }

    /// Localize the given string, returning a string suitable for Kotlin/Java formatting rather than Swift formatting.
    private func lookupLocalizableString(forKey key: String, value: String?, table tableName: String?, fallback: Bool = false) -> Triple<String, String, MarkdownNode?>? {
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

            // If we have specified a fallback bundle (e.g., for a default localization), then call into that
            if let value {
                // We can't cache this in case different values are passed on different calls
                return Triple(value, value.kotlinFormatString, MarkdownNode.from(string: value))
            } else if fallback {
                // only cache the miss if we specify fallback; this is so we can cache this only for the top-level bundle
                let formats = Triple(key, key.kotlinFormatString, MarkdownNode.from(string: key))
                locTable![key] = formats
                return formats
            } else {
                return nil
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
                if locBundle == nil,
                   let locstrURL = self.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: localeid),
                   let locBundleLocal = try? Bundle(url: locstrURL.deletingLastPathComponent()) {
                    locBundle = locBundleLocal
                    //break // The feature "break continue in inline lambdas" is experimental and should be enabled explicitly
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

    /// The global Android context
    private static var androidContext: android.content.Context {
        ProcessInfo.processInfo.androidContext
    }

    private static var packageManager: android.content.pm.PackageManager {
        androidContext.getPackageManager()
    }

    private static var packageInfo: android.content.pm.PackageInfo? {
        return packageManager.getPackageInfo(androidContext.getPackageName(), android.content.pm.PackageManager.GET_META_DATA)
    }

    private static var applicationInfo: android.content.pm.ApplicationInfo {
        return androidContext.getApplicationInfo()
    }

    public var infoDictionary: [String : Any]? {
        // infoDictionary only supported for main bundle currently
        if location == .main {
            return Self.mainInfoDictionary
        } else {
            return nil
        }
    }

    /// The `Bundle.main.infoDictionary` with keys synthesized from various Android metadata accessors
    private static var mainInfoDictionary: [String : Any] {
        let packageManager = self.packageManager
        let packageInfo = self.packageInfo
        let applicationInfo = self.applicationInfo
        
        var info = [String : Any]()
        info["CFBundleIdentifier"] = Self.androidContext.getPackageName()
        let appLabel = packageManager.getApplicationLabel(applicationInfo)?.toString() ?? ""
        info["CFBundleName"] = appLabel
        info["CFBundleDisplayName"] = appLabel
        info["CFBundleShortVersionString"] = packageInfo?.versionName ?? ""
        if android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P {
            info["CFBundleVersion"] = packageInfo?.longVersionCode.toString() ?? "0"
        } else {
            info["CFBundleVersion"] = packageInfo?.versionCode.toString() ?? "0"
        }
        info["CFBundleExecutable"] = androidContext.getPackageName()
        info["DTPlatformName"] = "android"
        info["DTPlatformVersion"] = android.os.Build.VERSION.SDK_INT.toString()
        info["DTSDKName"] = "android" + android.os.Build.VERSION.SDK_INT.toString()
        info["BuildMachineOSBuild"] = android.os.Build.FINGERPRINT
        info["MinimumOSVersion"] = applicationInfo.minSdkVersion?.toString()
        info["CFBundleLocalizations"] = Bundle.main.localizations

        return info
    }

    public var localizedInfoDictionary: [String : Any]? {
        // currently no support for localized info on Android
        return infoDictionary
    }

    public func object(forInfoDictionaryKey key: String) -> Any? {
        infoDictionary?[key]
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
    return (bundle ?? Bundle.main).localizedString(forKey: key, value: value, table: tableName, locale: .current)
}

/// A localized string bundle with the key, the kotlin format, and optionally a markdown node
public struct LocalizedStringInfo {
    public let string: String
    public let kotlinFormat: String
    public let markdownNode: MarkdownNode?
}


#if SKIP
public typealias URLProtocol = java.net.URLStreamHandlerFactory
#endif

public class AssetURLProtocol: URLProtocol {
    /// The URL scheme that this protocol handles
    public static var scheme = "asset"

    private static var registered = false

    public static func register() {
        if registered { return }
        registered = true

        #if !SKIP
        URLProtocol.registerClass(AssetURLProtocol.self)
        #else
        java.net.URL.setURLStreamHandlerFactory(AssetURLProtocol())
        // cannot ever call this twice in the same JVM, or else:
        //java.net.URL.setURLStreamHandlerFactory(AssetStreamHandlerFactory()) // java.lang.Error: factory already defined
        #endif
    }

    #if !SKIP
    public override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.scheme == AssetURLProtocol.scheme
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        guard let client else { return }

        guard let url = request.url else {
            client.urlProtocol(self, didFailWithError: NSError(domain: "AssetURLProtocol", code: -1, userInfo: nil))
            return
        }

        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        let data = AssetURLProtocol.data.data(using: .utf8)!
        client.urlProtocol(self, didLoad: data)

        client.urlProtocolDidFinishLoading(self)
    }

    public override func stopLoading() {
        // no-op
    }
    #else
    private init() {
    }

    override func createURLStreamHandler(protocol: String) -> java.net.URLStreamHandler? {
        if `protocol` == AssetURLProtocol.scheme {
            return AssetStreamHandler()
        } else {
            return nil
        }
    }

    class AssetStreamHandler: java.net.URLStreamHandler {
        init() {
        }

        override func openConnection(url: java.net.URL) -> java.net.URLConnection {
            AssetURLConnection(url: url)
        }

        class AssetURLConnection: java.net.URLConnection {
            init(url: java.net.URL) {
                super.init(url)
            }

            override func connect() {
                // No-op
            }

            override func getInputStream() -> java.io.InputStream {
                // e.g.: asset:/skip/path/file.ext
                var urlPath = self.url.path
                while urlPath.startsWith("/") {
                    urlPath = urlPath.substring(1) // trim initial "/"
                }
                urlPath = urlPath.removingPercentEncoding ?? urlPath
                // removingPercentEncoding does not always convert "+" to "%2B" to a space, which the Android AssetManager needs to be able to find the file
                urlPath = urlPath.replacingOccurrences(of: "+", with: "%2B")
                urlPath = urlPath.replacingOccurrences(of: "%2B", with: " ")
                let assetManager = ProcessInfo.processInfo.androidContext.resources.assets
                // android.content.res.AssetManager$AssetInputStream
                let stream = assetManager.open(urlPath)
                return stream
            }
        }
    }
    #endif
}

#endif
