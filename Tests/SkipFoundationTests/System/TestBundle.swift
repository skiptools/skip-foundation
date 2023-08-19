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

#if !SKIP
import CoreFoundation
#endif

internal func testBundle() -> Bundle {
    #if SKIP
    return Bundle(for: TestBundle.self as AnyClass) // Bundle.module doesn't seem to work from top-level functions, maybe due to Kotlin loading the wron
    #endif
    #if DARWIN_COMPATIBILITY_TESTS
    for bundle in Bundle.allBundles {
        if let bundleId = bundle.bundleIdentifier, bundleId == "org.swift.DarwinCompatibilityTests", bundle.resourcePath != nil {
            return bundle
        }
    }
    fatalError("Cant find test bundle")
    #else
    return Bundle.module
    #endif
}


#if true || DARWIN_COMPATIBILITY_TESTS
extension Bundle {
    static let _supportsFreestandingBundles = false
    static let _supportsFHSBundles = false
}
#endif


internal func testBundleName() -> String? {
    #if SKIP
    throw XCTSkip("TODO")
    #else
    // Either 'TestFoundation' or 'DarwinCompatibilityTests'
    return testBundle().infoDictionary?["CFBundleName"] as? String
    #endif // !SKIP
}

internal func xdgTestHelperURL() -> URL {
    #if SKIP
    throw XCTSkip("TODO")
    #else
    guard let url = testBundle().url(forAuxiliaryExecutable: "xdgTestHelper") else {
        fatalError("Cant find xdgTestHelper")
    }
    return url
    #endif // !SKIP
}


#if !SKIP
class BundlePlayground {
    enum ExecutableType: CaseIterable {
        case library
        case executable
        
        var pathExtension: String {
            switch self {
            case .library:
                #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                return "dylib"
                #elseif os(Windows)
                return "dll"
                #else
                return "so"
                #endif
            case .executable:
                #if os(Windows)
                return "exe"
                #else
                return ""
                #endif
            }
        }
        
        var flatPathExtension: String {
            #if os(Windows)
            return self.pathExtension
            #else
            return ""
            #endif
        }
        
        var fhsPrefix: String {
            switch self {
            case .executable:
                return "bin"
            case .library:
                return "lib"
            }
        }
        
        var nonFlatFilePrefix: String {
            switch self {
            case .executable:
                return ""
            case .library:
#if os(Windows)
                return ""
#else
                return "lib"
#endif
            }
        }
    }
    
    enum Layout {
        case flat(ExecutableType)
        case fhs(ExecutableType)
        case freestanding(ExecutableType)
        
        static var allApplicable: [Layout] {
            let layouts: [Layout] = [
                .flat(.library),
                .flat(.executable),
                .fhs(.library),
                .fhs(.executable),
                .freestanding(.library),
                .freestanding(.executable),
            ]
            
            return layouts.filter { $0.isSupported }
        }
            
        var isFreestanding: Bool {
            switch self {
            case .freestanding(_):
                return true
            default:
                return false
            }
        }
        
        var isFHS: Bool {
            switch self {
            case .fhs(_):
                return true
            default:
                return false
            }
        }
        
        var isFlat: Bool {
            switch self {
            case .flat(_):
                return true
            default:
                return false
            }
        }
        
        var isSupported: Bool {
            switch self {
            case .flat(_):
                return true
            case .freestanding(_):
                return false // Bundle._supportsFreestandingBundles
            case .fhs(_):
                return false // Bundle._supportsFHSBundles
            }
        }
    }
    
    #if !SKIP
    let bundleName: String
    let bundleExtension: String
    let resourceFilenames: [String]
    let resourceSubdirectory: String
    let subdirectoryResourcesFilenames: [String]
    let auxiliaryExecutableName: String
    let layout: Layout
    
    private(set) var bundlePath: String!
    private(set) var mainExecutableURL: URL!
    private var playgroundPath: String?
    
    init?(bundleName: String,
          bundleExtension: String,
          resourceFilenames: [String],
          resourceSubdirectory: String,
          subdirectoryResourcesFilenames: [String],
          auxiliaryExecutableName: String,
          layout: Layout) {
        self.bundleName = bundleName
        self.bundleExtension = bundleExtension
        self.resourceFilenames = resourceFilenames
        self.resourceSubdirectory = resourceSubdirectory
        self.subdirectoryResourcesFilenames = subdirectoryResourcesFilenames
        self.auxiliaryExecutableName = auxiliaryExecutableName
        self.layout = layout
        
        if !_create() {
            destroy()
            return nil
        }
    }
    #endif

    private func _create() -> Bool {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Make sure the directory is uniquely named
        
        let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("TestFoundation_Playground_" + UUID().uuidString)
        
        switch layout {
        case .flat(let executableType):
            do {
                try FileManager.default.createDirectory(atPath: temporaryDirectory.path, withIntermediateDirectories: false, attributes: nil)
                
                // Make a flat bundle in the playground
                let bundleURL = temporaryDirectory.appendingPathComponent(bundleName).appendingPathExtension(self.bundleExtension)
                try FileManager.default.createDirectory(atPath: bundleURL.path, withIntermediateDirectories: false, attributes: nil)
                
                // Make a main and an auxiliary executable:
                self.mainExecutableURL = bundleURL
                    .appendingPathComponent(bundleName)
                    .appendingPathExtension(executableType.flatPathExtension)
                
                guard FileManager.default.createFile(atPath: mainExecutableURL.path, contents: nil) else {
                    return false
                }
                
                let auxiliaryExecutableURL = bundleURL
                    .appendingPathComponent(auxiliaryExecutableName)
                    .appendingPathExtension(executableType.flatPathExtension)
                guard FileManager.default.createFile(atPath: auxiliaryExecutableURL.path, contents: nil) else {
                    return false
                }
                
                // Put some resources in the bundle
                for resourceName in resourceFilenames {
                    guard FileManager.default.createFile(atPath: bundleURL.appendingPathComponent(resourceName).path, contents: nil, attributes: nil) else {
                        return false
                    }
                }
                
                // Add a resource into a subdirectory
                let subdirectoryURL = bundleURL.appendingPathComponent(resourceSubdirectory)
                try FileManager.default.createDirectory(atPath: subdirectoryURL.path, withIntermediateDirectories: false, attributes: nil)
                
                for resourceName in subdirectoryResourcesFilenames {
                    guard FileManager.default.createFile(atPath: subdirectoryURL.appendingPathComponent(resourceName).path, contents: nil, attributes: nil) else {
                        return false
                    }
                }
                
                self.bundlePath = bundleURL.path
            } catch {
                return false
            }
            
        case .fhs(let executableType):
            do {
                
                // Create a FHS /usr/local-style hierarchy:
                try FileManager.default.createDirectory(atPath: temporaryDirectory.path, withIntermediateDirectories: false, attributes: nil)
                try FileManager.default.createDirectory(atPath: temporaryDirectory.appendingPathComponent("share").path, withIntermediateDirectories: false, attributes: nil)
                try FileManager.default.createDirectory(atPath: temporaryDirectory.appendingPathComponent("lib").path, withIntermediateDirectories: false, attributes: nil)
                
                // Make a main and an auxiliary executable:
                self.mainExecutableURL = temporaryDirectory
                    .appendingPathComponent(executableType.fhsPrefix)
                    .appendingPathComponent(executableType.nonFlatFilePrefix + bundleName)
                    .appendingPathExtension(executableType.pathExtension)
                guard FileManager.default.createFile(atPath: mainExecutableURL.path, contents: nil) else { return false }
                
                let executablesDirectory = temporaryDirectory.appendingPathComponent("libexec").appendingPathComponent("\(bundleName).executables")
                try FileManager.default.createDirectory(atPath: executablesDirectory.path, withIntermediateDirectories: true, attributes: nil)
                let auxiliaryExecutableURL = executablesDirectory
                    .appendingPathComponent(executableType.nonFlatFilePrefix + auxiliaryExecutableName)
                    .appendingPathExtension(executableType.pathExtension)
                guard FileManager.default.createFile(atPath: auxiliaryExecutableURL.path, contents: nil) else { return false }
                
                // Make a .resources directory in …/share:
                let resourcesDirectory = temporaryDirectory.appendingPathComponent("share").appendingPathComponent("\(bundleName).resources")
                try FileManager.default.createDirectory(atPath: resourcesDirectory.path, withIntermediateDirectories: false, attributes: nil)
                
                // Put some resources in the bundle
                for resourceName in resourceFilenames {
                    guard FileManager.default.createFile(atPath: resourcesDirectory.appendingPathComponent(resourceName).path, contents: nil, attributes: nil) else { return false }
                }
                
                // Add a resource into a subdirectory
                let subdirectoryURL = resourcesDirectory.appendingPathComponent(resourceSubdirectory)
                try FileManager.default.createDirectory(atPath: subdirectoryURL.path, withIntermediateDirectories: false, attributes: nil)
                
                for resourceName in subdirectoryResourcesFilenames {
                    guard FileManager.default.createFile(atPath: subdirectoryURL.appendingPathComponent(resourceName).path, contents: nil, attributes: nil) else { return false }
                }
                
                self.bundlePath = resourcesDirectory.path
            } catch {
                return false
            }
            
        case .freestanding(let executableType):
            do {
                let bundleName = URL(string:self.bundleName)!.deletingPathExtension().path
                
                try FileManager.default.createDirectory(atPath: temporaryDirectory.path, withIntermediateDirectories: false, attributes: nil)
                
                // Make a main executable:
                self.mainExecutableURL = temporaryDirectory
                    .appendingPathComponent(executableType.nonFlatFilePrefix + bundleName)
                    .appendingPathExtension(executableType.pathExtension)
                guard FileManager.default.createFile(atPath: mainExecutableURL.path, contents: nil) else { return false }
                
                // Make a .resources directory:
                let resourcesDirectory = temporaryDirectory.appendingPathComponent("\(bundleName).resources")
                try FileManager.default.createDirectory(atPath: resourcesDirectory.path, withIntermediateDirectories: false, attributes: nil)
                
                // Make an auxiliary executable:
                let auxiliaryExecutableURL = resourcesDirectory
                    .appendingPathComponent(executableType.nonFlatFilePrefix + auxiliaryExecutableName)
                    .appendingPathExtension(executableType.pathExtension)
                guard FileManager.default.createFile(atPath: auxiliaryExecutableURL.path, contents: nil) else { return false }
                
                // Put some resources in the bundle
                for resourceName in resourceFilenames {
                    guard FileManager.default.createFile(atPath: resourcesDirectory.appendingPathComponent(resourceName).path, contents: nil, attributes: nil) else { return false }
                }
                
                // Add a resource into a subdirectory
                let subdirectoryURL = resourcesDirectory.appendingPathComponent(resourceSubdirectory)
                try FileManager.default.createDirectory(atPath: subdirectoryURL.path, withIntermediateDirectories: false, attributes: nil)
                
                for resourceName in subdirectoryResourcesFilenames {
                    guard FileManager.default.createFile(atPath: subdirectoryURL.appendingPathComponent(resourceName).path, contents: nil, attributes: nil) else { return false }
                }
                
                self.bundlePath = resourcesDirectory.path
            } catch {
                return false
            }
        }
        
        self.playgroundPath = temporaryDirectory.path
        return true
        #endif // !SKIP
    }
    
    func destroy() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        guard let path = self.playgroundPath else { return }
        self.playgroundPath = nil

        try? FileManager.default.removeItem(atPath: path)
        #endif // !SKIP
    }
    
    #if !SKIP
    deinit {
        assert(playgroundPath == nil, "All playgrounds should have .destroy() invoked on them before they go out of scope.")
    }
    #endif
}
#endif

class TestBundle : XCTestCase {

    func test_paths() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let bundle = testBundle()
        
        // bundlePath
        XCTAssert(!bundle.bundlePath.isEmpty)
        XCTAssertEqual(bundle.bundleURL.path, bundle.bundlePath)
        let path = bundle.bundlePath

//        // /opt/src/github/skiptools/skiphub/Tests/SkipFoundationTests/TestBundle.swift:365: error: -[SkipFoundationTests.TestBundle test_paths] : XCTAssertEqual failed: ("Optional("/opt/src/github/skiptools/skiphub/.build/arm64-apple-macosx/debug/skiphub_SkipFoundationTests.bundle/Contents/Resources")") is not equal to ("Optional("/opt/src/github/skiptools/skiphub/.build/arm64-apple-macosx/debug/skiphub_SkipFoundationTests.bundle")")
//
//        // etc
//        #if os(macOS)
//        XCTAssertEqual("\(path)/Contents/Resources", bundle.resourcePath)
//        #if true || DARWIN_COMPATIBILITY_TESTS
//        //XCTAssertEqual("\(path)/Contents/MacOS/DarwinCompatibilityTests", bundle.executablePath)
//        #else
//        //XCTAssertEqual("\(path)/Contents/MacOS/TestFoundation", bundle.executablePath)
//        #endif
//        XCTAssertEqual("\(path)/Contents/Frameworks", bundle.privateFrameworksPath)
//        XCTAssertEqual("\(path)/Contents/SharedFrameworks", bundle.sharedFrameworksPath)
//        XCTAssertEqual("\(path)/Contents/SharedSupport", bundle.sharedSupportPath)
//        #endif
//        
//        XCTAssertNil(bundle.path(forAuxiliaryExecutable: "no_such_file"))
//        #if false && !DARWIN_COMPATIBILITY_TESTS
//        XCTAssertNil(bundle.appStoreReceiptURL)
//        #endif
        #endif // !SKIP
    }
    
    func test_resources() throws {
        let bundle = testBundle()
        
        // bad resources
        XCTAssertNil(bundle.url(forResource: nil, withExtension: nil, subdirectory: nil))
        XCTAssertNil(bundle.url(forResource: "", withExtension: "", subdirectory: nil))
        XCTAssertNil(bundle.url(forResource: "no_such_file", withExtension: nil, subdirectory: nil))

        // test file
        let testPlist = try XCTUnwrap(bundle.url(forResource: "Test", withExtension: "plist"))
        XCTAssertNotNil(testPlist)
        XCTAssertEqual("Test.plist", testPlist.lastPathComponent)
        // SKIP NOTE: bundle paths not necessarily files on disk, but in the case of these test cases they are
        XCTAssert(FileManager.default.fileExists(atPath: testPlist.path))
        XCTAssertEqual(true, try? testPlist.checkResourceIsReachable())

        // aliases, paths
        XCTAssertEqual(testPlist.path, bundle.url(forResource: "Test", withExtension: "plist", subdirectory: nil)?.path)
        XCTAssertEqual(testPlist.path, bundle.path(forResource: "Test", ofType: "plist"))
        XCTAssertEqual(testPlist.path, bundle.path(forResource: "Test", ofType: "plist", inDirectory: nil))
    }
    
    func test_infoPlist() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let bundle = testBundle()
        
        // bundleIdentifier
        #if true || DARWIN_COMPATIBILITY_TESTS
        //XCTAssertEqual("org.swift.DarwinCompatibilityTests", bundle.bundleIdentifier)
        #else
        //XCTAssertEqual("org.swift.TestFoundation", bundle.bundleIdentifier)
        #endif
        
        // infoDictionary
        let info = bundle.infoDictionary
        XCTAssertNotNil(info)
        
        #if true || DARWIN_COMPATIBILITY_TESTS
        //XCTAssert("DarwinCompatibilityTests" == info!["CFBundleName"] as! String)
        //XCTAssert("org.swift.DarwinCompatibilityTests" == info!["CFBundleIdentifier"] as! String)
        #else
        //XCTAssert("TestFoundation" == info!["CFBundleName"] as! String)
        //XCTAssert("org.swift.TestFoundation" == info!["CFBundleIdentifier"] as! String)
        #endif
        
        // localizedInfoDictionary
        XCTAssertNil(bundle.localizedInfoDictionary) // FIXME: Add a localized Info.plist for testing
        #endif // !SKIP
    }
    
    func test_localizations() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let bundle = testBundle()
        
        //XCTAssertEqual(["en"], bundle.localizations)
        XCTAssertEqual(["en"], bundle.preferredLocalizations)
        XCTAssertEqual(["en"], Bundle.preferredLocalizations(from: ["en", "pl", "es"]))
        #endif // !SKIP
    }
    
    #if !SKIP
    private let _bundleName = "MyBundle"
    private let _bundleExtension = "bundle"
    private let _bundleResourceNames = ["hello.world", "goodbye.world", "swift.org"]
    private let _subDirectory = "Sources"
    private let _main = "main"
    private let _type = "swift"
    private let _auxiliaryExecutable = "auxiliaryExecutable"
    
    private func _setupPlayground(layout: BundlePlayground.Layout) -> BundlePlayground? {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        return BundlePlayground(bundleName: _bundleName,
                                bundleExtension: _bundleExtension,
                                resourceFilenames: _bundleResourceNames,
                                resourceSubdirectory: _subDirectory,
                                subdirectoryResourcesFilenames: [ "\(_main).\(_type)" ],
                                auxiliaryExecutableName: _auxiliaryExecutable,
                                layout: layout)
        #endif // !SKIP
    }
    
    private func _withEachPlaygroundLayout(execute: (BundlePlayground) throws -> Void) rethrows {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for layout in BundlePlayground.Layout.allApplicable {
            if let playground = _setupPlayground(layout: layout) {
                try execute(playground)
                playground.destroy()
            }
        }
        #endif // !SKIP
    }
    
    private func _cleanupPlayground(_ location: String) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        try? FileManager.default.removeItem(atPath: location)
        #endif // !SKIP
    }
    #endif

    func test_URLsForResourcesWithExtension() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        _withEachPlaygroundLayout { (playground) in
            let bundle = Bundle(path: playground.bundlePath)!
            XCTAssertNotNil(bundle)
            
            let worldResources = bundle.urls(forResourcesWithExtension: "world", subdirectory: nil)
            XCTAssertNotNil(worldResources)
            XCTAssertEqual(worldResources?.count, 2)
            
            let path = bundle.path(forResource: _main, ofType: _type, inDirectory: _subDirectory)
            XCTAssertNotNil(path)
        }
        #endif // !SKIP
    }
    
    func test_bundleLoad() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
//        let bundle = testBundle()
//        let _ = bundle.load()
//        XCTAssertTrue(bundle.isLoaded)
        #endif // !SKIP
    }
    
    func test_bundleLoadWithError() {
//        let bundleValid = testBundle()
//
//        // Test valid load using loadAndReturnError
//        do {
//            try bundleValid.loadAndReturnError()
//        }
//        catch{
//            XCTFail("should not fail to load")
//        }
//
//        // Executable cannot be located
//        try! _withEachPlaygroundLayout { (playground) in
//            let bundle = Bundle(path: playground.bundlePath)
//            XCTAssertThrowsError(try bundle!.loadAndReturnError())
//        }
    }
    
    func test_bundleWithInvalidPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let bundleInvalid = Bundle(path: NSTemporaryDirectory() + "test.playground")
        XCTAssertNil(bundleInvalid)
        #endif // !SKIP
    }
    
    func test_bundlePreflight() {
//        XCTAssertNoThrow(try testBundle().preflight())
//
//        try! _withEachPlaygroundLayout { (playground) in
//            let bundle = Bundle(path: playground.bundlePath)!
//
//            // Must throw as the main executable is a dummy empty file.
//            XCTAssertThrowsError(try bundle.preflight())
//        }
    }
    
    func test_bundleFindExecutable() {
//        XCTAssertNotNil(testBundle().executableURL)
//
//        _withEachPlaygroundLayout { (playground) in
//            let bundle = Bundle(path: playground.bundlePath)!
//            XCTAssertNotNil(bundle.executableURL)
//        }
    }

    func test_bundleFindAuxiliaryExecutables() {
//        _withEachPlaygroundLayout { (playground) in
//            let bundle = Bundle(path: playground.bundlePath)!
//            XCTAssertNotNil(bundle.url(forAuxiliaryExecutable: _auxiliaryExecutable))
//            XCTAssertNil(bundle.url(forAuxiliaryExecutable: "does_not_exist_at_all"))
//        }
    }

#if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT
    func test_bundleReverseBundleLookup() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        _withEachPlaygroundLayout { (playground) in
            #if !os(Windows)
            if playground.layout.isFreestanding {
                // TODO: Freestanding bundles reverse lookup pending to be implemented on non-Windows platforms.
                return
            }
            #endif
            
            if playground.layout.isFHS {
                // TODO: FHS bundles reverse lookup pending to be implemented on all platforms.
                return
            }
            
            let bundle = Bundle(_executableURL: playground.mainExecutableURL)
            XCTAssertNotNil(bundle)
            XCTAssertEqual(bundle?.bundlePath, playground.bundlePath)
        }
        #endif // !SKIP
    }

    func test_mainBundleExecutableURL() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let maybeURL = Bundle.main.executableURL
        XCTAssertNotNil(maybeURL)
        guard let url = maybeURL else { return }
        
        XCTAssertEqual(url.path, ProcessInfo.processInfo._processPath)
        #endif // !SKIP
    }
#endif
    
    func test_bundleForClass() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        //XCTAssertEqual(testBundle(), Bundle(for: type(of: self)))
        #endif // !SKIP
    }
    
}

