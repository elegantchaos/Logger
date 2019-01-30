// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit)
import UIKit
import Logger

public class LoggerSettingsView: UITableViewController {
    public typealias DoneCallback = () -> Void
    
    enum Command: String {
        case enableAllChannels = "Enable All"
        case disableAllChannels = "Disable All"
        case resetAllSettings = "Reset All"
        
        static let commands: [Command] = [
            .enableAllChannels,
            .disableAllChannels,
            .resetAllSettings
        ]
    }
    
    static let cellIdentifier = "cell"
    static let sections = [ "Settings", "Channels" ]
    static let commandsSection = 0

    let manager = Logger.defaultManager
    let font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    
    public func show(in controller: UIViewController, sender: UIView, done: DoneCallback? = nil) {
        title = "Log Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: LoggerSettingsView.cellIdentifier)
        let nav = UINavigationController(rootViewController: self)
        nav.modalPresentationStyle = .popover
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneModal(_:)))
        if let popover = nav.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = UIPopoverArrowDirection.any
            popover.canOverlapSourceViewRect = false
        }
        
        controller.present(nav, animated: true) {
            done?()
        }
    }
    
    @IBAction func doneModal(_ sender: Any?) {
        dismiss(animated: true) {
            self.removeFromParent()
        }
    }
    
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return LoggerSettingsView.sections.count
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LoggerSettingsView.sections[section]
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == LoggerSettingsView.commandsSection {
            return Command.commands.count
        } else {
            return manager.registeredChannels.count
        }
    }
   
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LoggerSettingsView.cellIdentifier)!
        if indexPath.section == LoggerSettingsView.commandsSection {
            setupCommandRow(indexPath, cell)
        } else {
            setupChannelRow(indexPath, cell)
        }

        cell.textLabel?.font = font
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == LoggerSettingsView.commandsSection {
            selectCommand(indexPath, tableView)
        } else {
            selectChannel(indexPath, tableView)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    fileprivate func setupCommandRow(_ indexPath: IndexPath, _ cell: UITableViewCell) {
        let command = Command.commands[indexPath.row]
        cell.textLabel?.text = command.rawValue
        cell.accessoryType = .none
    }
    
    fileprivate func setupChannelRow(_ indexPath: IndexPath, _ cell: UITableViewCell) {
        let channel = manager.registeredChannels[indexPath.row]
        cell.textLabel?.text = channel.name
        cell.accessoryType = channel.enabled ? .checkmark : .none
    }
    
    fileprivate func selectCommand(_ indexPath: IndexPath, _ tableView: UITableView) {
        let item = Command.commands[indexPath.row]
        switch item {
        case .enableAllChannels:
            manager.update(channels: manager.registeredChannels, state: true)
            tableView.reloadSections(IndexSet([1]), with: .automatic)
            
        case .disableAllChannels:
            manager.update(channels: manager.registeredChannels, state: false)
            tableView.reloadSections(IndexSet([1]), with: .automatic)
            
        case .resetAllSettings:
            break
        }
    }
    
    fileprivate func selectChannel(_ indexPath: IndexPath, _ tableView: UITableView) {
        let channel = manager.registeredChannels[indexPath.row]
        manager.update(channels: [channel], state: !channel.enabled)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
#endif
