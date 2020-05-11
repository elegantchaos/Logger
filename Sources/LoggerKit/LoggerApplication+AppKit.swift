// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import Logger

/// A simple stub AppDelegate which:
/// - logs the main application events
/// - installs a Debug/Logger menu in the responder chain
///
/// Intended to be used as a base class.

open class LoggerApplication: NSResponder  {
}

// MARK: Application Lifecycle

extension LoggerApplication: NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        applicationChannel.debug("didFinishLaunching")
        
        if LoggerApplication.shouldInstallLoggerMenu() {
            let menubar = NSApp.mainMenu
            var debug = menubar?.item(withTitle: "Debug")
            if debug == nil {
                debug = NSMenuItem(title: "Debug", action: nil, keyEquivalent: "")
                debug?.submenu = NSMenu(title: "Debug")
                if let index = menubar?.indexOfItem(withTitle: "Help") {
                    menubar?.insertItem(debug!, at: index)
                }
            }
            
            if let menu = debug?.submenu {
                let item = menu.addItem(withTitle: "Logger", action: nil, keyEquivalent: "")
                item.submenu = LoggerMenu()
            }
        }
    }

    public func applicationWillTerminate(_ aNotification: Notification) {
        applicationChannel.debug("willTerminate")
    }

    public func applicationDidHide(_ notification: Notification) {
        applicationChannel.debug("didHide")
    }
    
    public func applicationWillHide(_ notification: Notification) {
        applicationChannel.debug("willHide")
    }

    public func applicationWillUnhide(_ notification: Notification) {
        applicationChannel.debug("willUnihde")
    }
    
    public func applicationDidUnhide(_ notification: Notification) {
        applicationChannel.debug("didUnhide")
    }

    public func applicationWillResignActive(_ notification: Notification) {
        applicationChannel.debug("willResignActive")
    }

    public func applicationDidBecomeActive(_ notification: Notification) {
        applicationChannel.debug("didBecomeActive")
    }

    public func applicationDidResignActive(_ notification: Notification) {
        applicationChannel.debug("didResignActive")
    }

    public func application(_ application: NSApplication, open urls: [URL]) {
        applicationChannel.debug("open \(urls)")
    }
}

#endif
