# Actual active transaction occupancy — #22 bounded milestone

Private meters are implemented and verified on actual indexed Readers and FailedTxn owners. Twenty backend cases pass complete public-output and fresh pinned TS gates. Four larger FailedTxn cases remain unavailable at the unchanged five-second limit. This is diagnostic preparation, not timing acceptance, an all-five-workload gate or a universal ECS proof.

| Actual workload, original 64 iterations | Schemas / counts | Native O3 / JS | Physical Tx peaks: commands, events, inverse, marks |
|---|---|---|---|
| Readers | Motion / Health; 64, 256, 1024 | Twelve backend cases pass | 0, 1, 1, 1 |
| FailedTxn | Motion / Health; 64, 256 | Eight backend cases pass | 1, 1, 3, 2 |
| FailedTxn | Motion / Health; 1024 | Four diagnostic deadlines and four separate verbose baseline deadlines | Unavailable |

Each passing Readers run carries 64 actual transactions; each passing FailedTxn run carries 192, including failure/retry. Twenty gzip JSONL files retain 31,232 diagnostic points, including 26,624 physical measurements and separate finish/retirement markers. Native/JS raw records match for each passing pair. Evidence identifies each maximum's actual transaction, point and mutation phase.

## Owner-preserving implementation

`CONTRACT.md` precedes the subjects. `prepare.py` instruments only a materialized copy. Actual Tx/Finished owners carry private Data records through append, successful/failed finish, publication and rollback. Command traversal returns every affine payload and preserves list order. Other actual Tx fields contain Data lists and are traversed physically. Each actual inverse pop and commit mark pop records remaining physical length. Opaque public callback quantities/signatures remain unchanged; trusted private result plumbing transports records at existing IO completion boundaries.

Actual Tx lists have no cached size fields. The independent metric oracle checks physical counts against append/drain transitions. No cached size or post-retirement empty owner is invented. Commit transfers command/event owners; failure discards staging. World queues/logs are distinct inspection cells. Readers stages disposal commands directly in its world queue, explaining its *measured* zero Tx command column. Historical fixture counts never substitute for workload observations.

Passing diagnostic and fresh uninstrumented public output match completely. Readers uses its original full validator; verbose FailedTxn uses its original full-value oracle against freshly executed pinned TS. Original required row slots, tags, lookups, reservations, effects, outcomes and reader observations remain checked. Diagnostics add no read, frame, trim, barrier, drain or callback and make no timing claim.

`overlay/` contains six reachable modified modules. `source-provenance.json` pins modified/replay sources, Base, tools, all three absolute read-only reference commits and input commit `56b72f6`. `evidence.json` pins complete reachable closures and generated diagnostic/uninstrumented C, JS and native artifacts. Eight compressed JSON files preserve the complete FailedTxn validator results; the evidence carries their hashes and concise summaries.

## Replay and finite controls

```sh
python3 experiments/s-prep/tx-occupancy/replay.py
python3 experiments/s-prep/tx-occupancy/negative-controls.py
python3 experiments/s-prep/tx-occupancy/mutations.py
python3 experiments/s-prep/tx-occupancy/verify-evidence.py
```

Replay retains a bounded-failure exit/status for missing cases. Checker/runtime limits are 5s, codegen 30s, clang 120s, serial CPU8, Native O3/one worker/GPU off. Only task-owned process groups are killed. No dependency, reference, installed compiler/kernel, main candidate or historical package changes.

Five fresh compiler negatives reject affine duplication, opaque meter reconstruction, an undeclared ledger token, supplying a read callback as a writer, and nominal cross-schema Tx use. Exact sources/rejections are retained. Six compiling JS mutants zero command/event/inverse/mark or actual unwind/mark-drain counts. All fail the intended metric oracle while retaining this task's fully validated Motion64 FailedTxn public hash. These finite controls approve no new law/proof.

## Preserved attempts and remaining cells

First/second-attempt JSON preserves an incorrect requirement that Readers must stage a Tx command, a host-library executable entry, failed artifact reuse and missing iteration argument. Final replay corrects those runner errors; it erases no deadline. An import collision with historical `t05/run.py` was corrected by naming this runner `replay.py`.

All four separately executed uninstrumented verbose FailedTxn1024 baselines also exceed five seconds. A private copy of existing frozen quiet full-field transport was assessed: initial Console-only/Recorded dispatcher mismatch rejected; corrected quiet diagnostic and quiet baseline both exceed five seconds on JS Motion1024. Quiet JSON files preserve these attempts. No Native quiet pass, quiet metric maximum or complete transport equivalence is inferred.

FailedTxn1024 return condition: connect the private meter to a shared reviewed equivalent-work diagnostic/transport protocol completing all original fields/effects and fresh reference validation on both backends within five seconds, then execute the missing four cases. No deadline increase, field omission, reduced iterations or fixture peak is authorized. Quiet warmup/protocol work is independent and untouched.

Dense/Sparse/Lifecycle occupancy remains **untested**. Dense/Sparse require a copied `measurement-bend` IO completion hook transporting the existing meter through `diag_strip`, followed by unchanged actual validators for every schema/count/backend. Lifecycle requires physical world-command hooks at its direct staging/barrier path. Stored/running reader and world/log metrics remain separate gates. This package establishes only its measured active-Tx cells, not full evaluator readiness or product performance.
