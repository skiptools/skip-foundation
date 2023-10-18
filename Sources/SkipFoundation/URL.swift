// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.URL
@_implementationOnly import struct Foundation.URLResourceKey
@_implementationOnly import struct Foundation.URLResourceValues
@_implementationOnly import class Foundation.NSURL
internal typealias PlatformURL = Foundation.URL
internal typealias NSURL = Foundation.NSURL
#else
public typealias PlatformURL = java.net.URL
public typealias NSURL = URL
#endif

public struct URL : Hashable, CustomStringConvertible, Encodable {
    internal var platformValue: PlatformURL
    #if SKIP
    private let isDirectoryFlag: Bool?
    public let baseURL: URL?

    public init(_ platformValue: PlatformURL, isDirectory: Bool? = nil, baseURL: URL? = nil) {
        self.platformValue = platformValue
        self.isDirectoryFlag = isDirectory
        self.baseURL = baseURL
    }

    public init(_ url: URL) {
        self.platformValue = url.platformValue
        self.isDirectoryFlag = url.isDirectoryFlag
        self.baseURL = url.baseURL
    }
    #else
    internal init(_ platformValue: PlatformURL) {
        self.platformValue = platformValue
    }

    internal init(platformValue: PlatformURL) {
        self.platformValue = platformValue
    }
    #endif

    public init(fileURLWithPath path: String, isDirectory: Bool? = nil, relativeTo base: URL? = nil) {
        #if SKIP
        self.platformValue = PlatformURL("file://" + path) // TODO: escaping
        self.baseURL = base // TODO: base resolution
        self.isDirectoryFlag = isDirectory ?? path.hasSuffix("/") // TODO: should we hit the file system like NSURL does?
        #else
        if let isDirectory = isDirectory {
            if let base = base {
                self.platformValue = Foundation.URL(fileURLWithPath: path, isDirectory: isDirectory, relativeTo: base.platformValue)
            } else {
                self.platformValue = Foundation.URL(fileURLWithPath: path, isDirectory: isDirectory)
            }
        } else {
            if let base = base {
                self.platformValue = Foundation.URL(fileURLWithPath: path, relativeTo: base.platformValue)
            } else {
                self.platformValue = Foundation.URL(fileURLWithPath: path)
            }
        }
        #endif
    }

    public init(from decoder: Decoder) throws {
        #if !SKIP
        self.platformValue = try PlatformURL(from: decoder)
        #else
        self.platformValue = SkipCrash("TODO: Decoder")
        self.isDirectoryFlag = SkipCrash("TODO: Decoder")
        self.baseURL = SkipCrash("TODO: Decoder")
        #endif
    }

    public func encode(to encoder: Encoder) throws {
        #if !SKIP
        try platformValue.encode(to: encoder)
        #else
        fatalError("SKIP TODO")
        #endif
    }

    public var description: String {
        return platformValue.description
    }

    #if SKIP
    /// Converts this URL to a `java.nio.file.Path`.
    public func toPath() -> java.nio.file.Path {
        return java.nio.file.Paths.get(platformValue.toURI())
    }
    #endif

    #if !SKIP
    // The base URL. It is provided as a member in SKIP but a calculated property in Swift
    public var baseURL: URL? {
        return foundationURL.baseURL.flatMap({ .init(platformValue: $0 as PlatformURL) })
    }
    #endif

    public var host: String? {
        #if SKIP
        return platformValue.host
        #else
        return foundationURL.host
        #endif
    }

    public var hasDirectoryPath: Bool {
        #if SKIP
        return self.isDirectoryFlag == true
        #else
        return foundationURL.hasDirectoryPath
        #endif
    }

    public var path: String {
        #if SKIP
        return platformValue.path
        #else
        return foundationURL.path
        #endif
    }

    @available(*, unavailable)
    public var port: Int? {
        #if SKIP
        fatalError("TODO: implement port")
        #else
        return foundationURL.port
        #endif
    }

    @available(*, unavailable)
    public var scheme: String? {
        #if SKIP
        fatalError("TODO: implement scheme")
        #else
        return foundationURL.scheme
        #endif
    }

    @available(*, unavailable)
    public var query: String? {
        #if SKIP
        fatalError("TODO: implement query")
        #else
        return foundationURL.query
        #endif
    }

    @available(*, unavailable)
    public var user: String? {
        #if SKIP
        fatalError("TODO: implement user")
        #else
        return foundationURL.user
        #endif
    }

    @available(*, unavailable)
    public var password: String? {
        #if SKIP
        fatalError("TODO: implement password")
        #else
        return foundationURL.password
        #endif
    }

    @available(*, unavailable)
    public var fragment: String? {
        #if SKIP
        fatalError("TODO: implement fragment")
        #else
        return foundationURL.fragment
        #endif
    }

    public var standardized: URL {
        #if SKIP
        return URL(platformValue: toPath().normalize().toUri().toURL())
        #else
        return Self(foundationURL.standardized as PlatformURL)
        #endif
    }

    public var absoluteString: String {
        #if SKIP
        return platformValue.toExternalForm()
        #else
        return foundationURL.absoluteString
        #endif
    }

    public var lastPathComponent: String {
        #if SKIP
        return pathComponents.lastOrNull() ?? ""
        #else
        return foundationURL.lastPathComponent
        #endif
    }

    public var pathExtension: String {
        #if SKIP
        let parts = Array((lastPathComponent ?? "").split(separator: "."))
        if parts.count >= 2 {
            return parts.last!
        } else {
            return ""
        }
        #else
        return foundationURL.pathExtension
        #endif
    }

    public var isFileURL: Bool {
        #if SKIP
        return platformValue.`protocol` == "file"
        #else
        return foundationURL.isFileURL
        #endif
    }

    public var pathComponents: [String] {
        #if SKIP
        let path: String = platformValue.path
        return Array(path.split(separator: "/")).filter { !$0.isEmpty }
        #else
        return foundationURL.pathComponents
        #endif
    }

    @available(*, unavailable)
    public var relativePath: String {
        #if SKIP
        fatalError("TODO: implement relativePath")
        #else
        return foundationURL.relativePath
        #endif
    }

    @available(*, unavailable)
    public var relativeString: String {
        #if SKIP
        fatalError("TODO: implement relativeString")
        #else
        return foundationURL.relativeString
        #endif
    }

    @available(*, unavailable)
    public var standardizedFileURL: URL {
        #if SKIP
        fatalError("TODO: implement standardizedFileURL")
        #else
        return Self(foundationURL.standardizedFileURL as PlatformURL)
        #endif
    }

    public mutating func standardize() {
        #if SKIP
        self = standardized
        #else
        platformValue.standardize()
        #endif
    }

    public var absoluteURL: URL {
        #if SKIP
        return self
        #else
        return Self(foundationURL.absoluteURL as PlatformURL)
        #endif
    }

    public func appendingPathComponent(_ pathComponent: String) -> URL {
        #if SKIP
        var url = self.platformValue.toExternalForm()
        if !url.hasSuffix("/") { url = url + "/" }
        url = url + pathComponent
        return URL(platformValue: PlatformURL(url))
        #else
        return Self(foundationURL.appendingPathComponent(pathComponent) as PlatformURL)
        #endif
    }

    public func appendingPathComponent(_ pathComponent: String, isDirectory: Bool) -> URL {
        #if SKIP
        var url = self.platformValue.toExternalForm()
        if !url.hasSuffix("/") { url = url + "/" }
        url = url + pathComponent
        return URL(platformValue: PlatformURL(url), isDirectory: isDirectory)
        #else
        return Self(foundationURL.appendingPathComponent(pathComponent, isDirectory: isDirectory) as PlatformURL)
        #endif
    }

    public func deletingLastPathComponent() -> URL {
        #if SKIP
        var url = self.platformValue.toExternalForm()
        while url.hasSuffix("/") && !url.isEmpty {
            url = url.dropLast(1)
        }
        while !url.hasSuffix("/") && !url.isEmpty {
            url = url.dropLast(1)
        }
        return URL(platformValue: PlatformURL(url))
        #else
        return Self(foundationURL.deletingLastPathComponent() as PlatformURL)
        #endif
    }

    public func appendingPathExtension(_ pathExtension: String) -> URL {
        #if SKIP
        var url = self.platformValue.toExternalForm()
        url = url + "." + pathExtension
        return URL(platformValue: PlatformURL(url))
        #else
        return Self(foundationURL.appendingPathExtension(pathExtension) as PlatformURL)
        #endif
    }

    public func deletingPathExtension() -> URL {
        #if SKIP
        let ext = pathExtension
        var url = self.platformValue.toExternalForm()
        while url.hasSuffix("/") {
            url = url.dropLast(1)
        }
        if url.hasSuffix("." + ext) {
            url = url.dropLast(ext.count + 1)
        }
        return URL(platformValue: PlatformURL(url))
        #else
        return Self(foundationURL.deletingPathExtension() as PlatformURL)
        #endif
    }

    public func resolvingSymlinksInPath() -> URL {
        #if SKIP
        if isFileURL == false {
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
            return URL(platformValue: originalPath.toRealPath().toUri().toURL())
        } catch {
            // this will fail if the file does not exist, but Foundation expects it to return the path itself
            return self
        }
        #else
        return Self(foundationURL.resolvingSymlinksInPath() as PlatformURL)
        #endif
    }

    public mutating func resolveSymlinksInPath() {
        #if SKIP
        self = resolvingSymlinksInPath()
        #else
        platformValue.resolveSymlinksInPath()
        #endif
    }

    public func checkResourceIsReachable() throws -> Bool {
        #if SKIP
        if !isFileURL {
            // “This method is currently applicable only to URLs for file system resources. For other URL types, `false` is returned.”
            return false
        }
        // check whether the resource can be reached by opening and closing a connection
        platformValue.openConnection().getInputStream().close()
        return true
        #else
        return try self.foundationURL.checkResourceIsReachable()
        #endif
    }

    @available(*, unavailable)
    public mutating func removeAllCachedResourceValues() {
        #if SKIP
        fatalError("TODO: implement removeAllCachedResourceValues")
        #else
        foundationURL.removeAllCachedResourceValues()
        #endif
    }

    #if !SKIP
    @available(*, unavailable)
    public func resourceValues(forKeys keys: Set<URLResourceKey>) throws -> URLResourceValues {
        #if SKIP
        fatalError("TODO: implement resourceValues")
        #else
        let platformKeys = keys.map({ Foundation.URLResourceKey(rawValue: $0.rawValue) })
        let platformValue = try foundationURL.resourceValues(forKeys: Set(platformKeys))
        return URLResourceValues(platformValue: platformValue)
        #endif
    }

    @available(*, unavailable)
    public mutating func setResourceValues(_ values: URLResourceValues) throws -> Void {
        #if SKIP
        fatalError("TODO: implement setResourceValues")
        #else
        try foundationURL.setResourceValues(values.platformValue)
        #endif
    }
    #endif
}


// MARK: Optional Constructors

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
    #if !SKIP
    internal var platformValue: Foundation.URLResourceValues

    internal init(platformValue: Foundation.URLResourceValues) {
        self.platformValue = platformValue
    }
    #else
    public var allValues: [URLResourceKey : Any]
    #endif
}

#if SKIP
public func URL(string: String, relativeTo baseURL: URL? = nil) -> URL? {
    do {
        let url = PlatformURL(relativeTo?.platformValue, string) // throws on malformed
        // use the same logic as the constructor so that `URL(fileURLWithPath: "/tmp/") == URL(string: "file:///tmp/")`
        let isDirectory = url.`protocol` == "file" && string.hasSuffix("/")
        return URL(url, isDirectory: isDirectory, baseURL: baseURL)
    } catch {
        // e.g., malformed URL
        return nil
    }
}

//public func URL(fileURLWithPath path: String, relativeTo: URL? = nil, isDirectory: Bool? = nil) -> URL {
//    URL(fileURLWithPath: path, relativeTo: relativeTo, isDirectory: isDirectory)
//}

//public func URL(fileURLWithFileSystemRepresentation path: String, relativeTo: URL?, isDirectory: Bool) -> URL {
//    // SKIP INSERT: val nil = null
//    if (relativeTo != nil) {
//        return URL(platformValue: PlatformURL(relativeTo?.platformValue, path))
//    } else {
//        return URL(platformValue: PlatformURL("file://" + path)) // TODO: isDirectory handling?
//    }
//}

extension String {
    public var deletingLastPathComponent: String {
        let lastSeparatorIndex = lastIndexOf("/")
        if lastSeparatorIndex == -1 || (lastSeparatorIndex == 0 && self.length == 1) {
            return self
        }
        let newPath = substring(0, lastSeparatorIndex)
        let newLastSeparatorIndex = newPath.lastIndexOf("/")
        if newLastSeparatorIndex == -1 {
            return newPath
        } else {
            return newPath.substring(0, newLastSeparatorIndex + 1)
        }
    }
}

#else

// MARK: Foundation.URL compatibility

extension URL {
    internal var foundationURL: Foundation.URL {
        get { platformValue as Foundation.URL }
        set { platformValue = newValue as PlatformURL }
    }

    public init?(string: String) {
        guard let url = Foundation.URL(string: string) else {
            return nil
        }
        self.platformValue = url as PlatformURL
    }

    public init?(string: String, relativeTo: URL?) {
        guard let url = Foundation.URL(string: string, relativeTo: relativeTo?.platformValue as Foundation.URL?) else {
            return nil
        }
        self.platformValue = url as PlatformURL
    }

    public init(fileURLWithPath path: String) {
        self.platformValue = PlatformURL(fileURLWithPath: path)
    }

    public init(fileURLWithPath path: String, relativeTo: URL? = nil) {
        self.platformValue = PlatformURL(fileURLWithPath: path, relativeTo: relativeTo?.platformValue as Foundation.URL?)
    }

    public init(fileURLWithPath path: String, isDirectory: Bool, relativeTo: URL? = nil) {
        self.platformValue = PlatformURL(fileURLWithPath: path, isDirectory: isDirectory, relativeTo: relativeTo?.platformValue as Foundation.URL?)
    }

    public init(fileURLWithFileSystemRepresentation path: String, isDirectory: Bool, relativeTo: URL? = nil) {
        self.platformValue = PlatformURL(fileURLWithPath: path, isDirectory: isDirectory, relativeTo: relativeTo?.platformValue as Foundation.URL?)
    }
}

extension Foundation.URL {
    /// Shim to support parity for test cases
    internal var foundationURL: Foundation.URL { self }
}

#endif

#if SKIP
extension URL {
    public func kotlin(nocopy: Bool = false) -> java.net.URL {
        return platformValue
    }
}

extension java.net.URL {
    public func swift(nocopy: Bool = false) -> URL {
        return URL(platformValue: self)
    }
}
#endif
