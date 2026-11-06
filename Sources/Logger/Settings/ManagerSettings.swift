// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Reads and saves the channel states that a manager persists between runs.
///
/// The saved states record only channels whose state differs from their default, keyed by
/// full identifier or, for states supplied by hand or on the command line, by short name.
/// A full identifier takes precedence over a short name. This is a protocol mostly so that
/// tests can inject settings.
public protocol ManagerSettings {
  /// Saved states of channels that differ from their defaults.
  var channelStates: Manager.ChannelStates { get }

  /// Replaces the saved channel states.
  func saveChannelStates(_ states: Manager.ChannelStates)

  /// Strip any settings-related command line arguments.
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String]
}

extension ManagerSettings {
  /// Saves the states of registered channels, keeping saved states for channels that have
  /// not registered.
  ///
  /// A channel at its default state has no saved state, so a later change to its default
  /// applies. A short-name state that disagrees with a registered channel is removed, since
  /// the channel's full identifier now records its state.
  public func saveChannelStates(for channels: Manager.Channels) {
    var states = channelStates
    for channel in channels {
      if let shortNameState = states[channel.name], shortNameState != channel.enabled {
        states[channel.name] = nil
      }
      let isEnabledByDefault = channel.defaultState == .enabled
      states[channel.id] = channel.enabled == isEnabledByDefault ? nil : channel.enabled
    }
    saveChannelStates(states)
  }
}
