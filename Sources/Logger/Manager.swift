// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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

  let settings: ManagerSettings
  private var channels: Channels = []
  private var changedChannels: Channels?
  nonisolated(unsafe) var fatalHandler: FatalHandler = defaultFatalHandler

  public enum Event {
    case started
    case shutdown
    case channelAdded
    case channelStarted
    case channelShutdown
  }

  /// Stream of manager events. Clients can watch this if they are
  /// interested in changes to the state of channels. When this stream
  /// ends, the manager has shut down, along with all channels.
  public let events: AsyncStream<Event>

  /// Private continuation used to yield events to the stream.
  private let eventSender: AsyncStream<Event>.Continuation

  /**
     An array of the names of the log channels
     that were persistently enabled - either in the settings
     or on the command line.
     */

  let channelsEnabledInSettings: Set<Channel.ID>

  public init(settings: ManagerSettings) {
    self.settings = settings
    let enabled = settings.enabledChannelIDs
    self.channelsEnabledInSettings = enabled
    var c: AsyncStream<Event>.Continuation? = nil
    let s = AsyncStream<Event> { continuation in
      c = continuation
    }
    self.events = s
    self.eventSender = c!

    logStartup(channels: enabled)
  }

  /// Initiate a shutdown of the manager.
  public func shutdown() async {
    for channel in channels {
      await channel.shutdown()
    }
    eventSender.yield(.shutdown)
    eventSender.finish()
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
    #if os(macOS) || os(iOS)
      return OSLogHandler()
    #else
      return stdoutHandler  // TODO: should perhaps be stderr instead?
    #endif
  }

  public static let defaultHandler = initDefaultHandler()

  /// Initialise the default log manager.
  static func initDefaultManager() -> Self {
    #if !os(Linux)
      /// We really do want there to only be a single instance of this, even if the logger library has mistakenly been
      /// linked multiple times, so we store it in the thread dictionary for the main thread, and retrieve it from there if necessary
      if let manager = Thread.main.threadDictionary["Logger.Manager"] {
        return unsafeBitCast(manager as AnyObject, to: Self.self)  // a normal cast might fail here if the code has been linked multiple times, since the class could be different (but identical)
      }
    #endif

    let manager = Self(settings: UserDefaultsManagerSettings(defaults: UserDefaults.standard))

    #if !os(Linux)
      Thread.main.threadDictionary["Logger.Manager"] = manager
    #endif

    return manager
  }

  nonisolated func logStartup(channels: Set<String>) {
    if let mode = ProcessInfo.processInfo.environment["LoggerDebug"], mode == "1" {
      #if DEBUG
        let mode = "debug"
      #else
        let mode = "release"
      #endif
      print("\nLogger running in \(mode) mode.")
      print(
        channels.isEmpty
          ? "All channels currently disabled.\n" : "Enabled log channels: \(channels)\n")
    }
    eventSender.yield(.started)
  }

  /**
         Pause until everything in the log queue has been logged.

         You shouldn't generally need to do this, but it's helpful if you
         need to ensure that all output reaches its destination before some
         action (exiting, for example).
     */

  public func flush() {
  }
}

// MARK: Fatal Error Handling

extension Manager {
  public typealias FatalHandler = (Any, Channel, StaticString, UInt) -> Never

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

  @discardableResult public func installFatalErrorHandler(_ handler: @escaping FatalHandler)
    -> FatalHandler
  {
    let previous = fatalHandler
    fatalHandler = handler
    return previous
  }

  /**
     Restore the default fatal error handler.
     */

  public func resetFatalErrorHandler() {
    fatalHandler = Manager.defaultFatalHandler
  }
}

extension Manager {
  func register(channel: Channel) {
    channels.insert(channel)
    eventSender.yield(.channelAdded)
  }
}
