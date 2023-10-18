// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.CharacterSet
internal typealias PlatformCharacterSet = Foundation.CharacterSet
#else
internal typealias PlatformCharacterSet = Set<Character>
#endif

public struct CharacterSet : Hashable {
    internal var platformValue: PlatformCharacterSet

    internal init(platformValue: PlatformCharacterSet) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = PlatformCharacterSet()
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
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.controlCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    public static var whitespaces: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.whitespaces)
        #else
        // TODO: Actual values
        return CharacterSet(platformValue: [" ", "\t"])
        #endif
    }

    public static var whitespacesAndNewlines: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.whitespacesAndNewlines)
        #else
        // TODO: Actual values
        return CharacterSet(platformValue: [" ", "\t", "\n", "\r"])
        #endif
    }

    @available(*, unavailable)
    public static var decimalDigits: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.decimalDigits)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var letters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.letters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    public static var lowercaseLetters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.lowercaseLetters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    public static var uppercaseLetters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.uppercaseLetters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var nonBaseCharacters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.nonBaseCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var alphanumerics: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.alphanumerics)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var decomposables: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.decomposables)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var illegalCharacters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.illegalCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var punctuationCharacters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.punctuationCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var capitalizedLetters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.capitalizedLetters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var symbols: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.symbols)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var newlines: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.newlines)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var urlUserAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlUserAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var urlPasswordAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlPasswordAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var urlHostAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlHostAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var urlPathAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlPathAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var urlQueryAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlQueryAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public static var urlFragmentAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlFragmentAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public var bitmapRepresentation: Data {
        #if !SKIP
        return Data(platformValue: platformValue.bitmapRepresentation)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public var inverted: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.inverted)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public func hasMember(inPlane plane: UInt8) -> Bool {
        #if !SKIP
        return platformValue.hasMember(inPlane: plane)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func insert(charactersIn range: Range<Unicode.Scalar>) {
        #if !SKIP
        platformValue.insert(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as Range)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func insert(charactersIn range: ClosedRange<Unicode.Scalar>) {
        #if !SKIP
        platformValue.insert(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as ClosedRange)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func remove(charactersIn range: Range<Unicode.Scalar>) {
        #if !SKIP
        platformValue.remove(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as Range)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func remove(charactersIn range: ClosedRange<Unicode.Scalar>) {
        #if !SKIP
        platformValue.remove(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as ClosedRange)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func insert(charactersIn string: String) {
        #if !SKIP
        platformValue.insert(charactersIn: string)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func remove(charactersIn string: String) {
        #if !SKIP
        platformValue.remove(charactersIn: string)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func invert() {
        #if !SKIP
        platformValue.invert()
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    @discardableResult
    public mutating func insert(_ character: Unicode.Scalar) -> (inserted: Bool, memberAfterInsert: Unicode.Scalar) {
        #if !SKIP
        fatalError("SKIP TODO: CharacterSet")
        //return platformValue.insert(SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion"))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    @discardableResult
    public mutating func update(with character: Unicode.Scalar) -> Unicode.Scalar? {
        #if !SKIP
        fatalError("SKIP TODO: CharacterSet")
        //return platformValue.update(with: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion"))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    @discardableResult
    public mutating func remove(_ character: Unicode.Scalar) -> Unicode.Scalar? {
        #if !SKIP
        fatalError("SKIP TODO: CharacterSet")
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public func contains(_ member: Unicode.Scalar) -> Bool {
        #if !SKIP
        fatalError("SKIP TODO: CharacterSet")
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public func union(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.union(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func formUnion(_ other: CharacterSet) {
        #if !SKIP
        platformValue.formUnion(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public func intersection(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.intersection(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func formIntersection(_ other: CharacterSet) {
        #if !SKIP
        platformValue.formIntersection(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public func subtracting(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.subtracting(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func subtract(_ other: CharacterSet) {
        #if !SKIP
        platformValue.subtract(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public func symmetricDifference(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.symmetricDifference(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public mutating func formSymmetricDifference(_ other: CharacterSet) {
        #if !SKIP
        platformValue.formSymmetricDifference(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    @available(*, unavailable)
    public func isSuperset(of other: CharacterSet) -> Bool {
        #if !SKIP
        return platformValue.isSuperset(of: other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    #if !SKIP
    public typealias ArrayLiteralElement = Unicode.Scalar
    public typealias Element = Unicode.Scalar
    #endif
}
