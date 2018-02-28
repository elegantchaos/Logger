// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Outputs log messages using NSLog()
 */

public class NSLogHandler : Handler {
  override public func log(channel: Logger, context : Context, logged : () -> Any) {
    NSLog("[\(channel.subsystem).\(channel.name)] \(logged())")
  }
}
