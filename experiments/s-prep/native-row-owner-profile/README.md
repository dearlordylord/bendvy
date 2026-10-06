# Row-owner Native phase profile (diagnostic only)

Both actual row-owner Motion and Health pass all65 complete fresh pinned TS world
observations and exact START/END markers before GNU gprof output is accepted.
The unchanged root native-phase-gprof/run.py uses CPU11, private approved Clang19
O3/pg compilation120s, runtime5s, threads1/GPUoff and existing GNU gprof2.40.
Only copied generated C receives phase instrumentation; original C hashes remain
unchanged. Profiling is active between original clocks3/4. Receipts pin original
C, reference, recipe, derived C, binary and exact commands. No source/kernel,
compiler, dependency or reference edit was made.

Sparse histogram ticks (one tick0.01s) identify broad candidates for investigation:

| Category | Baseline Motion | Row Motion | Baseline Health | Row Health |
| --- | ---: | ---: | ---: | ---: |
| all sampled ticks |39|49|37|43|
| term_drop |10|13|11|8|
| Held row entry |6|9|9|5|
| rfc_wrap |4|7|4|5|
| dispatcher visit closure |3|6|1|6|
| measurement rows entry |2|3|4|6|

These are separate instrumented runs on CPU7 baseline/CPU11 candidate. Sampling
is sparse, wrapper/inlining placement changes and -pg perturbs execution. Totals,
percentages, call accounting and elapsed values are not comparative speed or
causal evidence. Residual ownership/drop, Held callbacks and dispatcher paths
remain useful source investigation seams. Pre-main instrumentation can leave
startup records (_init), as documented by the root recipe. This profile neither
supersedes exact allocation counters nor establishes performance qualification.
All source-specific semantic/authority/negative/full22 gates remain separate.

All raw field observations, original receipts, phase stderr, generated diagnostic
C, gmon data and profiles are deterministic gzip archives in evidence/index.json;
decoded and compressed hashes are verified. Root baseline receipts are archived
as prior-task comparison evidence, not this task acceptance.

Reproduce with the unchanged root runner:

```sh
python3 experiments/s-prep/native-phase-gprof/run.py --source /tmp/bendvy-row-owner-split-motion-build/batch.c --reference /tmp/bendvy-frozen-chain-motion-comparison/reference.mjs --schema Motion --cpu 11 --output /tmp/fresh-row-motion-profile
python3 experiments/s-prep/native-phase-gprof/run.py --source /tmp/bendvy-row-owner-split-health-build/batch.c --reference /tmp/bendvy-frozen-chain-health-comparison/reference.mjs --schema Health --cpu 11 --output /tmp/fresh-row-health-profile
```
