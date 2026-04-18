// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitEnergy : Dimension {
    public static let kilojoules = UnitEnergy(symbol: "kJ", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let joules = UnitEnergy(symbol: "J", converter: UnitConverterLinear(coefficient: 1.0))
    public static let kilocalories = UnitEnergy(symbol: "kCal", converter: UnitConverterLinear(coefficient: 4184.0))
    public static let calories = UnitEnergy(symbol: "cal", converter: UnitConverterLinear(coefficient: 4.184))
    public static let kilowattHours = UnitEnergy(symbol: "kWh", converter: UnitConverterLinear(coefficient: 3600000.0))

    public override class func baseUnit() -> Dimension { joules }
}

#endif
