# Execution limits

Current defaults for new runs. The user authorized raising execution limits when
useful on 2026-10-18; record each change here before launching its successor.
Timeouts control resource use; they are not performance targets.

| Stage | Current limit | Scope |
| --- | ---: | --- |
| Bend source/proof check | 15 s | Current default; may increase with a recorded reason |
| Bend code generation | 60 s | Shared default for new JS and Native emission; Readers Native completion confirmed |
| Native compilation | 120 s | Ordinary Clang `-O3` |
| Ordinary consumer | 180 s | Shared limit; Health1024 completion confirmed below |
| Instrumented runtime diagnostic | 15 s | Existing allocation/CPU diagnostic plans |
| Offline profile processing | 30 s | Existing full-log processing successor |
| Heavy executions | 1 at a time | Shared queue; account for external CPU contention |

Keep frozen plans and failed receipts unchanged. A changed limit gets a new plan;
it does not turn an old timeout into a pass. For equivalent-work comparisons,
use the same limit on TS, JS and Native. Measure actual child execution separately
from compilation, guard hashing and queue wait. Select a practical rounded limit
with headroom from complete, oracle-checked runs rather than optimizing to an
arbitrary timeout. Record contention and uncertain measurements.

Proof verdicts, ownership/correctness checks, comparison protocols and product
targets remain unchanged: JS <= TS and Native <= 0.5 * TS. More time does not
approve a law, prove a foreign function or establish a speedup.

## Earlier Motion boundary

Manual-schedule Motion1024 IO-pieces candidate, four fresh processes per backend,
with warmup, execution and the
complete 444,624,902-byte output. All eight runs match the independent oracle. Retained plans, receipts, outputs
and the portable verifier are in the [boundary packet](../experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/runtime-v1/motion1024/runtime-boundary-attempt01/RETENTION.json)
(integrated at `93f55b13a`; independent final review and portable verification pass).

| Backend | Observed range |
| --- | ---: |
| JS | 13.78–18.01 s |
| Native | 13.60–15.44 s |

The earlier 30 s limit leaves about 12 s above this Motion observation. This empirical
range is not a worst-case guarantee or an ECS/bevy-ts speed comparison. External
CPU contention was reported; the initial pair briefly overlapped CPU0 preparation.

## Ordinary Health completion boundary

Same chunked Health1024 artifacts, one fresh child per backend, full warmup,
execution and 444,047,554-byte oracle-checked output; common 180 s limit.

| Backend | Child wall time |
| --- | ---: |
| JS | 29.00 s |
| Native | 83.28 s |

The limit leaves about 97 s above this observed maximum. One pair is not a
worst-case bound or comparative ECS qualification. Child metrics exclude build,
guard hashing and queue wait. Host contention was disclosed. Earlier 30/60 s
failures retain their original verdicts.

## Change history

| Recorded UTC | Stage / workload | Previous → new | Reason and evidence |
| --- | --- | --- | --- |
| 2026-10-18 | Baseline recorded | 5 / 30 / 120 s | Inherited checker / emission / Native build limits. Existing offline analysis already uses 30 s; see `81ef9a5b` and the delivery report. This records existing state, not a new raise. |
| 2026-10-18 04:58 | Ordinary consumer; FailedTxn1024 boundary trial | 5 → 15 s | User requested a useful boundary instead of continued optimization to 5 s. IO-pieces plans `867c9c94` / `beb72620` timed out with JS 0 bytes and an exact Native 49,319,936-byte oracle prefix. Trial reuses the same artifacts and full 444,624,902-byte oracle; both trials reached 15 s without completion; no completed child time was recorded. |
| 2026-10-18 05:03 | Bend development check | 5 → 15 s | The ordinary-App Scenario check passed in 2.8 s, then a repeat hit 5 s with no diagnostic; Program passed in 4.2 s. Add headroom for current source and CPU contention instead of reshaping correct code around this timeout. `scripts/bend-check` now uses 15 s; its CPU locks are preserved. |
| 2026-10-18 05:11 | FailedTxn1024 consumer boundary trial | 15 → 30 s | Both 15 s trials timed out: JS produced an exact 222,312,450-byte prefix, Native 300,023,808 bytes, against the same 444,624,902-byte oracle. Neither completed. The same artifacts complete in all eight 30 s runs. Confirmed at 05:20 UTC: JS 13.78–18.01 s, Native 13.60–15.44 s. Earlier policy bytes and failures are retained. |
| 2026-10-18 05:55 | Ordinary consumer; Health1024 successor | 30 → 60 s | Ordinary Health1024 JS passed the full 444,047,554-byte oracle at 30 s; Native plan `9edb4959` reached its child deadline with zero stdout and empty stderr. The cause is not established. Preserve that failure. New JS/Native successor plans share a 60 s cap and the full independent oracle; source repairs require fresh qualified artifacts. The owner subsequently found that the migration aggregates the final owner report into one String instead of the original chunks; a narrow restoration is being checked, without claiming the timeout cause is proved. No old-artifact 60 s trial was launched. This is a completion budget, not a speed claim. |
| 2026-10-18 06:09 | Ordinary consumer; chunked Health1024 completion trial | 60 → 180 s | Restored-stream Native plan `59e0d8dd` reached its 60 s child deadline after an exact 222,023,680-byte prefix of the 444,047,554-byte independent oracle; stderr was empty. Five other new-source cases completed. Preserve the incomplete run. A common 180 s JS/Native successor reuses the same qualified artifacts and full oracle, with the already-reviewed child wall/CPU/peak-RSS wrapper. The larger step provides completion headroom without assuming that output fraction predicts runtime. No source change, cause attribution or performance qualification is implied. Confirmed: one full pair completed (JS 29.00 s, Native 83.28 s), leaving about 97 s headroom. |
| 2026-10-18 06:51 | Bend code generation; ordinary Readers Motion64 Native | 30 → 60 s | Native plan `9189ee91` stopped at its emission child deadline, with zero stdout, empty stderr and unchanged guards; build and runtime were not reached. JS from the identical source already matches all 10,810,200 independent oracle bytes. Preserve actual01 unchanged. New emission plans use the shared 60 s budget; a Native successor keeps source `f44a2fc50` and the exact full oracle. Reuse the qualified JS artifact/result rather than recompiling it solely for a larger timeout. This is a correctness completion trial, not a comparative timing cohort or evidence of the timeout cause. Confirmed: successor `acfc11e0` emitted a 13,536,096-byte C artifact, passed ordinary Clang `-O3` and matched all 10,810,200 oracle bytes with empty stderr; source unchanged. No stage-duration measurement was retained. |
