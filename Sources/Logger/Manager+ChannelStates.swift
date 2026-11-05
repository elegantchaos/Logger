// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

extension Manager {
  /// Applies enabled states to registered channels.
  ///
  /// Identifiers without a registered channel are ignored. Each changed channel emits
  /// `Event.channelUpdated`, and the settings are saved once if anything changed.
  ///
  /// Returns the previous states of the channels that changed, which can be passed back
  /// to this method to restore them. This makes the result suitable for undo.
  @discardableResult
  public func setEnabled(_ states: ChannelStates) -> ChannelStates {
    var previous: ChannelStates = [:]
    for channel in channels {
      guard let isEnabled = states[channel.id] else { continue }
      let wasEnabled = channel.exchangeEnabled(isEnabled)
      if wasEnabled != isEnabled {
        previous[channel.id] = wasEnabled
        events.yield(.channelUpdated(channel))
      }
    }
    if !previous.isEmpty { saveChannelSettings() }
    return previous
  }

  /// Enables or disables every registered channel.
  ///
  /// Returns the previous states of the channels that changed.
  @discardableResult
  public func setAllEnabled(_ isEnabled: Bool) -> ChannelStates {
    setEnabled(ChannelStates(uniqueKeysWithValues: channels.map { ($0.id, isEnabled) }))
  }
}

extension Manager {
  /// Enabled states keyed by full channel identifier.
  public typealias ChannelStates = [Channel.ID: Bool]
}
