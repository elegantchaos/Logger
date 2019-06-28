// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/06/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Logger

public class LoggerMenu: UIResponder {
    var _next: UIResponder? = nil
    var channelMenu: UIMenu? = nil
    
    public override var next: UIResponder? {
        get {
            return _next
        }
        
        set (value) {
            _next = value
        }
    }
    
    public override func buildMenu(with builder: UIMenuBuilder) {
        print("building menu")
        guard builder.system == .main else { return }
        
        let debugMenu = buildDebugMenu(with: builder)
        addLoggerMenu(to: debugMenu, with: builder)
//        
//        Logger.defaultManager.registeredChannels.addObserver
    }
    
    public override func validate(_ command: UIMutableCommand) {
        print("validating \(command)")
    }
    
    func buildDebugMenu(with builder: UIMenuBuilder) -> UIMenu {
        let identifier = UIMenu.Identifier("Debug")
        
        // if the menu already exists, just return it
        if let menu = builder.menu(for: identifier) {
            return menu
        }
        
        // if not, insert one before the Help menu
        let debugMenu = UIMenu(__title: "Debug",
                               image: nil,
                               identifier: identifier,
                               options: [],
                               children: []
        )
        builder.insertSibling(debugMenu, beforeMenu: .help)
        return debugMenu
    }
    
    func addLoggerMenu(to debugMenu: UIMenu, with builder: UIMenuBuilder) {
        
        let enableAllItem = UIKeyCommand(__title: "Enable All", action: #selector(enableAllChannels(_:)), input: "E", modifierFlags: [.command, .control], propertyList: nil, alternates: [])
        let disableAllItem = UIKeyCommand(__title: "Disable All", action: #selector(disableAllChannels(_:)), input: "D", modifierFlags: [.command, .control], propertyList: nil, alternates: [])
        
        let loggerMenu = UIMenu(__title: "Logger",
                                image: nil,
                                identifier: UIMenu.Identifier("com.elegantchaos.logger.menu"),
                                options: [],
                                children: [
                                    enableAllItem,
                                    disableAllItem
            ]
        )
        builder.insertChild(loggerMenu, atStartOfMenu: debugMenu.identifier)
        
        var channelItems = [UIMenuElement]()
        for channel in Logger.defaultManager.registeredChannels {
            let item = UICommand(__title: channel.name, action: #selector(toggleChannel), propertyList: channel.name, alternates: [])
            channelItems.append(item)
        }
        
        let channelMenu = UIMenu(__title: "Channels",
                                 image: nil,
                                 identifier: UIMenu.Identifier("com.elegantchaos.logger.channels.menu"),
                                 options: [.displayInline],
                                 children: channelItems
        )
        builder.insertChild(channelMenu, atEndOfMenu: loggerMenu.identifier)
        self.channelMenu = channelMenu
    }
    
    @IBAction func toggleChannel(_ sender: Any) {
        if let command = sender as? UICommand {
            if let name = command.propertyList as? String {
                if let channel = Logger.defaultManager.channel(named: name) {
                    Logger.defaultManager.update(channels: [channel], state: !channel.enabled)
                }
            }
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
