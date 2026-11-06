// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/04/2023.
//  All code (c) 2023 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import LoggerUI
import SwiftUI

/// Standalone host for the LoggerUI example.
@main
struct SwiftUIExampleApp: App {
  /// Channel state shared between windows and the macOS menu.
  @State private var watcher = ChannelWatcher()

  /// The example's main window and channel menu.
  var body: some Scene {
    WindowGroup {
      ContentView(watcher: watcher)
    }
    #if os(macOS)
      .commands {
        CommandMenu("Debug") {
          Menu("Channels") {
            AllChannelsToggleView(watcher: watcher)
            Divider()
            IndividualChannelsToggleView(watcher: watcher)
            Divider()
            ResetChannelsButton(watcher: watcher)
          }
        }
      }
    #endif
  }
}
