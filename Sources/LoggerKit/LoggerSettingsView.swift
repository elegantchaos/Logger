// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)
import UIKit
import Logger

public class LoggerSettingsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public typealias DoneCallback = () -> Void
    
    var tableView: UITableView!
    let manager = Logger.defaultManager

    public override func loadView() {
        super.loadView()
        
        tableView = UITableView()
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 40
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        tableView.setNeedsDisplay()
    }
    
    public func show(in controller: UIViewController, sender: UIView, done: DoneCallback? = nil) {
        title = "Log Settings"
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
    
    enum Command {
        case enableAllChannels
        case disableAllChannels
        case resetAllSettings
    }
    
    struct Item {
        let name: String
        let accessory: UITableViewCell.AccessoryType
        let command: Command
    }
    
    let items = [
        Item(name: "Enable All", accessory: .disclosureIndicator, command: .enableAllChannels),
        Item(name: "Disable All", accessory: .disclosureIndicator, command: .disableAllChannels),
        Item(name: "Reset All", accessory: .disclosureIndicator, command: .resetAllSettings)
    ]
    
//    func pushViewController(controller: UIViewController) {
//        if let navigation = self.navController ?? self.navigationController {
//            navigation.pushViewController(controller, animated: true)
//        }
//    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Settings" : "Channels"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return items.count
        } else {
            return manager.registeredChannels.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebugViewCell") else {
            return UITableViewCell(style: .default, reuseIdentifier: "DebugViewCell")
        }
        
        if indexPath.section == 0 {
            let item = items[indexPath.row]
            cell.textLabel?.text = item.name
            //        cell.textLabel?.font = settingsFont
            cell.accessoryType = item.accessory
        } else {
            let channel = manager.registeredChannels[indexPath.row]
            cell.textLabel?.text = channel.name
            cell.accessoryType = channel.enabled ? .checkmark : .none
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let item = items[indexPath.row]
            switch item.command {
            case .enableAllChannels:
                manager.update(channels: manager.registeredChannels, state: true)
                tableView.reloadSections(IndexSet([1]), with: .automatic)
                
            case .disableAllChannels:
                manager.update(channels: manager.registeredChannels, state: false)
                tableView.reloadSections(IndexSet([1]), with: .automatic)

            case .resetAllSettings:
                break
            }
        } else {
            let channel = manager.registeredChannels[indexPath.row]
            manager.update(channels: [channel], state: !channel.enabled)
            tableView.reloadRows(at: [indexPath], with: .automatic)

        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
#endif
