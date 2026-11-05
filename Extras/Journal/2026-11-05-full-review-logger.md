# Full Review Logger

Reviewed the Logger package at `c65d312bc53e1cc74355a412e6889a540a2db8ba`, including the `Sources/Logger`, `Sources/LoggerUI` and test targets, against the package's stated purpose of configurable, persistent channel logging. Source coverage was complete; platform runtime, accessibility, and external consumer checks were not performed. No decision log exists. The same session fixes the reported LoggerUI watcher, event delivery, row layout and example project issues; those changes are on `feature/logger-ui-fixes`.

## Findings

- **Should fix: enabled state persistence saves every channel.** `ManagerSettings.saveEnabledChannels` maps all channels to IDs without filtering by `enabled`. A disabled channel is consequently saved as enabled and reappears enabled at the next launch. Saving also discards previously enabled channel IDs that have not registered yet.
- **Should fix: shutdown does not reliably drain or close the logging system.** Registration happens in an unstructured task, so shutdown can run before a new channel registers. `Manager.shutdown()` only asks the current channels to finish their input; it does not wait for their handlers to drain, call `Handler.shutdown()`, or finish manager events when no channel is running. `Manager.run(channel:)` finishes events as soon as the last currently running channel ends, even if the manager is still in use.
- **Should fix: fatal handler access is unsynchronized.** `Channel.fatal` reads `Manager.fatalHandler` through `nonisolated(unsafe)` while actor methods can replace it concurrently. This is a data race on a closure value.
- **Should fix: `autoRun` is ignored.** The channel initializer accepts `autoRun: false` but always starts the manager task. The test helper relies on the option and cannot control the channel lifetime as its documentation suggests.
- **Should fix: the command-line example is stale.** Its package uses a relative Git URL and the `main` branch, producing a separate copy instead of the working checkout; its source refers to removed API. Fast validation currently fails while resolving this dependency in the sandbox.
- **Suggestion: reconcile API documentation and standards.** Several existing source files lack required declaration comments and standard headers; `Sources/LoggerExample/main.swift` also refers to removed API and is not a manifest target. The OSLog cache is read using a default but never populated. Existing `Channel.swift` produces a lint warning for ambiguous overloads.

## Validation and limits

The added LoggerUI regression tests cover watcher lifetime, multiple observers and synchronous controls. The original multiple-observer implementation failed the new test. The standalone SwiftUI example was rewired to the checkout's root package and its scheme repaired. The macOS example build and all six package tests passed through `agt validate`; fast validation across discovered packages was blocked resolving the command-line example's local Git dependency. No iOS simulator, accessibility, interactive UI, Thread Sanitizer, Linux build or downstream consumer validation was performed.
