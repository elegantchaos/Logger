// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Combine
import Foundation

/**
 Represents a channel through which log messages can be sent.
 Each channel can be enabled/disabled, and configured to send its output
 to one or more handlers.
 */

public actor Channel {

  /**
     Default subsystem if nothing else is specified.
     If the channel name is in dot syntax (x.y.z), then the last component is
     assumed to be the name, and the rest is assumed to be the subsystem.

     If there are no dots, it's all assumed to be the name, and this default
     is used for the subsytem.
     */

  public let name: String
  public let subsystem: String

  nonisolated(unsafe) public var enabled: Bool

  let manager: Manager
  var handlers: [Handler] = []

  static let defaultSubsystem = "com.elegantchaos.logger"

  public init(
    _ name: String, handlers: @autoclosure () -> [Handler] = [Manager.defaultHandler],
    alwaysEnabled: Bool = false, manager: Manager = Manager.shared
  ) {
    let components = name.split(separator: ".")
    let last = components.count - 1
    let shortName: String
    let subName: String

    if last > 0 {
      shortName = String(components[last])
      subName = components[..<last].joined(separator: ".")
    } else {
      shortName = name
      subName = Channel.defaultSubsystem
    }

    let fullName = "\(subName).\(shortName)"
    let enabledList = manager.channelsEnabledInSettings
    let isEnabled =
      enabledList.contains(shortName) || enabledList.contains(fullName) || alwaysEnabled

    self.name = shortName
    self.subsystem = subName
    self.manager = manager
    self.enabled = isEnabled

    self.handlers = handlers()  // TODO: does this need to be a closure any more?
    Task {
      await manager.register(channel: self)
    }
  }

  /**
     Log something.

     The logged value is an autoclosure, to avoid doing unnecessary work if the channel is disabled.

     If the channel is enabled, we capture the logged value, by evaluating the autoclosure.
     We then log the value asynchronously.s

     Note that reading the `enabled` flag is not isolated, to avoid taking unnecessary locks. It's theoretically
     possible for another thread to be writing to this flag whilst we're reading it, if the channel state is being
     changed. Thread sanitizer might flag this up, but it's harmless, and should generally only happen in a debug
     setting.
     */

  nonisolated public func log<T>(
    _ logged: @autoclosure () -> T, file: StaticString = #file, line: UInt = #line,
    column: UInt = #column, function: StaticString = #function
  ) {
    if enabled {
      let context = Context(file: file, line: line, column: column, function: function)
      let value = asSendable(logged)
      Task.detached { await self._log(value, context: context) }
    }
  }

  public func _log(_ value: Sendable, context: Context) {
    for handler in handlers {
      Task { await handler.log(channel: self, context: context, logged: value) }
    }
  }

  nonisolated public func debug<T>(
    _ logged: @autoclosure () -> T, file: StaticString = #file, line: UInt = #line,
    column: UInt = #column, function: StaticString = #function
  ) {
    #if DEBUG
      if enabled {
        let context = Context(file: file, line: line, column: column, function: function)
        let value = asSendable(logged)
        Task { await self._log(value, context: context) }
      }
    #endif
  }

  nonisolated public func fatal(
    _ logged: @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line,
    column: UInt = #column, function: StaticString = #function
  ) -> Never {
    let value = logged()
    log(value, file: file, line: line, column: column, function: function)
    manager.fatalHandler(value, self, file, line)
  }
}

extension Channel: Identifiable {
  nonisolated public var id: String { "\(subsystem).\(name)" }
}

extension Channel: Hashable {
  // For now, we treat channels with the same name as equal,
  // as long as they belong to the same manager.
  nonisolated public func hash(into hasher: inout Hasher) {
    name.hash(into: &hasher)
  }

  public static func == (lhs: Channel, rhs: Channel) -> Bool {
    (lhs.name == rhs.name) && (lhs.manager === rhs.manager)
  }
}

func asSendable<T>(_ value: () -> T) -> Sendable where T: Sendable { value() }
func asSendable<T>(_ value: () -> T) -> Sendable { String(describing: value()) }
