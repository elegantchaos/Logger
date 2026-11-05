# Logger Consumer Review

Reviewed Logger and LoggerUI use in the current Stack (`f3adf694`), ActionStatus (`aa361398`, with local changes), ClockSync (`03361577`) and Bookish (`ae90a129`, with local changes) checkouts, alongside Logger PR #37 (`14f38c6`). This is a focused integration review, not a full review of those applications. Local package overrides and their resolved remote versions can differ.

## Findings

- Stack routes directly to `LoggerChannelsView`, which supplies a `Section` rather than a complete list screen. ActionStatus embeds that section in a preferences `List` with its own header. LoggerUI should expose reusable contents and a section, with a list screen owned by the host or provided separately; a menu needs contents without the section header's `HStack`.
- LoggerUI's individual and all-channel controls write directly through `ChannelWatcher`; neither Stack nor ActionStatus routes these changes through Commands. Commands already imports Logger, so Logger must not depend on Commands. Expose observable channel state and a way for a host to provide or construct controls whose changes dispatch host commands, while keeping the direct LoggerUI conveniences for apps without Commands. Bookish decisions 0001 and 0013 allow ordinary control bindings but establish Commands as the action boundary; decide deliberately how the logging controls use that boundary.
- The master toggle treats an empty list as all enabled, and a partial selection as off. Define empty and mixed-state presentation and explicit enable-all/disable-all semantics, including channels registered after the action. Persisting the correct state across launches remains a prerequisite; the package review records the current persistence defect.
- A row displays only a short name and sorts only on that name. Different subsystems can therefore produce indistinguishable rows. Also, independently created channels with equal IDs have separate enabled flags but collapse in the manager's set: Stack contains two `Summarizer` declarations, though whether both are active together was not established. Define duplicate-channel identity/ownership and show disambiguating context when required.
- `alwaysEnabled` currently supplies an initial value and does not prevent a later toggle, despite its name. ClockSync's Discovery and ActionStatus's Startup use it. Clarify the contract before offering an all-off action; neither consumer establishes a requirement that the channel be permanently locked on.
- ClockSync has no LoggerUI integration in its current checkout. Bookish uses Logger but has no current LoggerUI entry; its work plan schedules one. ActionStatus's connection preferences import LoggerUI without using it.
- Bookish decision 0018 assigns user-preference storage and presentation to the app for reusable packages. Logger's default manager constructs a UserDefaults-backed settings implementation, although `Manager(settings:)` is injectable; verify how the planned Bookish integration meets that policy rather than assuming the default is appropriate.

## Direction and Limits

Keep channel identity, state changes, event delivery and persistence in Logger; keep SwiftUI rendering in LoggerUI; let an app's command layer invoke Logger operations. Supply a small read/state and action surface so direct controls and command-driven controls use the same source of truth. Defer handler configuration UI and any new handler model to a later design, while avoiding API assumptions that prevent it.

Read the logging-facing source and dependency declarations, existing hosts, LoggerUI implementation and relevant project guidance. Did not run the applications, exercise menus or accessibility, inspect other worktrees, or validate actual dependency resolution in Xcode. Bookish decision-log coverage is incomplete for this focused cross-project review; architectural compliance is not asserted. No consumer code was changed.

## PR #37 Follow-up

Added persistence tests covering enabled and disabled registered channels across manager instances, preservation of unregistered full identifiers, and removal of a disabled channel's short-name setting. Saving now merges registered channel states with the stored settings; the master toggle is off and disabled when no channels exist. The corresponding tests failed before the fixes and pass with them.

Legacy short-name settings can match channels in multiple subsystems. Disabling a matching channel removes the short-name setting, so an unregistered channel with the same short name cannot retain that ambiguous choice; the existing representation cannot express that distinction. Channel identity and the settings representation remain follow-up work.

Sam converted the standalone example project to Xcode's JSON project format, which requires Xcode 27. Targeted Logger validation passes. Fast validation still fails when the command-line example tries to clone its local Git dependency in the sandbox. The example project's validation could not begin after the conversion: AgentTools reported that Xcode could not read the repository root during discovery. Interactive UI and cross-platform validation were not run.
