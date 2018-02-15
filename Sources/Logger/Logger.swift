import Foundation

public class Logger {
  public static let defaultHandler = NSLogHandler("default")

  static let enabledLogs = Logger.readEnabledLogs()

  let name : String
  var handlers : [LogHandler] = []
  let handlersSetup : () -> [LogHandler]

  public var enabled = false
  var setup = false

  public init(_ name : String, handlers : @autoclosure @escaping () -> [LogHandler] = [defaultHandler]) {
    self.name = name
    self.handlersSetup = handlers
  }

  static internal func readEnabledLogs() -> [String] {
    let defaults = UserDefaults.standard
    guard let logs = defaults.string(forKey: "logs") else {
      return []
    }
    var items = Set(logs.split(separator:","))

    if let additions = defaults.string(forKey: "logs+") {
      let itemsToAdd = Set(additions.split(separator:","))
      items.formUnion(itemsToAdd)
    }

    if let subtractions = defaults.string(forKey: "logs-") {
      let itemsToRemove = Set(subtractions.split(separator:","))
      items.subtract(itemsToRemove)
    }

    defaults.set(logs, forKey: "logs")
    return items.map { return String($0) }
  }

  internal func readSettings() {
    if Logger.enabledLogs.contains("\(name)") {
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
