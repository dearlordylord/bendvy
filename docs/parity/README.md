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
| #41 bundles | `bundles41_core_seam`; `parity-41-bundles`; `parity/41-bundles-delivery` | Constructor-stage/Batch/WorldIO; unresolved #38/#46 policies | Public bundle/OwnedRequest slice adopted; core-only Spawn/Insert JS/Native qualified. | Complete remaining issue acceptance; activation ownership policy remains open. |
| #49 handlers | `handlers49_finish`; `parity-49-handlers`; `parity/49-handlers-delivery` | #48/#35; approved #36 Local | Public handler bundle adopted; aligned TS/JS/Native 116 snapshots and 42 observation points verified. | Resolve #48 prerequisite and complete full-issue acceptance and feature timing. |
| #48 cleanup controls | `handlers49_finish`; `parity-49-handlers`; `parity/49-handlers-delivery` | Existing stream semantics; later-key policy unresolved | Generic and current-World cleanup controls are verified on JS/Native. The failed-batch mutation is INCOMPLETE at the Native compile limit. Ordinary factory has two complete JS observations and reached public-kernel controls; Native and core adoption remain incomplete. | Complete factory authority/Native gates, core adoption and full-issue acceptance; preserve lazy reader activation and owners on rejection. No unchanged timeout retry, performance or unresolved policy approval. |
| #42 relations | `inspector54_boxed_scan`; `parity-42-adoption-current`; `parity/42-adoption-current` | Eight staged relation modules; coordinator owns core adoption | All eight relation modules are already adopted and match retained readiness hashes; current complete 52-checkpoint reorder normal and three mutants are qualified on JS/Native. The public-provider consumer now has two nominal schemas, actual Factory-created worlds, full physical cells including absence, and real failure rollback; the complete 40-line normal and reached absence-omission consumers now pass actual JS/Native. All 20 mutation differences, 34 guards and 68 archived members passed independent review and are integrated. | Complete fair scaling/timing and dependent failure-reader integration; these finite consuming checks do not close full #42. Population1024 JS remains inconclusive. Whole-feature qualification now retains complete TS9, JS8 and Native9 raw outputs matching all byte oracles, full trace walks and execution markers; independent retained verification passes 62 serialized guards. Population1024 passes Native but remains unexecuted on JS after its earlier deadline. Current reached-boundary mutation preparation now retains successful last-leaf JS/C and moved-walk JS emission. Moved-walk C emission hits the unchanged deadline; its partial artifact and missing named postguard are preserved as incomplete. A focused no-child failure control verifies post/final checks for future stages. Sixteen complete JS mutation executions and the Native last-leaf build pass independent review; moved-walk rejects the marker/stat gate despite unchanged stdout. Native nine-case last-leaf runtime now passes its complete counteroracles; retained verification confirms 25 reached mutation cases and 56 serialized guards across JS and Native. Native moved-walk and JS1024 remain required gaps; fair comparative timing and full-task completion are outstanding. |
| #43 relation-failure readers | `snapshot58_retained_codecs`; `parity-43-readers-current`; `parity/43-readers-current` | #42; #35; root owns shared core | Source-current combined retry/foreign/lifecycle/mixed consumer passes source5; four intended authority/ownership negatives and two mutation variants are prepared. The complete two-schema independent oracle is integrated, retaining exact queue front/back and canonical World clocks. The complete current JS output passes the strict source-bound constructor transport and unchanged whole oracle; its actual packet passed independent review. The admitted normal Native development attempt fails with compiler arity over 247 before C; the wrong-reader JS mutation executes and matches a separately source-corrected full model after a physical queue-normalization error was found in the original oracle. The premature-publication JS mutation matches its whole counterfactual and rejects the unchanged baseline. The complete actual packet passed independent review; original failures are retained and mutation Native remains unexecuted. The source-grounded Array report candidate now matches the whole JS oracle and passes installed C emission/Clang build, but Native execution fails with a memory fault and 117-byte partial output; its complete packet passed independent review. The independently reviewed bounded generated-C printer diagnostic preserves the identical 117-byte failure output and locates invalid descriptor/value traversal at deliveries; source inspection then identifies an unparenthesized hot-Array conditional base whose offset is skipped on the true branch. The minimal copied-generated-C repair now passes build/run and the complete unchanged oracle with 71,461 bytes identical to JS; its packet passed independent review. The reproducible copied-compiler patch now also generates, builds and runs complete C with the same full output; its separate packet passes independent review. Neither result qualifies the installed compiler. A source-checked List carrier successor preserves the complete two-schema report under an explicit mandatory-Some Candidate wrapper; its independent whole model is frozen before execution. Historical full-count deadlines remain unmet. | Diagnose the Array candidate runtime fault through bounded generated-C evidence, preserve full observations, and finish normal declaration integration. Activation, retention and cleanup contracts remain unchanged; full-count, delivery and performance gates remain open. |
| #54 Inspector | `inspector54_boxed_scan`; `parity-54-boxed-scan`; `parity/54-boxed-scan` | #35; unresolved foreign/held-view policy | Full recursive private carriers preserve all 23 grants and the unchanged 5,077,477-byte oracle; whole source5 passes. The independently reviewed Native emit30 attempt reaches its deadline with no C, build or runtime. Earlier Garden reference diagnostics show continued conversion/emission, not an established installed-compiler cause. | A reviewed copied-reference profile has 15,056 samples: layout equality 20.2%, GC 10.9%; signed deltas remain raw and original DiagnosticAbort/INCOMPLETE receipt is retained. A copied-compiler comparator experiment also ends in DiagnosticAbort without C; its independently reviewed sample capture establishes no speedup. Private continuation boxing and entry-only sequential output both pass source5 but hit installed emit30 deadlines without C; reviewed packets and consolidated diagnosis are retained. Wrapper/entry iterations stopped. A further compiler investigation needs source provenance; complete actual outputs, controls, public integration, delivery and performance remain open. No installed-compiler cause or performance qualification is established. |
| #55 extension study | `inspector54_finish`; `parity-42-relations`; existing isolated branch | Adopted machine/relation/Inspector; #43/#48/#50/#53 unresolved stream/ownership boundaries | Relation Check TS/JS/Native verifies declaration evaluations and diagnostics. The current source-bound contract/gap map matches all eight core modules. Detached normal JS is verified; Native C emission is incomplete. | Complete source-current reached Check controls, public bridge integration, Native qualification and broader stream coverage. |
| #56 ordinary debug | `debug56_feasibility`; `parity-56-query-proposal`; independent evidence reviewers | #55; canonical declarations and readonly primitives | The accumulated nominal App candidate matches the unchanged complete 60-phase oracle on JS and across three Native 20-phase programs; all source, launch and actual-evidence reviews pass. A reached JS description-loss mutant changes exactly 18 Without clause arrays, preserves operational observations and is rejected by the unchanged full oracle. Repeated ordinary-query dumps now match all 54 snapshots and 12 populations on actual JS and across all three Native category programs, preserving nonempty events, pending commands, owners and disabled presentation; the complete packet passed independent review. The reached disabled-execution mutant changes exactly 18 payload fields and is rejected by the unchanged full oracle; its actual JS packet is integrated. A source-checked successor derives App inventory from retained ordinary schema and system declarations, including a separate affine resource consumer. Both complete App and affine-resource successor observations now match actual JS outputs and independent frozen v2 models; all 28 retained members, 14 guards and four successful commands pass independent review. The declaration-derived graph/machine successor now passes its whole JS oracle; the reached relation-description omission mutant matches its whole countermodel and rejects baseline. The separate affine-resource successor passes complete Native execution. The combined App successor hits its unchanged 30-second C-emission deadline before any build/runtime; the actual four-cohort packet passed independent review. A source-checked handler successor now retains and executes the same actual Bundle while deriving typed selector, requirements and registry descriptions; cross-schema/machine-key selectors are refused. Its independent full normal/mutation models and source-bound typed transport are frozen; complete synthetic reports and corruption controls pass. Both actual JS executions now match the complete independent models and pre-run synthetic bytes; independent review confirms 28 retained members, 14 guards and a reached mutation changing only two Enabled handler-entry arrays while preserving all World and owner observations. The complete handler Native attempt reaches the unchanged C-emission deadline before producing C, build or runtime; the incomplete receipt and raw outputs are retained, and compiler-cost investigation is next. State universes and transition graphs are not enumerable from current Family metadata. Earlier failures remain archived. | Qualify the complete ordinary App inventory successor on Native and finish declaration-derived graph/machine coverage, public integration, delivery and performance. Separate Native programs do not establish combined Native execution; experimental evidence does not close #56. |
| #61 audit preparation | `snapshot58_retained_codecs`; `audit61-current-evidence`; `audit61-current-evidence` | Pinned TS/Bevy/Bend; experimental and integrated evidence distinguished | Public-core source inventory and evidence mapping are available. They distinguish integrated capabilities, experimental candidates and missing behavior; the full executable audit remains incomplete. | Reconcile current experimental #53/#56 evidence and exact remaining gates; execute the full audit after dependencies. Preparation does not close #61. |
| #63 fixed-step simulation | Coordinator; installed config `simulation63_delivery` handoff | #35/#41; approved public ECS/streams; closed tool resolver boundary | Complete simulation development observations, semantic controls and relocation checks are available. Installed environment and reached-input configuration are prepared; closed tool qualification remains incomplete. | Complete source-current frozen delivery and unchanged performance gates. Prepared configuration is not closed compiler/runtime input qualification; default full discovery remains. |
| #46 complete decoding | `simulation63_delivery`; `parity-46-adoption-current`; `parity/46-adoption-current` | Existing Codec/Raw and affine receipt; no new conversion policy | Complete experimental decoding matches the full eight-case output on JS/Native; a reached budget mutant and owner refusal are verified. Ordinary constructed admission now has a source-passing 32-trace/two-schema consumer and an independent complete oracle. Foreign operation refusal restores the original 65-field input and sentinel after canonical validation. The complete extended JS consumer and both reached validation/write mutants now match their whole source-current models; mutants reject the unchanged baseline. Their independently reviewed raw evidence is integrated. Native C emission refuses continuation arity over 247 before C; Native mutation execution remains unqualified. Independently reviewed copied-reference metadata retains 16 distinct oversized continuations repeated five times, with no offending encoded nodes. It identifies accumulated 61-word observations as a representation candidate, without attributing installed-compiler internals or performance. A source-checked list-spine successor preserves all operations and fields; its independently frozen complete Candidate oracle requires every Some wrapper and exact unchanged semantic contents. The complete successor now passes JS and Native with byte-identical 747,754-byte reports; both packets pass independent review, and installed C emission no longer hits the prior arity refusal. This qualifies the experimental successor, not full public adoption or performance. Extended ordinary resource selectors, literal/handle boundaries and two source-passing mutation consumers now have independent complete normal/counterfactual models; root recomputation passes all three. The actual pinned TS reference now matches its independent complete v2 model for all 32 operations, selectors and genuine foreign-world control; the raw 68,920-byte output and 48 archived source aliases pass independent review and retained verification. TS numeric foreign-handle behavior remains an explicit reference difference, not a replacement for Bend MissingEntity semantics. | Complete ordinary descriptor adoption, full authority/delivery and equivalent-work performance gates. Automatic budget reasoning is not a universal proof. |
| #58 snapshot export | Coordinator integration `ordinary-snapshot-integration`, `integration/ordinary-snapshot`; `snapshot58_retained_codecs` evidence; `snapshot58_codec_oracle` review | #46/#38; canonical declaration/Family authority | Sixteen proposed src modules are staged on the integration branch with authority controls. Complete actual-src snapshot, Family and reached-mutation outputs match on JS/Native. Master contains experimental evidence, not the proposed src modules. | Finish source-current refusal/frozen delivery and unchanged regression before merging core branch. Master contains experimental evidence, not these src modules. Exact-current snapshot source5 retry passes in 2.704 seconds with unchanged source hashes; prior timeout remains retained; generic constructors and full acceptance remain open. |
| #59 restore readiness | `simulation63_delivery`; isolated restore reference; ownership packet by `snapshot58_retained_codecs` | #58/#46 constructor/admission provider; unresolved stale-handle identity | Actual pinned TS reference covers two schemas, 40 rejection cases and complete lifecycle/allocator observations matching independent expected output. Retained output and fixture hashes are checked. Bend restore remains incomplete. | Select outstanding Bend ownership/identity policies from one source-backed packet; implement declaration-bound construction and atomic restore. TS handles constructed after restore from prior IDs exercise old-ID resolution, not a literally retained pre-restore handle. No #59 completion. |
| #64 defense preparation | `inspector54_retention_fail_skip`; `parity-64-defense-readiness`; `parity/64-defense-readiness` | #61/#63 remain open; canonical repository read-only | Canonical source requirements and authority/evidence pins are mapped to existing tickets. The separate copied integration has not started; prerequisites remain open. | Revalidate source pins and prepare the separately copied integration after prerequisites. No canonical copy, platform execution or reducer migration performed. Preparation only. |
| Shared core/integration | `/root`; `bendvy`; `master` | Reviewed commits and exact dependency joins | Coordinator is sole writer of shared core/contracts; unrelated WIP preserved. | Integrate reviewed slices; apply unchanged #28 to executable delivery. |
| #50 / #53 research | `/root`; `simulation63_delivery`; isolated owned-event experiments | #50:#36; #53:#31; unresolved public ownership contracts | Recovery is a soft preference subordinate to API simplicity. Registered readers match all 24 snapshots and the exact 35,254-byte oracle on JS/Native. A reached retirement-loss mutant is detected against the unchanged whole oracle; actual reader-entry controls reject duplication, write access, handle escape and cross-schema misuse. WorldMeta omits live/store/pending. | Generic scoped transport now passes complete JS/Native observations with affine requests/arguments and Bool/String projections; independent actual review passes. Ordinary typed-grant assembly and five intended source refusals pass review. All four generic/registered JS/Native cohorts match complete independent oracles and are integrated as experimental evidence. The persistent ordinary System-owner consumer also matches its full 24-state oracle on JS/Native. A fixture-independent generic sibling now supports affine store, resources, arguments and outputs; both complete independent oracles now match actual JS/Native results across all four cohorts, with independently reviewed current input and output bindings. Finish App integration while preserving typed registration refusal separately from unselected schedule error policy. Declared-access enforcement, trusted provider preservation, public ownership/retirement boundaries, integration, delivery and performance remain open. No closure, finalizer policy or general memory claim. |

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
