// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class DateFormatter {
    internal var platformValue: java.text.SimpleDateFormat

    internal init(platformValue: java.text.SimpleDateFormat) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = java.text.SimpleDateFormat()
        self.isLenient = false // SimpleDateFormat is lenient by default
    }

    public var description: String {
        return platformValue.description
    }

    public var isLenient: Bool {
        get {
            return platformValue.isLenient
        }
        set {
            platformValue.isLenient = newValue
        }
    }

    public var dateFormat: String {
        get {
            return platformValue.toPattern()
        }
        set {
            platformValue.applyPattern(newValue)
        }
    }

    public func setLocalizedDateFormatFromTemplate(dateFormatTemplate: String) {
        platformValue.applyLocalizedPattern(dateFormatTemplate)
    }

    public static func dateFormat(fromTemplate: String, options: Int, locale: Locale?) -> String? {
        let fmt = DateFormatter()
        fmt.locale = locale
        fmt.setLocalizedDateFormatFromTemplate(fromTemplate)
        return fmt.platformValue.toLocalizedPattern()
    }

    public var timeZone: TimeZone? {
        get {
            if let rawTimeZone = platformValue.timeZone {
                return TimeZone(platformValue: rawTimeZone)
            } else {
                return TimeZone.current
            }
            fatalError("unreachable") // “A 'return' expression required in a function with a block body ('{...}'). If you got this error after the compiler update, then it's most likely due to a fix of a bug introduced in 1.3.0 (see KT-28061 for details)”
        }
        set {
            platformValue.timeZone = newValue?.platformValue ?? TimeZone.current.platformValue
        }
    }

    // SimpleDateFormat holds a locale, but it is not readable
    private var _locale: Locale? = nil

    public var locale: Locale? {
        get {
            return self._locale ?? Locale.current
        }
        set {
            // need to make a whole new SimpleDateFormat with the locale, since the instance does not provide access to the locale that was used to initialize it
            if let newValue = newValue {
                var formatter = java.text.SimpleDateFormat(self.platformValue.toPattern(), newValue.platformValue)
                formatter.timeZone = self.timeZone?.platformValue
                self.platformValue = formatter
                self._locale = newValue
            }
        }
    }

    public var calendar: Calendar? {
        get {
            return Calendar(platformValue: platformValue.calendar)
        }
        set {
            platformValue.calendar = newValue?.platformValue
        }
    }

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
}

#endif
