// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// An async stream of logged items.
public typealias LogStream = AsyncStream<LoggedItem>

/// Handler which outputs the logged items to an async stream.
public final class StreamHandler: Handler {
  /// Name of the handler.
  public let name: String

  /// Continuation to yield logged items to.
  let continuation: LogStream.Continuation

  /// Creates a handler that yields items to the given continuation.
  public init(_ name: String, continuation: LogStream.Continuation) {
    self.name = name
    self.continuation = continuation
  }

  /// Yields an item to the stream.
  public func log(_ item: LoggedItem) async {
    continuation.yield(item)
  }
}
