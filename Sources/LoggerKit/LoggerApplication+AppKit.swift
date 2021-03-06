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
    /// The very first thing that's called, at the beginning of didFinishLaunching
    /// Use this for quick setup only - for example to force log channels on/off.
    /// Proper setup should be deferred until later.
    open func prelaunch() {
    }
}

// MARK: Application Lifecycle

extension LoggerApplication: NSApplicationDelegate {
    open func applicationDidFinishLaunching(_ notification: Notification) {
        prelaunch()
        applicationChannel.debug("didFinishLaunching")
        
        if LoggerApplication.shouldInstallLoggerMenu() {
            let menubar = NSApp.mainMenu
            var debug = menubar?.item(withTitle: "Debug")
            if debug == nil {
                debug = NSMenuItem(title: "Debug", action: nil, keyEquivalent: "")
                debug?.submenu = NSMenu(title: "Debug")
                if let labelView = menubar?.indexOfItem(withTitle: "Help") {
                    menubar?.insertItem(debug!, at: labelView)
                }
            }
            
            if let menu = debug?.submenu {
                let item = menu.addItem(withTitle: "Logger", action: nil, keyEquivalent: "")
                item.submenu = LoggerMenu()
            }
        }
    }

    open func applicationWillTerminate(_ aNotification: Notification) {
        applicationChannel.debug("willTerminate")
    }

    open func applicationDidHide(_ notification: Notification) {
        applicationChannel.debug("didHide")
    }
    
    open func applicationWillHide(_ notification: Notification) {
        applicationChannel.debug("willHide")
    }

    open func applicationWillUnhide(_ notification: Notification) {
        applicationChannel.debug("willUnihde")
    }
    
    open func applicationDidUnhide(_ notification: Notification) {
        applicationChannel.debug("didUnhide")
    }

    open func applicationWillResignActive(_ notification: Notification) {
        applicationChannel.debug("willResignActive")
    }

    open func applicationDidBecomeActive(_ notification: Notification) {
        applicationChannel.debug("didBecomeActive")
    }

    open func applicationDidResignActive(_ notification: Notification) {
        applicationChannel.debug("didResignActive")
    }

    open func application(_ application: NSApplication, open urls: [URL]) {
        applicationChannel.debug("open \(urls)")
    }
}

#endif
