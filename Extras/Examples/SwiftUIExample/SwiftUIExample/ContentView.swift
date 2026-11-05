// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/04/2023.
//  All code (c) 2023 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import LoggerUI
import SwiftUI

/// Example channels that can be enabled independently in the settings view.
private let exampleChannels = [Channel("Example.General"), Channel("Example.Network")]

/// Demonstrates the LoggerUI channel settings inside a list.
struct ContentView: View {
  /// Creates the example channels before the settings view appears.
  init() {
    _ = exampleChannels
  }

  /// Displays channel settings and a button that logs to both channels.
  var body: some View {
    NavigationStack {
      List {
        LoggerChannelsView()
        Button("Log example messages") {
          for channel in exampleChannels {
            channel.log("Example message")
          }
        }
      }
      .navigationTitle("Logger Example")
    }
  }
}

#Preview {
  ContentView()
}
