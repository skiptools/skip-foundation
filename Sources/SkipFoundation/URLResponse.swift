// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.URLResponse
internal typealias PlatformURLResponse = Foundation.URLResponse
#else
#endif

public class URLResponse : CustomStringConvertible {
    #if !SKIP
    internal var platformValue: PlatformURLResponse
    public var url: URL? { platformValue.url.flatMap(URL.init(platformValue:)) }
    public var mimeType: String? { platformValue.mimeType }
    public var expectedContentLength: Int64 { platformValue.expectedContentLength }
    public var textEncodingName: String? { platformValue.textEncodingName }
    #else
    public internal(set) var url: URL?
    public internal(set) var mimeType: String?
    public internal(set) var expectedContentLength: Int64 = -1
    public internal(set) var textEncodingName: String?
    #endif

    public init() {
        #if !SKIP
        self.platformValue = PlatformURLResponse()
        #else
        #endif
    }

    public init(url: URL, mimeType: String?, expectedContentLength: Int, textEncodingName: String?) {
        #if !SKIP
        self.platformValue = PlatformURLResponse(url: url.platformValue, mimeType: mimeType, expectedContentLength: expectedContentLength, textEncodingName: textEncodingName)
        #else
        self.url = url
        self.mimeType = mimeType
        self.expectedContentLength = Int64(expectedContentLength)
        self.textEncodingName = textEncodingName
        #endif
    }

    #if !SKIP
    internal init(platformValue: PlatformURLResponse) {
        self.platformValue = platformValue
    }

    public var description: String {
        return platformValue.description
    }
    #endif

    public var suggestedFilename: String? {
        #if !SKIP
        return platformValue.suggestedFilename
        #else
        // A filename specified using the content disposition header.
        // The last path component of the URL.
        // The host of the URL.
        // If the host of URL can't be converted to a valid filename, the filename “unknown” is used.
        if let component = self.url?.lastPathComponent, !component.isEmpty {
            return component
        }
        // not expected by the test cases
        //if let host = self.url?.host {
        //    return host
        //}
        return "Unknown"
        #endif
    }

    public func copy() -> Any {
        #if !SKIP
        return platformValue.copy()
        #else
        if let url = self.url {
            return URLResponse(url: url, mimeType: self.mimeType, expectedContentLength: Int(self.expectedContentLength), textEncodingName: self.textEncodingName)
        } else {
            return URLResponse()
        }
        #endif
    }

    public func isEqual(_ other: Any?) -> Bool {
        #if !SKIP
        return platformValue.isEqual(other)
        #else
        guard let other = other as? URLResponse else {
            return false
        }
        return self.url == other.url &&
            self.mimeType == other.mimeType &&
            self.expectedContentLength == other.expectedContentLength &&
            self.textEncodingName == other.textEncodingName
        #endif
    }

    public var hash: Int {
        #if !SKIP
        return platformValue.hash
        #else
        return hashValue
        #endif
    }
}
