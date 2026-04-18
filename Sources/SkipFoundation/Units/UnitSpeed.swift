// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public class UnitSpeed : Dimension {
    public static let metersPerSecond = UnitSpeed(symbol: "m/s", converter: UnitConverterLinear(coefficient: 1.0))
    public static let kilometersPerHour = UnitSpeed(symbol: "km/h", converter: UnitConverterLinear(coefficient: 0.277778))
    public static let milesPerHour = UnitSpeed(symbol: "mph", converter: UnitConverterLinear(coefficient: 0.44704))
    public static let knots = UnitSpeed(symbol: "kn", converter: UnitConverterLinear(coefficient: 0.514444))

    public override class func baseUnit() -> Dimension { metersPerSecond }
}

#endif
