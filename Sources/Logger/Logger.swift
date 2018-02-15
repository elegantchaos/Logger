import Foundation

public class Logger {
  public static let defaultHandler = LogHandler("default")

  let name : String
  var handlers : [LogHandler] = []
  let handlersSetup : () -> [LogHandler]

  public var enabled = false
  var setup = false

  public init(_ name : String, handlers : @autoclosure @escaping () -> [LogHandler] = [defaultHandler]) {
    self.name = name
    self.handlersSetup = handlers
  }

  internal func readSettings() {
    let defaults = UserDefaults.standard
    if let logs = defaults.string(forKey: "logs") {
      let items = logs.split(separator:",")
      if logs.contains("\(name)") {
        enabled = true
      }
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
    #if DEBUG
      log(logged, file: file, line: line, column: column, function: function)
    #endif
  }
}
