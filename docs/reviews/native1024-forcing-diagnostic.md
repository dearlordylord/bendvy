# Native1024 forcing — read-only diagnostic review

**No demonstrated lazy-update mismatch.** Existing clocks exclude final observation on both Bend and TS. A delayed final traversal is possible to investigate, but neither the source review nor RFC request counts establish that authored updates were deferred. No timing or program modification was executed for this review.

## Exact observed seam

The current plan is `/tmp/bendvy-handoff-v8-dense-sizes-plan-r2.json`, SHA256 `2a8dc7024ae354a3a68b7b186999cb70c9c728d0b60f468827545c126236193d`. Its actual TS source is `experiments/s-integrate/measurement-samples-reference.mjs` (`ecfd1b590964fb76fb69a7a28e9dffa05b631592f47a52f11921ffaec25253b6`), derived by `source-handoff-dense-sizes/prepare-ts.py` (`d4380f5c3175c049cc8d971faabf5d634f57fa883bc573f8fc7119e11df36b13`). There is no current `experiments/s-integrate/measure-ts.mjs` at the requested path.

- Motion driver: `/tmp/bendvy-handoff-v8-motion-dense1024-build-r2/batch.bend`, SHA `cba149cd35ef9d350cf63860f207b7ee968dd2abb3154a2ec27dbcd59819c776`.
- Health driver: corresponding Health path, SHA `f7801b87eebd3804c3a69c39b597a11744b26dfa0aa179bfeb448d2c8c96139e`.
- Both source closures remain coherent v8 `4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235`; main count1024, ticks64, prepared worlds64 plus one warmup.

`batch.bend:25–31` takes start, awaits `motion_execute`, takes end, prints elapsed, then calls `motion_dump`; Health uses the matching `health_timed`. Execute awaits each runtime's64 IO tick loop before returning the owner list. Preparation and final dump/serialization are outside the interval. Local measurement `prototype_packed_motion_loops` matches fuel, awaits dispatch and requires `D.Complete` before the next tick. The actual handoff invokes the unchanged `SC.motion_body`/`health_body`.

`prototype-static-client.bend:18–24,31–37` reads all four Main values for readsum, increments first Main value, reads Ledger and increments its first value. Thus each subsequent row/frame depends on returned state. Actual complete-world verification occurs later, so correctness verification alone does not prove where every untouched field's traversal cost occurred.

The TS derivation preserves Seed, Update, oracle and Dump bodies. It prepares owners before start, runs64 Update ticks per owner inside the bracket and calls `observe` afterward. Original TS source `:70–71` likewise places Dump after end; the derived `run/observe` split retains that distinction. TS getters/setters and ordinary JS objects are eager operations; no additional update work is intentionally placed in observe.

Native `batch.c` RFC helpers (`rfc_wrap`, `rfc_seal`, `rfc_view`) allocate/read reference-count redirects to existing terms. They are not by themselves evidence of thunks: `rfc_wrap` rejects closure/task tags. This narrow fact does not prove universal eager evaluation or exclude all deferred internal work. Larger Native traversal, cache/refcount traffic and working-set effects remain alternative explanations.

## Smallest safe proposed observer experiment

Keep the exact authored update source, build flags, inputs, warmup and original update bracket. Create a **new** diagnostic driver/TS derivation and a prospectively pinned plan; do not change old plans or evaluators.

1. Retain clocks A→B around the unchanged64-world update loop.
2. Between B and C, execute one complete semantic-world observation per returned runtime, visiting every ordered row, all Main/Aux/Flag scalar array cells and Ledger fields. Consume the observation into a strict ordered scalar checksum returned through an IO continuation before C; retain original owners for the normal final dump. TS uses its original Dump/query result with the same field order and checksum, preserving the resulting runtime. Print checksum only after C. Verify checksum and all65 original complete outputs against fresh TS.
3. Report update A→B and observation B→C separately; total A→C is diagnostic. Also obtain the same observation on freshly prepared, unupdated worlds in separate children. This distinguishes ordinary traversal cost from extra post-update work; it does not prove lazy forcing merely from a positive B→C interval.
4. If complete **physical** Bend forcing is still required, add a separately labelled owner-consuming/reconstructing walker over all physical Main/Aux leaves, raw/cache fields, live/flag/added/changed arrays, Ledger and World context. Verify owner preservation with sparse/dead/missing and retained-view controls. No new callback, transaction or recovery algorithm should be introduced.

Physical Bend metadata/cache/tombstones have no exact TS representation counterpart. Therefore step4 cannot honestly be described as identical physical work in TS. Compare the shared semantic checkpoint of step2; expose private physical-walk cost independently. Do not replace original acceptance clocks with Bend's stronger private walk and TS's weaker logical Dump, or call serialization-only checksum a complete physical-owner forcing gate.

Required admission before any new clocks: exact source29/driver/callback preservation, full65 equality, independent checksum oracle and compiling omitted-cell control, unchanged owner/full physical field controls where applicable, explicit caps15/30/120/5, one worker/GPUoff, pre/post artifact/tool hashes and fixed roles. This proposal installs nothing and changes no compiler/kernel/reference/law. It is not an execution authorization, a measured result or performance acceptance.
