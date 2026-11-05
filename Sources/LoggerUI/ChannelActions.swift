// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/11/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

  import Logger

  /// Performs the channel changes requested by LoggerUI controls.
  ///
  /// Supply an implementation to `ChannelWatcher` when an app routes channel changes
  /// through its own action layer, such as commands that support undo. Each method should
  /// start the change and return; the watcher shows the result when the manager reports it.
  /// Implementations typically call `Manager.setEnabled(_:)` or `Manager.setAllEnabled(_:)`.
  @MainActor
  public protocol ChannelActions {
    /// Requests that the channel with the given identifier be enabled or disabled.
    func setEnabled(_ isEnabled: Bool, for id: Channel.ID)

    /// Requests that every channel be enabled or disabled.
    func setAllEnabled(_ isEnabled: Bool)
  }

#endif
