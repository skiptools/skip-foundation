// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import OSLog
import XCTest

/// This test is a minimal example of `OSLog.Logger` being transpiled to use `skip.foundation.SkipLogger` on the Kotlin side.
@available(macOS 14, iOS 16, watchOS 9, tvOS 16, *)
final class LoggerTests: XCTestCase {
    let logger: Logger = Logger(subsystem: "test", category: "LoggerTests")

    public func testLogDebug() {
        logger.debug("logger debug test")
    }

    public func testLogInfo() {
        logger.info("logger info test")
    }

    public func testLogWarning() {
        logger.warning("logger warning test")
    }

    public func testLogError() {
        logger.error("logger error test")
    }
}
