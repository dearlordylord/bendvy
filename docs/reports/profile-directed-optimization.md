# Profile-directed optimization continuation

Status: **incomplete** under #21/#24. JS parity and Native>=2x are not achieved or
qualified. Work follows generated JS, CPU/GC profiles and actual V8 allocation
sampling. These are bounded source probes; no production adoption, new proof/law,
compiler/kernel change, dependency installation or canonical allowance reset.

## Source results

All variants retain coherent29-module manifests, original callback algorithms and
arbitrary affine Type components. Counts cover eight fresh Motion worlds,
256entities×64ticks (131,072 callbacks); they count executed constructor expressions,
not physical allocations.

| Variant | Construction expressions | Result |
| --- | ---: | --- |
| Original profiling baseline |11,656,768|Reference diagnostic|
| Point+metadata+query fusion |10,478,144|Previously delivered|
| Flat point owner |10,216,000|−2/update; neighboring GC allocation grew, not adopted|
| Batched marks |10,218,048|−260,096;64 exact lifecycle fields/backend and live omission mutant pass|
| Batched+boxed point context |10,349,120|+1/update; narrower Native point transport|
| Batched+direct raw swap |9,955,904|−2 update closures/update; GC improvement unestablished|

[Flat owner](../../experiments/s-prep/js-flat-point-owner/README.md),
[batched marks](../../experiments/s-prep/js-batched-marks/README.md),
[boxed context](../../experiments/s-prep/boxed-point-context/README.md),
[direct raw swap](../../experiments/s-prep/js-direct-raw-swap/README.md).
Raw swaps preserve true old, all cells and metadata for four raw Type payloads on
JS/Native. Exact Native-specific patch retains existing helpers; an initial
application against the unsupported JS revision was refused without mutation.

Fresh boxed Tx controls pass both schemas, cached/original raw observation and
JS/Native. Mandatory no-op setter controls preserve true-old journal, marks and
full owner fields (144records per observer/backend subject). Lost-mark and
inverse-order compiling mutants are detected. Actual private setter families are
selected and source-bound; retained unused public setters are not mutation gates.
Direct-raw source also passes fresh original Tx/no-op controls.
[Fresh access controls](../../experiments/s-prep/profile-directed-access/README.md)
pass independently for JS direct-raw and Native boxed/direct roles:9 access,
8 provider (2positive/6negative),16 actual factory cases per role. These cannot
substitute for the full22 aggregate or general runtime refinement.

## Profiler findings

[Native phase sampling](../../experiments/s-prep/native-phase-profile/README.md)
excludes setup/serialization and validates all65 worlds against fresh TS.
term_drop, reached wide helper transport, motion_row and dispatcher continuations
remain prominent. Boxed Motion reaches a helper narrowed from63 to36 C parameters;
this is not an exact getter/source identity claim. The static schema entry retains
all selected work and recovers bounded C emission; canonical evaluator approval
remains separate. Sampling has few observations; percentages are diagnostic.

V8 collected-object sampling returns12,324 samples with406.4MB attributed self
size: callback frames124.6MB, held adapter117.5MB, query94.0MB, storage34.9MB.
Inlining can attribute allocations to callers. Allocation sampling is an estimate,
not exact accounting or retained-heap size. A local canary confirms collected-object
sampling includes allocations removed by GC. It uses the installed built-in
[Node Inspector API](https://nodejs.org/docs/latest-v24.x/api/inspector.html).
[Sampler and archived evidence](../../experiments/s-prep/js-profile/heap-evidence/index.json).

Same-CPU GC profiles contradict treating closure counts as a heap win: direct-raw
reports405.2MB versus batched380.2MB. Different GC interval boundaries/profiler/JIT
effects remain; do not adopt the raw swap from counts alone. A proposed point view
envelope predicts four extra records and unchanged property assignment count;
[cost decision](../../experiments/s-prep/js-point-envelope-cost/README.md) stops before implementation.

[Query CPS probe](../../experiments/s-prep/js-query-loop/README.md) passes nine full
worlds and a sparse high65538 control without increasing Node's stack limit. It
removes state records but adds14 closure expressions/ID and trampoline allocations:
11,920,960 total constructions, +1,965,056 versus its direct-raw input. Rejected as
an allocation-count candidate; no physical heap or speed regression is inferred.

## Source follow-up: live-first query

[Live-first flag read](../../experiments/s-prep/js-query-live-first/README.md)
branches before reading a dead slot's flag, preserving all affine columns. Dense
Motion construction count remains9,955,904; nine full worlds equal fresh TS.
Aligned all-dead high65538 removes65,538 Tuple constructions, with unchanged
other kinds. One short profiled sample estimates6.64MB versus6.24MB; no stable
heap/speed claim. Both schemas on JS/Native pass40 literal query/command checkpoints
and intended compiling order/membership mutants. Independent read-only review
finds no blocking semantic issue within that domain. Exact boxed Native static
Motion build passes15/30/120; one raw full65 observation TS389.164ms/JS776ms/
Native443ms still misses targets. Full22 remains separate; see terminal evidence below.

## Emitted affine container reuse

[Strict catalog probe](../../experiments/s-prep/js-affine-owner-reuse/README.md)
changes generated JS only, preserving evaluation order and every field. Reusing
private Held/Cache containers removes eight constructor executions per callback:
9,955,904 to8,907,328. Nine full worlds, cached Tx and four source-pinned
cached/raw suppressed-main fixtures pass exact comparisons (288 suppressed
checkpoints). Data snapshots, inverse nodes and generic Tuples are never mutated.
One sampled allocation observation falls from406.4MB to354.7MB; different runs
and sampling prevent treating this as stable heap or performance acceptance.
One fresh equal65-world comparison records TS1097.803ms versus JS1683ms,
so parity is still absent. [Raw receipt](../../experiments/s-prep/js-affine-owner-reuse/speed-evidence/index.json).

The [compiler follow-up draft](../design/affine-js-node-reuse.md) records the
checked ownership/origin information required before compiler adoption. Emitted
shape recognition does not prove universal alias safety. No compiler was modified.

## Timing and gate failures

Single unprofiled CPU11 Motion64 observation, all65 worlds equal: TS312.143ms,
JS direct-raw890ms, Native boxed/direct828ms. Both miss the targets in that
observation. Earlier raw Native clocks varied substantially, including986ms versus
TS1339.735ms. No qualified ratio, selected keep or complete matrix exists. Preserve
all observations; picking favorable timings is not acceptance.

Full22 remains FAIL. Combined gate first hit the embedded5s checker wrapper despite
an outer15s setting. Explicit executable15s now invokes supervised Bend directly;
default/proof5s remains unchanged. Subsequent combined Health query-order Cemit30
failed. Batched-JS joined gate failed Motion query-order Cemit30. Boxed joined gate
got through original, query-order and suppressed-setter on both backends/schemas,
then failed Motion inverse-order Cemit30. Downstream gates were not run by those
aggregates. Each partial pass belongs only to its exact source; no aggregate pass.
Live-first aggregate subsequently passes JS-role materialization/Host12/access,
then fails E11's missing host-batch-invoker override origin. The materializer
repair records copied control provenance; all95 Bend source hashes remain
identical. Standalone repaired E11 executes10 fresh TS references, then fails
Motion/message Cemit30:0 actual cases and mutants pending. Later JS gates and
the Native role are untested. [Terminal evidence](../../experiments/s-prep/js-query-live-first/full22-evidence/index.json).
Protected runner changes require pin reconciliation before canonical reuse.

Limits: executable diagnostic checker15s by explicit user approval, default/proof5s,
codegen30s, clang120s, runtime5s. References match the tracked manifest: TS3040a3b,
Bevyad67826, Bend2a950fd6; installed Bend2.0.35. No foreign process/repository was changed.

Next: the [Native cache-boxing draft](../design/native-point-cache-boxing.md)
records additional reached ABI headroom and allocation/drop costs before a source
probe. Investigate checked compiler reuse separately; reject source variants that trade
records for more closure/trampoline allocation; recover the exact-source full22
codegen gates; only then qualify complete equivalent JS/Native performance. Full
core, both schemas, five families×three sizes and copied defense integration stay
explicit follow-ups, not silently reduced scope.
