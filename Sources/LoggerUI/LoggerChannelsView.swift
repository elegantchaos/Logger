// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/01/2021.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(SwiftUI)

    import Logger
    import SwiftUI

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *) public struct LoggerChannelsView: View {
        @State var allEnabled = false
        @State var allDisabled = false

        public init() {}

        public var body: some View {
            List {
                Button(action: {
                    Manager.shared.update(channels: Manager.shared.registeredChannels, state: true)
                    self.updateState()
                }) {
                    Text("Enable All")
                }
                .disabled(allEnabled)

                Button(action: {
                    Manager.shared.update(channels: Manager.shared.registeredChannels, state: false)
                    self.updateState()
                }) {
                    Text("Disable All")
                }
                .disabled(allDisabled)

                Divider()

                ForEach(Manager.shared.registeredChannels, id: \Channel.name) { channel in
                    Toggle(channel.name, isOn: Binding<Bool>(
                        get: { channel.enabled },
                        set: { value in
                            Manager.shared.update(channels: [channel], state: value)
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
            allEnabled = Manager.shared.registeredChannels.allSatisfy { $0.enabled == true }
            allDisabled = Manager.shared.registeredChannels.allSatisfy { $0.enabled == false }
        }
    }

#endif
