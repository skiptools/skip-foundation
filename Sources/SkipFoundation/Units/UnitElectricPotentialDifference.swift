// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitElectricPotentialDifference : Dimension {
    public static let megavolts = UnitElectricPotentialDifference(symbol: "MV", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kilovolts = UnitElectricPotentialDifference(symbol: "kV", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let volts = UnitElectricPotentialDifference(symbol: "V", converter: UnitConverterLinear(coefficient: 1.0))
    public static let millivolts = UnitElectricPotentialDifference(symbol: "mV", converter: UnitConverterLinear(coefficient: 0.001))
    public static let microvolts = UnitElectricPotentialDifference(symbol: "µV", converter: UnitConverterLinear(coefficient: 0.000001))

    public override class func baseUnit() -> Dimension { volts }
}

#endif
