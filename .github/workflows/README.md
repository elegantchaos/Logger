# Workflow maintenance

Run `ActionBuilderTool` at the repository root to generate the caller workflow
and the shared Swift/Xcode job workflows. `.actionbuilder.json` preserves the
Swift 6.2/6.3 validation matrix.

`ActionBuilderXcodeJob.yml` includes local fixes that the generator does not yet
emit: package-scheme discovery and simulator setup failures must fail the job,
and Xcode enumeration uses a quoted path list instead of parsing `ls` output.
Regeneration overwrites these fixes. Preserve them until ActionBuilderCore
implements them; its `ROADMAP.md` records the follow-up.

After regenerating or editing workflows, run:

```sh
bash Extras/Scripts/test-workflow.sh
actionlint .github/workflows/*.yml
```

The regression script runs the checked-in scheme-discovery and simulator-selection
shell code with mocked Xcode tools. It covers iOS/tvOS/watchOS selection,
existing/downloaded simulators, already-booted devices, unsupported platforms
and failures during discovery, download and boot.
`workflow-validation.yml` runs these regression checks in CI and is maintained
independently of the generated workflows.
