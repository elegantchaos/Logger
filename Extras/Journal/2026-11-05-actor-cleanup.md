# Actor Cleanup

Audited Logger's actors after asking whether a per-channel actor made sense. Most did not: the actors protected no mutable state, and served only as a way to be `Sendable` and as somewhere to run a task. Since #37 and #38 already change the API enough for a 3.0.0 release, the other concurrency API changes are made now as well.

## Changes

- `Channel` is a `Sendable` final class. Its only changing state is the atomic enabled flag, and logging never used the actor. `shutdown()` is now synchronous, and the drain loop `run()` is `@concurrent`, so channels drain on the concurrent executor rather than on the manager actor that awaits them. The ignored `autoRun:` initialiser parameter is gone.
- `BasicHandler`, `StreamHandler` and `OSLogHandler` are `Sendable` final classes. `BasicHandler.tag(for:)` is now public and synchronous, so output closures no longer await it; the closure type is `BasicHandler.Output` and stays `async` for output that needs to wait. `StreamHandler` no longer prints every item.
- `OSLogHandler` caches one `OSLog` per channel behind a `Mutex`. Its previous cache was only ever read, so it created a new log for every message.
- `Handler.shutdown()` is removed: nothing called it.
- `Manager` stays an actor; it owns real mutable state. Its fatal handler was `nonisolated(unsafe)`, written while isolated and read from any thread; it is now behind a `Mutex`, `FatalHandler` is `@Sendable`, and installing or resetting it no longer needs `await`. Shutting down channels no longer needs a task group. The unused `changedChannels` property is gone.
- `YieldingSequence` is internal and uses `AsyncStream.makeStream` instead of the closure initialiser and a force unwrap.
- `LoggedItem` moved to its own file.

## Validation

This is a behaviour-preserving refactor apart from the `OSLogHandler` cache, so the existing tests establish correctness. `agt format` was clean, `agt validate --fast` passed with no compiler warnings from the package, and the SwiftUI example workspace built for macOS with the package tests passing. The `OSLogHandler` cache has no test, because its log lookup is private and its output goes to the unified log. Linux and the other Apple platforms were not built locally.
