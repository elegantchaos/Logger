// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit)
import UIKit
import Logger

let applicationChannel = Channel("Application", handlers: [OSLogHandler()])

/// Standardise AppDelegate which:
/// - logs the main application events
/// - installs a Debug/Logger menu in the responder chain
@available(iOS 13.0, *) open class LoggerApplication: UIResponder {
    let loggerMenu = LoggerMenu(manager: Logger.defaultManager)
    public var window: UIWindow?
    
    open override var next: UIResponder? {
        return loggerMenu
    }
}

// MARK: UIApplication Lifecycle

@available(iOS 13.0, *) extension LoggerApplication: UIApplicationDelegate {
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        applicationChannel.enabled = true
        applicationChannel.debug("didFinishLaunching")
        if let options = launchOptions {
            applicationChannel.debug("launch options: \(options)")
        }

        return true
    }

    open func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        applicationChannel.debug("willResignActive")
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        applicationChannel.debug("didEnterBackground")
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        applicationChannel.debug("willEnterForeground")
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        applicationChannel.debug("didBecomeActive")
    }

    open func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        applicationChannel.debug("open \(inputURL)")
        return false
    }

}


// MARK: UISceneSession Lifecycle

@available(iOS 13.0, *) extension LoggerApplication {

    open func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    open func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

#endif
