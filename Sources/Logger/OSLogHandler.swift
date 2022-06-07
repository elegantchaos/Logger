// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

    import os

    /**
     Outputs log messages using os_log().
     */

    @available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 5.0, *) public class OSLogHandler: Handler {
        public convenience init() {
            self.init("oslog")
        }

        override public func log(channel: Channel, context: Context, logged: Any) {
            let log = channel.manager.associatedData(handler: self, channel: channel) {
                OSLog(subsystem: channel.subsystem, category: channel.name)
            }

            let message = "\(logged)"
            os_log("%{public}@", dso: context.dso, log: log, type: .default, message)
        }
    }

#endif
