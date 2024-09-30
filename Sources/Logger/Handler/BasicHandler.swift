// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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

  public func shutdown() async {
  }

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
