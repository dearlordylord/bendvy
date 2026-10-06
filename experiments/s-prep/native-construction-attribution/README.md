# Native construction attribution

Bounded diagnostic for #21/#24, prepared from master3475dd3. **All65 complete
Motion states match a freshly executed pinned TS reference.** The original
frozen29-module generated C is unchanged before/after. These instrumented clocks
are not speed measurements, a keep, qualification or full-core acceptance.

| 64 worlds ×256 entities ×64 ticks | Executed requests |
| --- | ---: |
| Runtime heap_alloc |32,216,007|
| RFC redirect cells |14,774,590|
| Constructor-node allocations |17,322,305|
| Closure allocations |119,111|
| Task allocation |1|
| Cumulative requested allocator words |81,087,503|
| Allocator misses / bank pops / corpus growth |0 /0 /0|
| libc malloc / mmap / mprotect calls |0 /0 /0|

All heap requests in this phase use the primed local allocator freelists. The
word count includes repeatedly reused storage; it is not physical malloc bytes,
resident memory, peak live memory or a count of every constructor evaluation.
The allocation-kind partition sums exactly to32,216,007. Static labels identify
the unique constructor/closure use of an allocated C local; the single task is
otherwise unclassified. No stack sampling or inlining attribution is used.

All14,774,590 RFC creations originate constructor-field `rfc_seal`, **zero**
from `term_keep`, although1,085,440 keep calls execute. Array block allocator
sites make zero requests. Native transport is mainly escaping boxed records,
list nodes and the redirect cells used to seal their fields.

## Concrete source seams

Actual direct source sites, available with exact original C line numbers in
[evidence/index.json](evidence/index.json) →current-analysis.json.gz:

| C owner / preserved work | Constructor requests | RFC requests |
| --- | ---: | ---: |
| spin_43: two Handles, MainInverse, undo Cons, mark Cons |5,242,880|5,234,688|
| spin_36: query Cache/Position/View, Handle and present Velocity |4,546,560|2,097,152|
| spin_89: Held Cache/Position/View |3,145,728|2,097,152|
| held_adapter.motion_row_0:15-field World and1-field Raw root |2,097,152|1,048,576|
| spin_30: result Cons |1,048,576|2,093,056|
| spin_34: undo-operation Cons |1,048,576|1,048,576|
| spin_113: list reversal |0 (existing spare reused)|1,044,480|

`spin_N` labels are emitted specialized functions; their archived static direct
caller edges are not a claim about dynamic call stacks or a uniquely recovered
Bend def. The generated records/fields identify the stated work directly.

Follow-ups, sent to query/Held workers and integrator:

- Flatten private nested Cache owner/view products at trusted transport seams;
  preserve getters, arbitrary Type component ownership and abstract callbacks.
- Avoid rebuilding the nested World/Raw product for each Held row; retain every
  World field and restoration/rollback path.
- Investigate flat private journal/mark handle payloads: two Handle constructors
  and their two seals execute per update. Preserve world identity, order, stamps,
  inverse journal and atomic rollback. This is proposed research, not adopted.
- Preserve required result/list semantics while reducing escaping intermediate
  list products. Reversal already reuses allocation spares but still seals its
  tail, so removing allocator requests alone would miss that work.

No StructColsState/Rows/MetadataColumns allocator request appears in this phase;
Native already flattens those transports. A JS construction reduction there
cannot be assumed to reduce Native heap requests. Closures are119,111 requests,
well below the record/seal contribution; runtime getter closure removal alone
cannot explain this remaining Native churn.

## Compiler basis and boundaries

Read-only Bend2 commit a950fd683c0d76f09794078e6174fe98a1492876 matches tracked
reference report. In bend2/comp.ts, ctr_build (1058–1065) builds/reuses nodes;
seg_clo (1519–1522) allocates closures; node_fill (1551–1557) emits rfc_seal for
fields of constructors marked hot. facts_hot/facts_ctr (1398–1452) propagate
sharing requirements through types and fields, and bind_pop (1773–1787) marks
shared values hot. rfc_seal/rfc_wrap (3870–3882) allocate redirect cells only for
unsealed CTR nodes. This explains the observed sealing mechanism; it does not
claim every Data constructor always seals or remove Bend ownership obligations.

Runner expands the four BLK_ALLOC invocations exactly, adds expression counters
without rearranging arguments, and threads an extra diagnostic origin identifier
through the two runtime retain/seal helpers. Every original helper operation,
field, branch, argument and evaluation remains. The enclosing third/fourth clock
markers bound the existing phase; warmup/setup and output serialization are
excluded. Instrumentation can change optimization decisions. Counts are facts of
these diagnostic copies, not universal uninstrumented-binary counts.

The first parser was interrupted before compilation; the first compiling recipe
failed because overlapping nested-call edits corrupted diagnostic expressions.
Both receipts are retained. Corrected insertion-only edits passed full65; the
final additional allocator/physical-operation counters independently passed
full65 and reproduced exactly the same heap/RFC totals. No failure is a pass.

## Reproduce

```sh
python3 experiments/s-prep/native-construction-attribution/run.py --source /tmp/bendvy-query-frozen-provider-motion-build-v2/batch.c --reference /tmp/bendvy-clang19-diagnostic/motion-comparison/reference.mjs --output /tmp/fresh-native-construction-attribution
python3 experiments/s-prep/native-construction-attribution/analyze.py --source /tmp/bendvy-query-frozen-provider-motion-build-v2/batch.c --sites /tmp/fresh-native-construction-attribution/sites.json --output /tmp/fresh-native-construction-attribution/analysis.json
```

CPU11, approved private unchanged Clang19 wrapper/ELF pinned, O3 compile120s;
fresh Node TS and native runtime5s each, threads1/GPUoff. No Bend compilation or
checker was needed for this generated-C diagnostic. Read checkpoint, #21/#24,
SPEC, R-A/R-C1 and Bend-LDD; ran Bend2.0.35 version/guide before source review.
The runner verifies all29 frozen source hashes, original C, wrapper and ELF.
Artifacts retain original/derived C, complete raw outputs, counts, mappings,
upstream source/build manifests and failed receipts. Binary hash/path is in the
build receipt; no binary is committed. Current run: /tmp/bendvy-native-attribution-v4.

No compiler/runtime/kernel/reference/system edits, dependencies, laws, proofs or
production source adoption. Full22, authority/refinement, cross-schema/undeclared/
read-write source controls, Health/JS matrix and final JS≤TS/Native≥2× targets
remain open for any proposed source change. This task's finite positive equality
is not those gates.

## Why the affine World becomes hot

A read-only Node inspector observes the unchanged compiler at first wildcard and
World insertion. Compiler/entry/Base hashes remain unchanged, and regenerated C
is **byte-identical** to the installed baseline01683bcb… . No compiler edit,
monkeypatch, dependency or listening debugger endpoint was used. Book checking is
bounded15s under the explicit diagnostic allowance; C emission30s.

First wildcard insertion is `storage.metadata_live` calling
`metadata_live_done(F,...)`: `facts_hot` receives `Var F` with index2,
force=true/local=false. Its definition telescope at index2 is instead
`[Lone, "index", U32]`. Since the domain name differs from F, the compiler takes
its conservative `hot.add("*")` branch. This is exact observed IR/domain evidence;
no underlying soundness defect or universally incorrect compiler is claimed.

The first World insertion is later `measurement.motion_queries` →`bind_uses`,
with hotStar=true and binder world used exactly once (n=1). `bind_uses` forces every bound type hot when the wildcard is
present. World being explicitly affine Type does not prevent this global
representation fact. Direction: erased helper instantiation→wildcard→bound World
and its fields; a Data field alone is not the demonstrated first cause.

A distinct private Type context may still be heated under that same wildcard.
The proposed source seam is closed/frozen metadata helper type instantiation,
followed by inspection for additional wildcard seeds and full source-specific
controls. This is not permission to disable sealing or alter compiler/kernel.

```sh
python3 experiments/s-prep/native-construction-attribution/inspect-run.py --entry /tmp/bendvy-query-frozen-provider-motion-build-v2/batch.bend --output /tmp/fresh-hotness-inspection
```

Earlier inspector diagnostics remain archived: an unchecked book could not be
emitted; an initial breakpoint missed World and serialized circular IR poorly.
The corrected read-only probe observes both seeds and their domains. None of the
incomplete probes establishes the final cause by itself.

## Source-specific sibling comparisons

At integrator request, the same counter recipe independently checked the actual
Held-flat-both v5 C13a70ed6… and query-flat C6d0b53fd… . Their own29-source maps,
entries, upstream receipts and C before/after hashes were verified. Each matched
all65 complete fresh TS states under5s. Both show **zero delta** in heap requests,
RFC creations and cumulative requested words; counts.txt is byte-identical to
baseline (SHA256 c5fdb3ca…) despite distinct source/C hashes. These JS construction reductions do not remove the observed Native allocator
and sealing requests. This
establishes the count result, not speed equivalence or source gate readiness.

Current task receipts cover195 worlds (65 baseline +65 Held +65 query), with an
additional earlier baseline65 pass retained separately. The sibling source
changes remain owned by their respective workers; this folder adopts none.

```sh
python3 experiments/s-prep/native-construction-attribution/run.py --source /tmp/bendvy-held-flat-both-motion-build-v5/batch.c --source-root /tmp/bendvy-held-flat-both-reproduced-v5 --expected-source-sha256 13a70ed64cb040237f57c9ee1b7679836cb15ee5aa2f4805a4d81d13d1a98ffe --reference /tmp/bendvy-clang19-diagnostic/motion-comparison/reference.mjs --output /tmp/fresh-held-attribution
python3 experiments/s-prep/native-construction-attribution/run.py --source /tmp/bendvy-source-query-flat-motion-build/batch-retry.c --expected-source-sha256 6d0b53fd7788b730d3ce7fc7d60ccae0210d35f9e85c3ef793cb1c2fcfbf5d48 --reference /tmp/bendvy-clang19-diagnostic/motion-comparison/reference.mjs --output /tmp/fresh-query-attribution
```
