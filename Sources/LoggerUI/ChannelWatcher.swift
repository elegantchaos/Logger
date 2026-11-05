// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger
  import SwiftUI

  /// Observable main-actor adapter that exposes logger channels as SwiftUI-friendly value snapshots.
  ///
  /// The watcher keeps SwiftUI bound to simple value state instead of directly observing
  /// the underlying `Channel` actors, which do not participate in SwiftUI observation.
  @MainActor @Observable public final class ChannelWatcher {
    /// Immutable snapshot for one logger channel row.
    public struct Entry: Identifiable {
      /// Stable channel identifier used for diffing and bindings.
      public let id: Channel.ID

      /// The channel's short name, without its subsystem.
      public let name: String

      /// Name shown to distinguish channels with the same short name.
      public let displayName: String

      /// Whether the channel is currently enabled.
      public var isEnabled: Bool

      /// Backing channel to update when the UI toggles this row.
      fileprivate let channel: Channel

      /// Creates a value snapshot from a logger channel.
      init(channel: Channel, disambiguate: Bool) {
        self.id = channel.id
        self.name = channel.name
        self.displayName = disambiguate ? channel.id : channel.name
        self.isEnabled = channel.enabled
        self.channel = channel
      }
    }

    /// Sorted list of channel snapshots to display.
    public private(set) var channels: [Entry] = []

    /// The logger manager used to retrieve the channels.
    @ObservationIgnored private let manager: Logger.Manager

    /// Long-lived task that keeps the snapshots in sync with manager events.
    @ObservationIgnored private var watchTask: Task<Void, Never>?

    /// Creates a watcher for the specified logger manager and starts mirroring its events.
    public init(manager: Logger.Manager = .shared) {
      self.manager = manager
      watchChannels()
    }

    /// Cancels the long-lived manager event task.
    deinit {
      watchTask?.cancel()
    }

    /// Whether every channel snapshot is currently enabled.
    public var allEnabled: Bool {
      get { !channels.isEmpty && channels.allSatisfy(\.isEnabled) }
      set { setAllEnabled(newValue) }
    }

    /// Enables or disables all currently registered channels.
    public func setAllEnabled(_ isEnabled: Bool) {
      channels = channels.map { entry in
        var updated = entry
        updated.isEnabled = isEnabled
        return updated
      }

      for entry in channels {
        entry.channel.enabled = isEnabled
      }
    }

    /// Returns a binding for the enabled state of the channel snapshot with the given identifier.
    public func binding(for entryID: Entry.ID) -> Binding<Bool> {
      Binding(
        get: { [weak self] in
          self?.channels.first(where: { $0.id == entryID })?.isEnabled ?? false
        },
        set: { [weak self] newValue in
          self?.setEnabled(newValue, for: entryID)
        }
      )
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

        while let event = await events.next() {
          guard !Task.isCancelled else { return }
          _ = event
          await self?.updateChannels()
        }
      }
    }

    /// Updates one channel snapshot and forwards the same state to the backing channel.
    public func setEnabled(_ isEnabled: Bool, for entryID: Entry.ID) {
      guard let index = channels.firstIndex(where: { $0.id == entryID }) else { return }

      let channel = channels[index].channel
      var updated = channels
      updated[index].isEnabled = isEnabled
      channels = updated

      channel.enabled = isEnabled
    }
  }

#endif
