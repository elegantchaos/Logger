
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
