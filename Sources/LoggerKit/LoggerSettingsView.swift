// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)
import UIKit
import Logger

public class LoggerSettingsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    var headerView: UIView!
//    var titleLabel: UILabel!
    var tableView: UITableView!
    
    //    var settingsController: LoggingSettingsViewController
    //@property (strong, nonatomic) IBOutlet ECLogTranscriptViewController* oTranscriptController;
    
    public override func loadView() {
        super.loadView()
        
//        headerView = UIView()
//        headerView.backgroundColor = .red
//        self.view.addSubview(headerView)
//
//        titleLabel = UILabel()
//        titleLabel.text = "test"
//        titleLabel.textAlignment = .center
//        titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 20)
//        headerView.addSubview(titleLabel)
        
        tableView = UITableView()
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
//        headerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.15).isActive = true
//
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
//        titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
//        titleLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.4).isActive = true
//        titleLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.5).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        //    [self.oTranscriptController setupInitialLogItems];
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //    self.oSettingsController.navController = self.navigationController;
        //    [[ECLogManager sharedInstance] saveChannelSettings];
    }
    
    public func show(in controller: UIViewController, done: () -> Void) {
        edgesForExtendedLayout = UIRectEdge()
        
        if let nav = controller.navigationController {
            nav.pushViewController(self, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: self)
            title = "Logging"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneModal(_:)))
            controller.present(nav, animated: true) {
                
            }
        }
    }
    
    @IBAction func doneModal(_ sender: Any?) {
        dismiss(animated: true) {
            self.removeFromParent()
        }
    }
    
    enum Command {
        case showChannels
        case showHandlers
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
        Item(name: "Configure Channels", accessory: .disclosureIndicator, command: .showChannels),
        Item(name: "Default Handlers", accessory: .disclosureIndicator, command: .showHandlers),
        Item(name: "Enable All", accessory: .disclosureIndicator, command: .enableAllChannels),
        Item(name: "Disable All", accessory: .disclosureIndicator, command: .disableAllChannels),
        Item(name: "Reset All", accessory: .disclosureIndicator, command: .resetAllSettings)
    ]
    
    func showChannels() {
        //                ECDebugChannelsViewController* controller = [[ECDebugChannelsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        //                controller.settingsViewController = self;
        //                [self pushViewController:controller];
    }
    
    func showHandlers() {
        //                    ECDebugHandlersViewController* controller = [[ECDebugHandlersViewController alloc] initWithStyle:UITableViewStyleGrouped];
        //                    controller.settingsViewController = self;
        //                    [self pushViewController:controller];
    }
    
//    func pushViewController(controller: UIViewController) {
//        if let navigation = self.navController ?? self.navigationController {
//            navigation.pushViewController(controller, animated: true)
//        }
//    }
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Settings"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebugViewCell") else {
            return UITableViewCell(style: .default, reuseIdentifier: "DebugViewCell")
        }
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
//        cell.textLabel?.font = settingsFont
        cell.accessoryType = item.accessory
        return cell
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item.command {
        case .showChannels:
            showChannels()
            
        case .showHandlers:
            showHandlers()
            
        case .enableAllChannels:
            let manager = Logger.defaultManager
            manager.update(channels: manager.registeredChannels, state: true)
            
        case .disableAllChannels:
            let manager = Logger.defaultManager
            manager.update(channels: manager.registeredChannels, state: false)
            
        case .resetAllSettings:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
#endif
