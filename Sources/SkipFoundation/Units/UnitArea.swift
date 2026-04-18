// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitArea : Dimension {
    public static let squareMegameters = UnitArea(symbol: "Mm²", converter: UnitConverterLinear(coefficient: 1e12))
    public static let squareKilometers = UnitArea(symbol: "km²", converter: UnitConverterLinear(coefficient: 1e6))
    public static let squareMeters = UnitArea(symbol: "m²", converter: UnitConverterLinear(coefficient: 1.0))
    public static let squareCentimeters = UnitArea(symbol: "cm²", converter: UnitConverterLinear(coefficient: 0.0001))
    public static let squareMillimeters = UnitArea(symbol: "mm²", converter: UnitConverterLinear(coefficient: 0.000001))
    public static let squareMicrometers = UnitArea(symbol: "µm²", converter: UnitConverterLinear(coefficient: 1e-12))
    public static let squareNanometers = UnitArea(symbol: "nm²", converter: UnitConverterLinear(coefficient: 1e-18))
    public static let squareInches = UnitArea(symbol: "in²", converter: UnitConverterLinear(coefficient: 0.00064516))
    public static let squareFeet = UnitArea(symbol: "ft²", converter: UnitConverterLinear(coefficient: 0.092903))
    public static let squareYards = UnitArea(symbol: "yd²", converter: UnitConverterLinear(coefficient: 0.836127))
    public static let squareMiles = UnitArea(symbol: "mi²", converter: UnitConverterLinear(coefficient: 2.59e6))
    public static let acres = UnitArea(symbol: "ac", converter: UnitConverterLinear(coefficient: 4046.86))
    public static let ares = UnitArea(symbol: "a", converter: UnitConverterLinear(coefficient: 100.0))
    public static let hectares = UnitArea(symbol: "ha", converter: UnitConverterLinear(coefficient: 10000.0))

    public override class func baseUnit() -> Dimension { squareMeters }
}

#endif
