// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
public typealias NSURL = URL

public struct URL : Hashable, CustomStringConvertible, Codable, KotlinConverting<java.net.URI> {
    internal let platformValue: java.net.URI
    private let isDirectoryFlag: Bool?

    public let baseURL: URL?

    public init(platformValue: java.net.URI, isDirectory: Bool? = nil, baseURL: URL? = nil) {
        self.platformValue = platformValue
        self.isDirectoryFlag = isDirectory
        self.baseURL = baseURL
    }

    public init(_ url: URL) {
        self.platformValue = url.platformValue
        self.isDirectoryFlag = url.isDirectoryFlag
        self.baseURL = url.baseURL
    }

    public static func currentDirectory() -> URL {
        URL(fileURLWithPath: System.getProperty("user.dir"), isDirectory: true)
    }

    public static var homeDirectory: URL {
        URL(fileURLWithPath: System.getProperty("user.home"), isDirectory: true)
    }

    public static var temporaryDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    public static var cachesDirectory: URL {
        return URL(platformValue: ProcessInfo.processInfo.androidContext.getCacheDir().toURI(), isDirectory: true)
    }

    @available(*, unavailable)
    public static var applicationDirectory: URL {
        fatalError("applicationDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var libraryDirectory: URL {
        fatalError("libraryDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var userDirectory: URL {
        fatalError("desktopDirectory unimplemented in Skip")
    }

    public static var documentsDirectory: URL {
        return URL(platformValue: ProcessInfo.processInfo.androidContext.getFilesDir().toURI(), isDirectory: true)
    }

    @available(*, unavailable)
    public static var desktopDirectory: URL {
        fatalError("desktopDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var applicationSupportDirectory: URL {
        fatalError("applicationSupportDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var downloadsDirectory: URL {
        fatalError("downloadsDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var moviesDirectory: URL {
        fatalError("moviesDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var musicDirectory: URL {
        fatalError("musicDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var picturesDirectory: URL {
        fatalError("picturesDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var sharedPublicDirectory: URL {
        fatalError("sharedPublicDirectory unimplemented in Skip")
    }

    @available(*, unavailable)
    public static var trashDirectory: URL {
        fatalError("trashDirectory unimplemented in Skip")
    }

    public init?(string: String, relativeTo baseURL: URL? = nil) {
        guard let url = URL(string: string, encodingInvalidCharacters: true) else {
            return nil
        }
        self.platformValue = url.platformValue
        self.baseURL = baseURL
        // Use the same logic as the constructor so that `URL(fileURLWithPath: "/tmp/") == URL(string: "file:///tmp/")`
        let scheme = baseURL?.platformValue.scheme ?? self.platformValue.scheme
        self.isDirectoryFlag = scheme == "file" && string.hasSuffix("/")
    }

    public init?(string: String, encodingInvalidCharacters: Bool) {
        do {
            self.platformValue = java.net.URI(string) // throws on malformed
        } catch {
            guard encodingInvalidCharacters, let queryIndex = string.firstIndex(of: "?") else {
                return nil
            }
            // As of iOS 17, URLs are automatically encoded if needed. We're only doing the query
            let base = string.prefix(upTo: queryIndex)
            let query = string.suffix(from: queryIndex + 1)
            let queryItems = URLQueryItem.from(query)?.map { URLQueryItem(name: $0.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "", value: $0.value?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)) }
            let encodedQuery = URLQueryItem.queryString(from: queryItems)
            do {
                self.platformValue = java.net.URI(base + "?" + (encodedQuery ?? ""))
            } catch {
                return nil
            }
        }
        self.baseURL = nil
        self.isDirectoryFlag = self.platformValue.scheme == "file" && string.hasSuffix("/")
    }

    public init(fileURLWithPath path: String, isDirectory: Bool? = nil, relativeTo base: URL? = nil) {
        self.platformValue = java.net.URI("file://" + path) // TODO: escaping
        self.baseURL = base
        self.isDirectoryFlag = isDirectory ?? path.hasSuffix("/") // TODO: should we hit the file system like NSURL does?
    }

    @available(*, unavailable)
    init(fileURLWithFileSystemRepresentation: Any, isDirectory: Bool, relativeTo: URL? = nil, unusedp: Nothing? = nil) {
        self.platformValue = java.net.URI("")
        self.baseURL = nil
        self.isDirectoryFlag = false
    }

    @available(*, unavailable)
    public init(fileReferenceLiteralResourceName: String) {
        self.platformValue = java.net.URI("")
        self.baseURL = nil
        self.isDirectoryFlag = false
    }

    @available(*, unavailable)
    init(resolvingBookmarkData: Data, options: Any? = nil, relativeTo: URL? = nil, bookmarkDataIsStale: inout Bool) {
        self.platformValue = java.net.URI("")
        self.baseURL = nil
        self.isDirectoryFlag = false
    }

    @available(*, unavailable)
    init(resolvingAliasFileAt: URL, options: Any? = nil) throws {
        self.platformValue = java.net.URI("")
        self.baseURL = nil
        self.isDirectoryFlag = false
    }

    @available(*, unavailable)
    init?(resource: URLResource) {
        self.platformValue = java.net.URI("")
        self.baseURL = nil
        self.isDirectoryFlag = false
    }

    @available(*, unavailable)
    init(_ parseInput: Any, strategy: Any, unusedp: Nothing? = nil) {
        self.platformValue = java.net.URI("")
        self.baseURL = nil
        self.isDirectoryFlag = false
    }

    @available(*, unavailable)
    public init?(dataRepresentation: Data, relativeTo: URL?, isAbsolute: Bool) {
        self.platformValue = java.net.URI("")
        self.baseURL = nil
        self.isDirectoryFlag = false
    }

    public init(from decoder: Decoder) throws {
        let container = decoder.singleValueContainer()
        self = URL(string: container.decode(String.self))!
    }

    public func encode(to encoder: Encoder) throws {
        let container = encoder.singleValueContainer()
        container.encode(absoluteString)
    }

    public var description: String {
        return platformValue.toString()
    }

    /// Converts this URL to a `java.nio.file.Path`.
    public func toPath() -> java.nio.file.Path {
        return java.nio.file.Paths.get(absoluteURL.platformValue)
    }

    public var host: String? {
        return absoluteURL.platformValue.host
    }

    public func host(percentEncoded: Bool = true) -> String? {
        return absoluteURL.platformValue.host
    }

    public var hasDirectoryPath: Bool {
        return self.isDirectoryFlag == true
    }

    public var path: String {
        return absoluteURL.platformValue.path ?? ""
    }

    public func path(percentEncoded: Bool = true) -> String? {
        return percentEncoded ? absoluteURL.platformValue.rawPath : absoluteURL.platformValue.path
    }

    public var port: Int? {
        let port = absoluteURL.platformValue.port
        return port == -1 ? nil : port
    }

    public var scheme: String? {
        return absoluteURL.platformValue.scheme
    }

    public var query: String? {
        return absoluteURL.platformValue.query
    }

    public func query(percentEncoded: Bool = true) -> String? {
        return percentEncoded ? absoluteURL.platformValue.rawQuery : absoluteURL.platformValue.query
    }

    @available(*, unavailable)
    public var user: String? {
        fatalError()
    }

    @available(*, unavailable)
    public func user(percentEncoded: Bool = true) -> String? {
        fatalError()
    }

    @available(*, unavailable)
    public var password: String? {
        fatalError()
    }

    @available(*, unavailable)
    public func password(percentEncoded: Bool = true) -> String? {
        fatalError()
    }

    public var fragment: String? {
        return absoluteURL.platformValue.fragment
    }

    public func fragment(percentEncoded: Bool = true) -> String? {
        return percentEncoded ? absoluteURL.platformValue.rawFragment : absoluteURL.platformValue.fragment
    }

    @available(*, unavailable)
    public var dataRepresentation: Data {
        fatalError()
    }

    public var standardized: URL {
        return URL(platformValue: toPath().normalize().toUri())
    }

    public var absoluteString: String {
        return absoluteURL.platformValue.toString()
    }

    public var lastPathComponent: String {
        return pathComponents.last ?? ""
    }

    public var pathExtension: String {
        guard let lastPathComponent = pathComponents.last else {
            return ""
        }
        let parts = lastPathComponent.split(separator: ".")
        return parts.count >= 2 ? parts.last! : ""
    }

    public var isFileURL: Bool {
        return scheme == "file"
    }

    public var pathComponents: [String] {
        return path.split(separator: "/").filter { !$0.isEmpty }
    }

    public var relativePath: String {
        return platformValue.path
    }

    public var relativeString: String {
        return platformValue.toString()
    }

    public var standardizedFileURL: URL {
        return isFileURL ? standardized : self
    }

    public mutating func standardize() {
        self = standardized
    }

    public var absoluteURL: URL {
        if let baseURL = self.baseURL {
            return URL(platformValue: baseURL.platformValue.resolve(platformValue))
        } else {
            return self
        }
    }

    public func appendingPathComponent(_ pathComponent: String) -> URL {
        var string = absoluteString
        if !string.hasSuffix("/") { string = string + "/" }
        string = string + pathComponent
        return URL(platformValue: java.net.URI(string))
    }

    public func appendingPathComponent(_ pathComponent: String, isDirectory: Bool) -> URL {
        var string = absoluteString
        if !string.hasSuffix("/") { string = string + "/" }
        string = string + pathComponent
        return URL(platformValue: java.net.URI(string), isDirectory: isDirectory)
    }

    public mutating func appendPathComponent(_ pathComponent: String) {
        self = appendingPathComponent(pathComponent)
    }

    public mutating func appendPathComponent(_ pathComponent: String, isDirectory: Bool) {
        self = appendingPathComponent(pathComponent, isDirectory: isDirectory)
    }

    @available(*, unavailable)
    public func appendingPathComponent(_ pathComponent: String, conformingTo type: Any) -> URL {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func appendPathComponent(_ pathComponent: String, conformingTo type: Any) {
        fatalError()
    }

    public func appendingPathExtension(_ pathExtension: String) -> URL {
        var string = absoluteString
        string = string + "." + pathExtension
        return URL(platformValue: java.net.URI(string))
    }

    public mutating func appendPathExtension(_ pathExtension: String) {
        self = appendingPathExtension(pathExtension)
    }

    @available(*, unavailable)
    public func appendingPathExtension(for type: Any, unusedp: Nothing? = nil) -> URL {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func appendPathExtension(for type: Any, unusedp: Nothing? = nil) {
        fatalError()
    }

    public func deletingLastPathComponent() -> URL {
        var string = absoluteString
        while string.hasSuffix("/") && !string.isEmpty {
            string = string.dropLast(1)
        }
        while !string.hasSuffix("/") && !string.isEmpty {
            string = string.dropLast(1)
        }
        return URL(platformValue: java.net.URI(string))
    }

    public mutating func deleteLastPathComponent() {
        self = deletingLastPathComponent()
    }

    public func deletingPathExtension() -> URL {
        let ext = pathExtension
        var string = absoluteString
        while string.hasSuffix("/") {
            string = string.dropLast(1)
        }
        if string.hasSuffix("." + ext) {
            string = string.dropLast(ext.count + 1)
        }
        return URL(platformValue: java.net.URI(string))
    }

    public mutating func deletePathExtension() {
        self = deletingPathExtension()
    }

    public func resolvingSymlinksInPath() -> URL {
        guard isFileURL else {
            return self
        }
        let originalPath = toPath()
        //if !java.nio.file.Files.isSymbolicLink(originalPath) {
        //    return self // not a link
        //} else {
        //    let normalized = java.nio.file.Files.readSymbolicLink(originalPath).normalize()
        //    return URL(platformValue: normalized.toUri().toURL())
        //}
        do {
            return URL(platformValue: originalPath.toRealPath().toUri())
        } catch {
            // this will fail if the file does not exist, but Foundation expects it to return the path itself
            return self
        }
    }

    public mutating func resolveSymlinksInPath() {
        self = resolvingSymlinksInPath()
    }

    public func checkResourceIsReachable() throws -> Bool {
        guard isFileURL else {
            // “This method is currently applicable only to URLs for file system resources. For other URL types, `false` is returned.”
            return false
        }
        // check whether the resource can be reached by opening and closing a connection
        platformValue.toURL().openConnection().getInputStream().close()
        return true
    }

    @available(*, unavailable)
    public func resourceValues(forKeys: Set<URLResourceKey>) -> URLResourceValues {
        fatalError()
    }

    @available(*, unavailable)
    public func setResourceValues(_ values: URLResourceValues) {
        fatalError()
    }

    @available(*, unavailable)
    public func removeCachedResourceValue(forKey: URLResourceKey) {
        fatalError()
    }

    @available(*, unavailable)
    public func setTemporaryResourceValue(_ value: Any, forKey: URLResourceKey) {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func removeAllCachedResourceValues() {
        fatalError()
    }

    @available(*, unavailable)
    public func bookmarkData(options: Any, includingResourceValuesForKeys: Set<URLResourceKey>?, relativeTo: URL?) -> Data {
        fatalError()
    }

    @available(*, unavailable)
    public static func bookmarkData(withContentsOf: URL) -> Data {
        fatalError()
    }

    @available(*, unavailable)
    public static func writeBookmarkData(_ data: Data, to: URL) {
        fatalError()
    }

    @available(*, unavailable)
    public var resourceBytes: Any {
        fatalError()
    }

    @available(*, unavailable)
    public var lines: Any {
        fatalError()
    }

    @available(*, unavailable)
    public func checkPromisedItemIsReachable() -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func promisedItemResourceValues(forKeys: Set<URLResourceKey>) -> URLResourceValues {
        fatalError()
    }

    @available(*, unavailable)
    public func startAccessingSecurityScopedResource() -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func stopAccessingSecurityScopedResource() {
        fatalError()
    }

    public override func kotlin(nocopy: Bool = false) -> java.net.URI {
        return platformValue
    }
}

public struct URLResource: Hashable {
    public let bundle: Bundle
    public let name: String
    public let subdirectory: String?
    public let locale: Locale

    public init(name: String, subdirectory: String? = nil, locale: Locale = Locale.current, bundle: Bundle = Bundle.main) {
        self.bundle = bundle
        self.name = name
        self.subdirectory = subdirectory
        self.locale = locale
    }
}

public struct URLResourceKey : Hashable, Equatable, RawRepresentable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct URLResourceValues {
    public var allValues: [URLResourceKey : Any]
}

#endif
