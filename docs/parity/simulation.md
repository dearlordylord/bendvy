## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A reproducible console simulation spawns entities, moves them toward a goal, applies damage, removes them and reports hit/death events through the public ECS API.

## Acceptance criteria

- [ ] Freeze inputs, seed, fixed-step/system order and complete reference checkpoints; implement actual spawn/move/damage/removal/hit/death work without a bypassing custom state loop.
- [ ] Include failure/retry and explicit barriers, independent readers, affine payload cleanup and deterministic complete output on JS/Native/observed TS.
- [ ] Run the unchanged regression gate and scoped equal-work timing evidence. Maintain explicit proof and full-performance prerequisite status; this demo does not establish full parity or qualified product speed.
- [ ] Detect a reached omitted-hit/death or implicit-flush mutant and document running the application without internal provider knowledge.

## Blocked by

- #35
- #41

## Delivery and evidence

- Follow the [reference roles](../SPEC.md#implementation-decisions): Rust Bevy for ECS architecture and semantics, bevy-ts for feature scope and porting inspiration, and Bend guide/compiler/Base for types, affine ownership and runtime. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.
