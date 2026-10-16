## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An application reparents an ordered hierarchy, traverses it and removes linked subtrees with exact cleanup and diagnostics.

## Acceptance criteria

- [x] Observe pinned ancestors/descendants/children order, reparenting, linked-despawn options and self/cycle rejection. Compare Bevy ChildOf/Children and relationship traversal without importing unapproved Rust-only behavior.
- [x] Execute child reorder including missing/duplicate/unrelated children and child-set mismatch. Refusal preserves all edges and published failures follow actual barrier semantics.
- [x] Despawn roots/intermediate nodes and verify every survivor, inverse, removal stream and affine payload disposal exactly once; detect reached cycle/cleanup/order mutants.

## Blocked by

- #42

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Semantic acceptance reconciliation

The current-source audit and independent final Spec/Standards review by
`scopes45_source_control` confirm all three native semantic criteria. Publication
and CI remain pending. Evidence is joined by
operation and observation, rather than by treating one bounded packet as the
whole feature:

| Criterion | Retained evidence |
| --- | --- |
| Ordered traversal, reparenting and self/cycle rejection | [Public delivery](../../experiments/public-hierarchy/public-delivery-v1/FINAL-REVIEW.md), [ordinary App](../../experiments/public-hierarchy/granular-provider-v1/ordinary-app-v1/FINAL-REVIEW.md), [descendant query](../../experiments/public-hierarchy/granular-provider-v1/ordinary-app-v1/descendant-query-v1/FINAL-REVIEW.md), and [actual TS reference](../../experiments/public-hierarchy/RESULT.md): 46 complete checkpoints under two nominal schemas. |
| Missing, duplicate, unrelated and mismatched child-set refusals | [Rejection matrix](../../experiments/public-hierarchy/granular-provider-v1/ordinary-app-v1/rejection-matrix-v1/FINAL-REVIEW.md): complete 41,133-byte JS/Native observations preserve refused edges and publish errors at the barrier; compiling omission controls are retained. |
| Root/intermediate/repeated linked cleanup, survivors, inverses, streams and affine ownership | [Owner fold](../../experiments/public-hierarchy/public-delivery-v1/cleanup-v1/owner-fold-v3/FINAL-REVIEW.md), [root/repeat](../../experiments/public-hierarchy/public-delivery-v1/cleanup-v1/installed-app-v1/root-repeat-v1/FINAL-REVIEW.md), and [registered systems](../../experiments/public-hierarchy/public-delivery-v1/cleanup-v1/installed-app-v1/registered-system-v1/FINAL-REVIEW.md), including callback failure/rollback/retry and actual foreign-world refusals. |

The [cycle/order controls](../../experiments/public-hierarchy/bend-candidate/controls-v1/portable-controls-v1/REPORT.md)
retain complete JS/Native counteroutputs; the separate
[child-set successor](../../experiments/public-hierarchy/bend-candidate/controls-v1/set-checker-fix-v1/REPORT.md)
repairs its own failed cohort. The original cycle commands succeeded before the
later set-check deadline: the terminal failure is preserved. The old report's
missing per-command version-probe note is not a missing executable identity:
actual argv, stock Bend `f7741747…`, Node `23a5637c…`, Clang `c50213ca…`,
Base/resource/library pins and generated artifacts remain bound to the twelve
successful cycle commands. No receipt is relabelled and no new backend run is
claimed.

Seven principal hierarchy/cleanup modules match their qualified source hashes.
The rejection matrix has the same six dependency changes recorded for
[#45](../../experiments/public-scopes/source-survivor-control-v1/delivery-v1/REUSE.json):
order/count-equivalent pending-length traversal and unreached metadata/query or
failure-reader additions. This reconciliation changes no executable core and
reuses the protected #28 evidence at its existing scope. Comparative timing and
final performance targets remain under #21/#23/#24. Affine disposition here is
the existing cleanup contract, not general effectful IO finalization or Rust
`Drop`; finite observations are not universal refinement.

Independent verification retained the actual complete outputs: rejection matrix
41,133 bytes per backend, root/repeat 13,855, registered cleanup 9,103 and TS
reference 60,713. Portable control verification covers 893 archived objects and
14 complete comparisons; the child-set successor verifies separately. These
are offline source/artifact checks, not fresh compiler or benchmark executions.
