// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// import Combine
// import Foundation

// @MainActor class ChannelsWatcher: Manager.LogObserver, ObservableObject {
//   var allChannels = Set<Channel>()
//   var enabledChannels = Set<Channel>()

//   /**
//       Update the enabled/disabled state of one or more channels.
//       The change is persisted in the settings, and will be restored
//       next time the application runs.
//      */

//   public func update(channels: [Channel], state: Bool) {
//     for channel in channels {
//       channel.enabled = state
//       let change = channel.enabled ? "enabled" : "disabled"
//       print("Channel \(channel.name) \(change).")
//     }

//     saveChannelSettings()
//     postChangeNotification()
//   }

//   func channelsUpdated(
//     _ channels: Manager.Channels, enabled: Manager.Channels, all: Manager.Channels
//   ) {
//     self.allChannels = all
//     self.enabledChannels = enabled
//   }

//   let manager: Manager

//   /**
//       Add to our list of registered channels.
//      */

//   internal func register(channel: Channel) {
//     channels.insert(channel)
//     scheduleNotification(for: channel)
//   }

//   /**
//      All the channels registered with the manager.

//      Channels get registered when they're first used,
//      which may not necessarily be when the application first runs.
//      */

//   public var registeredChannels: [Channel] {
//     channels  // TODO: expose a ObservableObject copy
//   }

//   /**
//      All the enabled channels.
//      */
//   public var enabledChannels: [Channel] {
//     return channels.filter { await $0.enabled }
//   }

//   /**
//      State of all channels together; useful for the debug UI.
//      */
//   public enum ChannelsState {
//     case allDisabled
//     case allEnabled
//     case mixed
//   }

//   /**
//      Current state of all channels.
//      */

//   public var channelsState: ChannelsState {
//     let registeredChannels = self.registeredChannels
//     let enabledCount = registeredChannels.filter(\.enabled).count
//     if enabledCount == registeredChannels.count {
//       return .allEnabled
//     } else if enabledCount == 0 {
//       return .allDisabled
//     } else {
//       return .mixed
//     }
//   }

//   /**
//      Returns a channel with a give name, if we have one.
//      */
//   public func channel(named name: String) -> Channel? {
//     registeredChannels.first(where: { $0.name == name })
//   }

// }
