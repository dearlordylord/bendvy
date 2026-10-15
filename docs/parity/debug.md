## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An ordinary ECS application user enables debug. Structure, declared access and schedules derive from the application's ordinary ECS declarations, without repeated descriptions or user-written metadata adapters. Additional presentation functions are allowed for opaque user values. Debug preserves ECS behavior.

## Acceptance criteria

- [ ] Demonstrate an ordinary public ECS application that only enables debug: existing component/resource/query/system/schedule declarations supply structure, access and schedule descriptions. No parallel metadata declaration or manual metadata adapter is required from the application user; opaque-value presentation functions are allowed.
- [ ] Determine feasibility against the pinned Bend compiler/runtime and public ECS declaration model, with Rust Bevy as the architecture authority and bevy-ts as the feature-scope reference. The low-level metadata candidate alone does not fulfill this requirement. If automatic behavior is technically impossible, mark #56 as skipped with a precise source-backed obstruction. Missing plumbing or implementation difficulty alone is not impossibility.
- [ ] Inventory pinned description/lint/access-index/population/dump/naming formats and execute complete public observations including graph, machine and transient/plain values.
- [ ] Repeated descriptions and dumps neither register/advance readers nor retain events, mutate owners or flush pending work. A dump is not a restorable snapshot.
- [ ] Disabled debug performs no description work; measure enabled overhead separately. Reject foreign/schema misuse and detect a reached filter/noninterference mutant.

## Blocked by

- #55

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current ordinary entrypoints and remaining coverage

Source status follows the actual consuming App and complete source-bound evidence,
not the historical low-level metadata prototype. Reference pins remain Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
`a950fd683c0d76f09794078e6174fe98a1492876`, and bevy-ts
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334` in
[the manifest](../../.references/sources.json). Bevy retains system access through
`SystemParam::init_access` and exposes `System::name` and
`Schedule::systems_with_access`; this supports deriving descriptions from real
operational declarations. It does not require copying TS Debug formats or reader
behavior. Bend descriptions must derive only on enabled snapshots and return the
actual affine App/World owners.

The earlier statements that resource App observation, per-resource confinement,
operational Plan retention, or machine/relation App bridges were all absent are
historical. Current public slices are:

| Actual ordinary user entry | Implemented and qualified scope | Remaining boundary |
| --- | --- | --- |
| [Schema App](../../src/ecs/ordinary-app-schema.bend), [schema product](../../src/ecs/ordinary-app-schema-product.bend), component/resource/selected-field registration and generated owner fold | One ordinary declaration supplies schema key/order, binding/access/clauses and typed value projection. Enabled snapshots derive bindings from sole operational Fields; disabled snapshots bypass descriptions. Complete mixed Array owners, direct registered success/rollback/retry, rejected-App retention and reached cursor filtering have source-bound evidence; [public adoption review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/FINAL-REVIEW.md). Selected field writes protect undeclared siblings under #70. | Finite reusable schema products and registered owners do not establish a general full-schema Debug format or arbitrary-arity compiler feasibility. Direct registered calls are not Schedule dispatch. |
| [ordinary-app-schedule](../../src/ecs/ordinary-app-schedule.bend) attach/run/snapshot | Retains the actual operational Plan, per-step requirements, lowered steps and name. Genuine run reaches provision then Sch.run; complete normal, missing/refused-owner, callback-failure, namespace rejection and invalid-attachment recovery evidence is retained. | Finite Unit transport and trusted dispatch/provision conventions remain explicit; condition IDs exist but condition names do not. |
| [ordinary-app-machine](../../src/ecs/ordinary-app-machine.bend) install/read_app/queue_app/snapshot_app | Name and Current/Unavailable view derive from the same ordinary machine declaration; library supplies observation wiring. [Public entry review](../../experiments/public-inspect/ordinary-machine-review-v1/ENTRY-FINAL-REVIEW.md) covers full enabled/disabled/read/queue observations and affected authority. | Finite supplied vocabulary is adopted below; legacy declarations leave exhaustive vocabulary unspecified. Arbitrary Data enumeration and full scheduling/composition remain unqualified. |
| [ordinary-app-relation](../../src/ecs/ordinary-app-relation.bend) and [registered relation schedule](../../src/ecs/ordinary-app-relation-schedule.bend) | Same declaration supplies relation kind/name/inverse query and presentation. Actual operations/barriers and registered schedule/cursor/phase associations have complete public nominal and reached-control evidence; [registered review](../../experiments/public-inspect/ordinary-relation-schedule-oracle-v1/FINAL-REVIEW.md). | Selected relation views do not establish a generic all-relations World dump. |
| [ordinary-app-stream](../../src/ecs/ordinary-app-stream.bend) read_app/snapshot | Selected transition and relation-failure grants derive from ordinary declarations; enabled/disabled snapshots preserve independent reader/Registry owners. [Complete finite review](../../experiments/public-inspect/ordinary-stream-app-oracle-v1/FINAL-REVIEW.md) covers both schemas and reached control. | No new reader-consumption/cursor association policy; integrated regression and full feature timing remain separate. |

The [ordinary machine-handler App](../../src/ecs/ordinary-app-machine-handler.bend)
is adopted after [one independent final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-machine-handler-app-v1/FINAL-REVIEW.md).
Its normal and Other schemas, actual foreign Worlds, distinct Entry/Registry IDs
and reached cursor mutation pass ten complete JS/Native outcomes, with 25 commands
and 85 unchanged guards. The same operational Bundle and ordinary schedule
declaration supply descriptions; disabled snapshots bypass them. Binding retains
owners structurally, while execution applies the existing namespace refusal.
Malformed-ID preservation is snapshot-only; InternalOwnerRemainder remains a
source-retained path. This finite slice does not complete #56 or feature timing;
its combined regression is pending.

### Concrete unqualified debug operations

These are existing #56 inventory gates, not new contracts or a parallel fixture
plan. Pinned TS `Debug.ts` describes their feature categories; Rust Bevy remains
the semantics authority and exact shared scenarios must be agreed and executed.

| Operation still lacking a qualified ordinary entry | Actual available source/evidence | Existing #56 gap |
| --- | --- | --- |
| Full static description with Plain/Transient/Constructed classification and complete declared event/service/machine-state inventory | `ordinary-app-schema.snapshot` returns ordinary Fragment entries; `ordinary-app-description.bindings` derives runtime bindings. Ordinary classified component/resource provisioning now derives Plain/Transient/Constructed entries from the same indexed operational persistence extension; bare declarations remain unclassified. Finite supplied ordinary machine vocabulary is adopted; legacy declarations leave it unspecified, and Current/Unavailable retain their shapes. Selected stream/relation descriptions cover bounded views. | Connect the existing persistence/full inventory at ordinary declaration seams and qualify complete presentation, without a second user metadata declaration. |
| Global readers/writers access index and schedule lints | Actual Fields contain names/access/cursors/clauses; Schedule descriptions retain Plan/steps/needs. These are per-owner/per-schedule facts, not a cross-schedule index or linter. The ordinary component/resource/event index is now adopted for the qualified same-World App; cross-schedule inventory and schedule lints remain unqualified. | TS inventory includes component/resource/event readers and writers and event/next-state/component/read-before-write lint categories. Qualify retained diagnostics only from real declarations and approved native semantics; exact historical TS lint rules/messages are not newly approved by this inventory. Metadata alone is not authority. |
| General custom-store population adaptation | `world.handles` returns alive handles; `column.has` checks membership while restoring arbitrary affine payloads. Ordinary bindings retain typed storage lenses, while Schema entries retain only names/order. An all-schema closed population fold must therefore be generated at ordinary provisioning, including unqueried zero-count components; resource leaves are excluded. Ordinary Column/Product provisioning now generates this traversal and passes the bounded population packet; general custom Store lenses remain unqualified. | Preserve the adopted ordinary Column/Product entry and qualify any general custom-store adaptation at its actual typed lens boundary; fixture arithmetic is not a production entry. |
| Generic filtered complete dump by entity IDs, component conjunction and limit, including transient/plain values | Adopted ordinary Column/Product dump derives presentation from operational declarations and supports native typed entity IDs, component conjunction and Nat limit. Six full JS/Native outputs and a reached conjunction control preserve all 66 physical observations per consumer; resources remain global. | Direct event RuntimeApp population/dump and detached RuntimeView with U32 presentation are adopted. The retained ordinary composed packet already combines declared machine vocabulary with classified custom-store values and a limited dump on one World; its precise historical/current-source qualification is recorded below. General opaque presentation and mixed relation/registered-reader composition remain open. Preserve World, owners, runtime ticks, readers and pending work. Dump is not a restorable snapshot. |
| Debug naming/placement inventory and naming replacement | Ordinary schema names default to keys; actual Registry names and attached Schedule names/IDs are exposed. There is no `nameSchedules`-style renaming table or full placement/condition-name formatter; the operational declaration does not retain condition names. | Reconcile pinned naming formats with existing operational names and approved semantics; do not infer TS renaming or invented names from IDs. |

The [ordinary composed delivery](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/DELIVERY.json) and [independent review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/FINAL-REVIEW.md) retain eight complete JS/Native observations of one World: the same machine declaration supplies `Mode` vocabulary `[3,4]`, while operational provisioning supplies classified custom-store/schema presentation and a limit-one dump. Enabled, repeated, disabled and post-schedule checkpoints retain complete physical observations. This covers the finite machine/custom-store composition already exercised; it does not cover entity/conjunction filtering in that consumer, mixed registered readers, or general opaque presentation. The first matching JS/Native output is 18,011 bytes, SHA256 `512e6d8b9c4c9d02a6a4d21b22b0c2ead1ea1fda1e3f136cd6f10e39a1ad481d`.

The original runtime closure has 95 source pins. Its retained consumer and independent model still match; 93 source bodies match current files. The two changed public bodies are `ordinary-app-registration-fields` (additive `EventKind`) and `ordinary-app-description` (the corresponding retained-clause branch). Existing Component/Field/Service/Resource branches are unchanged, and this consumer registers no event reader. The [current-source qualification](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/current-source-v1/DELIVERY.json) reruns these unchanged ordinary entries against their current closures: all four positive source checks, eight complete JS/Native outputs and seven existing authority refusals pass (31 commands, 106 guards). The private `Family.enabled` fault rejects the matching complete normal output at byte 10,677 on both backends, while all four complete physical checkpoint strings remain identical. Historical receipts retain their original bindings; this packet supplies fresh current execution rather than transferring that credit.

Machine inventory covers the ordered finite vocabulary supplied by the ordinary operational declaration, including unused declared values, plus Current/Unavailable. Pinned TS `Machine.ts:308–322` retains that vocabulary and `internal/debug.ts:341–345` exposes it; Rust Bevy `States` supplies no exhaustive-value enumerator. The adopted Bend declaration retains supplied finite vocabulary with the same name and current-state machinery. Legacy declarations remain unspecified, and arbitrary Data enumeration is unqualified. Existing #48 queue semantics remain unchanged; the inventory does not impose vocabulary membership on queued states.

Descriptions remain enabled-only; test-only physical owner probes may run while
debug is disabled but are not production descriptions. Finite full before/after
traces and reached mutants establish their stated preservation scope, not
universal noninterference of arbitrary trusted projections. The retained full80
prototype and independent TS metadata studies remain reusable historical evidence,
not substitutes for these ordinary entries. Full shared TS Debug comparisons,
enabled-overhead/feature timing and scaling remain under #56 and #21/#23/#24;
protected default #28 success qualifies only its unchanged workload. No compiler
timeout or missing plumbing establishes technical impossibility.

### Adopted ordinary access index

`ordinary-app-access.index`/`schema_index` derives component/resource Reader, Writer and Filter uses from operational fields, retaining original modes and actual system identities. Debug disabled preserves affine owners and skips presentation. [Final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-access-index-v1/FINAL-REVIEW.md) covers twelve complete JS/Native outputs, seven query modes, two schemas, authority refusals and a reached grouping defect. Same-World Data-event origins and ordinary Column/Product population are adopted below. Type-event origins, cross-schedule access/lints, custom-store population, full dumps and integrated regression remain open; this does not close #56.

Historical preparation at `9611c7f8c` added the common `Events` category. The earlier event-only 37,423-byte pair and component/resource access-index packet retain their original source bindings; the adopted same-World successor is qualified below.

### Adopted same-World Data event access

The [ordinary event Runtime App](../../src/ecs/ordinary-app-event-runtime.bend) derives event access from the same typed domain that supplies grants and registrations, composing it with the prior SchemaApp generated fold. [Final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-event-access-v1/unified-v1/FINAL-REVIEW.md) qualifies six complete JS/Native outputs, two nominal schemas, four actual `with_previous` operations, 19 event phases/76 snapshots, six authority refusals and a reached category defect. The public three-module relocation is exact. These current observations qualify the additive common Events category; older packets retain their own source bindings. Type events, full static/cross-schedule inventory, lints, custom-store population/full dumps, integrated regression and feature timing remain open. The ordinary Column/Product population slice is adopted below.

### Ordinary population adoption

[Provisioning](../../src/ecs/ordinary-schema-provision.bend) generates key-free typed count slots from ordinary component/resource/product builders. [Population](../../src/ecs/ordinary-app-population.bend) pairs them with the sole retained Schema and scans actual live handles only when debug is enabled. [Final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-population-v1/FINAL-REVIEW.md) qualifies six complete JS/Native outputs, five authority refusals and a reached non-live-slot countermodel. Arbitrary affine columns/resources, pending work and registration cursors are preserved. Custom stores, full #56, integrated regression and feature timing remain open.

## Ordinary filtered dump

[Dump provisioning](../../src/ecs/ordinary-schema-dump.bend) derives typed presentation slots from ordinary component/resource/product declarations, retaining one Schema. [Dump App](../../src/ecs/ordinary-app-dump.bend) applies native typed entity IDs/component conjunction/optional Nat limit to alive handles before component presentation. Debug disabled skips traversal; limit zero skips component presentation, while resources remain global. U32, Bool and affine Array<U32> have built-in presentation; opaque values may supply a trusted owner-returning presenter.

Ordinary filtered dump is adopted after [one independent review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-filtered-dump-v1/FINAL-REVIEW.md): six complete JS/Native outputs, 15 commands/51 guards, six intended authority refusals and a reached conjunction defect. The same operational declarations generate typed component/resource presentation; alive IDs, component conjunction and native Nat limit select entities before component presentation. Both reached outputs reject the complete matched-QName baseline while preserving all 66 physical observations. Column/Product coverage is bounded; custom stores, full runtime composition/presentation and integrated performance remain open. A dump is not a restorable snapshot; arbitrary presenter signatures do not prove owner identity or noninterference.

## Population and dump inside event RuntimeApp

Direct event RuntimeApp population/dump is adopted after [one independent review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-runtime-dump-v1/FINAL-REVIEW.md): six complete JS/Native outputs, 15 commands/51 guards and six intended authority refusals. The same Provision generates one Schema and a metadata-free Recipe; the existing App type and operational with_previous remain unchanged. Debug observations reconstruct all ten Runtime fields without tick advancement or synchronization. Eighty snapshots include unsynchronized World.events[77] before frame cleanup. The reached tick defect matches its complete countermodel and rejects the full same-grammar baseline on both backends. At that adoption, runtime batches/reader/event payload presentation was only harness evidence; the subsequent public RuntimeView slice is qualified below. Custom stores, full presentation and integrated performance remain open. Retain the generated setup Recipe and enable debug; no second key list or built-in value presenter is required. Opaque presenters and raw Recipe/internal callback bridges remain trusted. This is finite Column/Product Data-event composition; Type events remain #53.

## Detached event RuntimeView

The existing [RuntimeApp](../../src/ecs/ordinary-app-event-runtime.bend) exposes `runtime_view` when debug is enabled: actual namespace, batches, Reader positions, next Reader ID, tick/frame boundary/retention metadata and the current World event log. Its detached `RuntimeView<E:Data>` retains the App and all affine owners. Disabled calls return None before World projection. The library U32 formatter labels actual Reader IDs; it does not infer their Registry associations or synchronize the log into batches.

[Independent final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-runtime-view-v1/FINAL-REVIEW.md) verifies six complete JS/Native outputs, 15 commands/51 guards and four intended authority refusals. Two nominal consumers retain all eighty observations; the reached returned-tick defect matches its full countermodel and rejects the matching complete baseline on both backends. Other’s successful source removes one unreachable helper; earlier Native/alias deadlines and parser failures remain preserved without qualification credit. This qualifies the generic detached Data view and finite U32 presentation; opaque formatting, Type events (#53), captures (#50), full static/composition/custom-store coverage and feature timing/combined regression remain open.

## Operational persistence classification

[Ordinary provisioning](../../src/ecs/ordinary-schema-provision.bend) supplies six component/resource builders for Plain, Transient and Constructed extensions. The same schema, canonical identity and constructed project indices determine operational admission and the sole ordered debug entries; enable the existing App debug flag and use its snapshot. No second metadata declaration or Data/Type inference is needed. Bare provisioning remains unclassified. The additive `Fragment.Entry.Classified` variant requires a branch in exhaustive client matches. Identity-based validation and descriptor requirements ignore classification; filtering retains tags/order, and population/render/eligibility normalize identities.

[Independent final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-classified-schema-v1/FINAL-REVIEW.md) qualifies eight complete JS/Native outputs, 20 commands/68 guards, seven typed authority refusals and a reached wrong-label defect. Two nominal four-mode consumers cover actual constructed component admission and resource refusal/same-Array repair/retry; compact Fragment controls cover both descriptor directions, filtering, duplicate validation and merged/rejected owners. The reached outputs reject the complete matching baseline at byte357. This is finite Array/raw Column/Context evidence, not alive-entity, scheduled-system, universal owner-identity or custom-store qualification. Full event/service/machine vocabulary, presentation/composition, feature timing and combined regression remain open under #56 and the existing performance tickets. No new laws or ownership policy are adopted.

## Finite operational machine vocabulary

[Ordinary machine declarations](../../src/ecs/ordinary-machine-declaration.bend) accept `declared(name, values)` once. The same indexed declaration drives normal installation, reads, queues and enabled debug snapshots, including supplied unused values when the current slot is unavailable. Name-only declarations leave vocabulary unspecified; an explicitly empty list is distinct. No separate metadata adapter or queue membership restriction is introduced. The additive `Declaration.Vocabulary` variant requires exhaustive external matches to add a branch.

[Independent final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-machine-vocabulary-v1/FINAL-REVIEW.md) qualifies twelve complete JS/Native outputs, 30 commands/102 guards, five intended authority refusals plus actual two-slot setup and scoped exact reuse of unchanged capability controls. Two nominal four-scene consumers preserve all World/Slot/Array owners and pending work through repeated enabled/disabled snapshots, reads and queues. Successful queue9 outside the supplied list remains accepted. Legacy/empty consumers distinguish None from Some([]); the reached omission rejects the complete matched baseline at byte400 while all forty physical observations remain exact. This is finite U32 vocabulary with affine sibling owners, not exhaustive arbitrary Data, universal owner-identity or fresh scheduling/apply/transition qualification. Full #56 and performance gates remain open.

[Mixed typed Data routing/inventory](typed-data-events.md) is integrated as a bounded #71 slice: recursive operational provisioning retains distinct typed stream metadata in one World, and unused declarations appear automatically. Four complete JS/Native pairs and independent final review cover routing, cursor/retention, transaction abort/retry, authority and actual affine Args/Out. Combined regression and feature timing/scaling remain pending; Type-event ownership stays #53. This extends closed reader prerequisites without claiming full #56 or parity.

## Custom aggregate Store bridge — bounded integration

The current Column/Product provisioning does not qualify arbitrary aggregate stores. Existing [Family](../../src/ecs/component.bend) `take/put` bindings already provide operational access to a Column within arbitrary Store:Type. Presence and payload display can derive from those same bindings through `Column.has/view`, while [World.handles](../../src/ecs/world.bend) supplies alive membership. Ordinary provisioning must retain the binding once and generate both observation callbacks; a second user debug lens or key list would fail #56. Opaque payload presentation remains an allowed extension.

The public [binding provision](../../src/ecs/ordinary-binding-provision.bend) is integrated after [independent final review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-custom-store-v1/FINAL-REVIEW.md): nine JS/Native pairs, eighteen complete outputs, 45 commands/153 guards, seven intended public authority refusals and a reached count defect. Four direct public pairs cover two nominal schemas and all six classified component/resource builders. The same operational bindings derive population and presentation for a named aggregate Store with affine sibling owners; alive membership, disabled debug, conjunction filters, limit zero, global resources and pending work are observed.

The first classified JS failure exposed omitted resource presentation. Its retained failure and one-line `Fragment.bare_entries` normalization repair remain explicit; the independent expected output was unchanged. [Delivery and retained evidence](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-custom-store-v1/DELIVERY.json) bind all source and runtime packets. Trusted family lenses, opaque presenters and raw indices remain setup boundaries; finite traces do not prove universal owner identity or callback noninterference. Non-Column backends remain unqualified. Full #56, combined regression and feature timing/scaling remain open.

## Ordinary native service inventory — bounded integration

The [service declaration](../../src/ecs/ordinary-service-declaration.bend) retains one operational Resource-slot binding for availability, callback and supplied/required inventory, including an unused service. [Application](../../src/ecs/ordinary-app-service.bend) derives actual registration/preflight and exposes a library-generated `Cap.ValueRead`; users supply no second metadata projection. [Independent final review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-service-v1/FINAL-REVIEW.md) passes five JS/Native pairs, ten full outputs, 25 commands/85 guards, six intended authority refusals and a reached availability defect. The current abstract read is actually invoked. Missing preflight preserves pending work, registration and held affine owners before same-owner repair/retry.

This is #34's bounded Resource-owned native service contract with trusted numeric setup tokens/lenses and a single Registry/Unit/barrier wrapper. It does not replace arbitrary authored schedules or qualify external IO, service sharing, callback recovery or rollback. Other is a nominal reuse, not an independent second application. The common SchemaApp composition is integrated below. Broader service ownership, complete #56, combined regression and feature timing/scaling remain open.

## Common ordinary composition — bounded integration

The [typed-family App bridge](../../src/ecs/ordinary-app-event-family-runtime.bend) and [service registration leaf](../../src/ecs/ordinary-app-service-registration.bend) retain one World, actual Registry owners and the same operational declarations. Service fields use a separate category without inventing a Query mode. An authored schedule dispatches the service, component and resource callbacks; debug derives their descriptions and inventory. Slot keys come from the retained bindings.

[Independent Spec/Standards review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/FINAL-REVIEW.md) passes eight complete JS/Native outputs, 20 commands/68 guards and seven intended authority refusals. The reached disabled-debug defect changes the full observation while preserving all four physical checkpoints. The initial oracle registration-order error and failed run remain archived. [Delivery](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/DELIVERY.json) binds the complete evidence. Event-reader composition is integrated below; mixed relation notices, general trusted-lens effects, full #56, combined regression and feature timing remain open.

## Common typed-family readers — bounded integration

The [reader leaf](../../src/ecs/ordinary-app-event-family-reader.bend) installs the actual typed Stream reader and Registry in the common App owner tree. Their operational declaration supplies descriptions and Events access; users supply no debug metadata adapter. Debug retains the Reader and all owners without reading, advancing or synchronizing events. The additive `RegistrationKind.EventKind` requires exhaustive client matches to add a branch.

[Independent Spec/Standards review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/reader-registration-v1/FINAL-REVIEW.md) passes eight complete JS/Native outputs, 20 commands/68 guards and four current typed/affine refusals. Two First readers and one Second reader share printable names without sharing typed authority; the unused stream remains visible. The reached category defect rejects the actual full matched baseline while all six physical checkpoints and eighteen Reader identities stay exact. [Delivery](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/reader-registration-v1/DELIVERY.json) binds evidence and limits.

This qualifies finite successful Read registrations; actual Registry cursors remain zero under existing untracked `Sys.run`, while native reader positions advance through actual reads. Authored lenses/recipes remain trusted. Mixed relation notices, writer execution, full presentation/composition, combined #28 and equivalent feature timing remain open.

The integrated common composition and reader source also pass the unchanged combined181 protected #28 gate after [independent final review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt181-01/FINAL-REVIEW.md): 20 paired samples per backend, no statistically confirmed slowdown. Workshop timing is not full debug/event feature qualification.

### One-World mixed relation notices

The [mixed runtime](../../src/ecs/event-notice-runtime.bend) retains the sole World while separating Original-only typed journals from descriptor-keyed relation-failure metadata. Existing per-domain ticks and retention remain distinct. [Independent final review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/mixed-notice-v1/FINAL-REVIEW.md) accepts eight complete JS/Native outputs, twenty commands/68 guards, two intended schema/affine refusals and a reached passthrough omission rejected against the complete matched baseline. The immutable catalogue correction fixes provenance digests; executed source-basis bindings were correct.

Actual relation self-failure and its reader execute. ComponentRemoved/CleanupPaused are seeded passthrough observations, not cleanup execution. The ordinary App adapter's start is source-reviewed but not yet reached by this consumer; next qualify common App ownership and execution of typed and failure readers together. Trusted synchronized-journal/provider boundaries, full formats, equivalent feature performance and full #56 remain open. [Combined183 protected regression](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt183-01/FINAL-REVIEW.md) passes independent final review on the integrated result: no statistically confirmed regression against the unchanged frozen Bend baseline. Descriptive Workshop ratios are JS/TS 0.373536× and Native/TS 0.097392×; they do not qualify the full debug workload.

### Common mixed readers — adopted

The [relation failure reader](../../src/ecs/ordinary-app-relation-failure-reader.bend) retains its operational declaration and Registry in the common App tree. The ordinary consumer now reaches mixed App start and executes two First readers, one Second reader and one failure reader; descriptions derive from those declarations. [Final review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/FINAL-REVIEW.md) passes eight full JS/Native outputs, 20 commands/68 guards and scoped authority controls. Removing the actual descriptor debug binding rejects the complete baseline on both backends while physical owners and reader views stay identical.

The Other Native emit deadline was resolved by sharing an identical observer projection; no fields were removed or limits raised. Its failure and copied compiler diagnostic remain archived. Raw callbacks, synchronized-journal boundaries and seeded cleanup observations retain their existing limits. Full formats, equivalent feature timing and full #56 remain open. [Combined184 protected #28](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt184-01/FINAL-REVIEW.md) passes independent final review with no statistically confirmed regression. Workshop JS/TS is 0.396053× and Native/TS 0.095298×; this does not qualify full debug/event timing.

Named schedule placements are [integrated after final review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-schedule-description-v1/FINAL-REVIEW.md). The public `ordinary-app-schedule-description.bend` joins ordered actual Plan steps to Registry namespace/id bindings, preserves the original description and all affine owners, and skips derivation when debug is disabled. First-public and affected normal/second-schema/name-binding controls pass eight complete JS/Native outputs; both reached controls reject the complete matched baseline. Closed ordinary condition names are integrated below; renaming/lint policy, stateful condition composition and broader performance remain open #56 gates. Combined185 passes the unchanged protected #28 gate with [independent final review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt185-01/FINAL-REVIEW.md): NO_CONFIRMED_REGRESSION on the accepted addition. This protects Workshop and does not establish full feature performance.


### Closed ordinary condition declarations — bounded integration

The [closed Program](../../src/ecs/ordinary-condition-declaration.bend) supplies executable routing, actual Registry-ID projections and per-condition debug names once; the [schedule adapter](../../src/ecs/ordinary-app-condition-schedule.bend) derives placements from that declaration. [Final Spec/Standards review](../../experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/FINAL-REVIEW.md) accepts full JS/Native ordinary, structural-refusal, queued foreign-world and reached-evaluator observations, plus typed controls and the actual scoped TS reference. Core integration is `0f92ed6d1`.

Raw World callbacks and Program constructors remain trusted; structural validation proves neither predicate purity nor provenance. Full formats, graph/machine and transient/plain observations, stateful registered conditions, enabled overhead, approved proofs and full performance remain incomplete. Combined201 predates these two modules; the unchanged regression gate needs a source-current successor in a quiet window.

### Mixed-reader filtered dump — bounded integration

The [common App dump](../../src/ecs/ordinary-app-event-family-dump.bend) reuses the schema-derived filter and projections while retaining the actual event family, tick and readers. One operational Binding supplies descriptions and component selection; opaque-value presentation remains explicit. [Final review](../../experiments/public-inspect/promotion-stage/ordinary-mixed-reader-dump-v1/FINAL-REVIEW.md) accepts the complete 212,540-byte two-schema JS/Native observations and one positive plus three authority controls. The actual zero-limit defect produces its independently derived 207,106-byte JS counter and rejects the whole normal baseline.

Native reached emission and a subsequent inline source check expired; neither receives qualification. Both attempts and exact normal restoration are retained. Raw World callbacks remain trusted; no purity or universal preservation proof is claimed. Native reached, broader formats/composition, combined #28 in a quiet window, enabled overhead and full #56 remain open.

The [opaque classified composition](../../experiments/public-inspect/promotion-stage/ordinary-mixed-reader-dump-v1/opaque-classified-v1/FINAL-REVIEW.md) also passes bounded final review: both backends match all 226,040 bytes, including both arrays and tag of an affine record payload and declaration-derived Transient/Plain classifications. Its presenter remains a trusted owner-returning function; unchanged adapter controls retain their lower scope. This adds finite composition evidence without a new API, disposal policy or universal proof.

### Named full machine snapshot — bounded integration

The [machine value snapshot](../../src/ecs/ordinary-app-machine-value-dump.bend) derives the name and full Data slot from the same operational machine declaration, preserves the affine App owners and returns `None` before projection when debug is disabled. [Final review](../../experiments/public-inspect/promotion-stage/ordinary-machine-value-dump-v1/FINAL-REVIEW.md) accepts complete 7,287-byte JS/Native observations of queued state, failed-queue rollback, structural flush and a separate transition marker, plus the actual API's positive and three authority controls. Both backends detect the reached enabled-output omission against the full normal baseline; exact normal source was restored.

Executed TS reuse covers only named current/pending/previous fields and marker/pending separation. Trusted resource lenses, enabled overhead, approved proofs, source-current combined #28 and full #56/performance remain open.

### Source-current acceptance reconciliation after machine values

The older “unqualified operations” table above records the gaps at that stage;
it must not be read as absence of the subsequently integrated public entries.
The following reconciliation separates actual missing interfaces from finite
qualification and policy gates. It does not close the unchecked acceptance list.

| Category | Current ordinary declaration/API and qualified evidence | Precise remaining scope |
| --- | --- | --- |
| Description and classification | Schema/Binding provisioning supplies classified identities and projections; relation, machine, typed event and service leaves derive their own operational names and inventory. Common composition, registered mixed readers, opaque Transient/Plain payloads and the named full machine snapshot are qualified in the deliveries linked above. | No single universal detached all-category formatter or arbitrary backend/value enumeration is claimed. Existing finite graph/machine/classification observations are present and should not be replayed merely as missing formats. |
| Access index | `ordinary-app-access.index` folds the actual retained owner Fields, including component/resource and Data-event uses. Same-World evidence and typed-reader composition are integrated. | The named multi-schedule placement-filtered index is qualified below. Whole-feature overhead remains open; combined220 passes the unchanged Workshop gate. |
| Lints | Actual operational access/Plan facts are retained; there is no public lint producer in `src/ecs`. Bevy fixes its ambiguity trigger and defaults; these do not require a new user choice. | Bevy diagnoses conflicting access only between unordered system pairs (default Ignore); redundant set-hierarchy edges default to Warn. Current Bend Plans are total sequences with no set hierarchy, so ordinary read/write overlap is ordered and is not a Bevy ambiguity. TS-specific lint categories are inventory, not native semantics. Broader graph diagnostics remain unqualified; do not invent unordered pairs from the access index. |
| Population and filtered dump | Column/Product and Binding-derived aggregate-store population/dump are qualified. The common mixed-reader dump preserves actual readers; its opaque classified successor displays both payload arrays and tag. Machine values now include the full native current/pending/previous/skipSame/changed Slot. | Traversal must cover every supported declared binding, including arbitrary affine Type payloads; adding another storage backend is not a separate #56 requirement. Mixed-reader zero-limit reached Native emit, ordinary -O3 build and consumer exited 0. Separate independently reviewed retained-output qualification matches all228202 bytes against source-derived relocated counter and rejects full234338-byte normal at byte355; the original collector receipt remains INCOMPLETE because it expected old-root QName presentation. No rerun or collector PASS is claimed; the machine-value control does not transfer credit to this subject. |
| Names and placements | Actual schema, Registry, machine, service and schedule names derive from ordinary setup; schedule-description and closed-condition declarations provide ordered per-placement names without a user metadata map. | Named-plan replacement follows Bevy and returns the previous Data plan while preserving registered owners, as qualified below. TS rename-map mechanics are not adopted. General stateful/read-grant conditions belong to #48/#50 if that ordinary API is introduced, rather than an extra #56 prerequisite. |
| Disabled work and preservation | Qualified entries return `None` before their production descriptions/projections; complete enabled/repeated/disabled observations and reached controls retain the stated owners/readers/pending work. | Trusted lenses/presenters/raw callbacks and forged closed Program provenance are not universal noninterference proofs. Combined205 now passes the unchanged protected #28 gate after independent review; enabled overhead and full feature timing/scaling remain unqualified. |

Rust Bevy retains operational system access and names, rather than requiring the
TS debug DTO or its lint/renaming policy. Bend's closed declaration indices and
ordinary owner folds provide the implemented derivation; function reflection or
a second debug-only metadata adapter is unnecessary for those slices. The named
machine snapshot's executed TS reuse is only current/pending/previous format and
marker/pending separation, not native skipSame/changed or physical-scene equality.

No further policy-free format fixture is identified with sufficient confidence
from this reconciliation. The named multi-schedule index is now qualified below
through an ordinary retained collection. Existing registration
identity already fixes ownership: one affine App retains World and H once;
Data plans reference registered IDs. Using one ID in two plans preserves that
instance's Local/cursor state; independent instances require separate registrations.
Replacing a Data plan does not itself dispose registrations. Label lookup and
collision behavior follow Bevy: `Schedules::insert` replaces and returns the
previous schedule. The named Bend collection therefore returns the previous Data
plan while retaining App owners, registered system state, Local and cursors.
This is the approved behavior; placement does not clone or reset registrations. Bevy lint triggers/defaults are source-determined; TS-specific renaming rules are
not adopted by that fact. The remaining #56 work is source-current ordinary-entry
acceptance, applicable preservation controls, scaling and separately identified
debug overhead. Neither a new storage backend, unbounded type-level arity proof,
TS renaming map nor general stateful predicates is an automatic prerequisite.
The current finite supported declarations must still be traversed completely;
existing gates are unchanged and #56 remains open.

Mixed-reader evidence applicability: its retained source map has 84 direct core
dependencies; 82 remain byte-exact. The two changed dependencies are
`inspector-query` and `inspector-relation-projection` at `dd54c5d68`; the changed
`grant` is reached by `ordinary-app-relation.observe`. The [runtime08 review](../../experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime08/delivery-v1/FINAL-REVIEW.md)
checks the replacement kernel's component-first matching, component-then-relation
projection, graph/spec operations and affine owner path, with actual current
JS/Native full 147,180-byte observations. This is a reviewed source-equivalence
bridge for those dependencies, alongside the [retained full counter qualification](../../experiments/public-inspect/promotion-stage/ordinary-mixed-reader-dump-v1/reached-f1a-v1/FINAL-REVIEW.md).
It is not byte-exact whole-closure reuse, a fresh mixed-reader run or an upgrade
of its historical INCOMPLETE collector receipt. The zero-limit filter and its
reached defect are unchanged; no new semantic operation was found in this audit.

### Combined213 protected regression

[Independent final review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt213-01/FINAL-REVIEW.md) accepts the current 213-module integration under the unchanged Workshop gate: 20 paired samples per backend, all 123 commands and 110 complete outputs pass with no statistically confirmed regression. Descriptive candidate/TS time ratios are JS 0.4021 and Native 0.0965. This covers the protected workload, including retained single-Schedule access and optional-resource registration; full debug feature timing, overhead and remaining contracts are still open.

### Retained single-Schedule access index

[Bounded final review](../../experiments/public-inspect/promotion-stage/ordinary-schedule-access-v1/FINAL-REVIEW.md) accepts [the public index](../../src/ecs/ordinary-app-schedule-access.bend): the retained operational Plan selects registrations by namespace and Registry ID, in placement order, from ordinary declaration-derived Fields. Disabled debug returns before folding owners. Complete two-schema JS/Native observations match 53,843 bytes; the actual filtering omission matches the independent 58,307-byte counter on both backends and rejects the complete normal result. All 107 source inputs are restored. Actual API nominal/affine refusals and a scoped, executed 3,669-byte TS reference pass.

This covers one retained Schedule. TS empty descriptor entries and name deduplication remain explicit reference differences. The named multi-schedule collection is qualified below. Enabled overhead, universal proofs and full #56 remain open. Combined213 protects its exact historical core; the current combined core passes the unchanged #28 gate in combined220.


## Ordinary named schedules

[Named plans](../../src/ecs/ordinary-app-schedules.bend) retain one affine App and registered system owners; replacing a label returns the old Data plan, and removal does not reset Local or reader state. [Local registration](../../src/ecs/ordinary-app-local-fields.bend) derives access from the same typed executable declaration. Per-plan access indexes select actual registrations; disabled debug returns before folding owners or observing values.

[Independent final review](../../experiments/public-schedules/named-app-v1/delivery-v1/FINAL-REVIEW.md) accepts the bounded [ordinary consumer and retained packet](../../experiments/public-schedules/named-app-v1/README.md): complete 42,359-byte normal observations, an affine positive control and eight intended type refusals, actual WorldIO foreign-Local preservation on JS/Native, and a reached placement-filter defect rejecting the complete normal result. Normal JS is retained/posthoc with its original INCOMPLETE receipt preserved; Native is a fresh ordinary O3 pass. This consumer has Unit events and no pending commands: it does not qualify their noninterference. Matched TS, full feature timing/scaling and full #56 remain open. Combined220 passes the unchanged #28 Workshop gate after [independent review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt220-01/FINAL-REVIEW.md); this is not complete debug performance qualification.

The next matched ordinary named-schedule consumer has now actually passed TS, emitted JS and ordinary Native -O3: each matches all 30,216 independent bytes (104 records across two schemas and two debug modes), with guards 4/7/10 and all six commands successful. The existing bound-collector batch finishes WRAPPERS_PASS with no pending jobs. The runnable fixture and [portable retained packet](../../experiments/public-schedules/named-app-v1/matched-feature-delivery-v1/README.md) are integrated after [independent final review](../../experiments/public-schedules/named-app-v1/matched-feature-delivery-v1/FINAL-REVIEW.md). Root verification passes all 167 members and 12 malformed controls; all 64 relocated consuming Bend bodies match. Scales 2/4 execution, separate enabled overhead, feature timing and full #56 remain open.

Source reconciliation for diagnostics: pinned Bevy `schedule/node.rs:591–639` checks disconnected pairs against initialized access, including explicit ambiguity exclusions; `schedule/schedule.rs:1883–1953` fixes ambiguity Ignore and hierarchy Warn defaults, and `schedule/error.rs:19–74` separates build errors from configurable warnings. These are order/determinism diagnostics, not an access-safety failure. Bend `schedule-provision.bend:13–16,51–69` flattens Empty/Entry/Sequence into an ordered list; `schedule.bend:66–76` executes that list head-to-tail. No unordered pair or redundant hierarchy edge is represented. Adding a dependency graph solely to imitate a TS lint label is not required by this source comparison; public diagnostics and their represented scope still need #56 acceptance evidence. No new contract or runtime behavior is introduced here.

Scope check against the pinned implementations: TS `Debug.ts:87–105` classifies constructed/transient/plain values, not selectable component storage backends; its World stores dense ordinal records. Bend `ordinary-component-binding.bend:6–11` supplies Column leaves over generic stores, composed by Schema.product. TS `Condition.ts:1–70`/`Machine.ts:142–224` supplies a closed repeatable AST, whereas Bevy stateful SystemCondition is a broader API. These observations apply the existing SPEC scope; they do not waive full supported-binding traversal, arbitrary affine payloads, noninterference or performance gates.

After [independent final review](../../experiments/public-schedules/named-app-v1/debug-overhead-v1/delivery-v1/FINAL-REVIEW.md), the integrated [mode/scaling delivery](../../experiments/public-schedules/named-app-v1/debug-overhead-v1/delivery-v1/README.md) retains all 56 ordinary commands and 24 complete independent outputs across modes/scales on TS, emitted JS and ordinary Native -O3. Its baseline comparative cohort completes 810 commands and 360 paired observations: median JS/TS ratios span 2.069–2.453; Native exceeds 0.5×TS in four cells. These noisy observations do not qualify the performance targets.

A two-function tail-accumulator experiment also passes all three aggregate scales and lowers whole-process sampled allocations, but its 270-command/120-pair cohort shows no consistent timing improvement: JS/TS medians 2.234/2.288/2.275 and Native/TS 0.344/0.485/0.706 at scales 1/2/4. The core patch is archive-only and is not adopted. Before/after CPU/allocation profiles retain full-output checks; sampled allocation is not RSS or exact bytes saved. The portable verifier checks 2,892 members, 1,157 non-profile commands, 1,065 complete outputs, eight profiles and nine malformed controls. Historical failed attempts remain unchanged. Full #56 performance and acceptance remain open.
