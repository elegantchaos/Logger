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

    #expect(settings.saved == [channel.id])
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

/// Settings that record the most recently saved identifiers.
private final class RecordingSettings: ManagerSettings, Sendable {
  /// Identifiers passed to the most recent save.
  private let savedIDs = Mutex<Set<Channel.ID>?>(nil)

  /// Identifiers passed to the most recent save, if any.
  var saved: Set<Channel.ID>? { savedIDs.withLock { $0 } }

  /// No channels start enabled.
  var enabledChannelIDs: Set<Channel.ID> { [] }

  /// Records the saved identifiers.
  func saveEnabledChannelIDs(_ ids: Set<Channel.ID>) {
    savedIDs.withLock { $0 = ids }
  }

  /// Leaves arguments unchanged.
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] {
    arguments
  }
}
