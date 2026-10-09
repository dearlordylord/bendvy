## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A developer subscribes to ordered execution observations and unsubscribes/resets them without interfering with ECS execution.

## Acceptance criteria

- [ ] Observe pinned observe/unsubscribe/reset behavior and complete success/skip/failure/barrier/relation/transition-handler trace formats; document normalization of nondeterministic fields only.
- [ ] Run subscriber lifecycle and reset during repeated schedules. No retention participation, reader advancement or owner mutation; disabled debug performs no trace publication work.
- [ ] Detect reached missing-failure/order/disposal mutants; retain description/dump consumers and record enabled/disabled timing and sampled allocation separately.

## Blocked by

- #56

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Source preparation and reusable evidence (2026-10-09)

Scope is optional ordered execution observation with unsubscribe/reset and no
ECS mutation, reader advancement or retention participation. [SPEC](../SPEC.md)
places host IO outside ECS rollback. Subscriber identity, mutation during
callback delivery, callback errors, captured affine state disposal and replay
ownership are not decided by the current ticket; no new contract is adopted here.

Reference order matters: pinned Rust Bevy `ad678262` uses feature-gated tracing
in `crates/bevy_ecs/src/schedule/executor/single_threaded.rs` at condition checks,
system execution and `apply_deferred`. This supports observing actual boundaries,
not copying a JavaScript callback registry. Pinned Bend source `a950fd68` and
installed 2.0.35 guide distinguish reusable top-level definitions from affine
closures, copied Data observations from Type owners, and pure execution from IO.
A repeated JS listener with captured mutable state therefore needs an explicit
Bend ownership/IO design. Pinned bevy-ts `3040a3b2` is the third-priority inventory:
`Runtime.ts:723` uses a callback Set; `Runtime.ts:1983` exposes observe/stop.
Its identity deduplication and exception/reentrancy behavior are not approved
Bend contracts. See [source pins](../../.references/sources.json).

| Existing source seam | Remaining observation gap |
| --- | --- |
| [schedule.bend](../../src/ecs/schedule.bend), `conditioned`/`conditioned_skip`, `after_outcome`, `execute`/`execute_skip` | Real skip, dispatch result and barrier order exist. `Ran` currently covers both success and failure; it cannot alone supply failure outcome/error observations. |
| [system.bend](../../src/ecs/system.bend), `run_checked`, `cursor_outcome`, `tracked_outcome` | Observe actual success/failure/refusal without rerunning a body or advancing its cursor. |
| [compose.bend](../../src/ecs/compose.bend), `finished`/`finish_returned`; [transaction.bend](../../src/ecs/transaction.bend) | Attempted writes/publications differ from committed changes. Capture required detached information before rollback discards it; do not treat host logs as ECS commits. |
| [world.bend](../../src/ecs/world.bend), `barrier`; [relation-commands.bend](../../src/ecs/relation-commands.bend), `publish_relate` | Observe deferred application and relation failure at their actual operation boundaries; debug must not become a relation-failure reader. |
| [machine-handlers.bend](../../src/ecs/machine-handlers.bend), `run_phase`, `entry_outcome`, `after_exit`/`after_transition`/`after_enter`; [machine-handler-bundle.bend](../../src/ecs/machine-handler-bundle.bend), `partitioned_run`/`finished` | Retain real handler order and requeue versus committed-enter-failure outcomes. No whole-marker rollback or synthetic transition universe. |

Reuse the already executed TS development comparators, without rerunning them
for preparation: [subscriber lifecycle](../../experiments/public-debug-trace/lifecycle-reference-v1/RESULT.md)
and its [receipt](../../experiments/public-debug-trace/lifecycle-reference-v1/evidence/receipt.json)
cover six phases; reset clears a collector journal, **not a Debug reset method**.
[Runtime success/failure](../../experiments/public-debug-trace/runtime-reference-v1/RESULT.md)
and [receipt](../../experiments/public-debug-trace/runtime-reference-v1/evidence/receipt.json)
include complete cumulative journals and world dumps.
[Skip/defect/recovery](../../experiments/public-debug-trace/skip-defect-reference-v1/RESULT.md)
and [receipt](../../experiments/public-debug-trace/skip-defect-reference-v1/evidence/receipt.json)
cover the corrected five-phase oracle; the original failed allocator prediction
remains retained. TS emits no schedule.end for that thrown defect. Only finite
elapsed ms is normalized. These are historical nonportable development evidence,
not approved Bend defect policy, source-current Bend/Native qualification or full
#57 acceptance. Relation/transition traces, subscriber mutation/errors, ownership,
reached mutants, disabled-path nonexecution and timing/allocation remain open.
