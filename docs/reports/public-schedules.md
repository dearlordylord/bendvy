# Public schedules (#33): executable implementation evidence

The new public schedule owns its complete affine registered-owner record across
repeated runs, executes phases/systems/conditions in authored order, and applies
commands only at explicit barriers. It stops at a failed registered outcome and
recovers the schedule/world without flushing earlier committed commands.

Command: `python3 experiments/public-schedules/run.py`.
[Retained receipt](../../experiments/public-schedules/evidence/receipt.json) has
`status: PASS`, `sourceUnchanged: true` and the full fifteen-file source/fixture
inventory. [Exact TS output](../../experiments/public-schedules/evidence/expected.txt)
contains22 nonblank observations; the source-current JS and Native outputs match
byte-for-byte. It covers six authored cases, two executions of each valid plan,
and a final explicit drain. Every resource value, event payload and live entity
ID is checked. Two independently registered instances of the same closed runner
remain distinct; duplicate/unknown plans are rejected before execution.

The actual failing runner writes resource777, stages event7/command, then uses
`transaction.finish` to roll back. Earlier resource/event commits remain;
earlier pending commands survive repeated failures. Failed reservations consume
an ID, so final entities are1,3 rather than1,2, matching actual pinned TS.

Four source-current intended negatives reject: duplicated affine schedule,
cross-schema world, undeclared raw World access inside the called abstract
condition callback, and writes through its read capability. The positive complete
application checks and runs. A scheduled namespace mismatch rejects all actual
system invocations, returns retained owners/world, and repeats unchanged on both
backends. This control uses a deliberately wrong scheduled namespace against an
actual world; it does not claim independent factory global authority.

Order, false-condition execution and implicit-end-flush mutants each typecheck,
emit and execute on JS and Native, then fail the complete observation oracle:
six reached detections, no compile failure counted as a mutation result. Checker
and runtime5s, emission30s and approved private Clang19 compilation120s limits
are recorded per command.

This is a finite source-bound slice with trusted closed dispatch/catalog
provisioning, arbitrary affine owner Type and normalized Unit step outputs.
Heterogeneous runtime captures, parallel schedules, provisioning, shared reader
policy and full-core proof/refinement are separate scope. No new laws, proofs,
dependencies, Data-only restrictions or performance allowances were introduced.
One admitted diagnostic process sample was TS85.105ms, JS24.166ms and Native5.490ms;
startup/output are included and one sample does not qualify feature hot-path
performance. Root must independently replay/review the integrated source, run the
unchanged #28 regression gate and deliver against GitHub#33 before closure.

Earlier full runs reached all mutation observations but failed the final source
closure guard when concurrent edits/harness changes occurred. Their receipts at
`.artifacts/public-schedules-1791328804345107777` and
`.artifacts/public-schedules-1791328880909778117` remain unaccepted evidence; the
retained PASS receipt is the later unchanged full import closure.

## Independent integrated replay

Initial integrated root replay PASS is retained in `experiments/public-schedules/evidence/root/receipt.json`. This receipt binds its recorded source snapshot. Later storage/component changes require a fresh final-source replay; performance and final delivery remain separate.

## Root shared-live source replay

Fresh root schedule verification passes on Column869091a8/Component0e41557c. Complete observed order, conditional execution, explicit barriers and failure behavior, intended negatives and reached compiling mutants are retained in `experiments/public-schedules/evidence/root-current/receipt.json`. No hot-path qualification follows; common regression and delivery remain pending.


## Current shared-source replay — 2026-10-07

Fresh root replay passes on Column `3fec368b`, captured-column `340efc23` and indexed-lifecycle `e997f3b0`: authored order, conditions, barriers, failure rollback, namespace refusal and three reached mutations. Source-bound receipts, full observations and retention hashes are in `experiments/public-schedules/evidence/indexed-core-current/`. Five complete feature timing observations per backend are retained in `evidence/indexed-core-timing/`; they include process startup/output and do not qualify hot-path performance. Historical receipts remain historical.

Independent final Spec and Standards reviews identify no blocking bounded-feature functional defect. The unchanged default #28 gate passes on the current core; all recorded source hashes match. The additional prepared-provider gate remains failed for #30 and is not this ticket's shared regression requirement. Commit/push and governing issue reporting remain pending; this update does not close the issue or parent qualification tasks.
