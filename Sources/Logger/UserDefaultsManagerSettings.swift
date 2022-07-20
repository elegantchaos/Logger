// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Implementation of ManagerSettings that uses the UserDefaults system.
/// The default Manager.shared instance uses one of these to read/write
/// settings, and in normal situations it should be all you need.

struct DefaultSettings: ManagerSettings {
    let defaults: UserDefaults
    
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
        setup()
    }
    
    /**
     Calculate the list of enabled channels.
     
     This is determined by two settings: `logsKey` and `persistentLogsKey`,
     both of which contain comma-delimited strings.
     
     The persistentLogs setting contains the names of all the channels that were
     enabled last time. This is expected to be read from the user defaults.
     
     The logs setting contains overrides, and if present, is expected to have
     been supplied on the command line.
     
     Items in the overrides can be in two forms:
     
     - "name1,-name2,+name3": *modifies* the list by enabling/disabling named channels
     - "=name1,name2,name3": *resets* the list to the named channels
     
     Note that `+name` is a synonym for `name` in the first form - there just for symmetry.
     Note also that if any item in the list begins with `=`, the second form is used and the list is reset.
     */
    
    mutating func setup() {
        var persistent = enabledChannelIDs
        let changes = defaults.string(forKey: .logsKey)?.split(separator: ",") ?? []
        
        var onlyDeltas = true
        var newItems = Set<String>()
        for item in changes {
            var trimmed = String(item)
            if let first = item.first {
                switch first {
                    case "=":
                        trimmed.removeFirst()
                        newItems.insert(trimmed)
                        onlyDeltas = false
                    case "-":
                        trimmed.removeFirst()
                        if let index = persistent.firstIndex(of: trimmed) {
                            persistent.remove(at: index)
                        }
                    case "+":
                        trimmed.removeFirst()
                        newItems.insert(trimmed)
                    default:
                        newItems.insert(trimmed)
                }
            }
        }
        
        if onlyDeltas {
            persistent.formUnion(newItems)
        } else {
            persistent = newItems
        }
        
        saveEnabledChannelIDs(persistent)
        defaults.set("", forKey: .logsKey)
    }
    
    var enabledChannelIDs: Set<Channel.ID> {
        let s = defaults.string(forKey: .persistentLogsKey)?.split(separator: ",").map({ String($0) })
        return Set(s ?? [])
    }
    
    func saveEnabledChannelIDs(_ ids: Set<Channel.ID>) {
        let sortedIDs = ids.sorted().joined(separator: ",")
        defaults.set(sortedIDs, forKey: .persistentLogsKey)
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
    static let persistentLogsKey = "logs-persistent"
    static let logsKey = "logs"
}
