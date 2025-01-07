// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

import CoreFoundation

import android.icu.text.RelativeDateTimeFormatter.AbsoluteUnit
import android.icu.text.RelativeDateTimeFormatter.Direction
import android.icu.text.RelativeDateTimeFormatter.RelativeUnit

extension RelativeDateTimeFormatter {
    public enum DateTimeStyle: Int {
        case numeric = 0
        case named = 1
    }

    public enum UnitsStyle: Int {
        case full = 0
        @available(*, unavailable)
        case spellOut = 1
        case short = 2
        @available(*, unavailable)
        case abbreviated = 3
    }
}

public class RelativeDateTimeFormatter: Formatter {
    internal var platformValue: android.icu.text.RelativeDateTimeFormatter!

    public var dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle = .numeric

    public var unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full {
        didSet {
            updatePlatformValue()
        }
    }

    @available(*, unavailable)
    public var calendar: Calendar!

    public var locale: Locale! {
        didSet {
            updatePlatformValue()
        }
    }

    public init () {
        locale = .current
    }

    private func updatePlatformValue() {
        let ulocale = locale != nil ? android.icu.util.ULocale.forLocale(locale!.platformValue) : android.icu.util.ULocale.getDefault()
        platformValue = android.icu.text.RelativeDateTimeFormatter.getInstance(ulocale, nil, relativeDateTimeFormatterStyle, android.icu.text.DisplayContext.CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE)
    }

    public func localizedString(from dateComponents: DateComponents) -> String {
        var relativeUnit: RelativeUnit?
        var absoluteUnit: AbsoluteUnit?
        // Find the set date component, prioritizing non-zero
        var value = 0
        if let year = dateComponents.year {
            value = year
            if abs(value) == 1 && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.YEAR
            } else {
                relativeUnit = RelativeUnit.YEARS
            }
        }
        if value == 0, let month = dateComponents.month {
            value = month
            if abs(value) == 1 && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.MONTH
            } else {
                relativeUnit = RelativeUnit.MONTHS
            }
        }
        if value == 0, let week = dateComponents.weekOfMonth {
            value = week
            if abs(value) == 1 && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.WEEK
            } else {
                relativeUnit = RelativeUnit.WEEKS
            }
        }
        if value == 0, let day = dateComponents.day {
            value = day
            if (value == 0 || abs(value) == 1) && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.DAY
            } else {
                relativeUnit = RelativeUnit.DAYS
            }
        }
        if value == 0, let hour = dateComponents.hour {
            value = hour
            relativeUnit = RelativeUnit.HOURS
        }
        if value == 0, let minute = dateComponents.minute {
            value = minute
            relativeUnit = RelativeUnit.MINUTES
        }
        if value == 0, let second = dateComponents.second {
            value = second
            if value == 0 && dateTimeStyle == .named {
                return platformValue.format(Direction.PLAIN, AbsoluteUnit.NOW)
            }
            relativeUnit = RelativeUnit.SECONDS
        }
        let direction = value == -0 || value <= 0 ? Direction.LAST : Direction.NEXT
        if let absoluteUnit {
            return platformValue.format(value == 0 ? Direction.THIS : direction, absoluteUnit)
        }
        if value == 0 && relativeUnit == nil {
            return ""
        }
        let timeValue = Double(abs(value))
        return platformValue.format(timeValue, direction, relativeUnit!)
    }

    public func localizedString(fromTimeInterval timeInterval: TimeInterval) -> String {
        let isNegative = timeInterval < 0.0
        let direction = isNegative ? Direction.LAST : Direction.NEXT
        var relativeUnit: RelativeUnit?
        var absoluteUnit: AbsoluteUnit?
        var timeValue = abs(timeInterval)
        if timeValue < 60.0 {
            relativeUnit = RelativeUnit.SECONDS
            if timeValue < 1.0 && dateTimeStyle == .named {
                return platformValue.format(Direction.PLAIN, AbsoluteUnit.NOW)
            }
        } else if timeValue < 60.0 * 60.0 {
            timeValue /= 60.0
            relativeUnit = RelativeUnit.MINUTES
        } else if timeValue < 60.0 * 60.0 * 24.0 {
            timeValue /= 60.0 * 60.0
            relativeUnit = RelativeUnit.HOURS
        } else if timeValue < 60.0 * 60.0 * 24.0 * 7.0 {
            timeValue /= 60.0 * 60.0 * 24.0
            if timeValue < 2.0 && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.DAY
            } else {
                relativeUnit = RelativeUnit.DAYS
            }
        } else if timeValue < 60.0 * 60.0 * 24.0 * 31.0 {
            timeValue /= 60.0 * 60.0 * 24.0 * 7
            if timeValue < 2.0 && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.WEEK
            } else {
                relativeUnit = RelativeUnit.WEEKS
            }
        } else if timeValue < 60.0 * 60.0 * 24.0 * (isNegative ? 366.0 : 365.0) {
            timeValue /= 60.0 * 60.0 * 24.0 * 30.4375
            if timeValue < 2.0 && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.MONTH
            } else {
                relativeUnit = RelativeUnit.MONTHS
            }
        } else {
            timeValue /= 60.0 * 60.0 * 24.0 * 365.25
            if timeValue < 2.0 && dateTimeStyle == .named {
                absoluteUnit = AbsoluteUnit.YEAR
            } else {
                relativeUnit = RelativeUnit.YEARS
            }
        }
        if let absoluteUnit {
            return platformValue.format(direction, absoluteUnit)
        }
        timeValue = relativeUnit! != RelativeUnit.SECONDS && timeValue < 1.0 ? 1.0 : timeValue.rounded(.down)
        return platformValue.format(timeValue, direction, relativeUnit!)
    }

    public func localizedString(for date: Date, relativeTo referenceDate: Date) -> String {
        let timeInterval = date.timeIntervalSince(referenceDate)
        return localizedString(fromTimeInterval: timeInterval)
    }

    override public func string(for obj: Any?) -> String? {
        guard let date = obj as? Date else { return nil }
        return localizedString(for: date, relativeTo: .now)
    }

    private var relativeDateTimeFormatterStyle: android.icu.text.RelativeDateTimeFormatter.Style {
        // NARROW and SHORT both behave like `UnitsStyle.Abbreviated` as of Android 15
        // https://developer.android.com/reference/android/icu/text/RelativeDateTimeFormatter.Style#NARROW
        switch unitsStyle {
//        case .abbreviated:
//            android.icu.text.RelativeDateTimeFormatter.Style.NARROW
        case .short:
            android.icu.text.RelativeDateTimeFormatter.Style.SHORT
        default:
            android.icu.text.RelativeDateTimeFormatter.Style.LONG
        }
    }
}

#endif
