// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitPower : Dimension {
    public static let terawatts = UnitPower(symbol: "TW", converter: UnitConverterLinear(coefficient: 1e12))
    public static let gigawatts = UnitPower(symbol: "GW", converter: UnitConverterLinear(coefficient: 1e9))
    public static let megawatts = UnitPower(symbol: "MW", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kilowatts = UnitPower(symbol: "kW", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let watts = UnitPower(symbol: "W", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milliwatts = UnitPower(symbol: "mW", converter: UnitConverterLinear(coefficient: 0.001))
    public static let microwatts = UnitPower(symbol: "µW", converter: UnitConverterLinear(coefficient: 0.000001))
    public static let nanowatts = UnitPower(symbol: "nW", converter: UnitConverterLinear(coefficient: 1e-9))
    public static let picowatts = UnitPower(symbol: "pW", converter: UnitConverterLinear(coefficient: 1e-12))
    public static let femtowatts = UnitPower(symbol: "fW", converter: UnitConverterLinear(coefficient: 1e-15))
    public static let horsepower = UnitPower(symbol: "hp", converter: UnitConverterLinear(coefficient: 745.7))

    public override class func baseUnit() -> Dimension { watts }
}

#endif
