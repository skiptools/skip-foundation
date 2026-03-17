// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitDispersion : Dimension {
    public static let partsPerMillion = UnitDispersion(symbol: "ppm", converter: UnitConverterLinear(coefficient: 1.0))

    public override class func baseUnit() -> Dimension { partsPerMillion }
}

#endif
