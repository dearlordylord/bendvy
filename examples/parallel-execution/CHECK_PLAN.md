# Ordinary execution check plan

The reviewed source is this committed example, `test-fixtures/common/column-observation.bend`
and the transitive Bend import closure. `expected.stdout` is the full finite
observation derived from the scenario, not a generated-backend baseline. Final
review independently checks that derivation against the source and contract.

The new normal-CI entry is `bash examples/parallel-execution/check.sh`. Existing
`examples/check.sh` discovers it automatically. It uses `examples/common.sh`
without changing that shared runner. Source checks use one allowed CPU and the
same CPU lock naming as `scripts/bend-check`; backend work retains the shared
heavy lock. Existing outer example runs pass their already-held lock through
`BENDVY_EXAMPLE_LOCK_HELD`.

The script checks the full application and four valid controls, then requires sixteen
invalid controls to exit exactly 1 with their intended expected/observed diagnostic.
It rejects timeouts, signals, syntax errors and unrelated missing definitions as
successful controls. Each source check has a 15-second wall limit. JavaScript
emission and execution retain the shared runner's 30-second limits. Native
emission uses that same path, native compilation has 120 seconds and each run
has 5 seconds. Native is enabled by `BENDVY_EXAMPLE_NATIVE=1`, with explicit
`--threads 1` and `--threads 4` and `--gpu off`. Every backend compares directly
with the same complete `expected.stdout`.

Local final verification selects the already-qualified matching resource bundle
`/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35`, Node from the installed
configuration, and the existing Clang 19 wrapper with
`BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root`. CI uses its pinned Bend
2.0.37 and Clang 19 configuration. No installed tool or generated C is changed.
This plan does not qualify new compiler behavior or claim concurrency for this
single-system example.

Launch the new script only after independent review of this frozen source and
plan. Existing unchanged shared-runner commands remain development checks.
Normal CI's temporary build outputs are disposable. Final delivery retains
source/tool hashes, raw outputs and diagnostics separately under the existing
evidence workflow. Source changes require a source-bound successor rather than
relabeling earlier receipts.
