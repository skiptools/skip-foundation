// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

// This code is adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which has the following license:

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

public typealias UnicodeScalarValue = UInt32

@available(*, unavailable)
public func String(_ scalar: Unicode.Scalar) -> String {
    fatalError("SKIP TODO")
}

public struct Unicode {
    public struct ASCII {
    }

    public struct UTF16 : Sendable {
        //case _swift3Buffer(Unicode.UTF16.ForwardParser)
    }

    public struct UTF32 : Sendable {
        //case _swift3Codec
    }

    public struct UTF8 : Sendable {
        //case struct(Unicode.UTF8.ForwardParser)
    }

    public typealias Encoding = _UnicodeEncoding

    public enum ParseResult<T> {
        case valid(T)
        case emptyInput
        case error(length: Int)
    }

    public typealias Parser = _UnicodeParser

    public struct Scalar : RawRepresentable, Hashable, Comparable, Sendable {
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

    public typealias Version = (major: Int, minor: Int)
}

#endif
