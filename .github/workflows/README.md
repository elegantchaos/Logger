# Workflow maintenance

Run `ActionBuilderTool` v2.2.5 or later at the repository root to generate the
caller workflow and the shared Swift/Xcode job workflows. `.actionbuilder.json`
preserves the Swift 6.2/6.3 validation matrix.

The generated Xcode job fails when package-scheme discovery or required simulator
setup fails. Xcode enumeration uses a quoted path list to preserve application
names containing spaces. All three generated workflows can be regenerated
directly without local patches.

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
