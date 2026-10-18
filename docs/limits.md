# Execution limits

Current defaults for new runs. The user authorized raising execution limits when
useful on 2026-10-18; record each change here before launching its successor.
Timeouts control resource use; they are not performance targets.

| Stage | Current limit | Scope |
| --- | ---: | --- |
| Bend source/proof check | 15 s | Current default; may increase with a recorded reason |
| Bend code generation | 30 s | JS and Native emission |
| Native compilation | 120 s | Ordinary Clang `-O3` |
| Ordinary consumer | 30 s | Provisional shared limit; boundary experiment below |
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

## Change history

| Recorded UTC | Stage / workload | Previous → new | Reason and evidence |
| --- | --- | --- | --- |
| 2026-10-18 | Baseline recorded | 5 / 30 / 120 s | Inherited checker / emission / Native build limits. Existing offline analysis already uses 30 s; see `81ef9a5b` and the delivery report. This records existing state, not a new raise. |
| 2026-10-18 04:58 | Ordinary consumer; FailedTxn1024 boundary trial | 5 → 15 s | User requested a useful boundary instead of continued optimization to 5 s. IO-pieces plans `867c9c94` / `beb72620` timed out with JS0 bytes and an exact Native49,319,936-byte oracle prefix. Trial reuses the same artifacts and full444,624,902-byte oracle; both trials reached 15 s without completion; no completed child time was recorded. |
| 2026-10-18 05:03 | Bend development check | 5 → 15 s | The ordinary-App Scenario check passed in 2.8 s, then a repeat hit 5 s with no diagnostic; Program passed in 4.2 s. Add headroom for current source and CPU contention instead of reshaping correct code around this timeout. `scripts/bend-check` now uses 15 s; its CPU locks are preserved. |
| 2026-10-18 05:11 | FailedTxn1024 consumer boundary trial | 15 → 30 s | Both 15 s trials timed out: JS produced an exact222,312,450-byte prefix, Native300,023,808 bytes, against the same444,624,902-byte oracle. Neither completed. Reuse the same artifacts with a shared30 s limit; earlier policy bytes and failures are retained. |
