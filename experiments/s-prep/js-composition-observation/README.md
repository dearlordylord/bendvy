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

A trace-only `--trace-turbo-inlining` diagnostic verifies nine full worlds on
TS, exact baseline and store-elided JS. The generated hot query does inline
array_rmw, main/aux and run_clo; zero `Cannot consider`/`Not considering` lines
were observed for these two Bend traces. This does not justify tuning V8 budgets.
It identifies actual freshly built query providers, consumed by a callback that
ignores them, as a separate closed-call optimization hypothesis. [Raw traces](inlining/index.json).

Further adjacent Motion diagnostics: same-slot store elision343→311ms (TS197.458),
then static swap bridge308→290ms (TS217.928). Their baselines differ, clocks are
unqualified and every full65 field matches. Do not chain these timings into a
cumulative speed percentage. [Scoped store controls](../js-owner-store-elision/README.md),
[swap controls](../js-array-swap-elision/README.md). JS parity remains unmet.

## Later exact diagnostic chain

The final old-source chain executes 5,498,944 constructions/eight timed worlds,
versus baseline10,086,976 (45.5% fewer literal/closure constructions, not physical
allocations). Its fresh full-nine-world heap sample is239,600,904 bytes, versus
baseline378,932,680; the approximate36.8% sample reduction is not exact accounting.
The CPU/GC trace reports246MB between GC intervals versus TS92MB, with22.45% JS
self samples in GC. Query, row extraction and read bridges remain reached hot paths.

The first profiler attempt interleaved Node's GC logging into an asynchronous
large TS JSON write at byte131072. It failed parsing; raw output is retained.
The diagnostic runner now requires stdout.setBlocking(true) before both programs;
that transport-only correction passes all nine full states on both roles. It
neither changes the measured phase nor establishes a cause for unrelated E11
five-second TS lifecycle timeouts. [Failed and corrected receipts/heap](final/index.json).

Fresh adjacent full65 timing is mixed: old-source final Motion JS300/TS246.954ms,
Health773/293.061ms. Retain the adverse Health observation. Source-frozen query
joined with eight unchanged backend recipes passes both schemas at266/209.680ms
and271/212.434ms, respectively; Native256/209.680 and282/212.434 remain far from
2x. Nine-world construction count5,236,800 in both schemas is separate from speed
acceptance. No old-source Tx/mutation acceptance transfers to this new source.
