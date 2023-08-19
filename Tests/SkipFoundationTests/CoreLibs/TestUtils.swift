// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

func ensureFiles(_ fileNames: [String]) -> Bool {
    var result = true
    let fm = FileManager.default
    for name in fileNames {
        guard !fm.fileExists(atPath: name) else {
            continue
        }
        
        if name.hasSuffix("/") {
            do {
                try fm.createDirectory(atPath: name, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return false
            }
        } else {
        
            var isDir: ObjCBool = ObjCBool(false)
            let dir = NSString(string: name).deletingLastPathComponent
            if !fm.fileExists(atPath: dir, isDirectory: &isDir) {
                do {
                    try fm.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                    return false
                }
            } else if !isDir.boolValue {
                return false
            }
            
            result = result && fm.createFile(atPath: name, contents: nil, attributes: nil)
        }
    }
    return result
}


