// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
// #if !SKIP
// import struct Foundation.ComparisonResult
// public typealias ComparisonResult = Foundation.ComparisonResult
// public typealias PlatformComparisonResult = Foundation.ComparisonResult
// #else
// public typealias ComparisonResult = SkipComparisonResult
// public typealias PlatformComparisonResult = java.util.ComparisonResult
// #endif
//
//
// public struct SkipComparisonResult : Hashable {
//     public let platformValue: PlatformComparisonResult
//
//     public init(platformValue: PlatformComparisonResult) {
//         self.platformValue = platformValue
//     }
//
//     public init(_ platformValue: PlatformXXX = PlatformComparisonResult()) {
//         self.platformValue = platformValue
//     }
//
//     var description: String {
//         return platformValue.description
//     }
// }
