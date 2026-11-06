// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// An async sequence that producers can add to synchronously from any thread.
///
/// A channel uses one as the queue between logging calls and its handler.
struct YieldingSequence<Element: Sendable>: AsyncSequence, Sendable {
  /// Stream that delivers the yielded elements.
  private let stream: AsyncStream<Element>

  /// Continuation that receives yielded elements.
  private let continuation: AsyncStream<Element>.Continuation

  /// Creates an empty sequence with an unbounded buffer.
  init() {
    (stream, continuation) = AsyncStream.makeStream(of: Element.self)
  }

  /// Returns an iterator over the yielded elements.
  func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
    stream.makeAsyncIterator()
  }

  /// Adds an element to the sequence.
  func yield(_ element: Element) {
    continuation.yield(element)
  }

  /// Ends the sequence once the elements already yielded have been consumed.
  func finish() {
    continuation.finish()
  }
}
