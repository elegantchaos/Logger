// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Manager {
    typealias AssociatedLoggerData = [Logger:Any]
    typealias AssociatedHandlerData = [Handler:AssociatedLoggerData]
    
    let defaults: UserDefaults
    var channels: [Logger] = []
    var associatedData: AssociatedHandlerData = [:]
    var fatalHandler: FatalHandler = defaultFatalHandler
    lazy var channelsEnabledInSettings: [String] = loadChannelSettings()

    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    /**
     Return arbitrary data associated with a channel/handler pair.
     This provides handlers with a mechanism to use to store per-channel state.
     
     If no data is stored, the setter closure is called to provide it.
     */
    
    public func associatedData<T>(handler: Handler, logger: Logger, setter: ()->T ) -> T {
        var handlerData = associatedData[handler]
        if handlerData == nil {
            handlerData = [:]
            associatedData[handler] = handlerData
        }
        
        var loggerData = handlerData![logger] as? T
        if loggerData == nil {
            loggerData = setter()
            handlerData![logger] = loggerData
        }
        
        return loggerData!
    }
    
    
    /**
     An array of the names of the log channels
     that were persistently enabled - either in the settings
     or on the command line.
     */
    
    func logStartup(enabledChannels: String) {
        #if DEBUG
        let mode = "debug"
        #else
        let mode = "release"
        #endif
        print("Logger running in \(mode) mode.")
        if enabledChannels.isEmpty {
            print("All channels currently disabled.\n")
        } else {
            print("Enabled log channels: \(enabledChannels)\n")
        }
    }
}

// MARK: Fatal Error Handling

extension Manager {
    
    public typealias FatalHandler = (Any, Logger, StaticString, UInt) -> Never
    
    
    /**
     Default handler when a channel is sent a fatal error.
     
     Just calls the system's fatal error function and exits.
     */
    
    static public func defaultFatalHandler(_ message: Any, logger: Logger, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("Channel \(logger.name) was sent fatal message.\n\(message)", file: file, line: line)
    }
    
    /**
     Install a custom handler for fatal errors.
     */
    
    @discardableResult public func installFatalErrorHandler(_ handler: @escaping FatalHandler) -> FatalHandler {
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

// MARK: Channels

extension Manager {
    func register(channel: Logger) {
        channels.append(channel)
    }
    
    /**
     All the channels registered with the manager.
     
     Channels get registered when they're first used,
     which may not necessarily be when the application first runs.
     */
    
    public var registeredChannels: [Logger] {
        get {
            return channels
        }
    }
    
    public var enabledChannels: [Logger] {
        return channels.filter { $0.enabled }
    }
    
}

// MARK: Settings

extension Manager {
    static let persistentLogsKey = "logs-persistent"
    static let logsKey = "logs"

    /**
        Calculate the list of enabled channels.
 
        This is determined by two settings: `logsKey` and `persistentLogsKey`,
        both of which contain comma-delimited strings.
 
        The persistentLogs setting contains the names of all the channels that were
        enabled last time. This is expected to be read from the user defaults.
 
        The logs setting contains overrides, and if present, is expected to have
        been supplied on the command line.
 
        Items in the overrides can be in two forms:
 
            - "name1,-name2,+name3": *modifies* the list by enabling/disabling named channels
            - "=name1,name2,name3": *resets* the list to the named channels
     
        Note that `+name` is a synonym for `name` in the first form - there just for symmetry.
        Note also that if any item in the list begins with `=`, the second form is used and the list is reset.
    */
 
    public func loadChannelSettings() -> [String] {
        var persistent = defaults.string(forKey: Manager.persistentLogsKey)?.split(separator: ",") ?? []
        let changes = defaults.string(forKey: Manager.logsKey)?.split(separator: ",") ?? []
        
        var onlyDeltas = true
        var newItems = [String.SubSequence]()
        for item in changes {
            var trimmed = item
            if let first = item.first {
                switch first {
                case "=":
                    trimmed.removeFirst()
                    newItems.append(trimmed)
                    onlyDeltas = false
                case "-":
                    trimmed.removeFirst()
                    if let index = persistent.firstIndex(of: trimmed) {
                        persistent.remove(at: index)
                    }
                case "+":
                    trimmed.removeFirst()
                    newItems.append(trimmed)
                default:
                    newItems.append(item)
                }
            }
        }
        
        if onlyDeltas {
            persistent.append(contentsOf: newItems)
        } else {
            persistent = newItems
        }
        
        let string = persistent.joined(separator: ",")
        let list = persistent.map { return String($0) }

        defaults.set(string, forKey: Manager.persistentLogsKey)
        defaults.set("", forKey: Manager.logsKey)
        logStartup(enabledChannels: string)
        
        return list
    }
    
    /**
     Update the enabled/disabled state of one or more channels.
     The change is persisted in the settings, and will be restored
     next time the application runs.
    */
    
    public func update(channels: [Logger], state: Bool) {
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
        let names = enabledChannels.map { $0.name }
        defaults.set(names.joined(separator: ","), forKey: Manager.persistentLogsKey)
    }

    /**
     Returns a copy of the input arguments array which has had any
     arguments that we handle stripped out of it.
     
     This is useful for clients that are parsing the command line arguments,
     particularly with something like Docopt.
     
     Our options are meant to be semi-hidden, and we don't really want every
     client of this library to have to know about all of them, or to have
     to document them.
     */
    
    static public func removeLoggingOptions(from arguments: [String]) -> [String] {
        var args: [String] = []
        var dropNext = false
        for argument in arguments {
            if (argument == "-\(Manager.logsKey)") || (argument == "--\(Manager.logsKey)") {
                dropNext = true
            } else if dropNext {
                dropNext = false
            } else {
                args.append(argument)
            }
        }
        return args
    }

}
