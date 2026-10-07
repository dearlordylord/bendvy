# Remaining full-core parity — published execution map

Specification: [37](https://github.com/dearlordylord/bendvy/issues/37). Full parent #1 and performance parents #21/#23/#24 are unchanged. Existing #34/#35 remain the next immediate feature slices.

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

Existing #34 and #35, plus new #38, #39, #41, #42, #46, #47, #50, #53. Explicit unresolved identity/capture/affine-event contract choices must still be resolved before implementation; there is no blanket approval of divergence.

## Implementation checkpoint — 2026-10-07

| Issue | Current evidence | Remaining delivery boundary |
| --- | --- | --- |
| #34 | Delivered bounded nested provisioning: current 33-core provisioning/flat replays pass 31/42 guarded commands, complete refusal/access/owner controls and reached mutants. Corrected actual-command common work retains full TS/JS/Native observations and 120 timing pairs. | Independent final reviews pass; metadata laws remain unapproved. Modest JS overhead is recorded, and full-product qualification remains #21/#23/#24. See [completion](../reports/nested-provision-completion.md). |
| #35 | Source-current composed schedule-reader controls and independent root replay pass (96 commands, 28 result rows); final independent reviews are reconciled. | Exact law drafts remain unapproved; current paired regression passes; equivalent feature measurements and delivery remain open. |
| #38 | Independent-root collision discovery, checked IO-host namespace and reservation-state wrapper pass finite JS/Native controls; final wrapper has 61 commands and five reached mutants per backend. | Canonical production identity, reservation/capacity/clock/owner gates and explicit unresolved policy decisions remain open. |
| #39 | Delivered executable fragment slice: two-schema public applications, collision/refusal/barrier controls, four reached mutants and independent replay. | Final reviews, unchanged regression and complete timing/scaling retained; JS initialization is slower than TS, Native faster. Full-product qualification remains #21/#23/#24. See [completion](../reports/schema-fragments-completion.md). |
| #41 | Constructor receipts pass 28 guarded commands, pending real-Column insertion passes both backends; fallible spawn is under validation. | No production adoption; actual eager construction, fallible spawn lifecycle, confinement and performance gates remain open. |
| #42 | Pure graph and actual affine World/Commands transport pass guarded JS/Native controls with reached mutants. | No core implementation or acceptance. |
| #46 | Guarded Node reference and independent root replay observe 38 Decode/constructor/Standard Schema cases. | Typed raw ownership, actual ECS rejection, transient save boundaries and full controls remain open. |
| #47 | Generic typed state adapter passes an initial 36-command JS/Native application/foreign/mutant cohort. | Both reader families and executed raw constructors are being expanded; production and delivery gates remain open. |

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
