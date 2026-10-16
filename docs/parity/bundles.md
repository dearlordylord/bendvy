## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A caller authors reusable heterogeneous component bundles and uses them in public spawn/insert commands without consuming payloads on refusal.

## Acceptance criteria

- [x] Observe pinned staged-component/bundle duplicate, constructor, replacement and deferred ordering behavior; publish a complete API coverage list before implementation.
- [x] Execute bundles containing tags, Data values and multiple arbitrary affine Type Array payloads in two schemas. Preserve explicit barriers, full replacement rollback and exact owner cleanup.
- [x] Test invalid construction, duplicate entries, missing/foreign entity and retry with complete queue/world/payload observations. No scalar-only or fixed-demo arity substitute; detect a reached omitted-component mutant.

## Blocked by

None (can start immediately; explicit unresolved contract gates still apply).

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
and CI remain pending.

| Criterion | Retained evidence |
| --- | --- |
| Public API, staging, duplicates and constructors | [Coverage and current acceptance](../../experiments/public-bundles/owned-public-result-v1/surface-COVERAGE.md); public duplicate preflight follows Bevy and rejects repeated families before construction/reservation, returning original owners. The older pending duplicate-contract note is superseded history; the current inventory does not retrospectively establish publication before the first experimental implementation. |
| Tags, Data and multiple affine Array payloads under two schemas | [Complete-family review](../../experiments/public-bundles/complete-families-oracle-v1/FINAL-REVIEW.md): full 5,411-byte JS/Native observations and the reached omitted-Data installer. Recipes are heterogeneous typed composition, not a scalar or fixed-arity substitute. |
| Invalid construction and original-owner recovery/retry | [Mixed construction](../../experiments/public-bundles/owned-public-result-v1/canonical-world-v1/mixed-construction-v1/FINAL-REVIEW.md): full 6,859-byte A/B JS/Native results and executed 3,686-byte TS comparator. |
| Duplicate, missing and foreign refusals | [Duplicate admission](../../experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/FINAL-REVIEW.md): complete refusal/retry observations, intended authority negatives and reached admission bypass. The [canonical WorldIO review](../../experiments/public-bundles/canonical-world-review-v1/AFFECTED-REVIEW.md) separately qualifies two actual ordinary WorldIO creations and inactive-target retry. |
| Deferred ordering, full replacement rollback and cleanup | [Current ordinary application](../../experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/FINAL-REVIEW.md): full stock JS/Native results at scales 1/2/4 and executed TS counterparts; these correctness observations do not claim comparative performance. |

All nine modules in the [core acceptance join](../../experiments/public-bundles/owned-public-result-v1/MASTER-CORE-ACCEPTANCE-JOIN.json)
remain byte-identical; the qualified ordinary bundle frontend is
`f4c83075da63df011c6acd2bc5ac704e40038a117961941b83f886eb0217ac64`.
Private normalization candidates are not needed or adopted for this semantic
reconciliation. Existing explicit constructor inverses and owner recovery remain
the contract; no global cancellation/failed-activation policy, implicit finalizer
or universal inverse is inferred. Those separate identity/runtime obligations
remain with their owning tasks. Combined #28 and final comparative targets under
#21/#23/#24 retain their scope; this document changes no executable core.

Current dependency applicability: `World.pending_length` uses an equivalent
owner/order/count-preserving tail accumulator; schema-fragment classification
changes are exercised by the retained current-classification stock traces;
`world-io.bend` changes are comments. The JS sidecar now shares its namespace
allocator across modules; these single-module fresh-process consumers retain
the same sequence. Namespace Bend/C and remaining selected core inputs match.
The older World alpha-rename-only reuse note is not the full current delta.

The inventory was published in `8f6843090` before canonical production adoption
`12710fab4`; publication before initial experiments is not asserted. Independent
review checked 408 retained runtime members/24 complete family, construction and
refusal results, 102 current-classification members with all six stock JS/Native
outputs (18,058/36,186/72,442 bytes), and the 3,686-byte executed TS comparator.
These are source-bound finite observations, not universal refinement.
