// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

  import os

  /// Outputs log messages using os_log().
  public actor OSLogHandler: Handler {
    /// Table of logs - one for each channel.
    var logTable: [Channel: OSLog] = [:]
    public let name = "oslog"
    public func log(_ value: Sendable, context: Context) async {
      let channel = context.channel
      let log = logTable[
        channel, default: OSLog(subsystem: channel.subsystem, category: channel.name)]

      let message = String(describing: value)
      let dso = UnsafeRawPointer(bitPattern: context.dso)
      os_log("%{public}@", dso: dso, log: log, type: .default, message)
    }
  }

#endif
