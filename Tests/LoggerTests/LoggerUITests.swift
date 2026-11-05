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

    /// Duplicate short names remain distinguishable and have deterministic ordering.
    @Test
    func duplicateNamesIncludeSubsystems() async throws {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      let first = Channel("alpha.Shared", manager: manager)
      let second = Channel("beta.Shared", manager: manager)
      try await waitUntil { watcher.channels.count == 2 }
      #expect(watcher.channels.map(\.displayName) == ["alpha.Shared", "beta.Shared"])
      first.shutdown()
      second.shutdown()
      await manager.shutdown()
    }

    /// A single row controls every channel instance with its full identifier.
    @Test
    func duplicateIdentitySharesToggle() async throws {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      let first = Channel("Example.Shared", manager: manager)
      let second = Channel("Example.Shared", manager: manager)
      try await waitUntil { watcher.channels.count == 1 }
      watcher.setEnabled(true, for: first.id)
      #expect(first.enabled == true)
      #expect(second.enabled == true)
      second.enabled = false
      try await waitUntil { watcher.channels.first?.isEnabled == false }
      #expect(first.enabled == false)
      await manager.shutdown()
    }

    /// Without actions, the watcher's methods change the channels directly.
    @Test
    func watcherMethodsUpdateChannelsDirectly() async throws {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      let channel = Channel("action", manager: manager)
      try await waitUntil { watcher.channels.count == 1 }
      watcher.setEnabled(true, for: channel.id)
      #expect(channel.enabled == true)
      watcher.setAllEnabled(false)
      #expect(channel.enabled == false)
      await manager.shutdown()
    }

    /// With actions, every change is passed to them and the channels are left alone.
    @Test
    func actionsReceiveChanges() async throws {
      let manager = Manager(settings: TestSettings())
      let actions = RecordingActions()
      let watcher = ChannelWatcher(manager: manager, actions: actions)
      let channel = Channel("routed", manager: manager)
      try await waitUntil { watcher.channels.count == 1 }

      watcher[enabled: channel.id] = true
      watcher.allEnabled = true
      watcher.setEnabled(false, for: channel.id)
      watcher.setAllEnabled(false)
      watcher.resetToDefaults()

      #expect(
        actions.requests == [
          .channel(channel.id, true), .all(true), .channel(channel.id, false), .all(false),
          .reset,
        ])
      #expect(channel.enabled == false)
      await manager.shutdown()
    }

    /// Resetting returns channels to their defaults, after which the watcher reports that
    /// they are at their defaults.
    @Test
    func resetReturnsChannelsToDefaults() async throws {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      let onByDefault = Channel("reset-on", default: .enabled, manager: manager)
      let offByDefault = Channel("reset-off", manager: manager)
      try await waitUntil { watcher.channels.count == 2 }
      #expect(watcher.isAtDefaults == true)

      watcher.setAllEnabled(false)
      #expect(watcher.isAtDefaults == false)
      watcher.resetToDefaults()

      #expect(onByDefault.enabled == true)
      #expect(offByDefault.enabled == false)
      #expect(watcher.isAtDefaults == true)
      await manager.shutdown()
    }

    /// The master toggle's sources describe a mixed state, and writing the any-enabled
    /// source makes no change.
    @Test
    func masterToggleSourcesShowMixedState() async throws {
      let manager = Manager(settings: TestSettings())
      let watcher = ChannelWatcher(manager: manager)
      let first = Channel("mixed-first", manager: manager)
      let second = Channel("mixed-second", manager: manager)
      try await waitUntil { watcher.channels.count == 2 }
      watcher[enabled: first.id] = true

      #expect(watcher.anyEnabled == true)
      #expect(watcher.allEnabled == false)
      watcher.anyEnabled = false
      #expect(first.enabled == true)
      #expect(second.enabled == false)
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

      watcher[enabled: first.id] = true
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

    /// Built-in labels resolve from LoggerUI's own string catalog, not to their keys.
    @Test
    func builtInLabelsAreLocalized() {
      #expect(String(localized: .allChannels) == "All Channels")
      #expect(String(localized: .resetChannels) == "Reset to Defaults")
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

  /// Channel actions that record the changes requested of them.
  @MainActor
  private final class RecordingActions: ChannelActions {
    /// Changes requested so far, in order.
    private(set) var requests: [Request] = []

    /// Records a single-channel request.
    func setEnabled(_ isEnabled: Bool, for id: Channel.ID) {
      requests.append(.channel(id, isEnabled))
    }

    /// Records an all-channels request.
    func setAllEnabled(_ isEnabled: Bool) {
      requests.append(.all(isEnabled))
    }

    /// Records a reset request.
    func resetToDefaults() {
      requests.append(.reset)
    }
  }

  extension RecordingActions {
    /// A recorded change request.
    enum Request: Equatable {
      /// A request for one channel.
      case channel(Channel.ID, Bool)

      /// A request for every channel.
      case all(Bool)

      /// A request to reset every channel.
      case reset
    }
  }
#endif
