// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 31/01/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(watchOS) && (!os(iOS) || targetEnvironment(simulator))

import Logger
import XCTest

public extension XCTestCase {
    static let DefaultFatalErrorTimeout = 1.0

    /**
      Assert that a fatal error has been reported via the Log Manager.
     */

    @discardableResult func XCTAssertFatalError(timeout: TimeInterval = XCTestCase.DefaultFatalErrorTimeout, testcase: @escaping () -> Void) -> Any? {
        func unreachable() -> Never {
            // run forever, to simulate a function that never returns
            repeat {
                RunLoop.current.run()
            } while true
        }

        let expectation = expectation(description: "expectingFatalError")
        var fatalLogged: Any?

        let _ = Manager.shared.installFatalErrorHandler { logged, _, _, _ in
            fatalLogged = logged
            expectation.fulfill()
            unreachable()
        }

        DispatchQueue.global(qos: .default).async(execute: testcase)

        wait(for: [expectation], timeout: timeout)

        Manager.shared.resetFatalErrorHandler()
        return fatalLogged
    }

    /**
     Assert that a fatal error has been reported via the Log Manager, and check
     that the message/object logged matches an expected value.
     */

    func XCTAssertFatalError<T: Equatable>(equals: T, timeout: TimeInterval = XCTestCase.DefaultFatalErrorTimeout, testcase: @escaping () -> Void) {
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

    func XCTAssertFatalError<T>(testing: (T) -> Bool, timeout: TimeInterval = XCTestCase.DefaultFatalErrorTimeout, testcase: @escaping () -> Void) {
        let result = XCTAssertFatalError(timeout: timeout, testcase: testcase)
        guard let error = result as? T else {
            XCTFail("unexpected message type: \(String(describing: result))")
            return
        }

        XCTAssertTrue(testing(error))
    }
}

#endif
