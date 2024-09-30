// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public struct LoggedItem: Sendable {
  let value: Sendable
  let context: Context
}

/// An async stream of logged items.
public typealias LogStream = AsyncThrowingStream<any Sendable, any Error>
public typealias LogStream2 = AsyncStream<LoggedItem>

/// Handler which outputs the logged items to an async stream.
public actor StreamHandler: Handler {
  public init(
    _ name: String,
    continuation: AsyncThrowingStream<any Sendable, Error>.Continuation
  ) {
    self.name = name
    self.continuation = continuation
  }

  /// Name of the stream.
  public let name: String

  /// Continuation to yield logged items to.
  let continuation: AsyncThrowingStream<Sendable, Error>.Continuation

  /// Log an item.
  public func log(_ value: Sendable, context: Context) async {
    print("logged \(value)")
    continuation.yield(value)
  }

  public func shutdown() {
    continuation.finish()
  }
}

public struct LogSequence: AsyncSequence, Sendable {
  public typealias AsyncIterator = LogStream2.Iterator
  public typealias Element = LoggedItem

  var stream: LogStream2!
  var continuation: LogStream2.Continuation!

  public init() {
    self.stream = LogStream2 { continuation in
      self.continuation = continuation
    }
  }

  public func makeAsyncIterator() -> LogStream2.Iterator {
    stream.makeAsyncIterator()
  }

  func log(_ item: LoggedItem) {
    continuation.yield(item)
  }
}
