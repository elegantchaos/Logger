// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(watchOS)
import Foundation
import LoggerTestSupport
import XCTest

@testable import Logger

/**
 Test item that fulfills an expectation when it's logged.
 */

struct TestItem: CustomStringConvertible {
    let test: XCTestCase
    let expectation = XCTestExpectation(description: "logged")
    let message: String

    init(_ message: String, test: XCTestCase) {
        self.message = message
        self.test = test
    }

    var description: String {
        message
    }

    func logged() {
        expectation.fulfill()
    }

    func wait() {
        test.wait(for: [expectation], timeout: 1.0)
    }
}

/**
 Test log handler that keeps a list of the things its logged.
 */

class TestHandler: Handler {
    var logged: [Any] = []

    override func log(channel _: Channel, context _: Context, logged: Any) {
        self.logged.append("\(logged)")
        if let item = logged as? TestItem {
            item.logged()
        }
    }
}

struct EmptyManagerSettings: ManagerSettings {
    var enabledChannelIDs: Set<Channel.ID> { [] }
    func saveEnabledChannelIDs(_: Set<Channel.ID>) {}
    func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] { arguments }
}

/**
 Tests
 */

class LoggerTests: XCTestCase {
    func makeTestManager() -> Manager {
        Manager(settings: EmptyManagerSettings())
    }

    func makeItem(_ message: String) -> TestItem {
        TestItem(message, test: self)
    }

    func blankDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: "LoggerTests")!
        defaults.removePersistentDomain(forName: "LoggerTests")
        return defaults
    }

    func testLoggingEnabled() {
        let item = makeItem("blah")
        let handler = TestHandler("test")
        let channel = Channel("test", handlers: [handler], manager: makeTestManager())
        channel.enabled = true
        channel.log(item)
        item.wait()
        XCTAssert(handler.logged.count == 1)
        XCTAssert(handler.logged[0] as! String == "blah")
    }

    func testLoggingDisabled() {
        let handler = TestHandler("test")
        let channel = Channel("test", handlers: [handler], manager: makeTestManager())
        channel.enabled = false
        channel.log("blah")
        XCTAssert(handler.logged.count == 0)
    }

    func testDebugLogging() {
        let item = makeItem("logged")
        let handler = TestHandler("test")
        let channel = Channel("test", handlers: [handler], manager: makeTestManager())
        channel.enabled = true
        channel.debug("debug-only")
        channel.log(item)
        item.wait()

        #if DEBUG
        XCTAssert(handler.logged.first as! String == "debug-only")
        #else
        XCTAssert(handler.logged.first as! String == "logged")
        #endif
    }

    func testContextDescription() {
        let c = Context(file: "test.swift", line: 123, column: 456, function: "testFunc")
        XCTAssertEqual(c.description, "test.swift: 123,456 - testFunc")
    }

    func testChannelSimpleName() {
        let channel = Channel("simpleName")
        XCTAssertEqual(channel.name, "simpleName")
        XCTAssertEqual(channel.subsystem, Channel.defaultSubsystem)
    }

    func testChannelComplexName() {
        let channel = Channel("com.elegantchaos.logger.test.name")
        XCTAssertEqual(channel.name, "name")
        XCTAssertEqual(channel.subsystem, "com.elegantchaos.logger.test")
    }

    func testChannelComparison() {
        let channel1 = Channel("test")
        let channel2 = Channel("test")
        XCTAssertEqual(channel1, channel2)
        XCTAssertEqual(channel1.hashValue, channel2.hashValue)
    }

    func testHandlerComparison() {
        let h1 = Handler("test")
        let h2 = Handler("test")
        XCTAssertEqual(h1, h2)
        XCTAssertEqual(h1.hashValue, h2.hashValue)
    }

    #if !os(iOS)
    func testFatalError() {
        let manager = makeTestManager()
        let logged = XCTAssertFatalError(manager: manager) {
            let channel = Channel("test", manager: manager)
            channel.fatal("Oh bugger")
        } as? String

        XCTAssertEqual(logged, "Oh bugger")
    }
    #endif
}
#endif
