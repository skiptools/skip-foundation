// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public struct CharacterSet : Hashable {
    internal var platformValue: Set<Character>

    internal init(platformValue: Set<Character>) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = Set<Character>()
    }

    public var description: String {
        return platformValue.description
    }

    @available(*, unavailable)
    public init(charactersIn range: Range<Unicode.Scalar>) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    @available(*, unavailable)
    public init(charactersIn range: ClosedRange<Unicode.Scalar>) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    @available(*, unavailable)
    public init(charactersIn string: String) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    @available(*, unavailable)
    public init(bitmapRepresentation data: Data) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    @available(*, unavailable)
    public init?(contentsOfFile file: String) {
        self.platformValue = SkipCrash("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var controlCharacters: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    public static var whitespaces: CharacterSet {
        // TODO: Actual values
        return CharacterSet(platformValue: [" ", "\t"])
    }

    public static var whitespacesAndNewlines: CharacterSet {
        // TODO: Actual values
        return CharacterSet(platformValue: [" ", "\t", "\n", "\r"])
    }

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

    public static var newlines: CharacterSet {
        // TODO: Actual values
        return CharacterSet(platformValue: ["\n", "\r"])
    }

    @available(*, unavailable)
    public static var urlUserAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var urlPasswordAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var urlHostAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var urlPathAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var urlQueryAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public static var urlFragmentAllowed: CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
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

    @available(*, unavailable)
    public mutating func insert(charactersIn string: String) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func remove(charactersIn string: String) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func invert() {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    @discardableResult
    public mutating func insert(_ character: Unicode.Scalar) -> (inserted: Bool, memberAfterInsert: Unicode.Scalar) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    @discardableResult
    public mutating func update(with character: Unicode.Scalar) -> Unicode.Scalar? {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    @discardableResult
    public mutating func remove(_ character: Unicode.Scalar) -> Unicode.Scalar? {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public func contains(_ member: Unicode.Scalar) -> Bool {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public func union(_ other: CharacterSet) -> CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func formUnion(_ other: CharacterSet) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public func intersection(_ other: CharacterSet) -> CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func formIntersection(_ other: CharacterSet) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public func subtracting(_ other: CharacterSet) -> CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func subtract(_ other: CharacterSet) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public func symmetricDifference(_ other: CharacterSet) -> CharacterSet {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public mutating func formSymmetricDifference(_ other: CharacterSet) {
        fatalError("SKIP TODO: CharacterSet")
    }

    @available(*, unavailable)
    public func isSuperset(of other: CharacterSet) -> Bool {
        fatalError("SKIP TODO: CharacterSet")
    }
}

#endif
