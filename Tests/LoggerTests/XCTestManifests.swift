import XCTest

extension LoggerTests {
    static let __allTests = [
        ("testArgumentsWithoutLoggingOptions", testArgumentsWithoutLoggingOptions),
        ("testChannelComparison", testChannelComparison),
        ("testChannelComplexName", testChannelComplexName),
        ("testChannelSimpleName", testChannelSimpleName),
        ("testContextDescription", testContextDescription),
        ("testDebugLogging", testDebugLogging),
        ("testEnabledViaSettings", testEnabledViaSettings),
        ("testFatalError", testFatalError),
        ("testHandlerComparison", testHandlerComparison),
        ("testLoggingDisabled", testLoggingDisabled),
        ("testLoggingEnabled", testLoggingEnabled),
        ("testSettings", testSettings),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LoggerTests.__allTests),
    ]
}
#endif
