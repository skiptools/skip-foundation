// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias NSURL = URL

public struct URL : Hashable, CustomStringConvertible, Codable {
    internal var platformValue: java.net.URL
    private let isDirectoryFlag: Bool?
    public let baseURL: URL?

    public var platformURL: java.net.URL { platformValue }

    public init(_ platformValue: java.net.URL, isDirectory: Bool? = nil, baseURL: URL? = nil) {
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
        return URL(ProcessInfo.processInfo.androidContext.getCacheDir().toURL(), isDirectory: true)
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
        return URL(ProcessInfo.processInfo.androidContext.getFilesDir().toURL(), isDirectory: true)
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

    public init(fileURLWithPath path: String, isDirectory: Bool? = nil, relativeTo base: URL? = nil) {
        self.platformValue = java.net.URL("file://" + path) // TODO: escaping
        self.baseURL = base // TODO: base resolution
        self.isDirectoryFlag = isDirectory ?? path.hasSuffix("/") // TODO: should we hit the file system like NSURL does?
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
        return platformValue.description
    }

    /// Converts this URL to a `java.nio.file.Path`.
    public func toPath() -> java.nio.file.Path {
        return java.nio.file.Paths.get(platformValue.toURI())
    }

    public var host: String? {
        return platformValue.host
    }

    public var hasDirectoryPath: Bool {
        return self.isDirectoryFlag == true
    }

    public var path: String {
        return platformValue.path
    }

    @available(*, unavailable)
    public var port: Int? {
        fatalError("TODO: implement port")
    }

    @available(*, unavailable)
    public var scheme: String? {
        fatalError("TODO: implement scheme")
    }

    @available(*, unavailable)
    public var query: String? {
        fatalError("TODO: implement query")
    }

    @available(*, unavailable)
    public var user: String? {
        fatalError("TODO: implement user")
    }

    @available(*, unavailable)
    public var password: String? {
        fatalError("TODO: implement password")
    }

    @available(*, unavailable)
    public var fragment: String? {
        fatalError("TODO: implement fragment")
    }

    public var standardized: URL {
        return URL(platformValue: toPath().normalize().toUri().toURL())
    }

    public var absoluteString: String {
        return platformValue.toExternalForm()
    }

    public var lastPathComponent: String {
        return pathComponents.lastOrNull() ?? ""
    }

    public var pathExtension: String {
        let parts = Array((lastPathComponent ?? "").split(separator: "."))
        if parts.count >= 2 {
            return parts.last!
        } else {
            return ""
        }
    }

    public var isFileURL: Bool {
        return platformValue.`protocol` == "file"
    }

    public var pathComponents: [String] {
        let path: String = platformValue.path
        return Array(path.split(separator: "/")).filter { !$0.isEmpty }
    }

    @available(*, unavailable)
    public var relativePath: String {
        fatalError("TODO: implement relativePath")
    }

    @available(*, unavailable)
    public var relativeString: String {
        fatalError("TODO: implement relativeString")
    }

    @available(*, unavailable)
    public var standardizedFileURL: URL {
        fatalError("TODO: implement standardizedFileURL")
    }

    public mutating func standardize() {
        self = standardized
    }

    public var absoluteURL: URL {
        return self
    }

    public func appendingPathComponent(_ pathComponent: String) -> URL {
        var url = self.platformValue.toExternalForm()
        if !url.hasSuffix("/") { url = url + "/" }
        url = url + pathComponent
        return URL(platformValue: java.net.URL(url))
    }

    public func appendingPathComponent(_ pathComponent: String, isDirectory: Bool) -> URL {
        var url = self.platformValue.toExternalForm()
        if !url.hasSuffix("/") { url = url + "/" }
        url = url + pathComponent
        return URL(platformValue: java.net.URL(url), isDirectory: isDirectory)
    }

    public func deletingLastPathComponent() -> URL {
        var url = self.platformValue.toExternalForm()
        while url.hasSuffix("/") && !url.isEmpty {
            url = url.dropLast(1)
        }
        while !url.hasSuffix("/") && !url.isEmpty {
            url = url.dropLast(1)
        }
        return URL(platformValue: java.net.URL(url))
    }

    public func appendingPathExtension(_ pathExtension: String) -> URL {
        var url = self.platformValue.toExternalForm()
        url = url + "." + pathExtension
        return URL(platformValue: java.net.URL(url))
    }

    public func deletingPathExtension() -> URL {
        let ext = pathExtension
        var url = self.platformValue.toExternalForm()
        while url.hasSuffix("/") {
            url = url.dropLast(1)
        }
        if url.hasSuffix("." + ext) {
            url = url.dropLast(ext.count + 1)
        }
        return URL(platformValue: java.net.URL(url))
    }

    public func resolvingSymlinksInPath() -> URL {
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
    }

    public mutating func resolveSymlinksInPath() {
        self = resolvingSymlinksInPath()
    }

    public func checkResourceIsReachable() throws -> Bool {
        if !isFileURL {
            // “This method is currently applicable only to URLs for file system resources. For other URL types, `false` is returned.”
            return false
        }
        // check whether the resource can be reached by opening and closing a connection
        platformValue.openConnection().getInputStream().close()
        return true
    }

    @available(*, unavailable)
    public mutating func removeAllCachedResourceValues() {
        fatalError("TODO: implement removeAllCachedResourceValues")
    }
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
    public var allValues: [URLResourceKey : Any]
}

public func URL(string: String, relativeTo baseURL: URL? = nil) -> URL? {
    do {
        let url = java.net.URL(relativeTo?.platformValue, string) // throws on malformed
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
