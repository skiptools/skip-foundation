// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public struct IndexPath : Hashable, CustomStringConvertible {
    public typealias Element = Int

    internal var array: Array<Int>

    internal init(array: Array<Int>) {
        self.array = array
    }

    public init(collection: Iterable<Int>) {
        self.array = Array(collection)
    }

    public init(index: IndexPath.Element) {
        self.array = [index]
    }

    public var description: String {
        return array.description
    }

//    public typealias Index = Array<Int>.Index
//    public typealias Indices = DefaultIndices<IndexPath>
//    public init<ElementSequence>(indexes: ElementSequence) where ElementSequence : Sequence, ElementSequence.Element == Int
//    public init(arrayLiteral indexes: IndexPath.Element...)
//    public init(indexes: [IndexPath.Element])
//    public init(index: IndexPath.Element)
//    public func dropLast() -> IndexPath
//    public mutating func append(_ other: IndexPath)
//    public mutating func append(_ other: IndexPath.Element)
//    public mutating func append(_ other: [IndexPath.Element])
//    public func appending(_ other: IndexPath.Element) -> IndexPath
//    public func appending(_ other: IndexPath) -> IndexPath
//    public func appending(_ other: [IndexPath.Element]) -> IndexPath
//    public subscript(index: IndexPath.Index) -> IndexPath.Element
//    public subscript(range: Range<IndexPath.Index>) -> IndexPath
//    public func makeIterator() -> IndexingIterator<IndexPath>
//    public var count: Int { get }
//    public var startIndex: IndexPath.Index { get }
//    public var endIndex: IndexPath.Index { get }
//    public func index(before i: IndexPath.Index) -> IndexPath.Index
//    public func index(after i: IndexPath.Index) -> IndexPath.Index
//    public func compare(_ other: IndexPath) -> ComparisonResult
//    public func hash(into hasher: inout Hasher)
//    public static func == (lhs: IndexPath, rhs: IndexPath) -> Bool
//    public static func + (lhs: IndexPath, rhs: IndexPath) -> IndexPath
//    public static func += (lhs: inout IndexPath, rhs: IndexPath)
//    public static func < (lhs: IndexPath, rhs: IndexPath) -> Bool
//    public static func <= (lhs: IndexPath, rhs: IndexPath) -> Bool
//    public static func > (lhs: IndexPath, rhs: IndexPath) -> Bool
//    public static func >= (lhs: IndexPath, rhs: IndexPath) -> Bool
//    public typealias ArrayLiteralElement = IndexPath.Element
//    public typealias Iterator = IndexingIterator<IndexPath>
//    public typealias SubSequence = IndexPath
//    public var hashValue: Int { get }
}

extension IndexPath: KotlinConverting<MutableList<Int>> {
    public override func kotlin(nocopy: Bool = false) -> MutableList<Int> {
        return array.kotlin(nocopy: nocopy) as! MutableList<Int>
    }
}

#endif
