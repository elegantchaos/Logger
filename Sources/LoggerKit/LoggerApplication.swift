// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit) && !os(watchOS)
import UIKit
import Logger

let applicationChannel = Channel("Application", handlers: [OSLogHandler()])

/// A simple stub AppDelegate which:
/// - logs the main application events
/// - installs a Debug/Logger menu in the responder chain
///
/// Intended to be used as a base class.
@available(iOS 13.0, tvOS 13.0, *) open class LoggerApplication: UIResponder {
    let loggerMenu = LoggerMenu(manager: Logger.defaultManager)
    lazy var loggerMenuEnabled = LoggerApplication.shouldInstallLoggerMenu()
    
    public var window: UIWindow?

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
        
    open override var next: UIResponder? {
        return  loggerMenuEnabled ? loggerMenu : super.next
    }
}

// MARK: UIApplication Lifecycle

@available(iOS 13.0, tvOS 13.0, *) extension LoggerApplication: UIApplicationDelegate {
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applicationChannel.debug("didFinishLaunching")
        if let options = launchOptions {
            applicationChannel.debug("launch options: \(options)")
        }

        return true
    }

    open func applicationWillResignActive(_ application: UIApplication) {
        applicationChannel.debug("willResignActive")
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        applicationChannel.debug("didEnterBackground")
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        applicationChannel.debug("willEnterForeground")
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        applicationChannel.debug("didBecomeActive")
    }

    open func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        applicationChannel.debug("open \(inputURL)")
        return false
    }

    open func applicationWillTerminate(_ application: UIApplication) {
        applicationChannel.debug("willTerminate")
    }
}


// MARK: UISceneSession Lifecycle

@available(iOS 13.0, tvOS 13.0, *) extension LoggerApplication {

    open func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        applicationChannel.debug("configurationForConnecting \(connectingSceneSession) \(options)")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    open func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        applicationChannel.debug("didDiscardSceneSessions \(sceneSessions)")
    }
}

#endif
