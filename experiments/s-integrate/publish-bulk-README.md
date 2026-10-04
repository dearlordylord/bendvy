# Actual affine batch publication

Run `python3 experiments/s-integrate/publish-bulk-run.py`.

The actual E11 driver exposed a JavaScript machine-stack failure while publishing
65,537 staged Spawn commands, before any reader or renderer. The independent
publication fixture reproduces this for both schemas: Native passes, JS fails.
`publish-bulk-baseline.json` preserves those results and original closure hashes.

`storage.publish` now reverses the affine staged list and prepends its reversed
traversal onto the existing pending queue using tail-recursive `List.reverse.go`.
The exact `staged ++ pending` order is preserved; no command payload is copied or
reconstructed. Publication remains separate from explicit application.

Both schemas at 1/17/65,537 commands now pass Native/JS under the unchanged five
second runtime limit. The receiver queue contains an existing issued Spawn;
complete getter canaries and subsequent application/removal/despawn check all
actual payload cells, metadata, issued handles and lifecycle order. Three compiling
mutants reverse newer commands, drop the existing queue or swap old/new batches;
all are detected in both schemas on both backends. The original failure is retained.

Evidence pins the local import closure. This is a finite prerequisite repair;
full E11 dispatch/retention, nonuniform payload coverage and independent review
remain separate gates. No universal proof or performance acceptance is claimed.
