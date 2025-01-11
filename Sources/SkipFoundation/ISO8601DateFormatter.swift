// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeFormatterBuilder
import java.time.format.ResolverStyle
import java.time.temporal.ChronoField
import java.time.temporal.TemporalAccessor

public class ISO8601DateFormatter : DateFormatter {
    public override init() {
        super.init()
        self.formatOptions = .withInternetDateTime
        self.timeZone = TimeZone(identifier: "UTC")
    }

    public var formatOptions: Options = Options(rawValue: UInt(0))

    private func buildDateFormatter(parse: Bool) -> DateTimeFormatter {
        var builder = DateTimeFormatterBuilder()

        let withInternetDateTime = formatOptions.contains(.withInternetDateTime)
        let withDay = formatOptions.contains(.withDay)
        let withMonth = formatOptions.contains(.withMonth)
        let withYear = formatOptions.contains(.withYear)
        let withWeekOfYear = formatOptions.contains(.withWeekOfYear)
        let withDate = withInternetDateTime || formatOptions.contains(.withFullDate)
        let hasDate = withDate || withDay || withMonth || withYear || withWeekOfYear
        if hasDate {
            var hadDateValue = false
            func appendSeparator() {
                let withDash = formatOptions.contains(.withDashSeparatorInDate)
                if hadDateValue && withDash {
                    builder.appendLiteral("-")
                }
                hadDateValue = true
            }
            if withDate || withYear {
                builder.appendValue(ChronoField.YEAR, 4)
                hadDateValue = true
            }
            if withDate || withMonth {
                appendSeparator()
                builder.appendValue(ChronoField.MONTH_OF_YEAR, 2)
            }
            if withWeekOfYear {
                appendSeparator()
                builder.appendLiteral("W")
                builder.appendValue(ChronoField.ALIGNED_WEEK_OF_YEAR)
            }
            // The format for day is inferred based on provided options:
            // If withMonth is specified, dd is used.
            // If withWeekOfYear is specified, ee is used.
            if withDate || withDay {
                appendSeparator()
                if withWeekOfYear {
                    builder.appendValue(ChronoField.DAY_OF_WEEK, 2)
                } else if withDate || withMonth {
                    builder.appendValue(ChronoField.DAY_OF_MONTH, 2)
                } else {
                    builder.appendValue(ChronoField.DAY_OF_YEAR)
                }
            }
        }

        let withTime = formatOptions.contains(.withTime)
        let hasTime = withTime || withInternetDateTime || formatOptions.contains(.withFullTime)
        if hasTime {
            if hasDate {
                if formatOptions.contains(.withSpaceBetweenDateAndTime) {
                    builder.appendLiteral(" ")
                } else {
                    builder.appendLiteral("T")
                }
            }

            let withColon = formatOptions.contains(.withColonSeparatorInTime)
            builder.appendValue(ChronoField.HOUR_OF_DAY, 2)
            if withColon { builder.appendLiteral(":") }
            builder.appendValue(ChronoField.MINUTE_OF_HOUR, 2)
            if withColon { builder.appendLiteral(":") }
            builder.appendValue(ChronoField.SECOND_OF_MINUTE, 2)

            if formatOptions.contains(.withFractionalSeconds) {
                builder.appendFraction(ChronoField.NANO_OF_SECOND, 0, 3, true);
            }
        }

        if withInternetDateTime || formatOptions.contains(.withTimeZone) {
            let withColon = formatOptions.contains(.withColonSeparatorInTimeZone)
            if parse {
                builder.appendPattern("[XXX][XX][X]")
            } else {
                builder.appendOffset(withColon ? "+HH:MM" : "+HHMM", "Z")
            }
        }

        return builder.toFormatter() //.withResolverStyle(ResolverStyle.LENIENT)
    }

    public override func date(from string: String) -> Date? {
        // TODO: return nil for exceptions, like: java.time.format.DateTimeParseException: Text '2016-10-08T00:00:00+0600' could not be parsed, unparsed text found at index 22
        do {
            if let accessor: TemporalAccessor = buildDateFormatter(parse: true).parse(string),
               let date = java.util.Date.from(Instant.from(accessor)) {
                return Date(platformValue: date)
            } else {
                return nil
            }
        } catch {
            // Foundation expects failed date parses to return nil
            //print("failed to parse date: \(string): \(error)")
            return nil
        }
    }

    public override func string(from date: Date) -> String {
        return buildDateFormatter(parse: false).format(date.platformValue.toInstant().atZone(timeZone?.platformValue.toZoneId()))
    }

    public override func string(for obj: Any?) -> String? {
        guard let date = obj as? Date else {
            return nil
        }
        return string(from: date)
    }

    public static func string(from date: Date, timeZone: TimeZone, formatOptions: ISO8601DateFormatter.Options = .withInternetDateTime) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = timeZone
        formatter.formatOptions = formatOptions
        return formatter.string(from: date)
    }

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

#endif
