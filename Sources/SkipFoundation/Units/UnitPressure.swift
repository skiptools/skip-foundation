// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitPressure : Dimension {
    public static let newtonsPerMetersSquared = UnitPressure(symbol: "N/m²", converter: UnitConverterLinear(coefficient: 1.0))
    public static let gigapascals = UnitPressure(symbol: "GPa", converter: UnitConverterLinear(coefficient: 1e9))
    public static let megapascals = UnitPressure(symbol: "MPa", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kilopascals = UnitPressure(symbol: "kPa", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let hectopascals = UnitPressure(symbol: "hPa", converter: UnitConverterLinear(coefficient: 100.0))
    public static let inchesOfMercury = UnitPressure(symbol: "inHg", converter: UnitConverterLinear(coefficient: 3386.39))
    public static let bars = UnitPressure(symbol: "bar", converter: UnitConverterLinear(coefficient: 100000.0))
    public static let millibars = UnitPressure(symbol: "mbar", converter: UnitConverterLinear(coefficient: 100.0))
    public static let millimetersOfMercury = UnitPressure(symbol: "mmHg", converter: UnitConverterLinear(coefficient: 133.322))
    public static let poundsForcePerSquareInch = UnitPressure(symbol: "psi", converter: UnitConverterLinear(coefficient: 6894.76))

    public override class func baseUnit() -> Dimension { newtonsPerMetersSquared }
}

#endif
