# P-REGRESSION #28 — completion

**Complete for the approved regression-benchmark scope.** The user selected no
statistically confirmed slowdown. The gate compares a fixed source baseline
`327bec49` against current `src/ecs`, compiled on the same host/toolchain with the
same frozen Workshop workload. The baseline is committed and never auto-updated.

[Runner and contract](../../benchmarks/README.md) execute 20 adjacent pairs per
backend, balanced randomized order, two warmup rounds and complete validation of
ten 22-checkpoint applications per process. All timings/outliers and lossless
outputs remain. One-sided exact paired sign tests use zero slowdown allowance
and Holm correction at family alpha0.05. This is confidence, not a5% tolerance.
Confirmed regression exits1; invalid output, timeout, source/reference/artifact
drift or failed build also fails. No confirmed regression does not prove equality.

## Actual results

| Cohort | JS | Native | Exit |
|---|---|---|---|
| Current vs baseline | p0.057659, paired median ratio1.015879 | p0.942341, ratio0.987363 | 0: no confirmed regression |
| Harness-only30ms delay | 20/20 slower, p0.000000954 | 20/20 slower, p0.000000954 | 1: regression detected |

Each cohort preserves 110 validated process outputs: 24,200 complete checkpoints.
The delay control keeps observations unchanged and adds real process latency;
its Python launcher also adds startup overhead. It changes no project ECS code.
Four decision tests cover significant slowdown, improvement/noise/ties, Holm
correction and invalid/missing timings. [Independent review](../reviews/performance-regression.md)
recomputes decisions and verifies every retained output and source/artifact pin.

Evidence: [current](../../benchmarks/evidence/current/receipt.json),
[detected slowdown](../../benchmarks/evidence/slowdown-control/receipt.json).
Python3.11.2, Bend2.0.35, Node24.20.0, approved private Clang19.1.7, aarch64 CPU0.
Checker/runtime limits5, emission30, Native compilation120; no dependency or
compiler/kernel changes. The initial pre-measurement archive-extraction error
was corrected for the installed Python API; the admitted cohorts are complete.

This protects whole-process Workshop/public API cost, including startup/output.
It does not qualify the separate optimized Dense/matrix workload or product
hot-path performance. Candidate/TS ratios0.429627(JS),0.073129(Native) are
descriptive and separate from the regression decision. Existing #21/#24 remain
open. AGENTS now requires this gate before delivering executable src/ecs changes.
