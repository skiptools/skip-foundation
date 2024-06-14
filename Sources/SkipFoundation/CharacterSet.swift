// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

// SKIP DECLARE: class CharacterSet : SetAlgebra<CharacterSet, Unicode.Scalar>, MutableStruct
public struct CharacterSet : SetAlgebra, Hashable {
    internal var platformValue: Set<UInt32>

    private static func toPlatformValue(_ value: [String]) -> Set<UInt32> {
        var set = LinkedHashSet<UInt32>()
        for str in value {
            for c in str.toCharArray() {
                set.add(UInt32(c.code))
            }
        }
        return Set(collection: set, nocopy: true)
    }

    internal init(platformValue: Set<UInt32>) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = Set<UInt32>()
    }

    @available(*, unavailable)
    public init(charactersIn range: Range<Unicode.Scalar>) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    @available(*, unavailable)
    public init(charactersIn range: ClosedRange<Unicode.Scalar>) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    public init(charactersIn string: String) {
        self.platformValue = Self.toPlatformValue([string])
    }

    @available(*, unavailable)
    public init(bitmapRepresentation data: Data) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    @available(*, unavailable)
    public init?(contentsOfFile file: String) {
        self.platformValue = SkipCrash("SKIP TODO: CharacterSet")
    }

    public var description: String {
        return platformValue.description
    }

    @available(*, unavailable)
    public static var controlCharacters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    // Also see SkipLib.Character.isWhitespace, .whitespacesAndNewlines
    public static let whitespaces: CharacterSet = CharacterSet(platformValue: toPlatformValue([" ", "\t", "\u{2029}", "\u{3000}"]))

    // Also see SkipLib.Character.isWhitespace, SkipLib.Character.isNewline, .whitespaces, .newlines
    public static let whitespacesAndNewlines = CharacterSet(platformValue: toPlatformValue([" ", "\t", "\u{2029}", "\u{3000}", "\n", "\r", "\u{000B}", "\u{000C}", "\u{0085}", "\u{2028}", "\u{2029}"]))

    @available(*, unavailable)
    public static var decimalDigits: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var letters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var lowercaseLetters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var uppercaseLetters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var nonBaseCharacters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var alphanumerics: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var decomposables: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var illegalCharacters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var punctuationCharacters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var capitalizedLetters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var symbols: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    // Also see SkipLib.Character.isNewline, .whitespacesAndNewlines
    public static let newlines: CharacterSet = CharacterSet(platformValue: toPlatformValue(["\n", "\r", "\u{000B}", "\u{000C}", "\u{0085}", "\u{2028}", "\u{2029}"]))

    @available(*, unavailable)
    public static var urlUserAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var urlPasswordAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    public static var urlHostAllowed: CharacterSet {
        return urlPathAllowed
    }

    public static let urlPathAllowed = CharacterSet(platformValue: toPlatformValue(["-", ".", "_", "~", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]))

    public static let urlQueryAllowed = CharacterSet(platformValue: toPlatformValue(["/", "?", "&", "=", "+", "-", ".", "_", "~", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]))

    public static var urlFragmentAllowed: CharacterSet {
        return urlQueryAllowed
    }

    @available(*, unavailable)
    public var bitmapRepresentation: Data {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public var inverted: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public func hasMember(inPlane plane: UInt8) -> Bool {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func insert(charactersIn range: Range<Unicode.Scalar>) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func insert(charactersIn range: ClosedRange<Unicode.Scalar>) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func remove(charactersIn range: Range<Unicode.Scalar>) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func remove(charactersIn range: ClosedRange<Unicode.Scalar>) {
        fatalError("SKIP TODO: CharacterSet")
    }

    public mutating func insert(charactersIn string: String) {
        platformValue.union(Self.toPlatformValue([string]))
    }

    public mutating func remove(charactersIn string: String) {
        platformValue.subtract(Self.toPlatformValue([string]))
    }

    @available(*, unavailable)
    public mutating func invert() {
        fatalError("SKIP TODO: CharacterSet")
    }

    @discardableResult
    public mutating func insert(_ character: Unicode.Scalar) -> (inserted: Bool, memberAfterInsert: Unicode.Scalar) {
        let (inserted, _) = platformValue.insert(character.rawValue)
        return (inserted, character)
    }

    @discardableResult
    public mutating func update(with character: Unicode.Scalar) -> Unicode.Scalar? {
        return platformValue.update(with: character.rawValue) == nil ? nil : character
    }

    @discardableResult
    public mutating func remove(_ character: Unicode.Scalar) -> Unicode.Scalar? {
        return platformValue.remove(character.rawValue) == nil ? nil : character
    }

    public func contains(_ member: Unicode.Scalar) -> Bool {
        return platformValue.contains(member.rawValue)
    }

    public func union(_ other: CharacterSet) -> CharacterSet {
        return CharacterSet(platformValue: self.platformValue.union(other.platformValue))
    }

    public mutating func formUnion(_ other: CharacterSet) {
        platformValue.formUnion(other.platformValue)
    }

    public func intersection(_ other: CharacterSet) -> CharacterSet {
        return CharacterSet(platformValue: self.platformValue.intersection(other.platformValue))
    }

    public mutating func formIntersection(_ other: CharacterSet) {
        platformValue.formIntersection(other.platformValue)
    }

    public func subtracting(_ other: CharacterSet) -> CharacterSet {
        return CharacterSet(platformValue: self.platformValue.subtracting(other.platformValue))
    }

    public mutating func subtract(_ other: CharacterSet) {
        platformValue.subtract(other.platformValue)
    }

    public func symmetricDifference(_ other: CharacterSet) -> CharacterSet {
        return CharacterSet(platformValue: self.platformValue.symmetricDifference(other.platformValue))
    }

    public mutating func formSymmetricDifference(_ other: CharacterSet) {
        platformValue.formSymmetricDifference(other.platformValue)
    }

    public func isSuperset(of other: CharacterSet) -> Bool {
        return platformValue.isSuperset(of: other.platformValue)
    }

    public func isSubset(of other: CharacterSet) -> Bool {
        return platformValue.isSubset(of: other.platformValue)
    }

    public func isDisjoint(with other: CharacterSet) -> Bool {
        return platformValue.isDisjoint(with: other.platformValue)
    }

    public func isStrictSubset(of other: CharacterSet) -> Bool {
        return platformValue.isStrictSuperset(of: other.platformValue)
    }

    public func isStrictSuperset(of other: CharacterSet) -> Bool {
        return platformValue.isStrictSuperset(of: other.platformValue)
    }

    public var isEmpty: Bool {
        return platformValue.isEmpty
    }
}

#endif
