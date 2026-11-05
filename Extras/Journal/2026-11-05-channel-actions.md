# Channel Actions

Reworked the Logger and LoggerUI channel-control API so that an app can route channel changes through its own action layer, such as Commands with undo, without making the direct case more complex. This follows the direction in [Logger Consumer Review](2026-11-05-logger-consumer-review.md): Logger owns state changes, LoggerUI renders, and the app's command layer calls Logger.

## Changes

- `Manager.setEnabled(_:)` applies a `ChannelStates` dictionary to registered channels and returns the previous states of only the channels that changed. Passing the result back restores exactly those channels, which gives commands undo and redo for both single and bulk changes; inverting a bulk change would be wrong when it started from a mixed state. `setAllEnabled(_:)` builds on it. Changes are applied with an atomic exchange, emit `channelUpdated` per changed channel, and save settings once.
- LoggerUI's `ChannelActions` protocol lets a host receive the controls' change requests. Without it, `ChannelWatcher` changes the channels directly and refreshes its snapshots at once, as before.
- Views bind to `$watcher[enabled: id]` and `$watcher.allEnabled` through `@Bindable`. This removes `ChannelWatcher.binding(for:)`, the host-binding initialisers and `ChannelToggleView`, which had become a bare `Toggle`. These existed only to accept `Binding(get:set:)` values, which the SwiftUI guidance rules out, as it does closures passed as view inputs.
- The master toggle keeps its mixed state yet makes one change per click: it uses `Toggle(sources:)` over two sources, any-enabled and all-enabled, and only the all-enabled write acts.
- `LoggerChannelsView` no longer creates its own watcher. It previously initialised `@State` from an init parameter, which goes stale; hosts now own the watcher and pass it in.

## Validation

`agt format` was clean. Red/green steps ran through `agt validate --target Logger` and `--target LoggerUI`; the new tests failed against stubs before implementation. `agt validate --fast` passed, and the SwiftUI example workspace built for macOS with the package tests passing, inside the sandbox.

The master toggle's single-change behaviour depends on how SwiftUI writes collection-toggle sources, and has not been exercised interactively. The mixed-state click direction, VoiceOver and other platforms are also unverified. Stack and ActionStatus call `LoggerChannelsView` without a watcher and will need a one-line update when they adopt this version.
