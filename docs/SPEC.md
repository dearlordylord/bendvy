## Problem Statement

We need a Bend-native entity-component-system runtime that retains the useful behavior of the current bevy-ts core without inheriting TypeScript's representation or ownership assumptions. Starting with a small ECS must not silently discard events, relations, states, transactions, composition or tooling from the eventual scope.

The runtime must exploit Bend's type system and execution model correctly and offer measurable performance: low-level native builds must substantially outperform bevy-ts, while JavaScript builds must be at least comparable on equivalent workloads. At specification creation, no implementation or performance evidence existed. Current bounded experimental evidence and remaining production gates are recorded in [the next checkpoint draft](next-core-checkpoint.md); the full runtime and final performance acceptance remain incomplete.

## Solution

Build Bendvy toward the complete core of the pinned bevy-ts reference, using explicit typed world declarations initially, declared system access, observable ECS contracts, and law-driven development. Plan the immediate expressibility and architecture checks in detail; retain later capabilities with dependencies and conditions for returning to detailed planning.

Deliver a simple reproducible CPU console simulation first. Later, validate integration using a separate copy of canonical-defense, preserving its authoritative reducer and leaving its original repository untouched.

## User Stories

1. As an ECS application developer, I want entities with stable world-scoped handles, so that references can survive across ticks without implying liveness.
2. As an ECS application developer, I want fallible lookup of dead, foreign and not-yet-live handles, so that invalid references cannot access another entity's data.
3. As an ECS application developer, I want typed components, tags and spawn bundles, so that I can express entity composition without unchecked casts.
4. As an ECS application developer, I want explicit world schemas, so that components from unrelated worlds cannot be mixed accidentally.
5. As an ECS application developer, I want schema fragments and feature composition in the eventual core, so that applications can be assembled from reusable modules.
6. As an ECS application developer, I want required, optional, presence and absence queries, so that systems operate on exactly the intended entities.
7. As an ECS application developer, I want declared read and write access, so that system capabilities are visible in its contract.
8. As an ECS application developer, I want undeclared access and writes through read access rejected by Bend checking, so that correctness does not depend on developer discipline alone.
9. As an ECS application developer, I want resources and per-system local state, so that shared and private state have explicit ownership.
10. As an ECS application developer, I want host services and checked provisioning, so that external capabilities are separated from ECS-owned state.
11. As an ECS application developer, I want repeatedly executable systems, so that affine closures do not prevent schedules from running every tick.
12. As an ECS application developer, I want deterministic schedules, phases, conditions and nested composition, so that execution order and dependencies are predictable.
13. As an ECS application developer, I want deferred structural commands with explicit application barriers, so that query membership changes at known boundaries.
14. As an ECS application developer, I want queued commands to remain pending between schedule runs, so that schedule completion does not introduce an implicit flush.
15. As an ECS application developer, I want reserved spawn handles distinguished from live entities, so that references to pending entities have defined behavior.
16. As an ECS application developer, I want observable query order preserved across lifecycle operations, so that storage changes do not silently change gameplay.
17. As an ECS application developer, I want added and changed detection per system, so that readers independently observe relevant updates.
18. As an ECS application developer, I want removed and despawned observations, so that cleanup does not depend on querying already-deleted data.
19. As an ECS application developer, I want buffered events with independent reader cursors, so that one reader cannot consume another reader's events.
20. As an ECS application developer, I want defined event retention and lag reporting, so that schedules running at different rates do not silently lose messages.
21. As an ECS application developer, I want explicit skip and failure cursor rules, so that retries and conditional schedules see predictable data.
22. As an ECS application developer, I want typed system failures and read-your-writes, so that stateful decisions can fail without publishing partial ECS changes.
23. As an ECS application developer, I want rollback limited to the failed system, so that earlier successful systems remain committed.
24. As an ECS application developer, I want commands, events and machine queues published only according to their transaction contracts, so that failed systems cannot leave hidden work behind.
25. As an ECS application developer, I want relations, inverse links and hierarchy rules, so that linked entities remain consistent through cleanup.
26. As an ECS application developer, I want entity lifetime scopes, so that scene-owned entities can be cleaned up together.
27. As an ECS application developer, I want state machines with explicit transitions and transition schedules, so that entering and leaving states has defined ordering and failure boundaries.
28. As an ECS application developer, I want validation and typed errors at input boundaries, so that invalid authored or loaded data cannot silently enter the world.
29. As an ECS application developer, I want snapshots with an explicit restoration contract, so that save/load guarantees are distinguishable from full runtime recovery.
30. As an ECS application developer, I want read-only inspectors and opt-in debug facilities, so that observation does not consume schedule visibility or alter state.
31. As a Bend developer, I want component and query interfaces shaped around Bend kinds and ownership, so that the runtime uses the language correctly rather than simulating JS aliases.
32. As a Bend developer, I want Data and affine Type payload options investigated before an API restriction is adopted, so that useful Bend capabilities are not discarded for convenience.
33. As a Bend developer, I want two different schemas checked early, so that the API is not accidentally specialized to one demo.
34. As a project maintainer, I want every simplification recorded as a follow-up with a return condition, so that postponed scope is not forgotten.
35. As a project maintainer, I want native execution substantially faster than bevy-ts on equivalent representative workloads, so that low-level compilation delivers a meaningful benefit.
36. As a project maintainer, I want JavaScript execution at least comparable to bevy-ts, so that the JS backend remains practical.
37. As a project maintainer, I want reproducible timing, memory and scaling evidence, so that speed claims are based on equivalent work rather than different semantics.
38. As a project maintainer, I want laws describing exact results, preservation, bounds and helper behavior where applicable, so that trivial incorrect implementations cannot satisfy an incomplete specification.
39. As a project maintainer, I want laws falsified and explained before I approve them, so that ambiguous requirements are discovered before proof work.
40. As a project maintainer, I want proofs and meaningful mutation controls for approved laws, so that both implementation correctness and law coverage are examined.
41. As a simulation developer, I want a fixed-step console scenario with spawn, movement, damage, removal and events, so that the first slice has a visible reproducible outcome.
42. As a canonical-defense developer, I want integration tested on a separate copy while preserving the authoritative reducer, so that Bendvy can be exercised without changing the original project.
43. As a canonical-defense developer, I want system order, fixed-step behavior, linked work and cleanup considered during integration, so that the ECS does not bypass existing application contracts.

## Implementation Decisions

- The end goal is complete Bend-native coverage of the Rust Bevy ECS capabilities represented in the pinned bevy-ts core, plus only explicitly user-approved bevy-ts-specific extensions. "Full parity" means complete coverage of that agreed capability set through idiomatic Bend APIs; it does not mean reproducing every bevy-ts export, JS/TS integration mechanism or implementation detail. Feature inventory and acceptance tables must distinguish required Bevy capabilities, approved extensions and TS-specific items pending a scope decision. Contract decisions use this explicit order: **(1) Rust Bevy architecture and ECS semantics; (2) Bend's type system, affine ownership and runtime constraints; (3) bevy-ts as the feature inventory and porting inspiration.** Preserve Bevy's intended behavior through a valid, idiomatic Bend design. Where Bend requires an adaptation, explain the constraint and decide the observable contract explicitly. bevy-ts does not independently define our contract: its behavior is a third-priority reference only where consistent with the first two. A TS trace demonstrates TS behavior, not approval to copy it into Bendvy. API similarity and bug-for-bug TypeScript behavior are not requirements. Existing approved contracts remain binding; changing them requires an explicit decision and coverage evidence.
- **bevy-ts-specific features require explicit user agreement before implementation.** The pinned TS inventory, an existing parity ticket or the phrase "full parity" does not by itself authorize features unique to bevy-ts or its JS/TS ecosystem. First distinguish the underlying Bevy ECS capability from the TS-specific mechanism, explain its application value and Bend-native alternative, and agree whether it belongs in scope. Until agreed, mark it pending scope decision and continue independent approved ECS work. Standard Schema integration and the JS-to-Bend host bridge require this decision separately from Bend-native validation and typed construction; existing experimental work does not establish approval.
- Preserve the agreed ECS model: entities, components, queries, resources, declared system capabilities and controlled structural changes. Design representations for Bend's types, affine ownership and runtime.
- Begin with explicit typed world declarations, without a schema DSL or generator. Revisit declaration ergonomics after two schemas and a second application provide evidence.
- Require check-time rejection of undeclared component access, cross-schema misuse and writes through read capabilities. Positive examples alone are insufficient evidence.
- Data-only components have not been approved. Investigate Data and affine Type payloads, ownership-preserving access, update cost and rollback before choosing a restriction.
- Initial systems execute on CPU through a simple schedule; preserve an explicit follow-up for parallel execution. Sequential orchestration does not justify ignoring efficient storage or traversal.
- Define identity, reservation, liveness, query order and exhaustion behavior before fixing allocator/storage interfaces. ID reuse and physical layout remain technical choices subject to the observable contract.
- Approved identity divergence (2026-10-03): a handle originating in another runtime world must return `MissingEntity`, even when its schema and local entity ID match a live entity. The pinned bevy-ts reference can resolve that collision to the receiving world's entity; this behavior is intentionally not preserved. Cross-schema rejection alone does not establish same-schema runtime-world isolation. World identity must originate from world creation rather than caller-selected fixture constants. ID reuse, generation/exhaustion policy and the production representation remain unresolved; this decision does not approve candidate laws or pass T05.
- Define system transaction boundaries and read-your-writes before fixing write APIs. Failure preserves earlier committed systems and discards the failed system's ECS-owned changes and publications. Host IO is outside ECS rollback.
- Match explicit deferred barriers, independent reader visibility and the reference's skip/failure/lag semantics. Do not equate commit visibility with structural command application.
- Check composition and provisioning early enough to constrain the System/Schedule interfaces; complete their coverage in later core blocks.
- Investigate state-transition failure ordering and snapshot restoration boundaries before assuming whole-schedule rollback or full-runtime restore.
- Follow bend-ldd: candidate laws and plain-language rationale, falsification with a planted-defect control, human approval of specific laws, proofs, and mutation checks. Choosing this workflow does not approve future laws.
- Use the installed guide and pinned compiler/Base as the language authority. Reuse Base/mathlib facts where appropriate; mathlib is not a production-core dependency. Verify tool compatibility before adoption.
- Approved foreign-command result (2026-10-04): a structural command using a handle from another runtime world returns `MissingEntity` and leaves the receiver queue unchanged, including colliding same-schema entity IDs. Preserve receiver observations and test the actual command API. This does not imply an exception, automatic transaction abort, TS parity or new general proof approval.
- Each checker run is limited to five seconds. Timeouts require reshaping the statement or implementation, not increasing the limit. Proof completion requires successful verdict and mutation gates, with no silent skipped checks or unsafe/foreign proof dependencies.
- New project dependencies require approval when their concrete need is established. No dependencies are installed by publishing this specification.
- Low-level native builds must substantially outperform bevy-ts; JS builds must be at least comparable. Determine numerical native speedup and JS tolerance criteria from an agreed representative workload before closing performance acceptance. Do not invent a multiplier, average away material regressions, or require beating Rust Bevy.
- User performance clarification (2026-10-07): after implementing all features and full bevy-ts parity, an aggregate loss of up to10% against the optimized Bend version is acceptable, provided final JavaScript remains at least as fast as bevy-ts on equivalent work. The Native target remains at least2× faster than bevy-ts. This full-parity allowance does not select a new frozen comparator, amend the existing bounded #28 statistical contract, or approve a31% intermediate provider regression. Full qualification remains with #21/#23/#24; the precise full-parity comparator and measured protocol must be frozen before acceptance.
- Scoped #30 amendment approved on 2026-10-07: selected complete Workshop JS <= pinned bevy-ts and Native <= 0.5 * pinned bevy-ts replace its additional historical-Bend-baseline comparison requirement. Equivalent full observations and exact-source evidence remain mandatory. The default #28 statistical gate and full-core performance qualification are unchanged; historical failed receipts retain their original verdicts.
- The first application is a minimal fixed-step reproducible console CPU simulation: entities appear, move toward a goal, take damage and are removed; events report hits and deaths.
- The later canonical-defense check uses an isolated copy of relevant sources. The original project is never modified, a single shared code location is not required, and synchronizing the copy is not required. Preserve the authoritative reducer initially; migrating it is a separate conditional follow-up.
- Every simplification and unresolved limitation has an explicit follow-up, reason, status and return condition. Detailed planning advances only when its prerequisites have evidence.

### Execution sequence and acceptance

1. Establish the full parity matrix and pin references, compiler/Base and native/JS environments. Include postponed core and separately tracked platform features.
2. Specify observations for handles, commands, transaction boundaries, visibility, readers and failure; investigate upstream ambiguities instead of asking the user to supply discoverable facts.
3. Run small expressibility checks for two schemas, repeatable systems and negative access cases. Explore Data/Type storage access before choosing the supported interface.
4. Validate a minimal transaction/composition path: an earlier system commits component/resource changes; a later system reads its own writes, emits an event, queues a command and fails; its changes/publications are absent, the earlier commit remains, and its reader cursor has not advanced. A successful retry observes the expected data; structural work remains governed by markers.
5. Compare native and JS candidate storage/query/update paths with bevy-ts on equivalent workloads, including rollback and structural churn. Record scaling and memory, then propose concrete performance thresholds.
6. Present falsified candidate laws and proof sketches for approval. After approval, complete proofs and law-specific mutation checks; record the selected interfaces and any follow-ups.
7. Implement and verify the simple simulation against the chosen contracts. Expand lifecycle/streams, relations/scopes, states, composition/provisioning and tooling by dependency, retaining the full parity matrix.
8. Perform the copied canonical-defense integration when required capabilities exist. Optimize storage/cache and assess parallel compute using reproducible workloads and evidence.

The immediate agent-ready work is preparation and technical probes through candidate laws. Proofs remain gated by approval of those particular laws. A failed probe triggers redesign or an explicit requirement discussion, not an automatic scope reduction. The full runtime is complete only when core contracts, agreed proof obligations, performance criteria and explicit divergence records are resolved.

## Testing Decisions

- Prefer one highest-level runtime seam: operation traces submitted through the public ECS API, with normalized observable results. Reuse it for equivalence, regression scenarios and performance workloads. At specification creation there was no Bendvy implementation seam; current probes remain separate until their integration gate passes.
- Compare TS and Bend results for identical logical inputs and equivalent work. Exclude physical storage, allocation addresses and incidental ID encodings from observations; preserve liveness, membership, specified order, publications, state and failures.
- Add compile-time fixtures as a distinct necessary boundary for schema identity and read/write capabilities. Require rejection for the intended reason rather than an unrelated parse/type error.
- Good tests assert external behavior. Do not mirror storage algorithms or assert caches, journals, ordinals or particular layouts merely because the implementation uses them.
- Cover spawn reservation and flush, stale/foreign lookup, optional queries, lifecycle order, independent readers, different-rate schedules, skip/failure/lag, rollback, relation cleanup, state-transition failure and provisioning. Borrow contract scenarios from the pinned bevy-ts runtime and type tests; its headless scripted simulations are additional prior art.
- Falsify general laws using small inputs concentrated around valid premises and boundary cases. A passing finite test is evidence about those inputs, not a universal proof.
- For every approved law, require a meaningful compilable mutant, an instance true on the original and false on the mutant, a checking control and proof failure in the intended section. Investigate equivalent survivors and report coverage gaps honestly.
- Measure compiled execution, not checker normalization. Separate compilation/setup from steady-state runtime and report any included setup costs explicitly. Pin environment, inputs, compiler flags, worker counts and TS/JS runtime versions; warm up JS where appropriate, repeat measurements and report variability.
- Evaluate representative spawn/despawn, sparse and dense query iteration, component/resource update, structural churn, event readers and rollback workloads as capabilities become available. Include both reference-compatible and Bend-appropriate traversal strategies without changing observed work.
- Native significant-speedup and JS-comparability thresholds must be made quantitative before final acceptance. Record per-workload ratios and regressions; performance cannot be declared complete from a single favorable scenario.
- Memory measurements must state their method and limits; do not equate process peak memory with exact per-component allocation cost.
- Test the simple simulation by deterministic input/result traces. Later verify copied canonical-defense behavior at its integration boundary while preserving its authoritative reducer and leaving the original source unchanged.

## Out of Scope

- Porting the full Rust game engine, renderer, PBR, asset pipeline, audio engine or editor.
- Changing the original canonical-defense project, consolidating its code into this repository, or maintaining synchronization with the integration copy.
- Implementing a schema DSL, generator, full parallel scheduler or GPU ECS orchestration in the first slice. These have tracked revisit conditions rather than disappearing silently.
- Rewriting the canonical-defense authoritative reducer during initial integration.
- Promising unrestricted component payloads before language and ownership probes, or silently restricting the final core to Data-only values.
- Claiming speedup, complete parity, approved laws or checked proofs before the corresponding evidence exists.
- Proving host IO, backend code generation or all gameplay merely by proving the pure ECS model.
- Publishing packages or deploying a game as part of this specification task.

## Further Notes

The shared understanding from the interview is confirmed, with the final performance correction taking precedence over earlier measurement-only wording. This specification synthesizes the agreed scope; there is no additional design interview.

At creation, the repository contains research and planning documents only. Reference commits are pinned in the reference manifest; reference source checkouts are local and excluded from Git. Installed Bend was previously observed as 2.0.34; its compatibility and alignment with the pinned source must be checked again during environment preparation.

The issue tracker is GitHub Issues, the triage label is `ready-for-agent`, and the repository's primary branch is `master`. The primary testing boundary follows the previously approved plan: identical TS/Bend scenarios compared by observable behavior, plus negative compile checks for access guarantees. There is no request to approve a new internal testing boundary.
