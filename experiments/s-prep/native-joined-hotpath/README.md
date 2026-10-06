# Joined Native hot-path attribution

Exact fold/noAux29-source join is read-only and reverified in pins.json. No source,
compiler/kernel/reference/runtime implementation or dependency is changed. Existing
privateClang19 is used, CPU8/oneworker/GPUoff. Both schemas complete fresh65 TS
world field comparisons pass before phase GNUgprof2.40 output is admitted.
Motion branch counters independently pass65 fields. Phase is original clocks3/4;
compile120/runtime5 and exact original/derived hashes remain recorded. Instrumented
clocks are not metrics. New counter code retains every original helper operation,
argument/evaluation and complete workload; only counters/phase reporting are added
in private generatedC. No diagnostic mutation is a source optimization.

Sparse profile observations: Motion25ticks includes term_drop8, foldstep4, spin514,
dispatchervisit3, RFCwrap3, foldloop2. Health24ticks includes foldstep8, RFCwrap4,
loopcontinuation3, drop2, dispatchervisit2 (andstartup_init2). Sparse proportions
vary; no precision, causal stack or speed inference follows. Drop remains a useful
source seam but is not proven dominant in both schemas.

Motion exact dynamic runtime destruction counts:

| Operation | Executions |
| --- | ---: |
| term_drop external entries |36,928|
| iterative outer / inner steps |4,235,328 /12,714,048|
| RFC decrement / last release / deferred release |4,223,040 /4,198,464 /24,576|
| object frees / child slots visited |4,210,688 /8,466,432|
| RFC view / wrap / bump |9,556,414 /13,726,014 /20,480|

Dropped actual constructor IDs map to Cons2,101,248, Handle1,052,672,
MainInverse1,048,576 and System4096. Destruction therefore traverses journal/list
and nested handles, rather than millions of payload/world objects. Internal loop
counts explain why prior36,928 drop callsite counts understate actual runtime work.
These count executed branches, not elapsed costs. Counts include forced original
observer work; no helper or ownership work is skipped.

Earlier source-specific allocator attribution (separate native-hotness-seed-followup)
shows journal spin31 creates5,234,688 RFCs across nestedHandle/MainInverse/list tails;
spin45 creates4,190,208 around cache payload/view and marks; spin65 creates2,097,152
around cachepayload/view. Those static sites and counts do not provide dynamic
call-stack timing. Global hotness seed is separate compiler-emission evidence;
this profile cannot infer what proportion is avoidable sharing.

Concrete next Bend-source experiment: retain abstract public Handle and original
rollback algorithm, but use private flattened journal entries containing the same
namespace/id and Maybe affine owner fields. Construct public Handles only at
necessary authority boundaries; preserve world binding and every inverse/mark/order
observation. A flat owner/journal fold could avoid nested Handle constructor/RFC
creation and immediate committed-journal destruction. It must prove its actual
emission changes and pass independent full65, rollback/directTx/access/Type controls
before comparative timing. No Data-only scope, journal deletion, ignored failure
work or compiler-sealing change is proposed. If flattening preserves identical
emission, retain the negative and stop that seam.

Requestedwords/allocator requests are not physical malloc or peak memory. No speed
qualification, source keep, new law/proof or universal runtime refinement is claimed.
All raw profiles/phase markers/full observations/dropcounts/generateddiagnosticC
are verified deterministic archives. The script runs only exactMotionjoinC:

```sh
python3 experiments/s-prep/native-joined-hotpath/drop-count.py --source /tmp/bendvy-threehour-fold-noaux-motion-build/batch.c --reference /tmp/bendvy-frozen-chain-motion-comparison/reference.mjs --output /tmp/fresh-join-drop
```
