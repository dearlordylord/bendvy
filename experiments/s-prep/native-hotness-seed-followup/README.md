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

## Closed frame/trim negative follow-up

The next candidate freezes14 private exact-body trim/frame helpers while preserving
originals. Inspector/check15/emitter30 PASS and byte-identical C
`19a4fb4f6c2201b3c40343aef27f4f69130bbb62cb5f1d3867ad4488ee49074b`
observes1,888 branches/119sites. The first wildcard remains unchanged: original
streams.trim_second line74/span3722 supplies Batch<V> to Base List.reverse→go,
with foreign VarV index0 resolving to a:Qnt quantNone. This is evidence that the
original generic helper still reaches emission despite concrete private hooks;
not a successful global-sharing fix. Exact firstseed frames and bounds are archived.

## Corrected frame v2 follow-up

The source worker corrected two missed private helper call edges (actual P/H
arguments). Original v1 negative remains intact. Actual checker15/emitter30
replay PASS byte-identical C
`d406c71f4be0a5269260a936e97539b8e6a32b9ef10dd87879f2e5f7b5546275`
observes1,819 branches/117sites. The previous Batch trim seed is gone. New first
seed is observations.rows_finish line69 calling List.reverse with RowView<V,AV,F>;
foreign VarV index3/span4247 has no local telescope domain. Wildcard is false at
this site. Upstream frozen rows_go/advance still call an erased-type rows_finish.
Closing that helper is a separate source hypothesis, not a delivered sharing fix.

## Closed row-observation finish follow-up

The one-helper private frozen rows_finish removes the preceding RowView firstseed.
Checker15/emitter30 PASS, byte-identical actual C
`38fb1f6c285c012af5b462295365882cd94ad7660ee96724991699fd70cb4ff1`,
observes1,782branches/111sites. Next firstseed is observations.world_ledger line130
calling List.reverse(PendingView<V,AV,F>): VarV index6/span9419 has no local
telescope domain, starfalse. world_commands is frozen, world_ledger has erased
type arguments. Metadata worker owns the next exact-boundary experiment.

## Independent write-row-fold v2 counters

Actual Motion C
`4b6402750739fbf88959eaf82931b510dbd9ac9903f09e53582f1905bcf5e7f2`
with current29 source pins independently passes all65 complete fresh TS fields.
Approved private Clang19 compile120/runtime5 on CPU11; original C unchanged.
Heap29,070,279, RFC13,726,014 and cumulative requestedwords62,213,135 exactly
equal the prior row split. Operation totals also match: seal40,890,112,
ctr_take12,079,617, keep1,085,440, drop36,928, span8,192; zero allocator/system
misses/growth. Constructor-category totals agree. This new flat fold source
produces no additional measured allocator-request reduction over row split;
compared with original frozen baseline it independently retains3 fewer heap
requests/1 fewer RFC/18 fewer words per updated row. Requested words describe
primed local freelist requests, not physical allocation, peak memory or time.
Source-specific authority/negative/full22 and speed gates remain separate.
Receipts, original/derived C, full fresh observations and exact maps are archived
under write-fold-v2 names. No earlier candidate receipt is used as this acceptance.

## Closed world observation boundary

world_ledger closure removes PendingView firstseed. Checker15/emitter30 PASS
byte-identical C9e0d21c311ef8b8321f1e495f5ea548cc596d1d594c02d7dae5c7e98fe19a7db,
1,594branches/105sites. Next first is query.struct_idx_finish line103→List.reverse
with VarO index3/span12508/domNULL/starfalse. Exact source mapping accounts for
book_load blanking import lines (bend.ts984): span12508 points to O in that call,
not read_rows_finish. Metadata worker owns the next closed finish hypothesis.

## Independent no-Aux query counters

Actual C1d1310c739afad94a4d3383c301d0115cba3ab73948ce7940679748b6b539ec7/current29
passes65 complete fresh TS fields under privateClang19 compile120/runtime5 CPU11.
Against its frozen/continuation source base: heap31,863,751 (−352,256), cumulative
requestedwords80,382,991 (−704,512), RFC14,774,590 unchanged. The only constructor
category reduction is Velocity−352,256. seal56,962,816 and ctr_take13,824,513
reduce704,512 and352,256; keep/drop/span unchanged. System/miss/growth remain0.
This removes one two-word auxiliary constructor per populated Velocity; no
physical malloc, peak memory or speed inference follows.

Separately, compared with row split it requests2,793,472 more heap objects,
1,048,576 more RFCs and18,169,856 more words. These are different source overlays;
no joined or mixed-base saving is claimed. Exact fresh receipts/observations/maps
are archived under noaux-v1. Source-specific gates and qualification remain open.

## Closed query finish follow-up

Private closed struct_idx_finish/struct_cols_finish removes prior O firstseed.
Checker15/emitter30 PASS byte-identical C
`fef387f8acd21d622ed4a3d16b9f1fbd390c9a9d15ec6c584f4555808d3d64d2`,
1,582branches/105sites. New firstseed is transaction.commit line41→
List.reverse(&1,C,commands): foreign VarC index2/span2449 resolves xs:List
quantLone, with wildcardfalse. Import-blank source mapping confirms C in that
exact reverse call. A closed commit boundary remains a source hypothesis; all
commands/order/authority fields must stay intact.

## Independent composed fold + no-Aux attribution

Exact joined C
`f5261110337876cd31e0a0fd8c4d50f5f182b085306904f82ab69b6c7beb6295`
passes65 complete fresh TS fields with29 current source pins, unchanged original
C and approved private compile120/runtime5 CPU11. Actual heap28,718,023,
RFC13,726,014 and requestedwords61,508,623 are independently observed.
Against exact fold-v2 base:−352,256 heap/−704,512 words/RFCunchanged. Against
exact noAux-v1 base:−3,145,728 heap/−1,048,576 RFC/−18,874,368words. Arithmetic
additivity therefore holds for these observed requests in this exact join; it
was not assumed from individual sources. No speed additivity, physical-memory
claim, universal semantic refinement or source qualification follows. Raw complete
fields, currentmanifest, original/derived C and counters are separate join archives.

## Narrow transaction element follow-up

Freezing only the generic commit element C removes its previous firstseed;
full-slot source-emission negative remains the source worker's separate receipt.
Read-only checker15/emitter30 PASS byte-identical C
`e2505123516eaa289bc9568eb503d8d607691ccd82ab341ba2bae9f9f5b55125`,
1,572branches/103sites. Next actual firstseed is transaction.storage_commit
line121→List.reverse(&1,S.Command<M,A,F>,commands): foreign VarM index1/span9071
resolves local A:Type quantNone with wildcardfalse. Import-blank mapping confirms
that exact source call. Global sharing is still seeded; conditional follow-on
counters for a globally resolved candidate therefore were not run. No code or
compiler edit was made by this diagnostic.

## Minimal storage commit follow-up

Freezing storage_commit M/A/F removes the preceding Command reverse firstseed.
Checker15/emitter30 PASS byte-identical C
`019713f7a0db70f64b64a877974a1c0106ce51b214e8f7d44d2b9fca7032e7f8`,
1,922branches/107sites. New firstseed is transaction.storage_mark_all calling
prototype_storage_mark_loop: foreign VarL index1/span9500 resolves local M:Type
quantNone with wildcardfalse. Globalstar remains; conditional resolved-star
full65/counts were not triggered. Branch/site counts grew from the previous
source despite moving its firstseed, illustrating that frontier movement alone
is not global-sharing resolution or a performance result. No further source
closure is presumed; metadata worker owns its bounded seam decision.

## Final private ledger-mark seam

The bounded privatecommit→markall→loop frozen L seam removes the prior markall
firstseed. Checker15/emitter30 PASS byte-identical C
`4dd5f99cc148bcc4a4483a45d00b4b45c9021ff2ef46c1c1f695cbd41ed0fcac`,
1,759branches/105sites. Final precise next firstseed is storage.publish line275:
List.reverse(&1,Command<M,A,F>,staged) recursively heats foreign VarM index1/
span24395, resolved against local A:Type quantNone while wildcardfalse. The
unchanged function prepends staged FIFO commands to pending with reverse.go;
no staging/order work was removed. Global wildcard remains, so conditional
resolved-star counters were not run. The bounded source investigation stops
with this exact residual, not a global-sharing, speed or acceptance claim.

## Publish-only final bounded negative

The additional private frozen publish helper and single already-closed commit
redirect checker15/emitter30 PASS, byte-identical actual C
`6ab2a0198168bbed2a29bc6f5a40bc00607d706a37a8ae5b5d5f66abed1c3304`.
All1,759branches/105sites and the FIRST seed remain unchanged: original generic
storage.publish line275/span24395 Command<M,A,F>/VarM index1 resolves A:Type
quantNone while wildcardfalse. Another route still emits the original generic
publish. No further cascade is authorized by this probe; it ends as a precise
negative. Globalstar remains, so conditional absent-star full65/counts were not
run. Moving private callers does not justify claiming elimination of generic
emission or runtime sharing. Exact current-source/compiler/C pins are archived.
