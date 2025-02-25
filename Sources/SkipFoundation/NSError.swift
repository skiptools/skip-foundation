// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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

#if SKIP

public typealias NSErrorDomain = String

public let NSCocoaErrorDomain: String = "NSCocoaErrorDomain"
public let NSPOSIXErrorDomain: String = "NSPOSIXErrorDomain"
public let NSOSStatusErrorDomain: String = "NSOSStatusErrorDomain"
public let NSMachErrorDomain: String = "NSMachErrorDomain"

public let NSUnderlyingErrorKey: String = "NSUnderlyingError"
public let NSLocalizedDescriptionKey: String = "NSLocalizedDescription"
public let NSLocalizedFailureReasonErrorKey: String = "NSLocalizedFailureReason"
public let NSLocalizedRecoverySuggestionErrorKey: String = "NSLocalizedRecoverySuggestion"
public let NSLocalizedRecoveryOptionsErrorKey: String = "NSLocalizedRecoveryOptions"
public let NSRecoveryAttempterErrorKey: String = "NSRecoveryAttempter"
public let NSHelpAnchorErrorKey: String = "NSHelpAnchor"
public let NSDebugDescriptionErrorKey = "NSDebugDescription"
public let NSStringEncodingErrorKey: String = "NSStringEncodingErrorKey"
public let NSURLErrorKey: String = "NSURL"
public let NSFilePathErrorKey: String = "NSFilePathErrorKey"

open class NSError : Error, CustomStringConvertible {
    // ErrorType forbids this being internal
    open var _domain: String
    open var _code: Int

    private var _userInfo: [String : Any]?

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

public protocol LocalizedError : Error {
    var errorDescription: String? { get }
    var failureReason: String? { get }
    var recoverySuggestion: String? { get }
    var helpAnchor: String? { get }
}

public extension LocalizedError {
    var errorDescription: String? { return nil }
    var failureReason: String? { return nil }
    var recoverySuggestion: String? { return nil }
    var helpAnchor: String? { return nil }
}

class _NSErrorRecoveryAttempter {
    func attemptRecovery(fromError error: Error,
        optionIndex recoveryOptionIndex: Int) -> Bool {
        let recoverableError = error as! RecoverableError
        return recoverableError.attemptRecovery(optionIndex: recoveryOptionIndex)
  }
}

public protocol RecoverableError : Error {
    var recoveryOptions: [String] { get }
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (_ recovered: Bool) -> Void)
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool
}

public extension RecoverableError {
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (_ recovered: Bool) -> Void) {
        handler(attemptRecovery(optionIndex: recoveryOptionIndex))
    }
}

public protocol CustomNSError : Error {
    //static var errorDomain: String { get } // FIXME: Kotlin does not support static members in protocols

    var errorCode: Int { get }
    var errorUserInfo: [String : Any] { get }
}

public extension CustomNSError {
    var errorCode: Int {
        return 0 // no equivalent for Swift._getDefaultErrorCode()
    }

    var errorUserInfo: [String : Any] {
        return [:]
    }
}

public struct CocoaError: Error {
    public let _nsError: NSError

    public init(_nsError error: NSError) {
        precondition(error.domain == NSCocoaErrorDomain)
        self._nsError = error
    }

    public var code: Code { Code(rawValue: _nsError.code) }

    public static var _nsErrorDomain: String { return NSCocoaErrorDomain }

    public struct Code : RawRepresentable, Hashable {
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

    private var _nsUserInfo: [String: Any] {
        return _nsError.userInfo
    }

    public var filePath: String? {
        return _nsUserInfo[NSFilePathErrorKey] as? String
    }

    public var underlying: Error? {
        return _nsUserInfo[NSUnderlyingErrorKey] as? Error
    }

    public var url: URL? {
        return _nsUserInfo[NSURLErrorKey] as? URL
    }

    public static func error(_ code: CocoaError.Code, userInfo: [AnyHashable: Any]? = nil, url: URL? = nil) -> Error {
        // SKIP NOWARN
        var info: [String: Any] = userInfo as? [String: Any] ?? [:]
        if let url = url {
            info[NSURLErrorKey] = url
        }
        return NSError(domain: NSCocoaErrorDomain, code: code.rawValue, userInfo: info)
    }

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

public struct URLError: Error {
    public let _nsError: NSError

    public init(_nsError error: NSError) {
        precondition(error.domain == NSURLErrorDomain)
        self._nsError = error
    }

    public init(_ code: URLError.Code, userInfo: [String: Any] = [:]) {
        self.init(_nsError: NSError(domain: NSURLErrorDomain, code: code.rawValue, userInfo: userInfo))
    }

    public var code: Code { Code(rawValue: _nsError.code)! }

    public static var _nsErrorDomain: String { return NSURLErrorDomain }

    public enum Code : Int {
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

    private var _nsUserInfo: [String: Any] {
        return _nsError.userInfo
    }

    public var failingURL: URL? {
        return _nsUserInfo[NSURLErrorFailingURLErrorKey] as? URL
    }

    public var failureURLString: String? {
        return _nsUserInfo[NSURLErrorFailingURLStringErrorKey] as? String
    }

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

public struct POSIXError: Error {
    public let _nsError: NSError

    public init(_nsError error: NSError) {
        precondition(error.domain == NSPOSIXErrorDomain)
        self._nsError = error
    }

    public static var _nsErrorDomain: String { return NSPOSIXErrorDomain }

    //public typealias Code = POSIXErrorCode // FIXME: Kotlin does not support typealias declarations within functions and types. Consider moving this to a top level declaration

    public enum Code : Int32 {
        case EPERM = 1
        case ENOENT = 2
        case ESRCH = 3
        case EINTR = 4
        case EIO = 5
        case ENXIO = 6
        case E2BIG = 7
        case ENOEXEC = 8
        case EBADF = 9
        case ECHILD = 10
        case EDEADLK = 11
        case ENOMEM = 12
        case EACCES = 13
        case EFAULT = 14
        case ENOTBLK = 15
        case EBUSY = 16
        case EEXIST = 17
        case EXDEV = 18
        case ENODEV = 19
        case ENOTDIR = 20
        case EISDIR = 21
        case EINVAL = 22
        case ENFILE = 23
        case EMFILE = 24
        case ENOTTY = 25
        case ETXTBSY = 26
        case EFBIG = 27
        case ENOSPC = 28
        case ESPIPE = 29
        case EROFS = 30
        case EMLINK = 31
        case EPIPE = 32
        case EDOM = 33
        case ERANGE = 34
        case EAGAIN = 35
        //public static var EWOULDBLOCK: POSIXErrorCode { get }
        case EINPROGRESS = 36
        case EALREADY = 37
        case ENOTSOCK = 38
        case EDESTADDRREQ = 39
        case EMSGSIZE = 40
        case EPROTOTYPE = 41
        case ENOPROTOOPT = 42
        case EPROTONOSUPPORT = 43
        case ESOCKTNOSUPPORT = 44
        case ENOTSUP = 45
        case EPFNOSUPPORT = 46
        case EAFNOSUPPORT = 47
        case EADDRINUSE = 48
        case EADDRNOTAVAIL = 49
        case ENETDOWN = 50
        case ENETUNREACH = 51
        case ENETRESET = 52
        case ECONNABORTED = 53
        case ECONNRESET = 54
        case ENOBUFS = 55
        case EISCONN = 56
        case ENOTCONN = 57
        case ESHUTDOWN = 58
        case ETOOMANYREFS = 59
        case ETIMEDOUT = 60
        case ECONNREFUSED = 61
        case ELOOP = 62
        case ENAMETOOLONG = 63
        case EHOSTDOWN = 64
        case EHOSTUNREACH = 65
        case ENOTEMPTY = 66
        case EPROCLIM = 67
        case EUSERS = 68
        case EDQUOT = 69
        case ESTALE = 70
        case EREMOTE = 71
        case EBADRPC = 72
        case ERPCMISMATCH = 73
        case EPROGUNAVAIL = 74
        case EPROGMISMATCH = 75
        case EPROCUNAVAIL = 76
        case ENOLCK = 77
        case ENOSYS = 78
        case EFTYPE = 79
        case EAUTH = 80
        case ENEEDAUTH = 81
        case EPWROFF = 82
        case EDEVERR = 83
        case EOVERFLOW = 84
        case EBADEXEC = 85
        case EBADARCH = 86
        case ESHLIBVERS = 87
        case EBADMACHO = 88
        case ECANCELED = 89
        case EIDRM = 90
        case ENOMSG = 91
        case EILSEQ = 92
        case ENOATTR = 93
        case EBADMSG = 94
        case EMULTIHOP = 95
        case ENODATA = 96
        case ENOLINK = 97
        case ENOSR = 98
        case ENOSTR = 99
        case EPROTO = 100
        case ETIME = 101
        case ENOPOLICY = 103
        case ENOTRECOVERABLE = 104
        case EOWNERDEAD = 105
        case EQFULL = 106
        //public static var ELAST: POSIXErrorCode { get }
    }

    public static var EPERM: POSIXError.Code { return .EPERM }
    public static var ENOENT: POSIXError.Code { return .ENOENT }
    public static var ESRCH: POSIXError.Code { return .ESRCH }
    public static var EINTR: POSIXError.Code { return .EINTR }
    public static var EIO: POSIXError.Code { return .EIO }
    public static var ENXIO: POSIXError.Code { return .ENXIO }
    public static var E2BIG: POSIXError.Code { return .E2BIG }
    public static var ENOEXEC: POSIXError.Code { return .ENOEXEC }
    public static var EBADF: POSIXError.Code { return .EBADF }
    public static var ECHILD: POSIXError.Code { return .ECHILD }
    public static var EDEADLK: POSIXError.Code { return .EDEADLK }
    public static var ENOMEM: POSIXError.Code { return .ENOMEM }
    public static var EACCES: POSIXError.Code { return .EACCES }
    public static var EFAULT: POSIXError.Code { return .EFAULT }
    #if !os(Windows)
    public static var ENOTBLK: POSIXError.Code { return .ENOTBLK }
    #endif
    public static var EBUSY: POSIXError.Code { return .EBUSY }
    public static var EEXIST: POSIXError.Code { return .EEXIST }
    public static var EXDEV: POSIXError.Code { return .EXDEV }
    public static var ENODEV: POSIXError.Code { return .ENODEV }
    public static var ENOTDIR: POSIXError.Code { return .ENOTDIR }
    public static var EISDIR: POSIXError.Code { return .EISDIR }
    public static var EINVAL: POSIXError.Code { return .EINVAL }
    public static var ENFILE: POSIXError.Code { return .ENFILE }
    public static var EMFILE: POSIXError.Code { return .EMFILE }
    public static var ENOTTY: POSIXError.Code { return .ENOTTY }
    #if !os(Windows)
    public static var ETXTBSY: POSIXError.Code { return .ETXTBSY }
    #endif
    public static var EFBIG: POSIXError.Code { return .EFBIG }
    public static var ENOSPC: POSIXError.Code { return .ENOSPC }
    public static var ESPIPE: POSIXError.Code { return .ESPIPE }
    public static var EROFS: POSIXError.Code { return .EROFS }
    public static var EMLINK: POSIXError.Code { return .EMLINK }
    public static var EPIPE: POSIXError.Code { return .EPIPE }
    public static var EDOM: POSIXError.Code { return .EDOM }
    public static var ERANGE: POSIXError.Code { return .ERANGE }
    public static var EAGAIN: POSIXError.Code { return .EAGAIN }
    #if !os(Windows)
    //public static var EWOULDBLOCK: POSIXError.Code { return .EWOULDBLOCK }
    public static var EINPROGRESS: POSIXError.Code { return .EINPROGRESS }
    public static var EALREADY: POSIXError.Code { return .EALREADY }
    public static var ENOTSOCK: POSIXError.Code { return .ENOTSOCK }
    public static var EDESTADDRREQ: POSIXError.Code { return .EDESTADDRREQ }
    public static var EMSGSIZE: POSIXError.Code { return .EMSGSIZE }
    public static var EPROTOTYPE: POSIXError.Code { return .EPROTOTYPE }
    public static var ENOPROTOOPT: POSIXError.Code { return .ENOPROTOOPT }
    public static var EPROTONOSUPPORT: POSIXError.Code { return .EPROTONOSUPPORT }
    public static var ESOCKTNOSUPPORT: POSIXError.Code { return .ESOCKTNOSUPPORT }
    #endif
    #if canImport(Darwin)
    public static var ENOTSUP: POSIXError.Code { return .ENOTSUP }
    #endif
    #if !os(Windows)
    public static var EPFNOSUPPORT: POSIXError.Code { return .EPFNOSUPPORT }
    public static var EAFNOSUPPORT: POSIXError.Code { return .EAFNOSUPPORT }
    public static var EADDRINUSE: POSIXError.Code { return .EADDRINUSE }
    public static var EADDRNOTAVAIL: POSIXError.Code { return .EADDRNOTAVAIL }
    public static var ENETDOWN: POSIXError.Code { return .ENETDOWN }
    public static var ENETUNREACH: POSIXError.Code { return .ENETUNREACH }
    public static var ENETRESET: POSIXError.Code { return .ENETRESET }
    public static var ECONNABORTED: POSIXError.Code { return .ECONNABORTED }
    public static var ECONNRESET: POSIXError.Code { return .ECONNRESET }
    public static var ENOBUFS: POSIXError.Code { return .ENOBUFS }
    public static var EISCONN: POSIXError.Code { return .EISCONN }
    public static var ENOTCONN: POSIXError.Code { return .ENOTCONN }
    public static var ESHUTDOWN: POSIXError.Code { return .ESHUTDOWN }
    public static var ETOOMANYREFS: POSIXError.Code { return .ETOOMANYREFS }
    public static var ETIMEDOUT: POSIXError.Code { return .ETIMEDOUT }
    public static var ECONNREFUSED: POSIXError.Code { return .ECONNREFUSED }
    public static var ELOOP: POSIXError.Code { return .ELOOP }
    #endif
    public static var ENAMETOOLONG: POSIXError.Code { return .ENAMETOOLONG }
    #if !os(Windows)
    public static var EHOSTDOWN: POSIXError.Code { return .EHOSTDOWN }
    public static var EHOSTUNREACH: POSIXError.Code { return .EHOSTUNREACH }
    #endif
    public static var ENOTEMPTY: POSIXError.Code { return .ENOTEMPTY }
    #if canImport(Darwin)
    public static var EPROCLIM: POSIXError.Code { return .EPROCLIM }
    #endif
    #if !os(Windows)
    public static var EUSERS: POSIXError.Code { return .EUSERS }
    public static var EDQUOT: POSIXError.Code { return .EDQUOT }
    public static var ESTALE: POSIXError.Code { return .ESTALE }
    public static var EREMOTE: POSIXError.Code { return .EREMOTE }
    #endif
    #if canImport(Darwin)
    public static var EBADRPC: POSIXError.Code { return .EBADRPC }
    public static var ERPCMISMATCH: POSIXError.Code { return .ERPCMISMATCH }
    public static var EPROGUNAVAIL: POSIXError.Code { return .EPROGUNAVAIL }
    public static var EPROGMISMATCH: POSIXError.Code { return .EPROGMISMATCH }
    public static var EPROCUNAVAIL: POSIXError.Code { return .EPROCUNAVAIL }
    #endif
    public static var ENOLCK: POSIXError.Code { return .ENOLCK }
    public static var ENOSYS: POSIXError.Code { return .ENOSYS }
    #if canImport(Darwin)
    public static var EFTYPE: POSIXError.Code { return .EFTYPE }
    public static var EAUTH: POSIXError.Code { return .EAUTH }
    public static var ENEEDAUTH: POSIXError.Code { return .ENEEDAUTH }
    public static var EPWROFF: POSIXError.Code { return .EPWROFF }
    public static var EDEVERR: POSIXError.Code { return .EDEVERR }
    #endif
    #if !os(Windows)
    public static var EOVERFLOW: POSIXError.Code { return .EOVERFLOW }
    #endif
    #if canImport(Darwin)
    public static var EBADEXEC: POSIXError.Code { return .EBADEXEC }
    public static var EBADARCH: POSIXError.Code { return .EBADARCH }
    public static var ESHLIBVERS: POSIXError.Code { return .ESHLIBVERS }
    public static var EBADMACHO: POSIXError.Code { return .EBADMACHO }
    #endif
    public static var ECANCELED: POSIXError.Code {
    #if os(Windows)
        return POSIXError.Code(rawValue: Int32(ERROR_CANCELLED))!
    #else
        return .ECANCELED
    #endif
    }
    #if !os(Windows)
    public static var EIDRM: POSIXError.Code { return .EIDRM }
    public static var ENOMSG: POSIXError.Code { return .ENOMSG }
    #endif
    public static var EILSEQ: POSIXError.Code { return .EILSEQ }
    #if canImport(Darwin)
    public static var ENOATTR: POSIXError.Code { return .ENOATTR }
    #endif
    #if !os(Windows)
    public static var EBADMSG: POSIXError.Code { return .EBADMSG }
    #if !os(OpenBSD)
    public static var EMULTIHOP: POSIXError.Code { return .EMULTIHOP }
    public static var ENODATA: POSIXError.Code { return .ENODATA }
    public static var ENOLINK: POSIXError.Code { return .ENOLINK }
    public static var ENOSR: POSIXError.Code { return .ENOSR }
    public static var ENOSTR: POSIXError.Code { return .ENOSTR }
    #endif
    public static var EPROTO: POSIXError.Code { return .EPROTO }
    #if !os(OpenBSD)
    public static var ETIME: POSIXError.Code { return .ETIME }
    #endif
    #endif
    #if canImport(Darwin)
    public static var ENOPOLICY: POSIXError.Code { return .ENOPOLICY }
    #endif
    #if !os(Windows)
    public static var ENOTRECOVERABLE: POSIXError.Code { return .ENOTRECOVERABLE }
    public static var EOWNERDEAD: POSIXError.Code { return .EOWNERDEAD }
    #endif
    #if canImport(Darwin)
    public static var EQFULL: POSIXError.Code { return .EQFULL }
    #endif
}

enum UnknownNSError: Error {
    case missingError
}

public let NSURLErrorDomain: String = "NSURLErrorDomain"
public let NSURLErrorFailingURLErrorKey: String = "NSErrorFailingURLKey"
public let NSURLErrorFailingURLStringErrorKey: String = "NSErrorFailingURLStringKey"
public let NSURLErrorFailingURLPeerTrustErrorKey: String = "NSURLErrorFailingURLPeerTrustErrorKey"
public let NSURLErrorBackgroundTaskCancelledReasonKey: String = "NSURLErrorBackgroundTaskCancelledReasonKey"
public var NSURLErrorCancelledReasonUserForceQuitApplication: Int { return 0 }
public var NSURLErrorCancelledReasonBackgroundUpdatesDisabled: Int { return 1 }
public var NSURLErrorCancelledReasonInsufficientSystemResources: Int { return 2 }

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

public var NSURLErrorSecureConnectionFailed: Int { return -1201 }
public var NSURLErrorServerCertificateHasBadDate: Int { return -1202 }
public var NSURLErrorServerCertificateUntrusted: Int { return -1203 }
public var NSURLErrorServerCertificateHasUnknownRoot: Int { return -1204 }
public var NSURLErrorServerCertificateNotYetValid: Int { return -1205 }
public var NSURLErrorClientCertificateRejected: Int { return -1206 }
public var NSURLErrorClientCertificateRequired: Int { return -1207 }
public var NSURLErrorCannotLoadFromNetwork: Int { return -2000 }

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

#endif
