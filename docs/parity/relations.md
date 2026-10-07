## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Systems create, replace and remove typed directed entity links and query both ends with consistent inverse results.

## Acceptance criteria

- [ ] Observe pinned relation definitions, self-link policies, missing-source/target errors, source replacement and inverse iteration order; compare Rust Bevy relationship source-of-truth and protected target collection architecture.
- [ ] Execute actual deferred relate/unrelate and query operations, preserving pre-barrier visibility and exact post-barrier inverse consistency. Direct inverse mutation must not bypass the declared relation API.
- [ ] Cover source/target deletion and exact ordered structural failure publication. Separate relation mutation failures from SystemFailure; registered failure-reader composition is a dependent slice.
- [ ] Test foreign handles and schema/access controls; detect a reached stale-inverse or failed-publication mutant and preserve arbitrary component owners.

## Blocked by

None (can start immediately; explicit unresolved contract gates still apply).

## Delivery and evidence

- Use the pinned bevy-ts behavior as the executable comparator, Rust Bevy ECS source as the architecture reference, and Bend guide/compiler/Base as the type, affine ownership and runtime authority. Record exact reference commits. Observe upstream behavior rather than inventing parity from source descriptions; approved divergences stay explicit.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.
