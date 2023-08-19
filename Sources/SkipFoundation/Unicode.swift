// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// This code is adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which has the following license:

public typealias UnicodeScalarValue = UInt32

public func String(_ scalar: Unicode.Scalar) -> String {
    fatalError("SKIP TODO")
}

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//


/// A namespace for Unicode utilities.
@frozen public struct Unicode {

    @frozen public struct ASCII {
    }

    @frozen public struct UTF16 : Sendable {
        //case _swift3Buffer(Unicode.UTF16.ForwardParser)
    }

    @frozen public struct UTF32 : Sendable {
        //case _swift3Codec
    }

    @frozen public struct UTF8 : Sendable {
        //case struct(Unicode.UTF8.ForwardParser)
    }

    public typealias Encoding = _UnicodeEncoding

    /// The result of attempting to parse a `T` from some input.
    @frozen public enum ParseResult<T> {

        /// A `T` was parsed successfully
        case valid(T)

        /// The input was entirely consumed.
        case emptyInput

        /// An encoding error was detected.
        ///
        /// `length` is the number of underlying code units consumed by this
        /// error, guaranteed to be greater than 0.
        case error(length: Int)
    }

    public typealias Parser = _UnicodeParser

    /// A Unicode scalar value.
    @frozen public struct Scalar : RawRepresentable, Hashable, Comparable, Sendable {
        public let rawValue: UnicodeScalarValue
        
        public init?(rawValue: UnicodeScalarValue) {
            self.rawValue = rawValue
        }

        public init?(_ rawValue: UnicodeScalarValue) {
            self.rawValue = rawValue
        }

        public static func < (lhs: Unicode.Scalar, rhs: Unicode.Scalar) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

    }

    /// A version of the Unicode Standard represented by its major and minor
    /// components.
    public typealias Version = (major: Int, minor: Int)
}
