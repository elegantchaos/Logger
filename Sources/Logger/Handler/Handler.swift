// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Something responsible for sending log output somewhere.
///
/// Examples might include printing the output with NSLog, print or OSLog, writing it to
/// disk, or sending it down a pipe or network stream. Each channel passes its items to its
/// handler one at a time, in order; several channels can share a handler, so `log(_:)`
/// can be called concurrently for different channels.
public protocol Handler: Sendable {
  /// Name of the handler.
  var name: String { get }

  /// Outputs a logged item.
  func log(_ item: LoggedItem) async
}
