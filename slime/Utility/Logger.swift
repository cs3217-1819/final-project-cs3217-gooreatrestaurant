//
//  Logger.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import os

/**
 * Logger is a wrapper around os_log, using Apple's unified logging protocol.
 * Refer to https://developer.apple.com/documentation/os/logging
 * Additional guide here: https://www.bignerdranch.com/blog/migrating-to-unified-logging-swift-edition/
 */
class Logger {
    public static let it = Logger()
    
    private init() {
    }
    
    // Default logging: Use this level to capture
    //                  information about things that might result in a failure.
    public func log(_ message: String) {
        os_log("[LOG] %{public}@", message)
    }
    
    // Info logging: Use this level to capture information that may be helpful,
    //               but isn’t essential, for troubleshooting errors.
    public func info(_ message: String) {
        os_log("%{public}@", log: OSLog.default, type: .default, message)
    }
    
    // Debug logging: Use this level to capture information that may be useful
    //                during development or while troubleshooting a specific problem.
    public func debug(_ message: String) {
        os_log("%{public}@", log: OSLog.default, type: .debug, message)
        
    }
    
    // Error loging: Use this log level to capture process-level
    //               information to report errors in the process
    public func error(_ message: String) {
        os_log("%{public}@", log: OSLog.default, type: .error, message)
    }
    
    // Fault logging: Use this level to capture system-level or multi-process
    //                information to report system errors.
    public func fault(_ message: String) {
        os_log("%{public}@", log: OSLog.default, type: .fault, message)
    }
}
