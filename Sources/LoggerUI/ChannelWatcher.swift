// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger
  import SwiftUI

  /// Observable main-actor model that exposes a manager's channels to SwiftUI.
  ///
  /// The watcher mirrors the manager's registered channels as sorted `Entry` snapshots,
  /// refreshing them whenever the manager emits an event. `Channel` actors do not take
  /// part in SwiftUI observation, so views read these snapshots instead.
  ///
  /// Views bind to `self[enabled:]` and `allEnabled` through `@Bindable`. By default,
  /// writes change the channels directly and update the snapshots at once. When the
  /// watcher has `ChannelActions`, writes are passed to them instead, and the snapshots
  /// change when the manager reports the result. Share one watcher between the surfaces
  /// that show the same channels, such as a settings list and a menu.
  @MainActor @Observable public final class ChannelWatcher {
    /// Sorted list of channel snapshots to display.
    public private(set) var channels: [Entry] = []

    /// The logger manager used to retrieve the channels.
    @ObservationIgnored private let manager: Logger.Manager

    /// Host actions for channel changes, or nil to change channels directly.
    @ObservationIgnored private let actions: (any ChannelActions)?

    /// Long-lived task that keeps the snapshots in sync with manager events.
    @ObservationIgnored private var watchTask: Task<Void, Never>?

    /// Creates a watcher for a manager and starts mirroring its events.
    ///
    /// Pass `actions` to route channel changes through the host app.
    public init(manager: Logger.Manager = .shared, actions: (any ChannelActions)? = nil) {
      self.manager = manager
      self.actions = actions
      watchChannels()
    }

    /// Cancels the long-lived manager event task.
    deinit {
      watchTask?.cancel()
    }

    /// Whether every channel is enabled. Setting it enables or disables every channel.
    public var allEnabled: Bool {
      get { !channels.isEmpty && channels.allSatisfy(\.isEnabled) }
      set { setAllEnabled(newValue) }
    }

    /// Whether any channel is enabled.
    ///
    /// Writing has no effect. The master toggle binds to this and `allEnabled` so that it
    /// can show a mixed state, and SwiftUI writes the new value to both; only the
    /// `allEnabled` write acts, so one click makes one change.
    var anyEnabled: Bool {
      get { channels.contains(where: \.isEnabled) }
      set {}
    }

    /// Whether the channel with the given identifier is enabled.
    ///
    /// Setting it enables or disables that channel. Bind a toggle to it with
    /// `$watcher[enabled: id]`.
    public subscript(enabled id: Channel.ID) -> Bool {
      get { channels.first { $0.id == id }?.isEnabled ?? false }
      set { setEnabled(newValue, for: id) }
    }

    /// Enables or disables the channel with the given identifier, through the actions if
    /// there are any.
    public func setEnabled(_ isEnabled: Bool, for id: Channel.ID) {
      if let actions {
        actions.setEnabled(isEnabled, for: id)
      } else if let entry = channels.first(where: { $0.id == id }) {
        entry.channel.enabled = isEnabled
        refreshStates()
      }
    }

    /// Enables or disables every channel, through the actions if there are any.
    public func setAllEnabled(_ isEnabled: Bool) {
      if let actions {
        actions.setAllEnabled(isEnabled)
      } else {
        for entry in channels {
          entry.channel.enabled = isEnabled
        }
        refreshStates()
      }
    }

    /// Re-reads each snapshot's enabled state from its channel.
    private func refreshStates() {
      channels = channels.map { $0.refreshed() }
    }

    /// Refreshes the channel snapshots from the manager, sorted by channel name.
    private func updateChannels() async {
      let registered = await manager.channels
      let names = Dictionary(grouping: registered, by: \.name)
      channels =
        registered
        .sorted { ($0.name, $0.id) < ($1.name, $1.id) }
        .map { Entry(channel: $0, disambiguate: (names[$0.name]?.count ?? 0) > 1) }
    }

    /// Starts a long-lived task that mirrors manager channel events into snapshots.
    private func watchChannels() {
      watchTask?.cancel()
      let manager = manager
      watchTask = Task { [weak self, manager] in
        var events = await manager.events.makeAsyncIterator()
        await self?.updateChannels()

        while await events.next() != nil {
          guard !Task.isCancelled else { return }
          await self?.updateChannels()
        }
      }
    }
  }

  extension ChannelWatcher {
    /// Immutable snapshot for one logger channel row.
    public struct Entry: Identifiable, Equatable {
      /// Stable channel identifier used for diffing and bindings.
      public let id: Channel.ID

      /// The channel's short name, without its subsystem.
      public let name: String

      /// Name shown to distinguish channels with the same short name.
      public let displayName: String

      /// Whether the channel was enabled when the snapshot was taken.
      public let isEnabled: Bool

      /// Backing channel that direct changes update.
      fileprivate let channel: Channel

      /// Creates a value snapshot from a logger channel.
      init(channel: Channel, disambiguate: Bool) {
        self.init(
          channel: channel,
          displayName: disambiguate ? channel.id : channel.name)
      }

      /// Creates a snapshot with an explicit display name.
      private init(channel: Channel, displayName: String) {
        self.id = channel.id
        self.name = channel.name
        self.displayName = displayName
        self.isEnabled = channel.enabled
        self.channel = channel
      }

      /// Returns a copy with the channel's current enabled state.
      fileprivate func refreshed() -> Entry {
        Entry(channel: channel, displayName: displayName)
      }

      /// Snapshots are equal when they show the same values; the channel is identified by `id`.
      public static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.id == rhs.id && lhs.displayName == rhs.displayName && lhs.isEnabled == rhs.isEnabled
      }
    }
  }

#endif
