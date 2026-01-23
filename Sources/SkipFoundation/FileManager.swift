// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

func platformFilePath(for url: URL) -> java.nio.file.Path {
    url.toPath()
}

func platformFilePath(for path: String) -> java.nio.file.Path {
    java.nio.file.Paths.get(path)
}

public class FileManager {
    public static let `default` = FileManager()

    public var temporaryDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
    
    public func createSymbolicLink(at url: URL, withDestinationURL destinationURL: URL) throws {
        java.nio.file.Files.createSymbolicLink(platformFilePath(for: url), platformFilePath(for: destinationURL))
    }

    public func createSymbolicLink(atPath path: String, withDestinationPath destinationPath: String) throws {
        java.nio.file.Files.createSymbolicLink(platformFilePath(for: path), platformFilePath(for: destinationPath))
    }

    public func createDirectory(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        let p = platformFilePath(for: url)
        if withIntermediateDirectories == true {
            java.nio.file.Files.createDirectories(p)
        } else {
            java.nio.file.Files.createDirectory(p)
        }
        if let attributes = attributes {
            try setAttributes(attributes, ofItemAtPath: p.toString())
        }
    }

    public func createDirectory(atPath path: String, withIntermediateDirectories: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        if withIntermediateDirectories == true {
            java.nio.file.Files.createDirectories(platformFilePath(for: path))
        } else {
            java.nio.file.Files.createDirectory(platformFilePath(for: path))
        }
        if let attributes = attributes {
            setAttributes(attributes, ofItemAtPath: path)
        }
    }

    public func destinationOfSymbolicLink(atPath path: String) throws -> String {
        return java.nio.file.Files.readSymbolicLink(platformFilePath(for: path)).toString()
    }

    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        // As a convenience, NSDictionary provides a set of methods (declared as a category on NSDictionary) for quickly and efficiently obtaining attribute information from the returned dictionary: fileGroupOwnerAccountName(), fileModificationDate(), fileOwnerAccountName(), filePosixPermissions(), fileSize(), fileSystemFileNumber(), fileSystemNumber(), and fileType().

        let p = platformFilePath(for: path)

        var attrs: [FileAttributeKey: Any] = [FileAttributeKey: Any]()
        let battrs = java.nio.file.Files.readAttributes(p, java.nio.file.attribute.BasicFileAttributes.self.java)

        let size = battrs.size()
        attrs[FileAttributeKey.size] = size
        let creationTime = battrs.creationTime()
        attrs[FileAttributeKey.creationDate] = Date(java.util.Date(creationTime.toMillis()))
        let lastModifiedTime = battrs.lastModifiedTime()
        attrs[FileAttributeKey.modificationDate] = Date(java.util.Date(creationTime.toMillis()))
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
    }

    public func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAtPath path: String) throws {
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
                java.nio.file.Files.setPosixFilePermissions(platformFilePath(for: path), permissions.toSet())

            case FileAttributeKey.modificationDate:
                if let date = value as? Date {
                    java.nio.file.Files.setLastModifiedTime(platformFilePath(for: path), java.nio.file.attribute.FileTime.fromMillis(Long(date.timeIntervalSince1970 * 1000.0)))
                }

            default:
                // unhandled keys are expected to be ignored by test_setFileAttributes
                continue
            }
        }
    }

    public func createFile(atPath path: String, contents: Data? = nil, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
        do {
            java.nio.file.Files.write(platformFilePath(for: path), (contents ?? Data(platformValue: PlatformData(size: 0))).platformValue)
            if let attributes = attributes {
                setAttributes(attributes, ofItemAtPath: path)
            }
            return true
        } catch {
            return false
        }
    }

    public func copyItem(atPath path: String, toPath: String) throws {
        try copy(from: platformFilePath(for: path), to: platformFilePath(for: toPath), recursive: true)
    }

    public func copyItem(at url: URL, to: URL) throws {
        try copy(from: platformFilePath(for: url), to: platformFilePath(for: to), recursive: true)
    }

    public func moveItem(atPath path: String, toPath: String) throws {
        java.nio.file.Files.move(platformFilePath(for: path), platformFilePath(for: toPath))
    }

    public func moveItem(at path: URL, to: URL) throws {
        java.nio.file.Files.move(path.toPath(), to.toPath())
    }

    @available(*, unavailable)
    public func contentsEqual(atPath path1: String, andPath path2: String) -> Bool {
        // TODO: recursively compare folders and files, taking into account special files; see https://github.com/apple/swift-corelibs-foundation/blob/818de4858f3c3f72f75d25fbe94d2388ca653f18/Sources/Foundation/FileManager%2BPOSIX.swift#L997
        fatalError("contentsEqual is unimplemented in Skip")
    }

    @available(*, unavailable, message: "changeCurrentDirectoryPath is unavailable in Skip: the current directory cannot be changed in the JVM")
    public func changeCurrentDirectoryPath(_ path: String) -> Bool {
        fatalError("FileManager.changeCurrentDirectoryPath unavailable")
    }

    public var currentDirectoryPath: String {
        return System.getProperty("user.dir")
    }

    private func checkCancelled() throws {
        try Task.checkCancellation()
    }

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

    public func subpathsOfDirectory(atPath path: String) throws -> [String] {
        var subpaths: [String] = []
        let p = platformFilePath(for: path)
        let stream = java.nio.file.Files.walk(p)
        defer {
            stream.close()
        }
        for file in stream {
            if file != p { // exclude root file
                let relpath = p.relativize(file.normalize())
                subpaths.append(relpath.toString())
            }
        }
        return subpaths
    }

    public func subpaths(atPath path: String) -> [String]? {
        return try? subpathsOfDirectory(atPath: path)
    }

    public func removeItem(atPath path: String) throws {
        try delete(path: platformFilePath(for: path), recursive: true)
    }

    public func removeItem(at url: URL) throws {
        try delete(path: platformFilePath(for: url), recursive: true)
    }

    public func fileExists(atPath path: String) -> Bool {
        return java.nio.file.Files.exists(java.nio.file.Paths.get(path))
    }

    public func fileExists(atPath path: String, isDirectory: inout ObjCBool) -> Bool {
        let p = platformFilePath(for: path)
        if java.nio.file.Files.isDirectory(p) {
            isDirectory = ObjCBool(true)
            return true
        } else if java.nio.file.Files.exists(p) {
            isDirectory = ObjCBool(false)
            return true
        } else {
            return false
        }
    }

    public func isReadableFile(atPath path: String) -> Bool {
        return java.nio.file.Files.isReadable(platformFilePath(for: path))
    }

    public func isExecutableFile(atPath path: String) -> Bool {
        return java.nio.file.Files.isExecutable(platformFilePath(for: path))
    }

    public func isDeletableFile(atPath path: String) -> Bool {
        let p = platformFilePath(for: path)
        if !java.nio.file.Files.isWritable(p) {
            return false
        }
        // also check whether the parent path is writable
        if !java.nio.file.Files.isWritable(p.getParent()) {
            return false
        }
        return true
    }

    public func isWritableFile(atPath path: String) -> Bool {
        return java.nio.file.Files.isWritable(platformFilePath(for: path))
    }

    public func contentsOfDirectory(at url: URL, includingPropertiesForKeys: [URLResourceKey]?) throws -> [URL] {
        // https://developer.android.com/reference/kotlin/java/nio/file/Files
        let stream = java.nio.file.Files.list(platformFilePath(for: url))
        defer {
            stream.close()
        }
        let shallowFiles = stream.collect(java.util.stream.Collectors.toList())
        let contents = shallowFiles.map { URL(platformValue: $0.toUri()) }
        return Array(contents)
    }

    public func contentsOfDirectory(atPath path: String) throws -> [String] {
        // https://developer.android.com/reference/kotlin/java/nio/file/Files
        let stream = java.nio.file.Files.list(platformFilePath(for: path))
        defer {
            stream.close()
        }
        let files = stream.collect(java.util.stream.Collectors.toList())
        let contents = files.map { $0.toFile().getName() }
        return Array(contents)
    }

    public func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask, appropriateFor url: URL?, create shouldCreate: Bool) throws -> URL {
        let ctx = ProcessInfo.processInfo.androidContext
        switch directory {
        case .documentDirectory: return URL.documentsDirectory
        case .cachesDirectory: return URL.cachesDirectory
        }
    }

    @available(*, unavailable)
    public func mountedVolumeURLs(includingResourceValuesForKeys propertyKeys: [URLResourceKey]?, options: VolumeEnumerationOptions = []) -> [URL]? {
        return nil
    }

    @available(*, unavailable)
    public func urls(for directory: SearchPathDirectory, in domainMask: SearchPathDomainMask) -> [URL] {
        return []
    }

    @available(*, unavailable)
    public func getRelationship(_ outRelationship: Any, ofDirectoryAt directoryURL: URL, toItemAt otherURL: URL) throws {
    }

    @available(*, unavailable)
    public func getRelationship(_ outRelationship: Any, of directory: SearchPathDirectory, in domainMask: SearchPathDomainMask, toItemAt url: URL) throws {
    }

    @available(*, unavailable)
    public var delegate: Any? /* FileManagerDelegate? */


    @available(*, unavailable)
    public func attributesOfFileSystem(forPath path: String) throws -> [FileAttributeKey : Any] {
        fatalError()
    }

    @available(*, unavailable)
    public func linkItem(atPath srcPath: String, toPath dstPath: String) throws {
    }

    @available(*, unavailable)
    public func linkItem(at srcURL: URL, to dstURL: URL) throws {
    }

    @available(*, unavailable)
    public func trashItem(at url: URL, resultingItemURL outResultingURL: Any?) throws {
    }

    @available(*, unavailable)
    public func displayName(atPath path: String) -> String {
        fatalError()
    }

    @available(*, unavailable)
    public func componentsToDisplay(forPath path: String) -> [String]? {
        return nil
    }

    @available(*, unavailable)
    public func enumerator(atPath path: String) -> Any? /* DirectoryEnumerator? */ {
        return nil
    }

    @available(*, unavailable)
    public func contents(atPath path: String) -> Data? {
        return nil
    }

    @available(*, unavailable)
    public func fileSystemRepresentation(withPath path: String) -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func string(withFileSystemRepresentation str: Any, length len: Int) -> String {
        fatalError()
    }

    @available(*, unavailable)
    public func replaceItem(at originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String?, options: ItemReplacementOptions = [], resultingItemURL resultingURL: Any?) throws {
    }

    @available(*, unavailable)
    public func setUbiquitous(_ flag: Bool, itemAt url: URL, destinationURL: URL) throws {
    }

    @available(*, unavailable)
    public func isUbiquitousItem(at url: URL) -> Bool {
        return false
    }

    @available(*, unavailable)
    public func startDownloadingUbiquitousItem(at url: URL) throws {
    }

    @available(*, unavailable)
    public func evictUbiquitousItem(at url: URL) throws {
    }

    @available(*, unavailable)
    public func url(forUbiquityContainerIdentifier containerIdentifier: String?) -> URL? {
        return nil
    }

    @available(*, unavailable)
    public func url(forPublishingUbiquitousItemAt url: URL, expiration outDate: Any?) throws -> URL {
        fatalError()
    }

    @available(*, unavailable)
    public var ubiquityIdentityToken: Any? {
        return nil
    }

    @available(*, unavailable)
    public func getFileProviderServicesForItem(at url: URL, completionHandler:  ([AnyHashable: Any]? /*[NSFileProviderServiceName : NSFileProviderService]? */, Error?) -> Void) {
    }

    @available(*, unavailable)
    public func fileProviderServicesForItem(at url: URL) async throws -> [AnyHashable: Any] /* [NSFileProviderServiceName : NSFileProviderService] */ {
        fatalError()
    }

    @available(*, unavailable)
    public func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL? {
        return nil
    }

    @available(*, unavailable)
    public func replaceItemAt(_ originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String? = nil, options: ItemReplacementOptions = []) throws -> URL? {
        return nil
    }

    @available(*, unavailable)
    public func enumerator(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: DirectoryEnumerationOptions = [], errorHandler handler: ((URL, Error) -> Bool)? = nil) -> Any? /* DirectoryEnumerator? */ {
        return nil
    }

    public struct DirectoryEnumerationOptions : OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static var skipsSubdirectoryDescendants = DirectoryEnumerationOptions(rawValue: UInt(1))
        public static var skipsPackageDescendants = DirectoryEnumerationOptions(rawValue: UInt(2))
        public static var skipsHiddenFiles = DirectoryEnumerationOptions(rawValue: UInt(4))
        public static var includesDirectoriesPostOrder = DirectoryEnumerationOptions(rawValue: UInt(8))
        public static var producesRelativePathURLs = DirectoryEnumerationOptions(rawValue: UInt(16))
    }

    public struct ItemReplacementOptions : OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static var usingNewMetadataOnly = ItemReplacementOptions(rawValue: UInt(1))
        public static var withoutDeletingBackupItem = ItemReplacementOptions(rawValue: UInt(2))
    }

    public enum SearchPathDirectory : UInt {
        case documentDirectory
        case cachesDirectory
    }

    public enum SearchPathDomainMask : UInt {
        case userDomainMask = 1
        //case localDomainMask = 2
        //case networkDomainMask = 4
        //case systemDomainMask = 8
        //case allDomainMask = 0x0fff
    }

    public struct VolumeEnumerationOptions : OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let skipHiddenVolumes = VolumeEnumerationOptions(rawValue: UInt(1))
        public static let produceFileReferenceURLs = VolumeEnumerationOptions(rawValue: UInt(2))
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

public func NSTemporaryDirectory() -> String { _NSTemporaryDirectory }
private let _NSTemporaryDirectoryBase: String = java.lang.System.getProperty("java.io.tmpdir")
private let _NSTemporaryDirectory: String = _NSTemporaryDirectoryBase.hasSuffix("/") ? _NSTemporaryDirectoryBase : (_NSTemporaryDirectoryBase + "/") // Android doesn't always end with "/", which is expected by foundation

/// The user's home directory.
public func NSHomeDirectory() -> String { _NSHomeDirectory }
private let _NSHomeDirectory: String = java.lang.System.getProperty("user.home")

/// The current user name.
public func NSUserName() -> String { _NSUserName }
private let _NSUserName: String = java.lang.System.getProperty("user.name")

public struct FileProtectionType : RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let none = FileProtectionType(rawValue: "none")
    public static let complete = FileProtectionType(rawValue: "complete")
    public static let completeUnlessOpen = FileProtectionType(rawValue: "completeUnlessOpen")
    public static let completeUntilFirstUserAuthentication = FileProtectionType(rawValue: "completeUntilFirstUserAuthentication")
    public static let completeWhenUserInactive = FileProtectionType(rawValue: "completeWhenUserInactive")
}

struct UnableToDeleteFileError : Error {
    let path: String
}

struct UnableToCreateDirectory : Error {
    let path: String
}

#endif
