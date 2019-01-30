// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Represents a channel through which log messages can be sent.
 Each channel can be enabled/disabled, and configured to send its output
 to one or more handlers.
 */

public class Channel {
    
    /**
     Default log handler which prints to standard out,
     without appending the channel details.
     */
    
    public static let stdoutHandler = PrintHandler("default", showName: false, showSubsystem: false)
    
    /**
     Default handler to use for channels if nothing else is specified.
     
     On the Mac this is an OSLogHandler, which will log directly to the console without
     sending output to stdout/stderr.
     
     On Linux it is a PrintHandler which will log to stdout.
     */
    
    static func initDefaultHandler() -> Handler {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10.0, *) {
            return OSLogHandler("default")
        }
        #endif
        
        return stdoutHandler // TODO: should perhaps be stderr instead?
    }
    
    public static let defaultHandler = initDefaultHandler()
    
    /**
     Default log manager to use for channels if nothing else is specified.
     
     Under normal circumstances it makes sense for everything to share the same manager,
     which is why this exists.
     
     There are times (particularly testing) when we might want to use a different manager
     though, which is why it's not a true singleton.
     */
    
    public static let defaultManager = Manager()
    
    /**
     Default subsystem if nothing else is specified.
     If the channel name is in dot syntax (x.y.z), then the last component is
     assumed to be the name, and the rest is assumed to be the subsystem.
     
     If there are no dots, it's all assumed to be the name, and this default
     is used for the subsytem.
     */
    
    static let defaultSubsystem = "com.elegantchaos.logger"
    
    /**
     Default log channel that clients can use to log their actual output.
     This is intended as a convenience for command line programs which actually want to produce output.
     They could of course just use print() for this (producing normal output isn't strictly speaking
     the same as logging), but this channel exists to allow output and logging to be treated in a uniform
     way.
     
     Unlike most channels, we want this one to default to always being on.
     */
    
    public static let stdout = Logger("stdout", handlers:[stdoutHandler], enabled: true)
    
    public let name : String
    public let subsystem : String
    let manager : Manager
    var handlers : [Handler] = []
    let handlersSetup : () -> [Handler]
    
    public var enabled : Bool
    var setup = false
    
    public init(_ name : String, handlers : @autoclosure @escaping () -> [Handler] = [defaultHandler], enabled : Bool = false, manager : Manager = Logger.defaultManager) {
        let components = name.split(separator: ".")
        let last = components.count - 1
        if last > 0 {
            self.name = String(components[last])
            self.subsystem = components[..<last].joined(separator: ".")
        } else {
            self.name = name
            self.subsystem = Logger.defaultSubsystem
        }
        self.handlersSetup = handlers
        self.enabled = enabled
        self.manager = manager

        manager.queue.async {
            manager.register(channel: self)
        }
    }
    
    internal func doSetup() {
        if !setup {
            readSettings()
            handlers = handlersSetup()
            setup = true
        }
    }
    
    internal func readSettings() {
        if manager.channelsEnabledInSettings.contains("\(name)") {
            enabled = true
        }
        
    }
    
    public func log(_ logged : @escaping @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line,  column: UInt = #column, function: StaticString = #function) {
        if (!setup) {
            manager.queue.async {
                self.doSetup()
                if self.enabled {
                    let context = Context(file:file, line:line, column:column, function:function)
                    self.handlers.forEach({ $0.log(channel:self, context:context, logged:logged) })
                }
            }
            
        } else if (enabled) {
            manager.queue.async {
                let context = Context(file:file, line:line, column:column, function:function)
                self.handlers.forEach({ $0.log(channel:self, context:context, logged:logged) })
            }
        }
    }
    
    public func debug(_ logged : @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line,  column: UInt = #column, function: StaticString = #function) {
        #if DEBUG
        log(logged, file: file, line: line, column: column, function: function)
        #endif
    }

    public func fatal(_ logged : @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line,  column: UInt = #column, function: StaticString = #function) -> Never {
        log(logged, file: file, line: line, column: column, function: function)
        manager.fatalHandler(logged(), self, file, line)
    }
}

extension Channel : Hashable {
    // For now, we treat loggers with the same name as equal,
    // as long as they belong to the same manager.
    
    public var hashValue: Int {
        return name.hashValue
    }
    
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        return (lhs.name == rhs.name) && (lhs.manager === rhs.manager)
    }
    
}

/**
 Externally, channels are declared with Logger(...)
 */

public typealias Logger = Channel
