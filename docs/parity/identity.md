## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An application safely creates independent worlds, reserves and materializes entities, grows storage and receives precise exhaustion/refusal results without losing owners.

## Acceptance criteria

- [ ] Observe pinned allocation/reservation/despawn behavior and enumerate the supported numeric and storage domains. Record the reuse/generation and stale-handle policy explicitly; obtain approval for any new divergence before implementing it.
- [ ] Test independently created same-schema worlds and attempted caller-fabricated authority. Colliding foreign handles return MissingEntity and leave queues unchanged; nominal schema checks alone do not pass.
- [ ] Run reservation, pending spawn, cancellation/failure, growth boundaries, clock/ID exhaustion and retries through actual commands/barriers. Bounds checks precede Bend masked array access; refusal preserves the complete world, allocator and owners.
- [ ] Detect a reached namespace/bounds mutation and preserve current consumers. Distinguish trusted raw constructors from the advertised application authority; do not claim language-wide confinement from factory-only tests.

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

## Proposed decision context — not an adopted contract

Pinned Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60` separates process-local WorldId allocation from entity index/generation allocation. [WorldId::new](../../.references/bevy/crates/bevy_ecs/src/world/identifier.rs) checks exhaustion and never reuses an allocated world id. [EntityAllocator](../../.references/bevy/crates/bevy_ecs/src/entity/mod.rs) can reuse freed indices; world despawn advances generations, invalidating older handles. Its generation is U32 and the pinned documentation explicitly permits eventual wrap/alias. Bevy Entity alone does not carry WorldId. Bend's approved foreign-handle MissingEntity behavior must remain stronger than that representation: namespace validation precedes lookup/queue effects and rejection preserves the receiving World and owners.

The current public `world.factory()` returns Factory{1}; affine threading prevents duplication of one Factory, but independent factory roots can restart the same namespace. The [checked host namespace packet](../../experiments/public-identity/host-namespace/README.md) demonstrates independent creator calls using a checked process-local host counter, including saturation refusal. The [public integration packet](../../experiments/public-identity/public-integration/README.md) retains actual same-schema Worlds, five typed columns, commands/barriers and foreign refusals. These finite private traces do not adopt a public creation authority or establish cross-process/snapshot identity. Raw World/Handle constructors remain trusted administration, so public factory confinement is not language-wide constructor secrecy.

Bend reference `a950fd683c0d76f09794078e6174fe98a1492876` makes the boundary concrete: `base.bend` Array.get.at masks an index with size-1; `comp.ts` U32 operations wrap to32 bits on JS/C. Affine Type ownership protects moved owners, not freshness of numeric IDs. Namespace, generation and capacity checks must therefore precede masked indexing or wrapping arithmetic; exhaustion returns original owners rather than inventing a fresh identity.

The smallest creation decision is whether the advertised independent-world creator adopts the existing checked process-local host allocator, while retaining pure Factory as trusted explicit setup. This matches Bevy's process-local architecture and preserves MissingEntity, but needs approval of host-effect authority and its identity domain. A pure alternative requires callers to thread one creation authority across all worlds; separately restartable roots cannot claim global uniqueness. Neither alternative specifies serialized/IPC identity.

Logical-ID reuse is a separate unresolved choice. Monotonic IDs with explicit exhaustion retain current stale-handle safety but do not recycle physical slots as Bevy does. Namespace+index+generation with a freelist is closer to Bevy: old handles fail after reuse, capacity can be recycled, and generation exhaustion needs an explicit refusal/retirement policy if indefinite stale safety is required. A monotonic external logical ID over recycled physical slots preserves old public handles but adds mapping/storage and differs from Bevy's reused index. No generation wrap policy, failed reservation reuse or snapshot rebinding is selected here. TS is comparison inventory and cannot decide these policies.

Ordinary IO creation is approved below. SPEC treats ID reuse and physical layout as technical choices constrained by observable contracts; a generation field or freelist alone is not a separate approval gate. A changed observable contract, including the finite generation-wrap/retirement or exhaustion boundary, still requires its explicit decision before adoption. Existing #38 reservation/cancellation/growth/clock exhaustion, caller-fabricated authority, reached bounds/namespace controls and complete backend/regression gates remain required. No new law or executable contract is adopted by this context.

## Current allocator facts — 2026-10-16

The integrated [World allocator](../../src/ecs/world.bend) has namespace/id handles,
no generation or freelist, and a bounded 131072-ID reservation domain. Reservation
consumes an ID immediately; despawn clears liveness without returning that ID.
[Command staging](../../src/ecs/commands.bend) does not rewind reservation on failed
publication. Clock advancement currently saturates at U32 maximum; registration
allocation instead refuses at its own maximum. These are distinct from the
approved namespace nonwrap policy.

The [core README](../../src/ecs/README.md) calls the allocator bounded;
[SPEC](../SPEC.md#implementation-decisions) leaves reuse/layout technical, and the
[arithmetic approval scope](../archive/recovered/reviews/delegated-owned-law-approval.md)
does not freeze allocator policy. The implementation constant is not an approved
production-capacity requirement. Preserve the qualified failed-reservation handle
and query-order observations while reconciling raw-ID consumers with a concrete
generational representation. Finite-domain wrap/alias versus slot retirement and
owner-preserving refusal remains an actual observable boundary, not a choice
settled by the current constant or the TS inventory.

## Approved ordinary creation — 2026-10-14

The user approved ordinary World creation through IO, following Bevy: allocate
a unique process-local namespace, refuse exhaustion without wrap or reuse, and
return incoming owners on refusal. Pure Factory/raw construction remains trusted
explicit setup. This selects creation authority only; entity ID reuse, generation
exhaustion, supported capacity and candidate laws remain undecided.

Implement through a host IO module over the pure World core. Reuse existing
owner/foreign-world controls and qualify the supported JS/Native runtime and
module/link boundaries explicitly; shared JS realms and single linked executables
do not by themselves establish uniqueness across workers, VM realms or DSOs.
Do not silently replace the approved process-local target with a narrower claim.

The [current-public host packet](../../experiments/public-identity/approved-io-creation-v1/README.md)
is integrated at `07a70564f`: complete owner, foreign-handle, rollback and
exhaustion controls pass at their documented host scopes. The shared-realm JS
allocator is adopted after independent final review and the [fresh unchanged #28 gate](../../experiments/public-identity/approved-io-creation-v1/regression-current-v1/fresh-gate-v2/delivery/DELIVERY.json):
20 pairs per backend, 110 complete checked outputs, no confirmed regression.
This Workshop gate does not exercise allocator IO or establish its hot-path performance.
Historical failed emission and the separate successful diagnostic remain distinct.

Native near-maximum saturation is now verified in the [retained successor](../../experiments/public-identity/approved-io-creation-v1/public-exhaustion-native01/delivery/RESULT.json):
one initializer-only trusted C seed, ordinary `-O3`, two last-valid namespaces
then two refusals, and exact 158-byte owner observations. This is sequential
single-executable evidence, not concurrency or cross-DSO qualification. The
original archive remains historical; no fresh Bend emission is claimed.

## Current authority and rollback backend qualification

The [complete public successor](../../experiments/public-identity/approved-io-creation-v1/native-authority-v1/delivery-v1/README.md)
now exercises independently created same-schema WorldIO worlds on stock JS and
Native. Colliding foreign handles return MissingEntity without changing the
transaction queue. Both backends match the full 1,829-byte successful-commit
oracle and 1,819-byte rollback oracle, including all five component families and
lifecycle stamps. Rollback restores the prior payload and stamp while retaining
the already advanced World clock. Production ECS sources are unchanged.

The previous JS-only observations omitted stamps and remain historical. The
successor retains all prior operations and adds their missing observations;
ten commands and 34 guards pass. The pinned checker retains its four expected
foreign-IO-dependent refusals, so this is backend evidence rather than a proof
checker PASS. The portable packet supports offline and relocated verification.

This fills a specific backend/observation gap, not complete #38 acceptance.
Reuse/generation/capacity decisions, broader host-domain uniqueness and the
remaining criterion-level source reconciliation still belong to this issue.
No fresh performance qualification is claimed; combined gates remain unchanged.

The [fork/join successor](../../experiments/public-identity/approved-io-creation-v1/native-authority-v1/fork-v1/delivery-v1/README.md)
adds two public IO tasks, both forked before joining their complete affine
World/Handle sessions. Whole-session namespace ordering makes the observations
of identical anonymous tasks deterministic. Stock JS and Native each match the
complete 1,829-byte independent oracle, including the unchanged authority and
lifecycle checks. This qualifies logical IO handoff, not distinct task-origin
routing or simultaneous native allocator contention: the nonblocking namespace
effect executes on Bend's IO loop. Cross-worker/realm/DSO qualification remains
separate. No identity policy or production core changed.

The earlier large-scan owner gap is superseded by the retained
[owner-extension evidence](../../experiments/public-identity/production-plan/OWNERS-REPORT.md).
Review of the actual JS/Native repeated-scan, payload/resource owner, dropped
pending-command and reversed-FIFO observations confirms reuse. Current tail
traversal matches the qualified helpers after constructor renaming; Store,
Resource and pending closures remain outside size-dependent recursion and pass
through the same finish operation. Joined large traversal and owner controls are
finite evidence; no additional combined-large-owner run was needed.
