# Canonical runtime Lifecycle correctness

Motion and Health run the authored Lifecycle workload through a persistent ordinary App, canonical queries, existing Local registrations, commands and WorldIO. Registration-derived library folds select and dispatch the original six schedules; the separate application stage preserves domain phases 0/1/2 and both barriers. Each schema accepts runtime entity counts 64, 256 and 1024, with 64 iterations. Larger runs reuse the unchanged artifacts compiled for the initial 64-entity run.

Each iteration reserves a transient entity, observes pending commands, applies a barrier, observes the committed state, removes its Main component and despawns it, then applies another barrier. The consumer retains actual callback results, complete logical rows and physical arrays, lifecycle stamps, allocator slots and free/order metadata, Local owners, registrations and pending state. Foreign handles are rejected by world identity; their IDs are not normalized to match TypeScript.

The private LC2 encoder preserves every observed field, ordering and repeated copy. An independent typed decoder expands the complete compact report into both historical LC1 and verbose reports and compares every byte. The encoder uses an affine Array scratch buffer with the same 4096-character output boundary. It changes no public ECS API or workload operation.

| Schema | Entities | JS, consumer limit 180s | Native -O3, consumer limit 180s | Complete oracle bytes |
| --- | --- | --- | --- | --- |
| Motion | 64 | PASS | PASS | 3,848,488 |
| Motion | 256 | PASS | PASS | 14,372,070 |
| Motion | 1024 | PASS | PASS | 57,594,965 |
| Health | 64 | PASS | PASS | 3,904,540 |
| Health | 256 | PASS | PASS | 14,649,881 |
| Health | 1024 | PASS | PASS | 58,759,817 |

The earlier manual-schedule Health1024 JS consumer hit its five-second deadline twice. Its first attempt retained 58,285,303 bytes and its second retained 48,514,731 bytes, with empty stderr. A separately reviewed 15-second V8 diagnostic completed and matched all 58,759,817 expected bytes. That diagnostic did not pass its original five-second gate; the later ordinary App runs use the recorded shared 180-second correctness boundary. No comparison of their elapsed times is claimed. Two later writer repairs also failed the larger JS gate and were not adopted.

`runtime-v1/ordinary-app-family01/RETENTION.json` retains all twelve ordinary App full-oracle passes. Exact equality to the preserved independent LC2 oracles reuses their qualified complete LC2-to-LC1 and verbose decoder controls. Initial codec and final stream project the actual World and affine owners back into the same App; the original observation constructors, encoder and chunk writers remain unchanged.

`runtime-v1/array-actual-batch01/RETENTION.json` preserves the earlier manual-schedule passing and incomplete roles separately from historical attempts and diagnostic controls. Content-addressed gzip objects preserve source and model dependencies, plans, receipts, guards, complete or partial raw streams, profiles and generated artifacts. Installed tool and shared-library binaries are bound by identity only. Original execution paths and producer chains remain explicit.

This consumer migration changes no shared `src/ecs` body. The coordinator reuses the protected default #28 gate by exact source equality on the integrated result. That reuse establishes no Lifecycle timing result.

This is Lifecycle correctness qualification, not comparative performance qualification or closure of #21. Equivalent timed forcing, transaction and memory observations, required sample rotations and final JS <= TS / Native <= 0.5 x TS qualification remain governed by #21. No comparative speedup is claimed.
