## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An application reuses typed heterogeneous captured systems across nested schedules with safe registration, disposal and refusal.

## Acceptance criteria

- [x] Compose independently authored instances with different affine capture types, resources and conditions; do not require a fixed closed dispatcher enumeration or copying single-use closures.
- [x] Validate registration identity, duplicate rules and requirements before work. Preserve capture owners on skip/refusal and the approved per-instance failure contract on retry.
- [x] Execute repeated runs, disposal/re-registration and foreign-world refusal with complete captures/world/queue observations; detect a reached instance mix-up/lost-owner mutant.

## Blocked by

- #50
- #34
- #35

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current implementation and evidence

`captured-schedule-composition` derives routing and identity catalogs from typed
owner products; applications compose independently authored owners without a
fixed dispatcher enum. Resource and query leaf adapters retain their actual
captures. `captured-schedule` validates exact live registrations, duplicates,
canonical steps and requirements before any phase, condition, callback or barrier.
Nested plans reuse the existing #34 flatten/requirement rules.

`captured-schedule-condition` retains ordinary #35 condition owners alongside
system owners. Condition registrations are checked separately and never enter
the executable system catalog. Actual stateful `StateChanged` revisions and
Registry cursors are independent of captured query cursors. Condition false
preserves system owners; condition and body errors retain their existing distinct
journal prefixes. The default `NoBinding` mapping is source-reviewed; that exact
constructor is not an executed case in the new consumer. Existing #35 evidence
qualifies mixed conditional/unconditional public behavior.

Current complete independent observations on stock JS and Native:

| Consumer | Full output | Checked behavior |
| --- | --- | --- |
| [Ordinary composition](../../experiments/public-captured-schedules/ordinary-v1/README.md) | 6,161 bytes | Different query Pack/resource Array types, nested order, repeat, skip, failure/retry and foreign refusal. |
| [Admission](../../experiments/public-captured-schedules/ordinary-v1/admission-v1/README.md) | 15,793 bytes | Genuine foreign collisions, stale owner, invalid nested plans and missing requirements before work; deferred Counter+37 survives and is drained. |
| [Lifecycle](../../experiments/public-captured-schedules/ordinary-v1/lifecycle-v1/README.md) | 4,217 bytes | Actual unregister returns heterogeneous packs, re-registration uses those values and new IDs, and a rebuilt plan runs again. |
| [Ordinary stateful conditions](../../experiments/public-captured-schedules/ordinary-v1/conditions-v1/README.md) | 13,895 bytes | Actual machine state/stream, condition revisions and Registry cursor, distinct captured owners, false skip and body failure/retry. |
| [Condition preflight](../../experiments/public-captured-schedules/ordinary-v1/conditions-v1/preflight-v1/README.md) | 16,957 bytes | Missing state is false; missing need preserves cursors; condition IDs are not executable systems; stale condition refuses before the prefix. |
| [Reached routing defect](../../experiments/public-captured-schedules/ordinary-v1/routing-mutant-v1/runtime-v1/README.md) | 5,831 bytes | Negated membership selects the wrong typed leaf; its unchanged guard refuses. Both backends reject the complete normal trace. |

The [actual TS comparison](../../experiments/public-captured-schedules/ordinary-v1/reference-delivery-v1/README.md)
retains all 7,079 independent oracle bytes for shared heterogeneous nested
execution. Tick/phase/API differences remain explicit; TS supplies no unregister
comparison. Finite traces do not prove universal refinement or host-IO rollback.
Protected #28 evidence is reusable through the unchanged 23-source workload;
combined full-feature performance stays under #21/#23/#24.

[Independent joined Spec/Standards review](../../experiments/public-captured-schedules/ordinary-v1/FINAL-REVIEW.md)
accepts the stated #51 semantic criteria. Composition owner duplication and
cross-schema checks reject at the actual new entry; unchanged grant-confinement
evidence is source-bound in authority-v1. Integrated at `1bcf107fa`; CI38859172838 passed. The
[English acceptance report](https://github.com/dearlordylord/bendvy/issues/51#issuecomment-6209257212)
was posted before closing #51.
