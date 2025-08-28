// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// //  Created by Sam Deane on 20/01/2021.
// //  All code (c) 2021 - present day, Elegant Chaos Limited.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger
  import SwiftUI

  public struct LoggerChannelsView: View {
    /// The channels to display in the view.
    @State var channels: [BoxedChannel] = []

    /// The logger manager used to retrieve the channels.
    var manager: Logger.Manager

    /// Create a new view with the specified logger manager.
    public init(manager: Logger.Manager = .shared) {
      self.manager = manager
    }

    public var body: some View {
      trace()

      return List {
        Section(header: Text("Global")) {
          Toggle(
            "All Channels",
            isOn: Binding<Bool>(
              get: { allChannelsEnabled },
              set: { value in setAllChannelsEnabled(value) }
            )
          ).toggleStyle(.switch)
        }

        Section(header: Text("Channels")) {
          ForEach(channels) { channel in
            Toggle(channel.name, isOn: channel.enabledBinding)
              .toggleStyle(.switch)
          }
        }
      }
      .onAppear(perform: watchChannels)
    }

    /// Update the list of channels from the manager.
    ///
    /// We sort the channels by name.
    @MainActor func updateChannels() async {
      channels = Array(
        await manager.channels
          .map { BoxedChannel(channel: $0) }
          .sorted { $0.name < $1.name }
      )
      print(channels.map { $0.name })
    }

    /// Are all the channels enabled?
    @MainActor var allChannelsEnabled: Bool { channels.allSatisfy { $0.enabled } }

    /// Enable/disable all channels.
    @MainActor func setAllChannelsEnabled(_ enabled: Bool) {
      Task {
        for var channel in channels {
          channel.enabled = enabled
        }
      }
    }

    /// Update once to set the initial channel list,
    /// then watch for changes.
    func watchChannels() {
      Task {
        await updateChannels()

        for await event in await manager.events {
          print(event)
          switch event {
          case .channelAdded, .channelUpdated:
            await updateChannels()
          default:
            break
          }
        }

        print("finished watching")
      }
    }

  }

  /// A boxed version of a channel, used to make it identifiable
  struct BoxedChannel: Identifiable {
    private let channel: Channel

    init(channel: Channel) {
      self.channel = channel
    }

    var name: String { channel.name }

    var enabledBinding: Binding<Bool> {
      Binding<Bool>(
        get: { channel.enabled },
        set: { newValue in Task { channel.enabled = newValue } }
      )
    }

    var enabled: Bool {
      get { channel.enabled }
      mutating set { channel.enabled = newValue }
    }

    var id: String { channel.id }
  }

  extension View {
    func trace() {
      if #available(macOS 12.0, iOS 15.0, *) {
        Self._printChanges()
      }
    }
  }

#endif
