# Pre-release Cleanup

Final cleanup for 3.0.0, done while Sam was away, from the candidates listed after the actor cleanup.

## Changes

- `Manager.shared` is a plain `static let`. It used to store the manager in the main thread's dictionary and `unsafeBitCast` it back, so that a library linked twice would share one manager. That depended on two copies of the type having the same layout, and touched the thread dictionary from whichever thread first used the manager. Linking the library twice is a build problem to fix in the app.
- `Manager.defaultHandler` uses `OSLogHandler` wherever `os` can be imported. The old platform list left out tvOS, which therefore printed to stdout although `OSLogHandler` was built for it. `OSLogHandler` uses the same condition.
- LoggerUI's built-in labels, "All Channels" and "Reset to Defaults", come from a string catalog in the package with symbolic keys (`channels.all`, `channels.reset`), following Commands. Previously they were looked up in the host app's bundle. The package declares `en` as its default localization. `AllChannelsToggleView` and `ResetChannelsButton` gain separate initialisers for the default and a custom label, because a public default argument cannot refer to the internal resources.

## Not Done

Coalescing settings saves was skipped. Each `Channel.enabled` change saves the settings, but `UserDefaults` writes are cheap and in memory, and batching would need a deferred save whose timing depends on actor scheduling, which no test could pin down. Bulk changes through `Manager.setEnabled(_:)` already save once.

## Validation

A new test checks that the labels resolve from the catalog rather than to their keys. `agt format` was clean, `agt validate --fast` passed, and the SwiftUI example workspace built for macOS with the package tests passing. Linux CI will show whether the string catalog builds there; LoggerUI's code is compiled out on Linux, but its resources are still processed.

## CI Follow-up

Linux CI showed that the string catalog builds there, but the mismatched-default exit test failed: CI also runs the tests in release builds, where `assert` is compiled out, so nothing exits. The test now runs only in debug builds. A requested Copilot review did not run, because the requesting account had no remaining review quota.
