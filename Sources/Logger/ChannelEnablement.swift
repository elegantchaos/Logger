// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Synchronization

/// Shared, synchronous enablement for channels with one manager and identifier.
final class ChannelEnablement: Sendable {
  /// The current enabled state, accessed atomically by logging callers.
  let value: Atomic<Bool>

  /// The state the channels have when nothing is saved for them.
  let isEnabledByDefault: Bool

  /// Creates the state with its initial value and its default.
  init(_ enabled: Bool, isEnabledByDefault: Bool) {
    self.value = Atomic(enabled)
    self.isEnabledByDefault = isEnabledByDefault
  }
}
