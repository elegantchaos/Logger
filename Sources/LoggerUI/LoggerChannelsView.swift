// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/01/2021.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger
  import SwiftUI

  /// SwiftUI section that exposes the logger manager's channels as toggles.
  public struct LoggerChannelsView<Label: View>: View {
    /// Watcher that adapts logger channels for SwiftUI observation.
    @State private var watcher: ChannelWatcher

    /// Section title shown above the channel toggles.
    @ViewBuilder private let label: () -> Label

    /// Creates a new section backed by the specified logger manager.
    public init(@ViewBuilder label: @escaping () -> Label, manager: Logger.Manager = .shared) {
      self.label = label
      self._watcher = State(initialValue: ChannelWatcher(manager: manager))
    }

    /// Creates a new section backed by the specified logger manager.
    public init(manager: Logger.Manager = .shared) where Label == Text {
      self.label = { Text("All Channels") }
      self._watcher = State(initialValue: ChannelWatcher(manager: manager))
    }

    /// Renders the channel settings section and the master toggle.
    public var body: some View {
      Section(header: HStack {
        label()
        Spacer()
        AllChannelsToggleView(watcher: watcher)
          .labelsHidden()
      }) {
        IndividualChannelsToggleView(watcher: watcher)
      }
    }
  }

  #Preview("Logger Channels") {
    let manager = Logger.Manager.shared
    let general = Channel("Preview.General", manager: manager)
    let network = Channel("Preview.Network", manager: manager)
    general.enabled = true
    _ = network

    return Form {
      LoggerChannelsView(manager: manager)
    }
  }

#endif
