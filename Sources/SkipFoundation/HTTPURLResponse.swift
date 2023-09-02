// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.HTTPURLResponse
internal typealias PlatformHTTPURLResponse = Foundation.HTTPURLResponse
#else
#endif

/// The metadata associated with the response to an HTTP protocol URL load request.
public class HTTPURLResponse : URLResponse {
    override init(url: URL, mimeType: String?, expectedContentLength: Int, textEncodingName: String?) {
        super.init(url: url, mimeType: mimeType, expectedContentLength: expectedContentLength, textEncodingName: textEncodingName)
    }

    #if SKIP
    public private(set) var statusCode: Int = 0
    public private(set) var allHeaderFields: [String : String] = [:]
    private var httpVersion: String? = nil

    public init?(url: URL, statusCode: Int, httpVersion: String?, headerFields: [String : String]?) {
        // get content length and type from header fields, bearing in mind their case-insensitivity
        // "conTent-lenGTH": "123"
        // "CONTENT-type": "text/plAIn; charset=ISO-8891-1"
        super.init(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        self.httpVersion = httpVersion
        self.allHeaderFields = headerFields ?? [:]
        self.statusCode = statusCode

        self.expectedContentLength = value(forHTTPHeaderField: "Content-Length")?.toLongOrNull() ?? -1

        if let contentType = value(forHTTPHeaderField: "Content-Type") {
            // handle "text/HTML; charset=ISO-8859-4"
            let parts = contentType.split(separator: ";") // TODO: need to not split on semicolons within quoted strings, like a filename
            if parts.count > 1 {
                self.mimeType = parts.firstOrNull()?.lowercased()
                for part in parts.dropFirst() {
                    let keyValue = part.split(separator: "=")
                    if keyValue.firstOrNull()?.trim() == "charset",
                        let charset = keyValue.lastOrNull()?.trim() {
                        self.textEncodingName = charset.lowercased()
                    }
                }
            } else {
                self.mimeType = contentType.lowercased()
            }
        }
    }
    #endif

    public override var suggestedFilename: String? {
        #if SKIP
        func splitStringWithQuotes(input: String, separator: String) -> [String] {
            let regex = Regex("(?<=^|\\s|\\w)(?<!\\w)\(separator)(?=\\s|\\w)")
            return Array(regex.split(input))
        }

        // let f = ["Content-Disposition": "attachment; filename=\"fname.ext\""]
        if var contentDisposition = value(forHTTPHeaderField: "Content-Disposition"),
           contentDisposition.hasPrefix("attachment;") {
            //let parts = splitStringWithQuotes(input: contentDisposition, separator: ";")
            let parts = contentDisposition.split(separator: ";").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })

            if parts.firstOrNull() == "attachment" {
                for part in parts.dropFirst() {
                    let keyValue = part.split(separator: "=")
                    if keyValue.firstOrNull()?.trim() == "filename" {
                        guard var filename: String = keyValue.lastOrNull()?.trim(*"\"".toCharArray()) else {
                            continue
                        }
                        filename = filename.replace("/", "_") // escape path separators
                        return filename
                    }
                }
            }
        }
        #endif
        return super.suggestedFilename // fallback to super impl
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func value(forHTTPHeaderField field: String) -> String? {
        #if !SKIP
        return (platformValue as? PlatformHTTPURLResponse)?.value(forHTTPHeaderField: field)
        #else
        return URLRequest.value(forHTTPHeaderField: field, in: allHeaderFields)
        #endif
    }

    public static func localizedString(forStatusCode statusCode: Int) -> String {
        #if !SKIP
        return PlatformHTTPURLResponse.localizedString(forStatusCode: statusCode)
        #else
        switch statusCode {
            // Informational 1xx
            case 100: return "Continue"
            case 101: return "Switching Protocols"
            case 102: return "Processing"

            // Successful 2xx
            case 200: return "OK"
            case 201: return "Created"
            case 202: return "Accepted"
            case 203: return "Non-Authoritative Information"
            case 204: return "No Content"
            case 205: return "Reset Content"
            case 206: return "Partial Content"
            case 207: return "Multi-Status"
            case 208: return "Already Reported"
            case 226: return "IM Used"

            // Redirection 3xx
            case 300: return "Multiple Choices"
            case 301: return "Moved Permanently"
            case 302: return "Found"
            case 303: return "See Other"
            case 304: return "Not Modified"
            case 305: return "Use Proxy"
            case 307: return "Temporary Redirect"
            case 308: return "Permanent Redirect"

            // Client Error 4xx
            case 400: return "Bad Request"
            case 401: return "Unauthorized"
            case 402: return "Payment Required"
            case 403: return "Forbidden"
            case 404: return "Not Found"
            case 405: return "Method Not Allowed"
            case 406: return "Not Acceptable"
            case 407: return "Proxy Authentication Required"
            case 408: return "Request Timeout"
            case 409: return "Conflict"
            case 410: return "Gone"
            case 411: return "Length Required"
            case 412: return "Precondition Failed"
            case 413: return "Payload Too Large"
            case 414: return "URI Too Long"
            case 415: return "Unsupported Media Type"
            case 416: return "Range Not Satisfiable"
            case 417: return "Expectation Failed"
            case 418: return "I'm a teapot"
            case 421: return "Misdirected Request"
            case 422: return "Unprocessable Entity"
            case 423: return "Locked"
            case 424: return "Failed Dependency"
            case 426: return "Upgrade Required"
            case 428: return "Precondition Required"
            case 429: return "Too Many Requests"
            case 431: return "Request Header Fields Too Large"
            case 451: return "Unavailable For Legal Reasons"

            // Server Error 5xx
            case 500: return "Internal Server Error"
            case 501: return "Not Implemented"
            case 502: return "Bad Gateway"
            case 503: return "Service Unavailable"
            case 504: return "Gateway Timeout"
            case 505: return "HTTP Version Not Supported"
            case 506: return "Variant Also Negotiates"
            case 507: return "Insufficient Storage"
            case 508: return "Loop Detected"
            case 510: return "Not Extended"
            case 511: return "Network Authentication Required"

            // Add more cases for additional status codes if needed
            default: return "Unknown"
        }
        #endif
    }
}
