# Adopt ActionBuilderTool v2.2.5

Regenerated Logger's three generated workflows and README header with the
Mint-installed ActionBuilderTool v2.2.5, following the generator fix in
[ActionBuilderCore PR #9](https://github.com/elegantchaos/ActionBuilderCore/pull/9).
The generated Xcode workflow exactly matches Logger's local corrections apart
from its version stamp and removal of the local-patch notice. Failure handling,
Xcode enumeration and the explicit Swift 6.2/6.3 matrix are unchanged.

Updated the workflow maintenance README to require v2.2.5 or later and describe
direct regeneration. Kept Logger's fourteen consumer workflow regression checks
and independently maintained CI workflow.

Validation:

- All fourteen workflow regression cases pass before and after regeneration.
- Actionlint reports no findings across all workflow YAML files.
- ShellCheck and shell syntax validation pass for the unchanged regression script.
- A second tool run reproduces the generated workflows and README byte for byte.
- `git diff --check` passes; no active local-patch notices remain.
- Checked the changed files against the baseline standards, scripting, Git and
  records guidance. No checklist exceptions were found.

Package tests, Swift formatting/validation and real simulator/remote CI checks
were not repeated: the executable workflow content is identical to the verified
local corrections, and no Swift code changed. No release was created.
