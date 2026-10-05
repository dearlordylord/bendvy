# Cached complete views over affine raw components — bounded experiment

`Cache<Raw:Type,View:Data>{raw,cached}` retains the actual original Type Main/Ledger
arrays as primary storage. Its getter returns the unchanged raw owner plus a copy
of the complete immutable Data view. Its writer delegates the original payload
swap0, returns its exact old scalar, and updates cached Four.a only. Other cells and
frame/reserve/class/epoch remain intact. Aux stays Type; flags and row metadata are
threaded unchanged in a separate affine context. There is no Data-only replacement.

The separate test-only Checked wrapper audits raw against cache through an
independent original uncached getter at initialization, every read/write checkpoint
and restore. The production-shaped Cache getter itself performs no raw observation.
Both original byte-identical Dense callback families execute twice through token-
specific rank-2 opaque Owner providers. Restoring initial old0 values10/100 then
checks all four raw cells and all four cached cells, every component metadata field,
Type Aux fields, flags and retained added/changed3/4. Each schema retains six exact
old-scalar journal entries and three Main marks; writes are not coalesced.

NativeO3 and JS must agree completely. Fresh pinned bevy-ts observes all24 matching
Main/Ledger checkpoints and Aux/flags. Bend row ticks are checked independently;
TS epoch equality is not invented. Original callback source, actual four swap0
writers, tracked prototype/adapter/guard sources and33-file TS import closure are
pinned before execution. The actual source guard rejects a fake wrong TS HEAD
before adapter execution. Each replay generates its own provenance and hashes.

Four compiling mutants must be detected on both backends: raw wrong slot, cache
wrong head, stale cache and corruption of raw cell3 with unchanged cache. The last
control prevents a cache-only oracle from hiding lost payload fields. An affine
Cache/Raw owner duplication control must reject at its intended checker boundary.

## Domain and limits

This finite invariant domain uses balanced four-cell arrays and only the four
original Position/Vitals/MotionLedger/HealthLedger scalar index0 writers. Cache
initialization observes the whole original payload; callbacks cannot receive or
mutate the raw owner directly. Exported constructors alone do not establish cache
consistency, and arbitrary trusted raw transformations are excluded. A new writer,
raw replacement, destructive edit or unknown transform must refresh/invalidate the
complete cache before the next cached read; this is an explicit integration task.

The restores use the independently known old initial scalars and actual original
swap0 through the cached provider. No general cached transaction unwind, optional
components/resources, world cache, traversal opening, reader epoch policy or
production provider is implemented here. This remains a finite capability probe,
not a universal cache correctness proof, ECS law approval or performance claim.

Replay after committing the reviewed input sources, with a fresh artifact path:

```sh
BENDVY_CPU=5 BENDVY_CACHE_ARTIFACT=/tmp/fresh-cached-owned-views python3 experiments/s-prep/cached-owned-views/run.py
```

Checker/runtime5s, codegen30s, clang120s, NativeO3/one worker/GPUoff and existing
Node remain fixed. No dependencies, compiler changes, optimization loop or timing
measurements were added. Cached observation reconstruction may be a candidate for
later measurement; this experiment does not establish a speed improvement.
