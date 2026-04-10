// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import SwiftUI

  /// Toggle that enables or disables every visible logging channel.
  public struct AllChannelsToggleView: View {
    /// Watcher that owns the channel snapshots.
    private let watcher: ChannelWatcher

    /// Creates the master toggle for the supplied watcher.
    public init(watcher: ChannelWatcher) {
      self.watcher = watcher
    }

    /// Renders the master toggle for all channels.
    public var body: some View {
      Toggle(
        "All Channels",
        isOn: Binding(
          get: { watcher.allEnabled },
          set: { watcher.allEnabled = $0 }
        )
      )
    }
  }

#endif
