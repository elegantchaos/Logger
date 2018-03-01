// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Logger {

    #if os(Mac)
    public static let defaultHandler = OSLogHandler("default")
    #else
    public static let defaultHandler = PrintHandler("default")
    #endif

    static let defaultManager = Manager()
    static let defaultSubsystem = "com.elegantchaos.logger"

    let name : String
    let subsystem : String
    let manager : Manager
    var handlers : [Handler] = []
    let handlersSetup : () -> [Handler]

    public var enabled = false
    var setup = false

    public init(_ name : String, handlers : @autoclosure @escaping () -> [Handler] = [defaultHandler]) {
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
        self.manager = Logger.defaultManager
    }

    internal func readSettings() {
        if manager.enabledLogs.contains("\(name)") {
            enabled = true
        }

    }

    public func log(_ logged : @autoclosure () -> Any, file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function) {
        if (!setup) {
            readSettings()
            handlers = handlersSetup()
            setup = true
        }

        if (enabled) {
            let context = Context(file:file, line:line, column:column, function:function)
            handlers.forEach({ $0.log(channel:self, context:context, logged:logged) })
        }
    }

    public func debug(_ logged : @autoclosure () -> Any, file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function) {
        #if debug
        log(logged, file: file, line: line, column: column, function: function)
        #endif
    }
}

extension Logger : Hashable {
    // For now, we treat loggers with the same name as equal,
    // as long as they belong to the same manager.

    public var hashValue: Int {
        return name.hashValue
    }

    public static func == (lhs: Logger, rhs: Logger) -> Bool {
        return (lhs.name == rhs.name) && (lhs.manager === rhs.manager)
    }

}
