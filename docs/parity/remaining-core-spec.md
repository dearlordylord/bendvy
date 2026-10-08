## Problem Statement

The nearest eight-ticket frontier is not the full bevy-ts core. Remaining capabilities are documented, but many have no executable issue, and bounded Workshop speed can be mistaken for full parity. Developers need a complete dependency-aware route without dropping ownership, behavior or performance obligations.

## Solution

Extend the existing full-core specification with executable vertical slices for the remaining public capabilities. Reuse delivered public systems, Compose, schedules, readers, transactions and exact-source evidence seams. Keep existing #34/#35 and #21/#23/#24 rather than duplicating them. Each slice runs an independently authored application and preserves complete observations on TS, JS and Native.

## User Stories

1. As an ECS application developer, I want to compose fragments and reusable features with declared dependencies, so that the complete core remains usable and verifiable in Bend.
2. As an ECS application developer, I want to reject descriptor collisions before application work, so that the complete core remains usable and verifiable in Bend.
3. As an ECS application developer, I want to author general heterogeneous bundles with affine payloads, so that the complete core remains usable and verifiable in Bend.
4. As an ECS application developer, I want to reserve and materialize entities safely across storage growth, so that the complete core remains usable and verifiable in Bend.
5. As an ECS application developer, I want to reject foreign or stale handles under an explicit identity contract, so that the complete core remains usable and verifiable in Bend.
6. As an ECS application developer, I want to query directed links and consistent inverse collections, so that the complete core remains usable and verifiable in Bend.
7. As an ECS application developer, I want to reparent and reorder hierarchies with precise cycle errors, so that the complete core remains usable and verifiable in Bend.
8. As an ECS application developer, I want to clean linked subtrees without leaking payload owners, so that the complete core remains usable and verifiable in Bend.
9. As an ECS application developer, I want to clean lifetime scopes while retaining persistent entities, so that the complete core remains usable and verifiable in Bend.
10. As an ECS application developer, I want to validate constructed descriptors and report nested input errors, so that the complete core remains usable and verifiable in Bend.
11. As an ECS application developer, I want to mark transient values without losing their live behavior, so that the complete core remains usable and verifiable in Bend.
12. As an ECS application developer, I want to use typed finite state components independently of machines, so that the complete core remains usable and verifiable in Bend.
13. As an ECS application developer, I want to queue machine transitions at explicit markers, so that the complete core remains usable and verifiable in Bend.
14. As an ECS application developer, I want to combine machine and read-only check conditions, so that the complete core remains usable and verifiable in Bend.
15. As an ECS application developer, I want to observe independent transition and relation-failure streams, so that the complete core remains usable and verifiable in Bend.
16. As an ECS application developer, I want to execute exit/transition/enter handlers with correct failure boundaries, so that the complete core remains usable and verifiable in Bend.
17. As an ECS application developer, I want to repeat systems that retain owned runtime captures, so that the complete core remains usable and verifiable in Bend.
18. As an ECS application developer, I want to recover destructive affine operations through explicit inverse contracts, so that the complete core remains usable and verifiable in Bend.
19. As an ECS application developer, I want to publish useful owned events without illicit payload copying, so that the complete core remains usable and verifiable in Bend.
20. As an ECS application developer, I want to inspect the world without consuming system visibility, so that the complete core remains usable and verifiable in Bend.
21. As an ECS application developer, I want to enable descriptions, filtered dumps and execution traces, so that the complete core remains usable and verifiable in Bend.
22. As an ECS application developer, I want to keep disabled debug free from tracing work, so that the complete core remains usable and verifiable in Bend.
23. As an ECS application developer, I want to save independent payload data with explicit codecs, so that the complete core remains usable and verifiable in Bend.
24. As an ECS application developer, I want to reject invalid saves before any mutation, so that the complete core remains usable and verifiable in Bend.
25. As an ECS application developer, I want to restore allocator, lifecycle, relations and committed machines, so that the complete core remains usable and verifiable in Bend.
26. As an ECS application developer, I want to retain services and registered local/capture state outside world saves, so that the complete core remains usable and verifiable in Bend.
27. As an ECS application developer, I want to verify all pinned public exports through independent applications, so that the complete core remains usable and verifiable in Bend.
28. As an ECS application developer, I want to see every missing parity behavior assigned to a task, so that the complete core remains usable and verifiable in Bend.
29. As an ECS application developer, I want to review exact falsified laws before approving proofs, so that the complete core remains usable and verifiable in Bend.
30. As an ECS application developer, I want to distinguish finite traces from executable proofs and universal refinement, so that the complete core remains usable and verifiable in Bend.
31. As an ECS application developer, I want to run a complete deterministic fixed-step console simulation, so that the complete core remains usable and verifiable in Bend.
32. As an ECS application developer, I want to plan an isolated Tower Defense copy preserving its reducer, so that the complete core remains usable and verifiable in Bend.
33. As an ECS application developer, I want to retain JavaScript comparability and Native twofold performance on equivalent work, so that the complete core remains usable and verifiable in Bend.
34. As an ECS application developer, I want to advance features while optimizing only demonstrated consequential bottlenecks, so that the complete core remains usable and verifiable in Bend.

## Implementation Decisions

- This is an additive remaining-core specification under #1, not a reduction or replacement of the original full scope. Closed slices #29/#30/#31/#32/#33/#36 are prerequisites/evidence, not proof of complete core parity.
- Rust Bevy ECS is the architecture and ECS semantics reference; pinned bevy-ts shows the target feature subset and provides porting inspiration and comparative scenarios; Bend guide, compiler and Base decide kinds, ownership, closure reuse and runtime representation. Record all three exact commits. Rust-only renderer/assets/audio/editor APIs are not introduced.
- Keep explicit typed declarations and sequential CPU orchestration. Data-only components are unapproved. Template functions, consumed-and-returned affine state and explicit safe projections must replace any impossible JS aliasing; behavioral divergence needs approval.
- Relationships maintain one authoritative source edge with protected inverse consistency; hierarchy and scope cleanup preserve explicit structural barriers and per-system transaction boundaries.
- Separate entity state from machines. Transition markers flush deferred work; exit/transition failures requeue, enter failures retain committed state/publication. Do not implement whole-marker rollback.
- Separate basic save/restore from graph/machine extension. Validate all saved inputs before mutation. World saves omit host services, registered system/reader/local/capture state and runtime queues; restore effects and handle freshness are explicit, not inferred.
- General runtime capture, recoverable payload and affine event contracts are executable tasks with explicit unresolved-decision gates. Publication does not approve a particular representation, host-IO rollback or Data-only shortcut.
- Native target remains <=0.5 times TS elapsed and JS <=TS on equivalent representative complete work. The default frozen #28 gate remains unchanged; the scoped #30 comparator amendment does not waive other gates. Full qualification stays with existing performance parents.
- Final parity auditing inventories every public pinned core export and static rejection boundary. Discovered gaps must become owning tickets and be resolved; an audit report alone cannot establish missing capability acceptance.
- Law proposal/falsification precedes human approval and later proof slices. Existing seven approved subjects stay delivered; 22 supporting candidates remain unapproved. No unconditional proof/refinement ticket is manufactured before exact subjects exist.

## Testing Decisions

- Prefer the highest existing seam: independently authored application -> public world/system/schedule/command/reader API -> complete observable world/stream/owner results. Extend source-bound negative and mutation controls from the delivered Workshop/query/event/removal/schedule/Local work.
- Observe pinned TS tests/checkpoints with Node before declaring parity. Compare complete ordered outputs with only explicit approved divergence normalization. Do not normalize away missing values, queue changes or order.
- Extend authority boundaries with two nominal schemas, actual independent runtime worlds, undeclared access, writes-through-read and affine duplication negatives. Preserve complete payloads and one-time disposal on every success/failure/refusal/retry path.
- Run unchanged baseline regression before executable delivery; retain full receipts. New features receive equivalent-work timing/scaling evidence, without inventing historical baselines. Full connected and five-workload/three-size qualification is separate.
- Use CPU/allocation profiling before/after a selected consequential optimization. Avoid timing under known CPU contention and report sampled allocations independently from physical memory. Preserve failed experiments.

## Out of Scope

Changes to canonical jev or references/compiler/kernel; new dependencies without approval; browser/render/math/devtools UI adapters, schema generation and parallel/GPU orchestration without a concrete separately scoped need. Full Rust Bevy parity is not the goal. These exclusions do not remove pinned bevy-ts core behavior, including host-facing contracts, from the coverage audit.

## Further Notes

Publication is pre-approved by the user. No new interview or permission loop is needed for existing application-level test seams and ticket granularity. Specific new public divergences, laws, dependencies and numeric criteria retain their own approval gates. This plan supplies concrete current slices and explicitly gated later specification work; it does not claim every future proof or copied integration ticket is already executable. Preserve #1 and existing parents unchanged.
