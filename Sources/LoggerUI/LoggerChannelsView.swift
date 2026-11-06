// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/01/2021.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger
  import SwiftUI

  /// List or form section showing a master toggle in its header, a toggle per channel, and
  /// a button that resets the channels to their defaults.
  ///
  /// The host owns the `ChannelWatcher`, usually in `@State`, so that other surfaces such
  /// as a menu can share it.
  public struct LoggerChannelsView<Label: View>: View {
    /// Watcher that supplies the channels and applies their changes.
    private let watcher: ChannelWatcher

    /// Section title shown above the channel toggles.
    private let label: Label

    /// Creates a section for the watcher's channels with a custom title.
    public init(watcher: ChannelWatcher, @ViewBuilder label: () -> Label) {
      self.watcher = watcher
      self.label = label()
    }

    /// Creates a section for the watcher's channels, titled "All Channels".
    public init(watcher: ChannelWatcher) where Label == Text {
      self.init(watcher: watcher) { Text(.allChannels) }
    }

    /// Renders the channel section and its master toggle.
    public var body: some View {
      Section {
        IndividualChannelsToggleView(watcher: watcher)
        ResetChannelsButton(watcher: watcher)
      } header: {
        HStack {
          label
          Spacer()
          AllChannelsToggleView(watcher: watcher)
            .labelsHidden()
        }
      }
    }
  }

  #Preview("Logger Channels") {
    @Previewable @State var watcher = ChannelWatcher.preview
    Form {
      LoggerChannelsView(watcher: watcher)
    }
  }

#endif
