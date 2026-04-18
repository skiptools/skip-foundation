// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitIlluminance : Dimension {
    public static let lux = UnitIlluminance(symbol: "lx", converter: UnitConverterLinear(coefficient: 1.0))

    public override class func baseUnit() -> Dimension { lux }
}

#endif
