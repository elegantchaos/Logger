// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/12/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
import Logger

public class LoggerMenu: NSMenu, NSMenuDelegate, NSMenuItemValidation {
    init() {
        super.init(title: "Logger")
        self.delegate = self
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.delegate = self
    }
    
    public func menuNeedsUpdate(_ menu: NSMenu) {
        removeAllItems()
        
        let enableAllItem = NSMenuItem(title: "Enable all", action: #selector(enableAllChannels(_:)), keyEquivalent: "")
        enableAllItem.target = self
        addItem(enableAllItem)
        
        let disableAllItem = NSMenuItem(title: "Disable all", action: #selector(disableAllChannels(_:)), keyEquivalent: "")
        disableAllItem.target = self
        addItem(disableAllItem)
        
        addItem(NSMenuItem.separator())

        for channel in Logger.defaultManager.registeredChannels {
            let item = NSMenuItem(title: channel.name, action: #selector(toggleChannel(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = channel
            addItem(item)
        }
    }

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(toggleChannel(_:)) {
            if let channel = menuItem.representedObject as? Logger {
                menuItem.state = channel.enabled ? .on : .off
            }
        }
            
        return true
    }
    
    @IBAction func toggleChannel(_ sender: Any) {
        if let item = sender as? NSMenuItem, let channel = item.representedObject as? Logger {
            Logger.defaultManager.update(channels: [channel], state: !channel.enabled)
        }
    }

    @IBAction func enableAllChannels(_ sender: Any) {
        let manager = Logger.defaultManager
        manager.update(channels: manager.registeredChannels, state: true)
    }

    @IBAction func disableAllChannels(_ sender: Any) {
        let manager = Logger.defaultManager
        manager.update(channels: manager.registeredChannels, state: false)
    }

}
#endif
