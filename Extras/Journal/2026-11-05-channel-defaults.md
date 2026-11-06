# Channel Defaults

Replaced `alwaysEnabled:` with a default state, and made it work. The flag was meant to make a channel start enabled when nothing was saved for it, but the settings stored only a set of enabled identifiers. A disabled channel was indistinguishable from one that had never been set, so a channel with the flag came back on at every launch however often it was turned off, and `-logs "-name"` could not turn it off either.

## Changes

- `Channel(_:handler:default:manager:)` takes a `Channel.State`, `.enabled` or `.disabled`, defaulting to `.disabled`; `Channel.defaultState` reports it. "Default" rather than "initial", since saved state takes precedence. Channels sharing an identifier must declare the same default; a debug assertion catches a mismatch, which would otherwise resolve silently to the first channel created.
- `ManagerSettings` reads and saves `Manager.ChannelStates` rather than a set of enabled identifiers. Only channels that differ from their default are saved, so a channel back at its default follows later changes to that default. A saved full identifier takes precedence over a short name, and a short-name state that disagrees with a registered channel is removed when saving, as before. `UserDefaultsManagerSettings` stores the states as a dictionary under a new key; the old `logs-persistent` value is ignored, which loses existing saved choices once.
- Command-line modifiers keep their syntax and are still saved. `name` and `+name` enable, `-name` disables, and `=` first clears the saved states, returning every channel to its default. Sam recalled that a bare name once applied only to the current run; the parser has treated it as a synonym for `+name` since December 2018, and session-only state was not reinstated.
- `Manager.resetToDefaults()` returns registered channels to their defaults and returns the previous states of those it changed, like the other state changes, so commands can undo it. `ChannelActions` gains `resetToDefaults()`, `ChannelWatcher` gains `resetToDefaults()` and `isAtDefaults`, and `ResetChannelsButton` offers it; `LoggerChannelsView` and the example's Debug → Channels menu include the button.

## Validation

The new tests failed against stubs before implementation. A first red run hung, because stubbing out defaults left `.enabled` channels silent and the stream-based logging tests wait for output; the default lookup was implemented first and the remaining stubs then failed as expected. The mismatched-default assertion is covered by an exit test on macOS and Linux. `agt format` was clean, `agt validate --fast` passed without package warnings, and the SwiftUI example workspace built for macOS with the package tests passing.
