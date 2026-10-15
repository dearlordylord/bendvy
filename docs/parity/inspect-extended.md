## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Read-only inspectors observe hierarchy, machine states, transition events and relation failures without affecting schedules or readers.

## Acceptance criteria

- [ ] Inventory and execute all newly enabled pinned inspector categories through public projections and condition checks where permitted.
- [ ] Compare complete graph/machine/stream observations before and after repeated inspection; no cursor or retention change, mutable escape or implicit barrier is permitted.
- [ ] Test undeclared machine/relation reads, schema misuse and reached stream-consumption/order mutations; preserve baseline inspector consumers.

## Blocked by

- #54
- #44
- #49
- #43

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current machine qualification

The [current ordinary machine slice](../../experiments/public-inspect/graph-stream-public-bridge-v1/ordinary-machine-stream-v1/FINAL-REVIEW.md) passes its complete two-schema 20,671-byte JS/Native oracle through `MD.declared`, `inspect` and registered `condition`/`required`, with fresh cross-schema, cross-token and Inspector-versus-Check refusals. Historical stream Inspector evidence is reused only for unchanged consuming bodies: 33 of 34 core modules match, and the drifted machine declaration functions are not called by those consumers. Historical tools/execution remain historical; no stream Check grant, new stream execution, performance or full #55 acceptance is claimed.

The [actual pinned TS addendum](../../experiments/public-inspect/graph-stream-public-bridge-v1/ordinary-machine-stream-v1/ts-shared-v1/FINAL-REVIEW.md) passes the full 13,834-byte oracle for public machine transitions, a real hierarchy-cycle failure, repeated Inspector reads and a separately registered operational reader. TS’s second selected-stream inspection is empty after its own cursor advances; Bend retains full-log projections. Different fixture ages, clocks and failure counts are explicit; this is shared logical-subset coverage, not identical physical execution or feature performance.

## Acceptance reconciliation after missing-machine qualification

The pinned `InspectorAccessInput` admits queries, resources, events, services, machines, transition events, removed, despawned and relation failures. Pinned `CheckAccessInput` admits only stateless read-only queries, resources and machines; events, transition events, removals, failures, services and change-filter queries are intentionally excluded. Relation selections are query clauses, not a separate stream Check grant. The inventory is a boundary on this task, not permission to add new reader or ownership policies.

| Public category / permitted Check | Current implementation and qualified evidence | Remaining owning scope |
| --- | --- | --- |
| Relation/hierarchy query clauses; Inspector and stateless Check | `ordinary-inspector-relation` delegates to Inspector/Check relation projections. [All sixteen Link/Parent categories](../../experiments/public-inspect/graph-stream-public-bridge-v1/ordinary-category-v1/FINAL-REVIEW.md) retain complete two-schema JS/Native observations, three frontend refusals, reached routing defect and actual TS comparison. The later ordinary hierarchy App/query/reorder deliveries remain separately bounded #44 evidence. | #44/#42 broader hierarchy acceptance; feature scaling/timing and current combined #28. No missing relation-mode implementation identified. |
| Machine current view and stateless condition/required preflight | `ordinary-machine-declaration` supplies nominal Inspector/Check grants. [Current ordinary machines](../../experiments/public-inspect/graph-stream-public-bridge-v1/ordinary-machine-stream-v1/FINAL-REVIEW.md), [identity transitions](../../experiments/public-inspect/promotion-stage/identity-transition-v1/FINAL-REVIEW.md) and [missing machine](../../experiments/public-inspect/promotion-stage/identity-transition-v1/missing-machine-v1/FINAL-REVIEW.md) qualify complete outputs, held-slot restoration, actual callbacks, nominal/frame refusals and reached defects. | #48/#49 wider machine lifecycle/handler acceptance, #34 stateful registered guards, feature timing/scaling. The selected U32 fixtures do not prove every value type. |
| Transition-event and declaration-selected relation-failure Inspector | `inspector-transition-projection` reconstructs the supplied runtime/resource; `inspector-failure-projection` selects only declared relation failures. The [current-machine reconciliation](../../experiments/public-inspect/graph-stream-public-bridge-v1/ordinary-machine-stream-v1/FINAL-REVIEW.md) binds historical full stream consumers and namespace/consumption/order controls; all 33 used core bodies remain exact. Only imported, unused machine-declaration functions drift. [Actual TS addendum](../../experiments/public-inspect/graph-stream-public-bridge-v1/ordinary-machine-stream-v1/ts-shared-v1/FINAL-REVIEW.md) and identity TS retain explicit cursor differences. | #55 feature timing/scaling and source-current combined gate. Historical tool execution remains historical; no stream Check capability is owed or granted. |
| Component/query/resource/event/removal/despawn Inspector; only stateless query/resource Check | Existing Inspector/query grants and ordinary event/resource/removal bindings are governed by [#54](inspect.md). Their complete current ordinary consumers, typed boundaries and reached controls are indexed in the existing parity delivery table. These categories are not absent because they predate this extension. | #54 equivalent-work performance qualification and #38 independent-world identity; no transfer of full #54 acceptance to #55. Inspector returns detached Data plus affine owners; no held-view API is proposed. |
| Service observation; no service Check | `ordinary-service-declaration.world_observed` restores Ready/Missing slots and returns Data status; `ordinary-app-service.read` exposes the declaration-derived inventory through abstract ownership. The [ordinary service review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-service-v1/FINAL-REVIEW.md) already qualifies repeated owner-preserving reads, removal/repair, six authority refusals and a reached defect under #56. TS `InspectorContext.services` instead exposes the supplied host service directly (`Runtime.ts:1212`). | General pinned service Inspector access remains #54 inventory/reconciliation; the existing status/inventory projection is qualified #56 evidence, not arbitrary service-value exposure. No standalone service ownership contract blocker is established by this review. Capture composition/recovery, if required by a proposed interface, belongs to #50/#51; #53 governs Type events, not services. |

Repeated inspection, full retained World/graph/slot/stream observations, operational-reader independence and reached consumption/order defects are already evidenced at the callsites above. Trusted slot lenses/presenters and finite owner-preservation observations remain their documented boundaries; tests cannot establish a new universal owner law. The missing-machine TS reuse covers real public unprovisioned-machine preflight and no callback only, not the Bend unavailable view, held-slot restoration or whole 4,645-byte scene.

The relation, machine and selected transition/failure categories added by #55 are qualified within the current Data-valued and declaration-bound scope; full #55 and the broader pinned Inspector inventory remain incomplete. No additional existing-contract #55 implementation is justified by this reconciliation. The next acceptance work is the source-current unchanged #28 regression and complete feature timing/scaling on an exclusive quiet lane, alongside #54 performance qualification and #38 independent-world identity, #34 registered-guard work and any independently justified #50/#51 capture or #53 Type-event extension. The source review does not establish these separate tickets as blockers for every current #55 read. New finite fixtures without a named missing acceptance would not close these gates. No comparative timing, proof, full #55 completion or new policy is claimed here.

The [combined205 review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt205-01/FINAL-REVIEW.md) subsequently passes the unchanged protected Workshop gate on the current 205-module integration. This resolves that accumulated regression gate; equivalent full-feature timing/scaling and dependent capability acceptance remain open.

## Runtime08 compiler-blocker resolution

The [runtime08 result](../../experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime08/RESULT.md)
and [independent review](../../experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime08/delivery-v1/FINAL-REVIEW.md)
bind the three-module fix integrated at `dd54c5d68`. Relation specs are ordinary
Data inside a shared kernel; public signatures and static affine capabilities
remain unchanged. Both fresh backends match all136 observations/147180 oracle
bytes; Native completes stock C emission, ordinary O3 and execution under the
unchanged30/120/5 caps. This resolves the observed emission blocker.

The retained #28 audit binds accepted `9a39b2d9e`: its actual23-source Workshop
closure excludes all three changed modules, with232 pins and four tools exact.
This qualifies protected-gate applicability for the exact transplant, not
Inspector performance. The runtime08 timer remains
`UNQUALIFIED_OPERATION_TO_RESULT_HANDOFF`; equivalent complete feature timing,
scaling and relevant runtime CPU/allocation profiles remain open. Earlier
category/control evidence keeps its original source/tool scope; no new full-#55
acceptance, TS execution or universal refinement follows from this finite run.

The matched-workflow audit subsequently exposed an ordinary-entry composition
gap: `I.Plan` owns a World frame, while transition/failure grants own an event
Runtime frame. Existing fixture `Cap.invoke` calls qualify their primitives, not
an ordinary union Inspector entry. The existing #55 contract therefore needs a
runtime-owned sibling entry with the same fresh/success/failure cursor behavior
as `I.run`, preserving all event-runtime metadata and operational readers. This
is current acceptance work, not a new stream policy. The earlier no-additional-
implementation conclusion was limited to the previously exercised callsites.

The sibling entry accepts the actual Runtime and existing Inspector instance;
its body remains rank-polymorphic over opaque H. Fresh starts at cursor0 and
reads registeredAt from the actual World clock. Success advances that clock
once; failure retains the prior Inspector cursor and does not advance it.
Runtime batches, positions, retention, pending work and all affine owners are
preserved; `Ev.with_world` is not an observational implementation. Acceptance
requires ordinary-entry success/failure/repeated reads and authority controls,
then a matched lifecycle consumer. Only two streams own this work: the runtime
entry and its lifecycle fixture; shared core integration stays with root.

The runtime-owned candidate now has a complete two-schema ordinary consumer:
retained JS output matches the independently corrected v3 oracle (the original
JS receipt remains incomplete), and a fresh Native emission/O3/consumer run
matches all 2,205 bytes under the unchanged limits. Canonical-stage controls
accept the affine-resource positive case and reject undeclared access,
cross-schema use, write-through-read and opaque-handle escape. A reached JS
mutation suppressing successful World-clock advancement matches the independent
counter-oracle and rejects the full normal oracle. This establishes the reached
callsite within this finite scope; it is not a universal ownership proof.

The [runtime-entry packet and independent final review](../../experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/FINAL-REVIEW.md)
retain 162 members; offline verification and malformed-record controls pass.
The additive `src/ecs/inspector-runtime.bend` is integrated with the exact reviewed
body. The protected Workshop's 23 reached sources and four tools still match
its applicability audit; this reuses that workload's accepted gate without
claiming new timings or Inspector performance.

The matched lifecycle fixture separately has a source-derived oracle and actual
TS/JS/Native scale-1 passes against all 24,298 bytes. The first stock Native
attempt reached its 30-second emission deadline on CPU3. A diagnostic source
compiler completed all phases; a subsequent stock CPU5 attempt passed emission,
ordinary O3 and the full consumer under the unchanged 30/120/5 limits, with ten
clean guards. No source repair or workload reduction was needed. The lane and
compiler differences prevent a causal timing claim about the first timeout.

Repository-relative fixture imports have a reversible mapping to those executed
sources and pass the five-second source check. They qualify the local-world
logical Inspector lifecycle, not the process-wide allocator or independent-world
guarantees of WorldIO. These lifecycle outputs are distinct from the 2,205-byte
runtime-entry consumer; full feature timing/scaling and full #55 acceptance
remain open.

The [matched lifecycle packet](../../experiments/public-inspect/graph-stream-public-bridge-v1/feature-timing-v1/ordinary-delivery-v1/README.md)
retains all three scale-1 backend traces, the earlier Native timeout, the diagnostic
profile and the root import mapping. Its 227-member offline verifier and fourteen
malformed controls pass. The fixture, three independently derived scale oracles
and the minimal TS staging import adapter are integrated; the stage preview is
source-only and is not a performance result.
