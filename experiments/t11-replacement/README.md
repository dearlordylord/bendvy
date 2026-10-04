# T11 replacement: connected transition laws and owned-runtime witnesses

Issue [#12](https://github.com/dearlordylord/bendvy/issues/12), parent [#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md), [ticket](../../docs/tickets/11-candidate-laws.md), [source audit](../../docs/reviews/laws-source-research.md), [Astra decision](../../docs/reviews/laws-decision.md). Branch baseline `484fb88`. All thirty-one laws remain **open and unapproved**. No general ECS proof is written. This replaces the *proposal*, not the historical files/evidence in `../t11`.

## Subjects and independent observations

[DESIGN.md](DESIGN.md), [types.bend](types.bend) and [LAWS.bend](LAWS.bend) were drafted before the implementation. Subsequent changes expose previously unstated domains rather than weakening failed claims: distinguish pure Nat admissibility from U32-refinability, pin admissibility independently, and match actual TS's allocation start of 1. The original failed raw-ID comparison exposed that last detail; no reference-ID remapping masks it.

[model.bend](model.bend) defines total pure Nat functions for factory creation, reservation, handle-based publication, lookup, command application, query, immediate writes and schedule execution. Factory/allocator guards are computed from state. Creation starts an empty local allocator at 1; reserve appends exactly one spawn with that next ID and returns the correctly scoped handle. Commands accept `(handle,action)`; there is no independently supplied target. Spawn prepends a physical row; sorted query observation never relies on that traversal order.

[spec.bend](spec.bend) imports only types and Base, never implementation helpers. It interprets the logical FIFO separately **for each entity**, then enumerates slots `[0,next)` to produce public projections. This differs from the implementation's whole-row-list mutation plus insertion sort. Namespace/reservation guards use comparison cases rather than caller-provided Booleans. The invariant oracle counts occurrences independently of the model's membership checks.

Pure model admissibility is an overapproximation of reachable states: `next <= limit`; unique live IDs below next; unique pending spawn IDs below next, disjoint from live IDs. Missing nonspawn command targets are allowed and ignored upon application. Nat namespaces, values and bounds are not silently U32 values. [model-fixtures.bend](model-fixtures.bend) and [runtime-fixtures.bend](runtime-fixtures.bend) construct positive states through actual creation/reservation/schedule/barrier transitions; one separately permuted live projection is a representation witness. Malformed duplicate-live and pending/live overlap worlds have explicit false-invariant controls. A later proof must establish reachability induction and the invariant from initial states, rather than infer it from finite witnesses.

[runtime.bend](runtime.bend) separately implements factory/reservation/publication/application/schedule with **U32** metadata and affine `World`, `Factory`, `Cell` and array owners. Every cell owns an actual `Array<U32>`; an immediate schedule write updates that owner in place. Observation returns the world beside a Data projection; no `+World`, array clone or value of abstract `P` reconstructed from reads exists. The runtime's query/lookup explicitly reuse the checked pure model on their Data projection; this sharing is visible, not an independent algorithm claim. Owned metadata/array transitions are separate from the Nat implementation.

The bounded runtime is one value/tag composition, not a production schema API or Data-only decision. Its cell read/write provider is separately checked for arbitrary abstract affine handles ([authority.bend](authority.bend)); it instantiates the callback with the real array-backed cell. Constructors remain public. Task-local negative controls exercise undeclared concrete access, wrong-schema tokens, write-through-read and reconstruction against that boundary. This is finite confinement evidence, not language-wide parametricity or full system confinement.

## Runtime/model relation and exact obligations

`R(w,m)` means the independent structural [owned-spec.bend](owned-spec.bend)
interpretation of owned runtime `w` agrees with `m` on namespace, next ID, FIFO
pending sequence and every cell's slot/value-at-element-zero/tag. Public row
observations are sorted; a physical row permutation is not a semantic difference.
The independent owned oracle does not call runtime projection/query/application/
schedule helpers. It reads actual fields and array element zero directly.

The laws use **direct proposition equalities**, not Boolean certificate results.
There is no Boolean `certificate`, `rows_eq` or `observation_eq` validator whose
always-True result can mask a wrong operation. In the laws an erased
`for -world: R.World` may occur repeatedly in mathematical observations; it cannot
reenter live code. [erasure-control.bend](erasure-control.bend) checks that shape
and ordinary affine forwarding; [erasure-negative.bend](erasure-negative.bend)
rejects a live erased-owner leak with expected `-world` / observed `world`. This
is a checker canary, not a general ECS proof or a runtime clone.

- **Initial correspondence:** actual `R.create`'s returned factory/world result
  is independently interpreted and compared with model/spec creation. Two calls
  through a returned factory pin distinct successful namespaces separately.
- **Projection and caller links:** separate laws pin runtime Data projection and
  the independent observation of its **returned owner**. Actual `R.query`,
  `R.lookup` and `R.reserve` have result-plus-owner equalities: returning empty
  rows, Missing, None or the wrong handle cannot be hidden by `R.step` ignoring a
  result. Query's premise is independent admissibility; lookup/reserve are total
  exact prototype equations, with freshness/live claims restricted separately.
- **Operation correspondence:** actual `R.step` output is compared directly with
  independent `S.step` applied to the independently interpreted input. Its domain
  is independent admissibility plus nonoverflowing Bump. Observations include
  metadata, complete ordered rows and pending commands; a dropped-pending mutant
  must fail a true-domain instance.
- **Schedule correspondence:** actual `R.tick` is separately constrained against
  independent schedule execution. `S.run_safe` checks admissibility and Bump
  safety at **every prefix**, not just the starting state; a safe initial scalar
  can otherwise overflow after repeated writes. An implicit final barrier or
  ignored steps must fail.
- **Preservation and trace induction:** model step preservation is a separate
  exact obligation. Runtime-refinability adds U32-width fields/inputs and safe
  increments before the relevant operation. Structural owner/projection lemmas,
  arithmetic bridges, invariant induction, provider parametricity, broader Type
  payload refinement and backend correctness remain separate proof dependencies.
  Literal comparisons prove none of these universal obligations.

Conditional claims use independent `S.When(condition, proposition)`: true
branches require the exact equality, false branches have type Unit. Its two
additional Type-equality laws pin both branches, so always-Unit cannot erase the
package. The runner separately records true-domain equality instances and
false-domain Unit controls. All mutation inputs are **fixed original-state
literals** linked to executed finite creation/reservation/barrier witnesses;
mutating a constructor cannot change the premise through a fixture call.

The factory guarantee assumes a **single trusted threaded factory lineage**. Public `Factory{0}` can establish a second, colliding root; independent-root global uniqueness/provenance is unresolved and not hidden behind fixture IDs. A production factory/root authority design must establish that boundary before claiming global isolation.

Index zero is safe for finite nonempty Bend arrays (Base has only ALeaf/ANode); constructed fixtures use depth zero (one element). The erased world quantifier also admits multi-element arrays: the relation observes **element zero only**, not all array contents or physical owner identity. Returned-owner preservation is at this declared observation, not a universal arbitrary-payload preservation theorem. The experiment does not claim arbitrary slot-index array bounds. Indexed storage and wider affine payload integration belong to #16/S-INTEGRATE. Allocator bounds precede U32 increment; `MAX` is rejected and `MAX-1` succeeds without wrapping. This is the experiment's selected bounded policy, **not approval of production exhaustion, reuse or error semantics**. TS's inspected allocator has no configured rejection; Rust Bevy may reuse generations and panics on exhaustion.

Foreign lookup preserves the approved `MissingEntity` divergence. Foreign command authority preserves the owned world's data and pending sequence. Its internal `publish` returns the owner without a public error result; final observable rejection/ignore/error policy is still unresolved. Actual TS collision commands mutate the receiving world. This reference behavior does not authorize using foreign authority in Bendvy, and lookup approval does not choose a public command error.

## Open candidates and proof sketches

Each law below quantifies an actual full function, independent projection or exact executable helper. Conditional Type propositions use independent premises, explicitly pinned encoder branches and true reachable-premise controls; false-domain Unit cases are excluded from equality/mutant success counts. No `def` fills any candidate.

| Exact ID | Guarantee / why | Later proof sketch and dependencies |
|---|---|---|
| `admissibility_independent` | Independent count-based invariant agrees with implementation membership invariant. | Structural list induction; occurrence-count/membership equivalence, unique spawn/live disjointness. |
| `namespace_creation_exact` | Computed create succeeds below bound with exact empty state/counter; rejection preserves factory. | Nat comparison cases and exact constructor projections. |
| `namespace_two_created` | Two successful calls through one returned factory yield unequal namespaces. | First/second guard cases, successor inequality; trusted-root provenance stays separate. |
| `reservation_exact` | Full allocator succeeds/freshens/publishes exactly as independent semantics; below-capacity always-reject fails. | Guard split, append characterization, freshness from invariant. Total equality is model semantics even for arbitrary input; reachable-state claims require admissibility. |
| `reservation_pending_lookup` | Reserved handle is not live before a barrier, on admissible input. | Fresh slot absent from live rows, full scoped lookup; success/rejection cases. |
| `query_any_complete_ordered` | All live rows, once each, with exact values and ascending IDs. | Invariant unique IDs; sorted insertion membership/order; enumeration completeness. |
| `query_present_complete_ordered` | Exactly live tagged rows with their values and ascending IDs. | Same plus tag predicate characterization. Required/optional arbitrary-schema descriptors stay a later package. |
| `query_absent_complete_ordered` | Exactly live untagged rows with values and ascending IDs. | Same plus complement of tag predicate. |
| `lookup_full_exact` | Full namespace check and actual local search agree; successful local and missing/mismatch/foreign cases. | Namespace comparison, independent `at` equivalence, selection predicate. |
| `publication_authorized_target` | Full guard binds target to handle; local append succeeds, foreign world is preserved. | Namespace cases and append sequence equality; public rejection result unresolved. |
| `explicit_flush_independent` | Spawn/insert/remove/despawn, missing targets, FIFO, survivors and queue clearing match entity-wise oracle. | Pointwise apply/replay lemma; command-list induction; unique materialization. Removal/despawn logs and relation/scope cleanup later. |
| `schedule_execution_exact` | Actual bounded steps perform ordinary writes/reservations/publications/barriers without a final implicit flush. | Step correspondence then list induction. Failed-system publication, general callbacks/phases/conditions later. |
| `admissibility_preserved` | Every model step preserves uniqueness, spawn/live disjointness and selected allocator bound. | Step case split, reserve freshness, flush command-prefix induction. |
| `query_independent_physical_order` | Reversing physical rows leaves public query unchanged. | Unique per-ID lookup, enumeration/sorting equivalence; not a mandated physical representation. |
| `owned_runtime_creation_correspondence` | Actual U32 affine factory creation has model observation. | Owner projection and comparison/no-wrap bridge; root confinement separate. |
| `owned_runtime_projection_exact` | Actual owned-to-Data projection agrees with an independent field/array observation. | Structural cell/list/command projection lemmas; array element-zero read. |
| `owned_runtime_projection_preserves_owner` | The returned owner preserves the same independent declared observation. | Owner-return field/array lemmas; no full arbitrary-array or physical identity claim. |
| `owned_runtime_step_correspondence` | Actual owned U32 step observation directly equals independent Nat successor on its admissible/nonoverflow domain. | Per-operation owner/projection lemmas, independent observation/caller links, arithmetic bridges and bounds. No Boolean certificate inference. |
| `u32_increment_no_wrap` | Below U32 max, machine increment projects to Nat successor. | Library Word/U32 arithmetic lemmas under explicit comparison premise; high-bound checker-normalization gap below. |
| `u32_comparison_agrees_nat` | Machine `<` agrees with Nat comparison of projections. | Word bit representation/conversion/comparison induction; external dependency not adopted. |
| `message_failure_helper` | Actual Data helper preserves failed reader position/registration. | Helper Boolean case, separate wrapper laws required. |
| `message_success_helper` | Successful helper advances to supplied boundary, preserves registration; permanently frozen helper fails. | Helper Boolean/cursor cases; wrapper selects correct reader/boundary later. |
| `message_skip_helper` | Skip advances message cursor and preserves registration. | Helper constructor case; separate lifecycle cursor and no-body wrapper obligation later. |
| `lifecycle_failure_helper` | Failed lifecycle helper preserves both cursor fields and registration. | Helper case; transaction/other-reader preservation later. |
| `lifecycle_success_helper` | Successful lifecycle helper advances both positions, preserves registration. | Helper cases; actual selected-slot success/failure/retry later. |
| `conditional_type_true` | A true conditional Type guard demands its supplied proposition. | Encoder true case; always-Unit must fail. |
| `conditional_type_false` | A false conditional Type guard excludes the supplied proposition as Unit. | Encoder false case; always-claim must fail. |
| `owned_runtime_query_result_and_owner` | Actual query result is complete/ordered on admissible input and its returned owner is preserved. | Independent raw owner projection, model query exactness, actual query caller/return linkage. |
| `owned_runtime_lookup_result_and_owner` | Actual lookup result and returned owner agree with full scoped lookup, including positive local and foreign collision. | Independent projection/handle conversion, full lookup and caller/owner linkage. |
| `owned_runtime_reservation_result_and_owner` | Actual allocator result/Maybe handle and owner agree; wrong/None handles fail below capacity. | Creation/factory domain, guard/no-wrap, exact result conversion and owner correspondence. |
| `owned_runtime_schedule_correspondence` | Actual runtime schedule executes all steps with explicit barriers on prefix-safe input. | Step induction, prefix invariant/width preservation, actual tick caller and no final implicit flush. |

## Every historical audit decision retained

| Historical candidate | Replacement or explicit later obligation |
|---|---|
| `query_any_exact` | Three complete ordered query laws + physical-order independence; old identity equation is historical internal evidence. |
| `query_present_exact` | Present exact membership/value/order law; descriptor/schema/optional required projection later P-Q/S-INTEGRATE. |
| `query_absent_exact` | Absent exact membership/value/order law; general `without` descriptor bridge later P-Q. |
| `foreign_lookup_guard` | Full lookup + same-lineage creation + positive local case + owned operation correspondence; independent-root namespace authority later P-ID/S-INTEGRATE. |
| `foreign_command_guard` | Full publication, target derived only from handle, owned correspondence; public rejection observable still a decision. |
| `reserve_projection` | Full computed-guard reservation, pending lookup, creation, preservation and owned correspondence. |
| `reserve_rejection` | Full allocator equation and actual U32 boundary controls; production exhaustion/reuse/error policy still a decision. |
| `bounded_reservation` | Model invariant/step preservation + increment/comparison bridge + runtime correspondence; runtime width domain and no-wrap explicit. |
| `flush_fifo_projection` | Independent entity-wise logical replay and actual full schedule/owned barriers, including compiling noncommuting FIFO defects. |
| `tick_preserves_pending` | Actual bounded executor with immediate writes and command/reservation/barrier steps; no identity stub. General transactional schedule semantics later P-TX/S-INTEGRATE. |
| `despawn_exact` | Flush exact projection constrains precise deletion, absent-target behavior and survivors; later P-READ/P-CMD must constrain removal/despawn records, relations/scopes. |
| `message_failure_position` | Exact failure + positive success helpers retained; later P-READ wrapper selects reader, restores failed publications, preserves earlier commits/other readers and retry visibility. |
| `message_skip_position` | Exact helper retained; later P-READ wrapper pins condition skip/no body, registration, separate lifecycle cursor, retention/capacity/lag. |
| `lifecycle_failure_position` | Exact failure + success helpers retained; later P-READ wrapper pins both actual positions, independent readers, retry and exact removed/despawn retention/capacity/lag. |

## Reproduce and evidence limits

Run, from this worktree or the integrated repository:

```sh
BENDVY_LAWS_CPU=8 python3 experiments/t11-replacement/falsify.py
BENDVY_LAWS_CPU=7 python3 experiments/t11-replacement/run.py
```

Final local evidence contains **31 law grids, 1,411 true-domain exact equalities,
635 separately excluded Unit controls, 31 compiling primary mutants and twelve
compiling extra mutants killed**. The runtime artifact records 72 matching actual
TS/Native/JS checkpoints, twelve compiling Native/JS defects, four access-negative
pairs, the erasure pair and five word-boundary observations.

Execution was segmented. Session 68449 completed every primary law grid, then
exited **1** on the old extra stage's missing pending-despawn witness; that process
is not reported as terminal PASS. Session 56530 independently rechecked originals
and completed all twelve refreshed extra mutants with **exit 0**. Its standalone
code is persisted as `falsify-extras.py`; `falsification.json` records both stages,
the unchanged Bend hashes and the final runner hashes. The default runner now
includes the same corrected extra controls. In particular a new fixed world with
pending despawn is checked against actual publication and independent admissibility
before mutation, requiring two unaffected entities to survive.

```sh
BENDVY_LAWS_CPU=7 python3 experiments/t11-replacement/falsify-extras.py
```

The runner reads installed `bend version`/`bend guide`, verifies all three reference commits against the tracked manifest and checks Node before directly importing pinned bevy-ts. No package installation or new dependency. Sources are absolute read-only `/workspace/formal-proofs/bendvy/.references/{bevy-ts,bevy,bend2}`; this worktree does not contain their checkout contents. Installed 2.0.34 is the syntax/runtime authority; pinned Bend 2.0.35 source is a cross-check, not proven binary identity.

Every checker invocation uses `../t01/bend-check` (five seconds). Literal slices are one definition each to stay within that gate. Emission (30s) and clang optimization (120s) are separate build work; runtime/reference processes have five-second limits and runner-owned process-group cleanup. Native uses one worker and GPU off; optional task-local CPU affinity changes only this task's own process. These correctness probes measure no performance acceptance.

[falsification.json](falsification.json) records each exact claim, binders, new literal inputs, true/false invariant controls, compiling decision-path mutants and their own-law diagnostics. False conditional premises are allowed as boundary controls but are not counted as positive witnesses. All original literals must check before any defect is tested. The report must show a killed typechecked own-statement mutant for every candidate; additional defects cover foreign comparison, wrong command target, reverse FIFO, wrong remove, no-op despawn, uncleared pending, frozen immediate writes, wrong reserved handle, ignored runtime schedules, barrier bypass and omitted observation fields.

There is an explicit tooling gap: external `lawcheck`/`bend-falsify` are unadopted and compatibility unverified. The dependency-free local runner evaluates exact statement instances; it is not either external tool and does not provide shrinking or universal proof. U32/Nat high-bound equations are not normalized at MAX-1/MAX by the checker: unary Nat at those constants is not a suitable literal workload. Actual compiled U32 boundary observations test guards/no-wrap at those values, **not** the universal arithmetic equations. Do not promote that distinction into approval or proof evidence.

[runtime-evidence.json](runtime-evidence.json) records newly executed actual Native/JS/TS public checkpoints, authority pairs, machine-boundary controls, compiling backend defects and source hashes. Compile/runtime success and the checker's `ALL PROOFS CHECK` on filled safe functions mean ordinary checking here. `LAWS.bend --check-only` intentionally reports 31 TODOs / `SOME PROOFS FAIL`; there is no `PROOF.bend`.

The coordinator independently reproduced the complete runtime artifact and verified the law package in **segmented stages: 25 earlier law grids, six suffix grids and twelve refreshed extra mutants**. The [independent verification report](../../docs/reviews/laws-independent-verification.md) pins the exact unchanged subjects and records terminal results; it does not claim a clean one-shot post-fix run.

## Remaining approval and capability gates

Human approval must name this exact law revision/IDs before proof work. No law, numerical performance threshold, production layout, dependency or rejection/exhaustion policy is approved by this investigation. The full core remains unchanged.

Later explicit packages retain: independent-root/factory provenance; generic declared schema access and noncopyable components; transaction rollback of allocation/marks/cursors/captures and earlier commits; real reader slot selection/registration/success/skip/failure/retry/retention/lag; removed/despawn publications and relation/scope cleanup; provisioning/conditions/phases/dynamic composition; states, validation, restoration and tooling. P-ID/P-Q/P-CMD/P-TX/P-READ/P-PROVIDE and S-INTEGRATE remain draft subjects for separately reviewed detailed work. No blanket performance dependency blocks drafting their actual laws, while product capability/performance acceptance remains mandatory.

## Governing acceptance evidence

| #12 criterion | Evidence and scope |
|---|---|
| Historical audit and withdrawal | Linked source audit/Astra decision; historical `../t11` statements/evidence preserved. |
| Every audit decision mapped | Fourteen-row mapping above includes strengthened operations, five retained cursor helpers and explicit later packages. |
| Interfaces, admissibility, observations and order | DESIGN/types, independent per-entity spec, computed invariant agreement/preservation, sorted complete queries and permuted physical-row controls. |
| Actual guards, namespaces and targets | Two creations through returned factory; computed reservation/publication, handle-derived target, actual local/foreign collision; unresolved public exhaustion/foreign-command policy documented. |
| Independent logical commands and schedule | Per-slot replay, noncommuting FIFO mutation, survivor/unknown-target/queue cases and actual model/runtime schedule with explicit barriers. |
| Positive/boundary controls and later readers | New reachable snapshots, below-capacity live/reserve/query cases, real word boundaries; compiling empty/Missing/reject/no-op defects. Reader wrappers remain explicit later contracts; frozen successful helper is rejected. |
| Runtime relation/owner/type mapping | Direct erased-owner creation/projection/returned-owner/step/query/lookup/reserve/tick equalities, affine live APIs, Nat/U32 domains, nonempty arrays and four access-negative pairs. Element-zero observation and root-provenance limits explicit. |
| Falsification and actual references | New exact literal instances and compiling own-law decision-path mutations; actual pinned TS/Native/JS checkpoints, five-second checker gate and external-tool/high-bound gaps. Final JSON artifacts provide exact results/hashes. |
| Approval-ready proposal without proof | Exact 31 IDs and law hash, per-law rationale/sketch/dependencies, human-review document. Every candidate remains TODO; no general ECS proof or PROOF.bend. |
| Checkpoint and follow-ups | Remaining packages/gates above are supplied for coordinator checkpoint integration. This isolated worker does not edit the shared tracker or publish detailed follow-up tickets. |


## Fresh semantic approval audit

[Astra medium semantic audit](../../docs/reviews/laws-semantic-audit.md) reviewed
all 31 statements independently of mutation counts: seven bounded public-observation
candidates, twenty internal lemmas and four infrastructure facts. The
[approval proposal](../../docs/reviews/laws-replacement-package.md) now requests
only the seven public candidates at that layer; supporting facts remain separately
unapproved. Pending lookup's observer can always return Missing; owned read laws
fix raw physical-row order; element-zero preservation permits loss outside that
projection; independent roots can collide. The report identifies the necessary
subject/representation/refinement corrections before broader claims. No false
equation was identified by inspection, no general proof was written and no Bend
subject or recorded finite evidence changed.
