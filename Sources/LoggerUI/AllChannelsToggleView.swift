// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)
  import SwiftUI

  /// Toggle that controls a collection of channels and displays a mixed state.
  public struct AllChannelsToggleView: View {
    /// Bindings to each channel's enabled state.
    private let sources: [Binding<Bool>]

    /// Toggle label.
    private let label: LocalizedStringResource

    /// Creates a master toggle that directly updates the watcher.
    public init(label: LocalizedStringResource = "All Channels", watcher: ChannelWatcher) {
      self.init(label: label, sources: watcher.channels.map { watcher.binding(for: $0.id) })
    }

    /// Creates a master toggle using host-supplied bindings.
    public init(label: LocalizedStringResource = "All Channels", sources: [Binding<Bool>]) {
      self.label = label
      self.sources = sources
    }

    /// Renders the aggregate toggle, disabling it when there are no channels.
    public var body: some View {
      Toggle(sources: sources, isOn: \.self) {
        Text(label)
      }
      .disabled(sources.isEmpty)
    }
  }
#endif
