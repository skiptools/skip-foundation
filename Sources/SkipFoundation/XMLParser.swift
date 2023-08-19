// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
// #if !SKIP
// import struct Foundation.XMLParser
// public typealias PlatformXMLParser = Foundation.XMLParser
// #else
// public typealias PlatformXMLParser = java.util.XMLParser
// #endif
//
//
// public struct XMLParser : RawRepresentable, Hashable, CustomStringConvertible {
//     public var platformValue: PlatformXMLParser
//
//     public init(platformValue: PlatformXMLParser) {
//         self.platformValue = platformValue
//     }
//
//     public init(_ platformValue: PlatformXMLParser = PlatformXMLParser()) {
//         self.platformValue = platformValue
//     }
//
//     var description: String {
//         return platformValue.description
//     }
// }
