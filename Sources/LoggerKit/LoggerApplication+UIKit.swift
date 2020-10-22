// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit) && !os(watchOS)
import UIKit
import Logger

/// A simple stub AppDelegate which:
/// - logs the main application events
/// - installs a Debug/Logger menu in the responder chain
///
/// Intended to be used as a base class.
@available(iOS 13.0, tvOS 13.0, *) open class LoggerApplication: ChainableResponder {
    let loggerMenu = LoggerMenu(manager: Logger.defaultManager)
    
    public var window: UIWindow?
    
    /// The very first thing that's called, at the beginning of didFinishLaunching
    /// Use this for quick setup only - for example to force log channels on/off.
    /// Proper setup should be deferred until later.
    open func prelaunch() {
        applicationChannel.debug("prelaunch")
    }
}

// MARK: UIApplication Lifecycle

@available(iOS 13.0, tvOS 13.0, *) extension LoggerApplication: UIApplicationDelegate {
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        prelaunch()
        install(responder: loggerMenu)
        applicationChannel.debug("willFinishLaunching")
        if let options = launchOptions {
            applicationChannel.debug("launch options: \(options)")
        }

        return true
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        applicationChannel.debug("didFinishLaunching")
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
