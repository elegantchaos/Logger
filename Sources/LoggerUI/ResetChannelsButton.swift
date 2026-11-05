// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)
  import SwiftUI

  /// Button that returns every channel to its default state, disabled when they already are.
  public struct ResetChannelsButton: View {
    /// Watcher that supplies the channels and applies the reset.
    private let watcher: ChannelWatcher

    /// Button label.
    private let label: LocalizedStringResource

    /// Creates a reset button for the watcher's channels.
    public init(watcher: ChannelWatcher, label: LocalizedStringResource = "Reset to Defaults") {
      self.watcher = watcher
      self.label = label
    }

    /// Renders the button.
    public var body: some View {
      Button(action: reset) {
        Text(label)
      }
      .disabled(watcher.isAtDefaults)
    }

    /// Resets the channels.
    private func reset() {
      watcher.resetToDefaults()
    }
  }

  #Preview("Reset Channels") {
    @Previewable @State var watcher = ChannelWatcher.preview
    Form {
      IndividualChannelsToggleView(watcher: watcher)
      ResetChannelsButton(watcher: watcher)
    }
  }
#endif
