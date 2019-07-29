//
//  ContentView.swift
//  Logger Example
//
//  Created by Sam Deane on 28/06/2019.
//  Copyright © 2019 Elegant Chaos. All rights reserved.
//

import SwiftUI
import Logger
import LoggerKit

let viewChannel = Logger("View")

//@objc class LMI : NSObject, UIContextMenuInteractionDelegate {
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (elements) -> UIMenu? in
//            let lm = LoggerMenu()
//            return lm.loggerMenu()
//        }
//    }
//
//    func showLoggerMenu(for view: UIView) {
//        let ui = UIContextMenuInteraction(delegate: self)
//        view.addInteraction(ui)
//    }
//}

struct ContentView : View {
    @State private var showPopup = false
    
    var popoverContent: some View {
        List {
            ForEach(Logger.defaultManager.enabledChannels, id: \Channel.name) { channel in
                Button(action: {
                    Logger.defaultManager.update(channels: [channel], state: !channel.enabled)
                }) {
                    HStack {
                        Text(channel.name)
                        Image(systemName: channel.enabled ? "checkmark" : "checkmark.circle")
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Button(action: {
                applicationChannel.log("hello ma!")
            }) {
                Text("Log to application channel")
            }

            Button(action: {
                viewChannel.log("hello ma!")
            }) {
                Text("Log to view channel")
            }
            
            Button(action: {
                self.showPopup = true
            }) {
                Text("Show Log Settings")
            }.presentation(showPopup ? Popover(content: popoverContent, dismissHandler: { self.showPopup = false }) : nil)


        }

    }
    
    func showSettings() {
//
//        let lv = LoggerSettingsView()
//        lv.show(in: , sender: <#T##UIView#>)
//
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
