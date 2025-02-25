// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public struct IndexPath : Codable, Comparable, Hashable, CustomStringConvertible, MutableCollection, RandomAccessCollection, KotlinConverting<MutableList<Int>> {
    public typealias Element = Int

    private let arrayList: ArrayList<Int> = ArrayList<Int>()

    override var mutableList: MutableList<Int> {
        return arrayList
    }
    override func willMutateStorage() {
        willmutate()
    }
    override func didMutateStorage() {
        didmutate()
    }

    public init() {
    }

    public init(indexes: Sequence<Int>) {
        arrayList.addAll(indexes)
    }

    public init(indexes: [Int]) {
        arrayList.addAll(indexes)
    }

    public init(index: Int) {
        arrayList.add(index)
    }

    // Override copy constructor
    public init(from: MutableStruct) {
        arrayList.addAll((from as! IndexPath).arrayList)
    }

    public init(from decoder: Decoder) {
        let unkeyedContainer = decoder.unkeyedContainer()
        while (!unkeyedContainer.isAtEnd) {
            arrayList.add(unkeyedContainer.decode(Int.self))
        }
    }

    public func encode(to encoder: Encoder) {
        let unkeyedContainer = encoder.unkeyedContainer()
        unkeyedContainer.encode(contentsOf: Array(collection: arrayList))
    }

    public var description: String {
        return arrayList.description
    }

    // SKIP DECLARE: operator fun plus(other: IndexPath): IndexPath
    public func plus(other: IndexPath) -> IndexPath {
        let combined = IndexPath()
        combined.arrayList.addAll(arrayList)
        combined.arrayList.addAll(other.arrayList)
        return combined
    }

    public func dropLast() -> IndexPath {
        let dropped = IndexPath()
        dropped.arrayList.addAll(arrayList)
        if !dropped.arrayList.isEmpty() {
            // cannot use removeLast() anymore: https://developer.android.com/about/versions/15/behavior-changes-15#openjdk-api-changes
            //dropped.arrayList.removeLast()
            dropped.arrayList.removeAt(dropped.arrayList.lastIndex)
        }
        return dropped
    }

    public mutating func append(_ other: IndexPath) {
        arrayList.addAll(other.arrayList)
    }

    public mutating func append(_ other: Int) {
        arrayList.add(other)
    }

    public mutating func append(_ other: [Int]) {
        arrayList.addAll(other)
    }

    public func appending(_ other: IndexPath) -> IndexPath {
        let copy = IndexPath()
        copy.arrayList.addAll(arrayList)
        copy.arrayList.addAll(other.arrayList)
        return copy
    }

    public func appending(_ other: Int) -> IndexPath {
        let copy = IndexPath()
        copy.arrayList.addAll(arrayList)
        copy.arrayList.add(other)
        return copy
    }

    public func appending(_ other: [Int]) -> IndexPath {
        let copy = IndexPath()
        copy.arrayList.addAll(arrayList)
        copy.arrayList.addAll(other)
        return copy
    }

    public override subscript(range: Range<Int>) -> IndexPath {
        let copy = IndexPath()
        for i in range {
            guard i < arrayList.size else {
                break
            }
            copy.arrayList.add(arrayList[i])
        }
        return copy
    }

    public static func <(lhs: IndexPath, rhs: IndexPath) {
        for i in 0..<lhs.count {
            if rhs.count < i {
                break
            }
            if lhs[i] < rhs[i] {
                return true
            } else if lhs[i] > rhs[i] {
                return false
            }
        }
        return lhs.count < rhs.count
    }

    public override func kotlin(nocopy: Bool = false) -> MutableList<Int> {
        return nocopy ? arrayList : ArrayList(arrayList)
    }
}

#endif
