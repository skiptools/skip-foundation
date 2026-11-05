// Copyright 2026 Skip
#if SKIP

public class UnitAcceleration : Dimension {
    public static let metersPerSecondSquared = UnitAcceleration(symbol: "m/s²", converter: UnitConverterLinear(coefficient: 1.0))
    public static let gravity = UnitAcceleration(symbol: "g", converter: UnitConverterLinear(coefficient: 9.81))

    public override class func baseUnit() -> Dimension { metersPerSecondSquared }
}

#endif
