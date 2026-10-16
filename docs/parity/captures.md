## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Independently authored systems retain runtime affine capture state across repeated registration, execution, failure and disposal.

## Acceptance criteria

- [x] Define the reusable runner contract from Bend single-use closure semantics and Bevy persistent FunctionSystem state; consume and return the actual capture owner each run rather than copying a closure.
- [x] Freeze the public capture failure/skip/disposal contract separately from ECS rollback and Local. Obtain approval for any new ownership-visible decision before implementation; feasibility alone is not delivery.
- [x] Execute two captured affine Arrays and distinct instances across repeated schedules, refusal/retry and one-time disposal; reject owner duplication and undeclared access.
- [x] Preserve existing closed-template consumers and detect a reached lost-capture/double-disposal mutant. No claim of rewinding arbitrary host IO.

## Blocked by

- #36

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Implementation direction — registered capture owners

Bevy's persistent `FunctionSystem.func` and owner-returning
`World::unregister_system` govern #50. A closed runner threads the actual affine
capture pack; entered-call changes persist on ordinary failure while the existing
ECS transaction rolls back. Skip preserves capture state; refusal returns the
actual instance and arguments. Unregister removes registration authority and
returns the capture; registering it again obtains a new registration ID. This
reuses Local transport without changing Local's behavior. It adds no mandatory
finalizer, cross-world transfer or #52 destructive inverse policy.

`ordinary-captures.define` accepts the existing resource declaration and authored
rank-2 body; access metadata and transaction completion are derived. The raw
`captures.register` runner remains a trusted integration seam. Initial consumer:
`experiments/public-captures/ordinary-owner-v1/main.bend`. The linked runtime packets retain complete backend observations, authority
controls, reached lifecycle mutations, actual TS references and regression reuse.

## Resource capture lifecycle — bounded delivery

The [ordinary entry](../../experiments/public-captures/ordinary-owner-v1/runtime-v1/README.md) passes stock JS/Native against all 3,749 independent oracle bytes. The [scheduled successor](../../experiments/public-captures/ordinary-owner-v1/scheduled-v1/README.md) adds repeated public schedules, genuine colliding foreign registrations and recovery of all three capture packs; both backends match all 6,169 bytes. Five intended type/affine refusals accompany a positive ordinary declaration check. The reached unregister-removal omission matches its 6,277-byte counter on both backends and rejects the normal trace; it tests retained registration authority, not an observed second disposal or external finalizer.

[Independent review](../../experiments/public-captures/ordinary-owner-v1/scheduled-v1/runtime-v1/FINAL-REVIEW.md) accepts the bounded scheduled/authority batch.

The [TS crosswalk](../../experiments/public-captures/ordinary-owner-v1/TS-APPLICABILITY.md) reuses actual pinned reference observations for shared capture behavior. Bevy governs unregister; TS has no equivalent public operation. Existing stock #28 evidence applies through the unchanged protected-source/artifact bridge, without a new timing claim.

## Ordinary query capture delivery

`ordinary-capture-query.define` threads arbitrary affine capture state across
matching rows through the existing query capabilities. Entered-row capture
changes persist on failure; component payloads/stamps roll back, the monotonic
World clock is retained, and the query cursor advances only on success.
The [first query packet](../../experiments/public-captures/ordinary-owner-v1/query-v1/runtime-v1/README.md)
retains all 7,441 independent oracle bytes on stock JS/Native, including the
original Native timeout and successful unchanged-ELF retry under the same cap.
Five intended query authority refusals accompany a positive two-Array check.

`ordinary-app-capture-query-fields.register` derives debug bindings, clauses and
modes from the ordinary declaration and retains each owner's actual cursor.
The [App consumer](../../experiments/public-captures/ordinary-owner-v1/query-v1/app-v1/README.md)
uses ordinary registration and enables the existing debug flag; it supplies no
metadata adapter. Both backends match the full 4,961-byte independent oracle,
including separate query cursors, all World/capture state and unregister recovery.
The [actual TS query crosswalk](../../experiments/public-captures/ordinary-owner-v1/query-v1/reference-delivery-v1/README.md)
retains its complete 8,785-byte shared-behavior trace and explicit tick/API differences.

The [actual repeated-unregister control](../../experiments/public-captures/ordinary-owner-v1/repeated-unregister-v1/runtime-v1/FINAL-REVIEW.md)
executes a second unregister with genuine original registration metadata and the
actual returned affine pack. Both stock backends reject it normally; the reached
omission mutant incorrectly accepts it. This meets the bounded repeated-unregister
mutation criterion. External finalization and general heterogeneous composition
remain outside #50; composition belongs to #51.

[Independent joined review](../../experiments/public-captures/ordinary-owner-v1/query-v1/FINAL-REVIEW.md)
accepts #50 semantic delivery. Integration, CI and the governing issue report
complete its delivery checkpoint.
No new law/proof or capture-specific performance claim follows from these finite
traces. Stock #28 evidence is reused through the unchanged 23-source protected
closure; combined feature performance remains under #21/#23/#24.
