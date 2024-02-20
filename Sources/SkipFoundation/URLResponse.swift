// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class URLResponse : Hashable, CustomStringConvertible {
    public internal(set) var url: URL?
    public internal(set) var mimeType: String?
    public internal(set) var expectedContentLength: Int64 = -1
    public internal(set) var textEncodingName: String?

    public init() {
    }

    public init(url: URL, mimeType: String?, expectedContentLength: Int, textEncodingName: String?) {
        self.url = url
        self.mimeType = mimeType
        self.expectedContentLength = Int64(expectedContentLength)
        self.textEncodingName = textEncodingName
    }

    public var suggestedFilename: String? {
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
    }

    public func copy() -> Any {
        if let url = self.url {
            return URLResponse(url: url, mimeType: self.mimeType, expectedContentLength: Int(self.expectedContentLength), textEncodingName: self.textEncodingName)
        } else {
            return URLResponse()
        }
    }

    public func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? URLResponse else {
            return false
        }
        return self.url == other.url &&
            self.mimeType == other.mimeType &&
            self.expectedContentLength == other.expectedContentLength &&
            self.textEncodingName == other.textEncodingName
    }

    public static func ==(lhs: URLResponse, rhs: URLResponse) -> Bool {
        return lhs.isEqual(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(mimeType)
        hasher.combine(expectedContentLength)
        hasher.combine(textEncodingName)
    }
}

#endif
