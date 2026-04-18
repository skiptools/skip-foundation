// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitMass : Dimension {
    public static let kilograms = UnitMass(symbol: "kg", converter: UnitConverterLinear(coefficient: 1.0))
    public static let grams = UnitMass(symbol: "g", converter: UnitConverterLinear(coefficient: 0.001))
    public static let decigrams = UnitMass(symbol: "dg", converter: UnitConverterLinear(coefficient: 0.0001))
    public static let centigrams = UnitMass(symbol: "cg", converter: UnitConverterLinear(coefficient: 0.00001))
    public static let milligrams = UnitMass(symbol: "mg", converter: UnitConverterLinear(coefficient: 0.000001))
    public static let micrograms = UnitMass(symbol: "µg", converter: UnitConverterLinear(coefficient: 1e-9))
    public static let nanograms = UnitMass(symbol: "ng", converter: UnitConverterLinear(coefficient: 1e-12))
    public static let picograms = UnitMass(symbol: "pg", converter: UnitConverterLinear(coefficient: 1e-15))
    public static let ounces = UnitMass(symbol: "oz", converter: UnitConverterLinear(coefficient: 0.0283495))
    public static let pounds = UnitMass(symbol: "lb", converter: UnitConverterLinear(coefficient: 0.453592))
    public static let stones = UnitMass(symbol: "st", converter: UnitConverterLinear(coefficient: 6.35029))
    public static let metricTons = UnitMass(symbol: "t", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let shortTons = UnitMass(symbol: "ton", converter: UnitConverterLinear(coefficient: 907.185))
    public static let carats = UnitMass(symbol: "ct", converter: UnitConverterLinear(coefficient: 0.0002))
    public static let ouncesTroy = UnitMass(symbol: "oz t", converter: UnitConverterLinear(coefficient: 0.0311035))
    public static let slugs = UnitMass(symbol: "slug", converter: UnitConverterLinear(coefficient: 14.5939))

    public override class func baseUnit() -> Dimension { kilograms }
}

#endif
