# PR #66 integration

PR #66 is merged on master at `018005c636928e19b583b2de3757c264c814784b`. The shared command runner replaces retired local process owners. Later relation and machine recipes have been reconciled with that API; the invalid historical relation `run-v3.py` and machine `owned-exec.py` are retired, with their original bytes retained in Git history and local preservation archives. Existing receipts are unchanged and historical.

Current work was preserved before merging: 1,200 overlapping or retired files were round-trip SHA-256 verified in `.artifacts/pr66-preservation-1791382401748419025/`. Unrelated core and feature work remains outside this integration commit. The structural infrastructure check covers tracked maintained entrypoints; local untracked research and preservation archives are outside its shipping scope.

Validation: `sh .githooks/pre-commit` checks 19 real-process controls, four log controls, seven tool-pin controls and four statistics controls, plus staged Python syntax/path misuse and whitespace checks. No Bend/application acceptance is renewed by these infrastructure checks.

The owner fork changes measurement overhead. Fresh preparation and timing controls are required before reporting current performance comparisons. The CI template remains inactive at `ci/workflows/infrastructure.yml`; the PR records the credential workflow-scope limitation.
