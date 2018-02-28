// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public class Handler {

  let name : String

  public init(_ name : String) {
    self.name = name
  }

  public func log(channel: Logger, context : Context, logged : () -> Any) {
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