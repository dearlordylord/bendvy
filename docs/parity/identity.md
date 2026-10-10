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
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Proposed decision context — not an adopted contract

Pinned Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60` separates process-local WorldId allocation from entity index/generation allocation. [WorldId::new](../../.references/bevy/crates/bevy_ecs/src/world/identifier.rs) checks exhaustion and never reuses an allocated world id. [EntityAllocator](../../.references/bevy/crates/bevy_ecs/src/entity/mod.rs) can reuse freed indices; world despawn advances generations, invalidating older handles. Its generation is U32 and the pinned documentation explicitly permits eventual wrap/alias. Bevy Entity alone does not carry WorldId. Bend's approved foreign-handle MissingEntity behavior must remain stronger than that representation: namespace validation precedes lookup/queue effects and rejection preserves the receiving World and owners.

The current public `world.factory()` returns Factory{1}; affine threading prevents duplication of one Factory, but independent factory roots can restart the same namespace. The [checked host namespace packet](../../experiments/public-identity/host-namespace/README.md) demonstrates independent creator calls using a checked process-local host counter, including saturation refusal. The [public integration packet](../../experiments/public-identity/public-integration/README.md) retains actual same-schema Worlds, five typed columns, commands/barriers and foreign refusals. These finite private traces do not adopt a public creation authority or establish cross-process/snapshot identity. Raw World/Handle constructors remain trusted administration, so public factory confinement is not language-wide constructor secrecy.

Bend reference `a950fd683c0d76f09794078e6174fe98a1492876` makes the boundary concrete: `base.bend` Array.get.at masks an index with size-1; `comp.ts` U32 operations wrap to32 bits on JS/C. Affine Type ownership protects moved owners, not freshness of numeric IDs. Namespace, generation and capacity checks must therefore precede masked indexing or wrapping arithmetic; exhaustion returns original owners rather than inventing a fresh identity.

The smallest creation decision is whether the advertised independent-world creator adopts the existing checked process-local host allocator, while retaining pure Factory as trusted explicit setup. This matches Bevy's process-local architecture and preserves MissingEntity, but needs approval of host-effect authority and its identity domain. A pure alternative requires callers to thread one creation authority across all worlds; separately restartable roots cannot claim global uniqueness. Neither alternative specifies serialized/IPC identity.

Logical-ID reuse is a separate unresolved choice. Monotonic IDs with explicit exhaustion retain current stale-handle safety but do not recycle physical slots as Bevy does. Namespace+index+generation with a freelist is closer to Bevy: old handles fail after reuse, capacity can be recycled, and generation exhaustion needs an explicit refusal/retirement policy if indefinite stale safety is required. A monotonic external logical ID over recycled physical slots preserves old public handles but adds mapping/storage and differs from Bevy's reused index. No generation wrap policy, failed reservation reuse or snapshot rebinding is selected here. TS is comparison inventory and cannot decide these policies.

Proposed next approval: select the independent-world creation authority/domain first; then explicitly choose public logical-ID reuse and generation-exhaustion behavior before implementation. Existing #38 reservation/cancellation/growth/clock exhaustion, caller-fabricated authority, reached bounds/namespace controls and complete backend/regression gates remain required. No new law or executable contract is adopted by this context.
