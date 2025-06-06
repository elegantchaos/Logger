// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// //  Created by Sam Deane on 20/01/2021.
// //  All code (c) 2021 - present day, Elegant Chaos Limited.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Combine
  import Logger
  import SwiftUI

  struct ChannelBox: Identifiable {
    let channel: Channel
    let name: String
    var enabled: Binding<Bool> {
      Binding<Bool>(
        get: { channel.enabled },
        set: { newValue in Task { channel.enabled = newValue } }
      )
    }

    var id: String { channel.id }
  }

  public struct LoggerChannelsView: View {
    @State var channels: [ChannelBox] = []
    var manager = Logger.Manager.shared

    public init() {
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
            Toggle(channel.name, isOn: channel.enabled)
              .toggleStyle(.switch)
          }
        }
      }
      .onAppear(perform: watchChannels)
    }

    @MainActor func updateChannels() async {
      channels = Array(
        await manager.channels
          .map { ChannelBox(channel: $0, name: $0.name) }
          .sorted { $0.name < $1.name }
      )
      print(channels.map { $0.name })
    }

    /// Are all the channels enabled?
    @MainActor var allChannelsEnabled: Bool { channels.allSatisfy { $0.channel.enabled } }

    /// Enable/disable all channels.
    @MainActor func setAllChannelsEnabled(_ enabled: Bool) {
      Task {
        for channel in channels {
          channel.channel.enabled = enabled
        }
      }
    }

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

  struct ChannelToggleView: View {
    var channel: Channel

    var body: some View {
    }
  }

#endif

extension View {
  func trace() {
    if #available(macOS 12.0, iOS 15.0, *) {
      Self._printChanges()
    }
  }
}
