## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A scene-style lifetime scope owns a group of spawned entities and queues cleanup without deleting persistent entities.

## Acceptance criteria

- [x] Observe pinned scope membership, persistence, repeated cleanup and deferred visibility; a lifetime token is neither a component nor proof of liveness.
- [x] Run scoped spawn/cleanup across linked and unlinked entities, including references from persistent survivors, pending work, failed/retried systems and independently created worlds.
- [x] Verify relation/inverse cleanup, removal/despawn visibility and one-time affine disposal. Detect a reached persistent-entity deletion mutant and reject foreign scope/schema misuse.

## Blocked by

- #44

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Linked cleanup boundary

Rust Bevy queues state-scoped despawns (`bevy_state/src/state_scoped.rs:177`) and
despawns a parent’s linked descendants (`bevy_ecs/src/hierarchy.rs:50`, pinned
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`). The existing #44 cleanup follows
that boundary. An unscoped entity survives scope cleanup when it is outside the
linked deletion closure; an ordinary relation to a deleted target is cleared.
An unscoped linked descendant is still deleted. These are the survivor and
linked cases for the ordinary #45 consumer; affine cleanup uses the existing
#44 callback contract.

## Semantic acceptance reconciliation

The [integrated delivery review](../../experiments/public-scopes/delivery-v1/FINAL-REVIEW.md)
qualifies membership, repeated/deferred cleanup, linked descendants and ordinary
survivors, relation/inverse cleanup, removal/despawn visibility, failed/retried
registered systems, actual independent worlds, affine owner disposition and
scope/schema refusals. Its generated-JS-only mutation remains historical.
The [matched application review](../../experiments/public-scopes/feature-timing-delivery-v1/FINAL-REVIEW.md)
qualifies the actual TS/JS/Native reference comparison: all 52 records and 12,932
bytes. The four production lifetime-scope modules remain byte-identical to the
qualified delivery. Reached dependency changes and their applicability are
reviewed separately; the open #44 label does not leave a missing scope operation.

The [source-level survivor control](../../experiments/public-scopes/source-survivor-control-v1/delivery-v1/FINAL-REVIEW.md) passes stock JS and ordinary Native -O3:
normal 2,328 bytes (`f146322d…`), mutated 2,310 bytes (`c93a6c31…`). The sole Bend
change appends the unscoped survivor to cleanup membership; both backends reject
the normal oracle and match the independent countermodel. The original ordinary
consumer and complete observation are preserved. This supplement executes Scene
only; broader two-schema coverage belongs to the joined delivery, not this run.
The pure normal/mutant modules pass their pinned checks. Full IO entries retain
the expected foreign-effect proof limitation; actual runtime passes are separate.

Independent final Spec/Standards review confirms all three native semantic
criteria are satisfied by the joined evidence. Publication and CI remain pending.
This qualification changes no
production core. The existing #28 evidence remains scoped to its protected
workload; combined comparative performance remains under #21/#23/#24. Finite
observations do not establish universal refinement.
