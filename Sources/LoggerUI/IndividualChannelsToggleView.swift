// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import SwiftUI

  /// Stack of per-channel toggles sourced from the watcher snapshots.
  public struct IndividualChannelsToggleView: View {
    /// Watcher that owns the channel snapshots.
    private let watcher: ChannelWatcher

    /// Creates the stack of row toggles for the supplied watcher.
    public init(watcher: ChannelWatcher) {
      self.watcher = watcher
    }

    /// Renders the list of per-channel toggles.
    public var body: some View {
      VStack {
        ForEach(watcher.channels) { entry in
          ChannelToggleView(watcher: watcher, entry: entry)
        }
      }
    }
  }

#endif
