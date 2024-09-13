// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS) || os(iOS)
  import Foundation

  /**
 Outputs log messages using NSLog()
 */

  public class NSLogHandler: Handler {
    public convenience init() {
      self.init("nslog")
    }

    override public func log(channel: Channel, context _: Context, logged: Any) async {
      let tag = tag(channel: channel)
      NSLog("\(tag)\(logged)")
    }
  }

#endif
