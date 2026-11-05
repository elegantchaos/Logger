// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)
  import SwiftUI

  /// Toggle row for a channel, with a binding supplied by Logger or the host app.
  public struct ChannelToggleView: View {
    /// Channel label, including its subsystem when needed to disambiguate it.
    private let name: String

    /// The channel's enabled state and action.
    @Binding private var isEnabled: Bool

    /// Creates a toggle that directly updates the watcher.
    public init(watcher: ChannelWatcher, entry: ChannelWatcher.Entry) {
      self.init(entry: entry, isEnabled: watcher.binding(for: entry.id))
    }

    /// Creates a toggle with a host-supplied binding, such as one that dispatches a command.
    public init(entry: ChannelWatcher.Entry, isEnabled: Binding<Bool>) {
      self.name = entry.displayName
      self._isEnabled = isEnabled
    }

    /// Renders the channel toggle.
    public var body: some View {
      Toggle(name, isOn: $isEnabled)
    }
  }
#endif
