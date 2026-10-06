# Native hotness seed follow-up

Read-only continuation of [construction attribution](../native-construction-attribution/README.md)
under #21/#24. No compiler, reference, kernel or production source edits. The
metadata worker owns its source candidates; this folder observes their actual
emission and keeps capability/performance gates open.

## Observed wildcard branches

The Node inspector pauses at the actual conservative `hot.add("*")` branch.
All executed occurrences are recorded, including already-hot repeats; they are
not168 independent initial causes. Every emitted C byte matches the separately
emitted pinned CLI C, with compiler/entry/Base unchanged before/after.

| Actual source | Executed branch entries | Distinct IR/domain sites | First independent seed |
| --- | ---: | ---: | --- |
| Frozen29 baseline |2,329|168|metadata_live →metadata_live_done, F index2 mapped to index:U32|
| Metadata live CPS candidate |2,332|169|metadata_get_live →Array.get(Maybe<F>), F index2 mapped to added:Array<U32>|

The first baseline replay hit the15s read/check bound, before any emission; its
negative receipt is retained. A fresh replay enabled the debugger after checking
and completed within unchanged15/30 bounds. No timeout is a passing seed result.

CPS removes the original live-only seed. Its next first seed has
wildcardPresent=false, force=true/local=false: the Array.get intrinsic requires
sharing its Data flag result and recursively forces Maybe<F> then F. Domain-name
mismatch takes the conservative branch. Main/Aux component ownership remains
Type; a Data-only restriction or suppressing field sealing is not the remedy.

Other early **potential** baseline sites:

| Definition | Actual variable | Definition telescope lookup |
| --- | --- | --- |
| metadata_get_live |F index2|added:Array<U32>|
| grow |M index0 /A index1 /F index2|fuel:Nat /M:Type /A:Type|
| grow_decide calls slots_empty/metadata_grow |M index1 /A index2 /F index3|A:Type /F:Data /needed:Bool|
| List.reverse and List.reverse.go |caller M/A/F variables|library A/xs/acc or no domain|

The full compact maps are archived.88 of168 baseline distinct sites originate
`bind_uses` under the already-present wildcard, including function types. Those
are propagation/cascade observations; removing the first seed need not remove
them individually, and their appearance after the first seed does not prove they
would independently seed a cold compiler fact set. The CPS run establishes one
actual next independent seed rather than assuming all later entries are causes.

## Source-only route and limits

1. Close concrete type instantiation at private query/provider helpers while
   preserving the generic public wrappers and rank2 abstract callback contracts.
   A frozen Schema chooses Main/Aux/Flag types, including arbitrary affine Type
   components. Trace subsequent first seeds after each source change.
2. Investigate private erased-binder ordering and closed-template helpers before
   runtime fuel/fields. This can align the type variables with the helper's own
   telescope; generic callbacks must still be valid for arbitrary owners.
3. Retain genuine Data sharing for flags, handles and journal values. If open
   caller variables reach library Array/List helpers, use legal source-level
   closed wrappers or continuations; do not alter Base or compiler facts.
4. Avoid transporting complete World as a nested callback-owned box when the
   callback only needs its declared main/ledger owner. Keep untouched affine
   World fields outside, return them once and rebuild at the boundary. This
   attacks escaping allocation even while a wildcard remains. The separate
   row-owner worker owns that hypothesis and its source gates.

A new private Type name alone cannot prevent wildcard-forced hotness: the earlier
actual first World heat was bind_uses(world,n=1), despite affine Type and a single
use. Closed/frozen helpers and binder ordering are legal mechanisms, not a claim
that any wrapper automatically removes all global hotness. Public generic
lifecycle paths may remain reachable and must be diagnosed separately.

The small binder-order.bend fixture checks an arbitrary Type owner with fuel-first,
erased-type-first and frozen-type-first recursion. Checker15/C emission30 pass;
three literal full Array-owner observations pass Native under5s after approved
private Clang19 O3/120 compilation. This establishes these binder arrangements
are legal; it does not prove their application fixes storage or authority. No ECS
law/proof was added. Existing dependent Type/negative/refinement/full22 gates
still apply to any source adoption.

## Actual query continuation counters

The separate frozen-continuation v2 source C
adee80fefd5aa7eb2c5000b73e09f7e8776f7df8c1896d83c92ff83b2d24b9cf has
all29 source pins verified and matches65 complete freshly executed TS worlds.
Its allocator/ownership operation totals equal the baseline exactly:

| Operation | Baseline and continuation v2 |
| --- | ---: |
| heap_alloc / RFC creation |32,216,007 /14,774,590|
| cumulative requested words |81,087,503|
| rfc_seal / ctr_take |57,667,328 /14,176,769|
| keep /drop /span_fade |1,085,440 /36,928 /8,192|
| allocator misses /bank pops /system allocation/growth |0|

Constructor-category request counts also agree. Per-site files differ because
specialized closure identifiers/site placement changed; no elapsed equivalence
or performance acceptance follows. This is a fresh source-specific receipt,
not transfer of the earlier flat-result or Held evidence.

## Actual row-owner split counters

The separate row-owner split C
`e537a0ec77b67f6e7c2c5e2af389462e0523dcd95d351211de1417e9fe6c013e`
has all29 current source pins verified and matches all65 complete fresh TS worlds.
It removes an actual Native allocation seam; no elapsed result is inferred.

| Operation | Baseline | Row split | Reduction per updated row |
| --- | ---: | ---: | ---: |
| heap_alloc |32,216,007|29,070,279|3|
| RFC creation |14,774,590|13,726,014|1|
| cumulative requested words |81,087,503|62,213,135|18|
| rfc_seal |57,667,328|40,890,112|16|
| ctr_take |14,176,769|12,079,617|2|

Exactly1,048,576 World constructor requests, RawWorldRoot requests and RFC redirect
requests disappear. World allocates16 words, RawWorldRoot1 and its RFC redirect1:
18 words per updated row. keep/drop/span remain1,085,440/36,928/8,192; allocator
misses, bank pops, corpus growth and system malloc/mmap/mprotect remain zero.
These are requests serviced by primed local freelists, not physical allocations
or peak memory. The source worker retains complete untouched affine World context
outside the seven-field callback owner and reassembles it on row return. Public
callback headers and all observed fields remain intact. Dependent semantic and
performance gates remain separate and open.

Compressed receipts, exact source/build manifests, original and instrumented C,
full observations and maps are indexed in evidence/index.json. Archive and decoded
hashes are recorded; failed initial15-second baseline inspection is retained.

## Reproduce

```sh
python3 experiments/s-prep/native-hotness-seed-followup/run.py --entry /tmp/bendvy-query-frozen-provider-motion-build-v2/batch.bend --expected-c /tmp/bendvy-query-frozen-provider-motion-build-v2/batch.c --output /tmp/fresh-baseline-seeds
python3 experiments/s-prep/native-hotness-seed-followup/run.py --entry /tmp/bendvy-metadata-cps-motion-build/batch.bend --expected-c /tmp/bendvy-metadata-cps-motion-build/batch.c --output /tmp/fresh-cps-seeds
python3 experiments/s-prep/native-construction-attribution/run.py --source /tmp/bendvy-source-query-cont-motion-build-v2/batch.c --expected-source-sha256 adee80fefd5aa7eb2c5000b73e09f7e8776f7df8c1896d83c92ff83b2d24b9cf --reference /tmp/bendvy-clang19-diagnostic/motion-comparison/reference.mjs --output /tmp/fresh-continuation-counters
```

Row split counter reproduction uses the same prior committed counter runner with
`--source /tmp/bendvy-row-owner-split-motion-build/batch.c`,
`--source-root /tmp/bendvy-row-owner-split` and
`--expected-source-sha256 e537a0ec77b67f6e7c2c5e2af389462e0523dcd95d351211de1417e9fe6c013e`.

CPU11; read/check15 under explicit diagnostic approval, emitter30, approved private
Clang19 compile120, runtime5, threads1/GPUoff. Node inspector is an in-process
Session with no listening endpoint or monkeypatch. Timers enforce bounds, not
metrics. No canonical packet, budget reset, new dependency, law, proof, authority
approval, universal refinement, full22 or JS≤TS/Native≥2× acceptance is claimed.

## Closed storage frontier follow-up

The separate closed-private62-helper storage/command/barrier frontier v3 removes
the earlier actual storage first seeds. Its actual C
`9f4e9062e53c1b8d80d36b822339ff58743789894b3cbe58840dee82d734139e`
is byte-identical to the read-only inspector emission (checker15/emitter30 pass).
The replay observes2,026 wildcard branches/129 distinct sites, with no missing
frames. The new first global wildcard is `streams:append_buffer` calling
`streams:count`: forced Var H index0 resolves to caller V:Type (quantNone),
not H. Wildcard was false at this site. Later capture/dispatcher branches already
observe wildcard true. This confirms a changed first-seed frontier, not elimination
of global sharing. Metadata worker owns the next source hypothesis. No compiler,
Base or source edit occurs in this diagnostic. Exact pin/frame receipts are archived.

## Closed stream follow-up

Private frozen stream/read-host lifecycle helpers remove the preceding first
stream-helper seed. Exact emission/check15/emitter30 PASS C
`18057e5a3c19bfb1ab00d7904b12f5784b6f55e8d9bd30869974db7ed809333f`
observes1,894 branches/120sites. Actual next first wildcard is Base List.reverse
calling List.reverse.go: Batch<V> recursively exposes foreign VarV index0,
resolved against local dom a:Qnt quantNone while wildcard is false. This is
remaining generic library reachability, not a need to change Base. Metadata
worker owns the source-only closed reversal hypothesis; no result is presumed.
