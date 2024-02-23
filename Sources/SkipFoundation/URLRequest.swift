// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias NSURLRequest = URLRequest

public struct URLRequest : Hashable, CustomStringConvertible {
    public var url: URL?
    public var httpMethod: String? = "GET" {
        didSet {
            if let method = httpMethod,
                method != method.uppercased(),
               ["GET", "PUT", "HEAD", "POST", "DELETE", "CONNECT"].contains(method.uppercased())
            {
                // standard method names are always uppercase
                self.httpMethod = method.uppercased()
            }
        }
    }
    public var httpBody: Data? = nil
    public var allHTTPHeaderFields: [String : String]? = nil
    public var cachePolicy: CachePolicy = CachePolicy.useProtocolCachePolicy
    public var timeoutInterval: TimeInterval = 0.0
    public var allowsCellularAccess: Bool = true
    public var allowsExpensiveNetworkAccess: Bool = true
    public var allowsConstrainedNetworkAccess: Bool = true
    public var assumesHTTP3Capable: Bool = true
    public var requiresDNSSECValidation: Bool = false
    public var httpShouldHandleCookies: Bool = true
    public var httpShouldUsePipelining: Bool = true
    public var mainDocumentURL: URL? = nil
    public var networkServiceType: URLRequest.NetworkServiceType = URLRequest.NetworkServiceType.default
    public var attribution: URLRequest.Attribution = URLRequest.Attribution.developer
    @available(*, unavailable)
    public var httpBodyStream: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    public init(url: URL, cachePolicy: CachePolicy = CachePolicy.useProtocolCachePolicy, timeoutInterval: TimeInterval = 0.0) {
        self.url = url
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }

    public var description: String {
        return url?.toString() ?? "url: nil"
    }

    public func value(forHTTPHeaderField field: String) -> String? {
        return Self.value(forHTTPHeaderField: field, in: allHTTPHeaderFields ?? [:])
    }

    /// Perform a case-insensitive header lookup for the given field name in the header fields.
    internal static func value(forHTTPHeaderField fieldName: String, in headerFields: [String: String]) -> String? {
        if let value = headerFields[fieldName] {
            // fast case-sensitive match
            return value.description
        } else {
            // case-insensitive key lookup
            let fieldKey = fieldName.lowercased()
            for (key, value) in headerFields {
                if fieldKey == key.lowercased() {
                    return value
                }
            }
            return nil // not found
        }
    }

    // The lowercased header heys that are reserved
    private static let reservedHeaderKeys = Set([
        "Content-Length".lowercased(),
        "Authorization".lowercased(),
        "Connection".lowercased(),
        "Host".lowercased(),
        "Proxy-Authenticate".lowercased(),
        "Proxy-Authorization".lowercased(),
        "WWW-Authenticate".lowercased(),
    ])

    private func transformHeaderKey(value: String) -> String {
        let lowerName = value.lowercased()
        if lowerName == "accept" {
            return "Accept"
        }
        return value
    }

    public mutating func setValue(_ value: String?, forHTTPHeaderField field: String) {
        if Self.reservedHeaderKeys.contains(field) {
            return // ignore reserved keys
        }
        var fields = self.allHTTPHeaderFields ?? [:]
        fields[transformHeaderKey(field)] = value
        self.allHTTPHeaderFields = fields
    }

    public mutating func addValue(_ value: String, forHTTPHeaderField field: String) {
        if Self.reservedHeaderKeys.contains(field) {
            return // ignore reserved keys
        }
        let fieldKey = transformHeaderKey(field)
        var fields = self.allHTTPHeaderFields ?? [:]
        var fieldValue: String = value
        // multiple vales are appended together with commas
        if let existingValue = fields[fieldKey], !existingValue.isEmpty, !value.isEmpty {
            fieldValue = existingValue + "," + value
        }
        fields[fieldKey] = fieldValue
        self.allHTTPHeaderFields = fields
    }

    public enum Attribution : Int {
        case developer
        case user
    }

    public enum CachePolicy : Int {
        case useProtocolCachePolicy = 0
        case reloadIgnoringLocalCacheData = 1
        case reloadIgnoringLocalAndRemoteCacheData = 4
        case returnCacheDataElseLoad = 2
        case returnCacheDataDontLoad = 3
        case reloadRevalidatingCacheData = 5
    }

    public enum NetworkServiceType : Int {
        case `default`
        case voip
        case video
        case background
        case voice
        case responsiveData
        case avStreaming
        case responsiveAV
        case callSignaling
    }
}

#endif
