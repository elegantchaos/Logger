# PR #34 local fixes and cleanup

Applied the findings from [the review](2026-10-15-review-pr-34.md) locally on
`integration/bookish`, without committing or pushing.

## Workflow

Regenerated the workflows and README header with ActionBuilderTool v2.2.4.
The caller now delegates to repository-local reusable Swift and Xcode jobs.
`.actionbuilder.json` explicitly keeps the existing Swift 6.2/6.3 matrix; the
builder's newer defaults would otherwise introduce Swift 6.4 and an `xcode-27`
runner label.

Locally corrected the shared Xcode workflow to fail when scheme discovery,
CoreSimulator discovery, destination listing, platform downloads or simulator
boot preparation fail. Failure reports retain the relevant logs and write an
error summary. Xcode application paths are enumerated with `printf` and read
with `IFS= read -r`, removing the ShellCheck findings.

Added `Extras/Scripts/test-workflow.sh` to execute the checked-in shell steps
with mocked Xcode tools. Five setup-failure cases were demonstrated failing
before the fix. All fourteen final cases pass, covering scheme success/failure,
iOS/tvOS/watchOS selection, existing/downloaded simulators, already-booted
devices, unsupported platforms and failures before/after downloads or during
booting. The independent `workflow-validation.yml` runs these checks in CI.

`.github/workflows/README.md` documents generation, validation and the local
patches that regeneration currently overwrites.

## Schemes and Swift Testing

Removed the standalone LoggerTestSupport and LoggerKit schemes. Removed
LoggerTestSupport, LoggerKit and LoggerKitTests references from the package
scheme, leaving the actual Logger/LoggerUI/LoggerTests targets.

Restored the explicit false comparison in the watcher regression test and
updated that file's header to the current standard. Logging implementation
and behavior are unchanged.

## Deferred generator work

Appended a dated follow-up to ActionBuilderCore's `ROADMAP.md`, describing the
failure-handling and Xcode-enumeration fixes, the Logger regression script and
the required generator/EndToEnd validation. No generator code was changed.
A one-time reminder is scheduled for 2026-10-16 at 09:00 Europe/London.

## Validation

- `bash Extras/Scripts/test-workflow.sh`: all fourteen cases pass.
- `bash -n Extras/Scripts/test-workflow.sh`: passes.
- `shellcheck Extras/Scripts/test-workflow.sh`: no findings.
- `actionlint .github/workflows/*.yml`: no findings.
- `xmllint --noout .swiftpm/xcode/xcshareddata/xcschemes/*.xcscheme`: passes.
- `agt format`: ran across the repository; two pre-existing findings remain in
  unchanged Channel.swift and Manager.swift. Incidental formatter changes in
  six unrelated source/example files were restored to keep the cleanup focused.
- `swift format lint --strict Tests/LoggerTests/LoggerUITests.swift`: no findings.
- Final `agt validate --fast`: passes; all three package tests execute.
  The initial broader fast pass also built Logger, LoggerUI and the command-line
  example, which reported existing Logger deprecation warnings.
- `swift test --configuration release`: all three tests pass after rerunning
  the same command outside the sandbox. The sandboxed attempt failed while
  starting SwiftPM's manifest sandbox (`sandbox_apply: Operation not permitted`).
- `xcodebuild test` on the cleaned Logger-Package scheme for macOS: all three
  tests pass outside the sandbox. Xcode emitted an AppIntents metadata warning.
- `git diff --check`: passes in Logger and ActionBuilderCore.
- Searched the workflow/scheme directories for successful skip exits and obsolete
  LoggerKit/LoggerTestSupport references: none remain.

Checked each changed file against the applicable baseline, records, Git,
Swift language/testing/concurrency and validation guidance. The changed Swift
file has the standard header and declaration documentation; changed scripts
and workflows pass their linters. Remaining formatter findings are in unchanged
code. ActionBuilderCore's edit is a documentation-only follow-up.

Full platform validation, actual Linux/mobile CI execution, UI/accessibility
checks and Thread Sanitizer were not run. The simulator regression checks mock
the tools; they verify failure propagation and selection logic, while actual
runner/runtime availability remains for CI. No commits, pushes or merge were
requested or performed.
