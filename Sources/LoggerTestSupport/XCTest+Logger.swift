// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(iOS) || targetEnvironment(simulator)

import XCTest
import Logger

extension XCTestCase {
    /**
     Assert that a fatal error has been reported via the Log Manager.
    */
    
    public func XCTAssertFatalError(testcase: @escaping () -> Void) -> Any? {
        func unreachable() -> Never {
            repeat {
                RunLoop.current.run()
            } while (true)
        }

        let expectation = self.expectation(description: "expectingFatalError")
        var fatalLogged: Any? = nil
        
        let previousErrorHandler = Logger.defaultManager.installFatalErrorHandler() { logged, logger, _, _ in
            fatalLogged = logged
            expectation.fulfill()
            unreachable()
        }
        
        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)
        
        wait(for: [expectation], timeout: 1.0)
        
        let _ = Logger.defaultManager.installFatalErrorHandler(previousErrorHandler)
        return fatalLogged
    }
 
    /**
     Assert that a fatal error has been reported via the Log Manager, and check
     that the message/object logged matches an expected value.
     */

    public func XCTAssertFatalError<T: Equatable>(equals: T, testcase: @escaping () -> Void) {
        let result = XCTAssertFatalError(testcase: testcase)
        guard let error = result as? T else {
            XCTFail("unexpected message type: \(String(describing: result))")
            return
        }

        XCTAssertEqual(error, equals)
    }

    /**
     Assert that a fatal error has been reported via the Log Manager, and check
     that a test passes.
     */
    
    public func XCTAssertFatalError<T>(testing: (T) -> Bool, testcase: @escaping () -> Void) {
        let result = XCTAssertFatalError(testcase: testcase)
        guard let error = result as? T else {
            XCTFail("unexpected message type: \(String(describing: result))")
            return
        }

        XCTAssertTrue(testing(error))
    }
}

#endif
