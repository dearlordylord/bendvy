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
| [ordinary-app-machine](../../src/ecs/ordinary-app-machine.bend) install/read_app/queue_app/snapshot_app | Name and Current/Unavailable view derive from the same ordinary machine declaration; library supplies observation wiring. [Public entry review](../../experiments/public-inspect/ordinary-machine-review-v1/ENTRY-FINAL-REVIEW.md) covers full enabled/disabled/read/queue observations and affected authority. | Current view does not yet expose a retained declared state vocabulary. |
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
| Full static description with Plain/Transient/Constructed classification and complete declared event/service/machine-state inventory | `ordinary-app-schema.snapshot` returns ordinary Fragment entries; `ordinary-app-description.bindings` derives runtime bindings. Ordinary classified component/resource provisioning now derives Plain/Transient/Constructed entries from the same indexed operational persistence extension; bare declarations remain unclassified. Machine Current and selected stream/relation descriptions cover bounded views. | Connect the existing persistence/full inventory at ordinary declaration seams and qualify complete presentation, without a second user metadata declaration. |
| Global readers/writers access index and schedule lints | Actual Fields contain names/access/cursors/clauses; Schedule descriptions retain Plan/steps/needs. These are per-owner/per-schedule facts, not a cross-schedule index or linter. The ordinary component/resource/event index is now adopted for the qualified same-World App; cross-schedule inventory and schedule lints remain unqualified. | TS inventory includes component/resource/event readers and writers and event/next-state/component/read-before-write lint categories. Qualify retained diagnostics only from real declarations and approved native semantics; exact historical TS lint rules/messages are not newly approved by this inventory. Metadata alone is not authority. |
| General custom-store population adaptation | `world.handles` returns alive handles; `column.has` checks membership while restoring arbitrary affine payloads. Ordinary bindings retain typed storage lenses, while Schema entries retain only names/order. An all-schema closed population fold must therefore be generated at ordinary provisioning, including unqueried zero-count components; resource leaves are excluded. Ordinary Column/Product provisioning now generates this traversal and passes the bounded population packet; general custom Store lenses remain unqualified. | Preserve the adopted ordinary Column/Product entry and qualify any general custom-store adaptation at its actual typed lens boundary; fixture arithmetic is not a production entry. |
| Generic filtered complete dump by entity IDs, component conjunction and limit, including transient/plain values | Adopted ordinary Column/Product dump derives presentation from operational declarations and supports native typed entity IDs, component conjunction and Nat limit. Six full JS/Native outputs and a reached conjunction control preserve all 66 physical observations per consumer; resources remain global. | Direct event RuntimeApp population/dump and detached RuntimeView with U32 presentation are adopted; qualify remaining opaque/general presentation, relation/machine/transient composition and custom-store coverage. Preserve World, owners, runtime ticks, readers and pending work. Dump is not a restorable snapshot. |
| Debug naming/placement inventory and naming replacement | Ordinary schema names default to keys; actual Registry names and attached Schedule names/IDs are exposed. There is no `nameSchedules`-style renaming table or full placement/condition-name formatter; the operational declaration does not retain condition names. | Reconcile pinned naming formats with existing operational names and approved semantics; do not infer TS renaming or invented names from IDs. |

Machine inventory covers the ordered finite vocabulary supplied by the ordinary operational declaration, including unused declared values, plus Current/Unavailable. Pinned TS `Machine.ts:308–322` retains that vocabulary and `internal/debug.ts:341–345` exposes it; Rust Bevy `States` supplies no exhaustive-value enumerator. The current Bend declaration retains name and current-state machinery but lacks the vocabulary, leaving a concrete #56 declaration-retention gap. Preserve existing #48 queue semantics when adding this description; the inventory requirement does not select a new validity policy.

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
