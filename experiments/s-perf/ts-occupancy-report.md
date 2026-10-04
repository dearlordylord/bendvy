# Actual TS Readers physical diagnostics

Passed all six frozen Motion/Health ×64/256/1024 Readers cases, comparing complete authored public observations against the unchanged authoritative reference. Separate warmup and measured outputs expose actual retained batches/values, lifecycle entries, reader slots/cursors/unread/lag, pending commands and maximum staged component/resource operations sampled before destructive drain.

`ts-occupancy-prepare.py` copies exact pinned TS sources and its ESM package boundary into a fresh destination, adding inspectors only to the copy. Runtime instrumentation keeps strong references to actual reader identities solely for diagnostics; it is excluded from timing/RSS comparisons. Inspectors do not read or drain the logical streams and do not add systems or callbacks.

Three executed counter mutants (zero cached size, missing first batch values, lost stream holder) are detected while callback data remains identical. Neither physical shape nor batch representation is assumed equal to Bend. Final unread zero is tested alongside nonzero physical retention; it is not interpreted as zero allocation.

Replay: `python3 experiments/s-perf/ts-occupancy-run.py --build-dir /tmp/bendvy-ts-physical-fresh --cpu 4`. Destination must be fresh and references must match `baseline.json`. Node24.20.0; runtime5s. `ts-occupancy-evidence.json` records all source/adapter pins and actual samples. Earlier missing-ESM and ambiguous mutation-anchor failures remain in separately labeled evidence; they are not mutant detections.

Local raw archive `.artifacts/indexed-ts-occupancy-20261004.tar.gz` SHA256 `e962fde38ee9589d9f499ebbcafe050af68ce8ec3273da432fc8393c5447a06d` preserves materialized sources, outputs and mutant runs. This archive is local; tracked runners/pins provide reconstruction rather than assuming a GitHub download exists. Finite diagnostic comparison is not universal metric correctness or product acceptance.
