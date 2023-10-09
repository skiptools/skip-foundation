// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.URLSessionConfiguration
internal typealias PlatformURLSessionConfiguration = Foundation.URLSessionConfiguration
#else
#endif

/// A configuration object that defines behavior and policies for a URL session.
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
open class URLSessionConfiguration {
    #if SKIP
    private static let _default = URLSessionConfiguration()
    #endif

    static var `default`: URLSessionConfiguration {
        #if !SKIP
        return URLSessionConfiguration(platformValue: PlatformURLSessionConfiguration.default)
        #else
        return _default
        #endif
    }

    #if SKIP
    // TODO: ephemeral config
    private static let _ephemeral = URLSessionConfiguration()
    #endif

    open class var ephemeral: URLSessionConfiguration {
        #if !SKIP
        return URLSessionConfiguration(platformValue: PlatformURLSessionConfiguration.ephemeral)
        #else
        return _ephemeral
        #endif
    }

    #if !SKIP
    internal var platformValue: PlatformURLSessionConfiguration

    init(platformValue: PlatformURLSessionConfiguration) {
        self.platformValue = platformValue
    }
    #else
    public var identifier: String?
    //public var requestCachePolicy: NSURLRequest.CachePolicy
    public var timeoutIntervalForRequest: TimeInterval = 60.0
    public var timeoutIntervalForResource: TimeInterval = 604800.0
    //public var networkServiceType: NSURLRequest.NetworkServiceType
    public var allowsCellularAccess: Bool = true
    public var allowsExpensiveNetworkAccess: Bool = true
    public var allowsConstrainedNetworkAccess: Bool = true
    //public var requiresDNSSECValidation: Bool = true
    public var waitsForConnectivity: Bool = false
    public var isDiscretionary: Bool = false
    public var sharedContainerIdentifier: String? = nil
    public var sessionSendsLaunchEvents: Bool = false
    public var connectionProxyDictionary: [AnyHashable : Any]? = nil
    //public var tlsMinimumSupportedProtocol: SSLProtocol
    //public var tlsMaximumSupportedProtocol: SSLProtocol
    //public var tlsMinimumSupportedProtocolVersion: tls_protocol_version_t
    //public var tlsMaximumSupportedProtocolVersion: tls_protocol_version_t
    public var httpShouldUsePipelining: Bool = false
    public var httpShouldSetCookies: Bool = true
    //public var httpCookieAcceptPolicy: HTTPCookie.AcceptPolicy
    public var httpAdditionalHeaders: [AnyHashable : Any]? = nil
    public var httpMaximumConnectionsPerHost: Int = 6
    //public var httpCookieStorage: HTTPCookieStorage?
    //public var urlCredentialStorage: URLCredentialStorage?
    //public var urlCache: URLCache?
    public var shouldUseExtendedBackgroundIdleMode: Bool = false
    //public var protocolClasses: [AnyClass]?

    public init() {
    }
    #endif
}

#if SKIP
internal protocol HTTPCookieStorage {
}

internal class URLCache {
    public enum StoragePolicy {
        case allowed
        case allowedInMemoryOnly
        case notAllowed
    }
}

internal protocol CachedURLResponse {
}
#endif
