# Public composed query contracts — #29

Run from the repository root, with a fresh output directory:

```sh
python3 experiments/public-query-contract/verify.py --output .artifacts/query-contract-replay
```

The runner freezes current library/fixture sources, verifies all three reference
HEADs against the tracked manifest, observes actual pinned TS, builds JS and
Native, and validates every full observation. It uses the existing private Clang
19.1.7 installation and no new dependency. Checker/runtime command caps are five
seconds, emission thirty seconds, native compilation 120 seconds. Errors,
timeouts and unintended diagnostic locations fail the runner.

The main Workshop fixture has 16 checkpoints: 15 TS-exact and the approved
foreign namespace divergence. Factory lineage is retained from `World.factory`
through both actual creations. Diagnostic entity IDs are preserved and TS actual
reservations map to application labels. It exercises zero/one/multiple cardinality,
missing/stale/mismatching lookup, optional Queue plus independent Enabled/Locked
filters, successful writes, shared family aliases, complete ascending component
views and structural churn. Query callbacks access actual affine Array-backed
components, not serialized replacement storage.

Additional controls pass actual owned Array lengths 0/9/17 through successful
`single` and write, reject writes through read/undeclared context recovery/
cross-schema handle lookup, and preserve clock, the written family lifecycle stamp, allocation metadata, event count
and a pre-existing deferred queue when multiple-match, mismatch and missing checks reject a body that would write, emit
and despawn. The retained post-barrier observation proves that the original queue
still executes and the rejected body's effects did not.

Two source mutants compile and execute: wrong actual cardinality and wrong
mismatch tag. Both must be detected in JS and Native. No ECS proof or new law is
written or approved by these finite checks. Reader cursor is passed unchanged;
owned registry cursor integration remains the schedule-reader work.

`--timing` additionally retains five complete outputs and whole-process samples
per backend against the same frozen feature workload. Timing is diagnostic and
must be collected with other benchmark workers stopped; it is not a hot-path or
product performance qualification. Root independently runs the unchanged #28
regression gate before delivery.
