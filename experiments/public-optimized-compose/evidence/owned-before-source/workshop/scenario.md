# Workshop query composition oracle

Frozen before Bend implementation for [#27](https://github.com/dearlordylord/bendvy/issues/27).
This third application is a workshop inventory/recipe/production queue, independent
of Arena and the earlier user simulation. Five descriptor families are Stock,
Recipe, Queue, Enabled and Locked. Every substantive payload contains a complete
three-element owned-array analogue; subsequent writes replace complete arrays.
TS values are ordinary JavaScript values; affine ownership acceptance is Bend's
separate source-bound gate.

Run from repository root with existing Node v24.20.0, no dependencies:

```sh
timeout 5 node examples/query-composition/reference.mjs --verify
```

Observed result: `{"status":"PASS","checkpoints":23}`. The committed JSON contains
all entity values and complete arrays, empty-selection results and composed
selection values, rather than checksums. No timing claim is made.

The first 19 checkpoints cover empty world, pending spawn, mixed required
write/read/optional selection, independent Enabled/Locked filters, missing Recipe,
missing Queue, empty selection, contradictory filters, repeated production,
three-family failed replacement and rollback, command rollback, same-instance
retry, deferred insertion/removal and despawn/spawn/reinsertion churn. IDs iterate
ascending, including the new ID after a gap. Duplicate write/write/read declarations
alias in TS; Bend must preserve this current-storage observation through
capability aliases that thread one opaque affine context. These declarations
do not duplicate component ownership; duplicating an actual context/owner remains
prohibited.

Checkpoints20–22 separately observe advanced AND-composed `added(Recipe)` and
`changed(Stock)` with structural filters: first reading-system run sees IDs
`[1,3,4,5,7]`, repeated run sees none, and replacing existing Recipe+Stock sees
none because replacement is changed but not added. These do not establish all
lifecycle semantics or relation composition. Checkpoint23 records foreign-world
same-numeric-ID collision: TS resolves local Stock; Bend's approved world identity
boundary must reject. Compare that separately, never as an ordinary equality.

Initial runner attempt returned `Array.push`'s numeric result from the observer;
TS interpreted that as an effect and rejected `effect.run`. Observer now explicitly
returns undefined. The frozen successful execution is actual runtime evidence.

Final expected JSON SHA256:
`e042305fedcb646ff7a52d28ca3fd5ba9f11a1eda2a12cd5c945dd77f57bb742`.
Runner SHA256:
`40ea098e003335229a2fdbeac023ad01a786fca6322165d1a698889c01358e35`.
