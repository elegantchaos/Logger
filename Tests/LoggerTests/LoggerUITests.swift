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
