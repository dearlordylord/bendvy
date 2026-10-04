# Exact Lifecycle measurement checkpoint

This package extends the earlier bounded Lifecycle observations to the complete historical-stale workload. It is executable finite evidence, not a proof or performance acceptance. Both nominal schemas use genuine affine payloads, actual registered dispatcher callbacks, storage, command queues, barriers, lookups and captures.

The actual selector queries membership and chooses first/middle/last. Each of 64 iterations invokes Select+Reserve, Observe, Deferred, Observe, Dispose+Deferred, Observe. Each Observer reads every Main/Aux/Flag field, Ledger, pending/current/foreign lookup and every previously disposed handle: 192 boundaries and 6,112 historical-stale lookups per case. The foreign world is genuinely created, published and queried before being discarded. Returned reservation handles and payloads are retained as actual events. No expected map drives selection or reconstructs a handle.

Full-output runs compare complete lossless tuples, all 64 actual reservation events, final owner/query/marks/pending/Mode/Ledger and captures. Their row observations also match the unchanged original TS reference’s boundary hashes. The complete TS and Bend lookup results retain the intentional raw-ID foreign collision difference; each is checked against its own expected result, not silently normalized. TS tuple namespace 1 is an explicit observation-lane tag, not reference-world authority. Capture totals are Select/Reserve/Dispose 64 each and Observe 192; the Bend clock is tick 513/frame 385.

Timing uses a fresh identical warmup followed by one fresh measured world, seven rotated Native/TS/JS repetitions, 64 iterations at counts 64/256/1024. Both authored loops consume the same ordered full-field checksum inside the clock. JSON and final diagnostic world reads occur afterward. Descriptor construction is outside the clock; TS lazy internal registration remains part of first invocation. Correctness output is never reported as a steady-loop timing. Checksum equality supports each quiet run only after complete-field correctness; it is not a collision-free substitute for the full trace.

The initial run completed six full-field cases and timing repetitions but was interrupted before mutant builds after discovering invalid inherited-peak RSS accounting. Its evidence is preserved as `measurement-lifecycle-timed-first-evidence.json`; all its RSS values are withdrawn. The corrected harness uses the byte-identical clean C launcher introduced by root 2213b0d. That launcher forks the backend from a small executable image and reports the backend child’s `wait4` peak; the outer Python process’s inherited peak is discarded. RSS includes startup, warmup, setup, final output and backend-owned validation, not only ECS allocations. It is a descriptive process-memory quantity.

Run `python3 experiments/s-integrate/measurement-lifecycle-timed-run.py`. CPU 10 is pinned for the harness and descendants. Checker/runtime children retain five-second process-group limits; codegen and clang retain their separate 30/120-second limits. Source closure, compiler/Base, helper, adapter, launcher and contract hashes are recorded. No dependencies or installed/reference files change. Earlier full-JSON/tuple timeouts remain historical failures; this smaller public-observation stream is a separately identified workload adapter, not a relabeling of those failed runs.

Current replay results are recorded in `measurement-lifecycle-timed-evidence.json`; the original author outcomes are preserved separately in `measurement-lifecycle-timed-frozen-evidence.json`. Numerical thresholds remain unapproved; slower results are regressions to investigate, not acceptance.

The first corrected-launcher attempt stopped while compiling its tiny C helper because the harness accidentally applied the default five-second runtime deadline to clang. No backend ran in that attempt. The corrected invocation uses the existing 120-second clang build limit; runtime/checker limits remain five seconds.

Strict decoder controls on an actual Motion64 boundary rejected shortened Main cell tuples, a string in a U32 cell and reversed query order. These are protocol/oracle controls; the compiling runtime mutations are recorded separately.

## Frozen `c28fe5f` measured cases

All four 64/256-row cases passed full fields and seven samples on each backend. Both 1,024-row cases retained Native and JS full-output five-second failures; TS passed. No corrected ratios or memory summaries are published for those unverified cases. The initial pass does not override these current failures.

| Schema/count | Native/TS median time | JS/TS median time | Native/TS/JS median peak KiB |
| --- | ---: | ---: | --- |
| Motion 64 | 2.01 | 3.99 | 4064/101048/80512 |
| Motion 256 | 2.06 | 4.19 | 6364/108904/139116 |
| Health 64 | 1.46 | 3.22 | 4188/100688/80228 |
| Health 256 | 3.29 | 5.05 | 6896/100424/135932 |

Ratios above 1 mean Bend took longer. Raw min/median/max and every sample are retained in the JSON; notably Motion64 Native ranged from 22 to 224 ms. This variability prevents treating a single ratio as stable performance. Corrected Native peaks are measured from the clean launcher; the initially inherited parent peaks have no memory interpretation.

Final runner exit: **1 / REGRESSION**, deliberately retaining the four 1,024-row backend deadline failures. Both wrong-target and omitted-disposal mutations compiled to Native/JS and were rejected by the unchanged complete-field validator on both backends. These are actual command/selection mutations, not oracle perturbations. No failed build is counted as a semantic rejection.

## Coordinator reproducibility refresh

The author package's exact import closure is retrievable at `c28fe5f`; five
shared runtime files differ from the joined root. Its record is preserved as
`measurement-lifecycle-timed-frozen-evidence.json`. The delivered runner also
imported an unmerged Dense/Sparse timing helper. It now imports the already
delivered sampling helper with the same deadline/statistics operations and
explicitly contaminated outer RSS labels; the clean inner launcher remains the
actual memory collector. A complete root-current replay is in progress.

Independent root-current Motion64 mutation replays retain exact public witnesses
in `measurement-lifecycle-mutation-witness-evidence.json`: choosing only the
head changes `observations[5].query[0].handle.id` from 2 to 3; omitting disposal
changes `observations[2].query` length from 64 to 65. Both are compiling
Native/JS runtime changes with identical witnesses, not typing or timeout kills.

The first root-current refresh passed Motion64/256 then stopped when its fresh
authoritative Motion1024 TS prerequisite exceeded five seconds. The interrupted
record is retained as `measurement-lifecycle-timed-current-interrupted-evidence.json`.
The runner now records a failed reference prerequisite per case and continues
independent cases; it never manufactures backend comparison or timing ratios
when the required reference is unavailable. Runtime limits remain unchanged.

## Root-current replay — `06f88a3`

Every runtime/import hash and the runner hash match the joined checkout. Five
complete cases pass all 192 full-field boundaries, 64 raw reservations and 6,112
historical-stale lookups before seven validated timing/memory repetitions on
each backend. Health1024 retains Native and JS five-second full-output failures;
TS passes. This case has no timing ratios or memory acceptance. Overall
exit1/REGRESSION is retained. The main replay detects omitted disposal on both
backends; its head-only mutation attempt hits the five-second checker limit and
is not a semantic kill. Separately, the earlier independent focused replay of
the byte-identical current import closure compiles and detects both mutations
on both backends, recording exact public differences. These records are distinct.
The interrupted reference attempt and older runtime measurements remain separate.

| Schema/count | Native/TS median | JS/TS median | Native/JS/TS median peak KiB |
| --- | ---: | ---: | --- |
| Motion 64 | 1.49 | 3.16 | 3052/81148/108788 |
| Motion 256 | 2.74 | 5.01 | 5396/135156/100460 |
| Motion 1024 | 5.03 | 4.54 | 15208/217344/110108 |
| Health 64 | 1.11 | 2.94 | 4188/81860/101944 |
| Health 256 | 3.23 | 5.40 | 6900/136004/99800 |

All these descriptive time ratios exceed1. Physical peak log/command occupancy
and peak reader lag remain uninstrumented; process RSS does not identify their
storage. Source changes and variability are retained without assigning a causal
speedup to a particular fix. Mandatory product performance is not met.
