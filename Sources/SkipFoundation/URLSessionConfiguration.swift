// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

open class URLSessionConfiguration {
    open class var `default`: URLSessionConfiguration {
        return _default
    }
    private static let _default = URLSessionConfiguration()

    open class var ephemeral: URLSessionConfiguration {
        return _ephemeral
    }
    // TODO: ephemeral config
    private static let _ephemeral = URLSessionConfiguration()

    @available(*, unavailable)
    public class func background(withIdentifier: String) -> URLSessionConfiguration {
        fatalError()
    }

    public var identifier: String?
    public var requestCachePolicy: URLRequest.CachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    public var timeoutIntervalForRequest: TimeInterval = 60.0
    public var timeoutIntervalForResource: TimeInterval = 604800.0
    public var networkServiceType: URLRequest.NetworkServiceType = URLRequest.NetworkServiceType.default
    public var allowsCellularAccess: Bool = true
    public var allowsExpensiveNetworkAccess: Bool = true
    public var allowsConstrainedNetworkAccess: Bool = true
    public var requiresDNSSECValidation: Bool = true
    public var waitsForConnectivity: Bool = false
    public var isDiscretionary: Bool = false
    public var sharedContainerIdentifier: String? = nil
    public var sessionSendsLaunchEvents: Bool = false
    public var connectionProxyDictionary: [AnyHashable : Any]? = nil
    public var httpShouldUsePipelining: Bool = false
    public var httpShouldSetCookies: Bool = true
    public var httpAdditionalHeaders: [AnyHashable : Any]? = nil
    public var httpMaximumConnectionsPerHost: Int = 6
    public var shouldUseExtendedBackgroundIdleMode: Bool = false
    public var protocolClasses: [AnyClass]? = nil

    public init() {
    }

    @available(*, unavailable)
    public var httpCookieAcceptPolicy: Any {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var httpCookieStorage: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var urlCredentialStorage: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var urlCache: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var tlsMinimumSupportedProtocol: Any {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var tlsMaximumSupportedProtocol: Any {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var tlsMinimumSupportedProtocolVersion: Any {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var tlsMaximumSupportedProtocolVersion: Any {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var multipathServiceType: Any {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var proxyConfigurations: [Any] {
        get {
            fatalError()
        }
        set {
        }
    }
}

#endif
