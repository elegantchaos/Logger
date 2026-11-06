// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/04/2023.
//  All code (c) 2023 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import LoggerUI
import SwiftUI

/// Example channels that can be enabled independently in the settings view.
private let exampleChannels = [
  Channel("Example.General"),
  Channel("Example.Network"),
  Channel("Services.Network"),
]

/// Demonstrates the LoggerUI channel settings inside a list.
struct ContentView: View {
  /// Channel state shared with the menu.
  private let watcher: ChannelWatcher

  /// Creates the example channels before the settings view appears.
  init(watcher: ChannelWatcher) {
    self.watcher = watcher
    _ = exampleChannels
  }

  /// Displays channel settings and a button that logs to both channels.
  var body: some View {
    NavigationStack {
      List {
        LoggerChannelsView(watcher: watcher)
        Button("Log example messages", action: logMessages)
      }
      .navigationTitle("Logger Example")
    }
  }

  /// Sends one message through each example channel.
  private func logMessages() {
    for channel in exampleChannels {
      channel.log("Example message")
    }
  }
}

#Preview {
  ContentView(watcher: ChannelWatcher())
}
