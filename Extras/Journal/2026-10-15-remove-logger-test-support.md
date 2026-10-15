# Remove LoggerTestSupport

`LoggerTestSupport` held only a commented-out XCTest helper for asserting fatal errors, and
nothing in the Elegant Chaos repositories depended on it. The product, its target, and the
commented-out tests that imported it (`UserDefaultsTests.swift` and the end of
`LoggerTests.swift`) are gone.

Removing a published product breaks anyone who names it, so the next release is v3.0.0.

Shared test helpers now live in ChaosTesting. `Manager.shared` still stores its channel state in
`UserDefaults.standard`, so a test process that touches it writes the `logs` and
`logs-persistent` keys into the test runner's preferences. That is deliberate app behaviour,
and is left as it is.
