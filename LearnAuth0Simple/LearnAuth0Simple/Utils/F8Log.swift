//
//  F8Log.swift
//
//  SwiftLogger
//

import Foundation
import os.log

public enum F8LogLevel: Int {
    case error = 3
    case warn = 2
    case info = 1
    case debug = 0
}

public class F8Log {
    
    private static var isDebugging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Returns true if the given logLevel should be filtered out.
    internal static func isFilteredOut(logLevel: F8LogLevel) -> Bool { return F8Log.logLevel.rawValue > logLevel.rawValue }
    
    /// The desired log level (.info by default)
    public static var logLevel: F8LogLevel = .info
    
    // MARK: - Loging methods
    
    /// Logs error messages on console with prefix [🔥].  This is used for items that are likely to cause a crash.
    /// Verbose fatalError is logged in debug mode, concise form is logged otherwise.
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func error ( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        // Filter
        if isFilteredOut(logLevel: .error) { return }
        // verbose fatalError in debug mode
        if isDebugging {
            fatalError("[🔥][\(filename):\(line):\(column):\(funcName)] \(object)")
        }
            // Otherwise, concise error is logged
        else {
            os_log("%@", log: OSLog.default, type: .error, "[🔥] \(object)")
        }
    }
    
    /// Logs warnings verbosely on console with prefix [🚨].  This is used for items that will cause a problem/crash if not resolved.
    /// Verbose form is logged in debug mode.  Concise form is logged otherwise.
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func warn ( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        // Filter
        if isFilteredOut(logLevel: .warn) { return }
        // Verbose warnings are logged when in debug mode
        if isDebugging {
            os_log("%@", log: OSLog.default, type: .error, "[🚨][\(filename):\(line):\(column):\(funcName)] \(object)")
        }
            // Concise warnings are logged otherwise
        else {
            os_log("%@", log: OSLog.default, type: .default, "[🚨] \(object)")
        }
    }
    
    /// Logs info messages on console with prefix [💬].  This is used for infrequent informational messages.
    /// Concise form is always logged.
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func info ( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        // Filter
        if isFilteredOut(logLevel: .info) { return }
        // Concise info is logged always
        os_log("%@", log: OSLog.default, type: .info, "[💬] \(object)")
    }
    
    /// Logs debug messages on console with prefix [🐞].  This is used for verbose debug messages.
    /// Verbose form is logged in debug mode.  Consise form is logged otherwise.
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func debug ( _ object: Any, filename: String = #file , line: Int = #line, column: Int = #column, funcName: String = #function) {
        // Filter
        if isFilteredOut(logLevel: .debug) { return }
        // Verbose debug logs are enabled in debugging mode
        if isDebugging {
            os_log("%@", log: OSLog.default, type: .debug, "[🐞][\(filename):\(line):\(column):\(funcName)] \(object)")
        }
        else {
            os_log("%@", log: OSLog.default, type: .debug, "[🐞] \(object)")
        }
    }
    
    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}
