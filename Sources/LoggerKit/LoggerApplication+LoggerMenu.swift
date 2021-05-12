// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(Linux) && !os(watchOS)
import Foundation

@available(iOS 13.0, tvOS 13.0, *) extension LoggerApplication {
    /// In a debug build, the menu is always shown.
    /// In a release build, visibility is determined by a preference.
    ///
    /// Subclasses can override this method to provide different logic.
    open class func shouldInstallLoggerMenu() -> Bool {
        #if DEBUG
        return true
        #else
        return UserDefaults.standard.bool(forKey: .showDebugMenuKey)
        #endif
    }
}
#endif
