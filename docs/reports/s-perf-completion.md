# S-PERF #20 — indexed storage evaluation

**Completed bounded negative implementation/evaluation under #20 clause7; final independent review supplements are recorded separately.** The implemented candidate passes the connected finite capability gates. Production adoption is rejected on current performance evidence: JavaScript parity fails, and Native does not consistently substantially outperform bevy-ts. This is an experimental ECS implementation, not completion of the full core.

## Delivered and verified

The [design](../design/s-perf-indexed-storage.md) freezes checked logical-ID access, ascending high-water membership, bounded capacity and genuinely affine Main/Aux columns. Main operations preserve the unrelated Aux owner. The [API](../design/s-perf-storage-api.md) returns owners explicitly; commands preflight the entire queue before FIFO application. Rank-2 declared providers, sequential dispatch, transactions, inverse rollback, barriers and registered readers use the candidate through an isolated [overlay](../../experiments/s-perf/README.md). No retained baseline or reference source is modified.

| Acceptance group | Outcome and evidence |
| --- | --- |
| Frozen baseline/design/independent design review | Passed: `baseline.json`, design/API and `s-perf-storage-design.md`; no new laws or production layout approval |
| Affine ownership/bounds/growth | Passed finite Native/JS points: clean replay 39 positive cases, three intended ownership negatives, three compiling wrong-slot/reversed-growth/lost-owner mutants detected; independent replay agrees |
| Connected behavior and captures | Passed complete E0–E10 trace, both schemas/two capture styles, ten channels/four lanes; exact SHA `0eb77b7656ad88ca6ca271a5d5de221307ab4545302733e8db1872259c3bdc32` |
| Lifecycle/reservations/foreign handles | Passed E11 originals on both backends and fresh TS; foreign handle returns MissingEntity without queue change; ten E11 compiling mutants detected on both backends |
| Access/semantic controls | Nine intended access controls and 12 compiling main mutants pass on both backends; Native mutation replay uses O0, separate from O3 measurements |
| Five workload measurements | Dense/Sparse/Lifecycle complete; Readers and quiet FailedTxn have explicit larger-case deadlines; cold-VM/timer resolution limits remain partial with #21 return conditions |
| Readers alignment | Passed preregistered descriptors and full diagnostics against unchanged reference; historical adapter costs remain separately labeled |
| Memory/retention | Corrected child RSS independently probed; actual TS diagnostics pass six cases and three counter mutants. Bend actual Readers diagnostics pass all six cases on Native/JS: 1196 checkpoints and84 running-delivery cross-checks per case/backend. Active Tx workload peaks remain unavailable with explicit hook follow-up |
| Independent reviews | Standards delivered; final supplement covers quiet source/evidence and closure; final Spec review covers bounded negative closure |

Sources and evidence are under [experiments/s-perf](../../experiments/s-perf/README.md). `main-evidence.json`, `e11-evidence.json`, `access-evidence.json`, `main-mutations-evidence.json` and `owned-storage-clean-replay-evidence.json` record actual executions and source hashes. Preliminary snapshots and failed attempts remain separate; a timeout is never counted as a mutation kill.

## Measurements and remaining gates

All comparisons use the frozen 64/256/1024 cases and authored callback sequence. Seven repetitions rotate Native/TS/JS. Dense/Sparse, Lifecycle and Readers use a fresh warmup world and a separate measured world in the same child. Quiet FailedTxn uses separate fresh warmup and measured children: this does not warm the measured JS/TS VM/JIT, so its ratios describe cold-VM fresh-child executions and do not establish warmed steady state. This is a partial timing-protocol gate. Timing includes authored observations; final diagnostic serialization remains outside. Ratios below are elapsed Bend/TS, so smaller is faster.

| Workload | Current result |
| --- | --- |
| Dense and Sparse | All 12 schema/workload/size cases validate; 252 samples. Native/TS median 0.1757–1.2806; JS/TS 3.4266–6.8753. Short Native intervals below 10ms are resolution limited |
| Lifecycle | All six cases validate, including 192 boundaries, 6112 historical stale observations and 64 reservations per case; 126 samples. Native/TS 0.458–0.915; JS/TS 2.139–2.685 |
| Readers | Current three complete sample sets: Motion64, Health64 and Health256 (63 samples). Motion256 Native and both 1024 Native/JS exceed the unchanged five-second whole-child protocol. No ratios inferred for failed prerequisites |
| FailedTxn | Guarded full diagnostics pass both schemas at64/256; larger cases fail deadlines. Guarded durations are not fair comparative ratios. Common full-field tuple/fold quiet gate passes all18 schema/size/backend combinations through17 primary passes plus one unchanged focused retry, preserving the earlier failure. Five complete cold-VM seven-rotation sets (105 samples): Native/TS0.7584–1.3232, JS/TS2.7666–3.8525. Motion1024 has six of seven JS five-second deadlines; Native/TS seven each pass, but no accepted comparative ratio is reported for that case. All126 repetition attempts are retained. Two compiling JS mutants are detected on both schemas: actual fourth payload field and failed-reader completion, four intended full-record counterexamples; no build/deadline failure is a kill |

Reader timing failures concern the warmup-plus-measured child protocol. Single-world diagnostic capability passes all six cases on both backends and is a separate observation. No deadline was increased; byte-identical retries and superseded results are preserved without claiming why variability changed.

Whole-process peak RSS uses the clean C exec-reset launcher. It is not component allocation accounting. The independent retained-parent probe records direct inherited floor 211744KiB versus fresh empty child 728KiB, Node 41444KiB and touched32MiB child 33476KiB. Physical log entries, holders, cursor lag, and pending/staged commands are separate metrics. Final unread zero does not establish zero retained entries. Finite transaction fixtures never stand in for unavailable workload transaction peaks.

## Decision and explicit follow-ups

**Do not adopt this layout as the production performance solution.** Keep the candidate as a connected correctness/measurement reference. Direct point access removes a source-supported list traversal; its contribution to total elapsed time is not independently isolated. Ascending queries still scan historical high-water/tombstones, and arbitrary Type destruction/root authority/allocator reuse remain outside this package.

The reviewed blocked follow-up [S-PERF-NEXT #21](../tickets/20-indexed-performance-follow-up.md) must preserve affine Type payloads and the complete connected observations while investigating occupied membership/query iteration and Native/JS observation/runtime costs. Return conditions: full five-workload semantic gates, valid seven-repetition comparable measurements at every requested size, documented timer resolution, and separately approved numerical product thresholds. All cases marked `resolutionLimited` remain a partial timing gate, including Dense/Sparse, Readers64 and Lifecycle64 Native samples: preregister a longer identical work/batch on Native, JS and TS, validate complete observations, then collect replacement seven-rotation samples whose resolution uncertainty is below the approved comparison margin. Keep current short-interval ratios as descriptive limited evidence; no replacement samples or numerical threshold are claimed here. No checksum-only replacement, new dependency, law or threshold is authorized by this report.

The quiet timing follow-up must build equivalent fresh warmup and measured worlds in the same child on every backend, preserve full tuple/effect equality and the five-second limit, and recollect seven rotations before claiming warmed comparative performance. Preserve current cold-VM samples and failures as a distinct protocol.

A diagnostics follow-up must expose actual active transaction staging/journal/mark peaks at workload boundaries where currently unavailable; connect owner-preserving hooks and detect lost/incorrect counters without changing callback output. Larger Readers/FailedTxn deadline cases require equivalent work inside the existing limits, or an explicitly reviewed repin shared by every backend. Simulation and copied Tower Defense integration remain behind existing capability/performance prerequisites; `/workspace/typescript/jev` is untouched.

Static `git diff --check a976667...HEAD` reports the unchanged inherited trailing space at host-observations.bend:8 in three frozen diagnostic copies. It is retained to preserve source hashes, not reported as a clean whitespace check. Python runner compilation and all55 quiet package hashes pass.

Verification environment: Bend2.0.34, Node24.20.0, ARM64 clang14, Native O3/one worker/GPU off for timing. Checker/runtime5s, codegen30s, clang120s. CPU affinity does not make the machine exclusive. Installed/source Bend version difference, exact reference pins, scoped checker repair and unchanged kernel/Base are recorded in the evidence. Finite execution and approved endpoint proofs do not establish universal runtime refinement.
