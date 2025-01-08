// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class DateFormatter: Formatter {
    internal var platformValue: java.text.DateFormat {
        if _platformValue == nil {
            _platformValue = createDateFormat()
        }
        return _platformValue!
    }
    private var _platformValue: java.text.DateFormat?

    private func createDateFormat() -> java.text.DateFormat {
        let formatter: java.text.DateFormat
        if _dateFormat != nil || _dateFormatTemplate != nil {
            let simpleFormat: java.text.SimpleDateFormat
            if let dateFormat = _dateFormat {
                if let locale = _locale {
                    simpleFormat = java.text.SimpleDateFormat(dateFormat, locale.platformValue)
                } else {
                    simpleFormat = java.text.SimpleDateFormat(dateFormat)
                }
            } else {
                if let locale = _locale {
                    // Provide some pattern that we'll override when we apply our template, because it's the only way to also pass a locale
                    simpleFormat = java.text.SimpleDateFormat("yyyy.MM.dd", locale.platformValue)
                } else {
                    simpleFormat = java.text.SimpleDateFormat()
                }
            }
            if let dateFormatTemplate = _dateFormatTemplate {
                simpleFormat.applyLocalizedPattern(dateFormatTemplate)
            }
            formatter = simpleFormat
        } else {
            let dstyle = platformStyle(for: dateStyle)
            let tstyle = platformStyle(for: timeStyle)
            if dateStyle != .none && timeStyle != .none {
                if let locale = _locale {
                    formatter = java.text.DateFormat.getDateTimeInstance(dstyle, tstyle, locale.platformValue)
                } else {
                    formatter = java.text.DateFormat.getDateTimeInstance(dstyle, tstyle)
                }
            } else if dateStyle != .none {
                if let locale = _locale {
                    formatter = java.text.DateFormat.getDateInstance(dstyle, locale.platformValue)
                } else {
                    formatter = java.text.DateFormat.getDateInstance(dstyle)
                }
            } else if timeStyle != .none {
                if let locale = _locale {
                    formatter = java.text.DateFormat.getTimeInstance(tstyle, locale.platformValue)
                } else {
                    formatter = java.text.DateFormat.getTimeInstance(tstyle)
                }
            } else {
                // There is no way to create a platform format with the equivalent of .none
                if let locale = _locale {
                    formatter = java.text.DateFormat.getDateTimeInstance(dstyle, tstyle, locale.platformValue)
                } else {
                    formatter = java.text.DateFormat.getDateTimeInstance(dstyle, tstyle)
                }
            }
        }

        formatter.isLenient = isLenient
        if let timeZone = _timeZone {
            formatter.timeZone = timeZone.platformValue
        }
        if let calendar = _calendar {
            formatter.calendar = calendar.platformValue
        }
        return formatter
    }

    private func platformStyle(for style: DateFormatter.Style) -> Int {
        switch style {
        case .none:
            return java.text.DateFormat.DEFAULT
        case .short:
            return java.text.DateFormat.SHORT
        case .medium:
            return java.text.DateFormat.MEDIUM
        case .long:
            return java.text.DateFormat.LONG
        case .full:
            return java.text.DateFormat.FULL
        }
    }

    @available(*, unavailable)
    override public var formattingContext: Formatter.Context = .unknown

    internal init(platformValue: java.text.DateFormat) {
        _platformValue = platformValue
        isLenient = platformValue.isLenient
        _dateFormat = (platformValue as? java.text.SimpleDateFormat)?.toPattern() ?? ""
        _timeZone = TimeZone(platformValue: platformValue.timeZone)
        _calendar = Calendar(platformValue: platformValue.calendar)
    }

    public init() {
    }

    public var description: String {
        return platformValue.toString()
    }

    public enum Style : UInt {
        case none, short, medium, long, full
    }

    public var dateStyle: DateFormatter.Style = .none {
        didSet {
            _platformValue = nil // No way to set without creating a new instance
        }
    }

    public var timeStyle: DateFormatter.Style = .none {
        didSet {
            _platformValue = nil // No way to set without creating a new instance
        }
    }

    public enum Behavior : Int {
        case `default` = 0
        case behavior10_0 = 1000
        case behavior10_4 = 1040
    }

    @available(*, unavailable)
    public static var defaultFormatterBehavior = Behavior.default

    public var isLenient = false {
        didSet {
            _platformValue?.isLenient = isLenient
        }
    }

    public var dateFormat: String {
        get {
            // Return whatever platform formatter is actually using
            return (platformValue as? java.text.SimpleDateFormat)?.toPattern() ?? ""
        }
        set {
            _dateFormat = newValue
            _dateFormatTemplate = nil
            if let simpleFormat = _platformValue as? java.text.SimpleDateFormat {
                simpleFormat.applyPattern(newValue)
            } else {
                _platformValue = nil
            }
        }
    }
    private var _dateFormat: String?

    public func setLocalizedDateFormatFromTemplate(dateFormatTemplate: String) {
        _dateFormatTemplate = dateFormatTemplate
        _dateFormat = nil
        if let simpleFormat = _platformValue as? java.text.SimpleDateFormat {
            simpleFormat.applyLocalizedPattern(dateFormatTemplate)
        } else {
            _platformValue = nil
        }
    }
    private var _dateFormatTemplate: String?

    public static func dateFormat(fromTemplate: String, options: Int, locale: Locale?) -> String? {
        let fmt = DateFormatter()
        fmt.locale = locale
        fmt.setLocalizedDateFormatFromTemplate(fromTemplate)
        return (fmt.platformValue as? java.text.SimpleDateFormat)?.toLocalizedPattern()
    }

    public static func localizedString(from date: Date, dateStyle dstyle: DateFormatter.Style, timeStyle tstyle: DateFormatter.Style) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = dateStyle
        fmt.timeStyle = timeStyle
        return fmt.string(from: date)
    }

    public var timeZone: TimeZone? {
        get {
            // Return whatever platform formatter is actually using
            return TimeZone(platformValue: platformValue.timeZone)
        }
        set {
            _timeZone = newValue
            if let _timeZone, let _platformValue {
                _platformValue.timeZone = _timeZone.platformValue
            }
        }
    }
    private var _timeZone: TimeZone?

    public var locale: Locale? {
        get {
            return _locale ?? Locale.current
        }
        set {
            _locale = newValue
            _platformValue = nil // No way to set without creating a new instance
        }
    }
    private var _locale: Locale?

    public var calendar: Calendar? {
        get {
            // Return whatever platform formatter is actually using
            return Calendar(platformValue: platformValue.calendar)
        }
        set {
            _calendar = newValue
            if let _calendar, let _platformValue {
                _platformValue.calendar = _calendar.platformValue
            }
        }
    }
    private var _calendar: Calendar?

    @available(*, unavailable)
    public var generatesCalendarDates = false

    @available(*, unavailable)
    public var formatterBehavior = Behavior.default

    @available(*, unavailable)
    public var twoDigitStartDate: Date?

    @available(*, unavailable)
    public var defaultDate: Date?

    @available(*, unavailable)
    public var eraSymbols: [String] = []

    @available(*, unavailable)
    public var monthSymbols: [String] = []

    @available(*, unavailable)
    public var shortMonthSymbols: [String] = []

    @available(*, unavailable)
    public var weekdaySymbols: [String] = []

    @available(*, unavailable)
    public var shortWeekdaySymbols: [String] = []

    @available(*, unavailable)
    public var amSymbol: String = ""

    @available(*, unavailable)
    public var pmSymbol = ""

    @available(*, unavailable)
    public var longEraSymbols: [String] = []

    @available(*, unavailable)
    public var veryShortMonthSymbols: [String] = []

    @available(*, unavailable)
    public var standaloneMonthSymbols: [String] = []

    @available(*, unavailable)
    public var shortStandaloneMonthSymbols: [String] = []

    @available(*, unavailable)
    public var veryShortStandaloneMonthSymbols: [String] = []

    @available(*, unavailable)
    public var veryShortWeekdaySymbols: [String] = []

    @available(*, unavailable)
    public var standaloneWeekdaySymbols: [String] = []

    @available(*, unavailable)
    public var shortStandaloneWeekdaySymbols: [String] = []

    @available(*, unavailable)
    public var veryShortStandaloneWeekdaySymbols: [String] = []

    @available(*, unavailable)
    public var quarterSymbols: [String] = []

    @available(*, unavailable)
    public var shortQuarterSymbols: [String] = []

    @available(*, unavailable)
    public var standaloneQuarterSymbols: [String] = []

    @available(*, unavailable)
    public var shortStandaloneQuarterSymbols: [String] = []

    @available(*, unavailable)
    public var gregorianStartDate: Date?

    @available(*, unavailable)
    public var doesRelativeDateFormatting = false

    public func date(from string: String) -> Date? {
        if let date = try? platformValue.parse(string) { // DateFormat throws java.text.ParseException: Unparseable date: "2018-03-09"
            return Date(platformValue: date)
        } else {
            return nil
        }
    }

    public func string(from date: Date) -> String {
        return platformValue.format(date.platformValue)
    }

    public override func string(for obj: Any?) -> String? {
        guard let date = obj as? Date else {
            return nil
        }
        return string(from: date)
    }
}

#endif
