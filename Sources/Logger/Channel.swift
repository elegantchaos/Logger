// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Synchronization

/// A named log channel that can be enabled or disabled at runtime.
///
/// Declare channels as globals or statics and log to them from any thread. Logging checks
/// an atomic enabled flag and, when enabled, queues the value; it never waits. Each channel
/// registers with its manager when created, and a task started by the manager passes the
/// queued values to the channel's handler in order.
///
/// Channels with the same manager and full identifier (`subsystem.name`) share their
/// enabled state. A channel's state is immutable apart from that atomic flag, so it can be
/// shared freely between threads.
public final class Channel: Sendable {
  /// Name of the channel.
  public let name: String

  /// Subsystem of the channel.
  public let subsystem: String

  /// Enablement shared by channels with this identifier and manager.
  private let _enabled: ChannelEnablement

  /// Manager that this channel is registered with.
  let manager: Manager

  /// Handler attached to this channel.
  let handler: any Handler

  /// Queue of logged items waiting for the handler.
  let sequence = YieldingSequence<LoggedItem>()

  /// Default subsystem if nothing else is specified.
  ///
  /// If the channel name is in dot syntax (x.y.z), then the last component is
  /// assumed to be the name, and the rest is assumed to be the subsystem.
  /// If there are no dots, it's all assumed to be the name, and this default
  /// is used for the subsystem.
  static let defaultSubsystem = "com.elegantchaos.logger"

  /// Initialise the channel and register it with its manager.
  ///
  /// The channel starts in the state saved by its manager's settings, or in
  /// `defaultState` when nothing is saved. Channels with the same manager and full
  /// identifier share enablement, and must declare the same default.
  public init(
    _ name: String, handler: (any Handler)? = nil,
    default defaultState: State = .disabled, manager: Manager? = nil
  ) {
    let manager = manager ?? Manager.shared
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

    self.name = shortName
    self.subsystem = subName
    self.manager = manager
    self._enabled = manager.enablement(
      for: "\(subName).\(shortName)", name: shortName,
      isEnabledByDefault: defaultState == .enabled)
    self.handler = handler ?? Manager.defaultHandler

    Task {
      await manager.run(channel: self)
    }
  }

  /// Is this channel enabled?
  ///
  /// Setting it notifies the manager, which emits an event and saves the settings.
  public var enabled: Bool {
    get { _enabled.value.load(ordering: .relaxed) }
    set {
      _enabled.value.store(newValue, ordering: .relaxed)
      Task { await manager.channelUpdated(self) }
    }
  }

  /// The state the channel has when nothing is saved for it.
  public var defaultState: State {
    _enabled.isEnabledByDefault ? .enabled : .disabled
  }

  /// Logs a value if the channel is enabled.
  ///
  /// The value is an autoclosure, so it is only evaluated when the channel is enabled.
  /// It is converted to a string immediately and passed to the handler asynchronously.
  public func log<T>(
    _ logged: @autoclosure () -> T, file: StaticString = #file, line: UInt = #line,
    column: UInt = #column, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle
  ) {
    if enabled {
      let context = Context(
        channel: self,
        file: file, line: line, column: column, function: function, dso: dso)
      let value = asSendable(logged)
      sequence.yield(LoggedItem(value: value, context: context))
    }
  }

  /// Logs a value if the channel is enabled, in debug builds only.
  public func debug<T>(
    _ logged: @autoclosure () -> T, file: StaticString = #file, line: UInt = #line,
    column: UInt = #column, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle
  ) {
    #if DEBUG
      if enabled {
        let context = Context(
          channel: self,
          file: file, line: line, column: column, function: function, dso: dso)
        let value = asSendable(logged)
        sequence.yield(LoggedItem(value: value, context: context))
      }
    #endif
  }

  /// Logs a value and then calls the manager's fatal error handler, which does not return.
  public func fatal(
    _ logged: @autoclosure () -> Any, file: StaticString = #file, line: UInt = #line,
    column: UInt = #column, function: StaticString = #function
  ) -> Never {
    let value = logged()
    log(value, file: file, line: line, column: column, function: function)
    manager.fatalHandler(value, self, file, line)
  }

  /// Stops the channel.
  ///
  /// Values logged after this call are discarded. Values already queued are still passed
  /// to the handler. Under normal conditions this does not need to be called; the manager
  /// stops its channels when it shuts down.
  public func shutdown() {
    sequence.finish()
  }

  /// Sets the enabled state without notifying the manager, and returns the previous state.
  ///
  /// The manager uses this to apply several changes, then notifies and saves once.
  func exchangeEnabled(_ isEnabled: Bool) -> Bool {
    _enabled.value.exchange(isEnabled, ordering: .relaxed)
  }

  /// Passes queued items to the handler until the channel is shut down.
  ///
  /// Runs on the concurrent executor, so channels drain independently of the manager actor
  /// that awaits this.
  @concurrent
  func run() async {
    for await item in sequence {
      await handler.log(item)
    }
  }
}

extension Channel {
  /// Whether a channel is enabled.
  public enum State: Sendable {
    /// The channel logs.
    case enabled

    /// The channel ignores logged values.
    case disabled
  }
}

extension Channel: Identifiable {
  /// The channel's full identifier, `subsystem.name`.
  public var id: String { "\(subsystem).\(name)" }
}

extension Channel: Hashable {
  /// Hashes the channel's identifier.
  ///
  /// Channels with the same identifier and manager are treated as equal.
  public func hash(into hasher: inout Hasher) {
    subsystem.hash(into: &hasher)
    name.hash(into: &hasher)
  }

  /// Channels are equal when they have the same identifier and manager.
  public static func == (lhs: Channel, rhs: Channel) -> Bool {
    (lhs.subsystem == rhs.subsystem) && (lhs.name == rhs.name) && (lhs.manager === rhs.manager)
  }
}

/// Converts a logged value to a sendable representation.
func asSendable<T>(_ value: () -> T) -> Sendable { String(describing: value()) }
