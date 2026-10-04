# S-PREP one-shot method diagnostics and shared batch proposal

This package belongs to #22, not replacement #21 samples. Source pin `56b72f6` and reference manifest are checked in `evidence.json`. `diagnose.py` pins CPU6, runs processes sequentially, enforces runtime/tool limits, checks reused unchanged artifacts against tracked historical hashes, runs fresh unchanged TS references, and invokes the existing full-field oracles. The machine is not exclusive. No profiler, dependency, layout change, optimization loop or seven-rotation cohort was introduced.

Command: `python3 experiments/s-prep/method/diagnose.py`. Bend version/guide, Node/clang, source/reference/artifact/output hashes, commands, exit status, wall time, first observed bytes and timing/fold markers are retained. Runtime deadline outputs cannot pass a field oracle. The first diagnostic used an unbounded Python validator after bounded runtime children; `first-unbounded-validator-evidence.json` preserves that method error and its limited positive controls. An alarm-based validator overran its cleanup boundary (5.36s/5.60s); alarm-validator-evidence.json preserves that method failure. The final diagnostic runs each full-field validator in a separate five-second process-group-limited child; validator timeout is a method failure, not an ECS mismatch or semantic pass. The second marker diagnostic rescanned the growing tuple on every chunk, introducing pipe backpressure; first-scan-overhead-evidence.json preserves those artificial deadlines. The final diagnostic scans complete marker lines incrementally and keeps bounded tails. Neither failed diagnostic authorizes an ECS timing claim; these are method repairs, not optimization iterations.

## What the phases establish

Readers `motion_finished/health_finished` take their end clock before emitting retained events, final drain/checkpoint and timing line. First output therefore follows initial creation/priming and the first 64-iteration loop, but it does not isolate those components. The warmup timing line marks completion of its output/drain; the second timing line completes the measured world. Actual observed marker times locate these boundaries. The corrected incremental-marker run observed Motion1024 warmup Native inner70ms, completion1.969s and JS inner253ms, completion4.193s, followed by whole-child deadlines. Those boundaries show substantial authored output/final work outside the inner loop. The final bounded-child replay observed Native inner87ms, completion3.154s and JS inner376ms, completion4.874s, again deadline5s. FailedTxn Native/TS runtime completed (inner781ms/756ms), but both full-field validator children reached5s; FailedTxn JS inner2559ms preceded its5s whole-child deadline. Aligned TS Readers runtime0.800s and full-field validator2.955s passed. Each version remains separate in its evidence file; no successful-subset ratios are reported. Post-first-byte time includes output realization/transport, final callbacks and possibly the second world's work. It is not a storage-only or serialization-only attribution. FailedTxn prints its common full-field fold before its end timestamp, then the complete tuple and counts: first fold bytes bound preceding setup/work/fold from above; the subsequent timing line reports the authored inner interval. Captured output timestamps include pipe scheduling; no subtraction is reported as an exact CPU phase cost.

Motion1024 Readers Native/JS deadlines and FailedTxn JS deadlines remain evidence. Successful Native/TS observations do not pass a failed backend's gate. In particular the expensive large Python full-field validator can itself exceed the bounded diagnostic phase; a frozen evaluator must resolve that cost with a lossless bounded verifier rather than a checksum substitute. Existing historical successful full oracle records remain separate.

## Exact longer common-batch proposal — NOT ACCEPTED

Proposed resolution allowance: **1.00%** from clock quantization alone, with a conservative **2ms** bound for two integer-ms endpoints. Proposed minimum single-bracket measured duration: **200ms**. This is a measurement uncertainty proposal, not Native/JS product acceptance or a keep threshold. Noise, timer monotonicity and uncertainty of ratios still require separate qualification and contract approval.

For each resolution-limited case below, propose the same number B of fresh measured worlds on Native/JS/TS, each running the unchanged 64-iteration fixture with actual provider/callback/barrier/read/Audit/effects and all fields. Prepare all owners/descriptors outside one enclosing clock bracket; execute their authored work sequentially inside it with the same observer forcing; retain every world's full ordered observations for validation and transport afterwards. One separate fresh warmup world precedes the batch in the same process. Namespace ownership must remain independent. Do not sum B separately quantized durations: that preserves relative endpoint uncertainty instead of resolving it. This batch requires a reviewed driver amendment, not a current runnable accepted protocol.

B = ceil(200/min historical Native milliseconds) is a **source-derived sizing proposal**, not evidence that future runs reach200ms. Historical minima are from the frozen seven-sample records; a faster candidate can require a new shared review rather than silently changing B.

| Case (both backends use same B as TS) | Historical Native minimum ms | Proposed B |
| --- | ---: | ---: |
| Motion Dense64 | 3 | 67 |
| Health Dense64 | 3 | 67 |
| Motion Sparse64 | 1 | 200 |
| Health Sparse64 | 1 | 200 |
| Motion Sparse256 | 5 | 40 |
| Health Sparse256 | 6 | 34 |
| Motion Readers64 | 7 | 29 |
| Health Readers64 | 5 | 40 |
| Motion Lifecycle64 | 7 | 29 |
| Health Lifecycle64 | 7 | 29 |

Historical files: `dense-sparse-evidence.json`, `indexed-readers-evidence.json`, `lifecycle-evidence.json`. Dense/Sparse64/256/1024 outside these rows retain their current cases unless newly resolution-limited. Readers256/1024 and FailedTxn1024 need their separate deadline repair; no reduced observations/size or backend-only deadline increase is proposed.

**Feasibility is blocked.** Even a linear extrapolation of historical JS inner maxima gives Motion Sparse64 200×38ms=7600ms, Health Sparse64 200×70ms=14000ms, Motion Readers64 29×319ms=9251ms. These are sizing warnings, not causal forecasts or measured batch outcomes. Setup, warmup, full output and validation add work. Therefore the above batch is not ready inside runtime5s. Lowest-cost next observation is one shared batch control only after explicit protocol review, retaining all lossless observations and five-second children. If it cannot fit, return an explicit common repin request with exact semantics, not a backend-specific timeout or observer removal. An alternative higher-resolution timer requires a shared reviewed observer/timer protocol; no new dependency or unilateral change is authorized here.

## Per-case feasibility ledger

Every proposed row is blocked pending a shared driver amendment and lossless full-field validation, with runtime5s unchanged. Historical JS inner maxima multiplied by B are: Motion Dense64 3015ms; Health Dense64 1943ms; Motion Sparse64 7600ms; Health Sparse64 14000ms; Motion Sparse256 3040ms; Health Sparse256 3400ms; Motion Readers64 9251ms; Health Readers64 3000ms; Motion Lifecycle64 1595ms; Health Lifecycle64 1276ms. Rows already exceeding5s even before setup/output are specifically infeasible by this conservative sizing screen. The other rows have only possible inner-work headroom; whole-child feasibility is unobserved, not passed. These products are historical sizing estimates, not replacement measurements. Compilation phase costs are not diagnosed here: existing artifacts match recorded codegen/build hashes, and no fresh phase-cost claim follows from their retained passing build records.

## One-hour future budget limit

A full matrix has 5 workloads×3 sizes×2 schemas×7 repetitions×3 backends = **630 measured children per cohort**, plus semantic gates, warmups, builds and decoding. Four noise cohorts alone mean 2520 measured children. Historical quiet FailedTxn126 attempts and decoding consumed roughly 20min according to the coordinator's evidence; this is external planning context, not a runtime result of this package. No full matrix repeated-search plan is feasible merely because a one-hour future budget was approved. Recommend accepting one explicit focus case and per-case metric packet, with unchanged full-matrix final #21 gates; metric aggregation/tradeoffs and keep semantics remain unaccepted. `diagnose.py` is the runnable protected method check; it is not an optimization evaluator or authority to create packets/session state.
