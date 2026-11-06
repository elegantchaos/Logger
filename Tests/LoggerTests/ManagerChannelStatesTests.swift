// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Synchronization
import Testing

/// Tests applying and restoring channel enabled states through a manager.
struct ManagerChannelStatesTests {
  /// Only channels whose state changes are reported, with their previous states.
  @Test
  func setEnabledReturnsPreviousStatesOfChangedChannels() async {
    let manager = Manager(settings: TestSettings())
    let (on, off) = await registeredChannels(["States.On", "States.Off"], manager: manager)
    on.enabled = true

    let previous = await manager.setEnabled([on.id: true, off.id: true])

    #expect(previous == [off.id: false])
    #expect(on.enabled == true)
    #expect(off.enabled == true)
    await manager.shutdown()
  }

  /// Identifiers without a registered channel are ignored.
  @Test
  func setEnabledIgnoresUnregisteredChannels() async {
    let manager = Manager(settings: TestSettings())
    let previous = await manager.setEnabled(["States.Missing": true])
    #expect(previous.isEmpty)
    await manager.shutdown()
  }

  /// Restoring the returned states undoes a bulk change from a mixed state, and returns
  /// the states needed to redo it.
  @Test
  func restoringPreviousStatesUndoesBulkChange() async {
    let manager = Manager(settings: TestSettings())
    let (first, second) = await registeredChannels(
      ["States.First", "States.Second"], manager: manager)
    first.enabled = true

    let undo = await manager.setAllEnabled(false)
    #expect(undo == [first.id: true])
    #expect(first.enabled == false)

    let redo = await manager.setEnabled(undo)
    #expect(redo == [first.id: false])
    #expect(first.enabled == true)
    #expect(second.enabled == false)
    await manager.shutdown()
  }

  /// Changed states are saved to the manager's settings.
  @Test
  func setEnabledSavesSettings() async {
    let settings = RecordingSettings()
    let manager = Manager(settings: settings)
    let (channel, _) = await registeredChannels(["States.Saved", "States.Other"], manager: manager)

    await manager.setEnabled([channel.id: true])

    #expect(settings.saved == [channel.id: true])
    await manager.shutdown()
  }

  /// Resetting returns channels to their defaults and reports what it changed.
  @Test
  func resetToDefaultsRestoresDefaultStates() async {
    let manager = Manager(settings: TestSettings())
    var events = await manager.events.makeAsyncIterator()
    let onByDefault = Channel("States.OnByDefault", default: .enabled, manager: manager)
    let offByDefault = Channel("States.OffByDefault", manager: manager)
    let untouched = Channel("States.Untouched", manager: manager)
    var added = 0
    while added < 3, let event = await events.next() {
      if case .channelAdded = event { added += 1 }
    }
    onByDefault.enabled = false
    offByDefault.enabled = true

    let previous = await manager.resetToDefaults()

    #expect(previous == [onByDefault.id: false, offByDefault.id: true])
    #expect(onByDefault.enabled == true)
    #expect(offByDefault.enabled == false)
    #expect(untouched.enabled == false)
    await manager.shutdown()
  }

  /// Creates channels and waits until the manager has registered them.
  private func registeredChannels(_ names: [String], manager: Manager) async -> (Channel, Channel) {
    var events = await manager.events.makeAsyncIterator()
    let channels = names.map { Channel($0, manager: manager) }
    var added = 0
    while added < channels.count, let event = await events.next() {
      if case .channelAdded = event { added += 1 }
    }
    return (channels[0], channels[1])
  }
}

/// Settings that record the most recently saved states.
private final class RecordingSettings: ManagerSettings, Sendable {
  /// States passed to the most recent save.
  private let savedStates = Mutex<Manager.ChannelStates?>(nil)

  /// States passed to the most recent save, if any.
  var saved: Manager.ChannelStates? { savedStates.withLock { $0 } }

  /// Nothing is saved initially.
  var channelStates: Manager.ChannelStates { [:] }

  /// Records the saved states.
  func saveChannelStates(_ states: Manager.ChannelStates) {
    savedStates.withLock { $0 = states }
  }

  /// Leaves arguments unchanged.
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] {
    arguments
  }
}
