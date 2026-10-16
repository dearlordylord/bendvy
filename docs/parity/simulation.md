## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A reproducible console simulation spawns entities, moves them toward a goal, applies damage, removes them and reports hit/death events through the public ECS API.

## Acceptance criteria

- [x] Freeze inputs, seed, fixed-step/system order and complete reference checkpoints; implement actual spawn/move/damage/removal/hit/death work without a bypassing custom state loop.
- [x] Include failure/retry and explicit barriers, independent readers, affine payload cleanup and deterministic complete output on JS/Native/observed TS.
- [x] Run the unchanged regression gate and scoped equal-work timing evidence. Maintain explicit proof and full-performance prerequisite status; this demo does not establish full parity or qualified product speed.
- [x] Detect a reached omitted-hit/death or implicit-flush mutant and document running the application without internal provider knowledge.

## Blocked by

- #35
- #41

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current retained delivery — 2026-10-14

[Ordinary v7 evidence](../../experiments/public-simulation/delivery-v1/ordinary-evidence-v7/evidence-v7/README.md)
is integrated at `c003fcd91`: actual TS/JS/ordinary Native consumers, complete
two-schema fourteen-phase reports, and reached hit/death omission controls pass.
The 871-member portable verifier and independent final Spec/Standards review pass.
Original failed collectors remain INCOMPLETE; hit is separately validated from
retained output, while the corrected death successor completed its consumer.

The retained Workshop #28 gate is historical measured evidence. Independent
source review found a later World pending-length implementation delta; semantic
equivalence does not establish timing identity. This observer-only delivery
changes no production ECS hot path. Combined #28 and #21/#23/#24 qualification
remain required under their existing contracts; no fresh speed claim is made.

## Semantic acceptance reconciliation

The [current-source delivery](../../experiments/public-simulation/delivery-v1/current-source-v1/delivery-v1/README.md)
adds complete lifecycle and registration observations to the ordinary gameplay.
Stock JS and Native both match the independent 97,054-byte model across two
schemas and fourteen phases. A reached compiling changed-stamp omission produces
its independently derived 96,998-byte counter and rejects the normal expectation.
Existing actual TS, hit/death, failure/retry and authority controls remain qualified
through explicit source-applicability joins; original failed receipts stay labeled.

[Independent final review](../../experiments/public-simulation/delivery-v1/current-source-v1/delivery-v1/FINAL-REVIEW.md)
passes all four semantic criteria under the approved R7 policy. The portable
484-object packet passes offline and relocated verification with ten malformed
controls. These finite observations establish this application delivery, not
universal proofs, WorldIO coverage, private backing-array identity or full parity.
The private tuple-fusion timer candidate is not adopted or used to qualify speed.
