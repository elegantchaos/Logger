// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit) && !os(watchOS)
import Logger
import UIKit

public let sceneChannel = Channel("Scene", handlers: [OSLogHandler()])

/// Standardised scene delegate which logs its main events.
open class LoggerScene: UIResponder {
    public var window: UIWindow?
}

@available(iOS 13.0, tvOS 13.0, *) extension LoggerScene: UIWindowSceneDelegate {
    open func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        sceneChannel.debug("willConnectTo")
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    open func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        sceneChannel.debug("didDisconnect")
    }

    open func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        sceneChannel.debug("didBecomeActive")
    }

    open func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        sceneChannel.debug("willResignActive")
    }

    open func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        sceneChannel.debug("willEnterForeground")
    }

    open func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        sceneChannel.debug("didEnterBackground")
    }
}
#endif
