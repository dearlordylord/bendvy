# Typed component lifecycle controls (#27)

Run `python3 experiments/query-composition/lifecycle-controls/run.py`.
The default build/log output is `/tmp/bendvy-lifecycle-controls`;
`BENDVY_LIFECYCLE_OUTPUT` selects another destination. The checked-in
`evidence/receipt.json` pins the exact source hashes, commands, process limits,
exit codes and literal JS/Native outputs of the verification run.

Lifecycle identity follows the closed typed family lens to its actual
`Column<Schema,Component>` owner. No lookup uses `Family.name`; two names
identical in the fixture reach independent columns. Metadata is Data but
component owners, including their complete Arrays, remain affine Type.
Ordinary `replace` and actual deferred `structural_replace` update lifecycle
metadata after a successful owner swap. Projection/raw swaps are neutral.
`Col.clear` removes payload and metadata for schema-owned structural cleanup.

The bounded clock is U32. Writes at 4294967295 reject with `CapacityExceeded`
before taking the incoming owner or changing storage. Raw clock advancement
saturates. Failed transactions restore exact prior component stamps and owners;
the monotonic world clock retains unused positions. This prevents rollback from
invalidating earlier committed stamps and keeps subsequent observations ordered.
The boundary fixture also rolls back a successful last-clock write at exhaustion,
so inverse restoration cannot require another available write-clock position.

Four fixture entry points pass both backends:

- `stamps.bend`: initial absence, insertion, equal-value replacement, three
  tentative writes followed by failure, exact restored two-cell owned payload,
  identical family names, removal and re-addition.
- `column.bend`: observing payload presence preserves stamps; explicit structural
  clearing removes the metadata entry.
- `cursors.bend`: actual registrations and `run_to_cursor`, two independent
  readers, repeat suppression, tentative failed writes, unchanged failed cursor,
  successful retry and later independent observation.
- `boundaries.bend`: queued replacement is invisible before barrier, stamp appears
  after barrier, last-clock rollback, exhaustion preserves the incoming owner,
  original stamp and saturated clock.

Checker limit is five seconds; emission30, Clang120 and runtime5 match the
existing diagnostic limits. Existing approved private Clang19 is used without
installing dependencies. These are finite executable observations, not laws,
proofs, universal refinement, query access acceptance or performance acceptance.
The caller-owned schema must use `Col.clear` for despawn cleanup. Full removal
streams, retention policy, production clock policy and representative scaling
remain full-core follow-ups; this list-backed metadata is a bounded implementation
whose performance cost requires fresh application measurements.
