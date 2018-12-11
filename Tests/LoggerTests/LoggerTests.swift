// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import Foundation
import LoggerTestSupport

@testable import Logger

class TestHandler : Handler {
    var logged : [Any] = []
    
    override func log(channel: Logger, context: Context, logged: () -> Any) {
        self.logged.append(logged())
    }
}

class LoggerTests: XCTestCase {
    func blankDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: "LoggerTests")!
        defaults.removePersistentDomain(forName: "LoggerTests")
        return defaults
    }
    
    func testLoggingEnabled() {
        let handler = TestHandler("test")
        let logger = Logger("test", handlers: [handler], manager: Manager(defaults: blankDefaults()))
        logger.enabled = true
        logger.log("blah")
        XCTAssert(handler.logged.count == 1)
        XCTAssert(handler.logged[0] as! String == "blah")
    }
    
    func testLoggingDisabled() {
        let handler = TestHandler("test")
        let logger = Logger("test", handlers: [handler], manager: Manager(defaults: blankDefaults()))
        logger.enabled = false
        logger.log("blah")
        XCTAssert(handler.logged.count == 0)
    }

    func testDebugLogging() {
        let handler = TestHandler("test")
        let logger = Logger("test", handlers: [handler])
        logger.enabled = true
        logger.debug("blah")
        #if DEBUG
            XCTAssert(handler.logged.count == 1)
            XCTAssert(handler.logged[0] as! String == "blah")
        #else
            XCTAssert(handler.logged.count == 0)
        #endif
    }
    
    func testSettings() {
        // test the -logs parameter
        let defaults = blankDefaults()
        defaults.removePersistentDomain(forName: "test")
        defaults.set("test1,test2", forKey:"logs")
        let l1 = Manager(defaults: defaults).enabledLogs
        XCTAssertTrue(l1.contains("test1"))
        XCTAssertTrue(l1.contains("test2"))

        // test the logs+ parameter
        defaults.set("test1,test2", forKey:"logs")
        defaults.set("test3", forKey:"logs+")
        let l2 = Manager(defaults: defaults).enabledLogs
        XCTAssertTrue(l2.contains("test1"))
        XCTAssertTrue(l2.contains("test2"))
        XCTAssertTrue(l2.contains("test3"))
        defaults.removeObject(forKey: "logs+")
        
        // test the logs- parameter
        defaults.set("test1,test2", forKey:"logs")
        defaults.set("test1", forKey:"logs-")
        let l3 = Manager(defaults: defaults).enabledLogs
        XCTAssertFalse(l3.contains("test1"))
        XCTAssertTrue(l3.contains("test2"))
        XCTAssertFalse(l3.contains("test3"))
    }
    
    func testEnabledViaSettings() {
        let defaults = blankDefaults()
        defaults.set("test", forKey:"logs")
        let l = Logger("test", manager: Manager(defaults: defaults))
        l.log("blah") // log something so that the channel is setup
        XCTAssertTrue(l.enabled)
    }
    
    func testContextDescription() {
        let c = Context(file: "test.swift", line: 123,  column: 456, function: "testFunc")
        XCTAssertEqual(c.description, "test.swift: 123,456 - testFunc")
    }
    
    func testLoggerSimpleName() {
        let l = Logger("simpleName")
        XCTAssertEqual(l.name, "simpleName")
        XCTAssertEqual(l.subsystem, Logger.defaultSubsystem)
    }

    func testLoggerComplexName() {
        let l = Logger("com.elegantchaos.logger.test.name")
        XCTAssertEqual(l.name, "name")
        XCTAssertEqual(l.subsystem, "com.elegantchaos.logger.test")
    }

    func testLoggerComparison() {
        let l1 = Logger("test")
        let l2 = Logger("test")
        XCTAssertEqual(l1, l2)
        XCTAssertEqual(l1.hashValue, l2.hashValue)
    }

    func testHandlerComparison() {
        let h1 = Handler("test")
        let h2 = Handler("test")
        XCTAssertEqual(h1, h2)
        XCTAssertEqual(h1.hashValue, h2.hashValue)
    }

    func testArgumentsWithoutLoggingOptions() {
        let stripped = Manager.removeLoggingOptions(from: ["blah", "-logs", "test,test2", "-logs+", "added", "-logs-", "removed", "waffle"])
        XCTAssertEqual(stripped.count, 2)
        XCTAssertEqual(stripped[0], "blah")
        XCTAssertEqual(stripped[1], "waffle")
    }
    
    func testFatalError() {
        let logged = XCTAssertFatalError() {
            let l = Logger("test")
            l.fatal("Oh bugger")
        } as? String
        
        XCTAssertEqual(logged, "Oh bugger")
    }
}
