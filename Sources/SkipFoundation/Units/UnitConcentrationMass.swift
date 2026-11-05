// Copyright 2026 Skip
#if SKIP

public class UnitConcentrationMass : Dimension {
    public static let gramsPerLiter = UnitConcentrationMass(symbol: "g/L", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milligramsPerDeciliter = UnitConcentrationMass(symbol: "mg/dL", converter: UnitConverterLinear(coefficient: 0.01))

    public static func millimolesPerLiter(withGramsPerMole gramsPerMole: Double) -> UnitConcentrationMass {
        return UnitConcentrationMass(symbol: "mmol/L", converter: UnitConverterLinear(coefficient: gramsPerMole / 1000.0))
    }

    public override class func baseUnit() -> Dimension { gramsPerLiter }
}

#endif
