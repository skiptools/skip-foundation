// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class NumberFormatter: Formatter {
    //typealias PlatformFormatter = java.text.DecimalFormat
    //typealias PlatformFormatterSymbols = java.text.DecimalFormatSymbols
    //typealias PlatformCurrency = java.util.Currency
    typealias PlatformFormatter = android.icu.text.DecimalFormat
    typealias PlatformFormatterSymbols = android.icu.text.DecimalFormatSymbols
    typealias PlatformCurrency = android.icu.util.Currency

    internal var platformValue: PlatformFormatter

    internal init(platformValue: PlatformFormatter) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = PlatformFormatter.getIntegerInstance() as PlatformFormatter
        self.groupingSize = 0
    }

    private init(style: Style) {
        self.init()
        self.numberStyle = style
    }

    @available(*, unavailable)
    override public var formattingContext: Formatter.Context = .unknown

    private var _numberStyle: NumberFormatter.Style = .none

    public var description: String {
        return platformValue.description
    }

    public var numberStyle: NumberFormatter.Style {
        get {
            return _numberStyle
        }

        set {
            var fmt: PlatformFormatter = self.platformValue
            switch newValue {
            case .none:
                if let loc = _locale?.platformValue {
                    fmt = PlatformFormatter.getIntegerInstance(loc) as PlatformFormatter
                } else {
                    fmt = PlatformFormatter.getIntegerInstance() as PlatformFormatter
                }
            case .decimal:
                if let loc = _locale?.platformValue {
                    fmt = PlatformFormatter.getNumberInstance(loc) as PlatformFormatter
                } else {
                    fmt = PlatformFormatter.getNumberInstance() as PlatformFormatter
                }
            case .currency:
                if let loc = _locale?.platformValue {
                    fmt = PlatformFormatter.getCurrencyInstance(loc) as PlatformFormatter
                } else {
                    fmt = PlatformFormatter.getCurrencyInstance() as PlatformFormatter
                }
            case .percent:
                if let loc = _locale?.platformValue {
                    fmt = PlatformFormatter.getPercentInstance(loc) as PlatformFormatter
                } else {
                    fmt = PlatformFormatter.getPercentInstance() as PlatformFormatter
                }
            case .scientific:
                if let loc = _locale?.platformValue {
                    fmt = PlatformFormatter.getScientificInstance(loc) as PlatformFormatter
                } else {
                    fmt = PlatformFormatter.getScientificInstance() as PlatformFormatter
                }
            default:
                fatalError("SkipNumberFormatter: unsupported style \(newValue)")
            }

            let symbols = self.platformValue.decimalFormatSymbols
            if let loc = _locale?.platformValue {
                self.platformValue.applyLocalizedPattern(fmt.toLocalizedPattern())
                symbols.currency = PlatformCurrency.getInstance(loc)
                //symbols.currencySymbol = symbols.currency.getSymbol(loc) // also needed or else the sumbol is not applied
            } else {
                self.platformValue.applyPattern(fmt.toPattern())
            }
            self.platformValue.decimalFormatSymbols = symbols
        }
    }

    private var _locale: Locale? = Locale.current

    public var locale: Locale? {
        get {
            return _locale
        }

        set {
            self._locale = newValue
            if let loc = newValue {
                applySymbol { $0.currency = PlatformCurrency.getInstance(loc.platformValue) }
            }
        }
    }

    #if os(macOS) || os(Linux) // seems to be unavailable on iOS
    public var format: String {
        get {
            return platformValue.toPattern()
        }

        set {
            platformValue.applyPattern(newValue)
        }
    }
    #endif

    public var groupingSize: Int {
        get {
            return platformValue.getGroupingSize()
        }

        set {
            platformValue.setGroupingSize(newValue)
        }
    }

    public var generatesDecimalNumbers: Bool {
        get {
            return platformValue.isParseBigDecimal()
        }

        set {
            platformValue.setParseBigDecimal(newValue)
        }
    }

    public var alwaysShowsDecimalSeparator: Bool {
        get {
            return platformValue.isDecimalSeparatorAlwaysShown()
        }

        set {
            platformValue.setDecimalSeparatorAlwaysShown(newValue)
        }
    }

    public var usesGroupingSeparator: Bool {
        get {
            return platformValue.isGroupingUsed()
        }

        set {
            platformValue.setGroupingUsed(newValue)
        }
    }

    public var multiplier: NSNumber? {
        get {
            return platformValue.multiplier as NSNumber
        }

        set {
            if let value = newValue {
                platformValue.multiplier = value.intValue
            }
        }
    }

    public var groupingSeparator: String? {
        get {
            return platformValue.decimalFormatSymbols.groupingSeparator.toString()
        }

        set {
            if let groupingSeparator = newValue?.first {
                applySymbol { $0.groupingSeparator = groupingSeparator }
            }
        }
    }

    public var percentSymbol: String? {
        get {
            return platformValue.decimalFormatSymbols.percent.toString()
        }

        set {
            if let percentSymbol = newValue?.first {
                applySymbol { $0.percent = percentSymbol }
            }
        }
    }

    public var currencySymbol: String? {
        get {
            return platformValue.decimalFormatSymbols.currencySymbol
        }

        set {
            applySymbol { $0.currencySymbol = newValue }
        }
    }

    public var zeroSymbol: String? {
        get {
            return platformValue.decimalFormatSymbols.zeroDigit?.toString()
        }

        set {
            if let zeroSymbolChar = newValue?.first {
                applySymbol { $0.zeroDigit = zeroSymbolChar }
            }
        }
    }

    @available(*, unavailable)
    public var plusSign: String? // no plusSign in DecimalFormatSymbols

    public var minusSign: String? {
        get {
            return platformValue.decimalFormatSymbols.minusSign?.toString()
        }

        set {
            if let minusSignChar = newValue?.first {
                applySymbol { $0.minusSign = minusSignChar }
            }
        }
    }

    public var exponentSymbol: String? {
        get {
            return platformValue.decimalFormatSymbols.exponentSeparator
        }

        set {
            applySymbol { $0.exponentSeparator = newValue }
        }
    }

    public var negativeInfinitySymbol: String {
        get {
            // Note: PlatformFormatterSymbols has only a single `infinity` compares to `positiveInfinitySymbol` and `negativeInfinitySymbol`
            return platformValue.decimalFormatSymbols.infinity
        }

        set {
            applySymbol { $0.infinity = newValue }
        }
    }

    public var positiveInfinitySymbol: String {
        get {
            // Note: PlatformFormatterSymbols has only a single `infinity` compares to `positiveInfinitySymbol` and `negativeInfinitySymbol`
            return platformValue.decimalFormatSymbols.infinity
        }

        set {
            applySymbol { $0.infinity = newValue }
        }
    }

    public var internationalCurrencySymbol: String? {
        get {
            return platformValue.decimalFormatSymbols.internationalCurrencySymbol
        }

        set {
            applySymbol { $0.internationalCurrencySymbol = newValue }
        }
    }


    public var decimalSeparator: String? {
        get {
            return platformValue.decimalFormatSymbols.decimalSeparator?.toString()
        }

        set {
            if let decimalSeparatorChar = newValue?.first {
                applySymbol { $0.decimalSeparator = decimalSeparatorChar }
            }
        }
    }

    public var currencyCode: String? {
        get {
            return platformValue.decimalFormatSymbols.internationalCurrencySymbol
        }

        set {
            applySymbol { $0.internationalCurrencySymbol = newValue }
        }
    }

    public var currencyDecimalSeparator: String? {
        get {
            return platformValue.decimalFormatSymbols.monetaryDecimalSeparator?.toString()
        }

        set {
            if let currencyDecimalSeparatorChar = newValue?.first {
                applySymbol { $0.monetaryDecimalSeparator = currencyDecimalSeparatorChar }
            }
        }
    }

    public var notANumberSymbol: String? {
        get {
            return platformValue.decimalFormatSymbols.getNaN()
        }

        set {
            applySymbol { $0.setNaN(newValue) }
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
        return platformValue.format(number)
    }

    public func string(from number: Int) -> String? { string(from: number as NSNumber) }
    public func string(from number: Double) -> String? { string(from: number as NSNumber) }

    /// Sets the DecimalFormatSymbols with the given block; needed since `getDecimalFormatSymbols` returns a copy, so it must be re-set manually.
    private func applySymbol(_ block: (PlatformFormatterSymbols) -> ()) {
        let dfs = platformValue.getDecimalFormatSymbols()
        block(dfs)
        platformValue.setDecimalFormatSymbols(dfs)
    }

    public override func string(for object: Any?) -> String? {
        if let number = object as? NSNumber {
            return string(from: number)
        } else if let bool = object as? Bool {
            // this is the expected NSNumber behavior checked in test_stringFor
            return string(from: bool == true ? 1 : 0)
        } else {
            return nil
        }
    }

    public func number(from string: String) -> NSNumber? {
        return platformValue.parse(string) as? NSNumber
    }

    public static func localizedString(from value: NSNumber, number numberStyle: NumberFormatter.Style) -> String {
        switch numberStyle {
        case .none: return PlatformFormatter.getIntegerInstance().format(value)
        case .decimal: return PlatformFormatter.getNumberInstance().format(value)
        case .currency: return PlatformFormatter.getCurrencyInstance().format(value)
        case .percent: return PlatformFormatter.getPercentInstance().format(value)
        case .scientific: return PlatformFormatter.getScientificInstance().format(value)
        //case .spellOut:
        //case .ordinal:
        //case .currencyISOCode:
        //case .currencyPlural:
        //case .currencyAccounting:
        default: return "\(value)"
        }
    }

    public enum Style : Int, @unchecked Sendable {
        case none = 0
        case decimal = 1
        case currency = 2
        case percent = 3
        case scientific = 4
        case spellOut = 5
        case ordinal = 6
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

public struct FormatStyle {
    let formatter: NumberFormatter.PlatformFormatter

    public static let number = FormatStyle(formatter: NumberFormatter.PlatformFormatter.getNumberInstance() as NumberFormatter.PlatformFormatter)
    public static let currency = FormatStyle(formatter: NumberFormatter.PlatformFormatter.getCurrencyInstance() as NumberFormatter.PlatformFormatter)
    public static let percent = FormatStyle(formatter: NumberFormatter.PlatformFormatter.getPercentInstance() as NumberFormatter.PlatformFormatter)
    public static let scientific = FormatStyle(formatter: NumberFormatter.PlatformFormatter.getScientificInstance() as NumberFormatter.PlatformFormatter)
}

public extension Number {
    public func formatted() -> String {
        FormatStyle.number.formatter.format(self)
    }

    public func formatted(_ style: FormatStyle) -> String {
        style.formatter.format(self)
    }
}
#endif
