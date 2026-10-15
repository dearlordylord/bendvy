# Full-core parity — current state

Specification: [37](https://github.com/dearlordylord/bendvy/issues/37). Full parent #1 and performance parents #21/#23/#24 are unchanged. #34, #35, #36, #39, #40 and #47 are delivered for their accepted bounded scopes; full numeric performance remains under #21/#23/#24. Active slices are recorded below.

Publication is complete scope tracking, not capability acceptance. Every issue is labeled ready-for-agent; execute only when its genuine blockers and explicit decision gates are satisfied.

| Issue | Blocked by | Complete observable delivery |
| --- | --- | --- |
| [#38](https://github.com/dearlordylord/bendvy/issues/38) — Complete public identity, reservation and capacity contracts | None | An application safely creates independent worlds, reserves and materializes entities, grows storage and receives precise exhaustion/refusal results without losing owners. |
| [#39](https://github.com/dearlordylord/bendvy/issues/39) — Compose typed schema fragments without descriptor collisions | None | Two independently authored schema fragments form a usable public world with component, resource, event and service access confined to the composed schema. |
| [#40](https://github.com/dearlordylord/bendvy/issues/40) — Execute reusable features with declared dependencies | #39, #34 | An application selects reusable features, binds their declared dependencies to its final schema and executes bootstrap/update schedules in authored feature order. |
| [#41](https://github.com/dearlordylord/bendvy/issues/41) — Spawn and insert heterogeneous typed component bundles | None | A caller authors reusable heterogeneous component bundles and uses them in public spawn/insert commands without consuming payloads on refusal. |
| [#42](https://github.com/dearlordylord/bendvy/issues/42) — Maintain directed links and inverse queries through barriers | None | Systems create, replace and remove typed directed entity links and query both ends with consistent inverse results. |
| [#43](https://github.com/dearlordylord/bendvy/issues/43) — Observe deferred relation failures independently | #42, #35 | Registered systems independently consume ordered relation mutation failures without conflating them with system transaction failure. |
| [#44](https://github.com/dearlordylord/bendvy/issues/44) — Preserve ordered traversal, cycle rejection and linked cleanup | #42 | An application reparents an ordered hierarchy, traverses it and removes linked subtrees with exact cleanup and diagnostics. |
| [#45](https://github.com/dearlordylord/bendvy/issues/45) — Clean entity lifetime groups while preserving persistent entities | #44 | A scene-style lifetime scope owns a group of spawned entities and queues cleanup without deleting persistent entities. |
| [#46](https://github.com/dearlordylord/bendvy/issues/46) — Validate constructed and transient descriptor boundaries | None | Applications construct components/resources from typed raw input and receive exact failures before invalid values or partial work enter the world. |
| [#47](https://github.com/dearlordylord/bendvy/issues/47) — Execute typed finite component states | None | Systems author finite-valued state components, query them and update them transactionally using typed values. |
| [#48](https://github.com/dearlordylord/bendvy/issues/48) — Queue and apply global state transitions with conditions | #34 | An application declares finite machines, reads committed states, queues changes and gates schedules by machine conditions at explicit transition markers. |
| [#49](https://github.com/dearlordylord/bendvy/issues/49) — Preserve exit, transition and enter failure boundaries | #48, #35 | Applications attach typed exit/transition/enter schedules and retry failed transitions without undoing already committed work. |
| [#50](https://github.com/dearlordylord/bendvy/issues/50) — Repeatedly execute systems with owned runtime capture state | #36 | Independently authored systems retain runtime affine capture state across repeated registration, execution, failure and disposal. |
| [#51](https://github.com/dearlordylord/bendvy/issues/51) — Compose heterogeneous captured system instances | #50, #34, #35 | An application reuses typed heterogeneous captured systems across nested schedules with safe registration, disposal and refusal. |
| [#52](https://github.com/dearlordylord/bendvy/issues/52) — Restore general affine payload operations through explicit inverses | #50 | Systems perform recoverable operations on caller-owned affine component/resource payloads and preserve exact state after failed ECS transactions. |
| [#53](https://github.com/dearlordylord/bendvy/issues/53) — Publish and read owned event payloads without illicit copies | #31 | Event publishers and multiple independent readers use useful affine Type payloads under an explicit ownership-safe publication and projection contract. |
| [#71](https://github.com/dearlordylord/bendvy/issues/71) — Route distinct typed Data event streams | #31, #35 (bounded prerequisites delivered) | One ordinary World publishes and reads different Data event types through distinct typed streams; existing cursor, retention and transaction semantics remain intact, and debug derives unused operational declarations automatically. |
| [#54](https://github.com/dearlordylord/bendvy/issues/54) — Read public world projections without consuming system visibility | #35 | Host code repeatedly inspects components, resources and event/removal streams while leaving system reader positions and retention unchanged. |
| [#55](https://github.com/dearlordylord/bendvy/issues/55) — Inspect relations, machines and failure streams safely | #54, #44, #49, #43 | Read-only inspectors observe hierarchy, machine states, transition events and relation failures without affecting schedules or readers. |
| [#56](https://github.com/dearlordylord/bendvy/issues/56) — Describe and dump public ECS structure without side effects | #55, #71 event inventory | A developer enables schema/system/schedule descriptions, lints, access indexes and filtered world dumps without changing ECS behavior. |
| [#57](https://github.com/dearlordylord/bendvy/issues/57) — Observe execution, failure and barrier traces with disposal | #56 | A developer subscribes to ordered execution observations and unsubscribes/resets them without interfering with ECS execution. |
| [#58](https://github.com/dearlordylord/bendvy/issues/58) — Export validated basic world snapshots with independent payload data | #46, #38 | An application exports basic entities, components, resources and allocator progress into an independent save value while preserving the live world. |
| [#59](https://github.com/dearlordylord/bendvy/issues/59) — Validate and atomically restore basic saved worlds | #58 | An application loads a basic save, rejects invalid input before mutation and resumes normal entity/lifecycle operations. |
| [#60](https://github.com/dearlordylord/bendvy/issues/60) — Save and restore ordered relations and committed machines | #59, #44, #49 | A complete public save restores ordered relation graphs and committed machine values with the exact runtime omissions and stream-clearing boundary. |
| [#61](https://github.com/dearlordylord/bendvy/issues/61) — Execute the complete pinned core capability matrix | #40, #41, #45, #47, #52, #53, #56, #60, #34, #35, #51, #57, #43, #71 | An independent public consumer verifies the whole pinned core surface and reports exact remaining differences before full parity is claimed. |
| [#62](https://github.com/dearlordylord/bendvy/issues/62) — Draft and falsify remaining exact core laws | #61 | Maintainers receive a source-bound set of precise remaining laws with falsification evidence and explicit approval status. |
| [#63](https://github.com/dearlordylord/bendvy/issues/63) — Execute the complete deterministic fixed-step ECS scenario | #35, #41 | A reproducible console simulation spawns entities, moves them toward a goal, applies damage, removes them and reports hit/death events through the public ECS API. |
| [#64](https://github.com/dearlordylord/bendvy/issues/64) — Freeze copied Tower Defense integration requirements | #63, #61 | A concrete integration plan identifies the exact ECS contracts needed by a separate copy of Canonical Tower Defense without modifying its original repository. |

Historical TS mechanisms and reusable tooling: [explicit archive index](../archive/ts-extension-index.md). These records do not define ECS scope.

## Immediate frontier

#38, #41, #42, #46, #48, #50 and #53. #34, #35, #39, #40 and #47 are closed; their dependencies permit #48 and the reader side of #43, whose #42 prerequisite remains open. #45 has actual TS preparation while #44 remains prerequisite. Explicit unresolved identity/capture/affine-event contract choices must still be resolved before implementation; there is no blanket approval of divergence.

## Current delivery coordination

This table records the current state of the existing #37 specification and issues.
Issue acceptance and approved contracts remain unchanged. Each worker owns one branch/worktree;
only the coordinator edits this table and shared contracts or integrates
`src/ecs`, common runners, laws, specifications and issue status.

Worktree prefix: `/workspace/formal-proofs/bendvy-worktrees/`.

Keep each row to its current status, current evidence and next action.
The structural guard limits a row to 1,200 characters; disclose detail through links.
Do not append milestones, prior checkpoints or historical summaries here.
Contracts and issue acceptance remain authoritative.

| Task | Agent / worktree / branch | Dependencies | State | Next step |
| --- | --- | --- | --- | --- |
| #38 independent World creation | `missing_resource_direct_consumer` / `identity38-io-creation`; root owns core | Approved IO creation; unchanged #28; entity reuse policy unresolved | [Current-public packet](../../experiments/public-identity/approved-io-creation-v1/README.md) integrated at `07a70564f`: seven public roles, full owner/authority/rollback/exhaustion observations, retained verifier and final review PASS. | Shared-realm JS allocator adopted after independent final review and fresh unchanged #28 PASS (20 pairs/backend, 110 full outputs). Resolve entity reuse/generation policy; broader host domains and allocator hot-path performance remain open. |
| #41 bundles | Root integrator | Constructor-stage/Batch/WorldIO; unresolved #38/#46 policies | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Mixed packet is integrated after [one final review](../../experiments/public-bundles/owned-public-result-v1/canonical-world-v1/mixed-construction-v1/FINAL-REVIEW.md): six complete Bend outputs,15 commands/51 guards and actual TS reference |
| #49 handlers | `debug56_remaining_sources` / `handlers49-current-ordinary-v1` (`parity49-current-heterogeneous`) | #48/#35; approved #36 Local | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Comparative successor `7f30f76f…` is reviewed but deferred under CPU contention |
| #45 lifetime scopes | `missing_resource_direct_consumer` / `scopes45-lifetime`; root integrates shared core | #44 cleanup; approved ownership contracts | Bounded source/evidence integrated: four additive modules; low-level, canonical frontend, authority/order and deferred-after consumers qualify full JS/Native observations. Aborted reservation and same-transaction spawn→cleanup pass; reached JS survivor-deletion control matches the full counter oracle. Original frontend JS receipt remains INCOMPLETE; corrected retained-output validation is separate. | [Bounded final review](../../experiments/public-scopes/delivery-v1/FINAL-REVIEW.md) and retained verifier/12 controls PASS; unchanged #28 packet reused under exact applicability. Matched adapter and independent 26/52/104-record oracles are integrated. Fresh ordinary TS/JS/Native O3 match all52 records/12932 bytes; [retained packet and final review](../../experiments/public-scopes/feature-timing-delivery-v1/FINAL-REVIEW.md) PASS. Timing/scaling and full #45 acceptance remain open. |
| #44 public hierarchy traversal | Root shared-core integrator | Existing relation providers; full #42 remains open | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Resolve remaining gates in owning issue and preserved status |
| #48 cleanup controls | Root shared-core integrator | Existing System/reader ownership; initialization choices unresolved | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Resolve remaining gates in owning issue and preserved status |
| #48 typed provisioning | `debug56_feasibility` | Existing machine Slot/Family; unresolved initialization adaptations | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Independent complete normal/mutant/Flow-only models are frozen (`4f3ab2d9`) |
| #42 relations | Root integrator; `missing_resource_direct_consumer` / `relations42-io-authority-v1` delivered | Existing relation operations; approved #38 WorldIO | IO-origin slice integrated at `54ce441e9`, CI passes; source-current reuse reconciled at `4c3546098`. [Full evidence](../../experiments/public-relations/ordinary-reader-query-v1/independent-io-authority-delivery-v1/README.md). | Existing nine-case feature timing/scaling remains open under contention; no further semantic fixture gap established. |
| #43 relation-failure readers | `event_schedule_independent_oracle` / `parity43-ordinary-full-lifecycle-sparse` / `parity43/ordinary-full-lifecycle-sparse`; root owns core | Integrated ordinary shared-runtime provider | Reviewed composition/retention/disposal slice integrated at `92975df9b`; CI passes, status at `6c4e8a9d5`. [Evidence and scope](relation-readers.md). Existing full-capacity evidence uses older direct readers. | Private command-aware barrier `8b84159e9` passes module checks and actual scheduled writer/barrier/two-reader JS/Native smoke (2,781-byte independent oracle). Full-capacity successor `a97a93792` is source-checked; complete owner/domain/skip observations are being added before acceptance. Final review/integration and feature timing remain open. |
| #54 Inspector | `missing_resource_direct_consumer` / `observable-query-boundaries`; root owns core | #35; existing declarations/limits | Full JS/Native and numeric oracles pass; all nine JS/Native/TS 1/2/4 runs and eleven existing type controls qualify at their exact scopes. Recovered project-relative wrapper executes stock check/f1a JS emit/full226096 oracle with thirteen clean guards; independent final review PASS. | Combined220 passes unchanged #28. Prepare existing complete-feature comparison with explicit same pipeline for frozen baseline/candidate. Comparisons HOLD under host contention; production adoption and #38 independent identity remain open. No more type-gate expansion without a concrete missing operation. |
| #55 extension study | Runtime entry: `event_schedule_independent_oracle` / `inspector55-runtime-entry`; lifecycle: `missing_resource_direct_consumer` / `inspector55-feature-timing`; independent oracle: `event_schedule_final_review`; root integrates | Existing Inspector/stream grants; runtime-owned frame | Runtime entry has retained JS full-oracle revalidation (original receipt INCOMPLETE), fresh Native pass, canonical authority controls and a reached clock mutant. Reviewed runtime entry and its 162-member packet are integrated; offline verifier and controls pass. The matched lifecycle now has actual TS/JS/Native scale-1 passes against all 24,298 bytes; the earlier Native timeout is preserved. The root-facing fixture and its 227-member packet are integrated after independent review. [Evidence and current gap](inspect-extended.md#runtime08-compiler-blocker-resolution). | Qualify complete feature timing/scaling with the existing harness; preserve local-world and WorldIO scope boundaries. Preserve reader/retention state; comparative runs HOLD under contention. |
| #56 ordinary debug | `missing_resource_direct_consumer` / `debug56-opaque-formats-current` / `parity56/opaque-formats-current`; root owns core | Integrated automatic reader-product metadata | Description/access consumer passes full 19,822-byte JS/Native oracle and independent review; CI passes. [Scope and evidence](debug.md). Physical fixture diagnostics are not public dump execution. | Public product dump integrated at `b68160da4`, CI passes. Current opaque graph/plain/transient successor `14b4fbb7d` passes fresh JS/Native against the independent 201,468-byte oracle `a28638a75`, including actual readerId/nextReader. Retain packet, final review and integrate. Remaining full-feature timing stays open. |
| #71 distinct typed Data events | `observable_query_boundaries` / `ordinary-schedule-debug-v1` | Existing #31/#35 reader contracts; #56 inventory | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | The regular interval adapter passes independent final review and complete JS/Native/TS correctness: seventeen actual operations and seventy-two full observations |
| #57 execution trace | `observable_query_boundaries` | #56; subscriber/affine/IO contracts unresolved | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Resolve subscriber ownership/delivery contracts from Rust Bevy and Bend; preserve historical reference scope |
| #61 audit preparation | `debug56_remaining_sources` / `public-audit61-app-b` | Pinned Bevy/Bend/TS; dependent feature acceptance | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | AppB reparent controls pass four complete 14,978-byte outcomes and two reached baseline rejections (`fcafaa1559`); independent final review and integration complete |
| #70 resource confinement | Root | #61; existing Product/schema; #38/#52 separate | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | No remaining #70 finite gate |
| #63 fixed-step simulation | Root retains private `simulation63-tx-get-feasibility` candidate; implementation owner reassigned #45 | #35/#41; frozen ordinary tool/resource guards | V7 normal/hit/death controls and private tuple-fusion semantics integrated without core adoption. Timer qualification packet `fef737165` passes retained839-member verifier, configured checks and final review; CI38598234270 SUCCESS. | Candidate four commands/full TS/JS/Native/strict clocks and15 guards PASS. Baseline outputs qualified posthoc without rerun; original missing-pin receipt stays INCOMPLETE. Sampling/profiles HOLD under CPU contention; benefit/adoption, timing/scaling/full acceptance remain open. |
| #46 complete decoding | `/root/event_schedule_independent_oracle` / `decode46-native-resume-v1`; root integrates | Canonical Codec/constructors; #38/#59 policies unchanged | Full fresh32 lifecycle/repeats and current40 codec cases pass. Two-schema constructor precedence passes full4682-byte JS/Native oracle; same fallible-path bypass matches2940-byte counter and rejects structurally rebased normal, final review PASS. Current22 handle/owner replay now passes JS and standard -O3 Native, exact80,800-byte oracle; [final review](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/native-consuming-current-v1/FINAL-REVIEW.md) PASS. | Producer `e73060c98` integrated at `f13765324`; Reuse current handle-admission evidence:41 source joins match, genuine same-schema live ID1 collision; no duplicate fixture or process-wide uniqueness claim. New schema provisioning branches are outside22 runtime scope and have separate classified-schema evidence. Paired performance held for quiet admission; #58/#59 retain save/restore gates; #46 remains open. |
| #58 snapshot export | Root integration of `missing_resource_direct_consumer` / `snapshot58-ordinary-constructor-save` | Existing #46 constructor/admission; approved #38 WorldIO; restore policies unchanged | Ordinary constructor → Save passes complete JS/Native observations; admission-bypass and included-transient controls are detected. [Evidence](../../experiments/public-snapshot/ordinary-constructor-save-delivery-v1/README.md) preserves the transient run's original INCOMPLETE receipt and separate v2 revalidation. Independent final review passes. | Equivalent feature timing/scaling and full #58 acceptance remain open. |
| #59 restore readiness | `simulation63_delivery` | #58/#46 constructor/admission provider; unresolved stale-handle identity | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Select outstanding Bend ownership/identity policies from one source-backed packet; implement declaration-bound construction and atomic restore |
| #64 defense preparation | `inspector54_retention_fail_skip` | #61/#63 remain open; canonical repository read-only | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Revalidate source pins and prepare the separately copied integration after prerequisites |
| Shared core/integration | `/root` / `master` | Reviewed packets; one core integrator | Runtime Inspector and matched lifecycle fixture integrated; master `bd42c8c61` CI `38659795024` SUCCESS. Scale-2 timer semantics pass all 48,594 bytes on TS/JS/Native; paired comparisons wait for quiet-host context. Unrelated WIP preserved. | Finish the two unblocked semantic streams, reuse qualified evidence, serialize heavy runs and batch executable integration gates. |
| #50 / #53 research | `/root` | #36/#31; unresolved public ownership contracts | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | Complete App/access integration and trusted-provider preservation; resolve publication/retirement/capture contracts |

### Fixed assignment contracts

Common requirements: read the governing issue and source-bound existing evidence;
use pinned bevy-ts, Rust Bevy and Bend sources. Preserve arbitrary affine `Type`
payloads, opaque-handle confinement, nominal schemas and actual independent
worlds. Never amend shared contracts, limits, baselines, dependency versions,
laws or unresolved policy to make a check pass. Report a proposed interface
change to the coordinator first. No proof against unapproved laws. Historical
receipts remain immutable; migration is not a current-source rerun or a silent
rebase. Private environments and generated caches must stay out of Git.

- **#41 ownership:** only `experiments/public-bundles/owned-public-result-v1/`.
  Contract: closed reusable request with independently fixed `Input`, `Output`,
  `Args`, `BodyOutput: Type` before abstract `H`; immediate refusal returns actual
  Raw owner to gameplay and allows retry; accepted packet/inverse transfers into
  existing Batch. Complete the issue's public spawn/insert and heterogeneous
  duplicate/construction/replacement/deferred-order surface; the current22-row
  insert slice alone does not finish it. Required evidence: full independent
  two-schema outputs, actual TS coverage joins, JS/Native, undeclared provisioning,
  actual cross-schema request, read authority, owner/context duplication and
  H escape controls; reached omitted-component mutation; exact cleanup/rollback.
  Escalate failed activation/reservation ownership policies rather than choosing.
- **#49 ownership:** only `experiments/public-machine-handlers/candidate-v1/`.
  Contract: exit/transition failure preserves old state and retries queued change;
  earlier successful handler effects stay committed. Enter failure happens after
  state/event commit and is not automatically retried. Handler-enqueued changes
  wait for a later marker. Use genuine System registrations/cursors, independent
  stream domains, actual affine components/resources and approved Local cells;
  no new capture contract. Required evidence: all96/eight checkpoints and12
  requirement refusals, definition/handler order, complete owner/pending/event
  state; JS/Native; whole-marker rollback, premature-publication and lost-retry
  compiling mutants; authority/ownership negatives.
- **#42 ownership:** only `experiments/public-relations/timing/current-qualification-v1/`.
  Contract: same complete public trace and actual registered operations in both
  roles; all immutable trace fields forced between Begin/completion, serialization
  and independent full validation afterwards. Preserve deferred inverse/order,
  future reservations, failures and rollback. Required evidence: full30 anchor,
  last-leaf/moved-walk falsifiers, generated JS/C effect-order review and Native;
  real population/fanout/depth correctness families and later equivalent-work
  serial timing. Existing semantic capsules are reused only through exact joins.
  Eight untracked relation modules are immutable dependencies, not worker-owned
  production edits; coordinator alone decides their reviewed adoption.
- **#54 ownership:** only new `experiments/public-inspect/promotion-stage/`.
  Contract: repeated read-only projections return World/affine owners; no writes,
  barrier flush, System reader advancement/registration or retention participation.
  Required evidence: source-backed coverage of all pinned Inspector read and
  condition/error categories; complete two-schema output/actual TS comparison,
  exact missing/undeclared/read-only negatives and reached reader-consumption
  mutation. Reuse delivered retention/optional-resource capsules with precise
  source joins. Implement confirmed gaps in this owned candidate directory;
  independent-world identity remains governed by #38. Current Inspector returns detached Data plus affine owners; no held-view API is proposed.
  Relation/machine inspection stays dependent #55, not silently substituted for #54.

- **#61 preparation ownership:** `docs/reference/core-map.md` current inventory,
  preparation materials appended to `docs/parity/coverage.md`, and optional
  `docs/archive/ts-port/core-export-inventory.json` (historical reference census; not an implementation checklist). Preserve historical inventory and
  existing acceptance criteria. Reconcile all pinned public core entrypoints,
  exports/reexports, bound APIs, substantial usage combinations, source tests and
  static/error boundaries. Each row names the contract, actual implementation,
  exact verification evidence, concrete remaining gap and existing owning issue.
  Distinguish integrated public code, experimental candidates and absent behavior;
  no new contract/divergence, implementation or #61 closure. Hand off a concrete
  owned commit, complete source inventory, focused checks and explicit limits.
  Source/document checks only; hooks and any executable checks use the shared queue.

### Consolidated ownership decision queue

No ownership contract below is selected by this coordination change. Keep one
approval packet; the existing #50 question remains pending and is not repeated.

| Issue | Concrete approval subject | Source basis / status |
| --- | --- | --- |
| #54 association | `canonical_full23_delivery` / `native54-matching-tree-v1` (ordinary current consumers and typed event Inspector capability); independent final review `inspector_integration_review`; root owns shared core | The extra registration-liveness proposal is withdrawn: Rust QueryState/SystemState World checks do not establish dependence on a registered System remaining present. No borrowed registered-cursor entry or new rejection result is adopted. Current Inspector returns detached Data and affine owners, so a held-view gate is not applicable. Query capabilities are schema/family typed, not bound to one World instance; namespace uniqueness across independent factory roots is the concrete #38 dependency. |
| #50 | Confirm the complete [capture draft](captures-contract-draft.md): affine pack returned on run/failure; skip/refusal unchanged; sequential sharing separate from World registration/cursors; successful one-time closed finalizer, refusal returns both owners. | Actual TS capture study supports failure/skip/sharing; TS does not establish disposal. Local approval is separate. Awaiting the existing explicit reply. |
| #53 access | Choose detached Data projections or opaque scoped read-only visitor with optional detached observations; explicitly approve departure from TS shared mutable alias identity. | [Observed study and proposal](../../experiments/public-owned-events/RESEARCH.md): TS shares objects, Rust readers borrow, Bend cannot duplicate arbitrary Type. A callback merely returning its owner does not prove read-only projection; the trusted concrete provider boundary, before/after preservation controls and any separately approved preservation laws must be explicit. Opaque scoped capabilities confine gameplay but do not prove provider purity. |
| #53 ownership/release | Confirm publication transfers into one log, refusal returns unpublished owner, failed reads retain log owner/cursor; distinguish reader disposal from record removal and define projection survival after trim. | Proposed only. Preserve existing Data-event cursor/retention behavior. Internal RC release is not a public finalizer contract; no destructor callback is silently added. |

Source investigation and typed interface preparation may continue; implementation
of these ownership-visible choices waits for approval. No new laws/proofs follow
from accepting a behavior contract; specific laws need their own approval.

### Resource and handoff protocol

Coordinator owns shared `src/ecs`, interfaces and integration. Workers own their
assigned files/worktrees, preserve others' edits and hand off exact commits,
source-bound receipts, complete outputs and remaining acceptance gates.
Use [workflow](../agent-workflow.md) and [check policy](../check-policy.md) for
execution/review; retain existing assignment contracts and unresolved approvals.

Authoring, research and review may run concurrently. One heavy stage runs at a
time using one owner of `/tmp/bendvy-parity-heavy.lock`; performance cohorts have
an exclusive reservation after host assessment. Current caps remain checker5,
emit30, compile120, runtime5; Native one thread/GPU off. Explicitly approved
scoped exceptions remain scoped; timeouts are inconclusive. A source diagnostic
slot may batch up to four affected checks within60s. Reuse existing runners and
run general regression on combined executable integration.

Keep this table to current owner, blocker, evidence link and next result;
evidence history belongs in linked reports.

## Full-scope return conditions

- Proof execution is deliberately not published as unconditional agent work: #62 drafts/falsifies exact remaining subjects and obtains specific approval; approved executable-proof/mutation and any backend-refinement slices are then published. Seven #18 subjects remain delivered; supporting candidates remain unapproved.
- #64 inventories copied Tower Defense requirements and publishes exact copy/integration tasks after its concrete capability, proof/performance and host-adapter prerequisites exist. Canonical jev stays read-only; reducer migration is a separate decision.
- #61 inventories every pinned public core export and type/error boundary. Any missed behavior must receive an owning task and be implemented before audit acceptance; the audit cannot replace missing features.
- Full equivalent-work performance and full connected qualification stay in #21/#23/#24. Neither scoped Workshop timings nor completing this feature list closes them.

## Source and test authority

[Three-reference source review](source-review.md) records bevy-ts behavior, Rust Bevy architecture and Bend ownership/runtime constraints, with exact read-only inputs. Existing independent public application traces are the highest test seam. New planning source descriptions remain unobserved until their actual TS/JS/Native controls execute.

Current combined core: [combined220 final review](../../experiments/integration-gates/combined-ordinary-app-v1/actual-attempt220-01/FINAL-REVIEW.md) accepts the unchanged #28 Workshop gate: all 123 commands and 110 full outputs pass, with no statistically confirmed regression. Whole-process median candidate/TS ratios are JS 0.413595 and Native 0.099988; these do not qualify complete feature timing or close parity tickets.
