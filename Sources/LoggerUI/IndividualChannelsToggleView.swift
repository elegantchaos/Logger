// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)
  import SwiftUI

  /// One toggle per channel, for use in a list, form or menu.
  public struct IndividualChannelsToggleView: View {
    /// Watcher that supplies the channels and applies their changes.
    @Bindable private var watcher: ChannelWatcher

    /// Creates toggles for the watcher's channels.
    public init(watcher: ChannelWatcher) {
      self._watcher = Bindable(watcher)
    }

    /// Renders a toggle for each channel.
    public var body: some View {
      ForEach(watcher.channels) { entry in
        Toggle(entry.displayName, isOn: $watcher[enabled: entry.id])
      }
    }
  }

  #Preview("Individual Channels") {
    @Previewable @State var watcher = ChannelWatcher.preview
    Form {
      IndividualChannelsToggleView(watcher: watcher)
    }
  }
#endif
