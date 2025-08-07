// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public struct YieldingSequence<E: Sendable>: AsyncSequence, Sendable {
  public typealias Stream = AsyncStream<E>
  public typealias AsyncIterator = Stream.Iterator
  public typealias Element = E

  let stream: Stream
  let continuation: Stream.Continuation

  public init() {
    var c: Stream.Continuation?
    let s = Stream { continuation in
      c = continuation
    }
    self.stream = s
    self.continuation = c!
  }

  public func makeAsyncIterator() -> AsyncIterator {
    stream.makeAsyncIterator()
  }

  func yield(_ item: E) {
    continuation.yield(item)
  }

  func finish() {
    continuation.finish()
  }
}
