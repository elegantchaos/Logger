// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Outputs log messages using swift's print() function.
 */

public class PrintHandler: Handler {
    public convenience init() {
        self.init("print")
    }

    override public func log(channel: Channel, context _: Context, logged: Any) {
        let tag = self.tag(channel: channel)
        print("\(tag)\(logged)")
    }
}
