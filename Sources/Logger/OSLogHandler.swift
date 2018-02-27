// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import os

public class OSLogHandler : LogHandler {
    static var LogObjects : [Logger:OSLog] = [:]
    
    override public func log(channel: Logger, context : LogContext, logged : () -> Any) {
        var log = OSLogHandler.LogObjects[channel]
        if log == nil {
            log = OSLog(subsystem: channel.subsystem, category:channel.name)
            OSLogHandler.LogObjects[channel] = log
        }
     
        let message = "\(logged())"
        os_log("%@", dso: context.dso, log: log!, type: .default, message)
    }
}
