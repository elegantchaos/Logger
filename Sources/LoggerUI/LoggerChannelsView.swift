// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/01/2021.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import Logger

@available(iOS 13.0, *) public struct LoggerChannelsView: View {
    @State var allEnabled = false
    @State var allDisabled = false
    
    public init() {
    }
    
    public var body: some View {
        List {
            Button(action: {
                Logger.defaultManager.update(channels: Logger.defaultManager.registeredChannels, state: true)
                updateState()
            }) {
                Text("Enable All")
            }
            .disabled(allEnabled)
            
            Button(action: {
                Logger.defaultManager.update(channels: Logger.defaultManager.registeredChannels, state: false)
                updateState()
            }) {
                Text("Disable All")
            }
            .disabled(allDisabled)
            
            Divider()
            
            ForEach(Logger.defaultManager.registeredChannels, id: \Channel.name) { channel in
                Toggle(channel.name, isOn: Binding<Bool>(
                    get: { channel.enabled },
                    set: { (value) in
                        Logger.defaultManager.update(channels: [channel], state: value)
                        updateState()
                    }
                ))
            }
        }
        .onAppear(perform: handleAppear)
    }
    
    func handleAppear() {
        updateState()
    }
    
    func updateState() {
        allEnabled = Logger.defaultManager.registeredChannels.allSatisfy({ $0.enabled == true })
        allDisabled = Logger.defaultManager.registeredChannels.allSatisfy({ $0.enabled == false })
    }
}

