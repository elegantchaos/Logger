// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Something responsible for sending log output somewhere.
/// Examples might include printing the output with NSLog/print/OSLog,
/// writing it to disk, or sending it down a pipe or network stream.

public protocol Handler: Sendable {
  var name: String { get }
  func log(_ item: LoggedItem) async
  func shutdown() async
}
