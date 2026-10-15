## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Applications attach typed exit/transition/enter schedules and retry failed transitions without undoing already committed work.

## Acceptance criteria

- [x] Observe pinned handler ordering, requirement unions and machine definition order. Exit/transition failure keeps the original state and requeues the transition; earlier successful handler effects remain committed.
- [x] Enter failure occurs after state commit and transition-event publication; it must not restore the old state. Changes queued by handlers are processed only at a later marker.
- [x] Run each failure/retry position with resources, affine components, Local, events, readers and pending structural work; preserve per-system rollback rather than whole-marker rollback.
- [x] Detect reached whole-marker rollback, premature publication and lost-retry mutants. Validate requirements before handler execution.

## Blocked by

- #48
- #35

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current-source component-write acceptance

The First-Transition failure/retry consumer now uses current canonical sources.
Its observer uses `machine-stream.snapshot`; exhaustive Initial/InitialEnter
branches are added but not reached by this pending-transition scenario. The
operations and complete observation remain unchanged. Actual `Component.tx_set`
writes, rollback, stamps, registry cursors, Local, pending work and successful
prefix effects remain visible.

JS and Native both match the historical independently reproduced 24,422-byte
oracle (`dfa63c0ed3b258d70c6622b4befd51a6ed1f1b319e718cf96f68b080fc2ff66d`).
All 29 source bodies match root adoption; the pinned source check passes.
The [retained packet and independent final review](../../experiments/public-machines/ordinary-heterogeneous-handlers-v1/failure-v1/component-write-v1/current-source-v1/delivery-v1/FINAL-REVIEW.md)
pass. Historical phase/pending mutants are not relabeled as component-undo
mutation tests.

## Semantic acceptance reconciliation

**Semantic acceptance complete.** The [source bridge](../../experiments/public-machines/ordinary-heterogeneous-handlers-v1/failure-v1/component-write-v1/current-source-v1/REUSE.json)
binds all six historical JS/Native failure/retry positions, the required
lost-retry/premature-publication/whole-marker-rewind mutations, requirement checks
before execution, and the executed shared TS reference. All 13 checked reached
handler/bundle bodies remain unchanged; additive Initial branches are unreachable
in the pending-transition fixtures. Current-source execution qualifies the
updated snapshot observer. Existing authority controls retain their stated scope.
Independent review found no remaining semantic checklist gap. The two-role
packet alone is bounded; the joined evidence supplies full issue acceptance.
Combined timing/scaling and final performance targets remain under #21/#23/#24.
