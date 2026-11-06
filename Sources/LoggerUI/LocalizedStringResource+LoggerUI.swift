// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Foundation

  /// LoggerUI's built-in labels, looked up in the package's string catalog.
  ///
  /// Each has an English default value, because toolchains that do not compile string
  /// catalogs bundle the catalog unprocessed, and the lookup would otherwise return the key.
  extension LocalizedStringResource {
    /// Label for controls that affect every channel.
    static var allChannels: LocalizedStringResource {
      LocalizedStringResource(
        "channels.all", defaultValue: "All Channels", bundle: .atURL(Bundle.module.bundleURL))
    }

    /// Label for the button that returns every channel to its default state.
    static var resetChannels: LocalizedStringResource {
      LocalizedStringResource(
        "channels.reset", defaultValue: "Reset to Defaults",
        bundle: .atURL(Bundle.module.bundleURL))
    }
  }

#endif
