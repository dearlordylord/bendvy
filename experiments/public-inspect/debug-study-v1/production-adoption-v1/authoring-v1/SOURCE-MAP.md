# Generic declaration authoring — source preparation

This is preparation, not relocated API or runtime qualification.

`definition.bend` retains schema-local nominal component/resource/event/machine/relation/service/condition tokens. Pure label functions produce descriptive strings. The same retained definition supplies registration metadata and resource/service provisioning requirements; names grant no authority. Query matcher requirements remain separate from Check runtime preflight. Machine tokens are not silently recast as SP resources. Condition callbacks/requirements are not introspected.

`registered.bend` is a low-level trusted schema adapter: its caller supplies pure name/access/metadata and nominal resource/service bindings. It preserves that selected binding, but cannot prove that arbitrary projections truthfully describe an opaque physical capability body. Safe application authoring uses closed canonical factories (Application.name/access/metadata/resource/service); end users do not choose those projections. Existing physical capability providers, not descriptions, enforce read/write and abstract-handle boundaries.

`registered.bend` threads the real affine System.Registry with its schema-matched declaration, actual namespace/id/cursor and observation. `schedule_entry` uses that actual id, the same declaration's resource/service requirements, and an explicitly authored condition-id binding. Empty condition lists and id zero are the concrete scenario here; this is not a general When facade.

`multi-registered.bend` creates three actual registered owners: two independently registered Reader instances sharing a label, and Writer. Main and again own disjoint instances. Main includes both deferred markers and an empty-target applyStateTransitions marker. All registration and schedule build failures retain the World and every already registered owner. No owner is cloned or stored in detached descriptions.

The independent `ORACLE.json` and pinned TS `reference.ts` cover duplicate display labels/actual object identities, marker positions, distinct system entries versus access-index Set names, read-before-write lint, and complete naming-map replacement. They were authored before runtime execution. Reference assertions use complete type-sensitive DTO equality and retain before/observed/after snapshots before assertions.

Source derivation:

- pinned `packages/core/src/internal/debug.ts:156`: schedule collection deduplicates actual schedule objects;
- `internal/debug.ts:236`: placements keyed by actual System objects, preserving distinct identically named definitions;
- `internal/debug.ts:255`: resource access indexes use system display-name sets;
- `internal/debug.ts:375`: read-before-write ignores non-system markers, so the independent main lint is required;
- `packages/core/src/Runtime.ts:1970`: nameSchedules clears the complete previous naming map before installing new entries.

Development source checks currently cover generic definitions, registration, and concrete multi-owner schedule construction only. They establish no output evidence, proof, optional condition policy, generic service capture, graph traversal/cycles or published formatting contract. Owner-returning scheduled views, complete physical World snapshots with actual namespace, full Registry/Provisioned owner before/after snapshots and the full DTO consumer are now connected in source; real IO bootstrap remains unexecuted before reviewed IO/JS/Native qualification. The six pure proposed modules remain candidate files, not adopted production API.
