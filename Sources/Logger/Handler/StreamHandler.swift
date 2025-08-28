// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public struct LoggedItem: Sendable {
  public let value: Sendable
  public let context: Context
}

/// An async stream of logged items.
public typealias LogStream = AsyncStream<LoggedItem>

/// Handler which outputs the logged items to an async stream.
public actor StreamHandler: Handler {
  public init(
    _ name: String,
    continuation: AsyncStream<LoggedItem>.Continuation
  ) {
    self.name = name
    self.continuation = continuation
  }

  /// Name of the stream.
  public let name: String

  /// Continuation to yield logged items to.
  let continuation: AsyncStream<LoggedItem>.Continuation

  /// Log an item.
  public func log(_ item: LoggedItem) async {
    print("logged \(item.value)")
    continuation.yield(item)
  }

  public func shutdown() {
    print("shutdown \(name)")
    continuation.finish()
  }
}
