// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import Foundation

@testable import Logger

class TestHandler : Handler {
    var logged : [Any] = []
    
    override func log(channel: Logger, context: Context, logged: () -> Any) {
        self.logged.append(logged())
    }
}

class LoggerTests: XCTestCase {
    func testLoggingEnabled() {
        let handler = TestHandler("test")
        let logger = Logger("test", handlers: [handler])
        logger.enabled = true
        logger.log("blah")
        XCTAssert(handler.logged.count == 1)
        XCTAssert(handler.logged[0] as! String == "blah")
    }
    
    func testLoggingDisabled() {
        let handler = TestHandler("test")
        let logger = Logger("test", handlers: [handler])
        logger.enabled = false
        logger.log("blah")
        XCTAssert(handler.logged.count == 0)
    }
    
    func testSettings() {
        let defaults = UserDefaults.standard
        // reset
        defaults.removeObject(forKey: "logs+")
        defaults.removeObject(forKey: "logs-")
        
        // test the -logs parameter
        defaults.set("test1,test2", forKey:"logs")
        let l1 = Manager().enabledLogs
        XCTAssertTrue(l1.contains("test1"))
        XCTAssertTrue(l1.contains("test2"))

        // test the logs+ parameter
        defaults.set("test1,test2", forKey:"logs")
        defaults.set("test3", forKey:"logs+")
        let l2 = Manager().enabledLogs
        XCTAssertTrue(l2.contains("test1"))
        XCTAssertTrue(l2.contains("test2"))
        XCTAssertTrue(l2.contains("test3"))
        defaults.removeObject(forKey: "logs+")
        
        // test the logs- parameter
        defaults.set("test1,test2", forKey:"logs")
        defaults.set("test1", forKey:"logs-")
        let l3 = Manager().enabledLogs
        XCTAssertFalse(l3.contains("test1"))
        XCTAssertTrue(l3.contains("test2"))
        XCTAssertFalse(l3.contains("test3"))
        defaults.removeObject(forKey: "logs-")
        defaults.removeObject(forKey: "logs")
    }
    
    static var allTests = [
        ("testLoggingEnabled", testLoggingEnabled),
        ("testLoggingDisabled", testLoggingDisabled),
        ("testSettings", testSettings),
        ]
}
