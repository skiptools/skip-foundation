// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitElectricCurrent : Dimension {
    public static let megaamperes = UnitElectricCurrent(symbol: "MA", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kiloamperes = UnitElectricCurrent(symbol: "kA", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let amperes = UnitElectricCurrent(symbol: "A", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milliamperes = UnitElectricCurrent(symbol: "mA", converter: UnitConverterLinear(coefficient: 0.001))
    public static let microamperes = UnitElectricCurrent(symbol: "µA", converter: UnitConverterLinear(coefficient: 0.000001))

    public override class func baseUnit() -> Dimension { amperes }
}

#endif
