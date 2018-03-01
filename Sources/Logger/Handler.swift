// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public class Handler {
    
    let name : String
    let showName : Bool
    let showSubsystem : Bool
    
    public init(_ name : String, showName : Bool = true, showSubsystem : Bool = false) {
        self.name = name
        self.showName = showName
        self.showSubsystem = showSubsystem
    }
    
    public func log(channel: Logger, context : Context, logged : () -> Any) {
    }

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


extension Handler : Hashable {
    // For now, we treat handlers with the same name as equal.
    
    public var hashValue: Int {
        return name.hashValue
    }
    
    public static func == (lhs: Handler, rhs: Handler) -> Bool {
        return (lhs.name == rhs.name)
    }
    
}
