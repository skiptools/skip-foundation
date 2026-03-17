// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitElectricResistance : Dimension {
    public static let megaohms = UnitElectricResistance(symbol: "MΩ", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kiloohms = UnitElectricResistance(symbol: "kΩ", converter: UnitConverterLinear(coefficient: 1000.0))
    public static let ohms = UnitElectricResistance(symbol: "Ω", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milliohms = UnitElectricResistance(symbol: "mΩ", converter: UnitConverterLinear(coefficient: 0.001))
    public static let microohms = UnitElectricResistance(symbol: "µΩ", converter: UnitConverterLinear(coefficient: 0.000001))

    public override class func baseUnit() -> Dimension { ohms }
}

#endif
