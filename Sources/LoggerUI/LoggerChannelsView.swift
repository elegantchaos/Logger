// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// //  Created by Sam Deane on 20/01/2021.
// //  All code (c) 2021 - present day, Elegant Chaos Limited.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger
  import SwiftUI

  /// Observable main-actor adapter that exposes logger channels as SwiftUI-friendly value snapshots.
  @MainActor @Observable public class ChannelWatcher {
    /// Immutable snapshot for one logger channel row.
    public struct Entry: Identifiable {
      /// Stable channel identifier used for diffing and bindings.
      public let id: Channel.ID

      /// Display name shown in the UI.
      public let name: String

      /// Whether the channel is currently enabled.
      public var isEnabled: Bool

      /// Backing channel to update when the UI toggles this row.
      let channel: Channel

      /// Creates a value snapshot from a logger channel.
      init(channel: Channel) {
        self.id = channel.id
        self.name = channel.name
        self.isEnabled = channel.enabled
        self.channel = channel
      }
    }

    /// Sorted list of channel snapshots to display.
    public private(set) var channels: [Entry] = []

    /// The logger manager used to retrieve the channels.
    @ObservationIgnored let manager: Logger.Manager

    /// Long-lived task that keeps the snapshots in sync with manager events.
    @ObservationIgnored private var watchTask: Task<Void, Never>?

    /// Create with the specified logger manager,
    /// and start watching for changes.
    public init(manager: Logger.Manager = .shared) {
      self.manager = manager
      watchChannels()
    }

    deinit {
      watchTask?.cancel()
    }

    /// Refreshes the channel snapshots from the manager, sorted by channel name.
    public func updateChannels() async {
      channels = await manager.channels
        .sorted { $0.name < $1.name }
        .map(Entry.init(channel:))
    }

    /// Starts a long-lived task that mirrors manager channel events into snapshots.
    public func watchChannels() {
      watchTask?.cancel()
      watchTask = Task { [weak self] in
        guard let self else { return }
        await updateChannels()

        for await event in await manager.events {
          guard !Task.isCancelled else { return }
          switch event {
          case .channelAdded, .channelUpdated:
            await updateChannels()
          default:
            break
          }
        }
      }
    }

    /// Whether every channel snapshot is currently enabled.
    public var allEnabled: Bool {
      get { channels.allSatisfy(\.isEnabled) }
      set {
        channels = channels.map { entry in
          var updated = entry
          updated.isEnabled = newValue
          return updated
        }

        let channelsToUpdate = channels.map(\.channel)
        Task {
          for channel in channelsToUpdate {
            channel.enabled = newValue
          }
        }
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

    /// Updates one channel snapshot and forwards the same state to the backing channel.
    public func setEnabled(_ isEnabled: Bool, for entryID: Entry.ID) {
      guard let index = channels.firstIndex(where: { $0.id == entryID }) else { return }

      let channel = channels[index].channel
      var updated = channels
      updated[index].isEnabled = isEnabled
      channels = updated

      Task {
        channel.enabled = isEnabled
      }
    }
  }

  public struct AllChannelsToggleView: View {
    let channels: ChannelWatcher

    public var body: some View {
      Self._printChanges()

      return Toggle(
        "All Channels",
        isOn: Binding(
          get: { channels.allEnabled },
          set: { channels.allEnabled = $0 }
        )
      )
    }
  }

  public struct ChannelToggleView: View {
    let channels: ChannelWatcher
    let channel: ChannelWatcher.Entry

    public var body: some View {
      return Toggle(
        channel.name,
        isOn: channels.binding(for: channel.id)
      )
    }
  }

  public struct IndividualChannelsToggleView: View {
    let channels: ChannelWatcher

    public var body: some View {
      Self._printChanges()

      return VStack {
        ForEach(channels.channels) { channel in
          ChannelToggleView(channels: channels, channel: channel)
        }
      }
    }
  }

  public struct LoggerChannelsView: View {
    let watcher: ChannelWatcher
    let label: LocalizedStringResource

    /// Create a new view with the specified logger manager.
    public init(label: LocalizedStringResource = "Log Channels", manager: Logger.Manager = .shared) {
      self.label = label
      self.watcher = ChannelWatcher(manager: manager)
    }

    public var body: some View {
      Section(header: HStack {
        Text(label)
        Spacer()
        AllChannelsToggleView(channels: watcher)
          .labelsHidden()
      }) {
        IndividualChannelsToggleView(channels: watcher)
      }
    }
  }

#endif
