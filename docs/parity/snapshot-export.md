## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An application exports basic entities, components, resources and allocator progress into an independent save value while preserving the live world.

## Acceptance criteria

- [ ] Observe pinned snapshot version/name keys, descriptor validation gate, transient omissions and basic field coverage. Publish the exact snapshot contract and explicit difference between world save and runtime checkpoint.
- [ ] Implement an ownership-safe independent representation using explicit codecs/projections for affine payloads; test post-save live mutation and save lifetime without relying on TS shared object aliases.
- [ ] Reject unvalidated saved descriptors at the advertised boundary; preserve transient resources and live owners. Basic save may precede graph/machine extension but is not full snapshot parity.
- [ ] Detect a reached included-transient/aliased-save mutant; serializer/JSON host integration must not assume a new dependency.

## Blocked by

- #46
- #38

## Delivery and evidence

- Follow the [reference roles](../SPEC.md#implementation-decisions): Rust Bevy for ECS architecture and semantics, bevy-ts for feature scope and porting inspiration, and Bend guide/compiler/Base for types, affine ownership and runtime. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.
