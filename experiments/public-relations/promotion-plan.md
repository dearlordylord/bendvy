# #42 minimal production promotion proposal

Draft for integrator coordination, not approval or completed delivery. Existing `src` remains unchanged. The earlier six-suite replay is historical after the coordinated core batch. Current experiment-local candidate slices against that core are indexed in `production-candidate-v5/evidence/aggregate-candidate.json`; independent review verified their exact source and packaging. Production promotion still requires integrator batch coordination and fresh actual adopter gates.

## Module split

1. `src/ecs/relation-types.bend`: nominal schema-bound ordinary/hierarchy descriptor types, authoritative edge/inverse graph and exact mutation/failure records. No edge payload or exclusive-incoming feature. Bind descriptor key/name validation to actual schema-fragment registration; keep registry declaration order for cleanup.
2. `src/ecs/relation-graph.bend`: promote maintained graph operations without the slow oracle. Relate replacement, unrelate, outgoing/incoming selection and nominal hierarchy reorder retain observed validation priority and inverse arrival order. Independent models remain experiments.
3. `src/ecs/relation-commands.bend`: generic `RelationStore<S,C:Type>` embeds complete application component pack plus Data graph. Namespace-only queue admission preserves approved foreign rejection/unchanged queue; actual application validates liveness at FIFO position. Wrap existing Tx/World/Commands, retaining arbitrary Resource/Event and all original returned owners. Failure integration must use actual descriptor-keyed reader-domain plumbing, not promote experiment cumulative telemetry as equivalent.
4. `src/ecs/relation-providers.bend`: descriptor-bound read-only inverse/outgoing access and declared write requests supplied to rank2 abstract-owner bodies. Returned immutable Data handle snapshots preserve schema+namespace. No public writable inverse capability. Retest undeclared, cross-schema, write-through-read and owner-clone controls on actual production registrations.
5. `src/ecs/relation-cleanup.bend`: generic entered-frame interpreter accepts application component-clear callback, retains complete removed owners/notices, descriptor order and duplicate entered-frame despawn effects. Integrate the actual existing command despawn path; liveness-only deletion is insufficient. Nominal hierarchy reorder may remain a separate small adapter in this module or a sibling module.

## Required adopter changes

- Application world creation uses shared affine Factory threading and `RelationStore` around its arbitrary component family; resources/events remain generic. Independently rooted Factory collision stays #38's known failed capability, not a reason to stop relation implementation.
- Schema construction provisions actual relation descriptors and declared read/write capability bundles before registered System execution. Preserve existing component provider APIs and do not substitute fixed demo arity.
- Registered gameplay calls actual deferred relate/unrelate/despawn/reorder through supplied opaque providers; existing System failure discards queued effects. Future reserved entities are validated at actual command application, not rejected because they are not live at enqueue.
- Query adapters compose outgoing/inverse required/optional and with/without selections with existing component selection/getters. Current finite inverse snapshots do not yet implement the complete public query surface.
- Reader-domain integration supplies descriptor-keyed mutation-failure reader composition/retention; cumulative experimental event arrays are only trace evidence.
- Component cleanup adapter receives only the arbitrary-Type component pack C and a schema-bound handle, consumes each removed owner and threads the complete surviving pack plus notices. It receives no outer relation graph, whole World or liveness carrier, so topology/live creation is structurally unavailable through this callback. Preserve original clear/removal semantics and entered-frame callbacks; do not replace them with metadata deactivation.

## Decisions before source changes

- Cleanup completion: `cleanup-progress.md` provides a source-backed conservative structural bound and finite falsification, including an actual accepted219-step witness. Use the reviewed automatic structural budget in candidate V5: shrinking original edge/descriptor lists and node counters, only drive1/2/3, one affine cleanup state and Complete short-circuiting. A scalar Nat product is rejected because emitted Nat is48-bit. Actual219-transition completion and the legal131072-count representation/old-overflow mutant are delivered as distinct reviewed finite slices. Diagnostic128 does not force a novel public pause/resume policy. No visited set, cycle rejection or universal proof is inferred.
- Failure-channel/reader-domain API shape must be coordinated with #35/#44. Exact observed mutation policy is already source-backed; stream retention and registration composition require actual adopter controls.
- Trusted descriptor registry identity/validation and relation-query registration hooks require integrator agreement on the source split. Existing exported constructors do not establish universal authority.

No new numerical threshold, dependency, ECS law or proof is proposed. Finite production-adopter traces, fresh reached mutants/access controls, independent source review, default regression and equivalent-feature performance remain required before claiming #42 complete.

## Next coordinated implementation batch

Promote the current generic candidate modules, not the fixed O.Components fixtures. Retain `relation-reorder-core.bend` plus `relation-reorder.bend` as separate siblings initially to avoid changing their audited nominal hierarchy/access boundary during cleanup promotion. Replace only experiment-relative imports with the actual local production modules; preserve rank2 headers and generic S/C/R/E parameters. The initial adopter must exercise both nominal schemas with complete arbitrary-Type payload packs, actual registered providers, deferred FIFO/barriers, component clearing and rollback/failure observations. Integrator owns shared indexed/lifecycle, schema, reader-domain and query changes; this worker has not edited those modules.

The graph outer-list stack repair preserves survivor order with tail accumulators and one reverse. Unchanged helper families have no broad stack-safety credit. Invalid registry/topology premises still retain an incomplete owner/continuation diagnostic; no public pause policy or universal proof is inferred.

## Current staged Query implementation

`promotion-stage/modules/relation-query.bend` is the eighth additive module. An arbitrary-length nominal descriptor requirement list composes Required/Optional/Present/Absent outgoing and incoming selection with an actual core component/family selector. The caller's component pack remains Type; projected views and immutable relation snapshots are Data. Closed rank2 read clients receive an abstract owner and only ValueRead for their provisioned row. This does not establish universal authority for exported raw constructors or arbitrary trusted provisioning functions.

The initial concrete staged application calls core Q.selected and Cmp.tx_get, registers its actual read systems, checks ten specs in two schemas, and retains all depth0..3 payload arrays. A fifth live entity has a relation but no component: required component selection excludes its row while incoming snapshots still include its source handle. Source-bound lifetime/pre-barrier/foreign cases, full affected adopter coverage, keyed failure publication and equivalent-feature timing remain mandatory, not optional follow-ups. See the staged Query law candidates and complete-feature timing plan; neither is an approval or proof.
