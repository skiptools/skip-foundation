// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.IndexSet
internal typealias PlatformIndexSet = Foundation.IndexSet
internal typealias IndexSetElement = Int
internal typealias IndexSetIndex = Foundation.IndexSet.Index
#else
internal typealias PlatformIndexSet = skip.lib.Set<IndexSetElement>
internal typealias IndexSetElement = Int
internal typealias IndexSetIndex = Int
#endif

/// A collection of unique integer values that represent the indexes of elements in another collection.
public struct IndexSet : Hashable, CustomStringConvertible {
    internal var platformValue: PlatformIndexSet

    internal init(platformValue: PlatformIndexSet) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = PlatformIndexSet()
    }

    @available(*, unavailable)
    public var count: Int {
        fatalError()
    }

    public var description: String {
        return platformValue.description
    }

    // TODO: fill in IndexSet stub methods
    #if false

    #if !SKIP
    public typealias Element = Int
    public typealias ArrayLiteralElement = IndexSetElement
    //public typealias Indices = DefaultIndices<IndexSet>
    //public typealias Iterator = IndexingIterator<IndexSet>
    //public typealias SubSequence = Slice<IndexSet>
    #endif

    @available(*, unavailable)
    public init(integersIn range: Range<IndexSetElement>) {
        fatalError()
    }

    @available(*, unavailable)
    public init<R>(integersIn range: R) where R : RangeExpression, R.Bound == Int {
        fatalError()
    }

    @available(*, unavailable)
    public init(integer: IndexSetElement) {
        fatalError()
    }

    @available(*, unavailable)
    public func makeIterator() -> IndexingIterator<IndexSet> {
        fatalError()
    }

    @available(*, unavailable)
    public var rangeView: IndexSet.RangeView {
        fatalError()
    }

    @available(*, unavailable)
    public func rangeView(of range: Range<IndexSetElement>) -> IndexSet.RangeView {
        fatalError()
    }

    @available(*, unavailable)
    public func rangeView<R>(of range: R) -> IndexSet.RangeView where R : RangeExpression, R.Bound == Int {
        fatalError()
    }

    @available(*, unavailable)
    public var startIndex: IndexSetIndex  {
        fatalError()
    }

    @available(*, unavailable)
    public var endIndex: IndexSetIndex  {
        fatalError()
    }

    #if !SKIP // no custom subscripts in Skip
    @available(*, unavailable)
    public subscript(index: IndexSetIndex) -> IndexSetElement  {
        fatalError()
    }

    @available(*, unavailable)
    public subscript(bounds: Range<IndexSetIndex>) -> Slice<IndexSet>  {
        fatalError()
    }
    #endif

    @available(*, unavailable)
    public func integerGreaterThan(_ integer: IndexSetElement) -> IndexSetElement? {
        fatalError()
    }

    @available(*, unavailable)
    public func integerGreaterThanOrEqualTo(_ integer: IndexSetElement) -> IndexSetElement? {
        fatalError()
    }

    @available(*, unavailable)
    public func integerLessThanOrEqualTo(_ integer: IndexSetElement) -> IndexSetElement? {
        fatalError()
    }

    @available(*, unavailable)
    public func indexRange(in range: Range<IndexSetElement>) -> Range<IndexSetIndex> {
        fatalError()
    }

    @available(*, unavailable)
    public func indexRange<R>(in range: R) -> Range<IndexSetIndex> where R : RangeExpression, R.Bound == Int {
        fatalError()
    }

    @available(*, unavailable)
    public func count<R>(in range: R) -> Int where R : RangeExpression, R.Bound == Int {
        fatalError()
    }

    @available(*, unavailable)
    public func contains(_ integer: IndexSetElement) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func contains(integersIn range: Range<IndexSetElement>) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func contains<R>(integersIn range: R) -> Bool where R : RangeExpression, R.Bound == Int {
        fatalError()
    }

    @available(*, unavailable)
    public func contains(integersIn indexSet: IndexSet) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func intersects(integersIn range: Range<IndexSetElement>) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func intersects<R>(integersIn range: R) -> Bool where R : RangeExpression, R.Bound == Int {
        fatalError()
    }

    @available(*, unavailable)
    public func index(after i: IndexSetIndex) -> IndexSetIndex {
        fatalError()
    }

    @available(*, unavailable)
    public func formIndex(after i: inout IndexSetIndex) {
        fatalError()
    }

    @available(*, unavailable)
    public func index(before i: IndexSetIndex) -> IndexSetIndex {
        fatalError()
    }

    @available(*, unavailable)
    public func formIndex(before i: inout IndexSetIndex) {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func formUnion(_ other: IndexSet) {
        fatalError()
    }

    @available(*, unavailable)
    public func union(_ other: IndexSet) -> IndexSet {
        fatalError()
    }

    @available(*, unavailable)
    public func symmetricDifference(_ other: IndexSet) -> IndexSet {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func formSymmetricDifference(_ other: IndexSet) {
        fatalError()
    }

    @available(*, unavailable)
    public func intersection(_ other: IndexSet) -> IndexSet {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func formIntersection(_ other: IndexSet) {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func insert(_ integer: IndexSetElement) -> (inserted: Bool, memberAfterInsert: IndexSetElement) {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func update(with integer: IndexSetElement) -> IndexSetElement? {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func remove(_ integer: IndexSetElement) -> IndexSetElement? {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func removeAll() {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func insert(integersIn range: Range<IndexSetElement>) {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func insert<R>(integersIn range: R) where R : RangeExpression, R.Bound == Int {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func remove(integersIn range: Range<IndexSetElement>) {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func remove(integersIn range: ClosedRange<IndexSetElement>) {
        fatalError()
    }

    @available(*, unavailable)
    public var isEmpty: Bool  {
        fatalError()
    }

    @available(*, unavailable)
    public func filteredIndexSet(in range: Range<IndexSetElement>, includeInteger: (IndexSetElement) throws -> Bool) rethrows -> IndexSet {
        fatalError()
    }

    @available(*, unavailable)
    public func filteredIndexSet(in range: ClosedRange<IndexSetElement>, includeInteger: (IndexSetElement) throws -> Bool) rethrows -> IndexSet {
        fatalError()
    }

    @available(*, unavailable)
    public func filteredIndexSet(includeInteger: (IndexSetElement) throws -> Bool) rethrows -> IndexSet {
        fatalError()
    }

    @available(*, unavailable)
    public mutating func shift(startingAt integer: IndexSetElement, by delta: Int) {
        fatalError()
    }

    @available(*, unavailable)
    public var hashValue: Int  {
        fatalError()
    }
    #endif
}

#if SKIP
extension IndexSet {
    public func kotlin(nocopy: Bool = false) -> skip.lib.Set<Int> {
        return nocopy ? platformValue : platformValue.sref()
    }
}
#endif
