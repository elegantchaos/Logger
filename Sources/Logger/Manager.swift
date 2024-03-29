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

public class Manager {
    typealias AssociatedChannelData = [Channel: Any]
    typealias AssociatedHandlerData = [Handler: AssociatedChannelData]

    public static let channelsUpdatedNotification = NSNotification.Name(rawValue: "com.elegantchaos.logger.channels.updated")

    let settings: ManagerSettings
    private var channels: [Channel] = []
    var associatedData: AssociatedHandlerData = [:]
    var fatalHandler: FatalHandler = defaultFatalHandler
    var queue: DispatchQueue = .init(label: "com.elegantchaos.logger", qos: .utility, attributes: [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit)
    
    /**
     An array of the names of the log channels
     that were persistently enabled - either in the settings
     or on the command line.
     */

    let channelsEnabledInSettings: Set<Channel.ID>

    required init(settings: ManagerSettings) {
        self.settings = settings
        self.channelsEnabledInSettings = settings.enabledChannelIDs
        logStartup()
    }

    /**
     Default log manager to use for channels if nothing else is specified.

     Under normal circumstances it makes sense for everything to share the same manager,
     which is why this exists.

     There are times (particularly testing) when we might want to use a different manager
     though, which is why it's not a true singleton.
     */

    public static let shared = initDefaultManager()

    /// Initialise the default log manager.
    static func initDefaultManager() -> Self {
        #if !os(Linux)
        /// We really do want there to only be a single instance of this, even if the logger library has mistakenly been
        /// linked multiple times, so we store it in the thread dictionary for the main thread, and retrieve it from there if necessary
        if let manager = Thread.main.threadDictionary["Logger.Manager"] {
            return unsafeBitCast(manager as AnyObject, to: Self.self) // a normal cast might fail here if the code has been linked multiple times, since the class could be different (but identical)
        }
        #endif
        
        let manager = Self(settings: UserDefaultsManagerSettings(defaults: UserDefaults.standard))
        
        #if !os(Linux)
            Thread.main.threadDictionary["Logger.Manager"] = manager
        #endif
        
        return manager
    }

    /**
     Return arbitrary data associated with a channel/handler pair.
     This provides handlers with a mechanism to use to store per-channel state.

     If no data is stored, the setter closure is called to provide it.
     */

    public func associatedData<T>(handler: Handler, channel: Channel, setter: () -> T) -> T {
        var handlerData = associatedData[handler]
        if handlerData == nil {
            handlerData = [:]
            associatedData[handler] = handlerData
        }

        var channelData = handlerData![channel] as? T
        if channelData == nil {
            channelData = setter()
            handlerData![channel] = channelData
        }

        return channelData!
    }

    func logStartup() {
        if let mode = ProcessInfo.processInfo.environment["LoggerDebug"], mode == "1" {
            #if DEBUG
            let mode = "debug"
            #else
            let mode = "release"
            #endif
            print("\nLogger running in \(mode) mode.")
            let channels = enabledChannels
            print(channels.isEmpty ? "All channels currently disabled.\n" : "Enabled log channels: \(channels)\n")
        }
    }

    /**
         Pause until everything in the log queue has been logged.

         You shouldn't generally need to do this, but it's helpful if you
         need to ensure that all output reaches its destination before some
         action (exiting, for example).
     */

    public func flush() {
        queue.sync {
            // do nothing
        }
    }
}

// MARK: Fatal Error Handling

public extension Manager {
    typealias FatalHandler = (Any, Channel, StaticString, UInt) -> Never

    /**
     Default handler when a channel is sent a fatal error.

     Just calls the system's fatal error function and exits.
     */

    static func defaultFatalHandler(_ message: Any, channel: Channel, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("Channel \(channel.name) was sent fatal message.\n\(message)", file: file, line: line)
    }

    /**
     Install a custom handler for fatal errors.
     */

    @discardableResult func installFatalErrorHandler(_ handler: @escaping FatalHandler) -> FatalHandler {
        let previous = fatalHandler
        fatalHandler = handler
        return previous
    }

    /**
     Restore the default fatal error handler.
     */

    func resetFatalErrorHandler() {
        fatalHandler = Manager.defaultFatalHandler
    }
}

// MARK: Channels

public extension Manager {
    /**
      Add to our list of registered channels.
     */

    internal func register(channel: Channel) {
        queue.async {
            self.channels.append(channel)
            #if os(macOS) || os(iOS)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Manager.channelsUpdatedNotification, object: self)
            }
            #endif
        }
    }

    /**
     All the channels registered with the manager.

     Channels get registered when they're first used,
     which may not necessarily be when the application first runs.
     */

    var registeredChannels: [Channel] {
        return queue.sync { channels }
    }

    var enabledChannels: [Channel] {
        return queue.sync { channels.filter(\.enabled) }
    }

    func channel(named name: String) -> Channel? {
        registeredChannels.first(where: { $0.name == name })
    }
}

extension Manager {
    /**
      Update the enabled/disabled state of one or more channels.
      The change is persisted in the settings, and will be restored
      next time the application runs.
     */

    public func update(channels: [Channel], state: Bool) {
        for channel in channels {
            channel.enabled = state
            let change = channel.enabled ? "enabled" : "disabled"
            print("Channel \(channel.name) \(change).")
        }

        saveChannelSettings()
    }

    /**
      Save the list of currently enabled channels.
     */

    func saveChannelSettings() {
        settings.saveEnabledChannels(enabledChannels)
    }
}
