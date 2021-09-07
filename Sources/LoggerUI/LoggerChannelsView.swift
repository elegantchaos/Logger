// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/01/2021.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

import Combine
import Logger
import SwiftUI

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *) public struct LoggerChannelsView: View {
    public init() {
    }
    
    public var body: some View {
        List {
            LoggerChannelsHeaderView()
            Divider()
            LoggerChannelsStackView()
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *) public struct LoggerChannelsStackView: View {
    public init() {
        
    }

    public var body: some View {
        VStack {
            ForEach(Logger.defaultManager.registeredChannels, id: \Channel.name) { channel in
                Toggle(channel.name, isOn: Binding<Bool>(
                    get: { channel.enabled },
                    set: { (value) in
                        Logger.defaultManager.update(channels: [channel], state: value)
                    }
                ))
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *) public struct LoggerChannelsHeaderView: View {
    let channelsChanged = NotificationCenter.default.publisher(for: Manager.channelsUpdatedNotification, object: Logger.defaultManager)

    @State var allEnabled = false
    @State var allDisabled = false

    public init() {
        
    }

    public var body: some View {
        VStack {
            Button(action: handleEnableAll) {
                Text("Enable All")
            }
            .disabled(allEnabled)
            
            Button(action: handleDisableAll) {
                Text("Disable All")
            }
            .disabled(allDisabled)
        }
        .onReceive(channelsChanged, perform: handleChannelsChanged)
        .onAppear(perform: handleAppear)
    }
    
    
    func handleAppear() {
        updateState()
    }
    
    func handleChannelsChanged(_ notification: Notification) {
        updateState()
    }

    func handleEnableAll() {
        Logger.defaultManager.update(channels: Logger.defaultManager.registeredChannels, state: true)
        allEnabled = true
        allDisabled = false
    }
    
    func handleDisableAll() {
        Logger.defaultManager.update(channels: Logger.defaultManager.registeredChannels, state: false)
        allEnabled = false
        allDisabled = true
    }

    func updateState() {
        allEnabled = Logger.defaultManager.registeredChannels.allSatisfy({ $0.enabled == true })
        allDisabled = Logger.defaultManager.registeredChannels.allSatisfy({ $0.enabled == false })
    }

}

#endif
