// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Responsible for sending log output somewhere.
 
 Examples might include printing the output with NSLog/print/OSLog,
 writing it to disk, or sending it down a pipe or network stream.
 */

public class Handler {
    
    let name : String
    let showName : Bool
    let showSubsystem : Bool
    
    public init(_ name : String, showName : Bool = true, showSubsystem : Bool = false) {
        self.name = name
        self.showName = showName
        self.showSubsystem = showSubsystem
    }
    
    /**
     Log something.
     */
    
    public func log(channel: Logger, context : Context, logged : Any) {
    }
    
    /**
     Calculate a text tag indicating the name of the channel.
     Provided as a utility for subclasses to use if they need.
     */
    
    internal func tag(channel : Logger) -> String {
        if showName && showSubsystem {
            return "[\(channel.subsystem).\(channel.name)] "
        } else if showName {
            return "[\(channel.name)] "
        } else if showSubsystem {
            return "[\(channel.subsystem)] "
        } else {
            return ""
        }
    }
}


/**
 We store an index of handlers in a dictionary, so need them to be hashable.
 For now, we simply treat handlers with the same name as equal.
 */

extension Handler : Hashable {
    
    public var hashValue: Int {
        return name.hashValue
    }
    
    public static func == (lhs: Handler, rhs: Handler) -> Bool {
        return (lhs.name == rhs.name)
    }
    
}
