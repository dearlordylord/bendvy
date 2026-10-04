# T10 — comparable prototype measurements

[Issue #11](https://github.com/dearlordylord/bendvy/issues/11), [SPEC](../../docs/SPEC.md).

**Measurement report complete; performance capability fails.** The ordered-row
prototype cannot be adopted as scalable production storage. Sparse traversal and
structural churn regress materially on native and JS; no average or favorable
microkernel result removes those regressions. Numerical thresholds below are
proposals for review, not approved acceptance.

## Reproduce and measured work

```
BENDVY_CPU=11 python3 experiments/t10/run.py
BENDVY_CPU=11 python3 experiments/t10/controls.py
```

The harness uses actual T08 owned World/row/command/log operations, parameterized
at runtime, and fresh public bevy-ts systems/schedules. It covers dense/sparse
query sums, committed updates, remove/reinsert churn, immediate stream
reads and failed writes/restoration at 64/256/1024 entities. Sparse keeps every
eighth component; present values initially equal 1. Updates set 2..2001. Churn
removes/reinserts entity 0 and counts its removal, preserving final order/value; events publish/read one
value per round. Rollback writes each present value, reads its own new value and restores it on
failure; the attempted-write observation remains outside ECS rollback.
Every timed round starts a frame on both sides; event/lifecycle retention is not
silently disabled to speed up the candidate.

Before timing, every exact measured input runs on native, JS and TS and must have
identical member count, final value sum and accumulated reader/query/attempted-write/removal sum and ordered slot/value projection. Every
sample repeats that comparison. Rollback reads each attempted write before failure;
churn reads actual removal entries after the marker. Separate own-path controls
reject compiling identity replacements for each on native and JS; prior probe
results are not substituted for validation of this measured path. Zero-round controls compare setup observations
and measure the cost of final observation/system dispatch alone. The six workloads
have fixed declared effects, so these projections establish the intended results
on these inputs; they do not expose every intermediate failure or prove parity.
Detailed semantic boundaries/mutations are covered by T05–T08 separately.

Compilation/typechecking and construction/initial structural flush are outside the
reported work interval. Bend IO.now surrounds loops and the final projection;
TS performance.now surrounds loops and the final public observation system. Three
full fresh-world workload warmups precede each sample **inside the same process**;
five samples run in fixed-seed randomized backend order. Fresh processes between
samples prevent cumulative cursor/allocator state from changing workloads.
The reported zero-round cost is not subtracted from workload times.

The native path measures trusted prototype storage primitives, without the final
rank-2 System/provider boundary. TS includes public System/transaction/frame costs.
Data-row snapshot rollback here is different from T06 owned-array inverse journal;
this benchmark does not accept generic affine payload storage or measure it.
The event path is a minimal immediate stream microkernel, without production
reader-slot registration; it is not an end-to-end scheduling speedup claim.
All entity columns have one U32 projection. These are explicit comparison limits,
not permission to reduce the eventual core or drop affine components.

## Results

[results.json](results.json) contains all 18 cases, exact observations, five raw
samples each, ranges, zero-round controls, environment and peak RSS. Each case
executes 2000 rounds. Bend's clock resolution is 1 ms; sub-millisecond results
are unresolved, not zero-cost or infinite speedup. Small-case ratios are coarse.

Representative largest-size medians, milliseconds:

| Workload (1024 entities) | Native | Bend JS | bevy-ts | Native TS/time ratio | JS/time TS ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| Dense | 16 | 28 | 19.676 | 1.23x | 1.42x |
| Sparse (128 matches) | 20 | 26 | 4.672 | 0.23x | 5.57x |
| Update | 110 | 49 | 104.036 | 0.95x | 0.47x |
| Remove/reinsert | 294 | 195 | 15.431 | 0.05x | 12.64x |
| Events | <1 | 1 | 8.629 | unresolved microkernel | 0.12x microkernel |
| Rollback | 120 | 75 | 111.574 | 0.93x | 0.67x |

No aggregate speedup is used for acceptance. Shared-host load, five samples,
millisecond clock granularity and evolving prototype boundaries preclude robust
production inference. Ranges are published rather than hidden. Zero-round measurements
range 0–1 ms for Bend, up to 2.33 ms for TS; setup is excluded, but final
projection/dispatch and timer resolution contribute to small workloads.

Environment: Bend 2.0.34 / pinned Base, clang 14.0.6 -O3, Linux aarch64,
Node 24.20.0, CPU affinity 11, native --threads 1 --gpu off; JS single event loop.
Checker deadlines remain five seconds; code generation 30 seconds/clang 120
seconds. Benchmark processes are separately bounded at 15 seconds to allow setup,
three warmups and measured work; that is not a checker/proof limit change.

Peak RSS for update/1024/2000, including setup + three warmups + measurement:
Native 6756 KiB, Bend JS 120124 KiB, TS 137972 KiB. Linux wait4 ru_maxrss observes
the exact child lifetime, including the inherited Python launcher RSS before exec.
That floor may dominate native results; this is not native runtime-only memory. This includes VM/runtime
baseline, allocator retention, JIT and setup; it does not measure live component
bytes or isolate per-operation allocation. No new dependency was installed.
The first RSS stage found no /usr/bin/time; the dependency-free wait4 observer
completed it without a new dependency. After review strengthened the observable
work, all 18 timing cases and RSS were freshly measured on that revised path.

## Bounded redesign and proposed acceptance numbers

The observed sparse scan traverses absent rows; repeated remove/reinsert searches
and reconstructs ordered lists. Concrete alternatives to compare next:
owned indexed columns plus a slot/live map, ordered membership traversal, and
per-write inverse journals with independently retained lifecycle logs. Preserve
world handle checks, observable order, deferred flushes, both cursor kinds and
Type payload ownership. Do not adopt swap-remove order or Data-only components
as an unreviewed optimization. Compare a dense ordered scan and sparse membership
path under the same projections/inputs before choosing layout; re-test malformed
indices and capability/provider boundaries.

**Proposal only:** require at least 2x native throughput on each agreed
representative workload/size, and JS noninferiority with at most 10% timing
regression, using repeated measurements whose uncertainty is smaller than that
margin. 2x sets a concrete material benefit rather than accepting roughly 1.2x; the JS
margin distinguishes comparability from clock/JIT noise. These numbers need user
approval and better-resolution representative simulation/copy-integration gates.
They are not inferred as approved from choosing Bend or from this microbenchmark.
Do not average away a sparse/churn failure. If the user prefers strict <=1.00x JS
or a different native multiplier, record that decision before final acceptance.

Return conditions: bounded storage comparison and integrated abstract providers,
actual reversible Type payload measurements, larger scaling/high-resolution timing,
allocation instrumentation and representative simulation workloads. Full-core
relations/states/tooling remain required before copied Canonical Defense integration
in its used scope. Parent #1 remains open; this prototype fails performance and
requires redesign, rather than accepting weaker requirements.
