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

    /// Initialize with a range of integers.
    ///
    /// It is the caller's responsibility to ensure that the values represent valid `Unicode.Scalar` values, if that is what is desired.
    @available(*, unavailable)
    public init(charactersIn range: Range<Unicode.Scalar>) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    /// Initialize with a closed range of integers.
    ///
    /// It is the caller's responsibility to ensure that the values represent valid `Unicode.Scalar` values, if that is what is desired.
    @available(*, unavailable)
    public init(charactersIn range: ClosedRange<Unicode.Scalar>) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    /// Initialize with the characters in the given string.
    ///
    /// - parameter string: The string content to inspect for characters.
    @available(*, unavailable)
    public init(charactersIn string: String) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    /// Initialize with a bitmap representation.
    ///
    /// This method is useful for creating a character set object with data from a file or other external data source.
    /// - parameter data: The bitmap representation.
    @available(*, unavailable)
    public init(bitmapRepresentation data: Data) {
        self.platformValue = SkipCrash("TODO: CharacterSet")
    }

    /// Initialize with the contents of a file.
    ///
    /// Returns `nil` if there was an error reading the file.
    /// - parameter file: The file to read.
    @available(*, unavailable)
    public init?(contentsOfFile file: String) {
        self.platformValue = SkipCrash("SKIP TODO: CharacterSet")
    }

    /// Returns a character set containing the characters in Unicode General Category Cc and Cf.
    @available(*, unavailable)
    public static var controlCharacters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.controlCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category Zs and `CHARACTER TABULATION (U+0009)`.
    public static var whitespaces: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.whitespaces)
        #else
        // TODO: Actual values
        return CharacterSet(platformValue: [" ", "\t"])
        #endif
    }

    /// Returns a character set containing characters in Unicode General Category Z*, `U+000A ~ U+000D`, and `U+0085`.
    public static var whitespacesAndNewlines: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.whitespacesAndNewlines)
        #else
        // TODO: Actual values
        return CharacterSet(platformValue: [" ", "\t", "\n", "\r"])
        #endif
    }

    /// Returns a character set containing the characters in the category of Decimal Numbers.
    @available(*, unavailable)
    public static var decimalDigits: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.decimalDigits)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category L* & M*.
    @available(*, unavailable)
    public static var letters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.letters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category Ll.
    public static var lowercaseLetters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.lowercaseLetters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category Lu and Lt.
    public static var uppercaseLetters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.uppercaseLetters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category M*.
    @available(*, unavailable)
    public static var nonBaseCharacters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.nonBaseCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Categories L*, M*, and N*.
    @available(*, unavailable)
    public static var alphanumerics: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.alphanumerics)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing individual Unicode characters that can also be represented as composed character sequences (such as for letters with accents), by the definition of "standard decomposition" in version 3.2 of the Unicode character encoding standard.
    @available(*, unavailable)
    public static var decomposables: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.decomposables)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing values in the category of Non-Characters or that have not yet been defined in version 3.2 of the Unicode standard.
    @available(*, unavailable)
    public static var illegalCharacters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.illegalCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category P*.
    @available(*, unavailable)
    public static var punctuationCharacters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.punctuationCharacters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category Lt.
    @available(*, unavailable)
    public static var capitalizedLetters: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.capitalizedLetters)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the characters in Unicode General Category S*.
    @available(*, unavailable)
    public static var symbols: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.symbols)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a character set containing the newline characters (`U+000A ~ U+000D`, `U+0085`, `U+2028`, and `U+2029`).
    @available(*, unavailable)
    public static var newlines: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.newlines)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns the character set for characters allowed in a user URL subcomponent.
    @available(*, unavailable)
    public static var urlUserAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlUserAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns the character set for characters allowed in a password URL subcomponent.
    @available(*, unavailable)
    public static var urlPasswordAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlPasswordAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns the character set for characters allowed in a host URL subcomponent.
    @available(*, unavailable)
    public static var urlHostAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlHostAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns the character set for characters allowed in a path URL component.
    @available(*, unavailable)
    public static var urlPathAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlPathAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns the character set for characters allowed in a query URL component.
    @available(*, unavailable)
    public static var urlQueryAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlQueryAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns the character set for characters allowed in a fragment URL component.
    @available(*, unavailable)
    public static var urlFragmentAllowed: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: PlatformCharacterSet.urlFragmentAllowed)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a representation of the `CharacterSet` in binary format.
    @available(*, unavailable)
    public var bitmapRepresentation: Data {
        #if !SKIP
        return Data(platformValue: platformValue.bitmapRepresentation)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns an inverted copy of the receiver.
    @available(*, unavailable)
    public var inverted: CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.inverted)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns true if the `CharacterSet` has a member in the specified plane.
    ///
    /// This method makes it easier to find the plane containing the members of the current character set. The Basic Multilingual Plane (BMP) is plane 0.
    @available(*, unavailable)
    public func hasMember(inPlane plane: UInt8) -> Bool {
        #if !SKIP
        return platformValue.hasMember(inPlane: plane)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Insert a range of integer values in the `CharacterSet`.
    ///
    /// It is the caller's responsibility to ensure that the values represent valid `Unicode.Scalar` values, if that is what is desired.
    @available(*, unavailable)
    public mutating func insert(charactersIn range: Range<Unicode.Scalar>) {
        #if !SKIP
        platformValue.insert(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as Range)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Insert a closed range of integer values in the `CharacterSet`.
    ///
    /// It is the caller's responsibility to ensure that the values represent valid `Unicode.Scalar` values, if that is what is desired.
    @available(*, unavailable)
    public mutating func insert(charactersIn range: ClosedRange<Unicode.Scalar>) {
        #if !SKIP
        platformValue.insert(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as ClosedRange)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Remove a range of integer values from the `CharacterSet`.
    @available(*, unavailable)
    public mutating func remove(charactersIn range: Range<Unicode.Scalar>) {
        #if !SKIP
        platformValue.remove(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as Range)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Remove a closed range of integer values from the `CharacterSet`.
    @available(*, unavailable)
    public mutating func remove(charactersIn range: ClosedRange<Unicode.Scalar>) {
        #if !SKIP
        platformValue.remove(charactersIn: SkipCrash("TODO: Unicode.Scalar to Foundation.Unicode.Scalar conversion") as ClosedRange)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Insert the values from the specified string into the `CharacterSet`.
    @available(*, unavailable)
    public mutating func insert(charactersIn string: String) {
        #if !SKIP
        platformValue.insert(charactersIn: string)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Remove the values from the specified string from the `CharacterSet`.
    @available(*, unavailable)
    public mutating func remove(charactersIn string: String) {
        #if !SKIP
        platformValue.remove(charactersIn: string)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Invert the contents of the `CharacterSet`.
    @available(*, unavailable)
    public mutating func invert() {
        #if !SKIP
        platformValue.invert()
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Insert a `Unicode.Scalar` representation of a character into the `CharacterSet`.
    ///
    /// `Unicode.Scalar` values are available on `Swift.String.UnicodeScalarView`.
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

    /// Insert a `Unicode.Scalar` representation of a character into the `CharacterSet`.
    ///
    /// `Unicode.Scalar` values are available on `Swift.String.UnicodeScalarView`.
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

    /// Remove a `Unicode.Scalar` representation of a character from the `CharacterSet`.
    ///
    /// `Unicode.Scalar` values are available on `Swift.String.UnicodeScalarView`.
    @available(*, unavailable)
    @discardableResult
    public mutating func remove(_ character: Unicode.Scalar) -> Unicode.Scalar? {
        #if !SKIP
        fatalError("SKIP TODO: CharacterSet")
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Test for membership of a particular `Unicode.Scalar` in the `CharacterSet`.
    @available(*, unavailable)
    public func contains(_ member: Unicode.Scalar) -> Bool {
        #if !SKIP
        fatalError("SKIP TODO: CharacterSet")
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a union of the `CharacterSet` with another `CharacterSet`.
    @available(*, unavailable)
    public func union(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.union(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Sets the value to a union of the `CharacterSet` with another `CharacterSet`.
    @available(*, unavailable)
    public mutating func formUnion(_ other: CharacterSet) {
        #if !SKIP
        platformValue.formUnion(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns an intersection of the `CharacterSet` with another `CharacterSet`.
    @available(*, unavailable)
    public func intersection(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.intersection(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Sets the value to an intersection of the `CharacterSet` with another `CharacterSet`.
    @available(*, unavailable)
    public mutating func formIntersection(_ other: CharacterSet) {
        #if !SKIP
        platformValue.formIntersection(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns a `CharacterSet` created by removing elements in `other` from `self`.
    @available(*, unavailable)
    public func subtracting(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.subtracting(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Sets the value to a `CharacterSet` created by removing elements in `other` from `self`.
    @available(*, unavailable)
    public mutating func subtract(_ other: CharacterSet) {
        #if !SKIP
        platformValue.subtract(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns an exclusive or of the `CharacterSet` with another `CharacterSet`.
    @available(*, unavailable)
    public func symmetricDifference(_ other: CharacterSet) -> CharacterSet {
        #if !SKIP
        return CharacterSet(platformValue: platformValue.symmetricDifference(other.platformValue))
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Sets the value to an exclusive or of the `CharacterSet` with another `CharacterSet`.
    @available(*, unavailable)
    public mutating func formSymmetricDifference(_ other: CharacterSet) {
        #if !SKIP
        platformValue.formSymmetricDifference(other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    /// Returns true if `self` is a superset of `other`.
    @available(*, unavailable)
    public func isSuperset(of other: CharacterSet) -> Bool {
        #if !SKIP
        return platformValue.isSuperset(of: other.platformValue)
        #else
        fatalError("SKIP TODO: CharacterSet")
        #endif
    }

    // TODO: expose to Skip
    #if !SKIP
    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = Unicode.Scalar

    /// A type for which the conforming type provides a containment test.
    public typealias Element = Unicode.Scalar
    #endif

}
