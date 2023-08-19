// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
// #if !SKIP
// import struct Foundation.DateIntervalFormatter
// public typealias PlatformDateIntervalFormatter = Foundation.DateIntervalFormatter
// #else
// public typealias PlatformDateIntervalFormatter = java.util.DateIntervalFormatter
// #endif
//
//
// public struct DateIntervalFormatter : Hashable, CustomStringConvertible {
//     public var platformValue: PlatformDateIntervalFormatter
//
//     public init(platformValue: PlatformDateIntervalFormatter) {
//         self.platformValue = platformValue
//     }
//
//     public init(_ platformValue: PlatformDateIntervalFormatter = PlatformDateIntervalFormatter()) {
//         self.platformValue = platformValue
//     }
//
//     var description: String {
//         return platformValue.description
//     }
// }
