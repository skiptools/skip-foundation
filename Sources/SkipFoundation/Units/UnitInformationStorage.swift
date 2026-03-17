// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class UnitInformationStorage : Dimension {
    // Base unit
    public static let bytes = UnitInformationStorage(symbol: "B", converter: UnitConverterLinear(coefficient: 1.0))

    // Sub-byte
    public static let bits = UnitInformationStorage(symbol: "bit", converter: UnitConverterLinear(coefficient: 0.125))
    public static let nibbles = UnitInformationStorage(symbol: "nibble", converter: UnitConverterLinear(coefficient: 0.5))

    // Decimal bytes
    public static let yottabytes = UnitInformationStorage(symbol: "YB", converter: UnitConverterLinear(coefficient: 1e24))
    public static let zettabytes = UnitInformationStorage(symbol: "ZB", converter: UnitConverterLinear(coefficient: 1e21))
    public static let exabytes = UnitInformationStorage(symbol: "EB", converter: UnitConverterLinear(coefficient: 1e18))
    public static let petabytes = UnitInformationStorage(symbol: "PB", converter: UnitConverterLinear(coefficient: 1e15))
    public static let terabytes = UnitInformationStorage(symbol: "TB", converter: UnitConverterLinear(coefficient: 1e12))
    public static let gigabytes = UnitInformationStorage(symbol: "GB", converter: UnitConverterLinear(coefficient: 1e9))
    public static let megabytes = UnitInformationStorage(symbol: "MB", converter: UnitConverterLinear(coefficient: 1e6))
    public static let kilobytes = UnitInformationStorage(symbol: "kB", converter: UnitConverterLinear(coefficient: 1000.0))

    // Decimal bits
    public static let yottabits = UnitInformationStorage(symbol: "Yb", converter: UnitConverterLinear(coefficient: 1.25e23))
    public static let zettabits = UnitInformationStorage(symbol: "Zb", converter: UnitConverterLinear(coefficient: 1.25e20))
    public static let exabits = UnitInformationStorage(symbol: "Eb", converter: UnitConverterLinear(coefficient: 1.25e17))
    public static let petabits = UnitInformationStorage(symbol: "Pb", converter: UnitConverterLinear(coefficient: 1.25e14))
    public static let terabits = UnitInformationStorage(symbol: "Tb", converter: UnitConverterLinear(coefficient: 1.25e11))
    public static let gigabits = UnitInformationStorage(symbol: "Gb", converter: UnitConverterLinear(coefficient: 1.25e8))
    public static let megabits = UnitInformationStorage(symbol: "Mb", converter: UnitConverterLinear(coefficient: 125000.0))
    public static let kilobits = UnitInformationStorage(symbol: "kb", converter: UnitConverterLinear(coefficient: 125.0))

    // Binary bytes (1024-based)
    public static let yobibytes = UnitInformationStorage(symbol: "YiB", converter: UnitConverterLinear(coefficient: 1208925819614629174706176.0))
    public static let zebibytes = UnitInformationStorage(symbol: "ZiB", converter: UnitConverterLinear(coefficient: 1180591620717411303424.0))
    public static let exbibytes = UnitInformationStorage(symbol: "EiB", converter: UnitConverterLinear(coefficient: 1152921504606846976.0))
    public static let pebibytes = UnitInformationStorage(symbol: "PiB", converter: UnitConverterLinear(coefficient: 1125899906842624.0))
    public static let tebibytes = UnitInformationStorage(symbol: "TiB", converter: UnitConverterLinear(coefficient: 1099511627776.0))
    public static let gibibytes = UnitInformationStorage(symbol: "GiB", converter: UnitConverterLinear(coefficient: 1073741824.0))
    public static let mebibytes = UnitInformationStorage(symbol: "MiB", converter: UnitConverterLinear(coefficient: 1048576.0))
    public static let kibibytes = UnitInformationStorage(symbol: "KiB", converter: UnitConverterLinear(coefficient: 1024.0))

    // Binary bits (1024-based)
    public static let yobibits = UnitInformationStorage(symbol: "Yib", converter: UnitConverterLinear(coefficient: 151115727451828646838272.0))
    public static let zebibits = UnitInformationStorage(symbol: "Zib", converter: UnitConverterLinear(coefficient: 147573952589676412928.0))
    public static let exbibits = UnitInformationStorage(symbol: "Eib", converter: UnitConverterLinear(coefficient: 144115188075855872.0))
    public static let pebibits = UnitInformationStorage(symbol: "Pib", converter: UnitConverterLinear(coefficient: 140737488355328.0))
    public static let tebibits = UnitInformationStorage(symbol: "Tib", converter: UnitConverterLinear(coefficient: 137438953472.0))
    public static let gibibits = UnitInformationStorage(symbol: "Gib", converter: UnitConverterLinear(coefficient: 134217728.0))
    public static let mebibits = UnitInformationStorage(symbol: "Mib", converter: UnitConverterLinear(coefficient: 131072.0))
    public static let kibibits = UnitInformationStorage(symbol: "Kib", converter: UnitConverterLinear(coefficient: 128.0))

    public override class func baseUnit() -> Dimension { bytes }
}

#endif
