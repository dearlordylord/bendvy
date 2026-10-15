## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Registered systems independently consume ordered relation mutation failures without conflating them with system transaction failure.

## Acceptance criteria

- [ ] Observe pinned relation failure payloads, ordering, independent reader registration/skip/failure/lag/disposal and structural publication timing through actual scheduled mutations.
- [ ] Run fast/slow readers across missing targets, refused self-links, earlier commits and retry; preserve component/graph owners and existing event/removal cursor contracts.
- [ ] Detect reached wrong-reader advancement and premature failure publication mutants; actual foreign commands still return MissingEntity without queue mutation.

## Blocked by

- #42
- #35

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current core promotion handoff

The [eight-module import-only promotion candidate](../../experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/README.md) maps qualified ordinary registration/runtime/disposal into the now-integrated core paths and lists the remaining actual provider-authority, source-current delivery and performance gates. The [reviewed stock full-capacity successor](../../experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/delivery-v2/FINAL-REVIEW.md) now passes ordinary JS and Native O3 against all 252,206,150 independently derived wire bytes; its inverse recovers every predecessor observation. Historical copied-printer JS and the v1 Native arity failure remain preserved. This is bounded retained evidence, with original source paths archived; no new core API is adopted by the transport wrapper. Combined220 passes the unchanged #28 Workshop gate after [independent review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt220-01/FINAL-REVIEW.md). Matched TS, feature timing/scaling and full #43 remain open.

### Combined parameter prototype: shared history repair

The private prototype checkpoints (`df0386e67`, `4bbade1db`, provider/consumer `33a786fbd`) pass bounded source checks but do not qualify runtime composition. Source audit found each provider retaining an entire event/failure history; collection ran after the callback, and moving that destructive collection into preparation would let the first provider consume another reader's input. This defect concerns the new prototype, not the previously integrated shared-runtime delivery.

The independent Astra review confirms the existing Bevy split: `MessageReader` has local cursor state and shared `Messages`. Reuse `Route.Runtime{world, Mixed.State, tick}` from `event-notice-runtime`/`event-family-runtime`; keep only per-system registration/reader state and ordinary declarations in the provider. Thread shared state through the actual `Sys.run` invocation/envelope, ingest once before all parameter projections, and advance World once per executed callback. Commit cursors together only on success; failure preserves ingested committed history and the previous cursors. No World layout, compiler, or observable contract change is required.

Before broader evidence, execute a small complete consumer with two independent providers (and repeated same-domain parameters), nonempty publication, and failure/retry. Both readers must see the publication exactly once; retry must see the same unread values without duplicate ingestion. Retained declarations must also support #56 automatic debug without a parallel user metadata adapter. These runtime controls remain pending.
