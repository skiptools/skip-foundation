// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitDuration : Dimension {
    public static let hours = UnitDuration(symbol: "hr", converter: UnitConverterLinear(coefficient: 3600.0))
    public static let minutes = UnitDuration(symbol: "min", converter: UnitConverterLinear(coefficient: 60.0))
    public static let seconds = UnitDuration(symbol: "s", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milliseconds = UnitDuration(symbol: "ms", converter: UnitConverterLinear(coefficient: 0.001))
    public static let microseconds = UnitDuration(symbol: "µs", converter: UnitConverterLinear(coefficient: 0.000001))
    public static let nanoseconds = UnitDuration(symbol: "ns", converter: UnitConverterLinear(coefficient: 1e-9))
    public static let picoseconds = UnitDuration(symbol: "ps", converter: UnitConverterLinear(coefficient: 1e-12))

    public override class func baseUnit() -> Dimension { seconds }
}

#endif
