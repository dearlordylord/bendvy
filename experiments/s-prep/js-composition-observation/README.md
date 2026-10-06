# Composed JS profiling observation

Incomplete performance investigation. Exact four-stage generated-code diagnostic:
World/Rows/Tx reuse, Held/Cache reuse, static call-product splitting, and pinned
nullary Data token sharing. [Recipes and semantic controls](../js-profile-composition/README.md)
remain scoped transformations, not compiler adoption or universal refinement.

Eight fresh Motion worlds (256 entities ×64 ticks) plus warmup pass all fields
in CPU/GC profiling and both heap-sampling executions. V8 sampling at32KiB
includes objects collected by minor/major GC, starts/ends at existing measured
phase markers and is not exact allocation accounting. Baseline and composition
sampled379/311MB respectively; differing samples/inlining prevent an exact byte
reduction claim. The composed CPU profile attributes14.8% self to query selected,
11.5% to GC and7.6% to storage mark guard. These are perturbed diagnostics.

Fresh adjacent full65 comparisons, milliseconds:

| Schema | bevy-ts | Baseline JS | Composed JS |
| --- | ---: | ---: | ---: |
| Motion |209.797197|341|438|
| Health |347.330431|746|598|

All fields match. JS parity remains unmet in both observations. Native roles
in these comparisons deliberately use the identical baseline binary twice;
there is no composed Native implementation or Native improvement claim.
Canonical attempts are exhausted; no cohort, qualified metric, keep, cap reset
or favorable-result selection. Full matrix/gates and independent acceptance stay
open. [Timing receipts](../cache-box-comparison/evidence/index.json),
[profile/heap inputs and outputs](evidence/index.json).

Commands use existing `js-profile/run.py`, `summarize.py`,
`heap-sampling-probe.py`, `heap-sampling-summary.py`, and the adjacent diagnostic
runner. CPU8 for Motion/profiles, CPU9 for Health, runtime5s. The injector now
accepts only its exact known marker hook reference; existing definitions or
unexpected symbols still reject. Its initial guard rejection is retained in the
index. No new tool, dependency, compiler/kernel, reference or production change.
