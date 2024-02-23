// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

/// Skip `Logger` aliases to `SkipLogger` type and wraps `java.util.logging.Logger`
public typealias Logger = SkipLogger
public typealias LogMessage = String
public typealias OSLogType = SkipLogger.LogType

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

    public func log(_ message: LogMessage) {
        do {
            android.util.Log.i(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.INFO, message)
        }
    }

    public func trace(_ message: LogMessage) {
        do {
            android.util.Log.v(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.FINER, message)
        }
    }

    public func debug(_ message: LogMessage) {
        do {
            android.util.Log.d(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.FINE, message)
        }
    }

    public func info(_ message: LogMessage) {
        do {
            android.util.Log.i(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.INFO, message)
        }
    }

    public func notice(_ message: LogMessage) {
        do {
            android.util.Log.i(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.CONFIG, message)
        }
    }

    public func warning(_ message: LogMessage) {
        do {
            android.util.Log.w(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.WARNING, message)
        }
    }

    public func error(_ message: LogMessage) {
        do {
            android.util.Log.e(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.SEVERE, message)
        }
    }

    public func critical(_ message: LogMessage) {
        do {
            android.util.Log.wtf(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.SEVERE, message)
        }
    }

    public func fault(_ message: LogMessage) {
        do {
            android.util.Log.wtf(logName, message)
        } catch {
            java.util.logging.Logger.getLogger(logName).log(java.util.logging.Level.SEVERE, message)
        }
    }
}

#endif
