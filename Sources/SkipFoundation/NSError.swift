// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// This code is adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which has the following license:

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

//@_implementationOnly import CoreFoundation

public typealias NSErrorDomain = String

/// Predefined domain for errors from most Foundation APIs.
public let NSCocoaErrorDomain: String = "NSCocoaErrorDomain"

// Other predefined domains; value of "code" will correspond to preexisting values in these domains.
public let NSPOSIXErrorDomain: String = "NSPOSIXErrorDomain"
public let NSOSStatusErrorDomain: String = "NSOSStatusErrorDomain"
public let NSMachErrorDomain: String = "NSMachErrorDomain"

// Key in userInfo. A recommended standard way to embed NSErrors from underlying calls. The value of this key should be an NSError.
public let NSUnderlyingErrorKey: String = "NSUnderlyingError"

// Keys in userInfo, for subsystems wishing to provide their error messages up-front. Note that NSError will also consult the userInfoValueProvider for the domain when these values are not present in the userInfo dictionary.
public let NSLocalizedDescriptionKey: String = "NSLocalizedDescription"
public let NSLocalizedFailureReasonErrorKey: String = "NSLocalizedFailureReason"
public let NSLocalizedRecoverySuggestionErrorKey: String = "NSLocalizedRecoverySuggestion"
public let NSLocalizedRecoveryOptionsErrorKey: String = "NSLocalizedRecoveryOptions"
public let NSRecoveryAttempterErrorKey: String = "NSRecoveryAttempter"
public let NSHelpAnchorErrorKey: String = "NSHelpAnchor"
public let NSDebugDescriptionErrorKey = "NSDebugDescription"

// Other standard keys in userInfo, for various error codes
public let NSStringEncodingErrorKey: String = "NSStringEncodingErrorKey"
public let NSURLErrorKey: String = "NSURL"
public let NSFilePathErrorKey: String = "NSFilePathErrorKey"

open class NSError : CustomStringConvertible {
    // ErrorType forbids this being internal
    open var _domain: String
    open var _code: Int
    /// - Experiment: This is a draft API currently under consideration for official import into Foundation.
    /// - Note: This API differs from Darwin because it uses [String : Any] as a type instead of [String : AnyObject]. This allows the use of Swift value types.
    private var _userInfo: [String : Any]?

    /// - Experiment: This is a draft API currently under consideration for official import into Foundation.
    /// - Note: This API differs from Darwin because it uses [String : Any] as a type instead of [String : AnyObject]. This allows the use of Swift value types.
    public init(domain: String, code: Int, userInfo dict: [String : Any]? = nil) {
        _domain = domain
        _code = code
        _userInfo = dict
    }

    open var domain: String {
        return _domain
    }

    open var code: Int {
        return _code
    }

    /// - Experiment: This is a draft API currently under consideration for official import into Foundation.
    /// - Note: This API differs from Darwin because it uses [String : Any] as a type instead of [String : AnyObject]. This allows the use of Swift value types.
    open var userInfo: [String : Any] {
        if let info = _userInfo {
            return info
        } else {
            return Dictionary<String, Any>()
        }
    }

    open var localizedDescription: String {
        if let localizedDescription = userInfo[NSLocalizedDescriptionKey] as? String {
            return localizedDescription
        } else {
            // placeholder values
            return "The operation could not be completed." + " " + (self.localizedFailureReason ?? "(\(domain) error \(code).)")
        }
    }

    open var localizedFailureReason: String? {
        if let localizedFailureReason = userInfo[NSLocalizedFailureReasonErrorKey] as? String {
            return localizedFailureReason
        } else {
            switch domain {
            case NSPOSIXErrorDomain:
                //return String(cString: strerror(Int32(code)), encoding: .ascii)
                return "POSIX error \(code)"
            case NSCocoaErrorDomain:
                return CocoaError.errorMessages[CocoaError.Code(rawValue: code)]
            case NSURLErrorDomain:
                return nil
            default:
                return nil
            }
        }
    }

    open var localizedRecoverySuggestion: String? {
        return userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String
    }

    open var localizedRecoveryOptions: [String]? {
        // SKIP NOWARN
        return userInfo[NSLocalizedRecoveryOptionsErrorKey] as? [String]
    }

    open var recoveryAttempter: Any? {
        return userInfo[NSRecoveryAttempterErrorKey]
    }

    open var helpAnchor: String? {
        return userInfo[NSHelpAnchorErrorKey] as? String
    }

    internal typealias UserInfoProvider = (_ error: Error, _ key: String) -> Any?
    internal static var userInfoProviders = Dictionary<String, UserInfoProvider>()

    open class func setUserInfoValueProvider(forDomain errorDomain: String, provider: (/* @escaping */ (Error, String) -> Any?)?) {
        NSError.userInfoProviders[errorDomain] = provider
    }

    open class func userInfoValueProvider(forDomain errorDomain: String) -> ((Error, String) -> Any?)? {
        return NSError.userInfoProviders[errorDomain]
    }

    open var description: String {
        return "Error Domain=\(domain) Code=\(code) \"\(localizedFailureReason ?? "(null)")\""
    }
}

extension NSError : Swift.Error { }

//extension CFError : _NSBridgeable {
//    typealias NSType = NSError
//    internal var _nsObject: NSType {
//        let userInfo = CFErrorCopyUserInfo(self)._swiftObject
//        var newUserInfo: [String: Any] = [:]
//        for (key, value) in userInfo {
//            if let key = key as? String {
//                newUserInfo[key] = value
//            }
//        }
//
//        return NSError(domain: CFErrorGetDomain(self)._swiftObject, code: CFErrorGetCode(self), userInfo: newUserInfo)
//    }
//}
//
//public struct _CFErrorSPIForFoundationXMLUseOnly {
//    let error: AnyObject
//    public init(unsafelyAssumingIsCFError error: AnyObject) {
//        self.error = error
//    }
//
//    public var _nsObject: NSError {
//        return unsafeBitCast(error, to: CFError.self)._nsObject
//    }
//}

/// Describes an error that provides localized messages describing why
/// an error occurred and provides more information about the error.
public protocol LocalizedError : Error {
    /// A localized message describing what error occurred.
    var errorDescription: String? { get }

    /// A localized message describing the reason for the failure.
    var failureReason: String? { get }

    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? { get }

    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? { get }
}

public extension LocalizedError {
    var errorDescription: String? { return nil }
    var failureReason: String? { return nil }
    var recoverySuggestion: String? { return nil }
    var helpAnchor: String? { return nil }
}

/// Class that implements the informal protocol.
/// NSErrorRecoveryAttempting, which is used by NSError when it
/// attempts recovery from an error.
class _NSErrorRecoveryAttempter {
    func attemptRecovery(fromError error: Error,
        optionIndex recoveryOptionIndex: Int) -> Bool {
        let recoverableError = error as! RecoverableError
        return recoverableError.attemptRecovery(optionIndex: recoveryOptionIndex)
  }
}

/// Describes an error that may be recoverable by presenting several
/// potential recovery options to the user.
public protocol RecoverableError : Error {
    /// Provides a set of possible recovery options to present to the user.
    var recoveryOptions: [String] { get }

    /// Attempt to recover from this error when the user selected the
    /// option at the given index. This routine must call handler and
    /// indicate whether recovery was successful (or not).
    ///
    /// This entry point is used for recovery of errors handled at a
    /// "document" granularity, that do not affect the entire
    /// application.
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (_ recovered: Bool) -> Void)

    /// Attempt to recover from this error when the user selected the
    /// option at the given index. Returns true to indicate
    /// successful recovery, and false otherwise.
    ///
    /// This entry point is used for recovery of errors handled at
    /// the "application" granularity, where nothing else in the
    /// application can proceed until the attempted error recovery
    /// completes.
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool
}

public extension RecoverableError {
    /// Default implementation that uses the application-model recovery
    /// mechanism (``attemptRecovery(optionIndex:)``) to implement
    /// document-modal recovery.
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (_ recovered: Bool) -> Void) {
        handler(attemptRecovery(optionIndex: recoveryOptionIndex))
    }
}

/// Describes an error type that specifically provides a domain, code,
/// and user-info dictionary.
public protocol CustomNSError : Error {
    /// The domain of the error.
    //static var errorDomain: String { get } // FIXME: Kotlin does not support static members in protocols

    /// The error code within the given domain.
    var errorCode: Int { get }

    /// The user-info dictionary.
    var errorUserInfo: [String : Any] { get }
}

public extension CustomNSError {
    #if !SKIP // Kotlin does not support static members in protocols
    /// Default domain of the error.
    static var errorDomain: String {
        return String(reflecting: self)
    }
    #endif

    /// The error code within the given domain.
    var errorCode: Int {
        #if !SKIP
        return _getDefaultErrorCode(self)
        #else
        return 0 // no equivalent for Swift._getDefaultErrorCode()
        #endif
    }

    /// The default user-info dictionary.
    var errorUserInfo: [String : Any] {
        return [:]
    }
}



/// Describes errors within the Cocoa error domain.
public struct CocoaError {
    public let _nsError: NSError

    public init(_nsError error: NSError) {
        precondition(error.domain == NSCocoaErrorDomain)
        self._nsError = error
    }

    public var code: Code { Code(rawValue: _nsError.code) }

    public static var _nsErrorDomain: String { return NSCocoaErrorDomain }

    /// The error code itself.
    public struct Code : RawRepresentable, Hashable {
        //public typealias _ErrorType = CocoaError

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var fileNoSuchFile:                           CocoaError.Code { return CocoaError.Code(rawValue:    4) }
        public static var fileLocking:                              CocoaError.Code { return CocoaError.Code(rawValue:  255) }
        public static var fileReadUnknown:                          CocoaError.Code { return CocoaError.Code(rawValue:  256) }
        public static var fileReadNoPermission:                     CocoaError.Code { return CocoaError.Code(rawValue:  257) }
        public static var fileReadInvalidFileName:                  CocoaError.Code { return CocoaError.Code(rawValue:  258) }
        public static var fileReadCorruptFile:                      CocoaError.Code { return CocoaError.Code(rawValue:  259) }
        public static var fileReadNoSuchFile:                       CocoaError.Code { return CocoaError.Code(rawValue:  260) }
        public static var fileReadInapplicableStringEncoding:       CocoaError.Code { return CocoaError.Code(rawValue:  261) }
        public static var fileReadUnsupportedScheme:                CocoaError.Code { return CocoaError.Code(rawValue:  262) }
        public static var fileReadTooLarge:                         CocoaError.Code { return CocoaError.Code(rawValue:  263) }
        public static var fileReadUnknownStringEncoding:            CocoaError.Code { return CocoaError.Code(rawValue:  264) }
        public static var fileWriteUnknown:                         CocoaError.Code { return CocoaError.Code(rawValue:  512) }
        public static var fileWriteNoPermission:                    CocoaError.Code { return CocoaError.Code(rawValue:  513) }
        public static var fileWriteInvalidFileName:                 CocoaError.Code { return CocoaError.Code(rawValue:  514) }
        public static var fileWriteFileExists:                      CocoaError.Code { return CocoaError.Code(rawValue:  516) }
        public static var fileWriteInapplicableStringEncoding:      CocoaError.Code { return CocoaError.Code(rawValue:  517) }
        public static var fileWriteUnsupportedScheme:               CocoaError.Code { return CocoaError.Code(rawValue:  518) }
        public static var fileWriteOutOfSpace:                      CocoaError.Code { return CocoaError.Code(rawValue:  640) }
        public static var fileWriteVolumeReadOnly:                  CocoaError.Code { return CocoaError.Code(rawValue:  642) }
        public static var fileManagerUnmountUnknown:                CocoaError.Code { return CocoaError.Code(rawValue:  768) }
        public static var fileManagerUnmountBusy:                   CocoaError.Code { return CocoaError.Code(rawValue:  769) }
        public static var keyValueValidation:                       CocoaError.Code { return CocoaError.Code(rawValue: 1024) }
        public static var formatting:                               CocoaError.Code { return CocoaError.Code(rawValue: 2048) }
        public static var userCancelled:                            CocoaError.Code { return CocoaError.Code(rawValue: 3072) }
        public static var featureUnsupported:                       CocoaError.Code { return CocoaError.Code(rawValue: 3328) }
        public static var executableNotLoadable:                    CocoaError.Code { return CocoaError.Code(rawValue: 3584) }
        public static var executableArchitectureMismatch:           CocoaError.Code { return CocoaError.Code(rawValue: 3585) }
        public static var executableRuntimeMismatch:                CocoaError.Code { return CocoaError.Code(rawValue: 3586) }
        public static var executableLoad:                           CocoaError.Code { return CocoaError.Code(rawValue: 3587) }
        public static var executableLink:                           CocoaError.Code { return CocoaError.Code(rawValue: 3588) }
        public static var propertyListReadCorrupt:                  CocoaError.Code { return CocoaError.Code(rawValue: 3840) }
        public static var propertyListReadUnknownVersion:           CocoaError.Code { return CocoaError.Code(rawValue: 3841) }
        public static var propertyListReadStream:                   CocoaError.Code { return CocoaError.Code(rawValue: 3842) }
        public static var propertyListWriteStream:                  CocoaError.Code { return CocoaError.Code(rawValue: 3851) }
        public static var propertyListWriteInvalid:                 CocoaError.Code { return CocoaError.Code(rawValue: 3852) }
        public static var xpcConnectionInterrupted:                 CocoaError.Code { return CocoaError.Code(rawValue: 4097) }
        public static var xpcConnectionInvalid:                     CocoaError.Code { return CocoaError.Code(rawValue: 4099) }
        public static var xpcConnectionReplyInvalid:                CocoaError.Code { return CocoaError.Code(rawValue: 4101) }
        public static var ubiquitousFileUnavailable:                CocoaError.Code { return CocoaError.Code(rawValue: 4353) }
        public static var ubiquitousFileNotUploadedDueToQuota:      CocoaError.Code { return CocoaError.Code(rawValue: 4354) }
        public static var ubiquitousFileUbiquityServerNotAvailable: CocoaError.Code { return CocoaError.Code(rawValue: 4355) }
        public static var userActivityHandoffFailed:                CocoaError.Code { return CocoaError.Code(rawValue: 4608) }
        public static var userActivityConnectionUnavailable:        CocoaError.Code { return CocoaError.Code(rawValue: 4609) }
        public static var userActivityRemoteApplicationTimedOut:    CocoaError.Code { return CocoaError.Code(rawValue: 4610) }
        public static var userActivityHandoffUserInfoTooLarge:      CocoaError.Code { return CocoaError.Code(rawValue: 4611) }
        public static var coderReadCorrupt:                         CocoaError.Code { return CocoaError.Code(rawValue: 4864) }
        public static var coderValueNotFound:                       CocoaError.Code { return CocoaError.Code(rawValue: 4865) }
        public static var coderInvalidValue:                        CocoaError.Code { return CocoaError.Code(rawValue: 4866) }
    }
}

internal extension CocoaError {
    static let errorMessages = [
        Code(rawValue: 4): "The file doesn’t exist.",
        Code(rawValue: 255): "The file couldn’t be locked.",
        Code(rawValue: 257): "You don’t have permission.",
        Code(rawValue: 258): "The file name is invalid.",
        Code(rawValue: 259): "The file isn’t in the correct format.",
        Code(rawValue: 260): "The file doesn’t exist.",
        Code(rawValue: 261): "The specified text encoding isn’t applicable.",
        Code(rawValue: 262): "The specified URL type isn’t supported.",
        Code(rawValue: 263): "The item is too large.",
        Code(rawValue: 264): "The text encoding of the contents couldn’t be determined.",
        Code(rawValue: 513): "You don’t have permission.",
        Code(rawValue: 514): "The file name is invalid.",
        Code(rawValue: 516): "A file with the same name already exists.",
        Code(rawValue: 517): "The specified text encoding isn’t applicable.",
        Code(rawValue: 518): "The specified URL type isn’t supported.",
        Code(rawValue: 640): "There isn’t enough space.",
        Code(rawValue: 642): "The volume is read only.",
        Code(rawValue: 1024): "The value is invalid.",
        Code(rawValue: 2048): "The value is invalid.",
        Code(rawValue: 3072): "The operation was cancelled.",
        Code(rawValue: 3328): "The requested operation is not supported.",
        Code(rawValue: 3840): "The data is not in the correct format.",
        Code(rawValue: 3841): "The data is in a format that this application doesn’t understand.",
        Code(rawValue: 3842): "An error occurred in the source of the data.",
        Code(rawValue: 3851): "An error occurred in the destination for the data.",
        Code(rawValue: 3852): "An error occurred in the content of the data.",
        Code(rawValue: 4353): "The file is not available on iCloud yet.",
        Code(rawValue: 4354): "There isn’t enough space in your account.",
        Code(rawValue: 4355): "The iCloud servers might be unreachable or your settings might be incorrect.",
        Code(rawValue: 4864): "The data isn’t in the correct format.",
        Code(rawValue: 4865): "The data is missing.",
        Code(rawValue: 4866): "The data isn’t in the correct format."
    ]
}

public extension CocoaError {
    private var _nsUserInfo: [String: Any] {
        return _nsError.userInfo
    }

    /// The file path associated with the error, if any.
    var filePath: String? {
        return _nsUserInfo[NSFilePathErrorKey] as? String
    }

    #if !SKIP // String.Encoding constructor
    /// The string encoding associated with this error, if any.
    var stringEncoding: StringEncoding? {
        return (_nsUserInfo[NSStringEncodingErrorKey] as? NSNumber)
        .map { StringEncoding(rawValue: $0.uintValue) }
    }
    #endif

    /// The underlying error behind this error, if any.
    var underlying: Error? {
        return _nsUserInfo[NSUnderlyingErrorKey] as? Error
    }

    /// The URL associated with this error, if any.
    var url: URL? {
        return _nsUserInfo[NSURLErrorKey] as? URL
    }
}

extension CocoaError {
    public static func error(_ code: CocoaError.Code, userInfo: [AnyHashable: Any]? = nil, url: URL? = nil) -> Error {
        // SKIP NOWARN
        var info: [String: Any] = userInfo as? [String: Any] ?? [:]
        if let url = url {
            info[NSURLErrorKey] = url
        }
        return NSError(domain: NSCocoaErrorDomain, code: code.rawValue, userInfo: info)
    }
}

extension CocoaError.Code {
}

extension CocoaError {
    public static var fileNoSuchFile:                           CocoaError.Code { return .fileNoSuchFile }
    public static var fileLocking:                              CocoaError.Code { return .fileLocking }
    public static var fileReadUnknown:                          CocoaError.Code { return .fileReadUnknown }
    public static var fileReadNoPermission:                     CocoaError.Code { return .fileReadNoPermission }
    public static var fileReadInvalidFileName:                  CocoaError.Code { return .fileReadInvalidFileName }
    public static var fileReadCorruptFile:                      CocoaError.Code { return .fileReadCorruptFile }
    public static var fileReadNoSuchFile:                       CocoaError.Code { return .fileReadNoSuchFile }
    public static var fileReadInapplicableStringEncoding:       CocoaError.Code { return .fileReadInapplicableStringEncoding }
    public static var fileReadUnsupportedScheme:                CocoaError.Code { return .fileReadUnsupportedScheme }
    public static var fileReadTooLarge:                         CocoaError.Code { return .fileReadTooLarge }
    public static var fileReadUnknownStringEncoding:            CocoaError.Code { return .fileReadUnknownStringEncoding }
    public static var fileWriteUnknown:                         CocoaError.Code { return .fileWriteUnknown }
    public static var fileWriteNoPermission:                    CocoaError.Code { return .fileWriteNoPermission }
    public static var fileWriteInvalidFileName:                 CocoaError.Code { return .fileWriteInvalidFileName }
    public static var fileWriteFileExists:                      CocoaError.Code { return .fileWriteFileExists }
    public static var fileWriteInapplicableStringEncoding:      CocoaError.Code { return .fileWriteInapplicableStringEncoding }
    public static var fileWriteUnsupportedScheme:               CocoaError.Code { return .fileWriteUnsupportedScheme }
    public static var fileWriteOutOfSpace:                      CocoaError.Code { return .fileWriteOutOfSpace }
    public static var fileWriteVolumeReadOnly:                  CocoaError.Code { return .fileWriteVolumeReadOnly }
    public static var fileManagerUnmountUnknown:                CocoaError.Code { return .fileManagerUnmountUnknown }
    public static var fileManagerUnmountBusy:                   CocoaError.Code { return .fileManagerUnmountBusy }
    public static var keyValueValidation:                       CocoaError.Code { return .keyValueValidation }
    public static var formatting:                               CocoaError.Code { return .formatting }
    public static var userCancelled:                            CocoaError.Code { return .userCancelled }
    public static var featureUnsupported:                       CocoaError.Code { return .featureUnsupported }
    public static var executableNotLoadable:                    CocoaError.Code { return .executableNotLoadable }
    public static var executableArchitectureMismatch:           CocoaError.Code { return .executableArchitectureMismatch }
    public static var executableRuntimeMismatch:                CocoaError.Code { return .executableRuntimeMismatch }
    public static var executableLoad:                           CocoaError.Code { return .executableLoad }
    public static var executableLink:                           CocoaError.Code { return .executableLink }
    public static var propertyListReadCorrupt:                  CocoaError.Code { return .propertyListReadCorrupt }
    public static var propertyListReadUnknownVersion:           CocoaError.Code { return .propertyListReadUnknownVersion }
    public static var propertyListReadStream:                   CocoaError.Code { return .propertyListReadStream }
    public static var propertyListWriteStream:                  CocoaError.Code { return .propertyListWriteStream }
    public static var propertyListWriteInvalid:                 CocoaError.Code { return .propertyListWriteInvalid }
    public static var xpcConnectionInterrupted:                 CocoaError.Code { return .xpcConnectionInterrupted }
    public static var xpcConnectionInvalid:                     CocoaError.Code { return .xpcConnectionInvalid }
    public static var xpcConnectionReplyInvalid:                CocoaError.Code { return .xpcConnectionReplyInvalid }
    public static var ubiquitousFileUnavailable:                CocoaError.Code { return .ubiquitousFileUnavailable }
    public static var ubiquitousFileNotUploadedDueToQuota:      CocoaError.Code { return .ubiquitousFileNotUploadedDueToQuota }
    public static var ubiquitousFileUbiquityServerNotAvailable: CocoaError.Code { return .ubiquitousFileUbiquityServerNotAvailable }
    public static var userActivityHandoffFailed:                CocoaError.Code { return .userActivityHandoffFailed }
    public static var userActivityConnectionUnavailable:        CocoaError.Code { return .userActivityConnectionUnavailable }
    public static var userActivityRemoteApplicationTimedOut:    CocoaError.Code { return .userActivityRemoteApplicationTimedOut }
    public static var userActivityHandoffUserInfoTooLarge:      CocoaError.Code { return .userActivityHandoffUserInfoTooLarge }
    public static var coderReadCorrupt:                         CocoaError.Code { return .coderReadCorrupt }
    public static var coderValueNotFound:                       CocoaError.Code { return .coderValueNotFound }
    public static var coderInvalidValue:                        CocoaError.Code { return .coderInvalidValue }
}

extension CocoaError {
    public var isCoderError: Bool {
        return code.rawValue >= 4864 && code.rawValue <= 4991
    }

    public var isExecutableError: Bool {
        return code.rawValue >= 3584 && code.rawValue <= 3839
    }

    public var isFileError: Bool {
        return code.rawValue >= 0 && code.rawValue <= 1023
    }

    public var isFormattingError: Bool {
        return code.rawValue >= 2048 && code.rawValue <= 2559
    }

    public var isPropertyListError: Bool {
        return code.rawValue >= 3840 && code.rawValue <= 4095
    }

    public var isUbiquitousFileError: Bool {
        return code.rawValue >= 4352 && code.rawValue <= 4607
    }

    public var isUserActivityError: Bool {
        return code.rawValue >= 4608 && code.rawValue <= 4863
    }

    public var isValidationError: Bool {
        return code.rawValue >= 1024 && code.rawValue <= 2047
    }

    public var isXPCConnectionError: Bool {
        return code.rawValue >= 4096 && code.rawValue <= 4224
    }
}

/// Describes errors in the URL error domain.
public struct URLError {
    public let _nsError: NSError

    public init(_nsError error: NSError) {
        precondition(error.domain == NSURLErrorDomain)
        self._nsError = error
    }

    public var code: Code { Code(rawValue: _nsError.code)! }

    public static var _nsErrorDomain: String { return NSURLErrorDomain }

    public enum Code : Int {
        //public typealias _ErrorType = URLError

        case unknown = -1
        case cancelled = -999
        case badURL = -1000
        case timedOut = -1001
        case unsupportedURL = -1002
        case cannotFindHost = -1003
        case cannotConnectToHost = -1004
        case networkConnectionLost = -1005
        case dnsLookupFailed = -1006
        case httpTooManyRedirects = -1007
        case resourceUnavailable = -1008
        case notConnectedToInternet = -1009
        case redirectToNonExistentLocation = -1010
        case badServerResponse = -1011
        case userCancelledAuthentication = -1012
        case userAuthenticationRequired = -1013
        case zeroByteResource = -1014
        case cannotDecodeRawData = -1015
        case cannotDecodeContentData = -1016
        case cannotParseResponse = -1017
        case appTransportSecurityRequiresSecureConnection = -1022
        case fileDoesNotExist = -1100
        case fileIsDirectory = -1101
        case noPermissionsToReadFile = -1102
        case dataLengthExceedsMaximum = -1103
        case secureConnectionFailed = -1200
        case serverCertificateHasBadDate = -1201
        case serverCertificateUntrusted = -1202
        case serverCertificateHasUnknownRoot = -1203
        case serverCertificateNotYetValid = -1204
        case clientCertificateRejected = -1205
        case clientCertificateRequired = -1206
        case cannotLoadFromNetwork = -2000
        case cannotCreateFile = -3000
        case cannotOpenFile = -3001
        case cannotCloseFile = -3002
        case cannotWriteToFile = -3003
        case cannotRemoveFile = -3004
        case cannotMoveFile = -3005
        case downloadDecodingFailedMidStream = -3006
        case downloadDecodingFailedToComplete = -3007
        case internationalRoamingOff = -1018
        case callIsActive = -1019
        case dataNotAllowed = -1020
        case requestBodyStreamExhausted = -1021
        case backgroundSessionRequiresSharedContainer = -995
        case backgroundSessionInUseByAnotherProcess = -996
        case backgroundSessionWasDisconnected = -997
    }
}

extension URLError {
    private var _nsUserInfo: [String: Any] {
        return _nsError.userInfo
    }

    /// The URL which caused a load to fail.
    public var failingURL: URL? {
        return _nsUserInfo[NSURLErrorFailingURLErrorKey] as? URL
    }

    /// The string for the URL which caused a load to fail.
    public var failureURLString: String? {
        return _nsUserInfo[NSURLErrorFailingURLStringErrorKey] as? String
    }
}

extension URLError {
    public static var unknown:                                  URLError.Code { return .unknown }
    public static var cancelled:                                URLError.Code { return .cancelled }
    public static var badURL:                                   URLError.Code { return .badURL }
    public static var timedOut:                                 URLError.Code { return .timedOut }
    public static var unsupportedURL:                           URLError.Code { return .unsupportedURL }
    public static var cannotFindHost:                           URLError.Code { return .cannotFindHost }
    public static var cannotConnectToHost:                      URLError.Code { return .cannotConnectToHost }
    public static var networkConnectionLost:                    URLError.Code { return .networkConnectionLost }
    public static var dnsLookupFailed:                          URLError.Code { return .dnsLookupFailed }
    public static var httpTooManyRedirects:                     URLError.Code { return .httpTooManyRedirects }
    public static var resourceUnavailable:                      URLError.Code { return .resourceUnavailable }
    public static var notConnectedToInternet:                   URLError.Code { return .notConnectedToInternet }
    public static var redirectToNonExistentLocation:            URLError.Code { return .redirectToNonExistentLocation }
    public static var badServerResponse:                        URLError.Code { return .badServerResponse }
    public static var userCancelledAuthentication:              URLError.Code { return .userCancelledAuthentication }
    public static var userAuthenticationRequired:               URLError.Code { return .userAuthenticationRequired }
    public static var zeroByteResource:                         URLError.Code { return .zeroByteResource }
    public static var cannotDecodeRawData:                      URLError.Code { return .cannotDecodeRawData }
    public static var cannotDecodeContentData:                  URLError.Code { return .cannotDecodeContentData }
    public static var cannotParseResponse:                      URLError.Code { return .cannotParseResponse }
    public static var fileDoesNotExist:                         URLError.Code { return .fileDoesNotExist }
    public static var fileIsDirectory:                          URLError.Code { return .fileIsDirectory }
    public static var noPermissionsToReadFile:                  URLError.Code { return .noPermissionsToReadFile }
    public static var secureConnectionFailed:                   URLError.Code { return .secureConnectionFailed }
    public static var serverCertificateHasBadDate:              URLError.Code { return .serverCertificateHasBadDate }
    public static var serverCertificateUntrusted:               URLError.Code { return .serverCertificateUntrusted }
    public static var serverCertificateHasUnknownRoot:          URLError.Code { return .serverCertificateHasUnknownRoot }
    public static var serverCertificateNotYetValid:             URLError.Code { return .serverCertificateNotYetValid }
    public static var clientCertificateRejected:                URLError.Code { return .clientCertificateRejected }
    public static var clientCertificateRequired:                URLError.Code { return .clientCertificateRequired }
    public static var cannotLoadFromNetwork:                    URLError.Code { return .cannotLoadFromNetwork }
    public static var cannotCreateFile:                         URLError.Code { return .cannotCreateFile }
    public static var cannotOpenFile:                           URLError.Code { return .cannotOpenFile }
    public static var cannotCloseFile:                          URLError.Code { return .cannotCloseFile }
    public static var cannotWriteToFile:                        URLError.Code { return .cannotWriteToFile }
    public static var cannotRemoveFile:                         URLError.Code { return .cannotRemoveFile }
    public static var cannotMoveFile:                           URLError.Code { return .cannotMoveFile }
    public static var downloadDecodingFailedMidStream:          URLError.Code { return .downloadDecodingFailedMidStream }
    public static var downloadDecodingFailedToComplete:         URLError.Code { return .downloadDecodingFailedToComplete }
    public static var internationalRoamingOff:                  URLError.Code { return .internationalRoamingOff }
    public static var callIsActive:                             URLError.Code { return .callIsActive }
    public static var dataNotAllowed:                           URLError.Code { return .dataNotAllowed }
    public static var requestBodyStreamExhausted:               URLError.Code { return .requestBodyStreamExhausted }
    public static var backgroundSessionRequiresSharedContainer: URLError.Code { return .backgroundSessionRequiresSharedContainer }
    public static var backgroundSessionInUseByAnotherProcess:   URLError.Code { return .backgroundSessionInUseByAnotherProcess }
    public static var backgroundSessionWasDisconnected:         URLError.Code { return .backgroundSessionWasDisconnected }
}

public typealias POSIXErrorCode = POSIXError.Code

/// Describes an error in the POSIX error domain.
public struct POSIXError {

    public let _nsError: NSError

    public init(_nsError error: NSError) {
        precondition(error.domain == NSPOSIXErrorDomain)
        self._nsError = error
    }

    public static var _nsErrorDomain: String { return NSPOSIXErrorDomain }

    //public typealias Code = POSIXErrorCode // FIXME: Kotlin does not support typealias declarations within functions and types. Consider moving this to a top level declaration

    public enum Code : Int32 {
        //public typealias RawValue = Int32

        /// Operation not permitted.
        case EPERM = 1

        /// No such file or directory.
        case ENOENT = 2

        /// No such process.
        case ESRCH = 3

        /// Interrupted system call.
        case EINTR = 4

        /// Input/output error.
        case EIO = 5

        /// Device not configured.
        case ENXIO = 6

        /// Argument list too long.
        case E2BIG = 7

        /// Exec format error.
        case ENOEXEC = 8

        /// Bad file descriptor.
        case EBADF = 9

        /// No child processes.
        case ECHILD = 10

        /// Resource deadlock avoided.
        case EDEADLK = 11

        /// 11 was EAGAIN.
        /// Cannot allocate memory.
        case ENOMEM = 12

        /// Permission denied.
        case EACCES = 13

        /// Bad address.
        case EFAULT = 14

        /// Block device required.
        case ENOTBLK = 15

        /// Device / Resource busy.
        case EBUSY = 16

        /// File exists.
        case EEXIST = 17

        /// Cross-device link.
        case EXDEV = 18

        /// Operation not supported by device.
        case ENODEV = 19

        /// Not a directory.
        case ENOTDIR = 20

        /// Is a directory.
        case EISDIR = 21

        /// Invalid argument.
        case EINVAL = 22

        /// Too many open files in system.
        case ENFILE = 23

        /// Too many open files.
        case EMFILE = 24

        /// Inappropriate ioctl for device.
        case ENOTTY = 25

        /// Text file busy.
        case ETXTBSY = 26

        /// File too large.
        case EFBIG = 27

        /// No space left on device.
        case ENOSPC = 28

        /// Illegal seek.
        case ESPIPE = 29

        /// Read-only file system.
        case EROFS = 30

        /// Too many links.
        case EMLINK = 31

        /// Broken pipe.
        case EPIPE = 32

        /// math software.
        /// Numerical argument out of domain.
        case EDOM = 33

        /// Result too large.
        case ERANGE = 34

        /// non-blocking and interrupt i/o.
        /// Resource temporarily unavailable.
        case EAGAIN = 35

        /// Operation would block.
        //public static var EWOULDBLOCK: POSIXErrorCode { get }

        /// Operation now in progress.
        case EINPROGRESS = 36

        /// Operation already in progress.
        case EALREADY = 37

        /// ipc/network software -- argument errors.
        /// Socket operation on non-socket.
        case ENOTSOCK = 38

        /// Destination address required.
        case EDESTADDRREQ = 39

        /// Message too long.
        case EMSGSIZE = 40

        /// Protocol wrong type for socket.
        case EPROTOTYPE = 41

        /// Protocol not available.
        case ENOPROTOOPT = 42

        /// Protocol not supported.
        case EPROTONOSUPPORT = 43

        /// Socket type not supported.
        case ESOCKTNOSUPPORT = 44

        /// Operation not supported.
        case ENOTSUP = 45

        /// Protocol family not supported.
        case EPFNOSUPPORT = 46

        /// Address family not supported by protocol family.
        case EAFNOSUPPORT = 47

        /// Address already in use.
        case EADDRINUSE = 48

        /// Can't assign requested address.
        case EADDRNOTAVAIL = 49

        /// ipc/network software -- operational errors
        /// Network is down.
        case ENETDOWN = 50

        /// Network is unreachable.
        case ENETUNREACH = 51

        /// Network dropped connection on reset.
        case ENETRESET = 52

        /// Software caused connection abort.
        case ECONNABORTED = 53

        /// Connection reset by peer.
        case ECONNRESET = 54

        /// No buffer space available.
        case ENOBUFS = 55

        /// Socket is already connected.
        case EISCONN = 56

        /// Socket is not connected.
        case ENOTCONN = 57

        /// Can't send after socket shutdown.
        case ESHUTDOWN = 58

        /// Too many references: can't splice.
        case ETOOMANYREFS = 59

        /// Operation timed out.
        case ETIMEDOUT = 60

        /// Connection refused.
        case ECONNREFUSED = 61

        /// Too many levels of symbolic links.
        case ELOOP = 62

        /// File name too long.
        case ENAMETOOLONG = 63

        /// Host is down.
        case EHOSTDOWN = 64

        /// No route to host.
        case EHOSTUNREACH = 65

        /// Directory not empty.
        case ENOTEMPTY = 66

        /// quotas & mush.
        /// Too many processes.
        case EPROCLIM = 67

        /// Too many users.
        case EUSERS = 68

        /// Disc quota exceeded.
        case EDQUOT = 69

        /// Network File System.
        /// Stale NFS file handle.
        case ESTALE = 70

        /// Too many levels of remote in path.
        case EREMOTE = 71

        /// RPC struct is bad.
        case EBADRPC = 72

        /// RPC version wrong.
        case ERPCMISMATCH = 73

        /// RPC prog. not avail.
        case EPROGUNAVAIL = 74

        /// Program version wrong.
        case EPROGMISMATCH = 75

        /// Bad procedure for program.
        case EPROCUNAVAIL = 76

        /// No locks available.
        case ENOLCK = 77

        /// Function not implemented.
        case ENOSYS = 78

        /// Inappropriate file type or format.
        case EFTYPE = 79

        /// Authentication error.
        case EAUTH = 80

        /// Need authenticator.
        case ENEEDAUTH = 81

        /// Intelligent device errors.
        /// Device power is off.
        case EPWROFF = 82

        /// Device error, e.g. paper out.
        case EDEVERR = 83

        /// Value too large to be stored in data type.
        case EOVERFLOW = 84

        /// Bad executable.
        case EBADEXEC = 85

        /// Bad CPU type in executable.
        case EBADARCH = 86

        /// Shared library version mismatch.
        case ESHLIBVERS = 87

        /// Malformed Macho file.
        case EBADMACHO = 88

        /// Operation canceled.
        case ECANCELED = 89

        /// Identifier removed.
        case EIDRM = 90

        /// No message of desired type.
        case ENOMSG = 91

        /// Illegal byte sequence.
        case EILSEQ = 92

        /// Attribute not found.
        case ENOATTR = 93

        /// Bad message.
        case EBADMSG = 94

        /// Reserved.
        case EMULTIHOP = 95

        /// No message available on STREAM.
        case ENODATA = 96

        /// Reserved.
        case ENOLINK = 97

        /// No STREAM resources.
        case ENOSR = 98

        /// Not a STREAM.
        case ENOSTR = 99

        /// Protocol error.
        case EPROTO = 100

        /// STREAM ioctl timeout.
        case ETIME = 101

        /// No such policy registered.
        case ENOPOLICY = 103

        /// State not recoverable.
        case ENOTRECOVERABLE = 104

        /// Previous owner died.
        case EOWNERDEAD = 105

        /// Interface output queue is full.
        case EQFULL = 106

        /// Must be equal largest errno.
        //public static var ELAST: POSIXErrorCode { get }
    }
}

//extension POSIXErrorCode: _ErrorCodeProtocol {
//    public typealias _ErrorType = POSIXError
//}

extension POSIXError {
    /// Operation not permitted.
    public static var EPERM: POSIXError.Code { return .EPERM }

    /// No such file or directory.
    public static var ENOENT: POSIXError.Code { return .ENOENT }

    /// No such process.
    public static var ESRCH: POSIXError.Code { return .ESRCH }

    /// Interrupted system call.
    public static var EINTR: POSIXError.Code { return .EINTR }

    /// Input/output error.
    public static var EIO: POSIXError.Code { return .EIO }

    /// Device not configured.
    public static var ENXIO: POSIXError.Code { return .ENXIO }

    /// Argument list too long.
    public static var E2BIG: POSIXError.Code { return .E2BIG }

    /// Exec format error.
    public static var ENOEXEC: POSIXError.Code { return .ENOEXEC }

    /// Bad file descriptor.
    public static var EBADF: POSIXError.Code { return .EBADF }

    /// No child processes.
    public static var ECHILD: POSIXError.Code { return .ECHILD }

    /// Resource deadlock avoided.
    public static var EDEADLK: POSIXError.Code { return .EDEADLK }

    /// Cannot allocate memory.
    public static var ENOMEM: POSIXError.Code { return .ENOMEM }

    /// Permission denied.
    public static var EACCES: POSIXError.Code { return .EACCES }

    /// Bad address.
    public static var EFAULT: POSIXError.Code { return .EFAULT }

    #if !os(Windows)
    /// Block device required.
    public static var ENOTBLK: POSIXError.Code { return .ENOTBLK }
    #endif

    /// Device / Resource busy.
    public static var EBUSY: POSIXError.Code { return .EBUSY }

    /// File exists.
    public static var EEXIST: POSIXError.Code { return .EEXIST }

    /// Cross-device link.
    public static var EXDEV: POSIXError.Code { return .EXDEV }

    /// Operation not supported by device.
    public static var ENODEV: POSIXError.Code { return .ENODEV }

    /// Not a directory.
    public static var ENOTDIR: POSIXError.Code { return .ENOTDIR }

    /// Is a directory.
    public static var EISDIR: POSIXError.Code { return .EISDIR }

    /// Invalid argument.
    public static var EINVAL: POSIXError.Code { return .EINVAL }

    /// Too many open files in system.
    public static var ENFILE: POSIXError.Code { return .ENFILE }

    /// Too many open files.
    public static var EMFILE: POSIXError.Code { return .EMFILE }

    /// Inappropriate ioctl for device.
    public static var ENOTTY: POSIXError.Code { return .ENOTTY }

    #if !os(Windows)
    /// Text file busy.
    public static var ETXTBSY: POSIXError.Code { return .ETXTBSY }
    #endif

    /// File too large.
    public static var EFBIG: POSIXError.Code { return .EFBIG }

    /// No space left on device.
    public static var ENOSPC: POSIXError.Code { return .ENOSPC }

    /// Illegal seek.
    public static var ESPIPE: POSIXError.Code { return .ESPIPE }

    /// Read-only file system.
    public static var EROFS: POSIXError.Code { return .EROFS }

    /// Too many links.
    public static var EMLINK: POSIXError.Code { return .EMLINK }

    /// Broken pipe.
    public static var EPIPE: POSIXError.Code { return .EPIPE }

    /// Math Software

    /// Numerical argument out of domain.
    public static var EDOM: POSIXError.Code { return .EDOM }

    /// Result too large.
    public static var ERANGE: POSIXError.Code { return .ERANGE }

    /// Non-blocking and interrupt I/O.

    /// Resource temporarily unavailable.
    public static var EAGAIN: POSIXError.Code { return .EAGAIN }

    #if !os(Windows)
    /// Operation would block.
    //public static var EWOULDBLOCK: POSIXError.Code { return .EWOULDBLOCK }

    /// Operation now in progress.
    public static var EINPROGRESS: POSIXError.Code { return .EINPROGRESS }

    /// Operation already in progress.
    public static var EALREADY: POSIXError.Code { return .EALREADY }
    #endif

    /// IPC/Network software -- argument errors.

    #if !os(Windows)
    /// Socket operation on non-socket.
    public static var ENOTSOCK: POSIXError.Code { return .ENOTSOCK }

    /// Destination address required.
    public static var EDESTADDRREQ: POSIXError.Code { return .EDESTADDRREQ }

    /// Message too long.
    public static var EMSGSIZE: POSIXError.Code { return .EMSGSIZE }

    /// Protocol wrong type for socket.
    public static var EPROTOTYPE: POSIXError.Code { return .EPROTOTYPE }

    /// Protocol not available.
    public static var ENOPROTOOPT: POSIXError.Code { return .ENOPROTOOPT }

    /// Protocol not supported.
    public static var EPROTONOSUPPORT: POSIXError.Code { return .EPROTONOSUPPORT }

    /// Socket type not supported.
    public static var ESOCKTNOSUPPORT: POSIXError.Code { return .ESOCKTNOSUPPORT }
    #endif

    #if canImport(Darwin)
    /// Operation not supported.
    public static var ENOTSUP: POSIXError.Code { return .ENOTSUP }
    #endif

    #if !os(Windows)
    /// Protocol family not supported.
    public static var EPFNOSUPPORT: POSIXError.Code { return .EPFNOSUPPORT }

    /// Address family not supported by protocol family.
    public static var EAFNOSUPPORT: POSIXError.Code { return .EAFNOSUPPORT }

    /// Address already in use.
    public static var EADDRINUSE: POSIXError.Code { return .EADDRINUSE }

    /// Can't assign requested address.
    public static var EADDRNOTAVAIL: POSIXError.Code { return .EADDRNOTAVAIL }
    #endif

    /// IPC/Network software -- operational errors

    #if !os(Windows)
    /// Network is down.
    public static var ENETDOWN: POSIXError.Code { return .ENETDOWN }

    /// Network is unreachable.
    public static var ENETUNREACH: POSIXError.Code { return .ENETUNREACH }

    /// Network dropped connection on reset.
    public static var ENETRESET: POSIXError.Code { return .ENETRESET }

    /// Software caused connection abort.
    public static var ECONNABORTED: POSIXError.Code { return .ECONNABORTED }

    /// Connection reset by peer.
    public static var ECONNRESET: POSIXError.Code { return .ECONNRESET }

    /// No buffer space available.
    public static var ENOBUFS: POSIXError.Code { return .ENOBUFS }

    /// Socket is already connected.
    public static var EISCONN: POSIXError.Code { return .EISCONN }

    /// Socket is not connected.
    public static var ENOTCONN: POSIXError.Code { return .ENOTCONN }

    /// Can't send after socket shutdown.
    public static var ESHUTDOWN: POSIXError.Code { return .ESHUTDOWN }

    /// Too many references: can't splice.
    public static var ETOOMANYREFS: POSIXError.Code { return .ETOOMANYREFS }

    /// Operation timed out.
    public static var ETIMEDOUT: POSIXError.Code { return .ETIMEDOUT }

    /// Connection refused.
    public static var ECONNREFUSED: POSIXError.Code { return .ECONNREFUSED }

    /// Too many levels of symbolic links.
    public static var ELOOP: POSIXError.Code { return .ELOOP }
    #endif

    /// File name too long.
    public static var ENAMETOOLONG: POSIXError.Code { return .ENAMETOOLONG }

    #if !os(Windows)
    /// Host is down.
    public static var EHOSTDOWN: POSIXError.Code { return .EHOSTDOWN }

    /// No route to host.
    public static var EHOSTUNREACH: POSIXError.Code { return .EHOSTUNREACH }
    #endif

    /// Directory not empty.
    public static var ENOTEMPTY: POSIXError.Code { return .ENOTEMPTY }

    /// Quotas

    #if canImport(Darwin)
    /// Too many processes.
    public static var EPROCLIM: POSIXError.Code { return .EPROCLIM }
    #endif

    #if !os(Windows)
    /// Too many users.
    public static var EUSERS: POSIXError.Code { return .EUSERS }

    /// Disk quota exceeded.
    public static var EDQUOT: POSIXError.Code { return .EDQUOT }
    #endif

    /// Network File System

    #if !os(Windows)
    /// Stale NFS file handle.
    public static var ESTALE: POSIXError.Code { return .ESTALE }

    /// Too many levels of remote in path.
    public static var EREMOTE: POSIXError.Code { return .EREMOTE }
    #endif

    #if canImport(Darwin)
    /// RPC struct is bad.
    public static var EBADRPC: POSIXError.Code { return .EBADRPC }

    /// RPC version wrong.
    public static var ERPCMISMATCH: POSIXError.Code { return .ERPCMISMATCH }

    /// RPC prog. not avail.
    public static var EPROGUNAVAIL: POSIXError.Code { return .EPROGUNAVAIL }

    /// Program version wrong.
    public static var EPROGMISMATCH: POSIXError.Code { return .EPROGMISMATCH }

    /// Bad procedure for program.
    public static var EPROCUNAVAIL: POSIXError.Code { return .EPROCUNAVAIL }
    #endif

    /// No locks available.
    public static var ENOLCK: POSIXError.Code { return .ENOLCK }

    /// Function not implemented.
    public static var ENOSYS: POSIXError.Code { return .ENOSYS }

    #if canImport(Darwin)
    /// Inappropriate file type or format.
    public static var EFTYPE: POSIXError.Code { return .EFTYPE }

    /// Authentication error.
    public static var EAUTH: POSIXError.Code { return .EAUTH }

    /// Need authenticator.
    public static var ENEEDAUTH: POSIXError.Code { return .ENEEDAUTH }
    #endif

    /// Intelligent device errors.

    #if canImport(Darwin)
    /// Device power is off.
    public static var EPWROFF: POSIXError.Code { return .EPWROFF }

    /// Device error, e.g. paper out.
    public static var EDEVERR: POSIXError.Code { return .EDEVERR }
    #endif

    #if !os(Windows)
    /// Value too large to be stored in data type.
    public static var EOVERFLOW: POSIXError.Code { return .EOVERFLOW }
    #endif

    /// Program loading errors.

    #if canImport(Darwin)
    /// Bad executable.
    public static var EBADEXEC: POSIXError.Code { return .EBADEXEC }
    #endif

    #if canImport(Darwin)
    /// Bad CPU type in executable.
    public static var EBADARCH: POSIXError.Code { return .EBADARCH }

    /// Shared library version mismatch.
    public static var ESHLIBVERS: POSIXError.Code { return .ESHLIBVERS }

    /// Malformed Macho file.
    public static var EBADMACHO: POSIXError.Code { return .EBADMACHO }
    #endif

    /// Operation canceled.
    public static var ECANCELED: POSIXError.Code {
#if os(Windows)
        return POSIXError.Code(rawValue: Int32(ERROR_CANCELLED))!
#else
        return .ECANCELED
#endif
    }

    #if !os(Windows)
    /// Identifier removed.
    public static var EIDRM: POSIXError.Code { return .EIDRM }

    /// No message of desired type.
    public static var ENOMSG: POSIXError.Code { return .ENOMSG }
    #endif

    /// Illegal byte sequence.
    public static var EILSEQ: POSIXError.Code { return .EILSEQ }

    #if canImport(Darwin)
    /// Attribute not found.
    public static var ENOATTR: POSIXError.Code { return .ENOATTR }
    #endif

    #if !os(Windows)
    /// Bad message.
    public static var EBADMSG: POSIXError.Code { return .EBADMSG }

    #if !os(OpenBSD)
    /// Reserved.
    public static var EMULTIHOP: POSIXError.Code { return .EMULTIHOP }

    /// No message available on STREAM.
    public static var ENODATA: POSIXError.Code { return .ENODATA }

    /// Reserved.
    public static var ENOLINK: POSIXError.Code { return .ENOLINK }

    /// No STREAM resources.
    public static var ENOSR: POSIXError.Code { return .ENOSR }

    /// Not a STREAM.
    public static var ENOSTR: POSIXError.Code { return .ENOSTR }
    #endif

    /// Protocol error.
    public static var EPROTO: POSIXError.Code { return .EPROTO }

    #if !os(OpenBSD)
    /// STREAM ioctl timeout.
    public static var ETIME: POSIXError.Code { return .ETIME }
    #endif
    #endif

    #if canImport(Darwin)
    /// No such policy registered.
    public static var ENOPOLICY: POSIXError.Code { return .ENOPOLICY }
    #endif

    #if !os(Windows)
    /// State not recoverable.
    public static var ENOTRECOVERABLE: POSIXError.Code { return .ENOTRECOVERABLE }

    /// Previous owner died.
    public static var EOWNERDEAD: POSIXError.Code { return .EOWNERDEAD }
    #endif

    #if canImport(Darwin)
    /// Interface output queue is full.
    public static var EQFULL: POSIXError.Code { return .EQFULL }
    #endif
}

enum UnknownNSError: Error {
    case missingError
}

// MARK: NSURLErrorDomain

/// `NSURLErrorDomain` indicates an `NSURL` error.
///
/// Constants used by `NSError` to differentiate between "domains" of error codes,
/// serving as a discriminator for error codes that originate from different subsystems or sources.
public let NSURLErrorDomain: String = "NSURLErrorDomain"

/// The `NSError` userInfo dictionary key used to store and retrieve the URL which
/// caused a load to fail.
public let NSURLErrorFailingURLErrorKey: String = "NSErrorFailingURLKey"

/// The `NSError` userInfo dictionary key used to store and retrieve the NSString
/// object for the URL which caused a load to fail.
public let NSURLErrorFailingURLStringErrorKey: String = "NSErrorFailingURLStringKey"

/// The `NSError` userInfo dictionary key used to store and retrieve the
/// SecTrustRef object representing the state of a failed SSL handshake.
public let NSURLErrorFailingURLPeerTrustErrorKey: String = "NSURLErrorFailingURLPeerTrustErrorKey"

/// The `NSError` userInfo dictionary key used to store and retrieve the
/// `NSNumber` corresponding to the reason why a background `URLSessionTask`
/// was cancelled
///
/// One of
/// * `NSURLErrorCancelledReasonUserForceQuitApplication`
/// * `NSURLErrorCancelledReasonBackgroundUpdatesDisabled`
/// * `NSURLErrorCancelledReasonInsufficientSystemResources`
public let NSURLErrorBackgroundTaskCancelledReasonKey: String = "NSURLErrorBackgroundTaskCancelledReasonKey"

/// Code associated with `NSURLErrorBackgroundTaskCancelledReasonKey`
public var NSURLErrorCancelledReasonUserForceQuitApplication: Int { return 0 }
/// Code associated with `NSURLErrorBackgroundTaskCancelledReasonKey`
public var NSURLErrorCancelledReasonBackgroundUpdatesDisabled: Int { return 1 }
/// Code associated with `NSURLErrorBackgroundTaskCancelledReasonKey`
public var NSURLErrorCancelledReasonInsufficientSystemResources: Int { return 2 }

//MARK: NSURL-related Error Codes

public var NSURLErrorUnknown: Int { return -1 }
public var NSURLErrorCancelled: Int { return -999 }
public var NSURLErrorBadURL: Int { return -1000 }
public var NSURLErrorTimedOut: Int { return -1001 }
public var NSURLErrorUnsupportedURL: Int { return -1002 }
public var NSURLErrorCannotFindHost: Int { return -1003 }
public var NSURLErrorCannotConnectToHost: Int { return -1004 }
public var NSURLErrorNetworkConnectionLost: Int { return -1005 }
public var NSURLErrorDNSLookupFailed: Int { return -1006 }
public var NSURLErrorHTTPTooManyRedirects: Int { return -1007 }
public var NSURLErrorResourceUnavailable: Int { return -1008 }
public var NSURLErrorNotConnectedToInternet: Int { return -1009 }
public var NSURLErrorRedirectToNonExistentLocation: Int { return -1010 }
public var NSURLErrorBadServerResponse: Int { return -1011 }
public var NSURLErrorUserCancelledAuthentication: Int { return -1012 }
public var NSURLErrorUserAuthenticationRequired: Int { return -1013 }
public var NSURLErrorZeroByteResource: Int { return -1014 }
public var NSURLErrorCannotDecodeRawData: Int { return -1015 }
public var NSURLErrorCannotDecodeContentData: Int { return -1016 }
public var NSURLErrorCannotParseResponse: Int { return -1017 }
public var NSURLErrorAppTransportSecurityRequiresSecureConnection: Int { return -1022 }
public var NSURLErrorFileDoesNotExist: Int { return -1100 }
public var NSURLErrorFileIsDirectory: Int { return -1101 }
public var NSURLErrorNoPermissionsToReadFile: Int { return -1102 }
public var NSURLErrorDataLengthExceedsMaximum: Int { return -1103 }

// SSL errors
public var NSURLErrorSecureConnectionFailed: Int { return -1201 }
public var NSURLErrorServerCertificateHasBadDate: Int { return -1202 }
public var NSURLErrorServerCertificateUntrusted: Int { return -1203 }
public var NSURLErrorServerCertificateHasUnknownRoot: Int { return -1204 }
public var NSURLErrorServerCertificateNotYetValid: Int { return -1205 }
public var NSURLErrorClientCertificateRejected: Int { return -1206 }
public var NSURLErrorClientCertificateRequired: Int { return -1207 }
public var NSURLErrorCannotLoadFromNetwork: Int { return -2000 }

// Download and file I/O errors
public var NSURLErrorCannotCreateFile: Int { return -3000 }
public var NSURLErrorCannotOpenFile: Int { return -3001 }
public var NSURLErrorCannotCloseFile: Int { return -3002 }
public var NSURLErrorCannotWriteToFile: Int { return -3003 }
public var NSURLErrorCannotRemoveFile: Int { return -3004 }
public var NSURLErrorCannotMoveFile: Int { return -3005 }
public var NSURLErrorDownloadDecodingFailedMidStream: Int { return -3006 }
public var NSURLErrorDownloadDecodingFailedToComplete: Int { return -3007 }

public var NSURLErrorInternationalRoamingOff: Int { return -1018 }
public var NSURLErrorCallIsActive: Int { return -1019 }
public var NSURLErrorDataNotAllowed: Int { return -1020 }
public var NSURLErrorRequestBodyStreamExhausted: Int { return -1021 }

public var NSURLErrorBackgroundSessionRequiresSharedContainer: Int { return -995 }
public var NSURLErrorBackgroundSessionInUseByAnotherProcess: Int { return -996 }
public var NSURLErrorBackgroundSessionWasDisconnected: Int { return -997 }
