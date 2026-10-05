# Unpack-once batched marks

Isolated S-PERF-NEXT #21 source experiment from the point/metadata/query-fused
29-module overlay, excluding flat point-owner. Only transaction.bend changes.

```sh
python3 experiments/s-prep/js-batched-marks/materialize.py \
  --input /tmp/bendvy-profile-combined-js \
  --output /tmp/bendvy-batched-marks-tuple-final
```

The recipe requires fresh output, exact transaction revision, all 29 source pins,
matching embedded/standalone cache metadata and complete closure maps/digest.
Output retains all public definition/type headers and writes coherent full pins.
The original recursive mark implementation remains as
prototype_storage_mark_all_reference; original storage S.mark_main and helpers,
actual callbacks, journal and publication/queue code remain unchanged.

Public storage_mark_all returns the original World immediately on empty marks.
For a nonempty list, it opens World/Rows/MetadataColumns once. The structurally
decreasing private loop carries arbitrary affine Main/Aux/Ledger and the stable
World fields directly, plus a live/changed array transport pair. Every handle
retains namespace, nonzero ID, capacity and high-water guards. Only guarded IDs
read live; only live entities update changed to the same tick. Foreign, ID0,
out-of-bounds, high-water rejected and dead handles make no write. Duplicate and
nonmonotonic handles execute in original list order with no deduplication or sorting.
Main/Aux/flags/added/pending/ledger/mode stay untouched; no field is duplicated.

At loop termination the three records reconstruct once. Each handle produces one
live/changed tuple; entry produces one tuple. The required Array.get pair and
Array.set behavior remain. There are no resume closures or callback duplication.
For n guarded marks, source prediction is 3n record constructions replaced with
n+4 transport/boundary objects (n permark tuples, one entry tuple, three final
records); reduction 2n-4, so tiny batches may regress. An invalid guard previously
reconstructed World/Rows while reusing MetadataColumns: substitute two old objects
for that mark in this accounting. Emitted construction counts and speed remain
unobserved; constructor counts alone cannot establish improvement.

Initial standalone executable checker on CPU10 under15s rejected matching the
computed Bool.and guard: Bend requires a parameter/field scrutinee. Guard/live
helpers now return only the array transport pair. Second check rejected multiple
scrutinee constructor-plus-tuple pattern syntax; final source uses explicit Tuple constructors for the transport patterns. These failures are retained as source diagnostic evidence, not passes.
No codegen, runtime, profiling or timing was executed by this worker.

Live stamp mutation anchor is now prototype_storage_mark_live's True branch
Array.set(U32,changed,index,tick); guard controls target prototype_storage_mark_guard
and the exact Bool.and expression in prototype_storage_mark_loop. A mutation of
old S.mark_main or prototype_storage_mark_all_reference is not authoritative for
this public batch path. Existing callback inverse/owner/queue anchors remain live;
no setter or journal code changes. Root must connect stamp suppression/guard
mutations to actual committed marks, while failure rollback still omits publication.

Follow-up: connected finite traces; duplicate/nonmonotonic marks; invalid/dead/foreign
controls; change-stamp and full untouched-field observations; compiling live stamp
mutants; equivalent JS/native timing after emitted counts. Canonical failed-cap
records remain. No Data-only scope, proofs/laws/dependencies/compiler changes or
production adoption. Authorized diagnostics use checker15s, runtime5/codegen30;
they do not reset canonical caps. Finite traces are not universal refinement.
Bend version2.0.35 and guide were run before work; AGENTS/checkpoint/#21/SPEC/LDD
instructions remain governing.

Final standalone diagnostic: taskset -c 10 timeout 15s bend
/tmp/bendvy-batched-marks-tuple-final/experiments/s-integrate/transaction.bend
--check-only exited 0, ALL PROOFS CHECK. This is generic executable module checking,
not new proof or connected acceptance. Output transaction SHA256:
67f0e0dc4dee21381dab33bc242e6c9c67f64705ef8faea3e02b641270fa3519.
