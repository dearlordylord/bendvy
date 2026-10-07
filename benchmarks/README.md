# Performance regression gate

```sh
python3 benchmarks/test-statistics.py
python3 benchmarks/run.py --output .artifacts/regression-$(date +%s) --cpu 0
```

Uses the existing Bend/Node/private Clang19 installation; no new dependencies.
Choose a CPU allowed by the host (`--cpu` defaults to the lowest allowed CPU).
Output must be a fresh directory. The receipt contains full inputs, source and
artifact hashes, environment versions, command limits, all pair measurements and
the decision. Every warmup/timed output is retained losslessly as gzip.

Baseline `327bec49` is compiled again on the same machine as current `src/ecs`.
Both execute the baseline's frozen Workshop workload: ten complete applications,
22 TS-equal checkpoints each, including rollback, retry, filters and structural
churn. Every full JSON observation is checked; reduced work cannot pass by
keeping a checksum. The foreign-world divergence is excluded identically.

Twenty adjacent pairs/backend have balanced randomized baseline/current order.
The exact one-sided paired sign test detects a median paired slowdown against
zero allowance; Holm controls family false-positive probability at0.05 across
the two backends. Ties carry no evidence. All samples/outliers remain. This is
the user's approved **no statistically confirmed slowdown** policy, not a5%
performance tolerance. `NO_CONFIRMED_REGRESSION` exits0; `REGRESSION` exits1;
invalid observations, failed builds/timeouts and source drift also fail.
No detected slowdown does not prove equivalence, especially with small effects
or a noisy host. Inspect the paired ratios and complete receipt.

```sh
# Harness-only detection control: same outputs, real extra candidate delay.
python3 benchmarks/run.py --output .artifacts/slowdown-control-$(date +%s) --cpu 0 --inject-slowdown-ms 30
# Expected exit1 and REGRESSION for both backends.
```

This measures whole-process time, including startup/output; it protects this
specific public-API workload, not a qualified hot-path floor or the separate
optimized five-workload/three-size matrix. Same-cohort candidate/TS ratios are
descriptive, separate from baseline regression and eventual product acceptance.
Compiler/runtime changes affect both newly built roles; this primarily guards
project-source regressions. Statistical inference still assumes a reasonably
stable host; randomized close pairs reduce drift, not eliminate every confound.

To change the baseline or workload, explicitly review/edit `contract.json` and
rerun both controls. Do not update it automatically after a failed benchmark.
Checker/runtime limits5, emission30, Native compilation120 remain unchanged.

## Reviewed provider variants

For #30, the same frozen baseline application can use an explicitly reviewed
candidate schema/declarations adapter:

```sh
python3 benchmarks/run.py --output .artifacts/optimized-provider-$(date +%s) --candidate-provider experiments/public-optimized-compose/workshop
```

Use `--candidate-declarations owned-declarations.bend` for the reviewed owned-row
adapter. Only candidate schema and selected declarations are replaced; the optional
listed `owned-rows.bend` and `reference-declarations.bend` helpers are copied and
hashed. Core import paths are rebased. Unknown Bend imports are rejected; exact
local gameplay/observe imports resolve to archived workload files.
The archived gameplay, driver, inputs, reference, complete expected observations,
ten applications per process and statistical contract remain unchanged. Inputs
and staged adapter hashes are retained and checked. This additional comparison
measures the prepared route against the original ordinary baseline; it does not
replace the default current-source gate. Do not supply an unreviewed adapter or
claim equal work from equal observations alone; review every provider diff and
retain actual gameplay/route controls. The baseline is never advanced by this mode.
