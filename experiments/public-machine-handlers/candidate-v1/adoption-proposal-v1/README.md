# #49 production adoption proposal — source only, unexecuted

Root owns src/ecs changes. These patches are review inputs, not applied or qualified production code. Existing finite JS/Native receipts retain their original source/import closure and do not qualify relocated modules.

| Patch | Public target | Exact baseline / dependencies |
|---|---|---|
| 01 | machine.bend | experiments/public-machines/machine.bend; Base, transaction.bend |
| 02 | machine-stream.bend | experiments/public-machines/stream.bend; machine.bend, event-runtime.bend |
| 03 | internal/machine-handler-events.bend | candidate event-stream.bend; event-runtime.bend |
| 04 | machine-handlers.bend | candidate handlers-tracked.bend; world.bend, system.bend, machine.bend |
| 05 | full fixture import migration | Full consumer/authority/negative roots use the proposed modules; bodies unchanged |

manifest.json binds every baseline byte hash and proposed module/import result. Patches 01–04 only relocate imports. Existing state.bend compare-set API stays separate. Existing event-runtime provides retention and tracked reader metadata; the two stream modules respectively carry typed transition events and the handler fixture’s Data event values. internal/machine-handler-events is an INTERNAL low-level Data metadata helper for this handler integration, not the general #53 public event API. It does not establish arbitrary Type event ownership, fan-out, retention or capture policy; those stay with the approved event capability contract. The helper remains private to trusted handler integration. Its raw U32 reader operations do not consume Reader<S,M> or validate namespace; the consumer must validate the affine reader and world namespace before calling them. Capacity and skip choices remain the existing fixture assumptions, not new public policies. Do not export or re-export these raw operations as a general event API.

Public generic surface (patches 01, 02, 04): machine Slot/Pending/Snapshot/Family/current/next projections and transaction writes; machine transition Stream/readers under existing trusted consumer binding; handler Phase/Invocation, affine Entry/Owners, HandlerResult, and run. Handler owners carry real Sys.Registry including runner identity and tracked cursor. C and R remain arbitrary Type; metadata/event/state values remain their existing Data restriction. Low-level helpers are inherited unchanged, not newly authorized capabilities. Consumer chooses registration names, declared access, phase-list order, matching predicates and trusted take/put/publish functions.

Fixture-only: SchemaA/B, Store/Resources, Flow/Level tokens/enums, demo events, trace and rendering, finite failures, Array clone inverse, trusted Local Aux indexing and resource providers, full-marker's two-machine loop. Do not adopt full-provider/context/actions/locals/marker as universal public APIs. In particular, cloned Data snapshots only implement the controlled whole-marker mutant, never an arbitrary Type cloning contract.

Boundary behavior is unchanged: Sys.run_tracked validates actual registry/world before runner/Local access and preserves Failed cursor semantics. Each callback owns its Tx and deferred commands; earlier committed handler effects survive later failures. Exit/transition failure requeues into current real world; successful transition commits/publishes before enter. Enter failure preserves published state without automatic retry. Local cells persist through gameplay rollback and remain separate per registration in the fixture. General Local storage ownership and arbitrary captured closures are not introduced by extraction.

Affected gates after applying patches to a fresh immutable root closure:

1. Source controls: full-authority-positive.bend; full-foreign-controls.bend and all four full-negative-{owner-duplicate,cross-schema,write-through-read,undeclared-next}. Preserve exact intended diagnostics and matched positive siblings; IO roots are typing evidence, not safe proofs.
2. Full unchanged TS-v3 / independent normal96+12 comparator on actual generated JS; full foreign7 rows/schema. Do not substitute bounded72. Existing selected reference manifest/guard remains pinned.
3. Normal Native nominal A/B full48+6 each and unchanged96+12 byte union. Use existing smaller roots, not previously timed-out combined specialization.
4. All three controlled semantic mutants, actual full96+12 JS and Native independent variant oracles. Rebase their exact handler/machine import patches onto the proposed modules in a frozen stage; no old receipts silently attributed to new sources. Native use original successful nominal/phase/single-predicate partition mapping, including premature B enter0/1.
5. Paired regression workload gate required for executable src/ecs adoption, unchanged workload/baseline; final full-core performance remains separate.

Before any backend: root selects patch boundaries, freezes complete current core/import/tool/library/config/discovery/environment/stage source closure and concrete bounded plans. Source/core drift invalidates reuse. Historical emitted C cannot qualify changed import closure without reviewed source/emission bindings. No new laws/contracts/proofs/dependencies or numerical limits are proposed here. API/package review must explicitly assess constructor exposure and trusted provider authority against existing public conventions before claiming ergonomic completion.
