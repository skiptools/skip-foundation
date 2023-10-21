// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

public class ISO8601DateFormatter : DateFormatter {
    public override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        self.timeZone = TimeZone(identifier: "UTC")
    }

    // TODO: handle options
    public var formatOptions: Options = Options(rawValue: UInt(0))

    public struct Options : OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let withYear = ISO8601DateFormatter.Options(rawValue: UInt(1) << 0)
        public static let withMonth = ISO8601DateFormatter.Options(rawValue: UInt(1) << 1)
        public static let withWeekOfYear = ISO8601DateFormatter.Options(rawValue: UInt(1) << 2)
        public static let withDay = ISO8601DateFormatter.Options(rawValue: UInt(1) << 4)
        public static let withTime = ISO8601DateFormatter.Options(rawValue: UInt(1) << 5)
        public static let withTimeZone = ISO8601DateFormatter.Options(rawValue: UInt(1) << 6)
        public static let withSpaceBetweenDateAndTime = ISO8601DateFormatter.Options(rawValue: UInt(1) << 7)
        public static let withDashSeparatorInDate = ISO8601DateFormatter.Options(rawValue: UInt(1) << 8)
        public static let withColonSeparatorInTime = ISO8601DateFormatter.Options(rawValue: UInt(1) << 9)
        public static let withColonSeparatorInTimeZone = ISO8601DateFormatter.Options(rawValue: UInt(1) << 10)
        public static let withFractionalSeconds = ISO8601DateFormatter.Options(rawValue: UInt(1) << 11)
        public static let withFullDate = ISO8601DateFormatter.Options(rawValue: withYear.rawValue + withMonth.rawValue + withDay.rawValue + withDashSeparatorInDate.rawValue)
        public static let withFullTime = ISO8601DateFormatter.Options(rawValue: withTime.rawValue + withTimeZone.rawValue + withColonSeparatorInTime.rawValue + withColonSeparatorInTimeZone.rawValue)
        public static let withInternetDateTime = ISO8601DateFormatter.Options(rawValue: withFullDate.rawValue + withFullTime.rawValue)
    }
}
