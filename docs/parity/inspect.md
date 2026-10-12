## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Host code repeatedly inspects components, resources and event/removal streams while leaving system reader positions and retention unchanged.

## Acceptance criteria

- [ ] Observe pinned Inspector read capabilities and check-condition behavior; execute public inspect repeatedly before and between schedules with two schemas.
- [ ] Verify no writes, structural flush, reader registration/advancement or retention participation; return affine World/payload owners and expose safe projections instead of mutable aliases.
- [ ] Check exact missing requirements and errors, read-only query negatives, undeclared categories and a reached reader-consumption mutant. Relations/machine inspector surfaces are completed in a dependent extension.

## Blocked by

- #35

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current resource boundary

The ordinary present-resource binder is integrated with [bounded JS/Native review](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/present-resource-v1/public-relocation-v1/FINAL-REVIEW.md). Missing-resource lowering remains an actual #54 gap: pinned bevy-ts `Runtime.ts` uses partial resources (line147), skips absent constructed inputs (498–510), inserts only supplied values (477–490), and preflights schedule requirements before advancing the frame (1674–1687). Rust Bevy validates absent `Res`/`ResMut` in `system_param.rs` (904/955). Bend’s current ordinary resource provision requires a supplied owner. A `Maybe` payload is not resource absence; no new absence or ownership policy is adopted here. References: TS3040a3b2a3f28fa8554d856f9ccb6bf5433fa334; Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60.

The [two-present-resource TS comparison](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/present-resource-v1/ts-common-v1/FINAL-REVIEW.md) passes its complete independent 10,876-byte oracle. TS cursor/tick advancement and JS aliases remain explicit reference differences; this does not resolve resource absence or held-view contracts.

The [ordinary query method slice](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/ordinary-query-errors-v1/FINAL-REVIEW.md) qualifies real handle2 `QueryMismatch`, required single success, optional `MultipleEntities`, and Changed/cursor1 zero-row `NoEntities` versus successful `None`. Both schemas and full returned App owners pass on JS/Native. Historical TS query evidence is current and reused as complete parsed JSON equality; no fresh TS run or affine ownership transfer is claimed. Earlier checks of the wrong consumer and an emitter failure remain explicitly uncredited. Full47 Native and broader composition remain separate gates.

### Ordinary missing-resource registration

[Bounded Spec/Standards review](../../experiments/public-inspect/promotion-stage/missing-resource-v1/FINAL-REVIEW.md) accepts the additive ordinary resource provider. The original `Resource<S,P>` identity indexes a physical affine Missing/Present Slot and its storage cursor. One declaration supplies grants, preflight, observation, access and the actual retained Registry/recipe. Optional reads expose `Maybe<DataV>` while returning owners; required Missing refuses before the existing transaction/callback. Registered arguments and detached `run_latest` outcomes are Data; retained resources and owners remain arbitrary Type. Presenters/lenses remain trusted.

Four real worlds across two nominal schemas pass complete 35,700-byte JS/Native observations. The actual preflight omission passes the independent 35,556-byte counter on both backends and rejects both complete normal results; all 59 source bodies are restored. Actual schema, same-payload resource/storage identity and affine-App refusals pass. Existing executed TS optional-inspection and registered-required scenarios are reused only within their exact source-bound scopes.

The [direct Inspector/Check consumer](../../experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/FINAL-REVIEW.md) now passes complete 51,702-byte JS/Native observations: repeated public calls surround actual optional/required system runs in four worlds, retain detached Payload/Counter Data, and distinguish Inspector clock/cursor from operational Registry cursors. New host access/owner refusals pass. A reached local Counter projection mutation passes its full independent counteroracle and rejects the matching normal baseline on both backends. This is finite detached-Data preservation and projection evidence; arbitrary borrowing, universal presenter purity and reader-consumption mutation are not established. Historical TS evidence is reused only for its exact selected operations.

Full #54, broader inspector composition, universal proofs and feature performance remain open. Combined213 is prepared but deferred under CPU contention; the unchanged #28 gate remains required for the integrated executable core.
