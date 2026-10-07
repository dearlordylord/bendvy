# Remaining full-core parity — published execution map

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

## Immediate frontier

#38, #41, #42, #46, #48, #50 and #53. #34, #35, #39, #40 and #47 are closed; their dependencies permit #40/#48 and the reader side of #43, whose #42 prerequisite remains open. #45 has actual TS preparation while #44 remains prerequisite. Explicit unresolved identity/capture/affine-event contract choices must still be resolved before implementation; there is no blanket approval of divergence.

## Parallel delivery coordination — 2026-10-07

This is the execution checkpoint for the existing #37 specification and issues,
not a second parity plan. Issue acceptance and approved contracts remain
unchanged. Coordination base: `14494e25`. Each worker owns one branch/worktree;
only the coordinator edits this table and shared contracts or integrates
`src/ecs`, common runners, laws, specifications and issue status.

Worktree prefix: `/workspace/formal-proofs/bendvy-worktrees/`.

| Task | Agent / worktree / branch | Dependencies | State | Next step |
| --- | --- | --- | --- | --- |
| #41 bundles | `bundles41_core_seam`; `parity-41-bundles`; `parity/41-bundles-delivery` | Constructor-stage/Batch/WorldIO; unresolved #38/#46 policies | Full20 public surface TS/JS/Native and ownership controls delivered; source integration map `51f83141`. [Evidence](../../experiments/public-bundles/owned-public-result-v1/bounded-README.md). | Implement agreed core seams; resolve activation policy before adoption; combined regression. |
| #49 handlers | `handlers49_finish`; `parity-49-handlers`; `parity/49-handlers-delivery` | #48/#35; approved #36 Local | Full96/12 baseline JS/Native, foreign-world controls and four static refusals delivered. Three reached JS mutations integrated `a8719d73`. [Evidence](../../experiments/public-machine-handlers/candidate-v1/delivery-mutants-v1/REPORT.md). | Final resolver qualification, Native mutation coverage and production adoption. Existing runner-lint repair integrated `b9b7e2f7`. |
| #42 relations | `inspector54_finish`; `parity-42-relations`; `parity/42-relations-delivery` | Eight staged relation modules; coordinator owns core adoption | Runtime-input full30 traces at64/256 entities pass JS and Native; Native evidence integrated `de91f711`. [Evidence](../../experiments/public-relations/timing/current-qualification-v1/phase2/remainder-v1/native-evidence-v1/index.json). | Nonpower/sparse/empty full TS and standalone JS controls pass; handoff in preparation. CLI5 timeout retained. Next:1024/fanout/depth, forcing, fair timing and adoption. |
| #54 Inspector | `inspector54_retention_fail_skip`; `parity-54-inspector`; `parity/54-inspector-delivery` | #35; prior retention capsules; unresolved foreign/held-view policy | Full74/84 query/Check observations pass JS/Native; six static refusals and reached JS reader mutation retained. [Evidence](../../experiments/public-inspect/promotion-stage/QUALIFIED-SLICE.md). | Reviewed exact92-file package integrated `8103b56e`; configured hooks and portable integrity checks pass. Next: remaining policy/core gates. |
| #61 audit preparation | `audit61_inventory`; `parity-61-audit`; `parity/61-core-audit-preparation` | Pinned TS/Bevy/Bend; experimental and integrated evidence distinguished | Complete source inventory integrated `85f2aeb1`:688 exports,477 targets,4999 classified calls. [Inventory](../reference/core-export-inventory.json). | Assign remaining helper/internal-command ownership; execute full audit after dependencies. Preparation does not close #61. |
| Shared core/integration | `/root`; `bendvy`; `master` | Reviewed commits and exact dependency joins | Single writer for `src/ecs` and contracts; unrelated root WIP preserved | Integrate small reviewed deliveries; targeted checks; unchanged #28 on combined executable result. |
| #50 / #53 research | `/root`; main worktree | #50:#36; #53:#31; ownership approval | Source studies delivered; existing approval packet pending | No dependent implementation before contract selection; keep questions in one packet. |

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
  `docs/reference/core-export-inventory.json`. Preserve historical inventory and
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
The lock serializes our processes; it cannot remove external contention. No
comparative timing is admitted yet. A coordinator-granted source diagnostic slot
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

Delivered reference selection uses the manifest-bound check in
[check policy](../check-policy.md#preparing-a-focused-runner). The #49 retry
initially selected an old failed adapter despite a delivered corrected comparator;
`e420cb00` adds a tested deterministic guard rather than repeating those fixes.

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

## Implementation checkpoint — 2026-10-07

| Issue | Current evidence | Remaining delivery boundary |
| --- | --- | --- |
| #34 | Delivered bounded nested provisioning: current 33-core provisioning/flat replays pass 31/42 guarded commands, complete refusal/access/owner controls and reached mutants. Corrected actual-command common work retains full TS/JS/Native observations and 120 timing pairs. | Independent final reviews pass; metadata laws remain unapproved. Modest JS overhead is recorded, and full-product qualification remains #21/#23/#24. See [completion](../reports/nested-provision-completion.md). |
| #35 | Delivered bounded reader slice: fresh post-batch 99-command replay, 28 backend cases, latest exact 38-module inventory, four negatives and seven reached mutants; independent final review and current #28 pass. Earlier complete feature observations retain 120 pairs. See [completion](../reports/schedule-readers-completion.md). | Heavy reader workload remains JS 3.8–4.1× TS and Native 1.1–2.0× TS; this remains a product qualification obligation in #21/#23/#24. Exact laws unapproved; no full-product qualification. |
| #38 | Canonical IO creator delivered at `f98c0645`: direct live-core controls pass 47 guarded commands, four exact negatives and collision/range mutants; independent review and unchanged #28 pass. | Full reservation/capacity/clock gates and failed-ID policies remain open. Trusted raw/legacy helpers and separate-program authority remain explicit limits. See [partial report](../../experiments/public-identity/production-candidate/promotion/LIVE-REPORT.md). |
| #39 | Delivered executable fragment slice: two-schema public applications, collision/refusal/barrier controls, four reached mutants and independent replay. | Final reviews, unchanged regression and complete timing/scaling retained; JS initialization is slower than TS, Native faster. Full-product qualification remains #21/#23/#24. See [completion](../reports/schema-fragments-completion.md). |
| #41 | Initial FIFO/pending delivery `04d446e4`; current 38-row application and nine reached mutants on both backends are reconciled across the preserved interrupted cohort and remaining-only PASS (27 commands, 87 pins, 54 logs). Thirteen exact negatives and arbitrary affine owners remain covered. | Current public Batch invalid-constructor spawn/insert and returned-owner retry now pass the separately reviewed 15-command cohort: eight actual TS applications and 14 full rows each in interpreter/JS/Native; all 57 pins and 30 logs reconciled. See [finite result](../../experiments/public-bundles/production-candidate/transactions/invalid-constructor-v1/RESULT.md). Production integration, equivalent feature timing, failed-activation policy and unchanged regression remain open; no issue completion. |
| #42 | Query/lifetime delivery `1cd27cfb`; registered 30-record rollback/spawn application `e37ab309` passes 47 commands. Real paired-world foreign application `929d5462` passes 29 commands, 464 pins and 58 logs, with two reached mutants on both backends. Actual TS ID aliasing is distinguished from approved Bend MissingEntity/unchanged-queue behavior. | Post-PR66 actual public working-tree replay passes 47/29 commands, 475 source pins per cohort and 94/58 raw logs. Complete relation timing correctness passes 25 commands; CPU/allocation profiles validate every full record and identify observation/graph continuations. Capture transport diagnostics are delivered in `5cc486e0`: complete baseline/candidate observations pass, sampled JS allocation falls 8.1% and TS 55.2%; this is harness attribution, not ECS speed qualification. [Exact source reuse joins](../../experiments/public-relations/promotion-stage/SOURCE-REUSE.md) preserve unchanged finite query/cleanup mutant coverage while identifying changed World registration matching. [Focused current normal controls](../../experiments/public-relations/promotion-stage/current-normal-controls-REPORT.md) now pass complete JS/Native lifetime (66 shapes and retained snapshots), cleanup (36 checkpoints including 219-transition completion) and the separate 131,072-node carrier: 18 subjects and 100 owned probes, with no historical mutant replay. The historical V4 overall FAIL is unchanged. Additive core delivery, demonstrated consequential optimization, fresh comparative timing and unchanged regression remain mandatory. Historical feature timings do not qualify the changed runner; strict source review also finds unequal timed observer/serialization work (Bend-only physical diagnostics versus TS public DTOs), so those ratios are diagnostic rather than fair ECS qualification. A matched-work fixture and actual population/fanout/depth scaling remain necessary. Finite traces do not establish universal progress or approved laws. |
| #43 | Actual TS observations cover independent failure readers, failed-reader retry, activated condition skip and never-activated skip/first activation (`77268a03`). | Bounded keyed-reader evidence is delivered in `58cde0e1`: independently reviewed frozen JS/Native complete finite consumers, actual TS shared-output comparison, five precise refusals and three reached mutations (35 commands). This finite candidate uses per-command stream ticks and leaves World clocks at zero; same-barrier retention and mixed-domain clocks are not qualified. Wider actual TS default-capacity observations now cover 65,537 same-tick failures, next-frame trimming to 65,536, independent keys and activated/never-activated skips. Wider Bend lossless development evidence is delivered in `89c50f00`: complete 65,537/65,536 observations, actual failure tick 5 and World clock 8, with exact source/raw hashes and seven decoded-observer controls. Complete JSON export remains UNMET; these controls are not compiling runtime mutations. The [scheduled lifecycle capsule](../../experiments/public-relation-readers/keyed-candidate/wider/portable-lifecycle-v12-001/REPORT.md) adds complete two-schema JS/Native false-condition skip and successful disposal observations through actual registrations, with seven subjects and 75 retained tool probes. [Mixed registered controls](../../experiments/public-relation-readers/keyed-candidate/wider/evidence/mixed-v16-001/REPORT.md) now pass 14 actual subjects: complete TS/Bend public comparison, real Native and three compiling clock/cursor/FIFO defects checked against full independent variant oracles in both schemas. Repeated component reads retain payloads while added/changed become false. World/component, relation, event and removal clock domains are explicitly mapped; raw TS/Bend clock numbers are not equated. All 140 execution and five preparation probes are retained. This is archive-only development delivery; live fixture/runtime adoption awaits #42. Full-count Native, rejected disposal, production and performance remain open; none of these bounded receipts completes this issue. |
| #44 | Actual public TS hierarchy reference delivered in `c4e141d1`: 46 checkpoints across two schemas cover depth/breadth/ancestor/root/query-match order, six refused mutations, subtree/root and repeated deletion, and ordinary-link detachment. See [reference result](../../experiments/public-hierarchy/RESULT.md). | The [finite Bend capsule](../../experiments/public-hierarchy/bend-candidate/controls-v1/portable-controls-v1/REPORT.md) retains complete 46-checkpoint JS/Native observations, actual paired-Factory foreign controls, four exact negatives and three complete compiling mutants on both backends. Focused cycle baseline/mutant observations also pass JS/Native. The historical child-set checker deadline remains inconclusive, but a guarded identical five-second reproduction now passes. [Focused current child-set controls](../../experiments/public-hierarchy/bend-candidate/controls-v1/set-checker-fix-v1/REPORT.md) retain complete six-record/two-schema JS/Native baseline and compiling refusal-mutation observations with 70 owned probes. Baseline adapter INCOMPLETE metadata is preserved and its successful whole output is separately reconciled; no source-shape fix or raised cap is inferred. Historical broad-cohort per-probe completeness, production, equivalent timing and unchanged regression remain open; #42 remains a prerequisite and this capsule does not close #44. |
| #46 | Staged decoder/host cohort passes 77 guarded commands; generic public capability cohort passes 19 commands, 26 complete records per backend, exact declaration mutant and four intended negatives. | Pending insertion, constructor integration and persistence boundaries (#58/#59), promotion and feature timing remain open. Host Promise observations do not claim Native Promise execution. |
| #47 | Delivered and closed: actual-live 87 commands, eight intended negatives, five reached mutants on both backends, complete TS observations/timing/profiles and independent final audit. Exact qualified equality/lazy World adopted in `26316f52`. See [completion](../reports/component-state-completion.md). | Full-feature JS remains 2.72–2.89× TS; Native is 13.38–19.59× faster on the state workload. Numeric product qualification stays open in #21/#23/#24. Laws remain unapproved. |
| #40 | Delivered and closed at `84f2187f`: public Feature/FeatureProvision, live 61-command cohort, full 16-case applications, six negatives/four reached mutants, complete repeated 20/200 correctness and timing, final independent audit. See [completion](../reports/features-completion.md). | Whole-process timings include startup and extra Bend observers; count sensitivity limits throughput interpretation. Full numeric qualification stays open in #21/#23/#24; laws remain unapproved. |
| #48 | Initial registered application `5d76f606` passes 67 commands: complete 24 checkpoints in each of two schemas on both backends, eight reached mutants and twelve exact negatives. Current actual TS followups observe never-activated skip, independent runtimes and 65537-event overflow/retry. See [initial report](../reports/machines-application-initial.md). | Isolated FIFO/cached-count transition-stream evidence is delivered in `d4215ced`: full JS 65,537-publication/default-65,536 capacity observations pass in both schemas, with all retry payloads and owners independently revalidated from the complete 19.37 MB output. Tail-loop formatting fixes the observer stack failure without omitting data. Matched-scope JS allocation profiles are delivered in `cacad739`: sampled allocation head self-size falls from 4,768,816,368 to 119,366,440 bytes at the same 9,848-publication prefix; this is instrumented allocation evidence, not throughput or RSS. Linear full-output JS/Native evidence and five exact full-workload JS mutations are delivered in `4d3cb9c2`: five complete 14-row variant oracles, four intended access/ownership refusals and all 210 owned child receipts pass. Both advertised validators pass in a relocated checkout containing only tracked and selected files. Native mutations, broader cleanup/general API, production and feature timing remain incomplete. Later-key pending deletion conflicts with blanket next-marker wording and requires an explicit choice; staged comparison grants no policy approval. |
| #49 | Actual TS handler reference delivered in `7d1395f1`: 12 applications, 96 complete checkpoints and 12 requirement refusals cover six failure positions in exit/transition/enter, reader redelivery and later markers. | Two labeled sets of fresh TS schemas are tested; nominal API checks remain open. Failed enter handlers are not automatically retried after state commit. Host closure counters are explicitly distinct from Local. Actual Bend handlers, affinity/negative/mutation controls, #48 prerequisite, production and performance remain open. See [result](../../experiments/public-machine-handlers/RESULT.md). |
| #50 | Actual TS capture reference delivered in `88664dce`: 16 full observations across two nominal roots, two separately authored callbacks with two captured Arrays each and two runtimes. | Failure preserves host captures while ECS Ledger writes roll back; the same callback shares host captures across runtimes. These are TS host observations, not a Bend owner contract. Capture failure/skip/disposal and cross-runtime policy approval, actual affine execution/refusals/disposal, mutations, production and performance remain open. See [reference](../../experiments/public-captures/README.md). |
| #53 | [Actual owned-object TS study](../../experiments/public-owned-events/RESEARCH.md): 28 complete observations across two nominal roots establish shared publisher/reader object and nested Array identities, post-publication mutation, independent readers/runtime, repeat/failure/retry/condition skip and default frame trimming. One Node preflight passes the full authored output. | No owned Bend event policy is selected. Safe affine publication/projection/failure/disposal decisions, actual Type execution/authority/ownership controls, Native, production and equivalent performance remain. The frozen `erased-cross-schema` label actually tests an undeclared descriptor; it establishes neither a foreign-schema operation nor a TS compiler negative. No public reader/payload disposal or GC timing is inferred from absent named methods. |
| #54 | Actual TS Inspector reference and retry observations remain delivered; joint query/resource/event/removal TS/JS observations are retained in `e48569e7`. | Typed experimental API and complete live import closure are delivered in `f2150cf1`: both nominal Bend schemas pass full eight-checkpoint JS/Native oracles for lookup, actual queued despawn, independent removed/despawn streams, failure/retry and two unchanged retaining System cursors. Four intended negatives and 60 owned tool probes are retained. TS setup adds activation ticks; absolute clocks are not equated. See [result](../../experiments/public-inspect/bend-candidate/full-v2/REPORT.md). Optional-resource/check-condition API and finite controls are delivered in `e3912af4`: 24 complete absent/present observations agree with independently authored TS/JS/Native outputs, seven intended static refusals are reconciled and all 40 tool probes are retained. One compiling failure-cursor consumption defect produces six exact deviations on JS/Native while all other fields agree. Both portable evidence verifiers pass. Focused actual System advancement/disposal now passes the same full 12-line oracle in interpreted Bend, JS and Native: genuine registered owners advance only the removal cursor, then actual disposal permits independent despawn collection. The [retention result](../../experiments/public-inspect/bend-candidate/full-v2/RETENTION-CONTROL-REPORT.md) retains 40 owned probes with only five emitted-backend subject commands. The [failed/skipped retainer controls](../../experiments/public-inspect/bend-candidate/full-v2/RETENTION-FAIL-SKIP-REPORT.md) add the full 20-line JS/Native oracle: genuine failed System execution and false Schedule condition preserve both owners/cursors/logs until real success/disposal, with 40 owned probes. Stale inherited receipt labels are explicitly qualified by the actual command ledger; no new interpreted run is claimed. Full API and policy gates, production and performance remain open. See [resource result](../../experiments/public-inspect/bend-candidate/full-v2/RESOURCE-REPORT.md). |

CPU contention defers comparative measurements. These are local integration
checkpoints, not issue completion or full-parity acceptance. The unattended
95%-confidence instruction does not approve new laws, dependencies or divergence.

## Full-scope return conditions

- Proof execution is deliberately not published as unconditional agent work: #62 drafts/falsifies exact remaining subjects and obtains specific approval; approved executable-proof/mutation and any backend-refinement slices are then published. Seven #18 subjects remain delivered; supporting candidates remain unapproved.
- #64 inventories copied Tower Defense requirements and publishes exact copy/integration tasks after its concrete capability, proof/performance and host-adapter prerequisites exist. Canonical jev stays read-only; reducer migration is a separate decision.
- #61 inventories every pinned public core export and type/error boundary. Any missed behavior must receive an owning task and be implemented before audit acceptance; the audit cannot replace missing features.
- Full equivalent-work performance and full connected qualification stay in #21/#23/#24. Neither scoped Workshop timings nor completing this feature list closes them.

## Source and test authority

[Three-reference source review](source-review.md) records bevy-ts behavior, Rust Bevy architecture and Bend ownership/runtime constraints, with exact read-only inputs. Existing independent public application traces are the highest test seam. New planning source descriptions remain unobserved until their actual TS/JS/Native controls execute.
