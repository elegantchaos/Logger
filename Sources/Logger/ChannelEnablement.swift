// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Synchronization

/// Shared, synchronous enablement for channels with one manager and identifier.
final class ChannelEnablement: Sendable {
  /// The current enabled state, accessed atomically by logging callers.
  let value: Atomic<Bool>

  /// Creates the state with its first channel's initial value.
  init(_ enabled: Bool) {
    self.value = Atomic(enabled)
  }
}
