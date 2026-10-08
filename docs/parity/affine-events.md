## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Event publishers and multiple independent readers use useful affine Type payloads under an explicit ownership-safe publication and projection contract.

## Business requirements and current direction

User direction (2026-10-08): prefer returning data after failure so applications
can reuse it; this is a soft preference, subordinate to a simple, elegant API.
Returning ownership is not a hard requirement for every failure path. If it
would complicate the public API or conflict with required rollback, choose the
simpler ownership-safe behavior and document where reuse is unavailable. Do not
claim a memory improvement merely because an owner is returned.

- **Notifications:** a failed operation must not deliver its notifications. A
  notification such as "enemy killed" may be recreated on retry; the application
  can discard a recovered payload when it has no further use.
- **Reusable transferred data:** an expensive path, loaded chunk or reusable
  buffer should remain recoverable after failed publication, allowing a retry
  without repeating preparation or allocating a replacement unnecessarily.

These are application requirements, not two new runtime event classes. Prefer
one typed ownership-return mechanism: immediate refusal returns the payload;
commit transfers it to the log; abort returns staged payloads through an owned
recovery result. Do not implicitly copy them or restore them into an arbitrary
Resource, Local or capture. The application chooses reuse or discard.

Existing ECS rollback takes precedence over exposing recovery ownership. If a
payload was moved from transactional ECS storage, the same owner cannot both
restore that storage and appear in the recovery result. Coordinate such moves
with #51/#52; recover only owners available after the required restoration. This
event design does not add arbitrary extraction from transactional storage.

Scoped read capabilities are the Bevy/Bend-oriented candidate for readers;
detached snapshots remain an explicit convenience. Returning ownership does not
by itself reduce allocations or bound retained memory: recovered data must be
reused or released, and the implementation needs allocation/profile evidence.
Effectful cleanup needs an IO-aware protocol. Affine typing alone supplies
neither automatic cleanup nor exactly-once finalization.

This records the user's business preference and design direction, not approval
of a particular public recovery signature, cleanup protocol, law or proof. The
implementation should validate the smallest generic ownership transport before
introducing per-event modes, mandatory finalizers or a second event framework.

## Acceptance criteria

- [ ] Observe pinned event-value aliasing and identify where it is incompatible with Bend ownership. Specify storage-owner/projection, independent reader, retention and disposal contracts; seek approval for any behavioral divergence before implementation.
- [ ] Execute actual publication with owned Array payloads and independent fast/slow/skipped/failed readers. Preserve complete payload contents, cursor rules, lag and one-time disposal without duplicating Type.
- [ ] Do not restrict every event to Data merely to make fan-out easy; no-copy shared mutation is not implied. Demonstrate the supported public contract in an independently authored application.
- [ ] Detect a reached payload loss/early disposal mutation and retain the existing Data event API. An expressibility report alone does not pass.

## Blocked by

- #31

## Delivery and evidence

- Follow the [reference roles](../SPEC.md#implementation-decisions): Rust Bevy for ECS architecture and semantics, bevy-ts for feature scope and porting inspiration, and Bend guide/compiler/Base for types, affine ownership and runtime. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Detached staging implementation preparation

[owned-recovery-v1](../../experiments/public-owned-events/owned-recovery-v1/README.md)
implements the simplest generic Type ownership seam: immediate admission refusal
returns the incoming owner and unchanged Stage; accepted commit transfers the
complete FIFO list; abort returns every still-staged owner in a typed receipt.
There is no runtime notification/expensive classification, clone, mandatory
finalizer/IO cleanup or automatic reinsertion. Source-consuming controls contain
complete affine Array payloads; intended duplication of recovered owners is
refused. Raw five-second checker results are retained. Complete detached
commit/abort/refusal observations execute on JS and Native with identical
132-byte output; independent review and the no-child source/output/oracle join
pass. The first JS byte gate remains recorded as failed: its oracle omitted
IO.print's terminal LF. The LF-only repair was checked against retained output
without replay; Native passed the repaired oracle. No #53 acceptance is claimed.

Scope is invocation-created payloads or explicitly transferred owners from
surviving external state. This seam neither extracts transactional components/
resources nor changes #51/#52 rollback. Independent fan-out projections, reader
cursor/retention semantics and World admission remain separate existing bounds;
they are not forced into this staging representation. Existing Data events remain
unchanged. Executed application, negative/mutation/backend/performance and
independent delivery review gates are outstanding.
