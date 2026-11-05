// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Testing

/// Tests channel enablement across identities and managers.
struct ChannelIdentityTests {
  /// Channels with one full ID and manager share changes, including late arrivals.
  @Test
  func sameIdentitySharesEnabledState() async {
    let manager = Manager(settings: TestSettings())
    let first = Channel("Example.Network", manager: manager)
    first.enabled = true
    let second = Channel("Example.Network", manager: manager)
    #expect(second.enabled == true)
    second.enabled = false
    #expect(first.enabled == false)
    let third = Channel("Example.Network", manager: manager)
    #expect(third.enabled == false)
    await manager.shutdown()
  }

  #if os(macOS) || os(Linux)
    /// Channels that share an identifier but declare different defaults fail an assertion.
    @Test
    func mismatchedDefaultsAssert() async {
      await #expect(processExitsWith: .failure) {
        let manager = Manager(settings: TestSettings())
        _ = Channel("Example.Mismatched", manager: manager)
        _ = Channel("Example.Mismatched", default: .enabled, manager: manager)
      }
    }
  #endif

  /// Different full identifiers and different managers do not share enablement.
  @Test
  func differentIdentitiesRemainIndependent() async {
    let manager = Manager(settings: TestSettings())
    let otherManager = Manager(settings: TestSettings())
    let first = Channel("One.Network", manager: manager)
    let otherSubsystem = Channel("Two.Network", manager: manager)
    let otherOwner = Channel("One.Network", manager: otherManager)
    first.enabled = true
    #expect(otherSubsystem.enabled == false)
    #expect(otherOwner.enabled == false)
    await manager.shutdown()
    await otherManager.shutdown()
  }
}
