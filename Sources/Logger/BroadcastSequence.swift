// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Synchronization

/// An event sequence that delivers each event to every active iterator.
public final class BroadcastSequence<Element: Sendable>: AsyncSequence, Sendable {
  /// The underlying iterator for one subscriber.
  public typealias AsyncIterator = AsyncStream<Element>.Iterator

  /// Protected subscriber state.
  private let state = Mutex(State())

  /// Creates an empty broadcast sequence.
  public init() {}

  /// Registers an independent subscriber.
  public func makeAsyncIterator() -> AsyncIterator {
    let id = UUID()
    let (stream, continuation) = AsyncStream<Element>.makeStream()
    continuation.onTermination = { [weak self] _ in
      self?.remove(id)
    }
    let finished = state.withLock { state in
      if state.finished { return true }
      state.subscribers[id] = continuation
      return false
    }
    if finished { continuation.finish() }
    return stream.makeAsyncIterator()
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

  /// State shared by subscriptions and event producers.
  private struct State {
    /// Continuations for active subscribers.
    var subscribers: [UUID: AsyncStream<Element>.Continuation] = [:]
    /// Whether the sequence has ended.
    var finished = false
  }
}
