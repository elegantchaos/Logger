// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(os)

  import os
  import Synchronization

  /// Outputs log messages using os_log(), with one log per channel.
  ///
  /// Each channel's subsystem and name become the log's subsystem and category. Logs are
  /// created on first use and reused.
  public final class OSLogHandler: Handler {
    /// Name of the handler.
    public let name = "oslog"

    /// Logs created so far, keyed by channel identifier.
    private let logs = Mutex<[Channel.ID: OSLog]>([:])

    /// Creates a handler.
    public init() {}

    /// Outputs an item to its channel's log.
    public func log(_ item: LoggedItem) async {
      let message = String(describing: item.value)
      let dso = UnsafeRawPointer(bitPattern: item.context.dso)
      os_log("%{public}@", dso: dso, log: log(for: item.context.channel), type: .default, message)
    }

    /// Returns the log for a channel, creating it on first use.
    private func log(for channel: Channel) -> OSLog {
      logs.withLock { logs in
        if let log = logs[channel.id] { return log }
        let log = OSLog(subsystem: channel.subsystem, category: channel.name)
        logs[channel.id] = log
        return log
      }
    }
  }

#endif
