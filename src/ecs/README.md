# Explicit typed ECS application API

This is the explicit typed API extended in #26 and #27. It supports caller-authored component
families and closed, repeatedly executable gameplay callbacks. It is not full
Bevy parity or a qualified performance claim.

Declare a nominal Data schema token and family tokens. Declare an ordinary
affine Store containing `Column<Schema,Component>` fields. Components can be
affine Type (including actual owned Arrays) or Data. Each family declaration
supplies closed `take`, `put` and ownership-preserving Data `project` functions.
`Family` indexes those functions and the component/view types. Schema-local
wrappers can bind the repeated template arguments; no generator is required.
Lenses and bundle population/cleanup are trusted provisioning declarations.

`Feature` (`feature.bend`) composes recursively typed feature owners and builder
callbacks using `FeatureOwner`, `recipe_empty` and `prepend`. `run_recipe`
validates selected names, dependencies and fragment collisions before running
builders in selected order. Refusal returns the original context and recipe;
success returns arbitrary affine extras and separate bootstrap/update plans.
Run these phases as separate schedules, threading returned World and registry
owners between them. Repeated references to the same dependency are permitted.
`FeatureProvision.bind_feature` (`feature-provision.bend`) checks declared needs
against the feature's own fragment and dependency closure; identical descriptor
entries collapse for grants, while conflicts remain errors. Raw metadata,
recipes and closed builder/getter declarations are trusted authoring operations.

Create application worlds with `WorldIO.create` from `world-io.bend`. Its IO
allocator shares namespaces across canonical creations in one emitted program.
`Created` returns the World; `Refused` returns the original affine resource.
Handles carry the resulting namespace and local ID. Foreign handles reject
before access/queue mutation even when local IDs coincide. Namespace allocation
saturates: 1 through 4294967294 succeed, and exhaustion refuses without reuse.
Separate programs, bundles, realms, workers and processes have no shared allocator.
Raw World/Handle constructors, `World.create_checked`, legacy `World.Factory`
and `World.create`, and `WorldIO.with_namespace/convert` remain trusted setup
operations. They can bypass canonical provenance; this is not language-wide
constructor confinement or a proved concurrent uniqueness guarantee.
The bounded allocator uses monotonic IDs, no reuse and a 131072 entity limit.
Production capacity/growth and exhaustion policy remain full-core follow-ups.

Use `Compose.each` with a closed `Plan{caps,select}` and an ordinary caller-defined
`Ops(H)` record. Each field selects an independently typed read/write/optional
capability; the library has no main/aux or fixed tuple-arity limit. `family_match`
and recursive `both` compose required, presence and absence requirements
independently of granted operations. `all` supports empty selection. Optional
reads return `Component.Access` without requiring presence. The Workshop
[declarations](../../examples/query-composition/declarations.bend) show reusable
schema-local binding helpers and named capability records without a generator.

Gameplay is checked for arbitrary affine H and receives only its declared
operations. Thread H through every call; closed getters can run repeatedly.
Aliases of the same component share the current storage through this one owner.
Replacement consumes actual C: Type and journals its old owner for rollback.
Read-only fields have no setter. Resource, event and command operations are
separate opt-in fields. Caller-defined Ops and closed adapters are trusted
provisioning; arbitrary type constructors are not a universal authority theorem.

`Compose.each_since` combines `lifecycle_match(Added/Changed)` with structural
predicates using a runtime reader cursor and authoritative typed column stamps.
Reads leave stamps unchanged; equal-value writes count as changes. Transaction
failure restores old payloads and stamps. The existing two-family `Query`
entry points remain available for earlier consumers; use Compose for new general
selections.

Bind a closed query runner to a caller-authored rank2 gameplay body, then call
`System.register`. Registration returns the World and an affine
`Registry<...,runner>` owner. `System.run` threads that exact owner through each
invocation and retry; changing its runner index is a type mismatch. Namespace
and exact metadata are checked before execution. Runtime captured affine callbacks remain a follow-up. `Schedule` provides authored static heterogeneous steps, read-only conditions, phases and explicit barriers; closed dispatch retains the registered instance owners.

The query executor owns one transaction across its selected callbacks.
Success publishes events and queues commands; failure restores its own writes
and discards its own tentative events/commands, preserving earlier commits.
Spawn reservations consume IDs even on failure. `World.barrier` applies commands
explicitly; schedule completion does not flush. Schema cleanup on public
despawn releases all component owners. `Structural` queues independent family
insert/remove operations with validation before queuing and at application.

`System.cursor` reads the current cursor while returning its registry owner.
Use `System.run_tracked` for lifecycle readers: success consumes the authoritative
post-run clock, including the system's own writes; failure/refusal retains the
old cursor. `System.run_to_cursor` remains an explicit caller-supplied cursor
operation for existing consumers.

`Events.create/read` retains its legacy append-only interface. `EventRuntime`
adds registered readers, bounded whole-batch retention and lag reporting against
the actual World event log. Reader failure preserves its position; an accepted
condition skip advances to the current tick without reading. `Removals` uses a
separate typed removal domain, preserves its cursor on skip and retains backlog until reader disposal;
observed Structural/Commands hooks publish metadata at the explicit barrier.
Affine event fan-out and composed event/removal provisioning remain follow-ups.

`QueryContract` adds count/single/get and exact typed error diagnostics over
caller-defined Compose selections. `OptimizedCompose` optionally prepares typed
column owners and always recovers them after the transaction; reverse access and
growth retain safe fallback. Caller-provided Store preparation/recovery is a
trusted schema adapter, with generic Type component payloads preserved.

`OwnedCompose` offers an additive provider for a caller-defined row owner `H`.
Selection still runs on the original Frame; closed enter/leave adapters move and
restore actual family owners around the same abstract gameplay body. Use its
direct closed-field entrypoints to declare capabilities, selector and adapters
without repeated runtime Plan projection. Existing Plan entrypoints remain usable.
All owners return before transaction completion, including failure. Adapters and
raw captured-row constructors are trusted provisioning, not opaque authority;
rank2 gameplay retains its abstract context. Current finite controls pass, while
the selected provider's performance acceptance remains pending.

`System.identity/dispose` exposes instance identity and checked unregistration;
rejected disposal returns the original owner. `Local` threads a separate affine
state owner for each registered system instance. Skip preserves that state;
changes returned by a failing system persist while its ECS transaction rolls back,
as explicitly approved. Rejected foreign execution/disposal returns the original
instance and argument owners. Finite executable controls pass; final shared-source
delivery remains pending. No universal proof/refinement or complete product
performance qualification follows from these finite compiler/application tests.

`SchemaFragments` (`schema-fragments.bend`) combines schema-indexed declaration
metadata and recursive affine owner packs. `merge` validates the left fragment,
the right fragment and then their combined declarations; conflicts remain local
to component/resource/event/relation/service kind. Refusal returns both owner
packs. `bind_declared` validates all initializer requirements before handing
owners to the closed setup initializer. Manifests and initializers are trusted
schema-author declarations; gameplay continues to receive abstract declared
capabilities. See the two independent applications in
[`public-schema-fragments`](../../experiments/public-schema-fragments/README.md).

`ScheduleProvision` (`schedule-provision.bend`) adds nested metadata flattening,
ordered requirement union and pre-execution provisioning checks. `ReaderDomains`
(`reader-domains.bend`) transports ordinary event and removal logs separately
while retaining real event ticks and reader cursors. Their composed public
applications and current delivery limits are recorded in the #34/#35 experiments.
Full-core performance qualification remains under #21/#23/#24.

`State` (`state.bend`) provides generic component-state comparison, legal typed
transitions and caller-defined raw decoding. Consumers declare their finite
value/move vocabulary, equality and endpoints. The owner context remains
arbitrary affine `Type`; neighboring components need not be Data. This is entity
component state; global scheduled machines belong to #48.

State writes require a `Cap.Request` returning `WriteAccepted` or the actual
`WriteRejected` error. A `Cap.Write` returning its owner alone does not establish
write success. `compare_set`/`transition` preserve mismatch, missing-entity and
absent-component distinctions; raw setters return the supplied raw value with
decoder/write refusal. Local acceptance still does not commit its surrounding
transaction. Equality, endpoints, decoder and closed checked-write adapters are
trusted consumer declarations. See
[`public-component-state`](../../experiments/public-component-state/completion.md)
for source-bound controls and remaining #47 delivery gates.

`MachineHandlerBundle` (`machine-handler-bundle.bend`) assembles arbitrary nested
typed exit/transition/enter registrations. It flattens authored order, validates
the world namespace and the stable union of all authored requirements (including
inactive entries), selects matching phases, and calls the existing handler kernel
once. Every registry and affine Local owner is returned on success or refusal.
Requirements, equality, frame adapters and transaction inverses remain trusted
closed author declarations. Raw partitions are trusted constructors.
The [current qualification](../../experiments/public-machine-handlers/candidate-v1/bundle-v1/delivery-relocated-v1/REPORT.md)
and reached JS/Native mutations establish finite application coverage; full #49,
#48 policy, universal bundle laws and feature-specific timing remain separate.
