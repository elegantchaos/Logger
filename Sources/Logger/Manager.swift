// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Manager {
    typealias AssociatedLoggerData = [Logger:Any]
    typealias AssociatedHandlerData = [Handler:AssociatedLoggerData]

    var associatedData : AssociatedHandlerData = [:]

    let defaults : UserDefaults
    
    
    init(defaults : UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    
    /**
     An array of the names of the enabled log channels.

     We read this from a combination of three user
     default keys: "logs", "logs+", and "logs-".

     The "logs" key is persisted in the user defaults,
     and contains the basic list of enabled channels.
     It can be overridden on the command line to completely
     replace the current list with a new one.

     The "logs+" key is intended to be used on the command
     line only. It appends channels to the enabled list without
     wiping out previously enabled channels.

     The "logs-" is similarly intended to be used on the command
     line only. It removes channels from the enabled list.
     */

    public lazy var enabledLogs : [String] = {
        guard let logs = defaults.string(forKey: "logs") else {
            return []
        }
        var items = Set(logs.split(separator:","))

        if let additions = defaults.string(forKey: "logs+") {
            let itemsToAdd = Set(additions.split(separator:","))
            items.formUnion(itemsToAdd)
        }

        if let subtractions = defaults.string(forKey: "logs-") {
            let itemsToRemove = Set(subtractions.split(separator:","))
            items.subtract(itemsToRemove)
        }

        defaults.set(logs, forKey: "logs")
        return items.map { return String($0) }
    }()


    /**
     Return arbitrary data associated with a channel/handler pair.
     This provides handlers with a mechanism to use to store per-channel state.

     If no data is stored, the setter closure is called to provide it.
     */

    public func associatedData<T>(handler: Handler, logger : Logger, setter : ()->T ) -> T {
        var handlerData = associatedData[handler]
        if handlerData == nil {
            handlerData = [:]
            associatedData[handler] = handlerData
        }

        var loggerData = handlerData![logger] as? T
        if loggerData == nil {
            loggerData = setter()
            handlerData![logger] = loggerData
        }

        return loggerData!
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
    
    static public func removeLoggingOptions(from arguments : [String]) -> [String] {
        var args : [String] = []
        var dropNext = false
        for argument in arguments {
            if (argument == "-logs") || (argument == "-logs+" || argument == "-logs-") {
                dropNext = true
            } else if dropNext {
                dropNext = false
            } else {
                args.append(argument)
            }
        }
        return args
    }
}
