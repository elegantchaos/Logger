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
  defaults.set(1.23, forKey:"test")
      defaults.set("test1,test2", forKey:"logs")
      print(Manager().enabledLogs)
      defaults.set("test3", forKey:"logs+")
      print(Manager().enabledLogs)
      defaults.set("test1", forKey:"logs-")
      print(Manager().enabledLogs)
  }
    static var allTests = [
        ("testLoggingEnabled", testLoggingEnabled),
        ("testLoggingDisabled", testLoggingDisabled),
        ("testSettings", testSettings),
    ]
}
