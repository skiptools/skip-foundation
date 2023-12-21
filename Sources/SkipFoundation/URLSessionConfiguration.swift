// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

open class URLSessionConfiguration {
    private static let _default = URLSessionConfiguration()

    static var `default`: URLSessionConfiguration {
        return _default
    }

    // TODO: ephemeral config
    private static let _ephemeral = URLSessionConfiguration()

    open class var ephemeral: URLSessionConfiguration {
        return _ephemeral
    }

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
}

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
