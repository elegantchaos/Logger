// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit) && !os(watchOS)
    import Logger
    import UIKit

    /**
     View controller which allows configuration of the log channel settings.
     */

    public class LoggerSettingsView: UITableViewController {
        /**
          Callback which is invoked when the settings view is dismissed.
         */

        public typealias DoneCallback = () -> Void

        /**
          Static commands which form the first part of the settings view.
         */

        enum Command: String {
            case enableAllChannels = "Enable All"
            case disableAllChannels = "Disable All"

            static let commands: [Command] = [
                .enableAllChannels,
                .disableAllChannels,
            ]
        }

        /**
         Table constants.
         */

        static let cellIdentifier = "cell"
        static let sections = ["Settings", "Channels"]
        static let commandsSection = 0

        /**
          The manager we're showing settings for.
         */

        let manager: Manager

        /**
          Font to use for the table.
         */

        #if os(tvOS)
            let font = UIFont.preferredFont(forTextStyle: .body)
        #else
            let font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        #endif

        public init(manager: Manager) {
            self.manager = manager
            super.init(style: .plain)
        }

        required init?(coder: NSCoder) {
            manager = Logger.defaultManager
            super.init(coder: coder)
        }

        /**
          Display the view in another controller.
          By default we display as a popover, using the sender to pick the location.
         */

        public func show(in controller: UIViewController, sender: UIView, revealed: DoneCallback? = nil) {
            title = "Log Settings"
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: LoggerSettingsView.cellIdentifier)
            let nav = UINavigationController(rootViewController: self)
            #if os(tvOS)
                nav.modalPresentationStyle = .fullScreen
            #else
                nav.modalPresentationStyle = .popover
            #endif

            tableView.reloadData()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneModal(_:)))
            if let popover = nav.popoverPresentationController {
                popover.sourceView = sender
                popover.sourceRect = sender.bounds
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
                if #available(iOS 9.0, *) {
                    popover.canOverlapSourceViewRect = true
                }
            }

            controller.present(nav, animated: true) {
                revealed?()
            }
        }

        @IBAction func doneModal(_: Any?) {
            dismiss(animated: true) {
                self.removeFromParent()
            }
        }

        override public func numberOfSections(in _: UITableView) -> Int {
            return LoggerSettingsView.sections.count
        }

        override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
            return LoggerSettingsView.sections[section]
        }

        override public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            }
        }

        fileprivate func selectChannel(_ indexPath: IndexPath, _ tableView: UITableView) {
            let channel = manager.registeredChannels[indexPath.row]
            manager.update(channels: [channel], state: !channel.enabled)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
#endif
