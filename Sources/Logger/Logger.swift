
public class LogContext : CustomStringConvertible {
  let file: String
  let line : Int
  let function : String
  let column : Int
  
  public init(file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function) {
    self.file = file
    self.line = line
    self.function = function
    self.column = column
  }
  
  public var description: String { get {
    return "\(file): \(line),\(column) - \(function)"
    }
  }
}

class LogHandler {
  let name : String
  
  init(_ name : String) {
    self.name = name
  }
  
  func log(channel: Logger, context : LogContext, logged : () -> Any) {
    print("\(channel.name): \(logged())")
  }
}

class Logger {
  static let defaultHandler = LogHandler("default")
  
  let name : String
  var handlers : [LogHandler] = []
  let handlersSetup : () -> [LogHandler]
  var enabled = false
  var setup = false
  
  init(_ name : String, handlers : @autoclosure @escaping () -> [LogHandler] = [defaultHandler]) {
    self.name = name
    self.handlersSetup = handlers
  }
  
  func log(_ logged : @autoclosure () -> Any, file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function) {
    if (!setup) {
      self.handlers = self.handlersSetup()
      self.setup = true
    }
    if (enabled) {
      let context = LogContext(file:file, line:line, column:column, function:function)
      handlers.forEach({ $0.log(channel:self, context:context, logged:logged) })
    }
  }
  
  func debug(_ logged : @autoclosure () -> Any, file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function) {
    #if DEBUG
      log(logged, file: file, line: line, column: column, function: function)
    #endif
  }
}

