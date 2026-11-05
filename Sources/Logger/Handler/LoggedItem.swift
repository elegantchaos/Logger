// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// A logged value and the context it was logged in.
public struct LoggedItem: Sendable {
  /// The logged value, converted to a sendable representation.
  public let value: Sendable

  /// Where and through which channel the value was logged.
  public let context: Context
}
