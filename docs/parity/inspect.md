## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Host code repeatedly inspects components, resources and event/removal streams while leaving system reader positions and retention unchanged.

## Acceptance criteria

- [ ] Observe pinned Inspector read capabilities and check-condition behavior; execute public inspect repeatedly before and between schedules with two schemas.
- [ ] Verify no writes, structural flush, reader registration/advancement or retention participation; return affine World/payload owners and expose safe projections instead of mutable aliases.
- [ ] Check exact missing requirements and errors, read-only query negatives, undeclared categories and a reached reader-consumption mutant. Relations/machine inspector surfaces are completed in a dependent extension.

## Blocked by

- #35

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current resource boundary

The ordinary present-resource binder is integrated with [bounded JS/Native review](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/present-resource-v1/public-relocation-v1/FINAL-REVIEW.md). Missing-resource lowering remains an actual #54 gap: pinned bevy-ts `Runtime.ts` uses partial resources (line147), skips absent constructed inputs (498–510), inserts only supplied values (477–490), and preflights schedule requirements before advancing the frame (1674–1687). Rust Bevy validates absent `Res`/`ResMut` in `system_param.rs` (904/955). Bend’s current ordinary resource provision requires a supplied owner. A `Maybe` payload is not resource absence; no new absence or ownership policy is adopted here. References: TS3040a3b2a3f28fa8554d856f9ccb6bf5433fa334; Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60.

The [two-present-resource TS comparison](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/present-resource-v1/ts-common-v1/FINAL-REVIEW.md) passes its complete independent 10,876-byte oracle. TS cursor/tick advancement and JS aliases remain explicit reference differences; resource absence is addressed by the later ordinary missing-resource slice below. Current Inspector returns detached Data with affine owners; it proposes no held-view contract.

The [ordinary query method slice](../../experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/ordinary-query-errors-v1/FINAL-REVIEW.md) qualifies real handle2 `QueryMismatch`, required single success, optional `MultipleEntities`, and Changed/cursor1 zero-row `NoEntities` versus successful `None`. Both schemas and full returned App owners pass on JS/Native. Historical TS query evidence is current and reused as complete parsed JSON equality; no fresh TS run or affine ownership transfer is claimed. Earlier checks of the wrong consumer and an emitter failure remain explicitly uncredited. Full47 Native and broader composition remain separate gates.

### Ordinary missing-resource registration

[Bounded Spec/Standards review](../../experiments/public-inspect/promotion-stage/missing-resource-v1/FINAL-REVIEW.md) accepts the additive ordinary resource provider. The original `Resource<S,P>` identity indexes a physical affine Missing/Present Slot and its storage cursor. One declaration supplies grants, preflight, observation, access and the actual retained Registry/recipe. Optional reads expose `Maybe<DataV>` while returning owners; required Missing refuses before the existing transaction/callback. Registered arguments and detached `run_latest` outcomes are Data; retained resources and owners remain arbitrary Type. Presenters/lenses remain trusted.

Four real worlds across two nominal schemas pass complete 35,700-byte JS/Native observations. The actual preflight omission passes the independent 35,556-byte counter on both backends and rejects both complete normal results; all 59 source bodies are restored. Actual schema, same-payload resource/storage identity and affine-App refusals pass. Existing executed TS optional-inspection and registered-required scenarios are reused only within their exact source-bound scopes.

The [direct Inspector/Check consumer](../../experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/FINAL-REVIEW.md) now passes complete 51,702-byte JS/Native observations: repeated public calls surround actual optional/required system runs in four worlds, retain detached Payload/Counter Data, and distinguish Inspector clock/cursor from operational Registry cursors. New host access/owner refusals pass. A reached local Counter projection mutation passes its full independent counteroracle and rejects the matching normal baseline on both backends. This is finite detached-Data preservation and projection evidence; arbitrary borrowing, universal presenter purity and reader-consumption mutation are not established. Historical TS evidence is reused only for its exact selected operations.

Full #54, broader inspector composition, universal proofs and feature performance remain open. [Combined213](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt213-01/FINAL-REVIEW.md) passes the unchanged #28 Workshop regression gate for the current 213-module core. Full feature performance remains separate.

### Event inspection around registered schedules

The [event/Schedule review](../../experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/event-schedule-v1/FINAL-REVIEW.md) qualifies the actual public `ordinary-inspector-event` Runtime `ValueRead` surface around registered fast/slow/second event readers dispatched by public Schedule. Two nominal schemas pass complete 211,157-byte JS/Native observations: 14 checkpoints per schema, two getter calls at each checkpoint, full physical owners, batches, reader positions, retention and six Schedule outcomes. This event surface has no `I.run` instance; World clock, event tick and Registry cursor follow their actual separate paths.

A compiling mutation of the actual public getter advances reader1. Both backends match the independent 211,671-byte counter and reject the complete same-QName normal result at byte3993; fast-reader output changes while the independent slow reader retains its event. The getter and all105 source files are restored exactly. This establishes the reached reader-consumption control for this slice. Historical TS discovery and authority checks are reused only at their exact recorded boundaries, with tool differences explicit. Full #54, broader composition/refinement, proofs and feature-specific performance remain open; the unchanged current-core combined213 regression remains qualified.

### Native compiler investigation — bounded qualification

[Source-pinned diagnostics and bounded-inlining candidate](../../experiments/native-compiler-diagnostics/inspector54-v1/README.md) locate expensive layout serialization, optional tail-inlining expansion and repeated full emission passes in the copied2.0.35 backend. The initial unexecuted candidate and stock failures below are historical. The later private f1a candidate completes the current 63-source pure consumer on JS and regenerated C→ordinary Native -O3, matching its full 226,096-byte oracle; existing numeric JS/Native controls also pass. Accepted packets and final reviews are indexed in the [current coordination table](README.md#current-delivery-coordination). The installed compiler, ECS API, acceptance limits and issue scope remain unchanged. The existing timed enum 1/2/4 successor emits JS/C and passes all 12 selector controls, but its ordinary Native build reaches the unchanged 120-second deadline; repetition runtimes were not run. Pure-consumer qualification therefore does not establish timed repetition/composition or adoption. PR1386 and layout-key follow-ups are recorded in that same investigation.

### Component-query retained Inspector lifecycle — current blocked stock attempt

The [Unit-filter attempt](../../experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/stock-unit-attempt-v3/RESULT.json) preserves the exact current 53-source fixture and source-only [independent model chain](../../experiments/public-inspect/promotion-stage/missing-resource-v1/independent-oracle-v1/direct-inspector-v1/component-query-v1/ORACLES.json). Stock source03 passes; JS matches all 207,834 bytes (14 query kinds, 9 Checks, 11 full checkpoints/schema, retained instances, failure/retry and registered writers). Stock Native emit again hits 30 seconds without C, build or runtime. [Final review](../../experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/stock-unit-attempt-v3/FINAL-REVIEW.md) accepts bounded retention only. The archive retains predecessor attempts; none establishes Native acceptance or full #54 completion. Unit consolidation changes private consumer projection wrappers, not public core/API.

### Current enum repetition qualification

The minimal successor transplants the already qualified query helper into the
existing timed enum consumer. Expanding its three calls restores the original
declaration source byte-for-byte; other enum bodies, timer/IO/argument handling
and complete oracles are unchanged. The ordinary Native O3 build and all nine
single-process JS/Native/TS repetitions (1/2/4, 20/40/80 intervals) pass. All 28
commands exit zero with clean guards (`1330c298`). Independent final evidence
review passes; no comparative speed, compiler adoption or full #54 closure
is established. Historical stock/enum failures above remain retained failures.

Current read projections require Data and return the supplied affine owner.
Arbitrary Type payloads remain behind trusted owner-preserving presenters;
there is no borrowed held-view API whose ownership needs a new approval. Query
capabilities accept compatible same-schema frames rather than binding one World
identity. Existing foreign-handle checks compare namespaces; independently
started factory roots can collide, leaving the concrete identity decision in #38.

### Current private-emitter type controls

The existing nine source controls were executed with pinned f1a check-only:
two positives pass and seven intended rejections match their retained semantic
diagnostics, with clean guards. Independent final packet review passes. The read-control
fixture named undeclared-read supplies a List<U32> capability where Bool is
required; this is a type-mismatch refusal, not an independent runtime
undeclared-handle test. Stock 2.0.35 remains the ordinary checker, and historical
stock backend/mutant results retain that tool identity. The project-local
private emitter has separate qualified runtime evidence; these source checks
do not grant backend, mutant or production-adoption credit.

The two existing canonical composed-query controls also pass f1a check-only:
a same-Unit-payload attempt to recover undeclared selection capability and an
opaque-owner escape both receive their intended refusals with clean guards.
Independent final packet review passes. The first plan was stopped before any compiler
command because its old union inventory had unused entries; the preserved
successor binds the exact 19-file import closure while retaining all 52 body
pins. Current each/get calls take a granted query and owner/entity handle, with
no runtime family/name selector. These checks do not establish arbitrary trusted
lens honesty, runtime undeclared-family lookup behavior or tool adoption.

### Recovered project-local wrapper

The actual recovered wrapper completes version, stock 2.0.35 check-only, f1a
JS emission and the full 226,096-byte independent oracle with thirteen clean
guards (`fb8e59e7`). Independent final review passes. Native retains its separately
qualified exact-emitter scope; no wrapper Native rerun, comparison, performance
result or production adoption is claimed. The earlier finite dispatch control
used mocked execution only; its unexecuted loader successor remains distinct.

### Unadopted full23 compiler remedy

The copied compiler in `b33d723e7` emits C byte-identical to the passed
host-lookup experiment: 33,749,160 bytes, SHA-256
`72f19590b07af441414acc172db039ef67adabe88903f1237f37266561e9c7d1`.
The explicit source→compiler→C→build→oracle join is retained in
`compiler-lookup-v1/RESULT.json` under the full23 `graph-only-v1/execution-source-v1`
experiment. It reuses the exact Clang19-O3 build120/full-oracle runtime5 result;
the copied-tool emit passed within30. No identical build is repeated.

The frozen `d0b687371` source changes only `inspector-query-projection.bend` and
`inspector-query.bend` against compared master `c96a86676` (those two master bodies
are unchanged from `f597c09d9`). Runtime callback forwarding retains the selected
ordinary signatures, constructor layouts, authority, evaluation and owner order.
Undocumented exported helpers change signatures, including `pair_matches`,
`projected_left`, `mapped`, `composed_lookup_matched` and `composed_scan_matched`;
direct trusted callers need compatibility review. No FrameLink is selected.

Compiler composition is exact ELF-derived2.0.35 plus the order-preserving graph
patch and two host lookup-template changes only. The device path and musttail
signature remain unchanged. No budget, boxing, instrumentation or installation
change is included. This qualifies a candidate; it does not change the selected
compiler pin or establish stock full-Native acceptance.

Independent full-consumer and exact-artifact reuse reviews pass (`8e3c449f3`,
`1f78ba01e`). Current-dependency authority controls, helper compatibility and
the reached reader-consumption body join pass bounded review `3d15de773`.
The protected23 workload emits byte-identical JS (669,036 bytes, `ca22d6b8…`),
independently reviewed in `2caddb28d`, so its existing JS artifact evidence is
reusable. Its C differs by 84 bytes. The protected Native build and complete
231,190-byte correctness observation pass under the original caps; the resulting
ELF differs from the historical artifact, so Native was measured rather than
reused. Both the unchanged default #28 and a separate same-source old/new compiler
comparison pass the existing statistical rule (result `577e9f295`, independent
final review retained with that result). The targeted Native median paired ratio
is 0.9597; this is scoped Workshop evidence, not full-feature performance. Compiler dispatch changes globally even though the two
ECS modules are outside the protected source closure. An explicit compiler adoption/upstream decision and final source integration
remain open; the installed-stock full Native gate has not passed. Full Inspector CPU/allocation profiles remain unmeasured; the protected
Workshop measurements do not establish its performance.

#### Independent helper compatibility review

Compared `d0b687371` with master `49fc6ca10` (same two production bodies as
`c96a86676`). Source-only review found sixteen changed helper signatures:
projection `matched_right`, `pair_matches_target`, `pair_matches`,
`projected_left`, `pair_project_target`, `pair_project`, `predicate_right`,
`predicate_both_target`, `predicate_both`, `constrained_target`, `constrained`,
`mapped`, `map_project`; query `composed_lookup_matched`,
`composed_lookup_valid`, `composed_scan_matched`.

A tracked-source import/call audit found no external qualified references to
these helpers: 390 projection-module and 577 query-module import occurrences
were inspected, including experimental copies. Unqualified matching calls are
inside their defining implementation/copies. Existing docs/contracts promise
the ordinary composition/query surface, not these worker signatures; the
only helper-name documentation is the explicit compatibility caveat above.
`pair`, `both`, `constrain`, `map`, outer composed-query entry signatures and
constructor layouts are unchanged. No compatibility wrapper is necessary for
the evidenced repo callers or documented API. This is not a guarantee for
unknown external callers: these helpers are importable, and direct users of
the old signatures must adapt. Do not describe the entire exported surface as
unchanged.

Runtime forwarding extracts the same closed declaration fields without calling
them early. Matching remains left then right only on True; constraints test the
selection before the predicate; paired projection passes the returned H owner
from left to right; mapping runs after projection. Lookup validates before
matching and projects only on a valid match. Scan keeps static recursion and
creates one runtime project callback per item, preserving target/row order and
threading the returned owner into its continuation. False branches omit the
same work and retain their incoming owner. No callback is duplicated or given
new authority; dropping an unused callback on a false branch is affine and
introduces no finalizer contract. This joins the prior callback/full-consumer
reviews; it is not a new runtime/proof result. The source owner's affected
authority controls and compiler adoption/regression gates remain separate.

The portable candidate packet is retained at
`experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/stock-format-owner-v1/callback-forwarding-v1/owner-forwarding-v1/boxed-diagnostic-v1/coherent-callback-v1/execution-callback-v1/actual-frame-v1/graph-only-v1/execution-source-v1/compiler-lookup-v1/candidate-delivery-v1/`.
Its offline verifier and independent review pass 524 full paths / 325 objects.
Its pre-cohort regression-pending status is superseded only by the bounded
`compiler-lookup-artifact-identity-v1/regression-result-v1` evidence above.

## Ordinary checked resource predicates

`ordinary-check-declaration.optional_resource` / `required_resource` derive
read grants, requirement validation and typed descriptions from the same binding.
`ordinary-checked-condition.check` builds a confined Bool predicate; `lift` accepts
existing conditions without replacing their owners or descriptions. `not`,
`and_then` and `or_else` compose both. Detached views and Check arguments are
Data; resource payloads, Worlds and App owners remain arbitrary affine Type.

Bind to an actual system ID with `ordinary-checked-bindings.bind`, then attach
to an ordinary schedule through `ordinary-app-checked-schedule`. Enable-debug
snapshots derive the condition tree and reads without caller metadata adapters.
Each reached Check leaf validates its own required resource. Lazy skipping does
not validate an unreached RHS; existing authored schedule-needs preflight stays
unchanged. Reached Check errors and existing registration failures remain distinct.
Raw selectors, numeric IDs and providers retain their trusted administrative scope.

The [independent final review](../../experiments/public-conditions/checked-predicate-v1/FINAL-REVIEW.md)
accepts complete stock JS/Native normal (104,475 bytes), machine/unbound-system
interoperability (48,757) and eager-RHS mutation (105,097, normal rejected) pairs,
plus three positive/ten intended authority controls. Actual TS execution matches
its complete 38,458-byte independent oracle. TS preflights combined requirements
eagerly; missing-resource outcomes explicitly differ from the Bevy-style lazy
path. The machine witness reaches supported missing-as-false and stale actual
registration refusal; generic lifted NoValue/NoBinding transport is source/type
coverage here. Full Inspector Native acceptance and the complete #61 matrix
remain open; final product performance stays in #21/#23/#24.

## Ordinary component-query Check declarations

`ordinary-check-query` derives required/optional reads and With/Without predicates
from ordinary component bindings. Compose them with `pair`, `both`, `constrain`
and `map`; `empty` supports membership-only queries. `declaration` supplies the
confined Check read and its description together. Component payloads remain
arbitrary affine Type; query results are detached Data.

`ordinary-check-declaration.both` combines declared reads, including a query and
a resource in one Check. Its existing requirement checks thread World left to
right and append returned missing names. Required components select rows; they
do not require a component somewhere in the World. Typed Component selection
metadata distinguishes Required/Optional/With/Without; the existing `required`
flag denotes required World-owned resource or machine availability. Exhaustive description renderers handle
the new Component category explicitly. Ordinary debug snapshots carry these
uses without a caller adapter.

The first stock JS/Native consumer pair matches all 96,029 independent oracle
bytes. Five positive and ten intended authority controls cover the new entry.
The reached constrain-omission mutant matches all 98,819 counteroracle bytes on
both backends and rejects the complete normal result. The current resource
compatibility pair retains all 104,475 original oracle bytes. Actual TS execution
matches its full 23,512-byte independent oracle; fresh missing-resource admission
is explicitly distinct from Bend's reached validation and returned-owner restore.
The [independent final review](../../experiments/public-conditions/component-query-v1/FINAL-REVIEW.md)
passes; integrated `c524034d2`, CI38901764699 PASS. This bounded join does not close #61 or the full #54 workload;
combined regression and final performance requirements are unchanged.

## Ordinary machine Check declarations

`ordinary-check-machine.optional` and `required` derive their read, availability
check and typed Machine description from the existing nominal machine declaration.
`read` returns the affine owner and the existing detached CurrentView. Optional
absence is `Unavailable`; a reached required read retains the existing
`MissingRuntimeRequirements` names. No Resource identity is fabricated for a
machine. `ordinary-check-declaration.both` combines machine, query and resource
grants in one confined Check; App debug snapshots derive those uses automatically.

The first stock JS/Native pair matches all 119,419 independent oracle bytes,
including current versus queued state, actual transition application and restoration
from the returned machine-state owner. This is a host-driven use of the existing
transition runner, not another registered-handler qualification. Affected authority
controls pass (five positive/ten intended refusals). The reached availability
defect matches119,371 independent bytes on both backends and rejects normal;
the current query/resource compatibility pair retains96,029 bytes. Actual TS
execution matches36,126 independent bytes; its fresh missing-machine admission
difference is explicit. [Independent final review](../../experiments/public-conditions/machine-query-check-v1/FINAL-REVIEW.md)
passes; integrated `88645bf21`, CI38906069050 PASS. Existing
#61/#54 and final combined product requirements remain open.
