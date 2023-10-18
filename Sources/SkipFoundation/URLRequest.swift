// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.URLRequest
internal typealias PlatformURLRequest = Foundation.URLRequest
internal typealias NSURLRequest = Foundation.URLRequest.ReferenceType // i.e., NSURLRequest
#else
public typealias PlatformURLRequest = java.net.HttpURLConnection
public typealias NSURLRequest = URLRequest
#endif

public struct URLRequest : Hashable, CustomStringConvertible {
    #if !SKIP
    internal var platformValue: PlatformURLRequest
    #else
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
    //public var networkServiceType: URLRequest.NetworkServiceType
    //public var attribution: URLRequest.Attribution
    //public var httpBodyStream: InputStream?
    #endif

    #if !SKIP
    internal init(platformValue: PlatformURLRequest) {
        self.platformValue = platformValue
    }

    internal init(_ platformValue: PlatformURLRequest) {
        self.platformValue = platformValue
    }
    #endif

    public init(url: URL, cachePolicy: CachePolicy = CachePolicy.useProtocolCachePolicy, timeoutInterval: TimeInterval = 0.0) {
        #if !SKIP
        self.platformValue = PlatformURLRequest(url: url.platformValue, cachePolicy: .init(rawValue: UInt(cachePolicy.rawValue))!, timeoutInterval: timeoutInterval)
        #else
        self.url = url
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        #endif
    }

    public var description: String {
        #if !SKIP
        return platformValue.description
        #else
        return url?.toString() ?? "url: nil"
        #endif
    }

    public func value(forHTTPHeaderField field: String) -> String? {
        #if !SKIP
        return platformValue.value(forHTTPHeaderField: field)
        #else
        return Self.value(forHTTPHeaderField: field, in: allHTTPHeaderFields ?? [:])
        #endif
    }

    /// Perform a case-insensitive header lookup for the given field name in the header fields
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
        #if !SKIP
        platformValue.setValue(value, forHTTPHeaderField: field)
        #else
        if Self.reservedHeaderKeys.contains(field) {
            return // ignore reserved keys
        }
        var fields = self.allHTTPHeaderFields ?? [:]
        fields[transformHeaderKey(field)] = value
        self.allHTTPHeaderFields = fields
        #endif
    }

    public mutating func addValue(_ value: String, forHTTPHeaderField field: String) {
        #if !SKIP
        platformValue.addValue(value, forHTTPHeaderField: field)
        #else
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
        #endif
    }

    public enum CachePolicy : Int {
        case useProtocolCachePolicy = 0
        case reloadIgnoringLocalCacheData = 1
        case reloadIgnoringLocalAndRemoteCacheData = 4
        //public static var reloadIgnoringCacheData: NSURLRequest.CachePolicy { get }
        case returnCacheDataElseLoad = 2
        case returnCacheDataDontLoad = 3
        case reloadRevalidatingCacheData = 5
    }
}
