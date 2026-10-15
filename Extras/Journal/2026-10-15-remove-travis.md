# Remove obsolete Travis configuration

Removed the root `.travis.yml`, which targeted Swift 5.1, Ubuntu 14.04 and
Xcode 11.3. GitHub Actions provides the package's current platform validation.
Also removed the sole commented Travis formatter command from `.bin/test`.
The active commands in that old helper are unchanged.

Checked the repository for Travis references in source, documentation and hidden
configuration; none remain outside this historical journal entry. The remaining
GitHub Actions workflows pass actionlint. Shell syntax and `git diff --check`
pass, and the changed files meet the applicable baseline, scripting and records
guidance. Package tests and Swift formatting/validation were skipped because
this removes unused CI configuration and a comment without changing Swift code
or executable behavior.
