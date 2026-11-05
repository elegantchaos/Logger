// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)
  import SwiftUI

  /// Master toggle for every channel, showing a mixed state when only some are enabled.
  ///
  /// Choosing it when the channels are mixed or off enables them all; choosing it when
  /// they are all on disables them. Each choice makes one `setAllEnabled(_:)` change.
  public struct AllChannelsToggleView: View {
    /// Watcher that supplies the channels and applies their changes.
    @Bindable private var watcher: ChannelWatcher

    /// Toggle label.
    private let label: LocalizedStringResource

    /// Creates a master toggle for the watcher's channels, labelled "All Channels".
    public init(watcher: ChannelWatcher) {
      self.init(watcher: watcher, label: .allChannels)
    }

    /// Creates a master toggle for the watcher's channels with a custom label.
    public init(watcher: ChannelWatcher, label: LocalizedStringResource) {
      self._watcher = Bindable(watcher)
      self.label = label
    }

    /// Renders the master toggle, disabled when there are no channels.
    public var body: some View {
      Toggle(sources: [$watcher.anyEnabled, $watcher.allEnabled], isOn: \.self) {
        Text(label)
      }
      .disabled(watcher.channels.isEmpty)
    }
  }

  #Preview("All Channels") {
    @Previewable @State var watcher = ChannelWatcher.preview
    Form {
      AllChannelsToggleView(watcher: watcher)
      IndividualChannelsToggleView(watcher: watcher)
    }
  }
#endif
