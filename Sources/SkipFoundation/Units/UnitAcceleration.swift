// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitAcceleration : Dimension {
    public static let metersPerSecondSquared = UnitAcceleration(symbol: "m/s²", converter: UnitConverterLinear(coefficient: 1.0))
    public static let gravity = UnitAcceleration(symbol: "g", converter: UnitConverterLinear(coefficient: 9.81))

    public override class func baseUnit() -> Dimension { metersPerSecondSquared }
}

#endif
