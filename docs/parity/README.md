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

#53 owned Type events is integrated at `32539b721` and closed after independent
final review and CI38883496921 PASS. #38 identity is integrated and closed after
CI38985163067 PASS. Remaining semantic work includes #54 Inspector compiler
selection, #57 execution subscriptions and #59/#60 restore. #57 post-run delivery
is selected. #61
full-core qualification, #62 laws and #64 copied-defense integration retain their
existing prerequisites. Combined performance stays under #21/#23/#24; Rust Bevy
semantics and approved Bend contracts remain authoritative.

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
| #38 identity and pending commands | Integrated by root; source `identity38_gate_audit`, final review `debug56_reader_product_oracle`; worktrees preserved | Approved IO creation, full U32 wrap and foreign refusal | Full-key migration and complete ordinary, scope, wrap, paused cleanup, foreign, capacity/growth and reached-defect pairs pass; current AppA/AppB/snapshot retain complete observations. Combined #28 and four profiles pass their scoped checks. | Closed after `6ad552b14` + frozen-whitespace fix `fe9a8f3c2`, independent final review, CI38985163067 PASS and English report. Full-feature performance remains #21/#23/#24; restore stays #59/#60. |
| #41 bundles | Root; audit `debug56_reader_product_oracle`, final review `scopes45_source_control` | Integrated typed constructors, Batch and WorldIO | [Joined semantic acceptance](bundles.md#semantic-acceptance-reconciliation) passes: heterogeneous families, ordinary duplicate preflight, constructor errors/retry, rollback/cleanup, actual foreign worlds and TS comparisons. Qualified core unchanged; dependency applicability reviewed. | Closed after `76c1735b8`, CI38829653048 and English completion report. Comparative timing belongs to #21/#23/#24; separate identity policies remain #38. |
| #49 handlers | `missing_resource_direct_consumer` / `handlers49-component-write-current` (`parity49/component-write-current`); root integrates | #48/#35; approved #36 Local | [Semantic reconciliation](handlers.md#semantic-acceptance-reconciliation) passes: current-source component-write JS/Native, exact applicability joins for all six historical positions, named phase mutants, requirements, actual TS and authority controls. Independent final review passes. | Closed after integration `b78be08c4`, independent review and CI pass; combined performance remains under #21/#23/#24. |
| #45 lifetime scopes | Source `scopes45_source_control`; oracle `debug56_reader_product_oracle`; root integrates | Integrated #44 subset; existing ownership contracts | [Joined semantic acceptance](scopes.md#semantic-acceptance-reconciliation) and [independent review](../../experiments/public-scopes/source-survivor-control-v1/delivery-v1/FINAL-REVIEW.md) pass. Ordinary lifecycle, actual TS reference, authority and affine checks join the new compiling survivor-deletion control on JS/Native. | Closed after `05dd2b753`, independent review and CI 38828003993 PASS. Comparative timing belongs to #21/#23/#24. |
| #44 public hierarchy traversal | Root; independent audit `debug56_reader_product_oracle`, final review `scopes45_source_control` | Integrated #42 relation providers | [Joined semantic acceptance](hierarchy.md#semantic-acceptance-reconciliation) passes: ordinary traversal/reorder/cleanup, two-schema authority, actual TS and compiling cycle/order/cleanup controls. Existing evidence and current source joins independently reviewed. | Closed after `a8090c7e8`, independent review and CI 38829031368 PASS. Comparative timing belongs to #21/#23/#24. |
| #48 machines | Root integrator; source `missing_resource_direct_consumer`, oracle `debug56_reader_product_oracle`, review `pr72_spec_review` | Existing System/reader ownership; ordinary initialization | [Semantic reconciliation](machines.md#issue-level-semantic-reconciliation) passes: current initialization/conditions, marker retention, failed-writer rollback, canonical capacity, actual TS reference and ordinary reader lifecycle. Seven-role reader packet includes cold first-use skip; JS/Native and independent final review pass. | Closed after integration `4b2d1bc1b`, independent review and CI pass; combined performance remains under #21/#23/#24. |
| #42 relations | Root; source `missing_resource_direct_consumer`, oracle `pr72_spec_review`, review `protected28_pending_reachability` | Existing relation operations; approved #38 WorldIO | [Semantic acceptance](relations.md#semantic-acceptance-reconciliation): all three current-source scenarios pass JS/Native; reached clear-omitted mutant rejects normal output. Independent final Spec/Standards PASS, prior authority/capacity/TS evidence reconciled. | Semantic acceptance complete under the approved amendment; final combined #21/#23/#24 qualification remains separate. |
| #43 relation-failure readers | Root integrates; `event_schedule_independent_oracle` / `parity43-ordinary-full-lifecycle-sparse`; helpers own oracle/evidence | Integrated ordinary shared-runtime provider | [Matched consumer/evidence](../../experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/ordinary-scheduled-matched-delivery-v1/README.md): TS and JS/Native pass; independent Spec/Standards PASS. Prior lifecycle, authority and mutant evidence retained. | Semantic acceptance complete under the approved performance-scheduling amendment; consolidated #21/#23/#24 qualification remains separate. |
| #54 Inspector | `audit61_current_inventory` / `/tmp/bendvy-inspector54-current`; independent oracle `trace57_final_review`; root integrates | Current public declarations; all23 operations/two schemas; installed compiler unchanged | Stock JS and the reviewed project-local layout-key compiler candidate pass the full6,731,751-byte independent oracle. Candidate emit30, Clang-O3 build120 and runtime5 all pass; generated C equals the uncached diagnostic. Five current authority refusals and helper compatibility are checked. Stock Native still hits emit30. | Closed after master81316652e, actual hooks, CI39010187646 and English acceptance report. Both regression cohorts and independent review pass. Stock Native remains unqualified; Inspector selects the project-local wrapper. |
| #55 extended Inspector | Root; source `debug56_reader_product_oracle`, independent review `scopes45_source_control` | Integrated Inspector/stream grants; #48 machine initialization | [Semantic acceptance](inspect-extended.md#semantic-acceptance-reconciliation) passes all three criteria: full current-source JS/Native 271,299-byte physical report and retained category/authority/mutation evidence. Portable packet and independent final review pass. | Closed after `3a0d0e26d`, independent final review and CI38834835781 PASS. Separate #54 full23 Native gate and combined #21/#23/#24 performance remain open. |
| #56 ordinary debug | Root; prior `debug56-resource-observation-once-stage` delivered; helper now supports #43 | Integrated automatic reader-product metadata | [Semantic evidence and scope](debug.md): current opaque and two-schema public dumps integrated; independent final reviews and CI pass. Constructor reduction `ade1b45aa` and [retained profiles](../../experiments/public-schedules/named-app-v1/debug-overhead-v1/resource-observation-delivery-v1/FINAL-REVIEW.md) pass full TS/JS/Native N1/N4 and independent final review; observation sampled allocation falls 27.52 → 4.69 MB. | Semantic acceptance complete after independent current-source audit and the approved amendment; global #21/#23/#24 qualification remains separate. |
| #71 distinct typed Data events | `debug56_reader_product_oracle` / `typed71-current-acceptance` (`parity71/current-acceptance`); review `scopes45_source_control`; root integrates | Existing #31/#35 reader contracts; approved R7; #56 inventory | [Semantic reconciliation](typed-data-events.md#current-semantic-acceptance--2026-10-15) and independent review pass: ordinary typed families, independent readers, rollback/retention, unused inventory, full capacity and authority controls. Current-source joins reuse qualified JS/Native/TS evidence. | Closed after `4ffa0a9a5`, independent review and CI38842756621 PASS. Historical performance failures remain explicit; combined #21/#23/#24 qualification stays open. |
| #57 debug trace | `audit61_current_inventory` / `/tmp/bendvy-trace57-controls`; root integrates in `/tmp/bendvy-trace57-integration`; helpers own models/evidence | Approved copied post-run delivery; integrated #38 full keys | Public one-engine `a08909ceb` and portable consumer `a913b7242` pass full Workshop/Garden160,344/160,342-byte stock JS/Native-O3 oracles; both fourteen-checkpoint scenarios remain complete. Experimental attempts remain scoped history. | Integrated candidate passes complete query-reader Workshop/Garden JS/Native and affected basic-restore JS/Native. Qualified selector, reader and initial-marker evidence has exact source applicability. Authority and reached mutants pass both backends; timing/profile packet is sealed. Combined default #28 passes both backends. Regression archive and independent final review pass. Delivered e9096051b with actual master hooks and CI39003777004 PASS; #57 closed. |
| #61 audit preparation | `debug56_reader_product_oracle` / current-audit sparse worktree; source helper `audit61_current_inventory`; root integrates | Existing #52/#56 contracts; declaration-derived metadata, no caller adapters | [Counted census](coverage.md#counted-core-census--source-88dcbb68e-2026-10-16) independently reviewed: 687 library export keys, 67 bound keys and all 35 source-test/static files routed to evidence or existing owners. AppA handoff integrated at `637e87135`, CI38888837157 PASS. [Recovery App review](../../experiments/public-recovery/automatic-app-v1/FINAL-REVIEW.md) accepts ordinary automatic metadata, preserved prior owners, full normal/legacy-compatibility/metadata-mutation/opaque-rejection stock pairs and affected authority controls. | #54/#60 delivered at81316652e with CI39010187646 PASS. Current-carrier AppA/AppB pass complete stock JS/Native oracles (48,145/14,577 bytes), both portable packets and independent final review. Exact census/current matrix reconciled. Closed after74a44d552, actual hooks/push, CI39011485053 PASS and English report. #62 and final numeric qualification are separate. |
| #61 ordinary composition | Root; source/oracle `audit61_current_inventory`, final review `resource_field_observer`; worktrees preserved | Existing public AppA/AppB and current World/commands pending metadata | [Current applications](../../experiments/public-audit61/pending-metadata-current-v1/runtime-v1/README.md): unchanged entrypoints pass complete47,464/13,475-byte stock JS/Native oracles. Exact physical pending planes and root-derived QNames preserved; other134/72 imports unchanged. | Independent final review and unchanged combined #28 PASS; integrated `f1fac4e90`, CI38929736000 PASS. #61 criteria1–3 retain finite scope; #38/#54/#57/#59/#60/#61 are closed; exact law proposals and full numeric qualification remain separate. |
| #61 resource-field recovery composition | Root; implementation/oracle/review worktrees preserved | Existing #52 operations and canonical resource-field bindings | [Final review](../../experiments/public-recovery/resource-field-v1/FINAL-REVIEW.md) PASS; integrated `88dcbb68e`, CI38890020198 PASS. Complete 10,339-byte normal/9,763-byte reached-loss pairs, two positive/eight intended authority controls qualify actual returned-owner retry and sibling preservation. | Product-field gap resolved; source/artifact #28 applicability reused. Recovery App/debug composition is accepted above; #61 is closed; final product qualification stays open. |
| #70 resource confinement | Root | #61; existing Product/schema; #38/#52 separate | Current evidence and remaining gates: [preserved status](checkpoint-history.md#coordination-before-version-11-2026-10-12) | No remaining #70 finite gate |
| #63 fixed-step simulation | Source `debug56_reader_product_oracle` / `simulation63-complete-observer`; oracle/review `scopes45_source_control`; root integrates | #35/#41; unchanged core and ordinary fourteen-phase workload | Full observer successor passes stock JS/Native: 97,054 bytes including lifecycle and registration state. A compiling persisted-stamp omission matches its 96,998-byte countermodel and rejects normal. Legacy hit/death/TS applicability reviewed. | Closed after integration `687abb043`, independent final review and CI38839033849 PASS. No private component optimization adopted; comparative qualification remains #21/#23/#24. |
| #46 complete decoding | `event_schedule_independent_oracle` / `decode46-scope-review`; independent review `debug56_reader_product_oracle`; root integrates | Canonical Codec/constructors; #38/#59 policies unchanged | [Joined evidence](validation.md#current-bounded-evidence-map-2026-10-15): stock 32-case TS/JS/Native public views plus canonical 92, current 22 and 40-row physical state/owner checks, authority and reached mutations. Native semantic review passes; private compiler evidence is separate. | Closed after integration `a2442d48d`, independent final review and CI 38825895705 PASS. Comparative timing belongs to combined #21/#23/#24; #58/#59 retain save/restore gates. |
| #58 snapshot export | Root; source reconciliation `debug56_reader_product_oracle`, final review `scopes45_source_control` | Integrated #46; approved #38 WorldIO; restore policies unchanged | [Semantic acceptance](snapshot-export.md#semantic-acceptance-reconciliation) passes all four criteria. Existing full two-schema JS/Native, actual TS, authority and reached defects joined to current sources; independent final review PASS. | Closed after `b8c7cde5b`, independent final review and CI38835649996 PASS. Combined #21/#23/#24 performance and #59/#60 restore/extension remain separate. |
| #59 basic restore | `identity38_gate_audit` / `/tmp/bendvy-restore59-opaque` (`feature/restore-opaque-token-v1`); observer `debug56_reader_product_oracle` / `/tmp/bendvy-restore59-observer`; independent oracle `relation_ts_oracle` / `/tmp/bendvy-restore59-oracle`; root integrates | Integrated #38/#46/#58; full saved-key mapping, existing generation and factory contracts | Complete28-checkpoint Workshop/Garden stock JS/Native-O3 pairs pass (Garden linear successor). Numeric10, stored-P7 and reached Raw-progress-mutant15 pairs pass full independent oracles; old deadlines retained. TS shared47,826-byte execution is reused under explicit scope (`51329eb00`). | Exact19-file core and selected consumer closures materialized byte-exact in master worktree. Portable evidence, independent final review and unchanged default #28 pass. Integrated `947ad64a7`; CI38999462816 PASS and English acceptance report posted. #59 closed; graph/machine restore remains #60. |
| #60 graph and machine restore | `identity38_gate_audit` / `/tmp/bendvy-restore60-current-runtime`; oracle `relation_ts_oracle`; root integrates | #44/#49/#59 closed; current event Runtime and approved restore ownership | Full Runtime+Raw consumer24e0fbca8 passes19 checkpoints on stock JS/Native for both schemas: Workshop239,306 bytes, Garden239,304 bytes against source-derived oracle75484df52. Original header-model error/failed receipt preserved; existing JS run reused by explicit corrected-oracle comparison. | Closed after master81316652e, actual hooks, CI39010187646 and English acceptance report. Normal/refusal/mutation pairs, TS/basic applicability, combined #28 and independent review pass; no universal recovery claim. |
| #64 defense preparation | `identity38_gate_audit` / current-defense-plan sparse worktree; root integrates | #63 semantic acceptance complete; #61 closed; canonical jev read-only | Commit `7268b7941` maps current per-event transport, complete identities, host seams and 26 working-tree source hashes. | Planning accepted and closed after a969f8c00, actual hooks/push, CI39010684455 PASS and English report. Copy/toolchain/adapters and combined qualification remain execution prerequisites; canonical jev unchanged. |
| #62 exact law proposals | Root / `master`; original law-draft worktree preserved | #61 closed; exact #18 approvals retained | Four exact Data proposals pass JS/Native and four JS mutants; technical/source review and unchanged 13-file completion audit pass. | Closed after `0e48247c7`, CI 39114729049 PASS and [English completion report](https://github.com/dearlordylord/bendvy/issues/62#issuecomment-6248183531). Four subjects remain unapproved with no proofs; future proof/refinement stays under #1. Existing 7+2 approvals and 22+11 other drafts remain distinct. |
| #21/#24 performance and dispatch acceptance | Root integrates; `cached_buffer_writer`: selected-case source/evidence reuse; memory owner `capture_carry_order`, model support `uniform_u32_blocks` | [Seven speed cases and distinct memory paths](../design/parity-resolution-protocol.md#current-acceptance-scope--user-amendment-2026-10-19); reuse90 semantic roles | Dense Indexed all sizes accepted; Sparse64 distinct Plain integratedfb22619d7 after JSNative/final GO. Selected FailedTxn Motion64/Health64 adapters accepted | Reuse Dense/Sparse/Lifecycle selected source/evidence; finish Readers adapter, seven rotations/uncertainty, uncovered ownership paths, clean child RSS and unchanged #28.1024 is targeted/nonblocking |
| #73 ordinary App usability | Root; helper, blind audit, docs and primary Dense source integrated | Existing capture/error/cursor contracts; prior heterogeneous/two-schema acceptance | Helper, blind greenhouse, guide/example and full failure/retry/authority consumers pass. Automatic primary Dense uses one `Component.add` registration and complete retained owners. Independent final review GO; required combined #28 attempt06 passes `NO_CONFIRMED_REGRESSION`. | Closed after integration `ba85ff4ce`, report `f4870e1c4` and CI39149828014 PASS. Prior failed cohorts remain historical evidence; passing statistical gate does not establish equivalence or full #21 performance. |
| Shared core/integration | `/root` / `master`; workers own isolated leaves | Accepted feature contracts and #73 ordinary entry | Ordinary query declarations evaluate once; five workload terminal matrices and finite current-boundary/metadata diagnostics are integrated. | CI39137421309 PASS. Complete #73 captured-query delivery and combined qualification. Four exact Data laws remain unapproved under #1; one shared-core owner and one heavy queue. |
| #50 owned captures | Root integrates; source/oracle/authority evidence retained | #36 accepted; Bevy persistent capture lifecycle | Complete resource/query/schedule/lifecycle, automatic App/debug metadata and authority evidence accepted by independent joined review. Integrated `34d7712cd`. | Closed after CI38855954288 PASS and the English acceptance report. Heterogeneous composition continues in #51. |
| #51 captured schedules | Root; qualified source/oracle/helper worktrees preserved | #34/#35/#50 accepted | Complete typed composition, stateful conditions, preflight/lifecycle, routing mutation, authority and shared TS evidence accepted by independent review. Integrated `1bcf107fa`; CI38859172838 PASS. | Closed after the English acceptance report; full performance remains #21/#23/#24. |
| #52 recoverable affine operations | Source `scopes45_source_control` / `recovery52-owned-operations`; helper `missing_resource_direct_consumer`; oracle `debug56_reader_product_oracle`; root integrates | #50/#51 accepted; exact recovery, unrestricted Type payloads and host-IO boundary | [Joined semantic acceptance](recovery.md#semantic-acceptance-reconciliation--2026-10-16) PASS: canonical component/resource/capture declarations share one typed journal; full mixed 16,673-byte stock JS/Native oracle, unlike families, returned owners, authority refusals and reached owner-loss control. | Closed after integration `8b80a21ba`, CI38868650606 PASS and the English acceptance report. Fresh independently authored present-removal application passes both stock backends with its complete 2,276-byte oracle. Existing #28 applicability is reused; combined performance remains #21/#23/#24. |
| #53 owned events | Root; implementation/oracle/application worktrees preserved | #31; [selected ownership](affine-events.md#selected-ownership-boundary--2026-10-16) | [Final Spec/Standards review](../../experiments/public-owned-events/ordinary-v1/FINAL-REVIEW.md) PASS: canonical families/readers, blind application, combined query/resource rollback, authority and reached retirement loss pass stock JS/Native. | Closed after `32539b721`, CI38883496921 PASS and the English acceptance report. Protected #28 evidence reused; combined performance remains #21/#23/#24. |

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

The #50 entry follows the existing Bevy-first decision; its older general
approval question is superseded. Other unresolved ownership choices remain open.

| Issue | Concrete approval subject | Source basis / status |
| --- | --- | --- |
| #54 association | `canonical_full23_delivery` / `native54-matching-tree-v1` (ordinary current consumers and typed event Inspector capability); independent final review `inspector_integration_review`; root owns shared core | The extra registration-liveness proposal is withdrawn: Rust QueryState/SystemState World checks do not establish dependence on a registered System remaining present. No borrowed registered-cursor entry or new rejection result is adopted. Current Inspector returns detached Data and affine owners, so a held-view gate is not applicable. Query capabilities are schema/family typed, not bound to one World instance; namespace uniqueness across independent factory roots is the concrete #38 dependency. |
| #50 | [Registered capture owners](captures.md#implementation-direction--registered-capture-owners): persistent affine state; owner-returning unregister and fresh registration identity. | Selected through Bevy FunctionSystem/RemovedSystem semantics and the existing reference-order decision. No mandatory finalizer, cross-world live transfer or #52 inverse policy. The older general question is superseded; #50 semantic acceptance is integrated and closed. |
| #53 access | Selected: opaque scoped read capability with detached Data projections and independently owned Type observations, following Bevy/Bend constraints. TS shared mutable alias identity is not a governing contract. | [Observed study and proposal](../../experiments/public-owned-events/RESEARCH.md): TS shares objects, Rust readers borrow, Bend cannot duplicate arbitrary Type. A callback merely returning its owner does not prove read-only projection; the trusted concrete provider boundary, before/after preservation controls and any separately approved preservation laws must be explicit. Opaque scoped capabilities confine gameplay but do not prove provider purity. |
| #53 ownership/release | Selected under delegated simpler-recovery direction: one log owner; refusal/available abort/retirement owners return in receipts; independently owned projections survive trim. Failed readers retain owner/cursor under existing rules. | [Selected boundary](affine-events.md#selected-ownership-boundary--2026-10-16). Reader disposal and record retirement remain distinct; there is no automatic IO finalizer, duplicate undo owner or arbitrary extraction. |

The selected #50/#53 boundaries may proceed to implementation. Unresolved
choices retain their approval gates. No new laws/proofs follow from accepting a
behavior contract; specific laws need their own approval.

### Resource and handoff protocol

Coordinator owns shared `src/ecs`, interfaces and integration. Workers own their
assigned files/worktrees, preserve others' edits and hand off exact commits,
source-bound receipts, complete outputs and remaining acceptance gates.
Use [workflow](../agent-workflow.md) and [check policy](../check-policy.md) for
execution/review; retain existing assignment contracts and unresolved approvals.

Authoring, research and review may run concurrently. One heavy stage runs at a
time using one owner of `/tmp/bendvy-parity-heavy.lock`; performance cohorts have
an exclusive reservation after host assessment. Current caps and dated changes are in [execution limits](../limits.md);
Native one thread/GPU off. Explicitly approved
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
