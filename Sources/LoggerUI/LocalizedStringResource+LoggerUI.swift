// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Foundation

  extension LocalizedStringResource {
    /// Label for controls that affect every channel.
    static var allChannels: LocalizedStringResource {
      LocalizedStringResource("channels.all", bundle: .atURL(Bundle.module.bundleURL))
    }

    /// Label for the button that returns every channel to its default state.
    static var resetChannels: LocalizedStringResource {
      LocalizedStringResource("channels.reset", bundle: .atURL(Bundle.module.bundleURL))
    }
  }

#endif
