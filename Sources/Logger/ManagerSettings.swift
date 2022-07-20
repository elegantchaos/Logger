// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public protocol ManagerSettings {
    var enabledChannelIDs: Set<Channel.ID> { get }
    func saveEnabledChannelIDs(_ ids: Set<Channel.ID>)
}

public extension ManagerSettings {
    func saveEnabledChannels(_ channels: [Channel]) {
        saveEnabledChannelIDs(Set(channels.map(\.id)))
    }
}

struct DefaultSettings: ManagerSettings {
    let defaults: UserDefaults
    
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    mutating func setup() {
        var persistent = enabledChannelIDs
        let changes = defaults.string(forKey: Manager.logsKey)?.split(separator: ",") ?? []

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
            persistent.union(newItems) 
        } else {
            persistent = newItems
        }
            
        var uniquePersistent = Set<String>()
        for item in persistent { uniquePersistent.insert(item) }
        let string = uniquePersistent.joined(separator: ",")
        let list = uniquePersistent.map { String($0) }
        
        saveEnabledChannelIDs(uniquePersistent)
        defaults.set("", forKey: Manager.logsKey)
        }

    var enabledChannelIDs: Set<Channel.ID> {
        let s = defaults.string(forKey: Manager.persistentLogsKey)?.split(separator: ",").map({ String($0) })
        return Set(s ?? [])
    }

    func saveEnabledChannelIDs(_ ids: Set<Channel.ID>) {
        let sortedIDs = ids.sorted().joined(separator: ",")
        defaults.set(sortedIDs, forKey: Manager.persistentLogsKey)
    }
}
