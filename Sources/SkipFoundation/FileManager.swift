// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.FileManager
@_implementationOnly import struct Foundation.FileAttributeKey
@_implementationOnly import struct Foundation.URLResourceKey
@_implementationOnly import struct Foundation.ObjCBool
@_implementationOnly import func Foundation.NSTemporaryDirectory
internal typealias PlatformFileManager = Foundation.FileManager
#else
#endif

/// An interface to the file system compatible with ``Foundation.FileManager``.
public class FileManager {
    #if SKIP
    /// Returns the shared single file manager
    public static var `default` = FileManager()
    #else
    static var `default` = FileManager(platformValue: PlatformFileManager.default)

    let platformValue: PlatformFileManager

    init(platformValue: PlatformFileManager) {
        self.platformValue = platformValue
    }
    #endif
}

#if SKIP // conversion from URLs and Strings to a java.nio.file.Path
private func _path(_ url: URL) -> java.nio.file.Path {
    url.toPath()
}

private func _path(_ path: String) -> java.nio.file.Path {
    java.nio.file.Paths.get(path)
}
#endif

public extension String {
    func write(to url: URL, atomically useAuxiliaryFile: Bool, encoding enc: PlatformStringEncoding) throws {
        #if !SKIP
        try write(to: url.platformValue, atomically: useAuxiliaryFile, encoding: enc.platformValue)
        #else
        var opts: [java.nio.file.StandardOpenOption] = []
        opts.append(java.nio.file.StandardOpenOption.CREATE)
        opts.append(java.nio.file.StandardOpenOption.WRITE)
        if useAuxiliaryFile {
            opts.append(java.nio.file.StandardOpenOption.DSYNC)
            opts.append(java.nio.file.StandardOpenOption.SYNC)
        }
        java.nio.file.Files.write(_path(url), self.data(using: enc)?.platformValue, *(opts.toList().toTypedArray()))
        #endif
    }

    func write(toFile path: String, atomically useAuxiliaryFile: Bool, encoding enc: PlatformStringEncoding) throws {
        #if !SKIP
        try write(toFile: path, atomically: useAuxiliaryFile, encoding: enc.platformValue)
        #else
        var opts: [java.nio.file.StandardOpenOption] = []
        opts.append(java.nio.file.StandardOpenOption.CREATE)
        opts.append(java.nio.file.StandardOpenOption.WRITE)
        if useAuxiliaryFile {
            opts.append(java.nio.file.StandardOpenOption.DSYNC)
            opts.append(java.nio.file.StandardOpenOption.SYNC)
        }
        java.nio.file.Files.write(_path(path), self.data(using: enc)?.platformValue, *(opts.toList().toTypedArray()))
        #endif
    }
}

extension FileManager {
    public var temporaryDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
    
    public func createSymbolicLink(at url: URL, withDestinationURL destinationURL: URL) throws {
        #if !SKIP
        try platformValue.createSymbolicLink(at: url.foundationURL, withDestinationURL: destinationURL.foundationURL)
        #else
        java.nio.file.Files.createSymbolicLink(_path(url), _path(destinationURL))
        #endif
    }

    public func createSymbolicLink(atPath path: String, withDestinationPath destinationPath: String) throws {
        #if !SKIP
        try platformValue.createSymbolicLink(atPath: path, withDestinationPath: destinationPath)
        #else
        java.nio.file.Files.createSymbolicLink(_path(path), _path(destinationPath))
        #endif
    }

    public func createDirectory(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        #if !SKIP
        try platformValue.createDirectory(at: url.foundationURL, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes?.rekey())
        #else
        let p = _path(url)
        if withIntermediateDirectories == true {
            java.nio.file.Files.createDirectories(p)
        } else {
            java.nio.file.Files.createDirectory(p)
        }
        if let attributes = attributes {
            try setAttributes(attributes, ofItemAtPath: p.toString())
        }
        #endif
    }

    public func createDirectory(atPath path: String, withIntermediateDirectories: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        #if !SKIP
        return try platformValue.createDirectory(atPath: path, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes?.rekey())
        #else
        if withIntermediateDirectories == true {
            java.nio.file.Files.createDirectories(_path(path))
        } else {
            java.nio.file.Files.createDirectory(_path(path))
        }
        if let attributes = attributes {
            setAttributes(attributes, ofItemAtPath: path)
        }
        #endif
    }

    public func destinationOfSymbolicLink(atPath path: String) throws -> String {
        #if !SKIP
        return try platformValue.destinationOfSymbolicLink(atPath: path)
        #else
        return java.nio.file.Files.readSymbolicLink(_path(path)).toString()
        #endif
    }

    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        #if !SKIP
        return try platformValue.attributesOfItem(atPath: path).rekey()
        #else
        // As a convenience, NSDictionary provides a set of methods (declared as a category on NSDictionary) for quickly and efficiently obtaining attribute information from the returned dictionary: fileGroupOwnerAccountName(), fileModificationDate(), fileOwnerAccountName(), filePosixPermissions(), fileSize(), fileSystemFileNumber(), fileSystemNumber(), and fileType().

        let p = _path(path)

        var attrs: [FileAttributeKey: Any] = [FileAttributeKey: Any]()
        let battrs = java.nio.file.Files.readAttributes(p, java.nio.file.attribute.BasicFileAttributes.self.java)

        let size = battrs.size()
        attrs[FileAttributeKey.size] = size
        let creationTime = battrs.creationTime()
        attrs[FileAttributeKey.creationDate] = Date(PlatformDate(creationTime.toMillis()))
        let lastModifiedTime = battrs.lastModifiedTime()
        attrs[FileAttributeKey.modificationDate] = Date(PlatformDate(creationTime.toMillis()))
        //let lastAccessTime = battrs.lastAccessTime()

        let isDirectory = battrs.isDirectory()
        let isRegularFile = battrs.isRegularFile()
        let isSymbolicLink = battrs.isSymbolicLink()
        if isDirectory {
            attrs[FileAttributeKey.type] = FileAttributeType.typeDirectory
        } else if isSymbolicLink {
            attrs[FileAttributeKey.type] = FileAttributeType.typeSymbolicLink
        } else if isRegularFile {
            attrs[FileAttributeKey.type] = FileAttributeType.typeRegular
        } else {
            // TODO: typeCharacterSpecial and typeBlockSpecial and typeSocket
            attrs[FileAttributeKey.type] = FileAttributeType.typeUnknown
        }

        let fileKey = battrs.fileKey()
        // let referenceCount = fileKey.referenceCount()
        // attrs[FileAttributeKey.referenceCount] = 1 // TODO: is there a way to find this in Java?

        let isOther = battrs.isOther()

        if java.nio.file.Files.getFileAttributeView(p, java.nio.file.attribute.PosixFileAttributeView.self.java) != nil {
            let pattrs = java.nio.file.Files.readAttributes(p, java.nio.file.attribute.PosixFileAttributes.self.java)
            let owner = pattrs.owner()
            let ownerName = owner.getName()
            attrs[FileAttributeKey.ownerAccountName] = ownerName
            // attrs[FileAttributeKey.ownerAccountID] = owner.uid

            let group = pattrs.owner()
            let groupName = group.getName()
            attrs[FileAttributeKey.groupOwnerAccountName] = groupName
            // attrs[FileAttributeKey.groupOwnerAccountID] = group.gid

            let permissions = pattrs.permissions()
            var perm = 0
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.OWNER_READ) {
                perm = perm | 256
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.OWNER_WRITE) {
                perm = perm | 128
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.OWNER_EXECUTE) {
                perm = perm | 64
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.GROUP_READ) {
                perm = perm | 32
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.GROUP_WRITE) {
                perm = perm | 16
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.GROUP_EXECUTE) {
                perm = perm | 8
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.OTHERS_READ) {
                perm = perm | 4
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.OTHERS_WRITE) {
                perm = perm | 2
            }
            if permissions.contains(java.nio.file.attribute.PosixFilePermission.OTHERS_EXECUTE) {
                perm = perm | 1
            }
            attrs[FileAttributeKey.posixPermissions] = perm
        }

        return attrs
        #endif
    }

    public func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAtPath path: String) throws {
        #if !SKIP
        try platformValue.setAttributes(attributes.rekey(), ofItemAtPath: path)
        #else
        for (key, value) in attributes {
            switch key {
            case FileAttributeKey.posixPermissions:
                let number = (value as Number).toInt()
                var permissions = Set<java.nio.file.attribute.PosixFilePermission>()
                if ((number & 256) != 0) { // 0o400
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.OWNER_READ)
                }
                if ((number & 128) != 0) { // 0o200
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.OWNER_WRITE)
                }
                if ((number & 64) != 0) { // 0o100
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.OWNER_EXECUTE)
                }
                if ((number & 32) != 0) { // 0o40
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.GROUP_READ)
                }
                if ((number & 16) != 0) { // 0o20
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.GROUP_WRITE)
                }
                if ((number & 8) != 0) { // 0o10
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.GROUP_EXECUTE)
                }
                if ((number & 4) != 0) { // 0o4
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.OTHERS_READ)
                }
                if ((number & 2) != 0) { // 0o2
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.OTHERS_WRITE)
                }
                if ((number & 1) != 0) { // 0o1
                    permissions.insert(java.nio.file.attribute.PosixFilePermission.OTHERS_EXECUTE)
                }
                java.nio.file.Files.setPosixFilePermissions(_path(path), permissions.toSet())
                
            case FileAttributeKey.modificationDate:
                if let date = value as? Date {
                    java.nio.file.Files.setLastModifiedTime(_path(path), java.nio.file.attribute.FileTime.fromMillis(Long(date.timeIntervalSince1970 * 1000.0)))
                }

            default:
                // unhandled keys are expected to be ignored by test_setFileAttributes
                continue
            }
        }
        #endif
    }

    public func createFile(atPath path: String, contents: Data? = nil, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
        #if !SKIP
        return platformValue.createFile(atPath: path, contents: contents?.platformValue, attributes: attributes?.rekey())
        #else
        do {
            java.nio.file.Files.write(_path(path), (contents ?? Data(platformValue: PlatformData(size: 0))).platformValue)
            if let attributes = attributes {
                setAttributes(attributes, ofItemAtPath: path)
            }
            return true
        } catch {
            return false
        }
        #endif
    }

    public func copyItem(atPath path: String, toPath: String) throws {
        #if !SKIP
        try platformValue.copyItem(atPath: path, toPath: toPath)
        #else
        try copy(from: _path(path), to: _path(toPath), recursive: true)
        #endif
    }

    public func copyItem(at url: URL, to: URL) throws {
        #if !SKIP
        try platformValue.copyItem(at: url.platformValue, to: to.platformValue)
        #else
        try copy(from: _path(url), to: _path(to), recursive: true)
        #endif
    }

    public func moveItem(atPath path: String, toPath: String) throws {
        #if !SKIP
        try platformValue.moveItem(atPath: path, toPath: toPath)
        #else
        java.nio.file.Files.move(_path(path), _path(toPath))
        #endif
    }

    public func moveItem(at path: URL, to: URL) throws {
        #if !SKIP
        try platformValue.moveItem(at: path.platformValue, to: to.platformValue)
        #else
        java.nio.file.Files.move(path.toPath(), to.toPath())
        #endif
    }

    @available(*, unavailable)
    public func contentsEqual(atPath path1: String, andPath path2: String) -> Bool {
        #if !SKIP
        return platformValue.contentsEqual(atPath: path1, andPath: path2)
        #else
        // TODO: recursively compare folders and files, taking into account special files; see https://github.com/apple/swift-corelibs-foundation/blob/818de4858f3c3f72f75d25fbe94d2388ca653f18/Sources/Foundation/FileManager%2BPOSIX.swift#L997
        fatalError("contentsEqual is unimplemented in Skip")
        #endif
    }


    @available(*, unavailable, message: "changeCurrentDirectoryPath is unavailable in Skip: the current directory cannot be changed in the JVM")
    public func changeCurrentDirectoryPath(_ path: String) -> Bool {
        #if !SKIP
        return platformValue.changeCurrentDirectoryPath(path)
        #else
        fatalError("FileManager.changeCurrentDirectoryPath unavailable")
        #endif
    }

    public var currentDirectoryPath: String {
        #if !SKIP
        return platformValue.currentDirectoryPath
        #else
        return System.getProperty("user.dir")
        #endif
    }

    private func checkCancelled() throws {
        try Task.checkCancellation()
    }

    #if SKIP

    private func delete(path: java.nio.file.Path, recursive: Bool) throws {
        if !recursive {
            java.nio.file.Files.delete(path)
        } else {

            // Cannot use java.nio.file.Files.walk for recursive delete because it doesn't list directories post-visit
            //for file in java.nio.file.Files.walk(path) {
            //    java.nio.file.Files.delete(file)
            //}

            /* SKIP REPLACE:
            java.nio.file.Files.walkFileTree(path, object : java.nio.file.SimpleFileVisitor<java.nio.file.Path>() {
                override fun visitFile(file: java.nio.file.Path, attrs: java.nio.file.attribute.BasicFileAttributes): java.nio.file.FileVisitResult {
                    checkCancelled()
                    java.nio.file.Files.delete(file)
                    return java.nio.file.FileVisitResult.CONTINUE
                }

                override fun postVisitDirectory(dir: java.nio.file.Path, exc: java.io.IOException?): java.nio.file.FileVisitResult {
                    checkCancelled()
                    java.nio.file.Files.delete(dir)
                    return java.nio.file.FileVisitResult.CONTINUE
                }
             })
             */
            fatalError("Recursive delete implemented with java.nio.file.Files.walkFileTree")
        }
    }

    private func copy(from src: java.nio.file.Path, to dest: java.nio.file.Path, recursive: Bool) throws {
        if !recursive {
            java.nio.file.Files.copy(src, dest)
        } else {
            /* SKIP REPLACE:
            java.nio.file.Files.walkFileTree(src, object : java.nio.file.SimpleFileVisitor<java.nio.file.Path>() {
                override fun visitFile(file: java.nio.file.Path, attrs: java.nio.file.attribute.BasicFileAttributes): java.nio.file.FileVisitResult {
                    checkCancelled()
                    java.nio.file.Files.copy(from, dest.resolve(src.relativize(file)), java.nio.file.StandardCopyOption.REPLACE_EXISTING, java.nio.file.StandardCopyOption.COPY_ATTRIBUTES, java.nio.file.LinkOption.NOFOLLOW_LINKS)
                    return java.nio.file.FileVisitResult.CONTINUE
                }

                override fun preVisitDirectory(dir: java.nio.file.Path, attrs: java.nio.file.attribute.BasicFileAttributes): java.nio.file.FileVisitResult {
                    checkCancelled()
                    java.nio.file.Files.createDirectories(dest.resolve(src.relativize(dir)))
                    return java.nio.file.FileVisitResult.CONTINUE
                }
             })
             */
            fatalError("Recursive copy implemented with java.nio.file.Files.walkFileTree")
        }
    }
    #endif

    public func subpathsOfDirectory(atPath path: String) throws -> [String] {
        #if !SKIP
        return try platformValue.subpathsOfDirectory(atPath: path)
        #else
        var subpaths: [String] = []
        let p = _path(path)
        for file in java.nio.file.Files.walk(p) {
            if file != p { // exclude root file
                let relpath = p.relativize(file.normalize())
                subpaths.append(relpath.toString())
            }
        }
        return subpaths
        #endif
    }

    public func subpaths(atPath path: String) -> [String]? {
        #if !SKIP
        return platformValue.subpaths(atPath: path)
        #else
        return try? subpathsOfDirectory(atPath: path)
        #endif
    }

    public func removeItem(atPath path: String) throws {
        #if !SKIP
        try platformValue.removeItem(atPath: path)
        #else
        try delete(path: _path(path), recursive: true)
        #endif
    }

    public func removeItem(at url: URL) throws {
        #if !SKIP
        try platformValue.removeItem(at: url.foundationURL)
        #else
        try delete(path: _path(url), recursive: true)
        #endif
    }

    public func fileExists(atPath path: String) -> Bool {
        #if !SKIP
        return platformValue.fileExists(atPath: path)
        #else
        return java.nio.file.Files.exists(java.nio.file.Paths.get(path))
        #endif
    }

    public func fileExists(atPath path: String, isDirectory: inout ObjCBool) -> Bool {
        #if !SKIP
        var isDir: Foundation.ObjCBool = false
        let exists = platformValue.fileExists(atPath: path, isDirectory: &isDir)
        isDirectory.boolValue = isDir.boolValue
        return exists
        #else
        let p = _path(path)
        if java.nio.file.Files.isDirectory(p) {
            isDirectory = ObjCBool(true)
            return true
        } else if java.nio.file.Files.exists(p) {
            isDirectory = ObjCBool(false)
            return true
        } else {
            return false
        }
        #endif
    }

    public func isReadableFile(atPath path: String) -> Bool {
        #if !SKIP
        return platformValue.isReadableFile(atPath: path)
        #else
        return java.nio.file.Files.isReadable(_path(path))
        #endif
    }

    public func isExecutableFile(atPath path: String) -> Bool {
        #if !SKIP
        return platformValue.isExecutableFile(atPath: path)
        #else
        return java.nio.file.Files.isExecutable(_path(path))
        #endif
    }

    public func isDeletableFile(atPath path: String) -> Bool {
        #if !SKIP
        return platformValue.isDeletableFile(atPath: path)
        #else
        let p = _path(path)
        if !java.nio.file.Files.isWritable(p) {
            return false
        }
        // also check whether the parent path is writable
        if !java.nio.file.Files.isWritable(p.getParent()) {
            return false
        }
        return true
        #endif
    }

    public func isWritableFile(atPath path: String) -> Bool {
        #if !SKIP
        return platformValue.isWritableFile(atPath: path)
        #else
        return java.nio.file.Files.isWritable(_path(path))
        #endif
    }

    public func contentsOfDirectory(at url: URL, includingPropertiesForKeys: [URLResourceKey]?) throws -> [URL] {
        #if !SKIP
        return try platformValue.contentsOfDirectory(at: url.platformValue, includingPropertiesForKeys: includingPropertiesForKeys?.map({ Foundation.URLResourceKey(rawValue: $0.rawValue) }))
            .map({ URL($0) })
        #else
        // https://developer.android.com/reference/kotlin/java/nio/file/Files
        let shallowFiles = java.nio.file.Files.list(_path(url)).collect(java.util.stream.Collectors.toList())
        let contents = shallowFiles.map { URL(platformValue: $0.toUri().toURL()) }
        return Array(contents)
        #endif
    }

    public func contentsOfDirectory(atPath path: String) throws -> [String] {
        #if !SKIP
        return try platformValue.contentsOfDirectory(atPath: path)
        #else
        // https://developer.android.com/reference/kotlin/java/nio/file/Files
        let files = java.nio.file.Files.list(_path(path)).collect(java.util.stream.Collectors.toList())
        let contents = files.map { $0.toFile().getName() }
        return Array(contents)
        #endif
    }
}


public struct FileAttributeType : RawRepresentable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let typeDirectory: FileAttributeType = FileAttributeType(rawValue: "NSFileTypeDirectory")
    public static let typeRegular: FileAttributeType = FileAttributeType(rawValue: "NSFileTypeRegular")
    public static let typeSymbolicLink: FileAttributeType = FileAttributeType(rawValue: "NSFileTypeSymbolicLink")
    public static let typeSocket: FileAttributeType = FileAttributeType(rawValue: "NSFileTypeSocket")
    public static let typeCharacterSpecial: FileAttributeType = FileAttributeType(rawValue: "NSFileTypeCharacterSpecial")
    public static let typeBlockSpecial: FileAttributeType = FileAttributeType(rawValue: "NSFileTypeBlockSpecial")
    public static let typeUnknown: FileAttributeType = FileAttributeType(rawValue: "NSFileTypeUnknown")
}

public struct FileAttributeKey : RawRepresentable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let appendOnly: FileAttributeKey = FileAttributeKey(rawValue: "NSFileAppendOnly")
    public static let creationDate: FileAttributeKey = FileAttributeKey(rawValue: "NSFileCreationDate")
    public static let deviceIdentifier: FileAttributeKey = FileAttributeKey(rawValue: "NSFileDeviceIdentifier")
    public static let extensionHidden: FileAttributeKey = FileAttributeKey(rawValue: "NSFileExtensionHidden")
    public static let groupOwnerAccountID: FileAttributeKey = FileAttributeKey(rawValue: "NSFileGroupOwnerAccountID")
    public static let groupOwnerAccountName: FileAttributeKey = FileAttributeKey(rawValue: "NSFileGroupOwnerAccountName")
    public static let hfsCreatorCode: FileAttributeKey = FileAttributeKey(rawValue: "NSFileHFSCreatorCode")
    public static let hfsTypeCode: FileAttributeKey = FileAttributeKey(rawValue: "NSFileHFSTypeCode")
    public static let immutable: FileAttributeKey = FileAttributeKey(rawValue: "NSFileImmutable")
    public static let modificationDate: FileAttributeKey = FileAttributeKey(rawValue: "NSFileModificationDate")
    public static let ownerAccountID: FileAttributeKey = FileAttributeKey(rawValue: "NSFileOwnerAccountID")
    public static let ownerAccountName: FileAttributeKey = FileAttributeKey(rawValue: "NSFileOwnerAccountName")
    public static let posixPermissions: FileAttributeKey = FileAttributeKey(rawValue: "NSFilePosixPermissions")
    public static let protectionKey: FileAttributeKey = FileAttributeKey(rawValue: "NSFileProtectionKey")
    public static let referenceCount: FileAttributeKey = FileAttributeKey(rawValue: "NSFileReferenceCount")
    public static let systemFileNumber: FileAttributeKey = FileAttributeKey(rawValue: "NSFileSystemFileNumber")
    public static let systemFreeNodes: FileAttributeKey = FileAttributeKey(rawValue: "NSFileSystemFreeNodes")
    public static let systemFreeSize: FileAttributeKey = FileAttributeKey(rawValue: "NSFileSystemFreeSize")
    public static let systemNodes: FileAttributeKey = FileAttributeKey(rawValue: "NSFileSystemNodes")
    public static let systemNumber: FileAttributeKey = FileAttributeKey(rawValue: "NSFileSystemNumber")
    public static let systemSize: FileAttributeKey = FileAttributeKey(rawValue: "NSFileSystemSize")
    public static let type: FileAttributeKey = FileAttributeKey(rawValue: "NSFileType")
    public static let size: FileAttributeKey = FileAttributeKey(rawValue: "NSFileSize")
    public static let busy: FileAttributeKey = FileAttributeKey(rawValue: "NSFileBusy")
}

#if SKIP
/// The system temporary folder
public func NSTemporaryDirectory() -> String {
    return java.lang.System.getProperty("java.io.tmpdir")
}

/// The user's home directory.
public func NSHomeDirectory() -> String {
    return java.lang.System.getProperty("user.home")
}

/// The current user name.
public func NSUserName() -> String {
    return java.lang.System.getProperty("user.name")
}

public struct FileProtectionType : RawRepresentable, Hashable {
    public let rawValue: String
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

struct UnableToDeleteFileError : java.io.IOException {
    let path: String
}

struct UnableToCreateDirectory : java.io.IOException {
    let path: String
}
#endif
