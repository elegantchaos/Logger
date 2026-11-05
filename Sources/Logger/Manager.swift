// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Synchronization

/// The main controller in charge of the logging system.
/// This is typically a singleton, and in most cases should not need
/// to be accessed at all from client code.
///
/// If you do need to access the default instance - for example to
/// dynamically configure it, or introspect the list of channels,
/// you can access it with ``Manager.shared``.
///
/// Other instances can be created explicitly if necessary. This should
/// generally be unnecessary, but may be useful for testing purposes.
///
/// If you do create multiple instances, you should take care to decide
/// whether or not they should share a single settings object.

public actor Manager {
  /// A set of channels.
  public typealias Channels = Set<Channel>

  /// Enablement state keyed by full channel identifier for this manager.
  private nonisolated let channelEnablements = Mutex<[Channel.ID: ChannelEnablement]>([:])

  /// Settings that supply and store the enabled channel identifiers.
  let settings: ManagerSettings

  /// Channels that have registered with this manager.
  public var channels: Channels = []

  /// Channel tasks that have registered and not yet drained.
  private var runningChannels: [ObjectIdentifier: Channel] = [:]

  /// Whether manager shutdown has started.
  private var isShuttingDown = false

  /// Whether all registered channels have drained and events have ended.
  private var hasShutdown = false

  /// Callers waiting for shutdown to finish.
  private var shutdownWaiters: [CheckedContinuation<Void, Never>] = []

  /// Handler called when a channel is sent a fatal message, guarded so that any thread
  /// can read it.
  private nonisolated let fatalHandlerStorage = Mutex<FatalHandler>(Manager.defaultFatalHandler)

  /// Manager events.
  public enum Event: Sendable {
    /// The manager has started. Every subscriber receives this first.
    case started

    /// Shutdown has begun; channels are being stopped.
    case shuttingDown

    /// Every channel has drained. This is the last event.
    case shutdown

    /// A channel has registered.
    case channelAdded(Channel)

    /// A channel's enabled state has changed.
    case channelUpdated(Channel)

    /// A channel has started passing items to its handler.
    case channelStarted(Channel)

    /// A channel has stopped and drained.
    case channelShutdown(Channel)
  }

  /// Stream of manager events. Clients can watch this if they are
  /// interested in changes to the state of channels. When this stream
  /// ends, the manager has shut down, along with all channels. Each subscriber
  /// receives `.started` before subsequent events. Slow subscribers retain the
  /// 256 most recent events and may miss older ones.
  public let events: BroadcastSequence<Event>

  /// Channel states read from the settings when the manager was created.
  let savedChannelStates: ChannelStates

  /// Creates a manager that reads and saves channel states through the given settings.
  public init(settings: ManagerSettings) {
    self.settings = settings
    let saved = settings.channelStates
    self.savedChannelStates = saved
    self.events = BroadcastSequence(initial: .started)

    logStartup(saved: saved)
  }

  /// Returns the existing enablement for a channel identifier, or creates it once.
  ///
  /// A new enablement starts in the state saved for the identifier or, failing that, for
  /// its short name, or else in its default. Channels sharing an identifier must declare
  /// the same default.
  nonisolated func enablement(
    for id: Channel.ID, name: String, isEnabledByDefault: Bool
  ) -> ChannelEnablement {
    channelEnablements.withLock { enablements in
      if let existing = enablements[id] {
        assert(
          existing.isEnabledByDefault == isEnabledByDefault,
          "Channels with the identifier \(id) declare different default states.")
        return existing
      }
      let saved = savedChannelStates[id] ?? savedChannelStates[name]
      let enablement = ChannelEnablement(
        saved ?? isEnabledByDefault, isEnabledByDefault: isEnabledByDefault)
      enablements[id] = enablement
      return enablement
    }
  }

  /// Shut down registered channels, wait for their output to drain, and end events.
  public func shutdown() async {
    if hasShutdown { return }
    if !isShuttingDown {
      isShuttingDown = true
      events.yield(.shuttingDown)
      for channel in runningChannels.values {
        channel.shutdown()
      }
      finishShutdownIfPossible()
    }
    if !hasShutdown {
      await withCheckedContinuation { shutdownWaiters.append($0) }
    }
  }

  /// Finishes shutdown once every registered channel has drained.
  private func finishShutdownIfPossible() {
    guard isShuttingDown, !hasShutdown, runningChannels.isEmpty else { return }
    hasShutdown = true
    events.yield(.shutdown)
    events.finish()
    let waiters = shutdownWaiters
    shutdownWaiters.removeAll()
    for waiter in waiters { waiter.resume() }
  }

  /**
     Default log manager to use for channels if nothing else is specified.

     Under normal circumstances it makes sense for everything to share the same manager,
     which is why this exists.

     There are times (particularly testing) when we might want to use a different manager
     though, which is why it's not a true singleton.
     */

  public static let shared = initDefaultManager()

  /**
     Default handler to use for channels if nothing else is specified.

     On the Mac this is an OSLogHandler, which will log directly to the console without
     sending output to stdout/stderr.

     On Linux it is a PrintHandler which will log to stdout.
     */

  static func initDefaultHandler() -> Handler {
    #if os(macOS) || os(iOS) || os(watchOS)
      return OSLogHandler()
    #else
      return printHandler  // TODO: should perhaps be stderr instead?
    #endif
  }

  public static let defaultHandler = initDefaultHandler()

  /// Initialise the default log manager.
  static func initDefaultManager() -> Self {
    #if !os(Linux)
      /// We really do want there to only be a single instance of this, even if the logger library has mistakenly been
      /// linked multiple times, so we store it in the thread dictionary for the main thread, and retrieve it from there if necessary
      if let manager = Thread.main.threadDictionary["Logger.Manager"] {
        // A normal cast can fail if the library was linked more than once.
        return unsafeBitCast(manager as AnyObject, to: Self.self)
      }
    #endif

    let manager = Self(settings: UserDefaultsManagerSettings(defaults: UserDefaults.standard))

    #if !os(Linux)
      Thread.main.threadDictionary["Logger.Manager"] = manager
    #endif

    return manager
  }

  /// Prints the saved channel states when the `LoggerDebug` environment variable is `1`.
  nonisolated func logStartup(saved: ChannelStates) {
    if let mode = ProcessInfo.processInfo.environment["LoggerDebug"], mode == "1" {
      #if DEBUG
        let mode = "debug"
      #else
        let mode = "release"
      #endif
      print("\nLogger running in \(mode) mode.")
      print(
        saved.isEmpty
          ? "All channels are in their default states.\n" : "Saved channel states: \(saved)\n")
    }
  }

  /// Called to indicate that channel settings have changed.
  public func channelUpdated(_ channel: Channel) async {
    events.yield(.channelUpdated(channel))
    saveChannelSettings()
  }

  /// Save settings for all the channels.
  public func saveChannelSettings() {
    settings.saveChannelStates(for: channels)
  }
}

// MARK: Fatal Error Handling

extension Manager {
  /// Function called with a fatal message, its channel, and its source location.
  public typealias FatalHandler = @Sendable (Any, Channel, StaticString, UInt) -> Never

  /// The current fatal error handler.
  nonisolated var fatalHandler: FatalHandler {
    fatalHandlerStorage.withLock { $0 }
  }

  /**
     Default handler when a channel is sent a fatal error.

     Just calls the system's fatal error function and exits.
     */

  public static func defaultFatalHandler(
    _ message: Any, channel: Channel, file: StaticString = #file, line: UInt = #line
  ) -> Never {
    fatalError(
      "Channel \(channel.name) was sent fatal message.\n\(message)", file: file, line: line)
  }

  /**
     Install a custom handler for fatal errors.
     */

  @discardableResult public nonisolated func installFatalErrorHandler(
    _ handler: @escaping FatalHandler
  ) -> FatalHandler {
    fatalHandlerStorage.withLock { current in
      let previous = current
      current = handler
      return previous
    }
  }

  /**
     Restore the default fatal error handler.
     */

  public nonisolated func resetFatalErrorHandler() {
    fatalHandlerStorage.withLock { $0 = Manager.defaultFatalHandler }
  }
}

extension Manager {

  /// Run a channel.
  /// We emit a `Event.channelStarted` event,
  /// run the channel until it is done, then
  /// emit a `Event.channelShutdown` event.
  func run(channel: Channel) async {
    guard !isShuttingDown else {
      channel.shutdown()
      return
    }
    channels.insert(channel)
    runningChannels[ObjectIdentifier(channel)] = channel
    events.yield(.channelAdded(channel))
    events.yield(.channelStarted(channel))
    await channel.run()
    runningChannels.removeValue(forKey: ObjectIdentifier(channel))
    events.yield(.channelShutdown(channel))
    finishShutdownIfPossible()
  }

}
