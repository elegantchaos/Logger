// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Encapsulates the context (function, line number, etc) in which the log statement was made.
 */

public struct Context: CustomStringConvertible, Sendable {
  let file: StaticString
  let line: UInt
  let function: StaticString
  let column: UInt
  let dso: UnsafeRawPointer

  public init(
    file: StaticString = #file, line: UInt = #line, column: UInt = #column,
    function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle
  ) {
    self.file = file
    self.line = line
    self.function = function
    self.column = column
    self.dso = dso
  }

  public var description: String {
    "\(file): \(line),\(column) - \(function)"
  }
}
