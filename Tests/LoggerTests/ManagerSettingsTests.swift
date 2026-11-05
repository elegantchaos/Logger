// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Synchronization
import Testing

@testable import Logger

/// Tests persistence of channel states across manager lifetimes.
struct ManagerSettingsTests {
  /// With nothing saved, a channel starts in its default state.
  @Test(arguments: [Channel.State.enabled, .disabled])
  func channelStartsInDefaultState(_ state: Channel.State) async {
    let manager = Manager(settings: PersistedTestSettings([:]))
    let channel = Channel("com.example.default", default: state, manager: manager)
    #expect(channel.enabled == (state == .enabled))
    await manager.shutdown()
  }

  /// A saved full-identifier state takes precedence over a saved short-name state.
  @Test
  func fullIdentifierTakesPrecedenceOverShortName() async {
    let settings = PersistedTestSettings(["Network": true, "com.example.Network": false])
    let manager = Manager(settings: settings)
    let channel = Channel("com.example.Network", manager: manager)
    let other = Channel("com.other.Network", manager: manager)
    #expect(channel.enabled == false)
    #expect(other.enabled == true)
    await manager.shutdown()
  }

  /// Disabling a channel enabled by its short name removes the short-name state.
  @Test
  func disablingChannelRemovesShortNameSetting() async {
    let settings = PersistedTestSettings(["disabled": true, "later": true])
    let manager = Manager(settings: settings)
    let channel = await registeredChannel("com.example.disabled", manager: manager)
    channel.enabled = false
    await manager.saveChannelSettings()
    #expect(settings.channelStates == ["later": true])
    await manager.shutdown()

    let restarted = Manager(settings: settings)
    let restored = Channel("com.example.disabled", manager: restarted)
    #expect(restored.enabled == false)
    restored.shutdown()
  }

  /// Saving keeps the saved states of channels that have not yet registered.
  @Test
  func savesStatesWithoutLosingUnregisteredChoices() async {
    let settings = PersistedTestSettings([
      "com.example.later": true, "com.example.disabled": true,
    ])
    let manager = Manager(settings: settings)
    let disabled = await registeredChannel("com.example.disabled", manager: manager)
    let enabled = await registeredChannel("com.example.enabled", manager: manager)
    disabled.enabled = false
    enabled.enabled = true
    await manager.saveChannelSettings()
    #expect(settings.channelStates == ["com.example.later": true, "com.example.enabled": true])
    await manager.shutdown()
  }

  /// A channel that is enabled by default stays disabled after a restart once disabled.
  @Test
  func disabledDefaultEnabledChannelStaysDisabled() async {
    let settings = PersistedTestSettings([:])
    let manager = Manager(settings: settings)
    let channel = await registeredChannel(
      "com.example.on", default: .enabled, manager: manager)
    channel.enabled = false
    await manager.saveChannelSettings()
    #expect(settings.channelStates == ["com.example.on": false])
    await manager.shutdown()

    let restarted = Manager(settings: settings)
    let restored = Channel("com.example.on", default: .enabled, manager: restarted)
    #expect(restored.enabled == false)
    restored.shutdown()
  }

  /// Returning a channel to its default state removes its saved state.
  @Test
  func returningToDefaultRemovesSavedState() async {
    let settings = PersistedTestSettings(["com.example.on": false])
    let manager = Manager(settings: settings)
    let channel = await registeredChannel(
      "com.example.on", default: .enabled, manager: manager)
    #expect(channel.enabled == false)
    channel.enabled = true
    await manager.saveChannelSettings()
    #expect(settings.channelStates.isEmpty)
    await manager.shutdown()
  }

  /// Creates a channel and waits until the manager has registered it.
  private func registeredChannel(
    _ name: String, default state: Channel.State = .disabled, manager: Manager
  ) async -> Channel {
    var events = await manager.events.makeAsyncIterator()
    let channel = Channel(name, default: state, manager: manager)
    while let event = await events.next() {
      if case .channelAdded(let added) = event, added === channel { break }
    }
    return channel
  }
}

/// A thread-safe in-memory settings store shared by successive managers.
private final class PersistedTestSettings: ManagerSettings, Sendable {
  /// Stored channel states.
  private let states: Mutex<Manager.ChannelStates>

  /// Creates a store containing the supplied states.
  init(_ states: Manager.ChannelStates) { self.states = Mutex(states) }

  /// The current stored states.
  var channelStates: Manager.ChannelStates { states.withLock { $0 } }

  /// Replaces the stored states.
  func saveChannelStates(_ states: Manager.ChannelStates) { self.states.withLock { $0 = states } }

  /// Leaves command-line arguments unchanged.
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] { arguments }
}
