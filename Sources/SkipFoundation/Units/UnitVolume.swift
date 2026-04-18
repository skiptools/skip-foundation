// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitVolume : Dimension {
    // Metric
    public static let megaliters = UnitVolume(symbol: "ML", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kiloliters = UnitVolume(symbol: "kL", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let liters = UnitVolume(symbol: "L", converter: UnitConverterLinear(coefficient: 1.0))
    public static let deciliters = UnitVolume(symbol: "dL", converter: UnitConverterLinear(coefficient: 0.1))
    public static let centiliters = UnitVolume(symbol: "cL", converter: UnitConverterLinear(coefficient: 0.01))
    public static let milliliters = UnitVolume(symbol: "mL", converter: UnitConverterLinear(coefficient: 0.001))

    // Cubic metric
    public static let cubicKilometers = UnitVolume(symbol: "km³", converter: UnitConverterLinear(coefficient: 1e12))
    public static let cubicMeters = UnitVolume(symbol: "m³", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let cubicDecimeters = UnitVolume(symbol: "dm³", converter: UnitConverterLinear(coefficient: 1.0))
    public static let cubicCentimeters = UnitVolume(symbol: "cm³", converter: UnitConverterLinear(coefficient: 0.001))
    public static let cubicMillimeters = UnitVolume(symbol: "mm³", converter: UnitConverterLinear(coefficient: 0.000001))

    // Cubic imperial
    public static let cubicInches = UnitVolume(symbol: "in³", converter: UnitConverterLinear(coefficient: 0.0163871))
    public static let cubicFeet = UnitVolume(symbol: "ft³", converter: UnitConverterLinear(coefficient: 28.3168))
    public static let cubicYards = UnitVolume(symbol: "yd³", converter: UnitConverterLinear(coefficient: 764.555))
    public static let cubicMiles = UnitVolume(symbol: "mi³", converter: UnitConverterLinear(coefficient: 4.168e12))

    // US customary
    public static let acreFeet = UnitVolume(symbol: "af", converter: UnitConverterLinear(coefficient: 1.233e6))
    public static let bushels = UnitVolume(symbol: "bsh", converter: UnitConverterLinear(coefficient: 35.2391))
    public static let teaspoons = UnitVolume(symbol: "tsp", converter: UnitConverterLinear(coefficient: 0.00492892))
    public static let tablespoons = UnitVolume(symbol: "tbsp", converter: UnitConverterLinear(coefficient: 0.0147868))
    public static let fluidOunces = UnitVolume(symbol: "fl oz", converter: UnitConverterLinear(coefficient: 0.0295735))
    public static let cups = UnitVolume(symbol: "cup", converter: UnitConverterLinear(coefficient: 0.24))
    public static let pints = UnitVolume(symbol: "pt", converter: UnitConverterLinear(coefficient: 0.473176))
    public static let quarts = UnitVolume(symbol: "qt", converter: UnitConverterLinear(coefficient: 0.946353))
    public static let gallons = UnitVolume(symbol: "gal", converter: UnitConverterLinear(coefficient: 3.78541))

    // Imperial
    public static let imperialTeaspoons = UnitVolume(symbol: "tsp", converter: UnitConverterLinear(coefficient: 0.00591939))
    public static let imperialTablespoons = UnitVolume(symbol: "tbsp", converter: UnitConverterLinear(coefficient: 0.0177582))
    public static let imperialFluidOunces = UnitVolume(symbol: "fl oz", converter: UnitConverterLinear(coefficient: 0.0284131))
    public static let imperialPints = UnitVolume(symbol: "pt", converter: UnitConverterLinear(coefficient: 0.568261))
    public static let imperialQuarts = UnitVolume(symbol: "qt", converter: UnitConverterLinear(coefficient: 1.13652))
    public static let imperialGallons = UnitVolume(symbol: "gal", converter: UnitConverterLinear(coefficient: 4.54609))
    public static let metricCups = UnitVolume(symbol: "metric cup", converter: UnitConverterLinear(coefficient: 0.25))

    public override class func baseUnit() -> Dimension { liters }
}

#endif
