// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import SwiftUI

  /// Toggle that enables or disables every visible logging channel.
  public struct AllChannelsToggleView: View {
    /// The channel snapshots.
    private let channels: ChannelWatcher

    /// Toggle label
    private let label: LocalizedStringResource

    /// Creates the master toggle for the supplied watcher.
    public init(label: LocalizedStringResource = "All Channels", watcher: ChannelWatcher) {
      self.channels = watcher
      self.label = label
    }

    /// Renders the master toggle for all channels.
    public var body: some View {
      Toggle(
        label,
        isOn: Binding(
          get: { channels.allEnabled },
          set: { channels.allEnabled = $0 }
        )
      )
    }
  }

#endif
