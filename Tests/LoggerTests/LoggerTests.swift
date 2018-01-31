import XCTest
@testable import Logger

class TestHandler : LogHandler {
  var logged : [Any] = []
  
  override func log(channel: Logger, context: LogContext, logged: () -> Any) {
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

    static var allTests = [
        ("testLoggingEnabled", testLoggingEnabled),
        ("testLoggingDisabled", testLoggingDisabled),
    ]
}
