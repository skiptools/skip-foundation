// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
// #if !SKIP
// import struct Foundation.NotificationCenter
// public typealias PlatformNotificationCenter = Foundation.NotificationCenter
// #else
// public typealias PlatformNotificationCenter = java.util.NotificationCenter
// #endif
//
//
// public struct NotificationCenter : RawRepresentable, Hashable, CustomStringConvertible {
//     public var platformValue: PlatformNotificationCenter
//
//     public init(platformValue: PlatformNotificationCenter) {
//         self.platformValue = platformValue
//     }
//
//     public init(_ platformValue: PlatformNotificationCenter = PlatformNotificationCenter()) {
//         self.platformValue = platformValue
//     }
//
//     var description: String {
//         return platformValue.description
//     }
// }
