// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitFrequency : Dimension {
    public static let terahertz = UnitFrequency(symbol: "THz", converter: UnitConverterLinear(coefficient: 1e12))
    public static let gigahertz = UnitFrequency(symbol: "GHz", converter: UnitConverterLinear(coefficient: 1e9))
    public static let megahertz = UnitFrequency(symbol: "MHz", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kilohertz = UnitFrequency(symbol: "kHz", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let hertz = UnitFrequency(symbol: "Hz", converter: UnitConverterLinear(coefficient: 1.0))
    public static let millihertz = UnitFrequency(symbol: "mHz", converter: UnitConverterLinear(coefficient: 0.001))
    public static let microhertz = UnitFrequency(symbol: "µHz", converter: UnitConverterLinear(coefficient: 0.000001))
    public static let nanohertz = UnitFrequency(symbol: "nHz", converter: UnitConverterLinear(coefficient: 1e-9))
    public static let framesPerSecond = UnitFrequency(symbol: "fps", converter: UnitConverterLinear(coefficient: 1.0))

    public override class func baseUnit() -> Dimension { hertz }
}

#endif
