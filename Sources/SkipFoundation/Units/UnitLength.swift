// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitLength : Dimension {
    public static let megameters = UnitLength(symbol: "Mm", converter: UnitConverterLinear(coefficient: 1000000.0))
    public static let kilometers = UnitLength(symbol: "km", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let hectometers = UnitLength(symbol: "hm", converter: UnitConverterLinear(coefficient: 100.0))
    public static let decameters = UnitLength(symbol: "dam", converter: UnitConverterLinear(coefficient: 10.0))
    public static let meters = UnitLength(symbol: "m", converter: UnitConverterLinear(coefficient: 1.0))
    public static let decimeters = UnitLength(symbol: "dm", converter: UnitConverterLinear(coefficient: 0.1))
    public static let centimeters = UnitLength(symbol: "cm", converter: UnitConverterLinear(coefficient: 0.01))
    public static let millimeters = UnitLength(symbol: "mm", converter: UnitConverterLinear(coefficient: 0.001))
    public static let micrometers = UnitLength(symbol: "µm", converter: UnitConverterLinear(coefficient: 0.000001))
    public static let nanometers = UnitLength(symbol: "nm", converter: UnitConverterLinear(coefficient: 1e-9))
    public static let picometers = UnitLength(symbol: "pm", converter: UnitConverterLinear(coefficient: 1e-12))
    public static let inches = UnitLength(symbol: "in", converter: UnitConverterLinear(coefficient: 0.0254))
    public static let feet = UnitLength(symbol: "ft", converter: UnitConverterLinear(coefficient: 0.3048))
    public static let yards = UnitLength(symbol: "yd", converter: UnitConverterLinear(coefficient: 0.9144))
    public static let miles = UnitLength(symbol: "mi", converter: UnitConverterLinear(coefficient: 1609.344))
    public static let scandinavianMiles = UnitLength(symbol: "smi", converter: UnitConverterLinear(coefficient: 10000.0))
    public static let lightyears = UnitLength(symbol: "ly", converter: UnitConverterLinear(coefficient: 9.4607304725808e15))
    public static let nauticalMiles = UnitLength(symbol: "NM", converter: UnitConverterLinear(coefficient: 1852.0))
    public static let fathoms = UnitLength(symbol: "ftm", converter: UnitConverterLinear(coefficient: 1.8288))
    public static let furlongs = UnitLength(symbol: "fur", converter: UnitConverterLinear(coefficient: 201.168))
    public static let astronomicalUnits = UnitLength(symbol: "ua", converter: UnitConverterLinear(coefficient: 1.495978707e11))
    public static let parsecs = UnitLength(symbol: "pc", converter: UnitConverterLinear(coefficient: 3.0856775814913673e16))

    public override class func baseUnit() -> Dimension { meters }
}

#endif
