// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(iOS) || targetEnvironment(simulator)

import XCTest
import Logger

extension XCTestCase {
    public static let DefaultFatalErrorTimeout = 2.0
    

    /**
     Assert that a fatal error has been reported via the Log Manager.
    */
    
    @discardableResult public func XCTAssertFatalError(timeout: TimeInterval = XCTestCase.DefaultFatalErrorTimeout, testcase: @escaping () -> Void) -> Any? {
        func unreachable() -> Never {
            repeat {
                print("unreachable...")
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            } while (true)
        }

        let expectation = self.expectation(description: "expectingFatalError")
        var fatalLogged: Any? = nil
        
        let _ = Logger.defaultManager.installFatalErrorHandler() { logged, channel, _, _ in
            fatalLogged = logged
            expectation.fulfill()
            unreachable()
        }
        
        DispatchQueue.global(qos: .default).async(execute: testcase)
        
        wait(for: [expectation], timeout: timeout)
        
        Logger.defaultManager.resetFatalErrorHandler()
        return fatalLogged
    }
 
    /**
     Assert that a fatal error has been reported via the Log Manager, and check
     that the message/object logged matches an expected value.
     */

    public func XCTAssertFatalError<T: Equatable>(equals: T, timeout: TimeInterval = XCTestCase.DefaultFatalErrorTimeout, testcase: @escaping () -> Void) {
        let result = XCTAssertFatalError(timeout: timeout, testcase: testcase)
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
    
    public func XCTAssertFatalError<T>(testing: (T) -> Bool, timeout: TimeInterval = XCTestCase.DefaultFatalErrorTimeout, testcase: @escaping () -> Void) {
        let result = XCTAssertFatalError(timeout: timeout, testcase: testcase)
        guard let error = result as? T else {
            XCTFail("unexpected message type: \(String(describing: result))")
            return
        }

        XCTAssertTrue(testing(error))
    }
}

#endif
