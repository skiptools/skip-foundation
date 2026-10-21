// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

/// A type that defines an attributed string attribute's name and value type.
public protocol AttributedStringKey {
    associatedtype Value : Hashable
    static var name: String { get }
}

/// A type that collects related attribute keys.
public protocol AttributeScope {
}

#endif
