// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(watchOS)
import XCTest
import Foundation
import LoggerTestSupport

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
        return message
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

class TestHandler : Handler {
    var logged : [Any] = []
    
    override func log(channel: Channel, context: Context, logged: Any) {
        self.logged.append("\(logged)")
        if let item = logged as? TestItem {
            item.logged()
        }
    }
}

/**
 Tests
 */

class LoggerTests: XCTestCase {
    func makeItem(_ message: String) -> TestItem {
        return TestItem(message, test: self)
    }
    
    func blankDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: "LoggerTests")!
        defaults.removePersistentDomain(forName: "LoggerTests")
        return defaults
    }
    
    func testLoggingEnabled() {
        let item = makeItem("blah")
        let handler = TestHandler("test")
        let channel = Channel("test", handlers: [handler], manager: Manager(defaults: blankDefaults()))
        channel.enabled = true
        channel.log(item)
        item.wait()
        XCTAssert(handler.logged.count == 1)
        XCTAssert(handler.logged[0] as! String == "blah")
    }
    
    func testLoggingDisabled() {
        let handler = TestHandler("test")
        let channel = Channel("test", handlers: [handler], manager: Manager(defaults: blankDefaults()))
        channel.enabled = false
        channel.log("blah")
        XCTAssert(handler.logged.count == 0)
    }

    func testDebugLogging() {
        let item = makeItem("logged")
        let handler = TestHandler("test")
        let channel = Channel("test", handlers: [handler])
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
    
    func testSettings() {
        // test the logs parameter from a clean slate
        let defaults = blankDefaults()
        defaults.removePersistentDomain(forName: "test")
        defaults.set("test1,test2", forKey:"logs")
        let l1 = Manager(defaults: defaults).channelsEnabledInSettings
        XCTAssertTrue(l1.contains("test1"))
        XCTAssertTrue(l1.contains("test2"))

        // test adding in channels
        defaults.set("+test3,+test4", forKey:"logs")
        let l2 = Manager(defaults: defaults).channelsEnabledInSettings
        XCTAssertTrue(l2.contains("test1"))
        XCTAssertTrue(l2.contains("test2"))
        XCTAssertTrue(l2.contains("test3"))
        XCTAssertTrue(l2.contains("test4"))

        // test removing channels
        defaults.set("-test1,-test3", forKey:"logs")
        let l3 = Manager(defaults: defaults).channelsEnabledInSettings
        XCTAssertFalse(l3.contains("test1"))
        XCTAssertTrue(l3.contains("test2"))
        XCTAssertFalse(l3.contains("test3"))
        XCTAssertTrue(l3.contains("test4"))
        
        // test resetting channels
        defaults.set("=test1,test3", forKey:"logs")
        let l4 = Manager(defaults: defaults).channelsEnabledInSettings
        XCTAssertTrue(l4.contains("test1"))
        XCTAssertFalse(l4.contains("test2"))
        XCTAssertTrue(l4.contains("test3"))
        XCTAssertFalse(l4.contains("test4"))
    }
    
    func testEnabledViaSettings() {
        let defaults = blankDefaults()
        defaults.set("test", forKey:"logs")
        let handler = TestHandler("test")
        let channel = Channel("test", handlers: [handler], manager: Manager(defaults: defaults))
        let item = makeItem("blah")
        channel.log(item) // log something so that the channel is setup
        item.wait()
        XCTAssertTrue(channel.enabled)
    }
    
    func testContextDescription() {
        let c = Context(file: "test.swift", line: 123,  column: 456, function: "testFunc")
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

    func testArgumentsWithoutLoggingOptions() {
        let stripped = Manager.removeLoggingOptions(from: ["blah", "-logs", "test,test2", "--logs=wibble", "waffle"])
        XCTAssertEqual(stripped.count, 2)
        XCTAssertEqual(stripped[0], "blah")
        XCTAssertEqual(stripped[1], "waffle")
    }
    
    #if !os(iOS)
    func testFatalError() {
        let logged = XCTAssertFatalError() {
            let channel = Channel("test")
            channel.fatal("Oh bugger")
        } as? String
        
        XCTAssertEqual(logged, "Oh bugger")
    }
    #endif
}
#endif
