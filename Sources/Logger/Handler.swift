// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Responsible for sending log output somewhere.

 Examples might include printing the output with NSLog/print/OSLog,
 writing it to disk, or sending it down a pipe or network stream.
 */

public protocol Handler: Sendable {
  var name: String { get }
  func log(_ value: Sendable, context: Context) async
}

public actor BasicHandler: Handler {
  public typealias Logger = @Sendable (Sendable, Context, BasicHandler) async -> Void

  public let name: String
  let showName: Bool
  let showSubsystem: Bool
  let logger: Logger

  public init(
    _ name: String, showName: Bool = true, showSubsystem: Bool = false, logger: @escaping Logger
  ) {
    self.name = name
    self.showName = showName
    self.showSubsystem = showSubsystem
    self.logger = logger
  }

  /// Log something.
  public func log(_ value: Sendable, context: Context) async { await logger(value, context, self) }

  /// Calculate a text tag indicating the context.
  /// Provided as a utility for logger callbacks to use as they need.
  internal func tag(for context: Context) -> String {
    let channel = context.channel
    if showName, showSubsystem {
      return "[\(channel.subsystem).\(channel.name)] "
    } else if showName {
      return "[\(channel.name)] "
    } else if showSubsystem {
      return "[\(channel.subsystem)] "
    } else {
      return ""
    }
  }
}

/// Outputs log messages using swift's print() function.
let printHandler = BasicHandler("print") { value, context, handler in
  let tag = handler.tag(for: context)
  print("\(tag)\(value)")
}

#if os(macOS) || os(iOS)
  import Foundation

  ///  Outputs log messages using NSLog()
  let nslogHandler = BasicHandler("nslog") {
    value, context, handler in
    let tag = handler.tag(for: context)
    NSLog("\(tag)\(value)")
  }

#endif
