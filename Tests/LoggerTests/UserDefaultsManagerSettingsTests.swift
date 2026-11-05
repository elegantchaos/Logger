// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Testing

@testable import Logger

/// Tests saving channel states in user defaults and applying command-line modifiers.
struct UserDefaultsManagerSettingsTests {
  /// Modifiers enable, disable or reset the saved states.
  @Test(arguments: [
    (["x": true], "", ["x": true]),
    ([:], "a,+b,-c", ["a": true, "b": true, "c": false]),
    (["x": true, "a": false], "+a", ["x": true, "a": true]),
    (["x": true], "=a,-b", ["a": true, "b": false]),
  ])
  func modifiersUpdateStates(
    saved: Manager.ChannelStates, modifiers: String, expected: Manager.ChannelStates
  ) {
    let updated = UserDefaultsManagerSettings.updateStates(saved, applyingModifiers: modifiers)
    #expect(updated == expected)
  }

  /// Modifiers in the defaults are applied and saved when the settings are created, then
  /// cleared so that they apply once.
  @Test
  func commandLineModifiersAreSavedOnce() throws {
    let suite = "UserDefaultsManagerSettingsTests-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    defaults.set("+a,-b", forKey: "logs")

    let settings = UserDefaultsManagerSettings(defaults: defaults)

    #expect(settings.channelStates == ["a": true, "b": false])
    #expect(
      UserDefaultsManagerSettings(defaults: defaults).channelStates == ["a": true, "b": false])
  }
}
