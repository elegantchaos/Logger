// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/01/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)
import UIKit

public class LoggerSettingsView: UIViewController {
    var headerView: UIView!
    //    var settingsController: LoggingSettingsViewController
    //@property (strong, nonatomic) IBOutlet ECLogTranscriptViewController* oTranscriptController;
    
    public override func viewDidLoad() {
        headerView = UIView()
        headerView.backgroundColor = .red
        self.view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = true
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        headerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.15).isActive = true
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
    
}
#endif
