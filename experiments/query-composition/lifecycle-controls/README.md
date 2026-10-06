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

Five fixture entry points pass both backends:

- `self-writes.bend`: actual `Q.each_since` Required+Changed selection and
  registered `run_tracked`, success consumes its own writes (one row then zero),
  a failed self-write preserves cursor and the exact prior stamp/two-cell Array,
  retry sees one row, then repeat sees zero. The runner executes pinned TS
  `self-writes-reference.mjs` and observes `[1,0,1,1,0]` plus the same complete
  restored retry payload. `System.cursor` returns the affine registry beside its
  position; the trusted runner adapter threads that actual value into query args.
  `run_tracked` captures authoritative post-success clock. Existing explicit
  `run_to_cursor` retains its caller-selected cursor behavior for compatibility.
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

The runner also copies the frozen sources into its output directory, plants a
compilable one-tick cursor omission (`postClock` becomes `postClock-1`) and runs
the same actual query control on JS. The expected repeat suppression fails at
`self-repeat`; the receipt records the mutant hash and complete output. This
finite source mutation is detected without modifying the original source tree.
