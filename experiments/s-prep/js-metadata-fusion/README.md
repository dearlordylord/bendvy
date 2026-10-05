# Metadata read/mark transport fusion

Bounded source experiment for S-PERF-NEXT [#21](https://github.com/dearlordylord/bendvy/issues/21).
The recipe applies only storage.patch, retaining all 29 runtime modules and every
original public definition/type header. Main and Aux remain arbitrary affine Type.

```sh
python3 experiments/s-prep/js-metadata-fusion/materialize.py \
  --input /tmp/bendvy-point-frame-fusion-coherent-js \
  --output /tmp/bendvy-metadata-fusion-worker
```

Input actual source, overlay, and cache-specialization pins must match; output
must be absent. Storage is revision-pinned exactly. The recipe verifies the input
closure digest and both complete closure maps, changes only storage, and writes
matching output closure maps and a receipt. It composes with independently repinned
query variants because only storage is revision-pinned. Existing public helpers
remain available, including metadata_live, metadata_mark, take_meta_done, fuse_meta,
and prototype_mark_world_result.

The point hook and row take paths pass the original Array.get result directly to
a continuation. They retain one final MetadataColumns construction and eliminate
the extra metadata/bool pair. Live mark keeps columns open through the live check
and writes only changed before final reconstruction. Dead mark never writes changed.
Namespace, nonzero ID, capacity and high-water guards remain at original callers;
array access cannot run before those guards. Flags, added, Main, Aux, pending,
ledger and mode are transported unchanged. No ownership or callback is duplicated.

| Path reaching liveness check | Source constructor reduction |
| --- | --- |
| Row take / trusted point hook, live or dead | one metadata wrapper pair |
| World mark, live | one metadata wrapper pair and one intermediate MetadataColumns |
| World mark, dead | one metadata wrapper pair |
| Guard-rejected calls | none |

These are source predictions, not emitted-code counts or runtime results.
Generated JS/C, semantic traces, access/ownership negative controls and performance
remain pending coordinator scheduling. No acceptance or adoption is claimed;
canonical checker/runtime caps are unchanged. Coordinator diagnostic budgets are
checker 15 seconds, runtime 5, codegen 30, clang 120; they do not reset canonical
failed-cap evidence. No ECS proof is written and no law is proposed.

Before work: read AGENTS.md, next-core checkpoint, #21, linked SPEC, R-A/R-C1 reports
and bend-ldd skill; ran bend version (2.0.35) and bend guide. Three absolute reference
HEADs match .references/sources.json. No references/compiler/dependencies change.

The first input /tmp/bendvy-point-frame-fusion-reproduced was rejected before output
creation: its overlay embedded cacheSpecialization had stale held-adapter closure
pins, differing from actual source and standalone cache-specialization.json. Root
repaired the preceding recipe and provided the coherent input above with unchanged
source bytes. This detected mismatch remains negative provenance evidence; it is
not a semantic or performance result. Successful materialization changed only storage.

Follow-up: independently inspect emitted construction counts and run connected
trace, guard/stamp and arbitrary affine payload controls before timing. Finite
trace agreement would not establish universal runtime refinement or proofs.

Local diagnostic: taskset -c 11 timeout 15s bend
/tmp/bendvy-metadata-fusion-worker/experiments/s-integrate/storage.bend --check-only
exited 0 with ALL PROOFS CHECK. This checks the generic affine source module; no
mathematical proof was added and no canonical aggregate cap result is replaced.
