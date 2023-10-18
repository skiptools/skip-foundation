// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.DateFormatter
internal typealias PlatformDateFormatter = Foundation.DateFormatter
#else
public typealias PlatformDateFormatter = java.text.SimpleDateFormat
#endif

public class DateFormatter {
    internal var platformValue: PlatformDateFormatter

    internal init(platformValue: PlatformDateFormatter) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = PlatformDateFormatter()
        self.isLenient = false // SimpleDateFormat is lenient by default
    }

    public var description: String {
        return platformValue.description
    }

    public var isLenient: Bool {
        get {
            #if !SKIP
            return platformValue.isLenient
            #else
            return platformValue.isLenient
            #endif
        }

        set {
            #if !SKIP
            platformValue.isLenient = newValue
            #else
            platformValue.isLenient = newValue
            #endif
        }
    }

    public var dateFormat: String {
        get {
            #if !SKIP
            return platformValue.dateFormat
            #else
            return platformValue.toPattern()
            #endif
        }

        set {
            #if !SKIP
            platformValue.dateFormat = newValue
            #else
            platformValue.applyPattern(newValue)
            #endif
        }
    }

    public func setLocalizedDateFormatFromTemplate(dateFormatTemplate: String) {
        #if !SKIP
        platformValue.setLocalizedDateFormatFromTemplate(dateFormatTemplate)
        #else
        platformValue.applyLocalizedPattern(dateFormatTemplate)
        #endif
    }

    public static func dateFormat(fromTemplate: String, options: Int, locale: Locale?) -> String? {
        #if !SKIP
        return PlatformDateFormatter.dateFormat(fromTemplate: fromTemplate, options: options, locale: locale?.platformValue)
        #else
        let fmt = DateFormatter()
        fmt.locale = locale
        fmt.setLocalizedDateFormatFromTemplate(fromTemplate)
        return fmt.platformValue.toLocalizedPattern()
        #endif
    }

    public var timeZone: TimeZone? {
        get {
            #if !SKIP
            return platformValue.timeZone.flatMap(TimeZone.init(platformValue:))
            #else
            if let rawTimeZone = platformValue.timeZone {
                return TimeZone(platformValue: rawTimeZone)
            } else {
                return TimeZone.current
            }

            fatalError("unreachable") // “A 'return' expression required in a function with a block body ('{...}'). If you got this error after the compiler update, then it's most likely due to a fix of a bug introduced in 1.3.0 (see KT-28061 for details)”
            #endif
        }

        set {
            #if !SKIP
            platformValue.timeZone = newValue?.platformValue ?? TimeZone.system.platformValue
            #else
            platformValue.timeZone = newValue?.platformValue ?? TimeZone.current.platformValue
            #endif
        }
    }

    #if SKIP
    // SimpleDateFormat holds a locale, but it is not readable
    private var _locale: Locale? = nil
    #endif

    public var locale: Locale? {
        get {
            #if !SKIP
            return platformValue.locale.flatMap(Locale.init(platformValue:))
            #else
            return self._locale ?? Locale.current
            #endif
        }

        set {
            #if !SKIP
            platformValue.locale = newValue?.platformValue
            #else
            // need to make a whole new SimpleDateFormat with the locale, since the instance does not provide access to the locale that was used to initialize it
            if let newValue = newValue {
                var formatter = PlatformDateFormatter(self.platformValue.toPattern(), newValue.platformValue)
                formatter.timeZone = self.timeZone?.platformValue
                self.platformValue = formatter
                self._locale = newValue
            }
            #endif
        }
    }

    public var calendar: Calendar? {
        get {
            #if !SKIP
            return platformValue.calendar.flatMap(Calendar.init(platformValue:))
            #else
            return Calendar(platformValue: platformValue.calendar)
            #endif
        }

        set {
            #if !SKIP
            platformValue.calendar = newValue?.platformValue
            #else
            platformValue.calendar = newValue?.platformValue
            #endif
        }
    }

    public func date(from string: String) -> Date? {
        #if !SKIP
        return platformValue.date(from: string).flatMap(Date.init(platformValue:))
        #else
        if let date = try? platformValue.parse(string) { // DateFormat throws java.text.ParseException: Unparseable date: "2018-03-09"
            return Date(platformValue: date)
        } else {
            return nil
        }
        #endif
    }

    public func string(from date: Date) -> String {
        #if !SKIP
        return platformValue.string(from: date.platformValue)
        #else
        return platformValue.format(date.platformValue)
        #endif
    }
}
