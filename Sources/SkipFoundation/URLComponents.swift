// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public struct URLComponents : Hashable, Equatable, Sendable {
    public init() {
    }

    @available(*, unavailable)
    public init?(url: URL, resolvingAgainstBaseURL resolve: Bool) {
    }

    @available(*, unavailable)
    public init?(string: String) {
    }

    @available(*, unavailable)
    public init?(string: String, encodingInvalidCharacters: Bool) {
    }

    @available(*, unavailable)
    public var url: URL? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public func url(relativeTo base: URL?) -> URL? {
        fatalError()
    }

    @available(*, unavailable)
    public var string: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var scheme: String? {
        get {
            fatalError()
        }
        set {
        }
    }

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

    @available(*, unavailable)
    public var host: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var port: Int? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var path: String {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var query: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var fragment: String? {
        get {
            fatalError()
        }
        set {
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

    @available(*, unavailable)
    public var percentEncodedHost: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var encodedHost: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var percentEncodedPath: String {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var percentEncodedQuery: String? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var percentEncodedFragment: String? {
        get {
            fatalError()
        }
        set {
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

    @available(*, unavailable)
    public var queryItems: [URLQueryItem]? {
        get {
            fatalError()
        }
        set {
        }

    }

    @available(*, unavailable)
    public var percentEncodedQueryItems: [URLQueryItem]? {
        get {
            fatalError()
        }
        set {
        }
    }
}

public struct URLQueryItem : Hashable, Equatable, Sendable {
    public init(name: String, value: String?) {
        self.name = name
        self.value = value
    }

    public var name: String
    public var value: String?
}

#endif
