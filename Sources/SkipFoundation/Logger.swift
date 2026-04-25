// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

/// Skip `Logger` aliases to `SkipLogger` type and wraps `java.util.logging.Logger`
public typealias Logger = SkipLogger
public typealias OSLogType = SkipLogger.LogType

/// Message wrapper that mirrors Apple-style logger entrypoints while allowing
/// platform-specific interpolation behavior on Android.
public struct LogMessage : ExpressibleByStringInterpolation, CustomStringConvertible, Sendable {
    #if SKIP
    // Mirror existing Skip pattern to avoid Kotlin unresolved nested interpolation type.
    public typealias StringInterpolation = LogMessage.StringInterpolation
    #endif

    public let description: String

    public init(stringLiteral value: String) {
        self.description = value
    }

    public init(stringInterpolation: StringInterpolation) {
        self.description = stringInterpolation.description
    }

    public struct StringInterpolation : StringInterpolationProtocol, Sendable {
        var parts: [String] = []

        public var description: String {
            parts.joined()
        }

        public init(literalCapacity: Int, interpolationCount: Int) {
            parts.reserveCapacity(interpolationCount * 2 + 1)
        }

        public mutating func appendLiteral(_ literal: String) {
            parts.append(literal)
        }

        public mutating func appendInterpolation<T>(_ value: T) {
            parts.append(String(describing: value))
        }

        public mutating func appendInterpolation(_ error: any Error) {
            parts.append(Self.renderedError(error))
        }

        private static func renderedError(_ error: any Error) -> String {
            if let throwable = error as? java.lang.Throwable {
                return throwableStackTraceString(throwable)
            }
            return String(describing: error)
        }

        private static func throwableStackTraceString(_ throwable: java.lang.Throwable) -> String {
            let writer = java.io.StringWriter()
            let printWriter = java.io.PrintWriter(writer)
            throwable.printStackTrace(printWriter)
            printWriter.flush()
            return writer.toString()
        }
    }
}

/// Logger cover for versions before Logger was available (which coincides with Concurrency).
public class SkipLogger {
    let logName: String

    public enum LogType {
        case `default`
        case info
        case debug
        case error
        case fault
    }

    public init(subsystem: String, category: String) {
        self.logName = subsystem + "." + category
    }

    public func isEnabled(type: OSLogType) -> Bool {
        return true
    }

    public func log(level: OSLogType, _ message: LogMessage) {
        switch level {
        case .default: log(message)
        case .info: info(message)
        case .debug: debug(message)
        case .error: error(message)
        case .fault: fault(message)
        default: log(message)
        }
    }

    public func log(level: OSLogType, _ message: String) {
        log(level: level, LogMessage(stringLiteral: message))
    }

    public func log(_ message: LogMessage) {
        do {
            android.util.Log.i(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.INFO, message.description)
        }
    }

    public func log(_ message: String) {
        log(LogMessage(stringLiteral: message))
    }

    public func trace(_ message: LogMessage) {
        do {
            android.util.Log.v(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.FINER, message.description)
        }
    }

    public func trace(_ message: String) {
        trace(LogMessage(stringLiteral: message))
    }

    public func debug(_ message: LogMessage) {
        do {
            android.util.Log.d(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.FINE, message.description)
        }
    }

    public func debug(_ message: String) {
        debug(LogMessage(stringLiteral: message))
    }

    public func info(_ message: LogMessage) {
        do {
            android.util.Log.i(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.INFO, message.description)
        }
    }

    public func info(_ message: String) {
        info(LogMessage(stringLiteral: message))
    }

    public func notice(_ message: LogMessage) {
        do {
            android.util.Log.i(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.CONFIG, message.description)
        }
    }

    public func notice(_ message: String) {
        notice(LogMessage(stringLiteral: message))
    }

    public func warning(_ message: LogMessage) {
        do {
            android.util.Log.w(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.WARNING, message.description)
        }
    }

    public func warning(_ message: String) {
        warning(LogMessage(stringLiteral: message))
    }

    public func error(_ message: LogMessage) {
        do {
            android.util.Log.e(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.SEVERE, message.description)
        }
    }

    public func error(_ message: String) {
        error(LogMessage(stringLiteral: message))
    }

    public func critical(_ message: LogMessage) {
        do {
            android.util.Log.wtf(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.SEVERE, message.description)
        }
    }

    public func critical(_ message: String) {
        critical(LogMessage(stringLiteral: message))
    }

    public func fault(_ message: LogMessage) {
        do {
            android.util.Log.wtf(logName, message.description)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.SEVERE, message.description)
        }
    }

    public func fault(_ message: String) {
        fault(LogMessage(stringLiteral: message))
    }
}

#endif
