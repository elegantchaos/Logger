// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Outputs log messages using swift's print() function.
 */

public class PrintLogHandler : Handler {
    override public func log(channel: Logger, context : Context, logged : () -> Any) {
        print("[\(channel.subsystem).\(channel.name)] \(logged())")
    }
}