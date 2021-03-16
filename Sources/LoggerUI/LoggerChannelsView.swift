// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/01/2021.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

import SwiftUI
import Logger

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *) public struct LoggerChannelsView: View {
    @State var allEnabled = false
    @State var allDisabled = false
    
    public init() {
    }
    
    public var body: some View {
        List {
            Button(action: {
                Logger.defaultManager.update(channels: Logger.defaultManager.registeredChannels, state: true)
                self.updateState()
            }) {
                Text("Enable All")
            }
            .disabled(allEnabled)
            
            Button(action: {
                Logger.defaultManager.update(channels: Logger.defaultManager.registeredChannels, state: false)
                self.updateState()
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
                        self.updateState()
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

#endif
