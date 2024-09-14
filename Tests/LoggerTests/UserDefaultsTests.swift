// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// //  Created by Sam Deane on 20/07/22.
// //  All code (c) 2022 - present day, Elegant Chaos Limited.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// #if !os(watchOS)
// import Foundation
// import LoggerTestSupport
// import XCTest

// @testable import Logger

// class UserDefaultsTests: XCTestCase {
//     func blankDefaults() -> UserDefaults {
//         let defaults = UserDefaults(suiteName: "LoggerTests")!
//         defaults.removePersistentDomain(forName: "LoggerTests")
//         return defaults
//     }

//     func makeItem(_ message: String) -> TestItem {
//         TestItem(message, test: self)
//     }

//     func updateAndSort(channels: [String], modifiers: String) -> [String] {
//         UserDefaultsManagerSettings.updateChannels(Set(channels), applyingModifiers: modifiers).sorted()
//     }

//     func testUnchangedChannels() {
//         XCTAssertEqual(updateAndSort(channels: ["test1", "test2"], modifiers: ""), ["test1", "test2"])
//     }

//     func testAddingChannels() {
//         XCTAssertEqual(updateAndSort(channels: ["test1", "test2"], modifiers: "+test3,+test4"), ["test1", "test2", "test3", "test4"])
//     }

//     func testRemovingChannels() {
//         XCTAssertEqual(updateAndSort(channels: ["test1", "test2", "test3", "test4"], modifiers: " -test1, -test3"), ["test2", "test4"])
//     }

//     func testResettingChannels() {
//         XCTAssertEqual(updateAndSort(channels: ["test1", "test2", "test3", "test4"], modifiers: "=test1,test3"), ["test1", "test3"])
//     }

//     func testMix() {
//         XCTAssertEqual(updateAndSort(channels: ["test1", "test2", "test4"], modifiers: "-test1,+test3"), ["test2", "test3", "test4"])
//     }

//     func testEnabledViaSettings() {
//         let defaults = blankDefaults()
//         defaults.set("test", forKey: "logs")
//         let handler = TestHandler("test")
//         let channel = Channel("test", handlers: [handler], manager: Manager(settings: UserDefaultsManagerSettings(defaults: defaults)))
//         let item = makeItem("blah")
//         channel.log(item) // log something so that the channel is setup
//         item.wait()
//         XCTAssertTrue(channel.enabled)
//     }

//     func testArgumentsWithoutLoggingOptions() {
//         let settings = UserDefaultsManagerSettings()
//         let stripped = settings.removeLoggingOptions(fromCommandLineArguments: ["blah", "-logs", "test,test2", "--logs=wibble", "waffle"])
//         XCTAssertEqual(stripped.count, 2)
//         XCTAssertEqual(stripped[0], "blah")
//         XCTAssertEqual(stripped[1], "waffle")
//     }
// }
// #endif
