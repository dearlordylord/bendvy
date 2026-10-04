# T05 candidate obligations — unapproved, no proofs

The executable subject is `lifecycle.bend`, composed with the existing R-C1
abstract read provider. These are proposals, not approved laws or theorems.

Admissible states originate from one trusted, singly owned Factory root and
`create`, `reserve`, `insert`, `remove`, `despawn`, `tick`, `flush`. Raw public
constructors/internal command helpers are trusted implementation boundaries;
arbitrarily constructed Worlds/Factories are not included. Establishing that an
application cannot bypass this boundary remains a production API obligation.

| Candidate | Precise intended property | Why / finite falsification |
|---|---|---|
| World identity | For two successful creates from the same affine Factory lineage, world IDs differ; lookup/commands reject a handle from the other world regardless of colliding slot | Prevent wrong-world access; colliding local value 7 vs foreign 99; compiling lookup/command world-check mutants |
| Reservation / liveness | Successful reserve yields a fresh ID and queues Spawn; before flush that ID is MissingEntity, after flush it is live unless later FIFO commands despawn it | Reservation must not imply liveness; pending and next-schedule snapshots; compiling auto-flush mutant |
| FIFO / completeness | Flush applies every queued command exactly in insertion order and clears pending; Spawn then Insert is live+tagged, Despawn then Insert remains missing | Soundness alone permits applying nothing; ordered reference snapshots, duplicate-display-label same-frame spawn+insert; compiling reverse-order mutant |
| Stable identity | ID allocation never reuses a despawned slot, never wraps, and exhaustion returns None without changing existing state | Stale references cannot resolve another entity; c has slot 2 after a's despawn; boundary at U32 max; larger boundary/model coverage still needed |
| Membership / selection | Live+matching query yields Matched, live+nonmatching query yields QueryMismatch, pending/dead/unknown/foreign yields MissingEntity; Optional preserves tag absence | Define full result partition, not just match soundness; all required/present/absent/optional queries and live/nonlive lookups across ten phases |
| Order / idempotence | Surviving rows retain spawn order; component insert/remove does not reorder; flushing an empty queue preserves observations | Deterministic traversal; b-then-a tag insertion, despawn and empty-marker reference snapshots |

Finite evidence does not prove these for every reachable state. A proof package
must either target executable definitions directly or specify an abstract model
and separately prove the runtime-to-model projection, admissibility and
transition correspondence. `Factory` uniqueness across independent roots,
restoration of affine payloads, general component bundles, scalable array layout
and runtime-wide authority are not covered by this package.
