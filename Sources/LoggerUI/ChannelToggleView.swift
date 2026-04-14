// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import SwiftUI

  /// Toggle row for one channel snapshot.
  public struct ChannelToggleView: View {
    /// Watcher that owns the channel snapshots.
    private let watcher: ChannelWatcher

    /// Snapshot rendered by this row.
    private let entry: ChannelWatcher.Entry

    /// Creates a row toggle for the supplied watcher snapshot.
    public init(watcher: ChannelWatcher, entry: ChannelWatcher.Entry) {
      self.watcher = watcher
      self.entry = entry
    }

    /// Renders the row toggle for a single channel.
    public var body: some View {
      Toggle(isOn: watcher.binding(for: entry.id)) {
        Text(entry.name)
      }
    }
  }

#endif
