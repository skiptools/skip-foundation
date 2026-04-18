// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitFuelEfficiency : Dimension {
    public static let litersPer100Kilometers = UnitFuelEfficiency(symbol: "L/100km", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milesPerImperialGallon = UnitFuelEfficiency(symbol: "mpg", converter: UnitConverterReciprocal(reciprocal: 282.481))
    public static let milesPerGallon = UnitFuelEfficiency(symbol: "mpg", converter: UnitConverterReciprocal(reciprocal: 235.215))

    public override class func baseUnit() -> Dimension { litersPer100Kilometers }
}

#endif
