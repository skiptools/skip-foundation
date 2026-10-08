// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

/// A container for attribute keys and values.
public struct AttributeContainer : Hashable {
    internal var storage: AttributeStorage

    public init() {
        storage = AttributeStorage()
    }

    internal init(_ storage: AttributeStorage) {
        self.storage = storage
    }

    public func value(key: String) -> Any? {
        return storage.value(key: key)
    }

    public mutating func setValue(_ value: Any?, key: String) {
        storage.setValue(value, key: key)
    }
}

/// Type-erased attribute storage keyed by attribute name.
struct AttributeStorage : Hashable {
    private var values: [String: Any] = [:]

    func value(key: String) -> Any? {
        return values[key]
    }

    mutating func setValue(_ value: Any?, key: String) {
        if let value {
            values[key] = value
        } else {
            values.removeValue(forKey: key)
        }
    }

    func merging(_ other: AttributeStorage) -> AttributeStorage {
        var result = self
        for (key, value) in other.values {
            result.values[key] = value
        }
        return result
    }

    static func ==(lhs: AttributeStorage, rhs: AttributeStorage) -> Bool {
        guard lhs.values.count == rhs.values.count else { return false }
        for (key, lhsValue) in lhs.values {
            guard let rhsValue = rhs.values[key] else { return false }
            if !AttributeStorage.valuesEqual(lhsValue, rhsValue) { return false }
        }
        return true
    }

    private static func valuesEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        if let lhs = lhs as? Bool, let rhs = rhs as? Bool { return lhs == rhs }
        if let lhs = lhs as? String, let rhs = rhs as? String { return lhs == rhs }
        if let lhs = lhs as? URL, let rhs = rhs as? URL { return lhs == rhs }
        return false
    }

    func hash(into hasher: inout Hasher) {
        for key in values.keys.sorted() {
            hasher.combine(key)
            hasher.combine(values[key])
        }
    }

    func attributeNames() -> [String] {
        return Array(values.keys)
    }

    func value(forName name: String) -> Any? {
        return values[name]
    }

    mutating func setValue(name: String, value: Any) {
        values[name] = value
    }
}

#endif
