// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import Logger

/// Tests the events delivered by a logger manager.
struct ManagerEventTests {
  /// A slow subscriber retains only the most recent events.
  @Test
  func subscriberBufferIsBounded() async {
    let sequence = BroadcastSequence<Int>()
    var iterator = sequence.makeAsyncIterator()
    for value in 0..<300 { sequence.yield(value) }
    #expect(await iterator.next() == 44)
    sequence.finish()
  }

  /// Shutting down an empty manager emits shutdown and closes its event stream.
  @Test
  func emptyManagerShutdownFinishesEvents() async {
    let manager = Manager(settings: TestSettings())
    var events = await manager.events.makeAsyncIterator()
    _ = await events.next()
    await manager.shutdown()
    let channel = Channel("after-shutdown", manager: manager)
    let shuttingDown = await events.next()
    let shutdown = await events.next()
    if case .shuttingDown = shuttingDown {} else { Issue.record("Missing shuttingDown event.") }
    if case .shutdown = shutdown {} else { Issue.record("Missing shutdown event.") }
    if case .none = await events.next() {} else { Issue.record("Events did not end.") }
    channel.shutdown()
  }

  /// Stopping the last channel does not stop observation of later channels.
  @Test
  func channelCanRegisterAfterLastChannelStops() async {
    let manager = Manager(settings: TestSettings())
    var events = await manager.events.makeAsyncIterator()
    _ = await events.next()
    let first = Channel("first", manager: manager)
    while let event = await events.next() {
      if case .channelStarted = event { break }
    }
    first.shutdown()
    while let event = await events.next() {
      if case .channelShutdown = event { break }
    }
    let second = Channel("second", manager: manager)
    let next = await events.next()
    if case .channelAdded = next {} else { Issue.record("The later channel was not observed.") }
    second.shutdown()
    await manager.shutdown()
  }

  /// Shutdown waits for an in-flight handler before closing the stream.
  @Test
  func shutdownDrainsRegisteredChannels() async {
    let manager = Manager(settings: TestSettings())
    var events = await manager.events.makeAsyncIterator()
    _ = await events.next()
    let (started, startedContinuation) = AsyncStream<Void>.makeStream()
    let gate = HandlerGate()
    let handler = BasicHandler("gated") { _, _ in
      startedContinuation.yield(())
      await gate.wait()
    }
    let channel = Channel("drain", handler: handler, default: .enabled, manager: manager)
    while let event = await events.next() {
      if case .channelStarted = event { break }
    }
    channel.log("pending")
    var startedIterator = started.makeAsyncIterator()
    _ = await startedIterator.next()
    let shutdown = Task { await manager.shutdown() }
    let shuttingDown = await events.next()
    if case .shuttingDown = shuttingDown {} else { Issue.record("Missing shuttingDown event.") }
    await gate.release()
    await shutdown.value
    let stopped = await events.next()
    let completed = await events.next()
    if case .channelShutdown = stopped {} else { Issue.record("Channel did not drain.") }
    if case .shutdown = completed {} else { Issue.record("Shutdown did not finish.") }
  }

  /// Each subscriber receives the startup event before subsequent channel events.
  @Test
  func subscribersReceiveStartup() async {
    let manager = Manager(settings: TestSettings())
    var first = await manager.events.makeAsyncIterator()
    var second = await manager.events.makeAsyncIterator()
    let channel = Channel("events", manager: manager)

    let firstEvent = await first.next()
    let secondEvent = await second.next()
    if case .started = firstEvent {
      // The first subscriber received startup.
    } else {
      Issue.record("The first subscriber did not receive the startup event.")
    }
    if case .started = secondEvent {
      // The second subscriber received startup.
    } else {
      Issue.record("The second subscriber did not receive the startup event.")
    }
    if case .channelAdded = await first.next() {
    } else {
      Issue.record("The first subscriber missed the channel.")
    }
    if case .channelAdded = await second.next() {
    } else {
      Issue.record("The second subscriber missed the channel.")
    }
    channel.shutdown()
    await manager.shutdown()
  }
}

/// Test gate for holding an asynchronous handler until released.
private actor HandlerGate {
  /// Whether the gate has been released.
  private var isReleased = false

  /// The handler waiting for release, if any.
  private var waiter: CheckedContinuation<Void, Never>?

  /// Waits until the gate is released.
  func wait() async {
    if isReleased { return }
    await withCheckedContinuation { waiter = $0 }
  }

  /// Releases the handler, whether it has started waiting or not.
  func release() {
    isReleased = true
    waiter?.resume()
    waiter = nil
  }
}
