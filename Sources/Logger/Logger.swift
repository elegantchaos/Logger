// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Logger {
  public static let defaultHandler = NSLogHandler("default")
  static let defaultManager = LogManager()

  let name : String
  let manager : LogManager
  var handlers : [LogHandler] = []
  let handlersSetup : () -> [LogHandler]

  public var enabled = false
  var setup = false

  public init(_ name : String, handlers : @autoclosure @escaping () -> [LogHandler] = [defaultHandler]) {
    self.name = name
    self.handlersSetup = handlers
    self.manager = Logger.defaultManager
  }

  internal func readSettings() {
    if manager.enabledLogs.contains("\(name)") {
      enabled = true
    }

  }

  public func log(_ logged : @autoclosure () -> Any, file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function) {
    if (!setup) {
      readSettings()
      handlers = handlersSetup()
      setup = true
    }

    if (enabled) {
      let context = LogContext(file:file, line:line, column:column, function:function)
      handlers.forEach({ $0.log(channel:self, context:context, logged:logged) })
    }
  }

  public func debug(_ logged : @autoclosure () -> Any, file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function) {
    #if debug
      log(logged, file: file, line: line, column: column, function: function)
    #endif
  }
}
