// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Synchronization

/// A broadcast sequence with independent, bounded buffers for subscribers.
///
/// Slow subscribers retain the 256 most recent events; older events can be dropped.
/// Each iterator receives the optional initial event before its buffered events.
public final class BroadcastSequence<Element: Sendable>: AsyncSequence, Sendable {
  /// Protected subscriber state.
  private let state = Mutex(State())

  /// Event delivered first to each subscriber, if any.
  private let initialElement: Element?

  /// Creates a broadcast sequence with an optional initial event for each subscriber.
  public init(initial: Element? = nil) {
    self.initialElement = initial
  }

  /// Registers an independent subscriber.
  public func makeAsyncIterator() -> AsyncIterator {
    let id = UUID()
    let (stream, continuation) = AsyncStream<Element>.makeStream(
      bufferingPolicy: .bufferingNewest(256))
    continuation.onTermination = { [weak self] _ in
      self?.remove(id)
    }
    let finished = state.withLock { state in
      if state.finished { return true }
      state.subscribers[id] = continuation
      return false
    }
    if finished { continuation.finish() }
    return AsyncIterator(initialElement: initialElement, iterator: stream.makeAsyncIterator())
  }

  /// Sends an event to the current subscribers.
  func yield(_ element: Element) {
    let subscribers = state.withLock { Array($0.subscribers.values) }
    for subscriber in subscribers { subscriber.yield(element) }
  }

  /// Ends all current and future subscriptions.
  func finish() {
    let subscribers = state.withLock { state in
      state.finished = true
      let subscribers = Array(state.subscribers.values)
      state.subscribers.removeAll()
      return subscribers
    }
    for subscriber in subscribers { subscriber.finish() }
  }

  /// Removes a terminated subscription.
  private func remove(_ id: UUID) {
    _ = state.withLock { $0.subscribers.removeValue(forKey: id) }
  }

  /// Iterator that delivers the initial event separately from its bounded buffer.
  public struct AsyncIterator: AsyncIteratorProtocol {
    /// Initial event that has not yet been delivered.
    private var initialElement: Element?

    /// Iterator for subsequent broadcast events.
    private var iterator: AsyncStream<Element>.Iterator

    /// Creates an iterator for a registered subscriber.
    fileprivate init(initialElement: Element?, iterator: AsyncStream<Element>.Iterator) {
      self.initialElement = initialElement
      self.iterator = iterator
    }

    /// Returns the next event, or nil when the subscription ends.
    public mutating func next() async -> Element? {
      if Task.isCancelled {
        _ = await iterator.next()
        return nil
      }
      if let initialElement {
        self.initialElement = nil
        return initialElement
      }
      return await iterator.next()
    }
  }

  /// State shared by subscriptions and event producers.
  private struct State {
    /// Continuations for active subscribers.
    var subscribers: [UUID: AsyncStream<Element>.Continuation] = [:]
    /// Whether the sequence has ended.
    var finished = false
  }
}
