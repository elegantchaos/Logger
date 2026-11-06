// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Settings that save channel states in user defaults.
///
/// The default `Manager.shared` uses one of these, and in normal situations it is all you
/// need. States are saved as a dictionary of identifiers to booleans. When created, it
/// applies any channel modifiers supplied with the `logs` argument, such as
/// `-logs "+Network,-Cache"`, saves the result, and clears the argument.
struct UserDefaultsManagerSettings: ManagerSettings {
  /// Defaults that hold the saved states and the command-line modifiers.
  let defaults: UserDefaults

  /// Creates settings for the given defaults and applies any command-line modifiers.
  init(defaults: UserDefaults = UserDefaults.standard) {
    self.defaults = defaults
    applyCommandLineModifiers()
  }

  /// Saved states of channels that differ from their defaults.
  var channelStates: Manager.ChannelStates {
    defaults.dictionary(forKey: .channelStatesKey) as? Manager.ChannelStates ?? [:]
  }

  /// Replaces the saved channel states.
  func saveChannelStates(_ states: Manager.ChannelStates) {
    defaults.set(states, forKey: .channelStatesKey)
  }

  /// Applies and saves the modifiers in the `logs` setting, then clears it.
  private func applyCommandLineModifiers() {
    let modifiers = defaults.string(forKey: .logsKey) ?? ""
    saveChannelStates(Self.updateStates(channelStates, applyingModifiers: modifiers))
    defaults.set("", forKey: .logsKey)
  }

  /// Applies a comma-separated list of channel modifiers to saved states.
  ///
  /// `name` or `+name` enables a channel and `-name` disables it. If any item begins with
  /// `=`, the saved states are cleared first, returning every channel to its default, and
  /// `=name` enables that channel. Names can be full identifiers or short names.
  static func updateStates(
    _ states: Manager.ChannelStates, applyingModifiers modifiers: String
  ) -> Manager.ChannelStates {
    let items = modifiers.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    var updated = items.contains { $0.hasPrefix("=") } ? [:] : states
    for item in items where !item.isEmpty {
      switch item.first {
      case "-": updated[String(item.dropFirst())] = false
      case "+", "=": updated[String(item.dropFirst())] = true
      default: updated[item] = true
      }
    }
    return updated
  }

  /**
   Returns a copy of the input arguments array which has had any
   arguments that we handle stripped out of it.

   This is useful for clients that are parsing the command line arguments,
   particularly with something like Docopt.

   Our options are meant to be semi-hidden, and we don't really want every
   client of this library to have to know about all of them, or to have
   to document them.
   */

  public func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] {
    let key: String = .logsKey
    var args: [String] = []
    var dropNext = false
    for argument in arguments {
      if argument == "-\(key)" {
        dropNext = true
      } else if dropNext {
        dropNext = false
      } else if !argument.starts(with: "--\(key)=") {
        args.append(argument)
      }
    }
    return args
  }
}

extension String {
  /// Defaults key for the saved channel states.
  static let channelStatesKey = "logs-states"

  /// Defaults key for channel modifiers supplied on the command line.
  static let logsKey = "logs"
}
