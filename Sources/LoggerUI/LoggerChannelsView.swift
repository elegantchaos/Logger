// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// //  Created by Sam Deane on 20/01/2021.
// //  All code (c) 2021 - present day, Elegant Chaos Limited.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// #if canImport(SwiftUI)

// import Combine
// import Logger
// import SwiftUI

// @available(macOS 10.15, iOS 15.0, tvOS 13.0, watchOS 6, *) public struct LoggerChannelsView: View {
//     @ObservedObject var manager = Manager.shared

//     public init() {
//     }

//     public var body: some View {
//         trace()

//         let channels = manager.registeredChannels.sorted(by: { $0.name < $1.name })

//         return List {
//             Section(header: Text("Global")) {
//                 Toggle("All Channels", isOn: Binding<Bool>(
//                     get: { manager.channelsState == .allEnabled },
//                     set: { value in Manager.shared.update(channels: Manager.shared.registeredChannels, state: value) }
//                 ))
//             }

//             Divider()

//             LoggerChannelsStackView(channels: channels)
//         }
//     }
// }

// @available(macOS 10.15, iOS 15.0, tvOS 13.0, watchOS 6, *) public struct LoggerChannelsStackView: View {
//     let channels: [Channel]

//     public init(channels: [Channel]) {
//         self.channels = channels
//     }

//     public var body: some View {
//         trace()

//         return Section(header: Text("Channels")) {
//             ForEach(channels, id: \Channel.name) { channel in
//                 ChannelToggleView(channel: channel)
//             }
//         }
//     }
// }

// struct ChannelToggleView: View {
//     @ObservedObject var channel: Channel

//     var body: some View {
//         Toggle(channel.name, isOn: $channel.enabled)
//     }
// }

// #endif

// extension View {
//     func trace() {
//         if #available(macOS 12.0, iOS 15.0, *) {
//             Self._printChanges()
//         }
//     }
// }
