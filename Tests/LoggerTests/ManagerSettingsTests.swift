// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Synchronization
import Testing

@testable import Logger

/// Tests persistence of enabled channels across manager lifetimes.
struct ManagerSettingsTests {
  /// A disabled channel no longer matches its legacy short-name setting.
  @Test
  func disablingChannelRemovesShortNameSetting() async {
    let settings = PersistedTestSettings(["disabled", "later"])
    let manager = Manager(settings: settings)
    var events = await manager.events.makeAsyncIterator()
    let channel = Channel("com.example.disabled", manager: manager)
    while let event = await events.next() {
      if case .channelAdded = event { break }
    }
    channel.enabled = false
    await manager.saveChannelSettings()
    #expect(settings.enabledChannelIDs == ["later"])
    await manager.shutdown()

    let restarted = Manager(settings: settings)
    let restored = Channel("com.example.disabled", manager: restarted)
    #expect(restored.enabled == false)
    restored.shutdown()
  }

  /// Saving changes preserves enabled channels that have not yet registered.
  @Test
  func savesEnabledChannelsWithoutLosingUnregisteredChoices() async throws {
    let settings = PersistedTestSettings(["com.example.later", "com.example.disabled"])
    let manager = Manager(settings: settings)
    var events = await manager.events.makeAsyncIterator()
    let disabled = Channel("com.example.disabled", manager: manager)
    let enabled = Channel("com.example.enabled", manager: manager)
    var registered = 0
    while registered < 2, let event = await events.next() {
      if case .channelAdded = event { registered += 1 }
    }
    disabled.enabled = false
    enabled.enabled = true
    await manager.saveChannelSettings()
    #expect(settings.enabledChannelIDs == ["com.example.later", "com.example.enabled"])
    await manager.shutdown()

    let restarted = Manager(settings: settings)
    let restoredDisabled = Channel("com.example.disabled", manager: restarted)
    let restoredEnabled = Channel("com.example.enabled", manager: restarted)
    let restoredLater = Channel("com.example.later", manager: restarted)
    #expect(restoredDisabled.enabled == false)
    #expect(restoredEnabled.enabled == true)
    #expect(restoredLater.enabled == true)
    restoredDisabled.shutdown()
    restoredEnabled.shutdown()
    restoredLater.shutdown()
  }
}

/// A thread-safe in-memory settings store shared by successive managers.
private final class PersistedTestSettings: ManagerSettings, Sendable {
  /// Stored enabled channel identifiers.
  private let ids: Mutex<Set<Channel.ID>>

  /// Creates a store containing the supplied identifiers.
  init(_ ids: Set<Channel.ID>) { self.ids = Mutex(ids) }

  /// The current stored identifiers.
  var enabledChannelIDs: Set<Channel.ID> { ids.withLock { $0 } }

  /// Replaces the stored identifiers.
  func saveEnabledChannelIDs(_ ids: Set<Channel.ID>) { self.ids.withLock { $0 = ids } }

  /// Leaves command-line arguments unchanged.
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] { arguments }
}
