// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitElectricCharge : Dimension {
    public static let coulombs = UnitElectricCharge(symbol: "C", converter: UnitConverterLinear(coefficient: 1.0))
    public static let megaampereHours = UnitElectricCharge(symbol: "MAh", converter: UnitConverterLinear(coefficient: 3.6e9))
    public static let kiloampereHours = UnitElectricCharge(symbol: "kAh", converter: UnitConverterLinear(coefficient: 3.6e6))
    public static let ampereHours = UnitElectricCharge(symbol: "Ah", converter: UnitConverterLinear(coefficient: 3600.0))
    public static let milliampereHours = UnitElectricCharge(symbol: "mAh", converter: UnitConverterLinear(coefficient: 3.6))
    public static let microampereHours = UnitElectricCharge(symbol: "µAh", converter: UnitConverterLinear(coefficient: 0.0036))

    public override class func baseUnit() -> Dimension { coulombs }
}

#endif
