# Canonical runtime Lifecycle correctness

Motion and Health run the authored Lifecycle workload through ordinary canonical queries, public systems, Local, schedules, commands and WorldIO. Each schema accepts runtime entity counts 64, 256 and 1024, with 64 iterations. Larger runs reuse the unchanged artifacts compiled for the initial 64-entity run.

Each iteration reserves a transient entity, observes pending commands, applies a barrier, observes the committed state, removes its Main component and despawns it, then applies another barrier. The consumer retains actual callback results, complete logical rows and physical arrays, lifecycle stamps, allocator slots and free/order metadata, Local owners, registrations and pending state. Foreign handles are rejected by world identity; their IDs are not normalized to match TypeScript.

The private LC2 encoder preserves every observed field, ordering and repeated copy. An independent typed decoder expands the complete compact report into both historical LC1 and verbose reports and compares every byte. The encoder uses an affine Array scratch buffer with the same 4096-character output boundary. It changes no public ECS API or workload operation.

| Schema | Entities | JS, consumer limit 5s | Native -O3, consumer limit 5s | Complete oracle bytes |
| --- | --- | --- | --- | --- |
| Motion | 64 | PASS | PASS | 3,848,488 |
| Motion | 256 | PASS | PASS | 14,372,070 |
| Motion | 1024 | PASS | PASS | 57,594,965 |
| Health | 64 | PASS | PASS | 3,904,540 |
| Health | 256 | PASS | PASS | 14,649,881 |
| Health | 1024 | INCOMPLETE | PASS | 58,759,817 |

Health1024 JS hit the unchanged five-second deadline twice. Its first attempt retained 58,285,303 bytes and its second retained 48,514,731 bytes, with empty stderr. A separately reviewed 15-second V8 diagnostic completed and matched all 58,759,817 expected bytes. That diagnostic does not pass the ordinary five-second gate. Two later writer repairs also failed the larger JS gate and were not adopted.

`runtime-v1/array-actual-batch01/RETENTION.json` records selected passing and incomplete roles separately from historical attempts and diagnostic controls. Content-addressed gzip objects preserve source and model dependencies, plans, receipts, guards, complete or partial raw streams, profiles and generated artifacts. Installed tool and shared-library binaries are bound by identity only. Original execution paths and producer chains remain explicit.

The protected default #28 gate is reused by exact equality of all 351 monitored source bodies. This additive fixture changes none of those bodies. That reuse establishes no Lifecycle timing result.

This is a partial correctness delivery. The Health1024 JS deadline remains open under #21, along with Readers, FailedTxn, equivalent timed forcing, transaction and memory observations, required sample rotations and final JS <= TS / Native <= 0.5 x TS qualification. No parent ticket is closed and no comparative speedup is claimed.
