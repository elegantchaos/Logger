// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

@testable import LoggerKit
import LoggerTestSupport
import XCTest

#if canImport(UIKit)

    import UIKit

    class ChainableResponderTests: XCTestCase {
        func testChaining() {
            let r1 = ChainableResponder()
            let r2 = ChainableResponder()

            XCTAssertNil(r1.next)
            XCTAssertNil(r2.next)
            XCTAssertEqual(r1.chain, [r1])
            XCTAssertEqual(r2.chain, [r2])

            r1.install(responder: r2)
            XCTAssertNil(r2.next)
            XCTAssertEqual(r1.chain, [r1, r2])
            XCTAssertEqual(r2.chain, [r2])
        }
    }

#endif
