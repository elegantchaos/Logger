// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger

  extension ChannelWatcher {
    /// Watcher for the shared manager with sample channels, one enabled, for previews.
    static var preview: ChannelWatcher {
      let general = Channel("Preview.General")
      general.enabled = true
      _ = Channel("Preview.Network")
      return ChannelWatcher()
    }
  }

#endif
