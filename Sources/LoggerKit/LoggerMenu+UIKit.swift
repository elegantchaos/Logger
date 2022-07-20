// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/06/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit) && !os(watchOS)

import Combine
import Logger
import UIKit

@available(iOS 13.0, tvOS 13.0, *) extension UIMenu.Identifier {
    static let debugMenu = Self("com.elegantchaos.logger.debug.menu")
    static let loggerMenu = Self("com.elegantchaos.logger.logger.menu")
    static let optionsMenu = Self("com.elegantchaos.logger.options.menu")
    static let channelsMenu = Self("com.elegantchaos.logger.channels.menu")
}

@available(iOS 13.0, tvOS 13.0, *) public class LoggerMenu: ChainableResponder {
    let manager: Manager
    var channelMenu: UIMenu?
    var channelWatcher: AnyCancellable?
    lazy var loggerMenuEnabled = LoggerApplication.shouldInstallLoggerMenu()

    public init(manager: Manager, next _: UIResponder? = nil) {
        self.manager = manager
    }

    override public func buildMenu(with builder: UIMenuBuilder) {
        guard builder.system == .main else { return }

        if loggerMenuEnabled {
            #if !os(tvOS) // TODO: re-enable tvOS when UIMenu works properly
            let debugMenu = buildDebugMenu(with: builder)
            addOptionsMenu(to: debugMenu, with: builder)
            addLoggerMenu(to: debugMenu, with: builder)
            #endif

            channelWatcher = NotificationCenter.default
                .publisher(for: Manager.channelsUpdatedNotification, object: manager)
                .sink { _ in
                    UIMenuSystem.main.setNeedsRebuild()
                }
        }
    }

    override public func validate(_ command: UICommand) {
        switch command.action {
            case #selector(toggleChannel):
                if let channel = channel(for: command) {
                    command.state = channel.enabled ? .on : .off
                }

            case #selector(toggleMenuVisibility):
                command.state = UserDefaults.standard.bool(forKey: .showDebugMenuKey) ? .on : .off

            default:
                break
        }
    }

    #if !os(tvOS)
    func buildDebugMenu(with builder: UIMenuBuilder, identifier: UIMenu.Identifier = .debugMenu) -> UIMenu {
        // if the menu already exists, just return it
        if let menu = builder.menu(for: identifier) {
            return menu
        }

        // if not, insert one before the Help menu
        let debugMenu = UIMenu(title: "Debug",
                               image: nil,
                               identifier: identifier,
                               options: [],
                               children: [
                               ])

        builder.insertSibling(debugMenu, beforeMenu: .help)
        return debugMenu
    }

    func addOptionsMenu(to debugMenu: UIMenu, with builder: UIMenuBuilder) {
        let showInReleaseItem = UICommand(title: "Show Debug Menu In Release Builds", action: #selector(toggleMenuVisibility))
        let optionsMenu = UIMenu(title: "Options",
                                 image: nil,
                                 identifier: .optionsMenu,
                                 options: [],
                                 children: [
                                     showInReleaseItem,
                                 ])

        builder.insertChild(optionsMenu, atEndOfMenu: debugMenu.identifier)
    }

    func addLoggerMenu(to debugMenu: UIMenu, with builder: UIMenuBuilder) {
        let enableAllItem = UIKeyCommand(input: "E", modifierFlags: [.command, .control], action: #selector(enableAllChannels))
        enableAllItem.title = "Enable All"

        let disableAllItem = UIKeyCommand(input: "D", modifierFlags: [.command, .control], action: #selector(disableAllChannels(_:)))
        disableAllItem.title = "Disable All"

        let loggerMenu = UIMenu(title: "Logger",
                                image: nil,
                                identifier: .loggerMenu,
                                options: [],
                                children: [
                                    enableAllItem,
                                    disableAllItem,
                                ])
        builder.insertChild(loggerMenu, atStartOfMenu: debugMenu.identifier)

        var channelItems = [UIMenuElement]()
        for channel in manager.registeredChannels {
            let item = UICommand(title: channel.name, image: nil, action: #selector(toggleChannel), propertyList: channel.name, alternates: [], discoverabilityTitle: channel.name, attributes: [], state: .on)
            item.title = channel.name
            channelItems.append(item)
        }

        let channelMenu = UIMenu(title: "Channels",
                                 image: nil,
                                 identifier: .channelsMenu,
                                 options: [.displayInline],
                                 children: channelItems)
        builder.insertChild(channelMenu, atEndOfMenu: loggerMenu.identifier)
        self.channelMenu = channelMenu
    }
    #endif

    func channel(for command: UICommand) -> Channel? {
        guard let name = command.propertyList as? String else { return nil }
        return manager.channel(named: name)
    }

    @IBAction func toggleChannel(_ sender: Any) {
        if let command = sender as? UICommand, let channel = channel(for: command) {
            manager.update(channels: [channel], state: !channel.enabled)
        }
    }

    @IBAction func enableAllChannels(_: Any) {
        manager.update(channels: manager.registeredChannels, state: true)
    }

    @IBAction func disableAllChannels(_: Any) {
        manager.update(channels: manager.registeredChannels, state: false)
    }

    @IBAction func toggleMenuVisibility(_: Any) {
        let defaults = UserDefaults.standard
        let current = defaults.bool(forKey: .showDebugMenuKey)
        defaults.set(!current, forKey: .showDebugMenuKey)
    }
}

#endif
