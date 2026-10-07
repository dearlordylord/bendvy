# P-QUERY-CONTRACT #29 implementation

Implemented a generic public composed-query `count`, `single`, and `get` path with
exact cardinality/membership errors, requested `entityId` diagnostics and affine
World return. Selection is rolled
back before cardinality checks; successful bodies run once under the existing
closed capability provider and ordinary transaction finish. Existing Compose
execution remains compatible. No component Data-only restriction, dependency,
proof law, checker kernel change or performance allowance was introduced.

## Evidence

The task runner is `experiments/public-query-contract/verify.py`. It freezes source
hashes and tool/reference versions, checks under five seconds, emits both
backends, observes pinned TS and retains all outputs. Commands and exact inputs
are in its receipt. Fifteen complete Workshop checkpoints must equal TS; one
foreign World namespace collision follows the approved MissingEntity divergence.
Actual affine Arrays of lengths 0/9/17 traverse the new single/write path. Three
intended negatives target read-set, undeclared context recovery and cross-schema
lookup. A pending queue/metadata control rejects multiple-match, mismatch and missing calls with a body granting write,
emit and despawn grants, verifies unchanged clock, the written family lifecycle stamp and counts, and observes the
original queue at the barrier. Wrong-cardinality and wrong-mismatch mutants are
compiled and must be detected in both JS and Native.

## Worker replay

`python3 experiments/public-query-contract/verify.py --output
.artifacts/public-query-contract-worker-id-final` returned PASS. The retained
worker receipt and complete outputs are under
`experiments/public-query-contract/evidence/worker`. Fifteen full common
checkpoints and the approved foreign diagnostic passed both backends; three
intended negatives and both reached compiling mutants passed. The latter failed
exactly `single-multiple` and `get-mismatch`, retaining diagnostic IDs. Actual
factory lineage and requested `entityId` payloads are included in this replay.
The integrity control covers failed single plus missing/mismatch lookup with
unchanged lifecycle stamp, clock, allocation/event/queue counts and post-barrier
observations. No feature timing samples were collected concurrently with other
workers.

## Delivery gates

Worker replay, independent Spec/Standards review, the unchanged #28 paired
regression receipt, optional serialized feature diagnostic timing, commit/push and
GitHub issue reporting are recorded by the integrator before closing #29.

Count and single currently scan the live handle snapshot; #30 owns indexed storage
integration. Finite observation equality is not universal refinement or executable
proof. Feature process timing does not replace the full #21/#23/#24 performance
qualification. Owned schedule reader cursors are not advanced by this API.

## Independent integrated replay

Initial integrated root replay PASS is retained in `experiments/public-query-contract/evidence/root/receipt.json`. This receipt binds its recorded source snapshot. Later storage/component changes require a fresh final-source replay; performance and final delivery remain separate.

## Root shared-live source replay

Independent root verification passes on the shared-live closure:15 common complete checkpoints plus the approved foreign-world difference, actual Array lengths0/9/17, three intended negatives and two reached compiling mutants detected on JS/Native. Receipt/full observations and five raw equivalent whole-process timing samples per backend are retained in `experiments/public-query-contract/evidence/root-current/receipt.json`. These timings include startup/printing and do not qualify product performance. Shared regression and final delivery remain pending.


## Current shared-source replay — 2026-10-07

Fresh root replay passes on Column `3fec368b`, captured-column `340efc23` and indexed-lifecycle `e997f3b0`: 15 common TS checkpoints plus approved foreign-world divergence; Array and integrity controls; wrong-cardinality and wrong-mismatch mutations. Source-bound receipts, full observations and retention hashes are in `experiments/public-query-contract/evidence/indexed-core-current/`. Five complete feature timing observations per backend are retained in `evidence/indexed-core-timing/`; they include process startup/output and do not qualify hot-path performance. Historical receipts remain historical.

Independent final Spec and Standards reviews identify no blocking bounded-feature functional defect. The unchanged default #28 gate passes on the current core; all recorded source hashes match. The additional prepared-provider gate remains failed for #30 and is not this ticket's shared regression requirement. Commit/push and governing issue reporting remain pending; this update does not close the issue or parent qualification tasks.
