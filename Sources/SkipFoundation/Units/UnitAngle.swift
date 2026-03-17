// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitAngle : Dimension {
    public static let degrees = UnitAngle(symbol: "°", converter: UnitConverterLinear(coefficient: 1.0))
    public static let arcMinutes = UnitAngle(symbol: "ʹ", converter: UnitConverterLinear(coefficient: 1.0 / 60.0))
    public static let arcSeconds = UnitAngle(symbol: "ʺ", converter: UnitConverterLinear(coefficient: 1.0 / 3600.0))
    public static let radians = UnitAngle(symbol: "rad", converter: UnitConverterLinear(coefficient: 180.0 / Double.pi))
    public static let gradians = UnitAngle(symbol: "grad", converter: UnitConverterLinear(coefficient: 0.9))
    public static let revolutions = UnitAngle(symbol: "rev", converter: UnitConverterLinear(coefficient: 360.0))

    public override class func baseUnit() -> Dimension { degrees }
}

#endif
