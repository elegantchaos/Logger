// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Testing

#if canImport(SwiftUI)
  @testable import LoggerUI

  /// Regression tests for the SwiftUI-facing logger channel watcher.
  @MainActor
  struct LoggerUITests {
    /// Watchers release their event tasks when their owner releases them.
    @Test
    func watcherDeinitializes() async throws {
      let manager = Manager(settings: TestSettings())
      weak var releasedWatcher: ChannelWatcher?
      do {
        let watcher = ChannelWatcher(manager: manager)
        releasedWatcher = watcher
        await Task.yield()
      }
      try await waitUntil { releasedWatcher == nil }
      await manager.shutdown()
    }

    /// Every watcher sees updates from the same manager.
    @Test
    func multipleWatchersReceiveUpdates() async throws {
      let manager = Manager(settings: TestSettings())
      let first = ChannelWatcher(manager: manager)
      let second = ChannelWatcher(manager: manager)
      let channel = Channel("multiple-watchers", manager: manager)
      try await waitUntil { first.channels.count == 1 && second.channels.count == 1 }
      channel.enabled = true
      try await waitUntil { first.allEnabled && second.allEnabled }
      await manager.shutdown()
    }

    /// An empty manager has no enabled channels.
    @Test
    func emptyManagerIsNotAllEnabled() async {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      #expect(watcher.channels.isEmpty)
      #expect(watcher.allEnabled == false)
      await manager.shutdown()
    }

    /// Individual and master controls update the channels immediately.
    @Test
    func controlsUpdateChannels() async throws {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      let first = Channel("controls-first", manager: manager)
      let second = Channel("controls-second", manager: manager)
      try await waitUntil { watcher.channels.count == 2 }

      watcher.binding(for: first.id).wrappedValue = true
      #expect(first.enabled == true)
      #expect(second.enabled == false)
      #expect(watcher.allEnabled == false)

      watcher.allEnabled = true
      #expect(first.enabled == true)
      #expect(second.enabled == true)
      watcher.allEnabled = false
      #expect(first.enabled == false)
      #expect(second.enabled == false)
      await manager.shutdown()
    }

    /// Verifies that external channel changes refresh the published watcher snapshots.
    @Test
    func channelWatcherRefreshesSnapshotsWhenChannelChanges() async throws {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      let channel = Channel("watcher-test", manager: manager)

      defer {
        Task {
          await manager.shutdown()
        }
      }

      try await waitUntil { watcher.channels.count == 1 }
      #expect(watcher.channels[0].name == "watcher-test")
      #expect(watcher.channels[0].isEnabled == false)

      channel.enabled = true

      try await waitUntil { watcher.channels.first?.isEnabled == true }
      #expect(watcher.allEnabled)
    }

    /// Polls until `predicate` succeeds or throws after a short timeout.
    private func waitUntil(
      timeoutNanoseconds: UInt64 = 1_000_000_000,
      intervalNanoseconds: UInt64 = 10_000_000,
      predicate: @escaping @MainActor () -> Bool
    ) async throws {
      let deadline = ContinuousClock.now + .nanoseconds(Int(timeoutNanoseconds))
      while ContinuousClock.now < deadline {
        if predicate() {
          return
        }

        try await Task.sleep(nanoseconds: intervalNanoseconds)
      }

      Issue.record("Timed out waiting for predicate to become true.")
      throw CancellationError()
    }
  }
#endif
