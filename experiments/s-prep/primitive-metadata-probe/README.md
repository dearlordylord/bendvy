# Primitive metadata transport witness

Status: executable bounded source readiness, isolated in this directory. The actual candidate is unchanged. No timing, benchmark, evaluator, packet or session was run. No new law/proof, dependency, compiler or kernel change is present.

`transport.bend` carries arbitrary `M: Type` and `A: Type` owners in `Array<Maybe<M>>` / `Array<Maybe<A>>`. Membership uses `Array<Bool>`, flags retain generic `Array<Maybe<&2,F>>` for `F: Data`, and added/changed ticks use separate `Array<U32>`. `columns_mark` first validates nonzero IDs against both capacity and high-water, reads membership, and sets only changed on a live row. Dead rows and IDs0,capacity+1,U32.max leave every field intact. `columns_read` returns all original owners plus a metadata observation; bounded dead-row reads expose stored metadata as does the shape reference. It does not read/copy Type payloads. `from_original` recursively splits metadata arrays while transporting both payload owners and capacity/depth/high fields once. This supplies a concrete initialization seam rather than requiring manually initialized columns.

The original-shape reference is a local bounded reconstruction of `Metadata`/Rows and `mark_rows` behavior from `/workspace/formal-proofs/bendvy/experiments/fivehour-candidate/JS/experiments/s-integrate/storage.bend` (SHA256 `ed8f8d390fd8f4d49465b3a717c414daa58abe6ff482ef16f5cbc6642f23d157`). It is not the full joined storage implementation. A complete-field output includes Main/Aux owner contents, all physical live/flag/added/changed rows, capacity, depth, high and read observation. Two concrete Type payloads (`ScalarOwner` and an owned `ArrayOwner`) occupy opposite Main/Aux positions in the two cases. The existing five IDs per placement remain, and four explicit high-water controls give14 complete comparisons per backend among original, independently initialized columns and destructively converted columns. Native and JS outputs are identical. `mutate-high-guard.py` drops both mark high-water guards with exact-two-match enforcement: the wrong source compiles and runs on both backends, but the independent full-field literal oracle rejects it. `high-guard-mutant.json` and `.out` retain the intended rejection; this is a finite implementation mutation, not a proof mutation. The oracle separately checks literal owner contents, unchanged stale dead-row metadata, exact changed88 on live ID1 within high-water, and OOB no-op. For each Type payload placement, an explicitly constructed high0/live-ID1 shape and high1/capacity2/live-ID2 shape require mark to do nothing while physical metadata read still observes the live row. These four additional controls distinguish a dropped high-water guard. They are constructed-shape-domain tests, not an assertion that the allocator can produce live rows beyond high-water. Reads deliberately retain a capacity-only guard; mark matches the reference nonzero/capacity/high-water guard. Neither fixture requires `M: Data` or `A: Data`.

Run the complete bounded correctness check:

```sh
python3 experiments/s-prep/primitive-metadata-probe/check.py
python3 experiments/s-prep/primitive-metadata-probe/mutate-high-guard.py
```

The runner executes these commands, with a hard process-group limit and no clock collection:

```sh
# Each source: transport, schema, schema-positive, fixture; limit5s.
bend fixture.bend --check-only
# Negative files: expected exit1 and their exact intended diagnostic; limit5s.
bend negative-duplicate.bend --check-only
bend negative-schema.bend --check-only
bend negative-undeclared.bend --check-only
# Each codegen: limit30s.
bend fixture.bend -o fixture.js
bend fixture.bend -o fixture.c
# Clang: limit120s; each runtime: limit5s.
clang -std=c11 -O3 fixture.c -lpthread -lm -o fixture-native
node fixture.js
./fixture-native --threads 1 --gpu off
```

The scripts resolve their inputs relative to their own directory and can be rerun after relocation. `evidence.json` records exact source hashes, compiler/Node/clang versions, case IDs and output hash. `js.out`/`native.out` retain all42 full-field records. The negative files respectively reject duplicate affine Columns owner, Health permit at Motion read, and omitted declared permit. `schema-positive.bend` checks the permitted generic Type twin. These are small nominal/arity controls, not project provider authority: local constructors are public and permits can be constructed; no abstract-handle confinement, scheduler declared-access policy or integrated read/write rejection is claimed. Read-only `ReadPermit` is never consumed by a mark API because this witness does not implement a capability-bound write API. Integrating one requires the actual existing provider controls, not this nominal toy wrapper.

Observed pins: installed Bend2.0.35 binary SHA256 `f77417474ded314ad5d1a68fa3ebbe214c2124bf04d56a59b05bc17be6b0327a`; Base SHA256 `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`. Read-only Bend reference `a950fd683c0d76f09794078e6174fe98a1492876`, bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60` all match the tracked `.references/sources.json`; they were not modified. `bend version` and `bend guide` were run before source work. The installed checker succeeds; no scoped checker repair was needed. Its conventional `ALL PROOFS CHECK` text means successful source checking here, not an ECS proof.

Generated Native source supplies structural attribution only: changed/added/member accesses lower to `blk_at(...,0)`, flags to `blk_at(...,1)`, while this original metadata layout lowers to `blk_at(...,3)`. These are emitted layout exponents from this fixture, not profiling, dominance or speed claims. Runtime/growth costs of having more arrays remain unmeasured.

## Concrete integration seams and retained limits

1. Replace Rows metadata ownership with four aligned columns at the private storage boundary; use the destructive `from_original` seam for initial transport. Keep all Type Main/Aux arrays and namespace/identity/high-water rules. Constructors currently trust aligned equal-depth arrays and capacity: neither this witness nor the original reconstructed shape validates arbitrary malformed constructors.
2. Adapt extraction/restore, place/despawn, take/put/fuse, replace_main, flag mutation and slot growth with atomic field consistency. This witness covers read/mark only; no production lifecycle, membership ordering, rollback, removal readers, cache invalidation or flag mutation integration is present. Mixed optional combinations and growth must be exercised at the actual joined consumer.
3. Transport all four metadata columns through actual Cache/Held/raw staging and command/undo boundaries. Preserve flag/added/changed snapshots, restore earlier commits and failed publications, and retain Main/Aux owners through errors. No raw adapter or Host integration is implemented here.
4. Repeat the actual abstract-handle, undeclared-access, cross-schema and writes-through-read negative controls on the integrated provider APIs; keep the local nominal controls as infrastructure checks only. Run all22 full fresh gates and approved equivalent-work protocol before considering adoption. The exhausted attempt allowance is not renewed by this source artifact.

No universal refinement, model proof, executable-function proof, production API, performance acceptance or full-core completion follows from these finite records. Approval of additional laws and any new measurement allowance remain separate.
