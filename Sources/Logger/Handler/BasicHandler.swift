// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Handler that passes each item to a closure.
///
/// The closure receives the handler too, so that it can use `tag(for:)` to label output
/// with the channel's name or subsystem.
public final class BasicHandler: Handler {
  /// Name of the handler.
  public let name: String

  /// Whether `tag(for:)` includes the channel name.
  let showName: Bool

  /// Whether `tag(for:)` includes the channel subsystem.
  let showSubsystem: Bool

  /// Closure that outputs each item.
  let output: Output

  /// Creates a handler that outputs items with a closure.
  public init(
    _ name: String, showName: Bool = true, showSubsystem: Bool = false,
    output: @escaping Output
  ) {
    self.name = name
    self.showName = showName
    self.showSubsystem = showSubsystem
    self.output = output
  }

  /// Outputs an item with the closure.
  public func log(_ item: LoggedItem) async { await output(item, self) }

  /// Returns a text tag identifying the item's channel, for output closures to use.
  public func tag(for context: Context) -> String {
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

extension BasicHandler {
  /// Closure that outputs an item, given the item and the handler.
  public typealias Output = @Sendable (LoggedItem, BasicHandler) async -> Void
}
