// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(Linux) && !os(watchOS)
import Foundation

@available(iOS 13.0, tvOS 13.0, *) extension LoggerApplication {
    /// Whether to initialise the logger menu is determined by a preference.
    /// In a debug build, if the preference is missing, we set it to true,
    /// so the menu will show by default.
    /// In a release build, the menu is hidden by default, unless someone has
    /// explicitly set the preference (or previously run a debug build).
    ///
    /// Subclasses can override this method to provide different logic.
    open class func shouldInstallLoggerMenu() -> Bool {
        #if DEBUG
        if UserDefaults.standard.object(forKey: "ShowDebugMenu") == nil {
            UserDefaults.standard.set(true, forKey: "ShowDebugMenu")
        }
        #endif
        
        return UserDefaults.standard.bool(forKey: "ShowDebugMenu")
    }
}
#endif
