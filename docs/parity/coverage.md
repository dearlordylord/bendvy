## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An independent public consumer verifies the whole pinned core surface and reports exact remaining differences before full parity is claimed.

## Acceptance criteria

- [x] Inventory every pinned core public export, bound Game/Runtime capability, source test and static rejection case. Map each to source-current executable evidence, approved divergence or a concrete owning ticket; no unowned core gap may remain.
- [x] Run two independently authored schemas/apps covering cross-feature combinations, complete observations and ownership/access controls through the public API. Historical miniature probes and closed child issues alone do not pass.
- [x] Check ergonomic ECS use against Rust Bevy and correct Bend kind/runtime use against compiler/Base; review fragmentation, hardcoded arity, fabricated authority and unsupported payload boundaries.
- [ ] Publish and resolve discovered gaps as executable dependent tasks; do not close this audit as full parity while any required behavior is absent. Full numeric product qualification stays in existing #21/#23/#24.

## Blocked by

- #40
- #41
- #45
- #47
- #52
- #53
- #56
- #60
- #34
- #35
- #51
- #57
- #43

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current implementation reconciliation — 2026-10-16

Source/document reconciliation through selected-resource integration `0b025defe`
(CI38919912200 PASS), after #53 integration `32539b721` and its passing
CI38883496921, and the accepted Check/reader integrations cited below. This current section supersedes pending/
absence claims in dated overlays below; it does not alter their immutable evidence.
GitHub issues #34–#64 were checked directly: #34–#36, #39–#53, #55–#56,
#58 and #63 are closed; #37/#38/#54/#57/#59/#60/#61/#62/#64 remain open.
Closure denotes accepted semantic scope, not arbitrary cross-feature composition.
The [current core map](../reference/core-map.md#current-parity-checkpoint--2026-10-16)
updates the existing capability rows. Archived TS helper/export catalogues remain
historical research; the capability classification in this document governs scope.

| Contract → actual implementation | Direct accepted evidence | Remaining gap → existing owner |
| --- | --- | --- |
| Reusable affine capture packs → public ordinary resource/query captures; heterogeneous captured systems and registered stateful conditions → typed composition/nested plans. #50/#51 closed. | [Capture acceptance](captures.md) joins resource/lifecycle and complete 7,441-byte query / 4,961-byte App JS/Native observations. [Composition acceptance](captured-schedules.md) joins complete 6,161/15,793/4,217/13,895/16,957-byte pairs, actual foreign/stale identities, returned/re-registered packs, authority refusals and reached wrong-leaf routing. | Capture updates persist after entered-call failure while ECS rollback remains separate. No arbitrary host-IO rollback or automatic finalizer; #51's original fixture source-reviewed its final NoBinding branch; the [AppA captured successor](../../experiments/public-audit61/app-a-captured-conditions-v1/runtime-v1/actual-attempt01/README.md) now executes that branch on both backends, including B updating while A skips. Full combinations #61; combined performance #21/#23/#24. |
| Reversible arbitrary affine component/resource/opt-in capture operations → canonical declaration-derived grants and one ordered journal. #52 closed. | [Recovery acceptance](recovery.md#semantic-acceptance-reconciliation--2026-10-16) joins the mixed 16,673-byte pair, reached resource-inverse owner loss, intended confinement refusals and independently authored present-component removal/rollback/commit (2,276-byte pair). | Arbitrary destructive callbacks and external IO remain outside reversible grants. Custom declaration builders are trusted provisioning. The new [canonical selected-field recovery](recovery.md#selected-resource-fields) closes the Product composition gap: complete 10,339-byte two-schema stock pair, 9,763-byte reached owner-loss pair rejecting normal, two positive/eight intended controls and independent final review. The field binding derives identity/path and preserves sibling/capture owners. Complete application/capability joins #61; combined timing/scaling #21/#23/#24. |
| Canonical owned event families → public [publisher](../../src/ecs/ordinary-owned-event-family-publisher.bend), [reader/query](../../src/ecs/ordinary-owned-event-family-reader-query.bend), [resource grant](../../src/ecs/ordinary-owned-event-family-resource.bend) and typed catalog maintenance. #53 closed. | [Selected contract](affine-events.md#selected-ownership-boundary--2026-10-16) and [final review](../../experiments/public-owned-events/ordinary-v1/FINAL-REVIEW.md) join four normal stock JS/Native pairs (21,529 / 10,193 / 48,711 / 90,973 bytes) and one reached retirement-loss pair (90,719 bytes), each against its complete independent oracle. Final combined authority controls have two positives/eight intended negatives; prior reader controls separately cover reader/Registry/Args duplication and wrong same-payload-family selection. | Payload:Type, Request:Type and detached Projection:Data permit independently owned Observation:Type. The log owner is restored before query row grants; all current-call events/rows/resources share one transaction. Failure restores ECS and reader/query cursors, retains earlier commits and returns available staged owners once; retirement/shutdown return owners for caller reuse/release. Trusted providers/lenses/raw provisioning do not imply purity, constructor secrecy, automatic IO finalization or physical cleanup. #61 owns full combinations; #21/#23/#24 own performance. |
| Existing Data event rules and public source compatibility → additive owned-event modules over the current runtime. | The same #53 final review confirms Data APIs unchanged, exact 23-source protected #28 closure/body identity and source-bound reuse. Executed pinned TS publication/failure/retry/skip/retention evidence is reused only within its original scope. | TS payload alias identity, owned abort/retirement and shutdown have explicit differences/unavailable counterparts; there is no invented TS disposal or whole-wire equality. Protected workload reuse does not establish equivalent feature performance. #61/#21/#23/#24. |
| Ordinary confined read-only predicates → canonical resource/query/machine/relation declarations, generic `CD.both`, lazy existing-condition composition and checked App schedules. | [Resource Check review](../../experiments/public-conditions/checked-predicate-v1/FINAL-REVIEW.md), [query review](../../experiments/public-conditions/component-query-v1/FINAL-REVIEW.md), [machine review](../../experiments/public-conditions/machine-query-check-v1/FINAL-REVIEW.md) and [relation review](../../experiments/public-conditions/relation-query-check-v1/FINAL-REVIEW.md) join complete stock normal/counter/compatibility observations, actual authority refusals and scoped TS comparisons. All eight relation modes also match the complete 117,959-byte current-source pair. | Required resources/machines preflight only when their Check leaf is reached; component Required is row membership, and structural relation declarations add no blanket World-input admission. TS eager-union requirements are an explicit difference. Full Inspector/compiler adoption #54 and exact remaining occurrence/static correspondence #61 remain open. |
| Lazy Check admission before actual ordinary family readers → additive checked-family App transport retaining generic family/tick, Registry and debug fold. | [Checked-reader review](../../experiments/public-conditions/checked-reader-v1/FINAL-REVIEW.md): complete 59,015-byte normal,59,039-byte snapshot-tick defect and 32,103-byte attach-outcome pairs; four positive/six intended negatives and seven exactly reused read controls. | False/lazy skip preserves the actual reader owner/cursor; a later reached barrier may still drain pending World work. The generic Product family is not another canonical journal qualification; callback failure/retry and all Rejected/Missing dispatch variants are not newly executed here. TS registered-false discards unread values, unlike selected Rust/Bend behavior. Remaining exact boundaries #61; subscriber lifecycle #57. |
| Existing public construction → final stored-owner admission → canonical selected-resource field write; one declaration and schema key, no new kernel/provider API. | [Selected-resource review](../../experiments/public-construction/selected-resource-v1/FINAL-REVIEW.md) joins complete 26,673-byte normal and 26,453-byte final-admission omission pairs rejecting normal, one positive/four intended negatives, seven exact reused read controls and 135 unchanged imported core bodies. Actual cooked rejection is observed before undo; its returned affine input is observed and retried. Integrated `0b025defe`, CI38919912200 PASS. | Handled operation refusals are successful outer callbacks, not transport/Registry failure tests. Actual clock/cursor remain 0 and pending callback count 1. Handle validation establishes namespace/positive ID, not liveness; opaque retained undo is not a universal inverse theorem. TS construction and selected-sibling logical subsets retain separate scopes. Restore #59/#60 and exact full audit #61 remain open; closed #46 whole-resource evidence stays valid. |
| IO-created authority and fork/join session transfer → adopted bounded #38 route; Inspector compiler/source candidate → retained private #54 package. | [Identity map](identity.md) retains genuine IO-created worlds, full owner/handle observations and the independently reviewed 1,829-byte fork pair. [Inspector coordination](README.md#current-delivery-coordination) records candidate full 5,077,477-byte Native observation and protected workload compiler comparisons; stock selected compiler/production Inspector sources remain unchanged pending adoption decision. | #38 reuse/generation/capacity decisions and wider runtime-domain qualification remain unresolved. #54 requires compiler selection and reviewed module adoption; private candidate success is not stock adoption. #57 subscriber identity/delivery/error/IO/capture-disposal contract remains unresolved in [trace preparation](debug-trace.md). |
| Basic independent save → integrated #58; ordinary debug and graph inspection → accepted #56/#55. | [Save acceptance](snapshot-export.md#semantic-acceptance-reconciliation), [ordinary debug](debug.md) and [graph inspection](inspect-extended.md) retain their direct bounded reviews. | Basic validate-before-mutate restore #59 and ordered graph/committed-machine restore #60 remain pending. Debug subscriber work #57 and full Inspector #54 remain independent; closed descriptions/graph slices do not close them. Full product targets remain #21/#23/#24. |
| Two independently authored finite public applications → existing AppA/AppB consumers, not a universal matrix. | [AppA actual review](../../experiments/public-audit61/app-a-v1/runtime-v1/spec-standards-review.md): seven complete owner snapshots, actual registered transactions/schedule/Inspector, 5,301-byte pair. [AppB actual runtime](../../experiments/public-audit61/app-b-v1/runtime-v1/README.md): independent hierarchy/machine/projection app, 14,582-byte pair. [AppA failure successor](../../experiments/public-audit61/app-a-failure-v1/runtime-v1/README.md) adds the complete 5,281-byte failure pair; existing [AppA authority/reached controls](../../experiments/public-audit61/app-a-controls-v1/SPEC-STANDARDS-REVIEW.md) and [AppB affected controls](../../experiments/public-audit61/app-b-controls-v1/runtime-v1/README.md) retain separate scopes. | Old application preparation READMEs do not override actual packets. AppB has no registered gameplay system; AppA supplies that finite slice. The [AppA captured successor](../../experiments/public-audit61/app-a-captured-conditions-v1/runtime-v1/actual-attempt01/README.md) adds a complete 18,892-byte stock JS/Native pair: bundles, registered field mutation, captured query/resource owners, A-only bound condition and repeated detached Inspector. The [owned-handoff successor](../../experiments/public-audit61/app-a-owned-handoff-v1/runtime-v1/FINAL-REVIEW.md) now joins component recovery, actual returned-owner retry/publication and scoped event reader/query effects to those same captured schedules and Inspector (46,717-byte stock pair). This is sequential ownership handoff, not a combined recovery/event transaction. Product resource-field recovery is now independently qualified through its canonical adapter. Exact full inventory/static mapping and remaining combinations stay #61. Exact current capability/source-use/static mapping, required cross-feature combinations and discovered gap resolution remain #61. Two finite applications and closed child issues alone do not complete the audit. |

Authority order remains Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`
(ECS access/ownership; `Messages::drain`/`update_drain` return owned messages),
Bend `a950fd683c0d76f09794078e6174fe98a1492876` (guide affine usage is at most
once; Type is not duplicable Data; exact delivery uses separately pinned 2.0.35),
then TS `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334` for the capability inventory
and applicable executed comparisons. The selected Data-event skip/cursor/retention
rules are not identical to Bevy update-window semantics. See the existing
[authority anchors](../reference/core-map.md#rust-bevy-and-bend-authority-review)
and [owned-event boundary](affine-events.md#selected-ownership-boundary--2026-10-16).

This maintenance reads source, governing issues and existing evidence only. No
compiler/backend/reference replay, runner change, benchmark, new contract/law or
full #61 acceptance is claimed. #28 protects its existing workload; full numeric
qualification, profiles/scaling and final JS <= TS / Native <= 0.5 * TS remain
#21/#23/#24.

## Counted core census — source `88dcbb68e`, 2026-10-16

This is the current criterion-1 routing census, not a declaration that every
routed capability has passed its acceptance gates. Independent Spec/Standards
review verified the counts, exact archived source bindings and capability routes. Rust Bevy and existing Bendvy
contracts govern the rows; TS is the third-priority inventory. The
[approved archive classification](../archive/ts-extension-index.md) applies to
TS-only mechanisms, without reopening their implementation. No new extension,
policy, law, backend run or issue is proposed here.

The three reference checkouts match `.references/sources.json`: Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
`a950fd683c0d76f09794078e6174fe98a1492876`, TS
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. Inspection covered the actual TS
`packages/core/package.json` export map, all 33 `src/**/*.ts` bodies, all 35
`test`/`dtslint` bodies, and especially `Schema.ts:479` (Game), `Runtime.ts:539`
(Runtime) and `System.ts:530` (query handles). All 68 file hashes match the
[lossless source census](../archive/ts-port/core-export-inventory.json), whose
embedded exact names, signatures, source lines, cases, marker boundaries and
call-resolution records remain the exhaustive key index. Its historical Bend
implementation/gap strings are superseded by the routing below.

The counted universe is **23 public modules** (22 deep modules plus `index`),
**687 library export-path keys**: 464 deep keys plus 223 root keys (13 namespace
objects and 210 expanded aliases). The archived semantic total 688 additionally
includes `test/utils/fixtures.ts`'s **`fixtures.readResourceValue`**, which is a
test helper, not a library export. The 493 declaration occurrences, 477 canonical
targets and 808 member occurrences use different syntactic/semantic units and
must not be added to the export count. Package `./internal/*` is explicitly
blocked; the ten internal source files are inspected implementation, not new
public APIs. There are **67 bound operation/metadata keys, 55 callable**;
**251 `it` cases + 40 suite declarations**, in 19 executable-test sources and
15 static sources, plus one helper source; and **133 explicit rejection markers**.
All these sets are routed below. A type alias, overload, alias export or TS
mapped-type helper does not create an additional Bend runtime requirement.

Criterion 1 routing is complete for this finite frozen universe: all 687 library
export keys (including 223 root keys), all 67 bound keys (55 callable), all 251
cases and 133 rejection markers resolve through the lossless index to the existing
module/source-group evidence, approved mechanism differences or concrete owning
tickets below. Exact bound-key sets and all 210 expanded root aliases were
reconciled; all 68 pinned source hashes match. This is route-only PASS, not
execution of every case or 133 Bend refusals. Current independently authored
AppA/AppB source joins are separately accepted at `0ee4562f4` (CI38921620111 PASS).
Required identity #38, Inspector/compiler #54, subscribers #57 and restore #59/#60
remain open; criterion 4 and full #61 are incomplete while those required
behaviors/decisions remain unresolved.

Criterion 3 review is complete through the accepted [two-app review](../../experiments/public-audit61/app-b-current-v1/FINAL-REVIEW.md),
[generic Check review](../../experiments/public-conditions/component-query-v1/FINAL-REVIEW.md),
[checked readers](../../experiments/public-conditions/checked-reader-v1/FINAL-REVIEW.md)
and [affine construction](../../experiments/public-construction/selected-resource-v1/FINAL-REVIEW.md).
These assess ordinary composition, generic arity, Bend kinds/runtime and actual
authority/payload boundaries. Both independent apps use bounded administrative
Factory creation; separate IO-world qualifications retain their own scopes.
Review completion does not resolve its findings: the existing #38/#54/#57/#59/#60
implementation and decision gates keep criterion 4 and full #61 open.

### Public module/export routing

Each row includes **every export key and nested member in the named frozen
module**, including its type-only keys; names are resolved by the lossless index,
not by a heuristic search. Root `index` exposes exactly `Brand`, `Decode`,
`Debug`, `Descriptor`, `Definition`, `Entity`, `EntityScope`, `Fx`, `Inspector`,
`Result`, `Requirement`, `Snapshot`, `Schema`; each expanded alias inherits its
deep-module row. Deep imports also expose Command/Condition/Feature/Machine/
Query/Relation/Runtime/Schedule/System. This describes the TS package, not a
requirement for a Bend barrel or Game object.

“Accepted” below means the cited **finite native capability** and its recorded
source applicability, not every TS helper or arbitrary type instantiation.
Ordinary grants are the gameplay boundary; World constructors, schema lenses,
projection callbacks and raw builder/catalog operations are trusted
administration. Existing whole-oracle reviews and source joins are reused;
this census executes no new body. There is no new universal proof claim. Source
module names in the table mean `.bend` files under `src/ecs/`; wildcard groups
mean that existing module family, not a proposed API.

| TS module (deep keys) | Bevy/native contract → current Bend source | Evidence and exact remaining mapping |
| --- | --- | --- |
| Brand (5), Entity (19) | Typed identities, entity lookup/liveness; `world`, `world-io`, `component`, `ordinary-query-selections` | [#38 identity](identity.md) has actual independently created worlds and fork/join evidence; AppA uses its actual Bundle return. Root/generation/reuse/exhaustion and arbitrary fabricated-authority policy remain **#38**. Structural phantom brands, `refine/all` package algebra and JS symbols are archived tooling, not missing ECS exports; ambiguous extra use stays **#61** scope decision. |
| Command (19), Definition (7) | Bevy Bundle/Commands and explicit deferred application; `ordinary-bundle`, `bundle-batch`, `decode-constructed-requests`, `decode-fallible-constructed-requests` | [#41 accepted Bundle semantics](bundles.md#semantic-acceptance-reconciliation), [#46 native construction](validation.md), actual AppA reserve→commit→queued observation→flush, current empty-Bundle review. Exact TS tuple/result helper shapes and `InternalWorld` are language/admin mechanisms. Arbitrary application combinations are **#61**; constructors remain schema-authored, with external IO/finalizer policy outside the inverse contract. |
| Condition (4), Inspector (9) | Bevy run conditions, read-only SystemParams and detached projection; `ordinary-condition-declaration`, `ordinary-condition-composition`, `ordinary-inspector-*` | [#55 graph/stream acceptance](inspect-extended.md); actual AppA repeated selected reads and A-only condition, registered machine conditions. Full general Inspector stock-source/compiler adoption remains **#54**; arbitrary noninterference is not inferred from a trusted projection. Exact source-test predicate combinations not joined below remain **#61**. |
| Debug (42) | Existing opt-in diagnostics contract, `ordinary-app-*`, `ordinary-app-schedule-description`, `ordinary-app-access` | [#56 ordinary description/dump acceptance](debug.md), [#55 projections](inspect-extended.md). `ComponentWrite` through `TraceEvent`, listener/subscriber delivery and failure/disposal observations route to **#57**, whose contract is unresolved; they are not delivered by a read-only dump. Exact TS DTO layout/JS subscription interface is not approved wholesale. |
| Decode (12), Descriptor (42) | Native typed registration, validation/construction and State/NextState; `ordinary-declaration`, `ordinary-schema`, `decode-*`, `state`, `ordinary-machine-declaration` | [#46 accepted bounded native construction](validation.md), [component State](component-state.md), [#48 state machines](machines.md), [#58 transient omission/save](snapshot-export.md). `StandardSchema`, `.Result`, `.Issue`, `fromStandardSchema` and JS unknown/object/UTF16 host conversion are **archived**, not native gaps. Ordinary Unicode names/native error paths stay native. Full validated restore **#59**, ordered graph/machine persistence **#60**; unclassified extras **#61**. |
| EntityScope (5) | Existing grouped cleanup contract, `ordinary-lifetime-scope`, `lifetime-scope-*` | [#45 accepted cleanup/returned-owner/foreign-world controls](scopes.md); restoration of scoped relationships/persistent runtime state remains **#60**. Exact named TS scope brands are mechanisms; no automatic general IO destructor is inferred. |
| Feature (7), Schema (33) | Typed registration/composition, `schema-fragments`, `feature`, `ordinary-app-schema-product`, `ordinary-app-schema`, `ordinary-app-composer` | Existing [#39 fragments](fragments.md), [#40 features](features.md) and accepted ordinary mixed schema/debug consumers. Structural JS record/type-map merging and pre-bind Game factory are archived mechanisms. Exact required native cross-feature composition not evidenced by the two finite apps stays **#61**, not an automatic requirement to duplicate TS factory arities. |
| Fx (14), Result (12) | Explicit typed outcomes; existing automatic ECS failure rollback plus persistent Local; `transaction`, `ordinary-recovery-system`, `ordinary-captures`, `ordinary-capture-query` | [#50 captures](captures.md), [#51 composition](captured-schedules.md), [#52 affine recovery](recovery.md). TS `Fx` environment/map/flatMap/provide/runSync and Result helper-library algebra are archived tooling; Base outcomes/IO and declared grants supply native use. Host exceptions and arbitrary IO rollback are not silently modeled; unresolved native needs **#61**. |
| Machine (40) | Bevy State/NextState, conditions and transition events; `ordinary-machine-operations`, `machine-world`, `machine-conditions`, `ordinary-machine-transition-reader` | [#48 joined semantic acceptance](machines.md#issue-level-semantic-reconciliation), [#49 handlers](handlers.md), actual AppB hierarchy/machine application. Native initialisation, forced/comparator-equal updates, failed writers and lazy conditions retain their exact reviews. Graph/committed-machine restore **#60**; additional application joins **#61**. TS finite values-array/type-union facade is not a new state-universe contract. |
| Query (43) | Bevy QueryData/QueryFilter and lookup; `query`, `ordinary-query-selections`, `ordinary-query-declaration`, `ordinary-query-observable`, `component` | Accepted query/lifecycle, [current query/Inspector consumer](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-public-consumer-v1/FINAL-REVIEW.md), [actual ordinary query errors](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/ordinary-query-errors-v1/FINAL-REVIEW.md) and actual AppA scalar query. Read-only/write/optional/absent/multiplicity errors adapt to Bend results, not JS alias cells. Full Inspector **#54**; precise unmatched combinations of filters, access and exceptional/prepared stores remain **#61** inventory work, not a claim that ordinary query support is absent. |
| Relation (42) | Bevy relationships, inverse edges, hierarchy ordering/cleanup; `ordinary-app-relation`, `relation-graph`, `relation-query`, `relation-failure-runtime` | [#42 current reader/query join](relations.md#semantic-acceptance-reconciliation), [#43 independent failure readers](relation-readers.md), [#44 hierarchy](hierarchy.md), actual AppB traversal/graph controls. Accepted finite cycle/refusal/order/cleanup/capacity cases remain qualified; graph restore **#60**, wider app combinations **#61**. Exact branded TS error constructors are mechanisms. |
| Requirement (4), Runtime (23) | Bevy SystemParam availability/initialisation plus selected checked admission, `schedule-provision`, `ordinary-schema-provision`, `ordinary-app-service-registration`, `ordinary-machine-initialization-marker`, `world` | [#34 schedule/provisioning](README.md), [native admission and component-state distinction](../reference/core-map.md#current-parity-checkpoint--2026-10-16), #46 constructors and #48 machine initialization; AppA reaches actual registrations and ordered schedule. JS host service objects are not required core representation. Unresolved independent-world numeric authority **#38**, basic restore **#59**, graph/checkpoint **#60**, full native composition **#61**. `streamCapacity` is a reference constant; native selected boundary tests retain their actual contract, not an inferred universal capacity. |
| Schedule (28) | Bevy ordered schedules, run conditions, deferred/state markers; `schedule`, `captured-schedule`, `captured-schedule-composition`, `ordinary-machine-handler-bundle` | Accepted #34/#35 scheduling, [#51 heterogeneous captured schedules](captured-schedules.md), [#49 handler phases](handlers.md); actual AppA true/false/true and retained B while A skips. TS arrays and marker token representation are mechanisms. General combinations and exact rejection predicate matches **#61**; no implicit flush or whole-tick rollback is introduced. |
| Snapshot (6) | Existing bounded persistence contract, related to Bevy reflection/scenes; `snapshot`, `snapshot-product`, `snapshot-leaf`, `snapshot-gate`, native construction codecs | [#58 independent save and current-source join](snapshot-export.md#semantic-acceptance-reconciliation) accepted; **#59** validate-before-mutate basic restore and **#60** ordered graph/machine save/restore remain open. TS `unknown`/JSON DTO/parse interface and shallow shared-value aliasing are archived host mechanisms, not permission to alias affine owners. |
| System (48) | Bevy typed SystemParams/Local and selected failures; ordinary component/resource/query/capture/event declarations, captured composition | [#50/#51](captured-schedules.md), [#52 selected-field recovery](recovery.md#selected-resource-fields), [#53 owned publication/query/resource](affine-events.md#selected-ownership-boundary--2026-10-16), [Data events](typed-data-events.md), lifecycle/failure readers. AppA's 46,717-byte handoff reaches these distinct boundaries sequentially. Declared grants, reader identity and affine Type preservation are accepted finite witnesses; custom providers/builders remain trusted, arbitrary host effects/disposal are not inferred. Full combinations **#61**, subscribers **#57**, restore **#59/#60**. |
| index (223 root keys) | Reexports only | Exactly the thirteen namespace rows above and their 210 aliases; no independent capability or missing runtime. The fixture helper is excluded. |

Source anchors for the native interpretation are pinned Bevy
`world/mod.rs`/`entity/mod.rs`/`world/identifier.rs` (identity and storage),
`bundle/mod.rs` and `system/commands/mod.rs` (structural changes),
`system/system_param.rs` (`Local`, resource/system authority),
`query/{fetch,filter}.rs`, `schedule/condition.rs`, `relationship/mod.rs`,
`message/messages.rs` (`drain`/`update_drain` return owned values),
`bevy_state/src/state/{resources,transitions}.rs` (NextState and ordered
OnExit/OnTransition/OnEnter), and `bevy_scene` (scene/reflection infrastructure).
Bevy does not itself select Bendvy's automatic failed-call inverse rollback or
whole-runtime checkpoint policy; those remain the approved SPEC adaptation and
open persistence decisions respectively.

### All 67 bound Game/Runtime keys

Prefixes are exactly `Schema.Schema.Game` (“Game”) and `Runtime.Runtime`
(“Runtime”) in the frozen census. Container keys are counted once alongside
their callable children; a TS namespace object is not an affine runtime owner.
Each row maps every named key to the public-module evidence/remaining owner above.

| Exact relative keys | Count | Contract/evidence route |
| --- | ---: | --- |
| Game `schema`, `EntityScope`, `Inspector`, `StateMachine` | 4 | Schema, EntityScope, Inspector, Machine rows respectively |
| Game `Entity`, `Entity.handle` | 2 | Entity; actual returned-handle application provenance, #38 remaining policy |
| Game `Query`, `Query.read`, `.write`, `.optional`, `.added`, `.changed`, `.readRelation`, `.optionalRelation`, `.readRelated`, `.optionalRelated` | 10 | Query; last four also Relation; exact combined query/graph predicates #61 |
| Game `Command`, `Command.spawn`, `.insert`, `.entry`, `.entryResult`, `.entryRaw`, `.relate` | 7 | Command/Definition, Decode for raw input, Relation for relate |
| Game `Condition`, `Condition.inState`, `.stateChanged`, `.not`, `.and`, `.or`, `.check` | 7 | Condition/Inspector and Machine; immutable reads/requirements, lazy composition |
| Game `System`, `System.readResource`, `.writeResource`, `.readEvent`, `.writeEvent`, `.service`, `.machine`, `.nextState`, `.readTransitionEvent`, `.transition`, `.readRemoved`, `.readDespawned`, `.readRelationFailures` | 13 | System; service→Requirement/Runtime, machine/transition→Machine, failure→Relation; actual current-call event/query/resource atomicity stays distinct from AppA's sequential recovery/publication |
| Game `Schedule`, `Schedule.transitions`, `.onEnter`, `.onExit`, `.onTransition`, `.when`, `.applyDeferred`, `.applyStateTransitions` | 8 | Schedule/Machine; marker timing, failure/retry and nested handler evidence |
| Game `Runtime`, `Runtime.make`, `.service`, `.services`, `.machine`, `.machines` | 6 | Runtime/Requirement; declared service and machine initialisation, native validation |
| Runtime `schema`, `services`, `resourceValues`, `machineValues`, `__schemaRoot` | 5 | Schema/Runtime metadata; TS object-property/brand shapes are mechanisms |
| Runtime `tick`, `tryTick` | 2 | Schedule and checked provisioning; first-failure stop/earlier commits, explicit barriers |
| Runtime `snapshot`, `restore`, `inspect` | 3 | Snapshot (#58/#59/#60), Inspector (#54/#55); a bound method's presence is not full restore acceptance |

### Source tests and static rejection boundaries

The following partition includes **every case and marker in each named file**;
there are no excluded test files. Exact titles, start/end lines and each marker's
following operation are retained in the hash-matched lossless census, so this
summary does not copy their 25 MB type graph into a live contract. Counts are
`it / suite / explicit rejection marker`. Runtime tests are TS reference-source
scenarios, **not newly executed TS evidence**. Cited native reviews establish
only their actual matching predicates/observations. A named test containing
several operations does not become qualified merely because its module is
accepted: remaining exact combined-predicate joins are owned by **#61**, with
specific open feature gates below. Historical static TypeScript assertions are
not Bend negative transcripts.

| Pinned source under `packages/core/` | Counts | Every scenario → native evidence/remaining owner; explicit exceptions |
| --- | ---: | --- |
| `test/Concepts.test.ts` | 1 / 1 / 0 | Guide application → ordinary Schema/Command/System/Schedule routes; full guide's combined correspondence #61. |
| `test/Condition.check.test.ts` | 8 / 1 / 0 | Read-only resource/query gating, previous writes, lazy machine combinations, requirements, naming → Condition/Machine/Debug. Predicate-thrown JS exception is host behavior, not a Bend exception contract. The accepted Check/checked-reader rows above supply reached lazy and cursor-preservation witnesses; exact remaining per-case correspondence #61, full Inspector #54. |
| `test/Decode.test.ts`, `test/Descriptor.State.test.ts` | 3 / 1 / 0; 4 / 1 / 0 | Native validation/path/handle and component compare-and-set/change/rollback → Decode/Entity/Machine; unknown state on restore #59/#60. |
| `test/Feature.test.ts` | 3 / 1 / 0 | Typed composition/order/collision → Feature/Schema; erased-JS throw style is mechanism, native deterministic refusal remains required. Exact combined correspondence #61. |
| `test/Runtime.commands.test.ts` | 7 / 1 / 0 | Ordered insert/remove/despawn/deferred visibility and plain/validated entries → Command/Decode; accepted Bundle evidence and actual AppA. Exact operation combinations not present in those consumers #61. |
| `test/Runtime.debug.test.ts` | 13 / 2 / 0 | Opt-in absence/population/description/access/lints/stream state → Debug (#56/#55). Cases at lines **120,169,191,276,296,320** require write/rollback/skip/missed/listener observations → #57; read-only dump evidence cannot satisfy them. |
| `test/Runtime.events.test.ts` | 12 / 1 / 0 | Order, independent readers, failure/retry, skip, late activation, retention/capacity and Inspector lag → Data-event/System/Inspector rows; [full Data capacity evidence](typed-data-events.md#complete-capacity-boundary-and-stack-repair), #53 owner-specific differences explicit. Remaining exact app predicates #61, full Inspector #54. |
| `test/Runtime.lifecycle.test.ts` | 7 / 1 / 0 | Added/changed, independent/failed/skipped readers and removed/despawned retention → Query/System lifecycle routes; retained native lifecycle/control evidence, combinations #61. Retained removal records do not prove IO cleanup. |
| `test/Runtime.query-lookup.test.ts` | 13 / 1 / 0 | Zero/one/multiple, optional/with/without, mutable cells, missing/mismatch, stored handles → Query/Entity; actual current query consumers, #38 stale/reuse domain policy, #61 exact unmatched lookup/cardinality diagnostics. Ordinary Required/Optional/With/Without Check families now have direct complete witnesses; their existence does not qualify every lookup error. |
| `test/Runtime.relations.test.ts` | 10 / 1 / 0 | General cycles, inverse/hierarchy cleanup, deferred relate/unrelate/reorder and failure readers → Relation; accepted #42/#43/#44 finite predicates, #61 application joins. |
| `test/Runtime.requirements.test.ts` | 1 / 1 / 0 | Erased-schedule preflight before effects → Runtime/Requirement; existing #34 nested provisioning and reached-leaf resource/machine Check admission. Exact service/resource/machine preflight occurrence mapping remains #61; no new eager-union policy is inferred. |
| `test/Runtime.resources.test.ts` | 11 / 1 / 0 | Seed/persist/union/read-write, constructed success-only writes, descriptor provisioning/service identity → Runtime/Decode/System; #46/#34 accepted finite use plus the selected-resource construction review above (input/custom/cooked refusal, actual undo/retry, sibling preservation). Exact remaining descriptor/provisioning case correspondence #61; restore #59/#60. Descriptor-name versus JS property-key layout is mechanism. |
| `test/Runtime.scheduling.test.ts` | 8 / 1 / 0 | Selected schedules, order, markers, flattening/duplicate/invalid entries → Schedule; source-level invalid arbitrary JS entries have no direct typed Bend value counterpart; native duplicate/refusal cases retain their own evidence, exact joins #61. |
| `test/Runtime.snapshot.test.ts` | 7 / 1 / 0 | Save/transient omission → #58; cases at **64,93,108,138,194** include restore/allocator/validation/change notification → #59/#60/#38 as applicable. **175** Standard Schema is archived host adapter; no new native gate. JSON serialization shape is host tooling. |
| `test/Runtime.stability.test.ts` | 4 / 1 / 0 | ECS rollback, scope cleanup, Inspector preservation, failed transitions → System/EntityScope/Inspector/Machine; #52/current AppA return-owner retry adds stronger affine observation, combinations #61; general Inspector #54. |
| `test/Runtime.state-machine.test.ts` | 20 / 1 / 0 | State/queued writes/conditions/order/transition readers/handler attachment/duplicate/nested marker/comparator identity → Machine/Schedule; accepted #48/#49 predicates, actual AppB, remaining combined type/handler mappings #61; persistence #60. |
| `test/Runtime.storage.test.ts` | 8 / 1 / 0 | Deferred queues, spawn ordering, live query values, stale command target, staged relations, identity-vs-display-name/erased collisions → Command/Query/Schema; #38 numeric/generation decisions and #61 exact combined witness joins. No TS borrowed-alias promise for affine Type. |
| `test/Schedule.when.test.ts` | 6 / 1 / 0 | Group/nested conditions, markers despite skip, shared reader identity, duplicate systems and machine needs → Schedule/Machine/System; accepted conditional/captured schedules plus actual staggered fast/slow checked-reader preservation. Exact collective-versus-per-system/group-reader correspondence remains #61; no new group evaluation policy is selected. |
| `test/utils/fixtures.ts` | 0 / 0 / 0 | Test setup and `readResourceValue`; helper calls are attributed to their underlying native operations, not a public export or another scenario. |
| `dtslint/Architecture.tst.ts` | 1 / 1 / 1 | Wide composed schedule + missing resource → Requirement/Schedule; TS map-normalisation/compile-cost mechanism archived; intended native absence-before-effects predicate #61. |
| `dtslint/Cells.tst.ts` | 6 / 2 / 4 | Read/write/constructed/optional/schema/slot proofs → Query/Decode/Command; current selected-field construction controls reach same-payload identity, write-through-read, cross-schema payload and affine-input boundaries. Other intended negatives reuse only matching actual native controls; unmatched static predicates #61. |
| `dtslint/Command.tst.ts`, `dtslint/CommandEntries.tst.ts` | 9 / 1 / 2; 3 / 1 / 5 | Descriptor-bound heterogeneous entry values, raw constructor eligibility, retained draft ownership → Command/Definition/Decode; Bundle/native construction controls; TS inferred tuple shapes archived; exact remaining type predicates #61. |
| `dtslint/Condition.tst.ts` | 5 / 1 / 19 | Read-only exact context, no cursor-consuming access/services/writes/change filters, schema/Bool and propagated needs → Condition/Inspector/Requirement; current Check factory/composition authority controls and actual checked-reader no-consumption witnesses; remaining marker-to-intended-diagnostic correspondence #61 and broad Inspector/compiler boundary #54. TS-only service/filter context mechanics are not automatically new native restrictions. |
| `dtslint/Debug.tst.ts` | 5 / 1 / 0 | Enabled-only handle, fallible construction, literal options, schema-bound dump/name → Debug/Decode; zero markers does not mean zero static assertions. Literal TS flag/conditional property mechanics archived; native enabled-only/confined evidence #56, exact other predicates #61. |
| `dtslint/Identity.tst.ts` | 7 / 1 / 7 | Descriptor/key/name collision, look-alike type, distinct system display names, fragment collisions → Schema/Feature/Entity; native #39/#40 controls and #38 authority scope; unmatched static predicate joins #61. |
| `dtslint/Runtime.tst.ts` | 19 / 3 / 17 | Initialization, constructed failure, service/resource/machine requirements and composed app propagation → Runtime/Requirement/Decode/Feature. Cases **438,456** gate persistence #58/#59; **474** Standard Schema archived; **490** native codec eligibility #46. JS record key/old tuple syntax is facade classification, not missing native API. Other exact predicates #61. |
| `dtslint/Schedule.tst.ts` | 4 / 1 / 2 | Explicit reusable fragments/phases/nested composition → Schedule; native nominal/owner/order controls, exact TS inference assertions archived and unmatched native predicates #61. |
| `dtslint/Schema.tst.ts` | 15 / 1 / 43 | All fragment/collision/schema/access/lifecycle/lookup/relations/feature predicates → Schema/Query/Relation/Feature/Entity. **18** barrel topology is TS facade; **599** durable-handle generation boundary includes #38. Existing native refusals remain bounded; all unjoined type assertions #61. |
| `dtslint/Stability.tst.ts` | 6 / 1 / 3 | Failure propagation, scopes, Inspector projection and transition failures → System/EntityScope/Inspector/Machine. Fx inference/void facade mechanics archived; native exact outcome/ownership controls reused, #54/#61 remainder. |
| `dtslint/State.tst.ts` | 3 / 1 / 9 | State values, graph transitions/exact graph → component State/Decode; native accepted graph/state controls; TS union exactness is language mechanism, remaining predicate correspondence #61. |
| `dtslint/StateMachine.tst.ts` | 14 / 1 / 14 | Machine value/schema/initialisation/conditions, context confinement, bundle requirements and nested-marker refusal → Machine/Schedule/Requirement; native #48/#49 controls, exact multivariate predicate correspondence #61. |
| `dtslint/System.tst.ts` | 3 / 1 / 5 | Declared context, reusable access fragments, unknown categories → System/Schema; ordinary grants and two-schema/undeclared/write/affine controls; TS open-object representation archived, exact remaining native predicates #61. |
| `dtslint/Values.tst.ts` | 5 / 3 / 2 | Codec/constructed eligibility → Decode (#46); Result/Fx narrowing/error/requirement combinator algebra is archived helper tooling, not a new ECS gate. Native typed outcome/declared needs route System/Requirement; ambiguous extra #61. |

Static mapping is deliberately predicate-based: declaration-derived access
refusal, cross-schema use, write-through-read, abstract-handle escape and affine
owner duplication are separate failure paths. Accepted #41/#46/#50/#51/#52/#53
controls and AppA/AppB actual controls supply finite native witnesses at their
reached boundaries. They do not prove every one of the 133 TS markers is an
executed Bend refusal, nor do TS compile failures establish affine preservation.
The 133 marker boundaries and remaining non-marker `.type` assertions are now
assigned by exact source group; **#61 owns the remaining scenario-to-intended-
Bend-diagnostic correspondence**, with #38/#54/#57/#59/#60's explicit feature
and policy gates above. No absent implementation is inferred solely from a
missing transcript or a TS-only helper.

The actual application additions close the previously concrete gaps of entered
unbound captured B while A skips, component failure→returned-owner retry→owned
publication→scoped query handoff, and selected Product resource-field recovery
with sibling preservation. The [automatic recovery App review](../../experiments/public-recovery/automatic-app-v1/FINAL-REVIEW.md)
also joins canonical declaration-derived debug/access metadata, prior-owner
preservation, current classic compatibility and repeated opaque rejection.
The [ordinary checked predicate review](../../experiments/public-conditions/checked-predicate-v1/FINAL-REVIEW.md)
adds canonical resource Check leaves joined to lazy App schedules, existing
registered machine conditions, actual unbound dispatch and automatic descriptions.
Full stock/TS observations, affected authority controls and a reached eager-RHS
defect qualify that route; TS eager requirements remain an explicit difference.
The [component-query Check slice](inspect.md#ordinary-component-query-check-declarations)
adds canonical Required/Optional/With/Without composition and membership-only
queries, including a query and required resource in one predicate. Complete
first stock normal and reached filtering-mutation pairs, affected authority
controls and current resource compatibility pass; actual TS execution matches
its independent full oracle. [Independent final review](../../experiments/public-conditions/component-query-v1/FINAL-REVIEW.md)
passes; integrated `c524034d2`, CI38901764699 PASS.
The [described machine Check slice](inspect.md#ordinary-machine-check-declarations)
joins a nominal machine read with query/resource grants in one predicate. Its
first stock119,419-byte normal, reached119,371-byte availability defect and
current96,029-byte query/resource compatibility pairs pass; actual TS comparison
matches36,126 independently derived bytes. Five positive/ten intended authority
controls pass. [Independent final review](../../experiments/public-conditions/machine-query-check-v1/FINAL-REVIEW.md)
passes; integrated `88645bf21`, CI38906069050 PASS. Host-driven transitions
are not another registered-handler qualification.
The [described relation Check slice](inspect.md#ordinary-relation-check-declarations)
joins the existing relation declaration with component selections and resource
reads, deriving operational access and automatic descriptions from one input.
Its full ordinary App, incoming-routing defect and previous machine compatibility
pairs pass; actual TS execution matches its independent complete oracle.
All eight modes match the current-source complete 117,959-byte JS/Native oracle;
[delivery review](../../experiments/public-conditions/relation-query-check-v1/FINAL-REVIEW.md)
passes; integrated `521b7dec5`, CI38910846706 PASS.
The [checked reader transport](inspect.md#ordinary-checked-reader-schedules)
adds a reached lazy-Check-before-reader join: both stock backends match59,015
independent bytes with staggered fast/slow reader history, retained completion
arrays, physical stream state and separate World/Family clocks. Its generic
Product family is not another canonical journal qualification. The full 59,039-byte
fold-tick counter and 32,103-byte attachment controls also pass on both backends;
independent [final review](../../experiments/public-conditions/checked-reader-v1/FINAL-REVIEW.md)
passes; integrated `77beba95a`, CI38914934433 PASS.
The [selected-resource construction join](../../experiments/public-construction/selected-resource-v1/FINAL-REVIEW.md)
adds the existing-API final-admission/selected-write boundary, with complete 26,673-byte
normal and 26,453-byte reached admission-omission pairs, actual refused owners,
undo and returned-input retry. Integrated `0b025defe`, CI38919912200 PASS;
its 135 imported canonical core bodies are unchanged. It extends the witnessed
application scope without invalidating closed #46 or inventing a provider API.
Those are finite current public consumers, not a
whole matrix or another independently authored application. Remaining #61 work is to join the
unmatched required predicates to their direct receipts, approved differences or
existing owners. A missing import or arbitrary Cartesian combination is not an
additional requirement. The [two-app current-source join](../../experiments/public-audit61/two-app-current-reuse-v1/README.md) preserves AppA
owned-handoff evidence through metadata-only changes (135 historical sources mapped;
136 current imports), and the [AppB successor](../../experiments/public-audit61/app-b-current-v1/README.md)
passes both complete 17,750-byte current-source observations. Local application edits repair unused renderer APIs; literal path-derived QNames
explain the difference from the historical 14,582-byte oracle. Eight existing core
dependency deltas and a new queue dependency are explicitly joined and exercised
by the current pair; all ten World snapshots and three selected observations remain. Historical
reparent/authority controls retain exact operation-boundary applicability. Independent [final review](../../experiments/public-audit61/app-b-current-v1/FINAL-REVIEW.md)
passes; integrated `0ee4562f4`, CI38921620111 PASS. The #38 pending-metadata successor now re-executes both unchanged application
entrypoints against independently derived full physical observations:
[AppA/AppB successor](../../experiments/public-audit61/pending-metadata-current-v1/runtime-v1/README.md).
AppA matches 47,464 bytes and AppB 13,475 bytes on stock JS/Native. The smaller
AppB output reflects literal root-path QNames; no stripping or normalization is
applied. World/commands bodies change in both closures; every other 134/72
imported body remains exact. The preceding byte-identity applicability is
historical, rather than a claim that these changed bodies are unchanged.
Neither application must duplicate every
feature of the other. New two-schema subsystem consumers do not substitute for
independent authorship. Restore #59/#60, identity #38,
broad Inspector/compiler #54 and subscriber requirements #57 retain their exact
unresolved operations/decisions; none is selected by this documentation update. This
census gives every inventory set a route and existing owner; it does not tick
full #61 delivery, approve an ambiguous extension, or turn historical/private
candidate evidence into stock execution.

## #61 preparation materials — 2026-10-07

Additive **PREPARATION** evidence only; the existing coverage contract and acceptance gates above remain unchanged. The [public-core preparation checkpoint](../reference/core-map.md#61-public-core-audit-preparation--2026-10-07) and [source inventory](../archive/ts-port/core-export-inventory.json) freeze audit base `2296bb5ef5281db4ed78ea8cf6b8b791d2a0ec5e`, all three manifest-matching reference commits, 33 TS source files and the exact current `src/ecs` hashes. Package wildcard exports, public low-level names and the root barrel are distinguished.

Census: 23 top-level modules, 13 barrel namespaces; 493 declaration occurrences /477 lexical keys; 808 nested signature-member occurrences /762 lexical paths; 61 bound Game and12 Runtime signature-member occurrences; 101 private top-level signature dependencies. All20 test files and15 dtslint files are retained:251 test declarations,40 suites,4,999 call occurrences,133 static rejection markers and466 top-level statements. The source catalogue additionally retains84 syntactic error/throw boundaries and62 documented TypeScript use examples. Counts describe syntax, including overloads and nested DTO/callback shapes; they do not claim semantic unique symbols or executed tests.

Every declaration/member has an existing capability-owner route or #61 pending ownership assignment, related bounded evidence lead and concrete remaining gap. Every test/static item explicitly retains its unmet exact evidence mapping. The historical checkpoint catalogues Brand/Definition/Fx/Result helper mechanisms alongside low-level commands, wider Inspector read categories, cross-feature use/error obligations and nine retained receipt/core hash comparisons. Standalone TS helper algebra is archived research, not an approved #61 requirement; the capability classification below governs current scope. Historical recorded passes are distinguished from stale pins, unavailable archived inputs and current joined execution; root #41/#42/#49 and concurrent experimental #54 source closures require separate joins.

Only cheap AST parsing, JSON/count/hash reconciliation and document checks were performed. No source-current #61 public consumer, checker/proof/backend/reference application, mutation, performance stage or full-parity acceptance is claimed. Semantic alias/inheritance/inferred-expression closure and classified source-use boundaries are completed in the appended checkpoint; exact per-boundary executable acceptance remains UNMET under #61; two independently authored schemas/apps and all governing acceptance gates remain required. New specific laws, dependencies and unresolved ownership divergences retain SPEC approval requirements; full numeric product qualification stays in #21/#23/#24.

The [completed semantic/source-use census](../reference/core-map.md#completed-semantic-closure-and-classified-source-uses) expands688 public reachable keys to477 canonical export targets, inherited core members and inferred shapes. It separately identifies67 bound Game/Runtime operation/metadata keys (55 callable) and classifies every4,999 use calls against222 resolved core-operation groups, authored helpers, framework assertions, host calls or intended invalid-member refusal. All source-test/static titles,133 rejection boundaries,84 source error/throw sites and62 documented uses remain source-only until exact application/type/error evidence executes.

[Current selected hash joins](../reference/core-map.md#current-selected-immutable-evidence-joins) reconcile #41's280-member full20 ZIP and221 consumed sources; #49's740 archive members/full96/12 JS and split Native; #42's116-object three-full30 same-artifact JS evidence; and experimental #54's separate37-source JS/Native plans,8/12 raw logs and2/4 generated artifacts. These are immutable source/raw-byte joins with failed/incomplete history preserved, not new backend passes, proof, production acceptance or a performance waiver. Full-core #61 application acceptance remains UNMET.

The lossless [compressed inventory](../archive/ts-port/core-export-inventory.json.gz) and readable [index](../archive/ts-port/core-export-inventory.json) retain complete records with byte/hash reconciliation. The final cutoff additionally joins integrated #42 Native extension `de91f711` (five subjects, three complete30 cases); subsequently approved #49 mutation74 (eight sources/447 archive members) and #54 final evidence (original95 reviewed paths; current91 listed+self92 selected paths/734 objects/2362 records) are additionally hash-joined, with experimental/integration and Native-mutation limitations explicit. These additions change preparation evidence only.


## Integrated evidence maintenance — aea31827

The [integrated capability update](../reference/core-map.md#integrated-capability-update--aea31827) reconciles current contract → implementation → evidence → concrete gap → owning ticket rows without changing the frozen inventory or #61 acceptance. Root12710fab adopts nine generic bundle modules/OwnedRequest and four machine/stream/handler modules with current source/negative, JS/Native and reached-mutant evidence. Rootbcee21cb adds an independently authored runnable core-only bundle bootstrap with exact owner restoration/return; it is a Success-path example alongside the broader full22/20 controls, not the two full-core audit applications.

Inspector21ff8196 integrates closed-declaration eight-row JS/Native baselines;856fe561 additionally integrates reached lens-routing/metadata-order complete eight-row CLI/JS/Native defect controls. Those historical candidate milestones are superseded for module adoption by61e85364 below; full #54 acceptance remains open. The closed descriptor index with runtime Arrays/Extra is the selected design; the rejected runtime-Plan alternative is not recorded as an unmet requirement. Eight relation modules were subsequently adopted at68327d49 after current semantic evidence d42a9c34 and reviewed byte-identical #28 reuse; full #42 remains open. General stream policy #48, reusable affine captures #50 and public affine events #53 remain pending; trusted internal Data handler events do not resolve them.

The combined bundle/handler unchanged #28 cohort has a separately reconciled NO_CONFIRMED_REGRESSION decision; its original inventory-guard ERROR receipt remains unchanged. Workshop current/baseline ratios JS0.88695/Native0.98262 do not establish equivalent-feature timing/scaling or final #21/#23/#24 product targets. This documentation maintenance performed source/report/link checks only; no inventory regeneration, backend replay, benchmark, new contract or #61 closure.

## Subsequent relation adoption — 68327d49

The [capability maintenance](../reference/core-map.md#subsequent-relation-adoption--68327d49) joins the eight adopted relation modules to current-root full52 reorder JS/Native normal and three reached controls, retained full30 world traces and bounded static-authority joins. Adoption is distinct from full #42 acceptance: complete N1024 output, unmatched correctness families, failure-stream integration and fair full-feature performance remain open. The existing unchanged Workshop #28 evidence was reused after exact current source/archive/harness joins, without another paired run.

Inspector readiness b52a0ccf and later current-source finite handoffs now support adopted seven-module Inspector/Check core at61e85364. The [current capability rows](../reference/core-map.md#inspectorcheck-and-machine-helper-adoption--61e85364) link normal, refusal, 74/84 CLI, three reached mutants and retainer20 evidence. Two machine-world/conditions helpers are also adopted; the independent capability caller Native gate for #49 remains open. Canonical constructors remain trusted and universal metadata truth is not claimed. Full #54 broader boundaries/dependencies and the frozen #61 two-application audit remain open.

Fresh unchanged [#28](../../benchmarks/evidence/inspector-handlers-20261008/REPORT.md) reports NO_CONFIRMED_REGRESSION with JS0.882504/Native1.056596 median paired current/baseline ratios. Native was slower in this cohort without statistical confirmation; this is not equivalence. Descriptive JS/TS0.401842 and Native/TS0.096579 apply only to Workshop, not complete feature performance. No inventory regeneration or backend replay accompanies this maintenance.

## Subsequent public snapshot/Core preparation — base1ebb743c

The [existing core map refresh](../reference/core-map.md#snapshotpublic-core-audit-preparation-refresh--base1ebb743c) and inventory `currentSnapshotAuditPreparation` preserve the full 23-module census and classify all export occurrences while recording 33 exact TS core pins, 69 master core pins and 16 proposed src-module pins. Whole actual-src snapshot/Family and reached recipe-restoration control reports pass JS/Native development with byte-identical pairs; source/receipt/evidence states remain separately named. The sixteen canonical snapshot/declaration modules are now adopted on master in `f8d7ef58`, with source-current import checking and unchanged Workshop regression PASS. The earlier source timeout remains retained; full snapshot acceptance remains incomplete.

The joined native semantic review for #46 reports PASS; #46 remains open pending integration, the issue report and CI. Generic constructor/admission and complete-codec work outside that reviewed scope remains with #41/#59; full snapshot/restore graph/machine/runtime lifecycle remains #58/#59/#60; ordinary debug binding remains #56/#57; complete joined public ECS apps remain #61. Standalone TS helper algebra stays archived for optional tooling; see the [explicit reuse index](../archive/ts-extension-index.md). In particular, `world.factory()` restarts `Factory{1}` and independent factory roots are not globally unique. Current foreign-world controls use one threaded Factory, so independent-root collisions and caller-fabricated authority stay under existing #38/#45. No new authority contract or duplicate plan is created. This is source/evidence maintenance only; #61 stays OPEN and all acceptance criteria above remain unchanged.

## Evidence maintenance — 2026-10-09

These updates supplement the historical inventory; they do not regenerate its
export census or qualify the full public core.

| Contract / owner | Current implementation | Exact evidence | Concrete remaining gap |
| --- | --- | --- | --- |
| #42 directed/inverse links, barriers and complete traversal | Eight adopted relation modules; experimental direct serializer preserves whole feature trace | `4348080a` JS and `dcafa6c4` Native: all nine complete cases, including N1024; `984e1fa4` current last-leaf/moved-force controls reject on JS/Native. [Native normal review](../../experiments/public-relations/timing/current-qualification-v1/phase2/remainder-v1/chunk-serializer-v1/whole-feature-timing-v1/direct-native-evidence-v1/REVIEW.md), [Native controls](../../experiments/public-relations/timing/current-qualification-v1/phase2/remainder-v1/chunk-serializer-v1/whole-feature-timing-v1/direct-mutant-native-evidence-v1/REVIEW.md). | #42 delivery and unchanged regression/full-feature timing gates; #43 independent failure readers. Serializer evidence is not another core adoption or fair timing claim. |
| #43 independent registered relation-failure readers and bounded retention | Eight canonical modules adopted on master `f8d7ef58`; complete opaque-ValueRead consuming fixtures | All eight promoted finite, reached-mutation and fullcapacity JS/Native cohorts PASS, independently reviewed. [Capacity review](../../experiments/public-relation-readers/current-adoption-v1/oracle-v1/promoted-consumer-capacity-actual-review.md): whole 244,722,906-byte outputs match; root archive verifier passes all eight. Pinned TS `92e0c24c` covers all 52 observations. | Master-relative finite JS/Native and unchanged Workshop regression pass; full-feature performance and remaining acceptance stay in #43. Installed recursive JS printer is unqualified; copied iterative printer is diagnostic. |
| #46 validated constructed/transient declarations, atomic admission and returned affine owners | Adopted typed construction core; current bounded consumers are mapped in the [#46 evidence review](validation.md#current-bounded-evidence-map-2026-10-15). | The joined native semantic review reports PASS. The evidence map scopes the matching stock JS/TS/Native 32-case result, complementary 92/22/40 observations, authority controls, and source/tool limits. Earlier generic15/deferred8 outputs remain separately reviewed (`e96cd42c`, `54d4731c`); the typed registration/finalization adapter source review passes (`4e9f141d`). | #46 remains open pending integration, the issue report, and CI. R7 assigns comparative timing/scaling to the combined #21/#23/#24 workload, not a separate #46 gate. Standard Schema/JavaScript host integration is archived and outside native acceptance unless separately approved; transient save/restore remains under #58/#59. #41 owns the unresolved global activation/recovery policy. |
| #56 enable-debug descriptions/dumps derived from ordinary declarations without side effects | Integrated ordinary Schema/App/query/resource/schedule/machine/relation/selected-stream and machine-handler entrypoints derive descriptions from their operational declarations. The declaration-derived ordinary component/resource access index is integrated at `25a1e0eb4`. | [Current ordinary entries](debug.md#current-ordinary-entrypoints-and-remaining-coverage) links exact bounded reviews. Machine-handler App adopted at `f505ec961`: [final review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-machine-handler-app-v1/FINAL-REVIEW.md) verifies ten full JS/Native outcomes, 25 commands/85 guards and authority boundaries. Earlier full71-source copied-compiler diagnostics remain historical, not stock acceptance. | Complete static inventory, cross-schedule access/lints, custom-store population adapters, filtered whole-world dumps and naming remain #56; #55/#57 dependencies and full #61 applications stay open. The [access-index review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-access-index-v1/FINAL-REVIEW.md) qualifies twelve full JS/Native outputs, seven query modes, two schemas and authority controls. Combined156 excludes later stream/handler/index additions; The [same-World event/index review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-event-access-v1/unified-v1/FINAL-REVIEW.md) qualifies six current full outputs, 15 commands/51 guards, six authority refusals and reached grouping control. Current combined regression and complete feature timing remain pending. |

Reference authority remains the frozen census: bevy-ts `3040a3b2…` (0.3.0) supplies the public surface/use scenarios, Rust Bevy `ad678262…` supplies ECS architecture, and Bend `a950fd68…` plus exact installed compiler/Base receipts supply affine/type/runtime boundaries. The [existing source inventory and authority anchors](../reference/core-map.md#rust-bevy-and-bend-authority-review) are unchanged. All rows distinguish experimental execution from integrated public capability; none substitutes for two independently authored complete public #61 applications or full numeric qualification under #21/#23/#24.

Use the [coordination table](README.md#current-delivery-coordination) for subsequent task state;
experimental evidence remains distinct from `src/ecs` delivery and performance.

## Construction audit overlay — master `64807397`

This source-only #61 preparation supersedes the earlier constructor-absence entry,
not the export census or complete parity gates. Reference pins remain bevy-ts
`3040a3b2`, Rust Bevy `ad678262` and Bend `a950fd68`; installed-runtime evidence
uses the separately pinned Bend 2.0.35 bytes.

| Contract → integrated API | Actual evidence | Concrete gap → owner |
| --- | --- | --- |
| Descriptor raw validation before construction → `decode-construction` retained nominal Factory, separate input codec, typed constructor and schema-authored undo | [Core delivery](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/CORE-DELIVERY.md): all 44+20+16+12 complete reports on JS/Native, four source spines and 14 authority/affine negatives | Arbitrary affine Type has no inferred inverse or reflection. The joined #46 native semantic review reports PASS; integration, issue report and CI remain. Comparative timing/scaling belongs to combined #21/#23/#24 under R7. Standard Schema/JavaScript host interop is archived separately, outside native acceptance unless explicitly approved. |
| Spawn/insert accepts constructed payload or returns exact raw owner → `decode-constructed-requests`, `decode-fallible-constructed-requests` | Same canonical full reports and three reached full mutation witnesses; custom construction and operation errors remain distinct | Complete reusable heterogeneous bundle delivery/readiness remains #41; these adapters do not choose unresolved global activation/recovery policy. |
| Resource admission preserves rejected owner → `decode-validated-resource`, `decode-constructed-resource`, `decode-fallible-constructed-resource` | Canonical actual JS/Native reviews and promotion Spec/Standards reviews linked from Core delivery; successful undo retained | Host Standard Schema conversion is a separate archived adapter experiment, not native ECS evidence. JavaScript lone-surrogate object keys and paths are host-interop scope, not Rust Bevy reflected-field requirements; see the [archive boundary](../archive/ts-extension-index.md#native-field-names-and-javascript-object-keys). Transient save/restore remains separately owned by #58/#59. |
| Ordinary debug derives structure/access/schedule without duplicate metadata → integrated ordinary Schema/App and selected machine/relation/schedule/stream/handler entrypoints | [Current source-bound entry reviews](debug.md#current-ordinary-entrypoints-and-remaining-coverage), complete nominal/reached JS/Native observations; machine-handler adoption `f505ec961` | Bounded public entrypoints are adopted; complete static/cross-schedule access/custom-store population/dump/naming coverage, dependencies and performance remain #56/#55/#57. The same-World C/R/Data-event index and ordinary Column/Product population are adopted, with their exact bounded reviews linked from the current debug inventory. The historical giant consumer and copied compiler diagnostics do not qualify those remaining operations. |

Architectural anchors: pinned TS `Decode.ts:161` enumerates actual object keys and
`Descriptor.ts:513` adapts Standard Schema; Rust `world/mod.rs:1243,2056` uses
typed Bundle/Resource admission and `bundle/mod.rs:202` defines the unsafe Bundle
contract. Bend README:226 makes closures/arrays affine. The delivered factories
therefore use retained nominal declarations and explicit reversible constructors,
rather than promising TypeScript-style host reflection for arbitrary Type.

The unchanged Workshop regression passes independently (current/frozen Bend
JS 0.90532474, Native 0.98513866); that bounded workload does not qualify the
full simulation, whose matched current JS/TS ratio remains 3.34450. #61 stays
open: two independently authored complete public applications and the remaining
capability/performance gates are still required.

## Capability scope reconciliation — #61 preparation

[Current SPEC decisions](../SPEC.md#implementation-decisions) and the
[porting workflow](../agent-workflow.md#porting-scope-and-concerns) govern this
overlay: required scope is Rust Bevy capabilities represented in pinned bevy-ts,
plus explicitly approved extras. An export, existing issue or prior experimental
execution does not approve a TS-only mechanism. This classifies all 23 existing
inventory modules without changing their census or closing #61.

Status: **required** means the underlying Bevy capability; **existing contract**
means an explicitly retained SPEC/user decision (not a newly approved extension);
**pending** means a TS-only mechanism or unresolved observable adaptation. Mixed
modules are not approved wholesale. Owners below are existing tracking issues,
not evidence of permission.

| Inventory module | Underlying capability / scope status | TS mechanism or unresolved extra | Existing owner |
| --- | --- | --- | --- |
| Brand | Required typed identity/authority | JS symbols and structural phantom brands are language mechanisms; use Bend nominal/schema indices | #38/#61 |
| Command | Required deferred structural commands, bundles and barriers | JS callback queue representation is not required; existing foreign-command MissingEntity contract remains binding | #41/#38/#35 |
| Condition | Required read-only run conditions | Inspector callback/context facade is a mechanism; no broader mutable predicate contract inferred | #54/#55 |
| Debug | Existing contract: opt-in read-only descriptions/dumps and observations (SPEC story30; user #56 enable-debug rule) | Particular TS DTOs, subscriptions and presentation helpers are not wholesale requirements; arbitrary Type presentation remains explicit | #56/#57 |
| Decode | Existing contract: typed native validation and exact constructor/refusal owners | Standard Schema, unknown/JS-number reflection and host bridge pending separately; exact TS decoder helper algebra not automatically required | #46/#59/#61 |
| Definition | Required reusable typed component/bundle declarations | Tuple/record mapped-type helper APIs are TS mechanisms; no separate generic JS record algebra approval | #41/#46/#61 |
| Descriptor | Required components/resources/events and typed state; existing native construction/persistence contract | Symbol descriptors, Standard Schema adapters pending; transient save omission is an existing bounded persistence contract, not universal host reconstruction | #46/#47/#53/#58 |
| Entity | Required entity handles, lookup/liveness and safe mutation | Intent/proof/draft TS brands are mechanisms; approved world isolation supersedes TS colliding-ID behavior | #38/#41/#60 |
| EntityScope | Existing contract: grouped lifetime cleanup (SPEC story26) | Named nominal scope-token implementation differs from Bevy relationships/state-scoped cleanup; complete persistent/restore behavior remains unresolved | #45/#60 |
| Feature | Required reusable application composition; existing schema/feature scope (story5) | TS pre-bind Game builder and lexical feature-access typing are mechanisms, not exact API targets | #39/#40/#61 |
| Fx | Existing contract: typed system failure/read-your-writes/failed-system rollback | Delayed Fx environment, map/flatMap/access/provide/runSync package algebra is TS-specific and pending as a standalone API | #50/#51/#52/#61 |
| Inspector | Required read-only query/resource/stream access and run conditions; existing observation contract | Unified TS Inspector/check facade is a mechanism; declared access and noninterference required, every helper/export is not | #54/#55/#56 |
| Machine | Required represented Bevy state/NextState and enter/exit/transition schedules | TS values-array machine declarations and generic state-machine facade require Bend-native adaptation; full enumerable state universe is not inferred from Family | #48/#49/#55/#56 |
| Query | Required read/write/optional/with/without/lifecycle selections | JS cell/result wrapper algebra is a mechanism; arbitrary affine owner recovery requires its selected contract, not copying host aliases | #35/#42/#47/#51/#52/#61 |
| Relation | Required directed/inverse relationships, hierarchy and cleanup | TS name/pair brands and failure-result wrapper shapes are mechanisms; exact traversal/refusal contracts remain tracked | #42/#43/#44 |
| Requirement | Required system parameter/resource availability/access; existing checked provisioning (story10) | Nominal union of descriptor/machine/host-service tokens is a mechanism; JS service/environment integration is not implied | #34/#54/#55/#61 |
| Result | Required fallible typed outcomes where selected | Tagged JS Result helper package, exact combinator surface and exception conventions are not standalone approved extras | #46/#51/#61 |
| Runtime | Required world execution, schedules, commands and readers | Bound JS Game/runtime object is a mechanism; automatic failed-system rollback is an existing explicit Bendvy contract, not Rust Bevy default behavior | #35/#38/#50/#53/#61 |
| Schedule | Required order, phases, conditions, deferred application and state-transition schedules | Nested JS arrays/marker tokens are mechanisms; no implicit rollback/flush beyond selected contracts | #34/#35/#48/#49/#52 |
| Schema | Required typed component/resource registration and access isolation; existing fragments contract | JS record merging, reflected names and bound Game factory are mechanisms. JavaScript UTF-16 object-key/path round-tripping is archived host scope, not a native field-name gate; ordinary Unicode string names remain in scope. | #39/#40/#46/#61 |
| Snapshot | Existing contract: explicitly bounded save/restore (story29); Bevy reflection/scenes support related capability | TS whole-World DTO, validation gates and allocator/runtime reconstruction are not interchangeable with Bevy scene serialization; exact restore policies remain open | #58/#59/#60 |
| System | Required typed SystemParams, Local, repeated systems, access and failure | JS captured aliases and closure ownership do not transfer to affine Type; #50/#53 capture/event policies must be selected explicitly | #36/#50/#51/#52/#53/#61 |
| index | Reexport inventory only; inherits each capability's status | Barrel namespace/path compatibility is not a runtime capability | #61 |

Primary-source anchors (same frozen pins as the census): Bevy
`bevy_ecs/src/world/mod.rs:1243,2056` and `bundle/mod.rs:202` establish typed
spawn/resource/Bundle boundaries; `system/system_param.rs:262,1189` supplies
SystemParam/Local; `schedule/condition.rs:75` supplies run conditions;
`relationship/mod.rs` supplies relationship architecture;
`bevy_state/src/state/transitions.rs:19–68` supplies transition schedules/events.
Bevy `reflect/component.rs:81,146` requires explicit reflection registration; it
does not provide an inverse for every arbitrary affine Bend Type. TS
`Descriptor.ts:95,157,513` separates constructor, transient and Standard Schema
mechanisms; `Decode.ts:161` uses JS object-key reflection; `Fx.ts` documents
failed-system rollback through its effect facade; `Snapshot.ts:78–126` defines
its particular saved DTO/errors. Bend README:226 and installed Base
`Nat.read`/type definitions supply affine/runtime constraints; pinned reference
source and installed compiler provenance remain distinct.

Outstanding scope decisions are genuinely separate: Standard Schema and JS-host
interop; standalone Fx/Result/Definition helper parity; any TS-specific inspector
facade beyond approved read-only capabilities; complete machine enumeration or
runtime snapshot reconstruction beyond selected contracts. Existing typed native
validation/construction, approved rollback and #56 enable-debug requirements
continue. Their current experimental or integrated evidence does not approve
these extras. Full public applications, capability evidence and numeric gates
remain open under their existing owners and #61.

## Inspector/debug audit overlay — master `32e183cab`

Preparation only. The current integrated surface contains 111 top-level core
modules; the frozen TS export census and capability scope reconciliation above
remain unchanged. Rust Bevy semantics govern World-bound state validation while
static declarations may be reused; Bend requires affine owners and detached Data
views. TS facade/DTO/helper compatibility is not an additional mandatory scope.
No registered-system liveness requirement is inferred for ordinary inspection.

| Contract / existing owner | Integrated implementation and concrete evidence | Remaining acceptance gap |
| --- | --- | --- |
| Read-only arbitrary-product query composition, declared presence/lifecycle selection → #54 | `ordinary-component-binding`, `ordinary-inspector-declaration`, `inspector-query-projection`, `inspector-query-families`, `inspector-query-world`, `ordinary-query-selections` and `inspector-query` are integrated. [Independent delivery review](../reviews/canonical-inspector-delivery/review-2026-10-09.md) joins four stock leaf JS/Native cohorts, full23 normal/reached-reader JS and six source/API controls. | Complete23 stock Native remains incomplete (emit30/no C; reader Native held), broader resource/stream and held-view ownership boundaries remain, and feature performance is not qualified. |
| One ordinary Binding/declaration drives both operational and inspection lowerings and actual registration → #56 | `ordinary-query-observable` and additive `ordinary-system` registration are integrated. [Observable successor](../../experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-system-retention-v1/observable-successor-v1/README.md) qualifies full79 operational JS normal/handler omission; [eight source/API controls](../../experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-observable-api-v1/README.md) retain exact authority/affine diagnostics. Combined111-core unchanged #28 passes `c574ccaf`. | This operational qualification does not execute detached Inspector lowering or finish automatic descriptions/dumps. No registered-cursor inspection entry is adopted; extra registration-liveness semantics were withdrawn rather than introduced. |
| Detached ordinary inspection with independent observation cursor, repeated enabled/disabled preservation → #56/#55 | [Full80 diagnostic review](../../experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-system-retention-v1/detached-observable-generic-v1/diagnostic-js-v1/launch-review.md) verifies normal/filter mutant/handler omission JS, complete outputs, ascending query rows and World/Registry preservation (`e4eae0d7`, `6a2b7d9e`). | The complete source5 prerequisite remains UNMET. These three executions are diagnostic, acceptance=false. [Native diagnostic review](../../experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-system-retention-v1/detached-observable-generic-v1/diagnostic-native-v1/launch-review.md) retains emit30/no C; build/runtime unattempted. Full stock Native, broader #55 categories, public App adoption and feature performance remain open. Family does not imply exhaustive states/transitions. |
| Optional ordered execution observation and subscriber lifecycle → #57 | [Existing trace preparation](debug-trace.md#source-preparation-and-reusable-evidence-2026-10-09) identifies actual schedule/system/transaction/barrier/relation/handler seams and three historical executed TS comparators. Core Schedule `Ran` still conflates success/failure; no subscriber core exists. | Subscriber ownership/delivery/IO adaptations require an explicit contract. Complete failure/order/relation/transition traces, reached disposal mutants, noninterference, disabled publication avoidance and timing/allocation remain unqualified. TS callback Set identity and particular trace DTOs are not automatically approved. |

Later copied-compiler phase/context diagnostics are retained investigation, not
stock source/backend qualification: one full graph traverses 2,043,695 queued
entries representing 3,727 unique definitions before an emission checkpoint
without C. The earlier file_book stop differs; neither observation establishes
an algorithmic cause, improvement or speedup. Original failures remain failures.

Concrete gaps stay with #54–#57; joined cross-feature application coverage stays
with #61 and full numeric product qualification with #21/#23/#24. #38 identity,
#48 initialization/marker adaptations, #50–#53 affine capture/event recovery and
#59–#60 restore policies remain their existing owners' decisions; this overlay
accepts none. No archived TS-only requirement, new contract, new runtime run or
full parity/audit closure is introduced. Current task coordination remains in
[the existing table](README.md#current-delivery-coordination).

## Current capability audit checkpoint — master `015327b09`

Current source/evidence reconciliation; earlier dated overlays remain historical.
The integrated surface now has 148 core modules; the prior 125/140-module gate snapshots remain historical evidence. Rust Bevy capabilities govern scope,
Bend types and affine runtime constraints govern representation, and the archived
TS census remains inventory third. Public adoption is distinguished from private
frontend qualification below. No backend replay or full #61 closure accompanies
this maintenance.

| Accepted capability / owner | Implementation → actual evidence | Specific remaining gate |
| --- | --- | --- |
| Read-only component selection and independent observation visibility — [#54](https://github.com/dearlordylord/bendvy/issues/54) | Adopted [Inspector query](../../src/ecs/inspector-query.bend) and [ordinary bindings](../../src/ecs/ordinary-component-binding.bend) retain leaf JS/Native and source-authority evidence. The complete47 consumer passes stock source5 and whole 5,077,477-byte JS observations; legal lookup-helper and scan-projector successors retain the same full JS scope. [Current delivery](README.md#current-delivery-coordination) identifies the exact `01d1657e3`/`0412feb16` source/evidence checkpoints. | Complete47 stock Native emission still exceeds30 seconds with no C/build/runtime acceptance. Reached-reader/authority coverage, held-view ownership and feature performance remain #54; narrower leaf Native passes do not qualify this whole consumer. |
| Resource-only systems execute once per invocation, including empty Worlds — [#56](https://github.com/dearlordylord/bendvy/issues/56) | Public [ordinary-resource-system](../../src/ecs/ordinary-resource-system.bend) is adopted. Public one-resource normal/rollback-mutant JS/Native outputs match independent2294-byte models with source controls. | This provider replaces physical R as a whole. Selected-field authority is supplied by #70 below; automatic public App observation and full debug composition remain #56. |
| Distinct ordinary resources generate confined affine field grants — [#70](https://github.com/dearlordylord/bendvy/issues/70) | Public [resource-field-binding](../../src/ecs/resource-field-binding.bend), [resource-field](../../src/ecs/resource-field.bend) and [ordinary-resource-field-system](../../src/ecs/ordinary-resource-field-system.bend) are adopted. The [acceptance ledger](../../experiments/public-resource-fields/public-transactions-v1/ACCEPTANCE.md) joins A/B reads/writes, complete owners/World/Registry/queues, provisioning, intended authority refusals, reached wrong-field/inverse controls, actual TS reconciliation and unchanged #28. | #70's finite confinement matrix is complete and the issue is closed. Automatic App use remains #56; general inverses/finalizers #52, identity #38 and broader feature performance retain their owners. Historical baseline checker deadlines remain failed history, not the current promotion status. |
| Ordinary declarations generate debug without user metadata adapters — [#56](https://github.com/dearlordylord/bendvy/issues/56) | The [private generated metadata frontend](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/generated-metadata-frontend-v1/README.md) passes complete11004-byte JS/Native observations: seven snapshots and two actual scheduled runs. [Lazy recipe composition](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/runtime-registration-records-v1/README.md) passes complete3198-byte JS/Native observations for three registrations. [Actual record execution](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/runtime-record-run-v1/README.md) passes complete5414-byte JS/Native success, rollback, retry, harness skip and registration refusal with affine Args/Out. | These are private frontend/representation qualifications. Sole-resource record transport and finite Unit-output scheduled witnesses do not establish general heterogeneous App dispatch. Public adoption, broader automatic categories and feature performance remain #56; earlier opaque runtime04 Native timeout remains historical. |
| Retained operational schedules supply enabled-only descriptions — [#56](https://github.com/dearlordylord/bendvy/issues/56)/[#34](https://github.com/dearlordylord/bendvy/issues/34) | [Schedule observation evidence](../../experiments/public-inspect/ordinary-declaration-v1/schedule-observation-v1/runtime-v1/actual-attempt01/README.md) preserves the single operational Plan, duplicate per-step requirements, actual Registry owners and true/false condition/barrier execution; reached description omission rejects the normal oracle on JS/Native. The private generated frontend above additionally reaches actual scheduled runs without caller-built metadata. | General public App schedule integration and arbitrary registration composition remain #56. Do not infer condition names from IDs when the ordinary declaration does not retain names; source-feasible older bridge attempts alone are not complete acceptance. |
| Declared relation/machine/transition/failure inspection — [#55](https://github.com/dearlordylord/bendvy/issues/55) | Five public projection modules, including corrected [stream frame](../../src/ecs/inspector-stream-frame.bend), [transition projection](../../src/ecs/inspector-transition-projection.bend), [failure projection](../../src/ecs/inspector-failure-projection.bend) are adopted. [Public core index](../../experiments/public-inspect/graph-stream-public-bridge-v1/public-core-delivery-v1/INDEX.json) and [integrated evidence review](../../experiments/public-inspect/graph-stream-public-bridge-v1/integrated-evidence-v1/spec-standards-review.md) join full Worlds/cursors, actual registered conditions and foreign provenance. The [corrected public review](../../experiments/public-inspect/ordinary-declaration-v1/stream-public-relocation-v1/review.md) joins four whole17819-byte Workshop/Garden outcomes and six whole18949-byte namespace/consumption/order outcomes:25 commands,85 guards and four full-baseline rejections. Eleven intended typed refusals retain their raw diagnostics; the first collector-label failure remains INCOMPLETE (`c650a8d23`/`eec581d13`). Combined125 #28 passes `a6ddcd6ed`. | The selected Parent failure grant exposes selected failures and safe timing, not the superseded full Notice snapshot. Declaration-authored transition take remains trusted; finite preservation does not prove a universal lens law. Category/reference coverage, automatic confinement/dumps #56 and full-feature performance remain #55; #50/#53 affine event policy is not selected here. |
| Ordinary machine operations and pending apply retention — [#48](https://github.com/dearlordylord/bendvy/issues/48) | Public [ordinary-machine-operations](../../src/ecs/ordinary-machine-operations.bend) supplies actual declared queue/read/write grants. [Ordinary frontend evidence](../../experiments/public-machines/remaining-core-v1/ordinary-frontend-v1/README.md) joins rollback, two nominal schemas, four intended authority refusals and reached dropped-write JS/Native controls; public qualification and combined125 #28 pass. [Private apply-retention evidence](../../experiments/public-machines/remaining-core-v1/marker-phases-v1/apply-retention-v1/README.md) preserves three complete marker checkpoints and rejects the reached pending-drop control on JS/Native (`9d835a933`). | The private Apply→Exit→Transition→Enter composition is not ordinary schedule installation. Complete applicable marker/condition/reader integration and feature timing remain #48, while initializer choices remain unresolved and #49's approved committed-failure/retry behavior must be preserved. |
| Two independently authored joined public applications — [#61](https://github.com/dearlordylord/bendvy/issues/61) | [AppA review](../../experiments/public-audit61/app-a-v1/runtime-v1/spec-standards-review.md) qualifies Bundle installation→registered component/selected-resource transactions→Schedule→selected Inspector with complete5301-byte JS/Native observations. [AppB delivery](../../experiments/public-audit61/app-b-v1/runtime-v1/README.md) qualifies a distinct Bundle→hierarchy/reparent→machine/read-only projection app with complete14582-byte JS/Native observations. [AppB affected controls](../../experiments/public-audit61/app-b-controls-v1/runtime-v1/README.md) retain actual Lookup schema/write-through-read refusals and four complete14978-byte namespace/omission outcomes with two full-baseline rejections; [AppA affected-control review](../../experiments/public-audit61/app-a-controls-v1/SPEC-STANDARDS-REVIEW.md) joins omitted-install JS/Native baseline rejection and three intended authority refusals. | The two-app obligation now has finite executable evidence, rather than two schemas of one shared consumer. AppB has no registered gameplay system; AppA supplies that slice. Exact reference/capability census reconciliation, dependent full-feature gates and broader numeric qualification remain #61/#21/#23/#24; these pairs do not close the audit. |
| Ordered execution/failure/barrier observation — [#57](https://github.com/dearlordylord/bendvy/issues/57) | [Trace preparation](debug-trace.md#source-preparation-and-reusable-evidence-2026-10-09) maps actual schedule, system, transaction, barrier and handler seams. Schedule.Ran still conflates success/failure; no subscriber core exists. | Subscriber ownership/delivery/IO contract remains unresolved. TS callback Set semantics do not select the Bend contract. |

The [expanded executed TS reference](https://github.com/dearlordylord/bendvy/blob/7726a3c8ce04c49c711d17fe87f6e5221203c201/experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-observable-api-v1/resource-fields-reference-v1/expanded-v1/SHARED-COMPARISON.md)
`7726a3c8c` passes its independent complete7421-byte oracle once. It compares
selected numeric contents, rollback/retry, two live component entities, retained
91/92 events and pending-work visibility. Its Marker99 insertion is explicitly
an analogue, not Bend's event99 callback. Physical missing-resource preflight,
Schema duplicate throws, frame/ticks, readers and valid runtime execution differ
from Bend Fragment metadata/owner return and identity initialization. No affine,
clock/cursor or generic Rust rollback equivalence follows.

#54 complete composed Native and held-view boundaries, #55 remaining category/reference acceptance, and #56 public automatic composition/projection-to-dump bridges stay with their existing owners. The current public #70 field representation is the confined resource authority; automatic descriptions must not substitute whole-aggregate access. Coordinate interfaces with the single core integrator. #57 and ownership-policy
gaps need existing contract decisions first. No new plan, contract, law, archived
TS-only requirement, backend run or #61 closure is introduced by this update.


## Current ordinary App and scheduling reconciliation — 2026-10-11

This supplements the historical rows above using the same Rust Bevy → Bend →
bevy-ts reference order and approved contracts; it does not regenerate the census.
The pinned [reference sources](../../.references/sources.json) are Rust Bevy
`ad678262`, Bend `a950fd68`, then bevy-ts `3040a3b2`. The archived TS export census
is historical inventory/potential adapter tooling, not an independent requirement
to reproduce TS-only mechanisms. Current ordinary callsites, source refusals and
independent whole models below delimit the accepted capability evidence.

| Contract → actual public entry | Whole evidence | Exact gap → owner |
| --- | --- | --- |
| Ordinary declarations plus enable-debug → public [component registration](../../src/ecs/ordinary-app-component.bend), [resource registration](../../src/ecs/ordinary-app-resource.bend) and App-only [snapshot](../../src/ecs/ordinary-app-composer.bend) | Integrated `6c5d32068` derives the fold from registration and describes sole retained operational Fields only when enabled. [Complete private outcomes](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/registration-derived-fold-v1/ACTUAL.json) match the independent 16,816-byte JS/Native oracle; [public successor source joins](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/registration-derived-fold-v1/public-successor/MANIFEST.json) and intended source PASS bind the exact fourteen public modules without private fallback. Runtime reuse is import-inverse evidence, not a public backend replay. | The mixed schema/selected-field foundation below now qualifies finite same-declaration naming/order. Complete automatic schedule/persistence/relation/machine presentation, arbitrary schema/registration decomposition, arity/scaling and feature timing remain #56. The earlier private-only and missing-public-adoption descriptions are historical. |
| Mixed ordinary schema/product declarations → public [schema wrapper](../../src/ecs/ordinary-app-schema.bend), [schema-product bindings](../../src/ecs/ordinary-app-schema-product.bend) and selected-field [registration](../../src/ecs/ordinary-app-resource-field.bend), [declaration](../../src/ecs/ordinary-app-resource-field-declaration.bend) and [observation](../../src/ecs/ordinary-app-resource-field-observation.bend) | Adopted `311854707`. [Public source join](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/README.md) qualifies current public normal/refusal source and exact import/body/nominal joins. The [mixed pair](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/runtime-v1/actual-attempt01/ACTUAL.json) matches complete 13,505-byte JS/Native observations; the [refusal pair](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/runtime-v1/actual-attempt01/ACTUAL.json) matches complete 458-byte JS/Native output, retaining accepted component owner/recipe/World/pending callback when selected-field registration exhausts the existing system-ID range. Same operational declarations supply canonical product lenses and enabled-only schema/Fields/value metadata; disabled paths preserve the App without deriving metadata. Private authority captures retain one second-schema positive and five intended typed/affine refusals. | Exact relocation supports private evidence reuse, not new public backend or authority transcripts. This two-registration mixed example uses direct registered invocation rather than Sch dispatch; arbitrary schema/registration decomposition, wider automatic categories and feature timing remain #56, and complete joined application obligations remain #61. General inverse/finalizer and independent-root identity policies retain #52/#38. Later protected combined185 evidence below supersedes the historical combined148 prerequisite; it does not broaden this finite feature witness. |
| Ordinary machine declaration → public [ordinary-machine-schedule](../../src/ecs/ordinary-machine-schedule.bend), actual Schedule execution and registered readers | Ordinary public schedule A/B complete outcomes and mapped private controls qualify the finite public interface. Condition/readers whole 3,957-byte JS/Native observations retain actual reader activation and skip. [Checked-condition adoption preparation](../../experiments/public-machines/remaining-core-v1/condition-readers-v1/missing-condition-v1/adoption-v1/README.md) (`8913` checkpoint) retains complete 3,733-byte normal and 3,740-byte Fail-to-false reached controls, both schemas and semantic refusals. | Public [schedule-checked](../../src/ecs/schedule-checked.bend) is adopted at `7598e090c`; public source and exact import/nominal joins reuse the bounded private runtime evidence, without claiming new public backend execution. Applicable condition/reader composition, initialization choices and full-feature timing remain #48; preserve #49's existing committed-failure/retry behavior. |
| Ordinary machine-handler Bundle → public [ordinary-machine-handler-bundle](../../src/ecs/ordinary-machine-handler-bundle.bend) and [machine-handler-phases](../../src/ecs/machine-handler-phases.bend) | Adopted `af88ee8b0`: the [public source relocation](../../experiments/public-machines/ordinary-handler-bundle-adapter-v1/public-relocation-v1/PUBLIC-REVIEW.json) verifies exact implementation/import/nominal joins. [Generic whole-pair review](../../experiments/public-machines/ordinary-handler-bundle-adapter-v1/FINAL-REVIEW.md) and [SchemaB/typed-refusal review](../../experiments/public-machines/ordinary-handler-bundle-affected-v1/FINAL-REVIEW.md) join complete 21,569-byte A/B JS/Native failure/retry observations and actual adapter-run cross-schema/affine refusals. [Bundle controls](../../experiments/public-machines/handler-schedule-composition-v1/bundle-v2/FINAL-REVIEW.md) retain inactive owners, unselected requirement deduplication and reached recovery-order discrimination; [actual owner controls](../../experiments/public-machines/handler-schedule-composition-v1/bundle-v2/actual-owner-controls-v1/FINAL-REVIEW.md) qualify missing machine-slot1 before barrier and twice-rejected Bundle2 against World1 with both Worlds/readers/owners and threaded Factory3 preserved. Public evidence reuse follows exact source joins, not a new public backend transcript. | Arbitrary heterogeneous/multimachine application decomposition, initialization and full-feature timing remain #48/#49/#61. Finite requirement predicates and trusted lenses do not establish universal provisioning/noninterference; independent Factory-root uniqueness remains #38. Existing committed failure/retry, owner recovery and reader policy are preserved. |
| Mixed Notice preservation → public [typed Notice runtime](../../src/ecs/event-notice-runtime.bend) and [ordinary App bridge](../../src/ecs/ordinary-app-event-notice-runtime.bend) | [Accepted review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/mixed-notice-v1/FINAL-REVIEW.md) joins one World, Original-only typed journal synchronization, ordered passthrough and separate descriptor framing: eight complete JS/Native outputs, 20 commands/68 guards, public schema/affine refusals and reached ComponentRemoved omission rejecting the matched whole baseline. The immutable catalogue digest correction is retained; executed plans bound the correct source bases. | Synchronized Original-prefix/provider callbacks remain trusted. Seeded ComponentRemoved/CleanupPaused preserve records, not actual cleanup execution. General unsynchronized retention, arbitrary callback/Type-event recovery and full presentation/timing remain #56/#71; no #38 allocation or #46 policy is inferred. |
| Common typed and relation-failure readers → public [relation failure reader](../../src/ecs/ordinary-app-relation-failure-reader.bend) and generated App fold | [Accepted common-reader review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/FINAL-REVIEW.md) verifies fourteen full checkpoints, all four actual callbacks, eight JS/Native whole outputs, 20 commands/68 guards and actual registration schema/affine refusals. Reached fields omission rejects the complete matched baseline while physical owners, reader identities/cursors and callback execution remain retained. Other observer repair and its earlier Native deadline remain distinct. | Finite Array-backed owners and actual typed/descriptor cursor distinctions qualify this composition, not universal raw-provider noninterference, independent-root identity, cleanup/failure policy or all callback decompositions. Remaining full presentation/composition and feature timing stay #56/#71/#61. |
| Retained actual Plan → public [named schedule description](../../src/ecs/ordinary-app-schedule-description.bend) | Adopted `c93e26ed5`; [final review](../../experiments/public-inspect/ordinary-declaration-v1/ordinary-schedule-description-v1/FINAL-REVIEW.md) joins actual seven-step dispatch, six enabled/repeated/disabled checkpoints, eight whole JS/Native outputs, 20 commands/68 guards and public cross-schema/owner-duplication refusals. Ordered placements resolve names from the same namespace/id bindings; raw condition IDs and missing-name None remain unchanged. Name omission rejects the whole same-QName baseline. Controlled stock successes preserve preceding deadlines without attributing their cause. | This supersedes the historical missing-public schedule-description row for this bounded route. Raw plan/projection setup remains trusted; named conditions, lints, arbitrary registration/owner decomposition, complete formats and feature timing remain #56/#34/#61. |
| Complete capacity actions and observation intervals → existing public event runtime | [Capacity interval review](../../experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-event-family-feasibility-v1/capacity-trace-v1/interval-v1/FINAL-REVIEW.md) verifies eleven actions/twelve full observations, actual continuation ordering and complete JS/Native/TS outputs. Comparative attempt retains 20 JS pairs but only one Native pair before a stock deadline; the separate Native diagnostic is not a completed cohort. | Instrumentation correctness is accepted; full comparative #71 acceptance, profiles/scaling and feature timing remain with the existing #71 owner. Observed incomplete JS slowdown is not erased by the protected regression verdict. |
| Empty public bundle → [ordinary terminal/request](../../src/ecs/ordinary-bundle.bend) through registered opaque owned capability | Accepted at `d7f817366`; [batched final review](../../experiments/public-bundles/owned-public-result-v1/empty-ordinary-v1/FINAL-REVIEW.md) joins current source03, independent 5,624-byte oracle and actual stock JS/Native: five commands/17 guards. Two nominal Worlds share one threaded Factory; eight complete states/schema retain all four World sibling/resource Arrays and Array context across reservation, deferred activation/delivery, repeated barriers, returned-handle Insert and Unit/MissingEntity recovery. | The [actual pinned TS empty reference](../../experiments/public-bundles/owned-public-result-v1/empty-ordinary-v1/ts-shared-v1/FINAL-REVIEW.md) additionally matches its full2,603-byte independent oracle; silent missing-target empty Insert and empty-barrier clock differences are preserved. This fills the finite empty-bundle route, not arbitrary nonempty raw/exceptional cleanup or a foreign-World witness. Existing authority/nonempty recovery evidence remains scoped reuse, not fresh negative coverage. Full API/owner-cleanup and matched feature performance remain #41; allocation/identity decisions are not invented for #38/#46. |
| Current ordinary binding/query/Inspector → current [ordinary caller](../../experiments/public-inspect/ordinary-declaration-v1/caller.bend) and public query/inspection dependencies | Accepted at `d7f817366`; [batched final review](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-public-consumer-v1/FINAL-REVIEW.md) verifies complete 863-byte stock JS/Native outputs, six accepted commands/21 guards and thirty current public dependencies. The observer reconstructs both nominal scenes' delivered Column/payload/resource Arrays, transaction receipts, World, Inspector cursor, projected rows/clauses and access before terminal observation. | The [registered-system repeat slice](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/FINAL-REVIEW.md) also passes both full4,407-byte outputs, preserving Inspector cursor/World and isolating the registered system cursor transition. This is not full Schedule/App execution or historical full47 qualification. Prepared/indexed/refused observations, resource/stream display, composed conditions, held views, reader/retention, affected authority negatives and full feature performance remain #54. Independent factories both yield namespace1; no process-global identity claim. |
| Full47 owner-preserving observation helper → private #54 research only | [Parked helper review](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/world-text-helper-v1/FINAL-REVIEW.md), recorded at `b306e9db9`, verifies source PASS and complete 5,077,477-byte JS output; stock Native emission reaches its unchanged deadline with no C. | PARK PRIVATE, DO NOT ADOPT. That complete full47 composed Native workload, held-view boundaries and full #54 performance remain with the #54 owner; source equivalence/copied diagnostics grant no stock Native credit. |
| Existing protected Workshop workload → unchanged combined #28 gate | [Qualified combined185 review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt185-01/FINAL-REVIEW.md) supersedes qualified184 for this protected workload: 365 retained bodies, 110 complete outputs, 123 exit-zero commands and twenty pairs/backend, NO_CONFIRMED_REGRESSION. Actual `6fc8fc2c2` received final review at `eac74f766`; it is no longer awaiting review. | This is the protected Workshop gate, not automatic-debug/bundle/capacity feature timing or full numeric qualification. Existing #41/#54/#56/#71 feature owners retain their measured acceptance gates; exact capability/application closure remains #61. |

AppA and AppB remain two independently orchestrated finite public witnesses.
Their qualified pairs and affected controls do not execute every inventoried core
capability, establish arbitrary composition, or close #61. This reconciliation
adds no contract, law, measurement, execution plan or parallel workstream.
