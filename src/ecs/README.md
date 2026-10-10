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

`BundleRecovery.resume` (`bundle-recovery.bend`) explicitly retries a retained
`HeadPending` or `TailPending` restoration. It threads the World and all pending
owners through the existing reverse installation order. Repair the cause of a
refusal before retrying; another refusal returns the recovery owner again.
There is no automatic retry or disposal. The [independent recovery review](../../experiments/public-bundles/canonical-world-review-v1/RECOVERY-REVIEW.md)
records both branches, the reached control and exact public-source evidence reuse.
Combined156 protected regression passes; broader bundle acceptance remains #41.

`ordinary-bundle` derives component keys from ordinary typed declarations and
composes them into a recursive `Plan` matching the raw and cooked bundle types.
`request` rejects duplicate component keys before construction or command
queuing, returning the original owner and affine raw payload through the existing
refusal result. A caller can repair the request and retry. Plans are metadata;
they grant no World or storage access. The [independent review](../../experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/FINAL-REVIEW.md) verifies two schemas, full refusal/retry observations and authority controls, with explicit public-source reuse of private runtime evidence. Combined156 protected regression passes; full #41 acceptance remains pending.

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
instance and argument owners. The bounded #36 delivery is accepted; its finite executable controls and
independent review are recorded in `docs/reports/public-local-owner.md`. No universal proof/refinement or complete product
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
for the accepted bounded #47 delivery and source-bound controls. Full numeric
performance qualification remains under #21/#23/#24.

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

`OrdinaryMachineSchedule` (`ordinary-machine-schedule.bend`) installs an explicit
structural barrier followed by Apply, Exit, Transition and Enter groups. Closed
typed callbacks thread arbitrary affine owners and return existing system
outcomes; the schedule runner preserves its failure and world-rejection behavior.
The four group IDs are schedule adapter IDs, not registered gameplay authorities.
The finite installer does not supply machine initialization or handler lifecycle
implementation: those remain governed by #48/#49 and the
[current delivery index](../../docs/parity/README.md#current-delivery-coordination).

`ordinary-app-schedule` retains an ordinary `schedule-provision.Plan` with the schema App that owns its World and registered systems. Attach the operational Plan once; enabling debug makes snapshots derive the ordered steps and their declared requirements from that same Plan, alongside the App’s declaration-derived schema, accesses and values. Disabled snapshots bypass presentation. Invalid attachment returns the original App. Running uses the existing owner-preserving dispatcher, conditions and provision callback; finished, failed, rejected and missing results return the owned App. Existing provision checks run before the Schedule namespace check. The finite ordinary examples qualify these paths with Unit-output scheduled systems; they do not establish every automatic-debug category or full #56 completion.

`ordinary-app-machine.Application` binds an ordinary machine declaration and
renderer to an App. Use `install`, `read_app` and `queue_app` for normal operations;
reads and successful or failed transactions return the owned App. Enable debug
with `snapshot_app(app, flag)`, supplying the same ordinary type indices. The
library assembles the observer and rows; callers need no metadata list, separate
attachment or `Tree.observe_pair` adapter. `Recipe`, `ObservedRows` and
`observation` expose derived aliases for typed serializers. Disabled snapshots
skip observation. The [independent review](../../experiments/public-inspect/ordinary-machine-review-v1/ENTRY-FINAL-REVIEW.md)
qualifies direct CurrentView/read/queue paths and declaration association;
transitions, stream readers, broader debug categories and full #56 remain open.
Combined152 protected regression passes [independent review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt152-01/FINAL-REVIEW.md); full-feature performance remains separate.

`ordinary-app-relation.Application` uses one ordinary relation declaration for
inverse reads, `relate_app`, `unrelate_app` and `snapshot_app`. The library derives
query metadata and built-in direction/handle rendering; callers enable debug
without a separate metadata adapter. Queued writes retain existing transactions
and explicit barriers. The [independent review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-relation-app-v1/public-adoption-v1/FINAL-REVIEW.md)
qualifies direct operations, two schemas and finite owner/World noninterference.
Stream readers, full #56 and feature performance remain open.
Combined156 protected regression passes.

`ordinary-app-relation-system` registers a read-only inverse-relation system from
its ordinary declaration and target. `ordinary-app-relation-schedule` attaches
that actual Registry and World to their operational `schedule-provision.Plan`;
`snapshot(app, flag)` derives the relation query, registered access, cursor and
schedule phase without user metadata adapters. The finite entry uses Unit system
arguments/output and built-in relation rendering. Attachment rejects a Registry
from another World or with mismatched registration metadata. Dispatch rejects a
requested system ID different from the held Registry. Both refusals retain the
original owners. An unscheduled registration has an empty phase; disabled debug
skips observation. Snapshots preserve pending commands, events and cursors.
The [independent review](../../experiments/public-inspect/ordinary-relation-schedule-oracle-v1/FINAL-REVIEW.md) verifies the complete finite backend observations and authority boundaries.
Combined156 [protected regression](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt156-01/FINAL-REVIEW.md) passes. Broader automatic-debug coverage and feature timing remain pending; this entry does not complete #56.

`ordinary-app-stream` binds selected transition and relation-failure declarations once. `read_app` returns typed values with the same affine App; enabling debug makes `snapshot` derive their presentation from those declarations. Disabled snapshots bypass both projections. Frame/grant construction is internal; built-in values need no metadata adapter.

The [independent review](../../experiments/public-inspect/ordinary-stream-app-oracle-v1/FINAL-REVIEW.md) qualifies complete Workshop/Garden and reached-control JS/Native outputs. The inspector cursor remains independent of preserved NoticeReader/Registry owners; no new consumption policy or cursor association is selected. Additional owner runtime coverage is Unit; arbitrary Type preservation is source-checked. This module is excluded from combined156; its integrated regression and full #56 remain pending.

`ordinary-app-machine-handler` binds the operational handler Bundle, ordinary
machine schedule declaration and World once. `enabled(app, flag)` controls
`snapshot`: enabled snapshots derive typed entry names, access, requirements,
cursors and phases from those actual owners; disabled snapshots bypass
descriptions. Both Entry and Registry IDs are preserved separately. `run_app`
uses the existing ordinary handler dispatcher and returns its owned result.
Structural binding retains owners; execution rejects a foreign Bundle before
accessing the World. No user metadata adapter is required.

The [independent review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-machine-handler-app-v1/FINAL-REVIEW.md)
qualifies ten complete JS/Native outcomes, nominal/authority refusals, actual
foreign Worlds and a reached cursor mutation. Malformed-ID preservation is
snapshot-only; generic Extra preservation is source-checked. Full #56 and feature
performance remain open. Combined156 excludes this module and the later selected
stream App; their integrated regression remains pending in the next batch.

`ordinary-app-access.index` and `schema_index` derive an access index from the App’s sole operational registration fields when its existing debug flag is enabled. Disabled calls preserve App/World/owners without invoking the fold or value projection. Entries group by component/resource category and canonical key, retain real system namespace/id/name and original declared modes, and label Reader, Writer or Filter. Write denotes a declared write slot; With/Without are filter-only and Added/Changed are readers. Duplicate declared uses remain visible. Event origins, unique-system aggregates and a complete cross-schedule inventory remain separate coverage gaps.

Its [independent review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-access-index-v1/FINAL-REVIEW.md) verifies twelve complete JS/Native outputs, all seven query modes and authority controls. Integrated regression and full #56 remain pending.

`ordinary-event-declaration.bend` names a typed Data event domain once for ordinary read/write grants and registration. `ordinary-app-event-runtime.bend` starts from an existing schema App, moves its sole World into the event Runtime, and retains its registered owners and recipe. Writer/reader registration composes common access entries automatically, using actual system Registry IDs independently of Reader IDs. Enable debug and call `index` for grouped component/resource/event access without payload reads or cursor advancement; disabled indexing skips both folds. `with_previous` threads ordinary schema operations through the same Runtime World and retains existing `Ev.with_world` behavior; World pending events remain distinct from Runtime batches. [Independent review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-event-access-v1/unified-v1/FINAL-REVIEW.md) qualifies two finite nominal consumers, Data event failure/retry, authority boundaries and a reached category defect: six full JS/Native outputs, 15 commands/51 guards. Type events (#53), full #56 and integrated regression remain open.
