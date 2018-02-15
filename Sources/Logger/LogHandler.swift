
public class LogHandler {
  let name : String

  public init(_ name : String) {
    self.name = name
  }

  public func log(channel: Logger, context : LogContext, logged : () -> Any) {
    print("\(channel.name): \(logged())")
  }
}
