// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP
import okhttp3.HttpUrl.Companion.toHttpUrl

public struct URLComponents : Hashable, Equatable, Sendable {
    public init() {
    }

    public init?(url: URL, resolvingAgainstBaseURL resolve: Bool) {
        self.url = url
    }

    public init?(string: String) {
        self.init(string: string, encodingInvalidCharacters: true)
    }

    public init?(string: String, encodingInvalidCharacters: Bool) {
        guard let url = URL(string: string, encodingInvalidCharacters: encodingInvalidCharacters) else {
            return nil
        }
        self.url = url
    }

    public var url: URL? {
        get {
            guard let string = self.string else {
                return nil
            }
            return URL(string: string)
        }
        set {
            var jarURL: URL?
            if let absoluteString = newValue?.absoluteString, absoluteString.hasPrefix("jar:file:") {
                jarURL = URL(string: "jarfile" + absoluteString.dropFirst(8))
                self.scheme = "jar:file"
            } else {
                self.scheme = newValue?.scheme
            }
            let validURL = jarURL ?? newValue
            self.host = validURL?.host(percentEncoded: false)
            self.port = validURL?.port
            self.percentEncodedPath = validURL?.path(percentEncoded: true) ?? ""
            self.fragment = validURL?.fragment
            self.queryItems = URLQueryItem.from(validURL?.query(percentEncoded: false))
        }
    }

    public func url(relativeTo base: URL?) -> URL? {
        guard let string = self.string else {
            return nil
        }
        return URL(string: string, relativeTo: base)
    }

    public var string: String? {
        get {
            var string = ""
            if let scheme {
                string += scheme + ":"
            }
            if let host {
                if scheme != nil {
                    string += "//"
                }
                string += host
                if let port {
                    string += ":\(port)"
                }
            }
            string += percentEncodedPath
            if let fragment {
                string += "#" + fragment
            }
            if let query = URLQueryItem.queryString(from: queryItems) {
                string += "?" + query
            }
            return string.isEmpty ? nil : string
        }
        set {
            if let newValue {
                self.url = URL(string: newValue)
            } else {
                self.url = nil
            }
        }
    }

    public var scheme: String? = nil
    public var host: String? = nil
    public var port: Int? = nil
    public var percentEncodedPath = ""
    public var fragment: String? = nil
    public var queryItems: [URLQueryItem]? = nil

    @available(*, unavailable)
    public var user: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var password: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    public var query: String? {
        get {
            return URLQueryItem.queryString(from: queryItems)
        }
        set {
            queryItems = URLQueryItem.from(newValue)
        }
    }

    @available(*, unavailable)
    public var percentEncodedUser: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var percentEncodedPassword: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    public var percentEncodedHost: String? {
        get {
            return host?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        }
        set {
            host = newValue?.removingPercentEncoding
        }
    }

    public var encodedHost: String? {
        get {
            return percentEncodedHost
        }
        set {
            percentEncodedHost = newValue
        }
    }

    public var path: String {
        get { percentEncodedPath.removingPercentEncoding ?? "" }
        set {
            percentEncodedPath = newValue.split(separator: "/", omittingEmptySubsequences: false)
                .map { $0.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? "" }
                .joined(separator: "/")
        }
    }

    public var percentEncodedQuery: String? {
        get {
            return URLQueryItem.queryString(from: percentEncodedQueryItems)
        }
        set {
            self.query = newValue?.removingPercentEncoding
        }
    }

    public var percentEncodedFragment: String? {
        get {
            return fragment?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
        }
        set {
            fragment = newValue?.removingPercentEncoding
        }
    }

    public var percentEncodedQueryItems: [URLQueryItem]? {
        get {
            return queryItems?.map { URLQueryItem(name: $0.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "", value: $0.value?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)) }
        }
        set {
            queryItems = newValue?.map { URLQueryItem(name: $0.name.removingPercentEncoding ?? $0.name, value: $0.value?.removingPercentEncoding) }
        }
    }

    @available(*, unavailable)
    public var rangeOfScheme: Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeOfUser: Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeOfPassword: Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeOfHost: Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeOfPort: Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeOfPath: Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeOfQuery: Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeOfFragment: Range<Int>? {
        fatalError()
    }
}

public struct URLQueryItem : Hashable, Equatable, Sendable {
    public var name: String
    public var value: String?

    static func from(_ string: String?) -> [URLQueryItem]? {
        guard let string, !string.isEmpty else {
            return nil
        }
        do {
            // Use okhttp's query parsing
            guard let httpUrl = ("http://skip.tools/?" + string).toHttpUrl() else {
                return nil
            }
            return (0..<httpUrl.querySize).map { index in
                let name = httpUrl.queryParameterName(index)
                let value = httpUrl.queryParameterValue(index)
                return URLQueryItem(name: name, value: value)
            }
        } catch {
            return nil
        }
    }

    static func queryString(from items: [URLQueryItem]?) -> String? {
        guard let items, !items.isEmpty else {
            return nil
        }
        var query = ""
        for item in items {
            let name = item.name
            let value = item.value ?? ""
            if !query.isEmpty {
                query += "&"
            }
            query += name + "=" + value
        }
        return query
    }
}

#endif
