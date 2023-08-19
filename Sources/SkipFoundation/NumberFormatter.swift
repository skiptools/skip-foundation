// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.NumberFormatter
internal typealias PlatformNumberFormatter = Foundation.NumberFormatter
#else
public typealias PlatformNumberFormatter = java.text.DecimalFormat
#endif

/// A formatter that converts between numeric values and their textual representations.
public class NumberFormatter {
    internal var platformValue: PlatformNumberFormatter

    internal init(platformValue: PlatformNumberFormatter) {
        self.platformValue = platformValue
    }

    public init() {
        #if !SKIP
        self.platformValue = PlatformNumberFormatter()
        #else
        self.platformValue = PlatformNumberFormatter.getIntegerInstance() as PlatformNumberFormatter
        self.groupingSize = 0
        #endif
    }

    #if SKIP
    private var _numberStyle: NumberFormatter.Style = .none
    #endif

    public var description: String {
        return platformValue.description
    }

    public var numberStyle: NumberFormatter.Style {
        get {
            #if !SKIP
            return Style(rawValue: .init(platformValue.numberStyle.rawValue))!
            #else
            return _numberStyle
            #endif
        }

        set {
            #if !SKIP
            platformValue.numberStyle = PlatformNumberFormatter.Style(rawValue: .init(newValue.rawValue))!
            #else
            var fmt: PlatformNumberFormatter = self.platformValue
            switch newValue {
            case .none:
                if let loc = _locale?.platformValue {
                    fmt = PlatformNumberFormatter.getIntegerInstance(loc) as PlatformNumberFormatter
                } else {
                    fmt = PlatformNumberFormatter.getIntegerInstance() as PlatformNumberFormatter
                }
            case .decimal:
                if let loc = _locale?.platformValue {
                    fmt = PlatformNumberFormatter.getNumberInstance(loc) as PlatformNumberFormatter
                } else {
                    fmt = PlatformNumberFormatter.getNumberInstance() as PlatformNumberFormatter
                }
            case .currency:
                if let loc = _locale?.platformValue {
                    fmt = PlatformNumberFormatter.getCurrencyInstance(loc) as PlatformNumberFormatter
                } else {
                    fmt = PlatformNumberFormatter.getCurrencyInstance() as PlatformNumberFormatter
                }
            case .percent:
                if let loc = _locale?.platformValue {
                    fmt = PlatformNumberFormatter.getPercentInstance(loc) as PlatformNumberFormatter
                } else {
                    fmt = PlatformNumberFormatter.getPercentInstance() as PlatformNumberFormatter
                }
            //case .scientific:
            //    fmt = PlatformNumberFormatter.getScientificInstance(loc)
            default:
                fatalError("SkipNumberFormatter: unsupported style \(newValue)")
            }

            let symbols = self.platformValue.decimalFormatSymbols
            if let loc = _locale?.platformValue {
                self.platformValue.applyLocalizedPattern(fmt.toLocalizedPattern())
                symbols.currency = java.util.Currency.getInstance(loc)
                //symbols.currencySymbol = symbols.currency.getSymbol(loc) // also needed or else the sumbol is not applied
            } else {
                self.platformValue.applyPattern(fmt.toPattern())
            }
            self.platformValue.decimalFormatSymbols = symbols
            #endif
        }
    }

    #if SKIP
    private var _locale: Locale? = Locale.current
    #endif

    public var locale: Locale? {
        get {
            #if !SKIP
            return platformValue.locale.flatMap(Locale.init(platformValue:))
            #else
            return _locale
            #endif
        }

        set {
            #if !SKIP
            platformValue.locale = newValue?.platformValue ?? platformValue.locale
            #else
            self._locale = newValue
            if let loc = newValue {
                applySymbol { $0.currency = java.util.Currency.getInstance(loc.platformValue) }
            }
            #endif
        }
    }

    #if os(macOS) || os(Linux) // seems to be unavailable on iOS
    @available(macOS 10.15, macCatalyst 11, *)
    @available(iOS, unavailable, message: "NumberFormatter.format unavailable on iOS")
    @available(watchOS, unavailable, message: "NumberFormatter.format unavailable on watchOS")
    @available(tvOS, unavailable, message: "NumberFormatter.format unavailable on tvOS")
    public var format: String {
        get {
            #if !SKIP
            return platformValue.format
            #else
            return platformValue.toPattern()
            #endif
        }

        set {
            #if !SKIP
            platformValue.format = newValue
            #else
            platformValue.applyPattern(newValue)
            #endif
        }
    }
    #endif

    public var groupingSize: Int {
        get {
            #if !SKIP
            return platformValue.groupingSize
            #else
            return platformValue.getGroupingSize()
            #endif
        }

        set {
            #if !SKIP
            platformValue.groupingSize = newValue
            #else
            platformValue.setGroupingSize(newValue)
            #endif
        }
    }

    public var generatesDecimalNumbers: Bool {
        get {
            #if !SKIP
            return platformValue.generatesDecimalNumbers
            #else
            return platformValue.isParseBigDecimal()
            #endif
        }

        set {
            #if !SKIP
            platformValue.generatesDecimalNumbers = newValue
            #else
            platformValue.setParseBigDecimal(newValue)
            #endif
        }
    }

    public var alwaysShowsDecimalSeparator: Bool {
        get {
            #if !SKIP
            return platformValue.alwaysShowsDecimalSeparator
            #else
            return platformValue.isDecimalSeparatorAlwaysShown()
            #endif
        }

        set {
            #if !SKIP
            platformValue.alwaysShowsDecimalSeparator = newValue
            #else
            platformValue.setDecimalSeparatorAlwaysShown(newValue)
            #endif
        }
    }

    public var usesGroupingSeparator: Bool {
        get {
            #if !SKIP
            return platformValue.usesGroupingSeparator
            #else
            return platformValue.isGroupingUsed()
            #endif
        }

        set {
            #if !SKIP
            platformValue.usesGroupingSeparator = newValue
            #else
            platformValue.setGroupingUsed(newValue)
            #endif
        }
    }

    public var multiplier: NSNumber? {
        get {
            #if !SKIP
            return platformValue.multiplier.flatMap(NSNumber.init(platformValue:))
            #else
            return platformValue.multiplier as NSNumber
            #endif
        }

        set {
            #if !SKIP
            platformValue.multiplier = newValue?.platformValue
            #else
            if let value = newValue {
                platformValue.multiplier = value.intValue
            }
            #endif
        }
    }

    public var groupingSeparator: String? {
        get {
            #if !SKIP
            return platformValue.groupingSeparator
            #else
            return platformValue.decimalFormatSymbols.groupingSeparator.toString()
            #endif
        }

        set {
            #if !SKIP
            platformValue.groupingSeparator = newValue
            #else
            if let groupingSeparator = newValue?.first {
                applySymbol { $0.groupingSeparator = groupingSeparator }
            }
            #endif
        }
    }

    public var percentSymbol: String? {
        get {
            #if !SKIP
            return platformValue.percentSymbol
            #else
            return platformValue.decimalFormatSymbols.percent.toString()
            #endif
        }

        set {
            #if !SKIP
            platformValue.percentSymbol = newValue
            #else
            if let percentSymbol = newValue?.first {
                applySymbol { $0.percent = percentSymbol }
            }
            #endif
        }
    }

    public var currencySymbol: String? {
        get {
            #if !SKIP
            return platformValue.currencySymbol
            #else
            return platformValue.decimalFormatSymbols.currencySymbol
            #endif
        }

        set {
            #if !SKIP
            platformValue.currencySymbol = newValue
            #else
            applySymbol { $0.currencySymbol = newValue }
            #endif
        }
    }

    public var zeroSymbol: String? {
        get {
            #if !SKIP
            return platformValue.zeroSymbol
            #else
            return platformValue.decimalFormatSymbols.zeroDigit?.toString()
            #endif
        }

        set {
            #if !SKIP
            platformValue.zeroSymbol = newValue
            #else
            if let zeroSymbolChar = newValue?.first {
                applySymbol { $0.zeroDigit = zeroSymbolChar }
            }
            #endif
        }
    }

    // no plusSign in DecimalFormatSymbols
    //public var plusSign: String? {
    //    get {
    //        #if !SKIP
    //        return platformValue.plusSign
    //        #else
    //        return platformValue.decimalFormatSymbols.plusSign?.toString()
    //        #endif
    //    }
    //
    //    set {
    //        #if !SKIP
    //        platformValue.plusSign = newValue
    //        #else
    //        if let plusSignChar = newValue?.first {
    //            applySymbol { $0.plusSign = plusSignChar }
    //        }
    //        #endif
    //    }
    //}

    public var minusSign: String? {
        get {
            #if !SKIP
            return platformValue.minusSign
            #else
            return platformValue.decimalFormatSymbols.minusSign?.toString()
            #endif
        }

        set {
            #if !SKIP
            platformValue.minusSign = newValue
            #else
            if let minusSignChar = newValue?.first {
                applySymbol { $0.minusSign = minusSignChar }
            }
            #endif
        }
    }

    public var exponentSymbol: String? {
        get {
            #if !SKIP
            return platformValue.exponentSymbol
            #else
            return platformValue.decimalFormatSymbols.exponentSeparator
            #endif
        }

        set {
            #if !SKIP
            platformValue.exponentSymbol = newValue
            #else
            applySymbol { $0.exponentSeparator = newValue }
            #endif
        }
    }

    public var negativeInfinitySymbol: String {
        get {
            #if !SKIP
            return platformValue.negativeInfinitySymbol
            #else
            // Note: java.text.DecimalFormatSymbols has only a single `infinity` compares to `positiveInfinitySymbol` and `negativeInfinitySymbol`
            return platformValue.decimalFormatSymbols.infinity
            #endif
        }

        set {
            #if !SKIP
            platformValue.negativeInfinitySymbol = newValue
            #else
            applySymbol { $0.infinity = newValue }
            #endif
        }
    }

    public var positiveInfinitySymbol: String {
        get {
            #if !SKIP
            return platformValue.positiveInfinitySymbol
            #else
            // Note: java.text.DecimalFormatSymbols has only a single `infinity` compares to `positiveInfinitySymbol` and `negativeInfinitySymbol`
            return platformValue.decimalFormatSymbols.infinity
            #endif
        }

        set {
            #if !SKIP
            platformValue.positiveInfinitySymbol = newValue
            #else
            applySymbol { $0.infinity = newValue }
            #endif
        }
    }

    public var internationalCurrencySymbol: String? {
        get {
            #if !SKIP
            return platformValue.internationalCurrencySymbol
            #else
            return platformValue.decimalFormatSymbols.internationalCurrencySymbol
            #endif
        }

        set {
            #if !SKIP
            platformValue.internationalCurrencySymbol = newValue
            #else
            applySymbol { $0.internationalCurrencySymbol = newValue }
            #endif
        }
    }


    public var decimalSeparator: String? {
        get {
            #if !SKIP
            return platformValue.decimalSeparator
            #else
            return platformValue.decimalFormatSymbols.decimalSeparator?.toString()
            #endif
        }

        set {
            #if !SKIP
            platformValue.decimalSeparator = newValue
            #else
            if let decimalSeparatorChar = newValue?.first {
                applySymbol { $0.decimalSeparator = decimalSeparatorChar }
            }
            #endif
        }
    }

    public var currencyCode: String? {
        get {
            #if !SKIP
            return platformValue.currencyCode
            #else
            return platformValue.decimalFormatSymbols.internationalCurrencySymbol
            #endif
        }

        set {
            #if !SKIP
            platformValue.currencyCode = newValue
            #else
            applySymbol { $0.internationalCurrencySymbol = newValue }
            #endif
        }
    }

    public var currencyDecimalSeparator: String? {
        get {
            #if !SKIP
            return platformValue.currencyDecimalSeparator
            #else
            return platformValue.decimalFormatSymbols.monetaryDecimalSeparator?.toString()
            #endif
        }

        set {
            #if !SKIP
            platformValue.currencyDecimalSeparator = newValue
            #else
            if let currencyDecimalSeparatorChar = newValue?.first {
                applySymbol { $0.monetaryDecimalSeparator = currencyDecimalSeparatorChar }
            }
            #endif
        }
    }

    public var notANumberSymbol: String? {
        get {
            #if !SKIP
            return platformValue.notANumberSymbol
            #else
            return platformValue.decimalFormatSymbols.getNaN()
            #endif
        }

        set {
            #if !SKIP
            platformValue.notANumberSymbol = newValue
            #else
            applySymbol { $0.setNaN(newValue) }
            #endif
        }
    }

    public var positiveSuffix: String? {
        get { platformValue.positiveSuffix }
        set { platformValue.positiveSuffix = newValue }
    }

    public var negativeSuffix: String? {
        get { platformValue.negativeSuffix }
        set { platformValue.negativeSuffix = newValue }
    }

    public var positivePrefix: String? {
        get { platformValue.positivePrefix }
        set { platformValue.positivePrefix = newValue }
    }

    public var negativePrefix: String? {
        get { platformValue.negativePrefix }
        set { platformValue.negativePrefix = newValue }
    }

    public var maximumFractionDigits: Int {
        get { platformValue.maximumFractionDigits }
        set { platformValue.maximumFractionDigits = newValue }
    }

    public var minimumFractionDigits: Int {
        get { platformValue.minimumFractionDigits }
        set { platformValue.minimumFractionDigits = newValue }
    }

    public var maximumIntegerDigits: Int {
        get { platformValue.maximumIntegerDigits }
        set { platformValue.maximumIntegerDigits = newValue }
    }

    public var minimumIntegerDigits: Int {
        get { platformValue.minimumIntegerDigits }
        set { platformValue.minimumIntegerDigits = newValue }
    }

    public func string(from number: NSNumber) -> String? {
        #if !SKIP
        return platformValue.string(from: number.platformValue)
        #else
        return platformValue.format(number)
        #endif
    }

    #if SKIP
    public func string(from number: Int) -> String? { string(from: number as NSNumber) }
    public func string(from number: Double) -> String? { string(from: number as NSNumber) }

    /// Sets the DecimalFormatSymbols with the given block; needed since `getDecimalFormatSymbols` returns a copy, so it must be re-set manually.
    private func applySymbol(_ block: (java.text.DecimalFormatSymbols) -> ()) {
        let dfs = platformValue.getDecimalFormatSymbols()
        block(dfs)
        platformValue.setDecimalFormatSymbols(dfs)
    }
    #endif

    public func string(for object: Any?) -> String? {
        #if !SKIP
        return platformValue.string(for: object)
        #else
        if let number = object as? NSNumber {
            return string(from: number)
        } else if let bool = object as? Bool {
            // this is the expected NSNumber behavior checked in test_stringFor
            return string(from: bool == true ? 1 : 0)
        } else {
            return nil
        }
        #endif
    }

    public func number(from string: String) -> NSNumber? {
        #if !SKIP
        return platformValue.number(from: string).flatMap(NSNumber.init(platformValue:))
        #else
        return platformValue.parse(string) as? NSNumber
        #endif
    }

    public enum Style : Int, @unchecked Sendable {
        case none = 0
        case decimal = 1
        case currency = 2
        case percent = 3
        case scientific = 4
        case spellOut = 5
        // case ordinal = 6 // FIXME: Kotlin error: 47:9 Conflicting declarations: public final val ordinal: Int, enum entry ordinal
        case currencyISOCode = 8
        case currencyPlural = 9
        case currencyAccounting = 10
    }

    public enum PadPosition : Int, @unchecked Sendable {
        case beforePrefix = 0
        case afterPrefix = 1
        case beforeSuffix = 2
        case afterSuffix = 3
    }

    public enum RoundingMode : Int, @unchecked Sendable {
        case ceiling = 0
        case floor = 1
        case down = 2
        case up = 3
        case halfEven = 4
        case halfDown = 5
        case halfUp = 6
    }
}
