// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Protocol for reading/writing settings store by the manager.
///
/// This is generalised into a protocol mostly to make it easier to
/// inject settings during testing.

public protocol ManagerSettings {
  /// The identifiers of the channels that should be enabled.
  var enabledChannelIDs: Set<Channel.ID> { get }

  /// Store the identifiers of the channels that should be enabled.
  func saveEnabledChannelIDs(_ ids: Set<Channel.ID>)

  /// Strip any settings-related command line arguments.
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String]
}

extension ManagerSettings {
  /// Save registered channel states while preserving choices for unregistered channels.
  public func saveEnabledChannels(_ channels: Manager.Channels) {
    var enabled = enabledChannelIDs
    for channel in channels {
      if channel.enabled {
        enabled.insert(channel.id)
      } else {
        enabled.remove(channel.id)
        enabled.remove(channel.name)
      }
    }
    saveEnabledChannelIDs(enabled)
  }
}
