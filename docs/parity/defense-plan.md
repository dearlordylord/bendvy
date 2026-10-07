## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A concrete integration plan identifies the exact ECS contracts needed by a separate copy of Canonical Tower Defense without modifying its original repository.

## Acceptance criteria

- [ ] Read the canonical application/reducer and record required fixed-step behavior, order, links, cleanup, host/input/render seams and authoritative outputs. Inspect only; do not modify canonical jev.
- [ ] Map every required capability to executable source-current evidence or a blocking ticket. Preserve the authoritative reducer; reducer migration requires a separate explicit decision.
- [ ] Produce a concrete isolated-copy destination, trace/equivalence plan and execution prerequisites including required proof/performance qualification. Publish actual copy/integration tickets only when those requirements are known.
- [ ] This planning deliverable neither installs dependencies nor changes external repositories nor claims integration complete. Missing platform adapters remain visible separate tasks.

## Blocked by

- #63
- #61

## Delivery and evidence

- Use the pinned bevy-ts behavior as the executable comparator, Rust Bevy ECS source as the architecture reference, and Bend guide/compiler/Base as the type, affine ownership and runtime authority. Record exact reference commits. Observe upstream behavior rather than inventing parity from source descriptions; approved divergences stay explicit.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.
