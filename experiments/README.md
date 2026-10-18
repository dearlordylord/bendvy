# Temporary experiments

This directory is disposable working state, not a source or evidence archive.
Only this README is tracked. History remains in Git before this cleanup.
Archive reference: `323bec96d9b86855cd738dd4f096932fc297bba7:experiments/`.
Inspect an old file with `git show <commit>:experiments/<path>`; do not restore
the archive wholesale to satisfy old documentation links.
Tracked edits that were uncommitted at cleanup are preserved in recovery commit
`05114454b13f7d64f2f525374a1f7adcc8cd4768`
(`archive/experiment-edits-20261018`), not in the active source tree.

Each temporary subdirectory must state `Why:` (a current question) and
`Remove when:` (an observable completion condition) in a short README.
"It existed before" and historical receipts are not reasons to keep it.
Delete the directory when the task ends; use TemporaryDirectory for build outputs.
Run `python3 scripts/check-experiment-state.py --clean` to discard local work.
The local budget is 100 entries including directories; the check stops at 101.

Durable fixtures belong in test-fixtures, with a current consumer and purpose.
Keep runnable inputs and minimal expected outputs, not compiler/evidence archives.
