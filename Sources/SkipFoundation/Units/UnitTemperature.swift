// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitTemperature : Dimension {
    public static let kelvin = UnitTemperature(symbol: "K", converter: UnitConverterLinear(coefficient: 1.0, constant: 0.0))
    public static let celsius = UnitTemperature(symbol: "°C", converter: UnitConverterLinear(coefficient: 1.0, constant: 273.15))
    public static let fahrenheit = UnitTemperature(symbol: "°F", converter: UnitConverterLinear(coefficient: 5.0 / 9.0, constant: 255.37222222222428))

    public override class func baseUnit() -> Dimension { kelvin }
}

#endif
