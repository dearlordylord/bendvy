# Profile-directed metadata/query fusion — bounded candidate

S-PERF-NEXT [#21](https://github.com/dearlordylord/bendvy/issues/21), with diagnostic findings for [#24](https://github.com/dearlordylord/bendvy/issues/24). This is an isolated executable source candidate, not production adoption or performance acceptance. All 29 runtime modules remain; Main/Aux retain arbitrary affine Type components.

## Changes and provenance

Compose the point-frame recipe, metadata read/mark transport recipe, then this query recipe. Indexed traversal carries the four affine metadata arrays directly. Original capacity/live/flag predicates, actual callback and per-row Main/Aux restoration remain. Columns and the original StructIdxState are reconstructed at the final query boundary; the original reachable finish/reverse operation remains, including its mutation anchor. query.patch shows the exact source change.

```sh
python3 experiments/s-prep/js-allocation-map/point-fusion.py --input /tmp/bendvy-primitive-columns-js-v4 --output /tmp/fresh-point
python3 experiments/s-prep/js-metadata-fusion/materialize.py --input /tmp/fresh-point --output /tmp/fresh-metadata
python3 experiments/s-prep/js-query-columns/materialize.py --input /tmp/fresh-metadata --output /tmp/fresh-query
# Repeat with the Native primitive-columns input for two-backend controls.
```

The delivered query recipe checks all 29 input source pins, both complete cache closure maps, their digest and embedded/standalone equality before creating output. Its added fail-closed input checks do not change emitted Bend source: all 29 delivered module bytes equal the executed overlay. Executed and delivered manifests are retained separately. The preceding point recipe now also refreshes the embedded cacheSpecialization; the earlier stale embedded pin was rejected by the metadata recipe, despite identical runtime source bytes. This corrects provenance, not runtime semantics.

## Observed results

| Diagnostic | Result / limit |
| --- | --- |
| Motion driver checker / JS codegen | Passed at 15 / 30 seconds |
| V8 CPU/GC profile, 8 fresh worlds × 64 ticks × 256 entities | All nine full worlds matched freshly executed bevy-ts |
| Construction counter, same work | 10,478,144 literal/closure executions, 79.942 per point callback; original 11,656,768 / 88.934 |
| Reduction | 1,178,624 constructions: point 393,216; metadata 393,216; query 392,192 |
| Approximate GC allocation bytes | 397,253,184 versus earlier baseline approximately 453.7 MB; TS approximately 81.4 MB |
| Query lifecycle | JS/Native × two nominal schemas each passed 40 literal observations and both compiling mutants (order, flag-membership) |
| JS factory / foreign-world field controls | 8 programs × 8 full-field observations passed; explicit JS-only subset, not the original 16-program two-backend gate |
| Arbitrary affine lifecycle | Quiet sequential run passed JS/Native, 52 observations each, clone/duplicate/cross-schema negatives and compiling omitted-mark mutant; initial 15-second negative-clone timeout retained |
| Motion unprofiled 14-pair cohort | Incomplete: first pair JS 1332 ms / TS 1573.837337 ms with all 65 worlds equal, then a child exceeded runtime 5 seconds |
| Native speed / Health speed / full22 connected gate | Not established by this candidate |

Executed constructor expressions are not physical heap allocations: counter instrumentation changes escape optimization/JIT, and Array runtime constructions are outside its counting scope. GC bytes are a separate approximate estimate. Profile bracket timings are not comparative acceptance. One partial unprofiled pair cannot establish a median or the JS target. The full native >=2× / JS parity goal remains open.

The query controls preserve original literal oracles and exact mutant witnesses, across JS-one, JS-two, Native-one, Native-two. They establish finite trace agreement, not provider authority, universal refinement or proofs. Original full22, connected rollback/journal, cursor, transaction/fallback and complete factory/access/ownership controls remain required. The initial negative-clone timeout is not a passing affine rejection or evidence of a particular cause. Targeted follow-up checks reject the same forbidden clone on unfused storage in 2.585 seconds and on the exact fused imported source closure in 2.696 seconds (expected Data, observed Type, exit1). These standalone diagnostics do not replace the full lifecycle gate; the initial timeout is retained. After these targeted diagnostics, the quiet sequential aggregate run passed on the same 29 candidate source bytes; no deadline or oracle changed. The cause of the first timeout is not established.

## Commands and evidence

```sh
python3 experiments/s-prep/js-profile/run.py --generated-js /tmp/bendvy-profile-combined-batch/batch.js --output /tmp/fresh-profile
node --expose-internals experiments/s-prep/js-allocation-map/instrument.cjs /tmp/bendvy-profile-combined-batch/batch.js /tmp/fresh-count.js
python3 experiments/s-prep/js-profile/run.py --no-gc --generated-js /tmp/fresh-count.js --output /tmp/fresh-count
BENDVY_CHECKER_SECONDS=15 BENDVY_CPU=11 python3 experiments/s-prep/primitive-storage-integration/query-run.py --candidate-root /tmp/bendvy-profile-combined-candidate --output /tmp/fresh-query.json
BENDVY_CHECKER_SECONDS=15 BENDVY_CPU=11 python3 experiments/s-prep/primitive-storage-integration/run.py --candidate-root /tmp/bendvy-profile-combined-candidate --output /tmp/fresh-lifecycle.json
python3 experiments/s-prep/primitive-speed-check/motion-js.py --output /tmp/bendvy-profile-combined-speed
```

The existing measurement preparation scripts produce the unchanged batch64 driver and TS reference. Receipts retain exact commands, source hashes, outputs and partial failures in [evidence-index.json](evidence-index.json); generated JS, profiles and raw outputs are gzip-compressed. Initial query parsing failure is retained; the corrected module passes independently. Lifecycle/query runners now allow explicitly opted-in executable checker15 diagnostics while defaulting to5. Proof checker remains5; no law, proof, kernel, dependency or reference changed. These runner-byte changes need canonical pin reconciliation before any future authorized cohort. The historical twenty-attempt canonical cap remains terminal; no reset, packet, keep, qualified metric or closed issue is claimed.

## Next profiling targets

CPU self samples identify actual callback read (~7.2%), ledger (~6.3%), query advance (~6.3%) and held row (~5.2%). Inspect those generated functions and their source owners next; avoid optimizing a sampled name alone. Require coherent full-field/cache-after-write semantics and authority/affinity controls before adoption. Retain and investigate the initial checker timeout if it recurs, then complete the connected gates and a qualified equal-work JS/Native comparison under an explicitly authorized future contract.
