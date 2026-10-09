# Full-core parity — current state

Specification: [37](https://github.com/dearlordylord/bendvy/issues/37). Full parent #1 and performance parents #21/#23/#24 are unchanged. #34, #35 and #39 are delivered; the active slices are recorded below.

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
| [#54](https://github.com/dearlordylord/bendvy/issues/54) — Read public world projections without consuming system visibility | #35 | Host code repeatedly inspects components, resources and event/removal streams while leaving system reader positions and retention unchanged. |
| [#55](https://github.com/dearlordylord/bendvy/issues/55) — Inspect relations, machines and failure streams safely | #54, #44, #49, #43 | Read-only inspectors observe hierarchy, machine states, transition events and relation failures without affecting schedules or readers. |
| [#56](https://github.com/dearlordylord/bendvy/issues/56) — Describe and dump public ECS structure without side effects | #55 | A developer enables schema/system/schedule descriptions, lints, access indexes and filtered world dumps without changing ECS behavior. |
| [#57](https://github.com/dearlordylord/bendvy/issues/57) — Observe execution, failure and barrier traces with disposal | #56 | A developer subscribes to ordered execution observations and unsubscribes/resets them without interfering with ECS execution. |
| [#58](https://github.com/dearlordylord/bendvy/issues/58) — Export validated basic world snapshots with independent payload data | #46, #38 | An application exports basic entities, components, resources and allocator progress into an independent save value while preserving the live world. |
| [#59](https://github.com/dearlordylord/bendvy/issues/59) — Validate and atomically restore basic saved worlds | #58 | An application loads a basic save, rejects invalid input before mutation and resumes normal entity/lifecycle operations. |
| [#60](https://github.com/dearlordylord/bendvy/issues/60) — Save and restore ordered relations and committed machines | #59, #44, #49 | A complete public save restores ordered relation graphs and committed machine values with the exact runtime omissions and stream-clearing boundary. |
| [#61](https://github.com/dearlordylord/bendvy/issues/61) — Execute the complete pinned core capability matrix | #40, #41, #45, #47, #52, #53, #56, #60, #34, #35, #51, #57, #43 | An independent public consumer verifies the whole pinned core surface and reports exact remaining differences before full parity is claimed. |
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
Do not append milestones, prior checkpoints or historical summaries here.
Contracts and issue acceptance remain authoritative.

| Task | Agent / worktree / branch | Dependencies | State | Next step |
| --- | --- | --- | --- | --- |
| #41 bundles | `snapshot58_retained_codecs`; `parity-41-public-readiness`; `research/41-public-readiness` | Constructor-stage/Batch/WorldIO; unresolved #38/#46 policies | Complete registered ten-world experimental consumer passes JS and Native against the independent whole oracle; recovery corruption control also passes both backends. The previous 102 core bodies remain unchanged; six construction additions are now qualified and integrated. | Matched IO timing semantics pass full JS/Native/TS outputs and all 20 shared checkpoints, plus reached early-end refusals on both Bend backends; the portable archive verifier passes from root. The admitted 86-process IO cohort completed with full outputs: descriptive median JS/TS 3.78222, Native/TS 0.152439; all 349 retained members, 175 guards and complete outputs pass independent actual review (`53a9ce8b`). JS slowdown is confirmed in this full IO scope; extra Bend physical diagnostics/rendering remain measured. CPU/allocation diagnostic packets and independent audit pass (`5b575b5b`); whole-process startup is substantial and no dominant IO cause is established. Full prebinding consumer and four semantic-only JS/Native cohorts pass complete normal16012 and wrong-binding9660 outputs; independent actual audit verifies all366 archive members,294 source captures and34 guards. Scenario/current-core authority joins and explicit duplicate policy remain owning #41 checks. Source review corrects the count to 20 baseline bindings and 20 candidate bindings; the 40 invocations include 20 observers. This qualifies a registration recipe, with no demonstrated work reduction or performance cohort planned. Dynamic refusal paths remain per invocation. Duplicate policy, scaling and final issue acceptance stay open. |
| #49 handlers | `handlers49_finish`; `parity-49-handlers`; `parity/49-handlers-delivery` | #48/#35; approved #36 Local | Public handler bundle adopted; aligned TS/JS/Native 116 snapshots and 42 observation points verified. | Resolve #48 prerequisite and complete full-issue acceptance and feature timing. |
| #48 cleanup controls | `/root` integrator; author `debug56_feasibility`; `parity-48-api-compact` | Existing System/reader ownership | Full normal/mutant JS/Native and unchanged #28 pass independent review. [Bounded factory delivery](../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/api-compact-v1/CORE-DELIVERY.md) is recorded. | Continue typed provisioning below; resolve remaining initialization/marker adaptations and full-feature timing before #48 closure. |
| #48 typed provisioning | `debug56_feasibility`; `parity-48-typed-provision`; `implement/48-typed-provision` | Existing machine Slot/Family; unresolved initialization adaptations | Immutable source candidate integrated (`cb9aaf4d`):17 checkpoints/schema plus5 single-Flow checkpoints/schema; source checks pass. Optional conditions are separate from required accesses. All six main/mutant/Flow-only JS and Native complete-output checks pass. | Independent complete normal/mutant/Flow-only models are frozen (`4f3ab2d9`). Pure String wire correction (`2a5aa7cc`) supersedes unquoted expectations; six v1 plans remain unexecuted/unadmitted. Six wire-aware v2 plans passed independent admission (`958b80a6`); Actual evidence is integrated (`24520417`); portable archive verification passes (`f2f9b19c`):278 members and51 progressive guards. Independent actual review passes (`b1e73bb3`); queue released. Do not select duplicate initial, initial-message or changed-flag policies. |
| #42 relations | `inspector54_boxed_scan`; `parity-42-adoption-current`; `parity/42-adoption-current` | Eight adopted relation modules; root owns shared core | Direct serializer passes all nine complete JS and Native cases (`4348080a`, `dcafa6c4`); matched CPU/Heap profiles retained (`95f82290`). No fair timing claim under contention. | Both current boundary mutants pass complete JS/Native rejection gates (`984e1fa4`); finish dependent readers and delivery/performance gates. |
| #43 relation-failure readers | `snapshot58_retained_codecs`; `parity-43-readers-current`; core integration `35e60a4c` | #42/#35; root owns shared core | Eight reader modules adopted on master (`f8d7ef58`); finite JS/Native matches the full oracle. Unchanged Workshop regression passes. | Complete full-feature performance and remaining issue acceptance; installed full-capacity JS printing remains unqualified. |
| #54 Inspector | `simulation63_delivery`; `parity-54-layout-provenance`; JS profiles `decode46_public_seam`; ordinary binding `debug56_feasibility` / `parity-48-typed-provision`; review `snapshot58_retained_codecs`; root integrates | #35; unresolved foreign/held-view policy | Full two-schema chunked serializer preserves all23 grants and the complete5,077,477-byte oracle. Normal JS and reached drop/reorder assembly controls pass (`f2a555cf`, review `dd168f72`). Original85509 artifact-only Native O0 also matches the entire oracle; its192-member immutable archive and independent review are integrated (`aac9d1de`, `1575d3cc`). O3 build remains incomplete at120s. | Both complete Native assembly mutations pass original95047; all four matched JS profiles pass their whole-output gates after signed-delta admission (`1e0232fc`). Archive and independently review these actuals. Continue ordinary binding reuse in owned `experiments/public-inspect/ordinary-declaration-v1/`, based on the public seam proposal (`4b097393`). Native assembly mutation evidence is awaiting immutable archive/review; source-current reader/retention controls, stock compiler delivery, core adoption and feature performance remain open. Historical compiler/PC evidence: [diagnosis](../../experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/layout-followup-v1/DIAGNOSIS.md). |
| #55 extension study | `inspector54_finish`; `parity-42-relations`; existing isolated branch | Adopted machine/relation/Inspector; #43/#48/#50/#53 unresolved stream/ownership boundaries | Relation Check TS/JS/Native verifies declaration evaluations and diagnostics. The current source-bound contract/gap map matches all eight core modules. Detached normal JS is verified; Native C emission is incomplete. | Complete source-current reached Check controls, public bridge integration, Native qualification and broader stream coverage. |
| #56 ordinary debug | `inspector54_boxed_scan`; `parity-54-boxed-scan`; independent reviews | #55; ordinary declarations and readonly primitives | Full normal and mutation JS outputs pass. Private Held composition removes the observed arity refusal; exact full-consumer Native C builds and runs at O0 with the whole oracle. O3 build reaches the existing deadline. | O0 actual review passes; O1 also reaches the existing build deadline without runtime. Stock installed emission of changed Held source reached the 30-second cap without a C artifact; this is inconclusive, not an arity refusal or impossibility finding. Installed delivery, Native mutation and performance remain open. |
| #61 audit preparation | `debug56_feasibility`; `parity-56-query-proposal`; existing audit inventory | Pinned TS/Bevy/Bend; experimental and integrated evidence distinguished | Public-core source inventory and evidence mapping are available. They distinguish integrated capabilities, experimental candidates and missing behavior; the full executable audit remains incomplete. | Construction refresh and the 23-module capability classification are integrated (`1e2aba3f`, `a80a94bf`); see coverage.md scope reconciliation and the TS extension archive index. Execute the complete approved-capability audit after dependencies; inventory preparation does not close #61. |
| #63 fixed-step simulation | `debug56_feasibility`; independent review `snapshot58_codec_oracle`; root integrates | #35/#41; frozen ordinary tool/resource guards | Full ordinary TS/JS/Native semantics, timer sequencing and named-loop semantics pass. The named-loop 20-pair cohort has median JS/TS 3.34450 and Native/TS 0.0600142; approved sign/Holm analysis confirms JS slowdown. Independent actual sampling and profile review passes. | Current CPU/allocation profiles are retained but establish no decisive bottleneck; no material improvement from removing closures is proven. Continue parity delivery and investigate new optimization only with stronger evidence. Larger lifecycle groups and full performance acceptance remain open. |
| #46 complete decoding | `decode46_public_seam`; `parity-46-timing-alignment`; `parity/46-timing-alignment` | Canonical Codec/constructors; root owns core | Six APIs adopted; canonical92 and complete application32 JS/Native are independently qualified (`ee24e429`). Registered setup/owner alignment is source preparation (`f0d4d4a3`), not timing evidence. | Corrected logical/physical queue observer is integrated (`09e1353f`); independent full32 common/native/TS models are frozen (`a39b5a05`). Aligned32 actual common and Whole JS gates pass (`77b244aa`); both C emissions reach30s with no C. Source-derived TS wire correction preserves the failed first attempt; the complete TS successor passes (`4851367d`) and independent review (`fa2146b7`). Native completion, reached controls and equivalent feature timing/scaling remain open. See [application32 evidence](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/oracle-v1/ACTUAL-REVIEW-v1.md). Archived TS host mechanisms do not define scope. |
| #58 snapshot export | Coordinator integration `ordinary-snapshot-integration`, `integration/ordinary-snapshot`; `snapshot58_retained_codecs` evidence; `snapshot58_codec_oracle` review | #46/#38; canonical declaration/Family authority | Sixteen snapshot/declaration modules adopted on master (`f8d7ef58`); complete bounded JS/Native controls and unchanged Workshop regression pass. | Complete generic constructor dependencies, broader snapshot coverage and feature performance; #38/#59 policies remain unresolved. |
| #59 restore readiness | `simulation63_delivery`; isolated restore reference; ownership packet by `snapshot58_retained_codecs` | #58/#46 constructor/admission provider; unresolved stale-handle identity | Actual pinned TS reference covers two schemas, 40 rejection cases and complete lifecycle/allocator observations matching independent expected output. Retained output and fixture hashes are checked. Bend restore remains incomplete. | Select outstanding Bend ownership/identity policies from one source-backed packet; implement declaration-bound construction and atomic restore. TS handles constructed after restore from prior IDs exercise old-ID resolution, not a literally retained pre-restore handle. No #59 completion. |
| #64 defense preparation | `inspector54_retention_fail_skip`; `parity-64-defense-readiness`; `parity/64-defense-readiness` | #61/#63 remain open; canonical repository read-only | Canonical source requirements and authority/evidence pins are mapped to existing tickets. The separate copied integration has not started; prerequisites remain open. | Revalidate source pins and prepare the separately copied integration after prerequisites. No canonical copy, platform execution or reducer migration performed. Preparation only. |
| Shared core/integration | `/root`; `bendvy`; `master` | Reviewed commits and exact dependency joins | Coordinator is sole writer of shared core/contracts; unrelated WIP preserved. | Integrate reviewed slices; apply unchanged #28 to executable delivery. |
| #50 / #53 research | `/root`; `simulation63_delivery`; owned-event experiments | #36/#31; unresolved public ownership contracts | Canonical capability provider and full registered/System/two-schema JS/Native pass whole independent models, including reached grant-zero mutation (`1964d497`). | Complete App/access integration and trusted-provider preservation; resolve publication/retirement/capture contracts. [Current provider evidence](../../experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/) does not establish finalizers, full delivery or performance. |

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
  foreign Inspector association and held-view ownership remain approval gates.
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
| #50 | Confirm the complete [capture draft](captures-contract-draft.md): affine pack returned on run/failure; skip/refusal unchanged; sequential sharing separate from World registration/cursors; successful one-time closed finalizer, refusal returns both owners. | Actual TS capture study supports failure/skip/sharing; TS does not establish disposal. Local approval is separate. Awaiting the existing explicit reply. |
| #53 access | Choose detached Data projections or opaque scoped read-only visitor with optional detached observations; explicitly approve departure from TS shared mutable alias identity. | [Observed study and proposal](../../experiments/public-owned-events/RESEARCH.md): TS shares objects, Rust readers borrow, Bend cannot duplicate arbitrary Type. A callback merely returning its owner does not prove read-only projection; the trusted concrete provider boundary, before/after preservation controls and any separately approved preservation laws must be explicit. Opaque scoped capabilities confine gameplay but do not prove provider purity. |
| #53 ownership/release | Confirm publication transfers into one log, refusal returns unpublished owner, failed reads retain log owner/cursor; distinguish reader disposal from record removal and define projection survival after trim. | Proposed only. Preserve existing Data-event cursor/retention behavior. Internal RC release is not a public finalizer contract; no destructor callback is silently added. |

Source investigation and typed interface preparation may continue; implementation
of these ownership-visible choices waits for approval. No new laws/proofs follow
from accepting a behavior contract; specific laws need their own approval.

### Resource and handoff protocol

Four workers may implement/research/prepare concurrently. With external CPU
contention, one executable/check/backend/probe stage runs at a time; coordinator
assigns the next slot. Run an admitted stage under
`flock /tmp/bendvy-parity-heavy.lock COMMAND...` and retain normal receipts/guards.
The lock serializes our processes; it cannot remove external contention.
Comparative timing requires independent admission of its exact full-workload
plan and an exclusive cohort reservation. A coordinator-granted source diagnostic slot
may contain up to four sequential affected checks, each capped at5s. Freeze the
actual source closure, command and raw receipt for each attempt; retain failed
inputs before repairs. Release the executable lock between attempts and return
the slot within60s, on success, timeout or any contract question. This batches
routine syntax/quantity repairs without repeated admission messages or full
resolver discovery; it grants no backend, proof or delivery acceptance.
Performance/profiling gets one exclusive
coordinator slot after live host assessment, with all our other child checks
paused. Native remains one thread/GPU off. Limits stay checker5, emit30,
compile120, runtime5; timeouts are inconclusive, not grounds to raise caps.

Reference selection uses the manifest-bound check in
[check policy](../check-policy.md#preparing-a-focused-runner).

A copied worktree must hash-join owned sources and read-only dependency overlays
before resuming. Original absolute-path receipts are preserved as historical;
new execution freezes its actual worktree paths/tool/config/environment. Never
commit another worker's dependency overlay or private environment. All workers
are not alone in the repository and must preserve others' changes.

Handoff: exact commit SHA, owned file list, source/dependency joins, commands and
terminal receipts/full oracles, intended negative diagnostics, reached mutants,
and explicit remaining issue gates. Workers commit only their owned deliverable;
they do not push/close issues or merge shared core. Coordinator obtains independent
Spec/Standards review, integrates small commits and posts English issue updates.
A bounded experiment is not full issue completion. Shared module/interface requests
are agreed before editing; `src/ecs` has one writer. General regression gates run
on the combined executable result, not redundantly per planning/evidence commit.
Full equivalent JS≤TS and Native≤0.5×TS remains #21/#23/#24; the unchanged default
#28 gate remains required. No performance tolerance is added here.

## Full-scope return conditions

- Proof execution is deliberately not published as unconditional agent work: #62 drafts/falsifies exact remaining subjects and obtains specific approval; approved executable-proof/mutation and any backend-refinement slices are then published. Seven #18 subjects remain delivered; supporting candidates remain unapproved.
- #64 inventories copied Tower Defense requirements and publishes exact copy/integration tasks after its concrete capability, proof/performance and host-adapter prerequisites exist. Canonical jev stays read-only; reducer migration is a separate decision.
- #61 inventories every pinned public core export and type/error boundary. Any missed behavior must receive an owning task and be implemented before audit acceptance; the audit cannot replace missing features.
- Full equivalent-work performance and full connected qualification stay in #21/#23/#24. Neither scoped Workshop timings nor completing this feature list closes them.

## Source and test authority

[Three-reference source review](source-review.md) records bevy-ts behavior, Rust Bevy architecture and Bend ownership/runtime constraints, with exact read-only inputs. Existing independent public application traces are the highest test seam. New planning source descriptions remain unobserved until their actual TS/JS/Native controls execute.
