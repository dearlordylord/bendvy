## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Maintainers receive a source-bound set of precise remaining laws with falsification evidence and explicit approval status.

## Acceptance criteria

- [x] Retain the delivered seven #18 subjects and the withdrawn historical proposal boundary. Reconcile the 22 supporting candidates against final executable contracts without silently treating them as approved.
- [x] For each proposed subject state exact results, preservation, bounds, helper/failure behavior and its model/executable/backend scope; provide meaningful planted-defect falsification and non-vacuity controls.
- [ ] Present the exact candidates for human approval; no ECS proof against an unapproved subject. Record rejected/deferred subjects and owning follow-up rather than weakening them invisibly.
- [x] This ticket delivers proposals/falsification, not proof acceptance. Publish approved proof/mutation/refinement slices only after exact subjects exist; universal refinement is never inferred from finite traces.

## Blocked by

- #61

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Exact approval boundary and current reconciliation

The original [31-law catalog](../../experiments/t11-replacement/LAWS.bend) remains
byte-exact at SHA256 `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
The withdrawn earlier proposal remains historical. Neither an issue title nor a
finite execution approves another law.

The [#18 delivery](../tickets/17-approved-observation-proofs.md) proves exactly
`lookup_full_exact`, `query_any_complete_ordered`,
`query_present_complete_ordered`, `query_absent_complete_ordered`,
`explicit_flush_independent`, `schedule_execution_exact` and
`owned_runtime_schedule_correspondence`. The first six concern the frozen Nat
value/tag model. The last concerns its separately approved owned prototype,
primitive schedule and element-zero observation, not the current generic ECS.
Its sole approved live-world-binder revision is SHA256
`8e400d78b08530ff17295fa32190d0cf93b1f4641816d2710506b64a8ae2940b`.

[Delegated exact approval](https://github.com/dearlordylord/bendvy/blob/8e149fdf8cf7f528ba7d7dce82b600f1fb0213a0/docs/reviews/delegated-owned-law-approval.md)
also covers `u32_increment_no_wrap` and `u32_comparison_agrees_nat` at
SHA256 `7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937`.
Increment excludes MAX; comparison is total over U32 pairs. Neither selects
allocator reuse, numeric capacity or foreign-world policy. Thus **22 catalog
subjects remain unapproved**, not24:20 internal candidates and two conditional
Type-encoder facts. Historical comments that say24 predate this decision.

The table reconciles every remaining exact ID against source at `a969f8c00`.
"Retain" preserves a historical mathematical subject and evidence; it does not
request approval or claim that the production code implements that model.
Deferred current refinement stays with #62, informed by #61's current API audit.
No new ticket or public runtime policy is created.

| Unapproved catalog ID | Exact historical result and domain | Current disposition and limit | Current seam |
| --- | --- | --- | --- |
| `admissibility_independent` | Total equality of the frozen Nat invariant and its independent count-based specification, including malformed inputs. | Retain model-only, unapproved. Current allocator phases, generation, free/order lists and generic store invariants are absent. A current invariant/representation relation remains #62 work after #61. | [`entity-allocator.bend`](../../src/ecs/entity-allocator.bend) |
| `namespace_creation_exact` | Experimental Nat factory creation uses next < limit, increments one threaded factory, starts local ID1, and preserves rejected factory. | Do not promote. Current WorldIO supplies independent-world authority and allocator capacity separately. This equation does not specify process-wide IO provenance. | [`world-io.bend`](../../src/ecs/world-io.bend) |
| `namespace_two_created` | Two creations through one returned factory produce next and next+1 under next+1 < limit. | Retain as single-lineage model fact only. It neither proves uniqueness of independent roots nor constrains current global WorldIO. | [`world-namespace.bend`](../../src/ecs/world-namespace.bend) |
| `reservation_exact` | Frozen reserve returns the next Nat ID, preserves raw rows and appends exactly one Spawn, or returns unchanged world on its bound. | Retire as a production allocator proposal. Current reserve may reuse an index at its current generation; deferred marking, failure consumption and cleanup-owned release are distinct operations. | [`entity-allocator.bend`](../../src/ecs/entity-allocator.bend) |
| `reservation_pending_lookup` | On model admissibility, a separately replaceable reserved_lookup helper returns Missing, including rejection. | Replace its intended production meaning, not its historical bytes. A future law must bind an actual successful returned full key to the actual lookup before activation; an always-Missing helper is insufficient. Current finite #38 evidence remains scoped. | [`commands.bend`](../../src/ecs/commands.bend) |
| `publication_authorized_target` | Frozen publish appends a target/action on equal numeric namespace and otherwise returns unchanged world, without a result. | Retire as a public command proposal. Current command admission checks namespace, full generation and live/pending status, returns MissingEntity on refusal and preserves the receiver queue. | [`commands.bend`](../../src/ecs/commands.bend) |
| `admissibility_preserved` | Every Nat primitive step preserves the model invariant under its independent admissibility premise. | Retain model-only. A no-op can satisfy it; it does not characterize current transactions, callbacks, allocation phases or runtime observations. | [`entity-allocator.bend`](../../src/ecs/entity-allocator.bend) |
| `query_independent_physical_order` | Reversing the frozen model physical rows preserves the selected query under admissibility. | Retain model-only. Current visible iteration follows logical reservation order across recycled physical slots. Reversal alone is neither complete query semantics nor arbitrary permutation independence. | [`query.bend`](../../src/ecs/query.bend) |
| `owned_runtime_creation_correspondence` | Experimental U32 factory/World observation equals its Nat creation result. | Defer a current replacement in #62. The historical factory is constructible, observes fixed value/tag cells and uses the old numeric policy; current WorldIO and generational allocation are different subjects. | [`world-io.bend`](../../src/ecs/world-io.bend) |
| `owned_runtime_projection_exact` | The prototype project result equals independent raw fields and element zero of each owned Array. | Retain only as prototype scope. A current observation must name every observable generic family; matching element zero is not full payload preservation. | [`column.bend`](../../src/ecs/column.bend) |
| `owned_runtime_projection_preserves_owner` | The returned prototype owner has the same raw element-zero snapshot as its input. | Do not request as generic owner preservation. Array truncation or reconstruction can satisfy it. A representation-neutral relation for full observable owners remains #62 work. | [`capabilities.bend`](../../src/ecs/capabilities.bend) |
| `owned_runtime_step_correspondence` | A safe prototype primitive step agrees with independent Nat step observation; Bump excludes overflow. | Defer current refinement. Real system failure, prior commits, actual returned values, journal ownership and explicit deferred carriers are absent from the prototype. | [`transaction.bend`](../../src/ecs/transaction.bend) |
| `message_failure_helper` | The old t07 complete(False,cursor,started) returns exactly the supplied two-field cursor. | Replace at the current pure metadata seam below. Current completed_positions activates an absent reader on failure but preserves existing cursors and registration metadata. It is not unconditional whole-list identity. | [`event-stream.bend`](../../src/ecs/event-stream.bend) |
| `message_success_helper` | The t07 helper changes last to supplied started and preserves registered. | Replace with exact selected-position and full Stream metadata equations below. They expose activation, duplicate raw IDs, unrelated positions and supplied tick behavior without inventing a monotonicity premise. | [`event-stream.bend`](../../src/ecs/event-stream.bend) |
| `message_skip_helper` | The t07 explicit skip helper advances its cursor to the supplied current boundary. | Replace with an exact explicit advance equation below. A false ordinary condition is a different path and preserves an unentered reader; this law must not select TS discard-on-false behavior. | [`event-stream.bend`](../../src/ecs/event-stream.bend) |
| `lifecycle_failure_helper` | The t08 helper returns the supplied last/message/registered reader unchanged after failure. | Retire as a current lifecycle wrapper law. Current tracked Registry cursor and independently registered stream positions are separate owners; a correct helper alone cannot prove selected-reader rollback. #62 retains that proof obligation. | [`system.bend`](../../src/ecs/system.bend) |
| `lifecycle_success_helper` | The t08 helper sets both last and message to started while preserving registration. | Retire as a universal current cursor rule. Current tracked systems use actual completion clock; stream publication uses its own epoch. No equality between all domain clocks is proposed. | [`system.bend`](../../src/ecs/system.bend) |
| `conditional_type_true` | Frozen S.When(True,claim) is exactly claim, for an erased Type claim. | Retain unapproved infrastructure only. This pins a proposition encoder, not an ECS behavior; an exact future proof must not silently fill this catalog statement as a renamed helper. | [`spec.bend`](../../experiments/t11-replacement/spec.bend) |
| `conditional_type_false` | Frozen S.When(False,claim) is exactly Unit, for an erased Type claim. | Retain unapproved infrastructure only. Excluded Unit instances are not successful equality/non-vacuity evidence for another law. | [`spec.bend`](../../experiments/t11-replacement/spec.bend) |
| `owned_runtime_query_result_and_owner` | Prototype query returns exact model rows plus the same raw element-zero snapshot. | Defer current replacement. Required/optional/filter composition and generic payload observation need a named logical relation; raw physical snapshot equality would overconstrain legitimate storage. | [`ordinary-query-declaration.bend`](../../src/ecs/ordinary-query-declaration.bend) |
| `owned_runtime_lookup_result_and_owner` | Prototype lookup returns exact model result and raw element-zero owner observation, including malformed rows. | Defer current replacement. Current namespace/full-key validation and typed family result must be bound to the returned owner under an explicit complete observation, not inherited from this prototype. | [`world.bend`](../../src/ecs/world.bend) |
| `owned_runtime_reservation_result_and_owner` | Prototype U32 reserve interpreted through element-zero observation equals exact Nat reserve. | Retire the numeric/raw-layout equation as production policy. Current consumed/pending/live/dead/free phases, full-key reuse and admission ordering require different exact subjects. | [`entity-allocator.bend`](../../src/ecs/entity-allocator.bend) |

Historical falsification is retained in
[`falsification.json`](../../experiments/t11-replacement/falsification.json):
1,411 active equality instances,635 excluded-domain controls,31 primary
compiling mutants and12 refreshed extras. Its law stage and refreshed-extra
stage have separate receipts; an obsolete later stage made the original whole
command nonzero. These facts apply only to its frozen functions and literals.
They neither requalify current generic modules nor supply approved proofs for
these22 subjects. The existing proof packages retain their exact checker/kernel
and mutation scope without being rewritten here.

## Separate metadata drafts remain unapproved

The following eleven subjects are a separate draft inventory. They are not
members of the historical31-law catalog or its22 remaining unapproved subjects,
and they are not included in the four proposals below. Their existing receipts
remain finite falsification evidence, not human approval or proofs.

| Existing draft | Exact subjects and scope | Retained evidence and current applicability |
| --- | --- | --- |
| [Nested provision](../laws/nested-provision-draft/README.md) | `category_identity`, `stable_first_union`, `authored_flatten`, `authored_requirements`, `complete_ordered_missing`: pure schedule-provision metadata and ordered missing requirements. | [Existing receipt](../laws/nested-provision-draft/evidence-final/receipt.json) records JS/Native literals and five planted defects. Its governed whole-source hash differs from current `schedule-provision.bend`; this index does not requalify the current module. |
| [Schedule readers](../laws/schedule-readers-draft/README.md) | `stable_partition`, `filtered_batch_order`, `retained_publication_ticks`: pure reader-domain partition, filtering and retained tick metadata. | [Existing receipt](../laws/schedule-readers-draft/evidence-final/receipt.json) records JS-only literals and three planted defects. It does not establish Native behavior, runtime reader ownership or current whole-source applicability; `reader-domains.bend` has changed. |
| [Schema fragments](../laws/schema-fragments-draft/README.md) | `collision_classification`, `validation_priority`, `declaration_membership`: pure fragment classification, validation order and membership. | [Existing receipt](../laws/schema-fragments-draft/evidence/receipt.json) records245 JS literal instances and five planted defects. It does not establish Native behavior or a generic runtime guarantee; the documented governed `schema-fragments.bend` hash differs from current source. |

All eleven remain **unapproved and deferred**. Their original law text,
specifications, receipts and source pins stay unchanged. A later exact proposal
must first reconcile its current helper body, domain, complete observation and
backend scope under #62, informed by #61. No approval of this index promotes
these drafts or extends their historical evidence to current executable APIs.

## Four concrete current helper proposals

The additive [law text](../laws/current-reader-key-draft/LAWS.bend) and
[independent specification](../laws/current-reader-key-draft/spec.bend) are
**unapproved**. The exact specification functions are part of each subject.
They characterize existing pure Data helpers, not an amended runtime policy.
No definition fills a law and no ECS proof file is added.

| Exact proposed ID | Result, preservation and domain | Why this subject and its falsification witness |
| --- | --- | --- |
| `full_key_equality` | For every two U32 index/generation pairs, actual `Key.equal` equals independent index-then-generation equality. Both fields matter. It does not assert liveness, namespace authority or permanent uniqueness after generation wrap. | A generation-omission mutation must distinguish1:2 from1:3. Equal pairs and equal MAX pairs prevent constant-false success; unequal indices prevent a generation-only implementation. |
| `selected_completion_positions` | For any raw position list, supplied ID, Nat tick and success flag: if the ID is absent, prepend exactly Position(id,0,tick−1 with Nat subtraction); otherwise preserve activation state. Success changes the cursor of every matching raw position to tick, retaining registration; failure preserves existing cursors. Nonmatching positions, order and multiplicity stay exact. | Advancing on failure must disagree for an existing selected reader. Missing-reader failure is a separate activation witness. Empty positions, absent-reader tick0 saturation, duplicate IDs, ID0 and existing cursors above the supplied tick expose the total helper domain, not public registration permissions or a monotonicity claim. |
| `stream_completion_fields` | For all nominal schemas and Data event types, actual `completed` returns the full Data Stream with only positions changed according to the preceding independent specification. Domain, all batches and values, nextReader, frameStart, boundary, capacity and dropped are preserved exactly. | Resetting dropped to0 must disagree on nonzero dropped metadata. Both schemas, existing/missing IDs and both outcomes exercise the position transition while retaining every other field. This is not preservation of an affine World, event-log payload owners or callbacks. |
| `stream_explicit_advance` | For all such Streams, actual explicit `advance` equals independent successful position completion, preserving the same other fields. This pins the actual caller separately from `completed`. | A mutation advancing to0 instead of the supplied tick must disagree on nonzero ticks. Absent and duplicate positions and tick0 prevent accidental assumptions. Explicit advance does not mean that a false ordinary condition invokes advance. |

These equations quantify unbounded lists and Nat ticks, plus the actual U32 key
and ID types. Their literal fixture is finite:18 complete actual/specification
rows over two phantom schemas. No equality is conditional on a Boolean premise,
so excluded-domain Unit values cannot count as successful instances. The raw
helper permits ID0 and duplicate positions; this does not grant authority to
construct a registered runtime reader with those values.

The independent specification scans for ID existence and maps selected positions;
it never calls production `equal`, `lookup`, `activate`, `update` or
`completed_positions`. Full Stream comparison preserves empty and nonmonotone
batches because these particular helpers do not perform retention trimming.
Tick correctness at a real provider, reader selection, namespace rejection,
rollback/publication ordering, retention/lag and arbitrary affine payload
preservation remain separate #61/#62 obligations. Existing finite application
receipts support those cases only within their stated source and backend scope.

The source basis is Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`,
Bend `a950fd683c0d76f09794078e6174fe98a1492876`, then bevy-ts
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. Current entity generation equality
supports the approved #38 behavior, including eventual full-U32 wrap/alias.
The selected-position helpers implement the existing entered-reader completion
contract. Pinned TS's discard-on-false condition path does not override Bend's
preserve-unentered-reader contract. No new TS-specific API is proposed.

The pinned default-five-second source check reports exactly four open TODOs for
the law file. The [18-row successor](../laws/current-reader-key-boundary-v2/falsify.bend)
and all four private planted-defect fixtures pass ordinary type/quantity checking.
The stock JS and Native normal executions both match the independently authored
complete 2,396-byte oracle. Four JS planted defects each match their independently
authored complete counter-oracle and reject the entire normal oracle: generation
omission, advancing an existing reader on failure, losing dropped metadata and
advancing to zero. Their changed equality-row counts are respectively 1, 4, 4
and 3. The same independent oracle/model was sealed before any subject execution.

The [portable packet](../laws/current-reader-key-boundary-v2/falsification-evidence/actual-attempt01/manifest.json)
retains all six roles, thirteen successful commands, full output and generated
artifacts, frozen imports, tool/resource joins and independent model. Its
[offline verification](../laws/current-reader-key-boundary-v2/falsification-evidence/actual-attempt01/FULL-JOIN-VERIFICATION.json)
reconstructs the objects and reproduces all expected text without backend replay.
This establishes meaningful finite falsification of these exact proposals; it is
not a proof over all inputs or a Native execution of each mutant. All four
subjects remain **unapproved**. No ECS proof was attempted. Historical law/proof
files, source modules, approval records and reference checkouts remain unchanged.

### Independent review and approval status

Astra medium technical/launch/final review and Luna max source research found no blocking defect in these four pure Data proposals. Final review of `ea6a042ec` independently verified all 519 retained bindings, six reviewed plans, thirteen successful commands, generated artifacts and every complete output against pre-execution model `c4a3700ce`. The key equation concerns index/generation only, not namespace or liveness. Raw MAX indices and ID0/duplicates do not assert valid public entities or reader registrations.

Human approval is still pending for the four exact law blocks at SHA-256 `b86435ad296308c3869ddf00d8603db83e7125aad6637bc203721a39ec43f6ed` and independent specification `aea16de7c7f9912322178d2c2337d44c7e71b6acd92e9c3421499f53d07526ea`. The 22 legacy and 11 separate metadata drafts are excluded. No proof has been written against an unapproved subject.
