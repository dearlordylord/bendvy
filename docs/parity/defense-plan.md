## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A concrete integration plan identifies the exact ECS contracts needed by a separate copy of Canonical Tower Defense without modifying its original repository.

## Acceptance criteria

- [ ] Read the canonical application/reducer and record required fixed-step behavior, order, links, cleanup, host/input/render seams and authoritative outputs. Inspect only; do not modify canonical jev.
- [ ] Map every required capability to executable source-current evidence or a blocking ticket. Preserve the authoritative reducer; reducer migration requires a separate explicit decision.
- [ ] Produce a concrete isolated-copy destination, trace/equivalence plan and execution prerequisites including required proof/performance qualification. Publish actual copy/integration tickets only when those requirements are known.
- [ ] This planning deliverable neither installs dependencies nor changes external repositories nor claims integration complete. Missing platform adapters remain visible separate tasks.

## Blocked by

- #63
- #61

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Source-backed preparation — integrated root c15eaf11

This is a read-only requirements snapshot for #64, not copied integration, a reducer migration decision or #61/#63/#64 completion. Source roles follow [SPEC](../SPEC.md#implementation-decisions): Rust Bevy supplies architecture/ECS semantics, pinned bevy-ts supplies feature scope and shared agreed comparison scenarios, and Bend supplies types, ownership and runtime authority. Canonical application behavior remains owned by Jev's shared reducer and game rules.

At initial inspection, the canonical checkout `/workspace/typescript/jev` had HEAD `7e2be112cbb165e247dc8023e0d4813d305aba0d` and was not globally clean: `.github/workflows/native-inputs.yml`, `docs/advicing-target-contract.md`, `docs/agents/navigation.md`, `packages/cli-entry/src/cli.ts` and `src/onboarding/interactive.test.ts` are modified, and `docs/update-context.md` is untracked. None was changed here. The inspected game/shared-Bend package paths and `simulation-adapter.ts` have no Git status changes; hashes below bind the actual files rather than treating HEAD as a blanket working-tree identity. Canonical README qualification belongs to its named historical receipts, not this preparation or Bendvy integration. During read-only validation its HEAD advanced externally to `9cace54ecfa5c9c04beecddd16eb59644f5d1d6b`; all fifteen named canonical source hashes remained identical. The later unrelated status also included `packages/administration/src/onboarding/verification-conversation.ts` instead of the workflow modification. This record does not freeze the whole evolving external checkout.

Read-only revalidation (2026-10-09), canonical HEAD `749eff6f1ea90299ed24ef9f396063bb8c612191`: 13 of the 15 named source hashes still match. README and the shared reducer changed; the historical pins below remain unchanged. The reducer adds `SourceCacheCheck` and `SourceCacheDrop/Retain` decisions, so future copy execution must inspect and freeze its current complete dependency closure rather than reuse the old snapshot. No canonical files or reducer behavior were changed here.

- `prototypes/canonical-defense/README.md` current SHA-256: `1fe354f746f64178f4302879aa2c957127bc0a34b552fd6999699e637799470d`.
- `packages/agent-flow-bend/Canonical.bend` current SHA-256: `c5b08371df7f6ce42938b61f6f871ab08f720264225017eb947f13feee7d51fe`.

### Required behavior and owning boundaries

The actual native entry is `prototypes/canonical-defense/DefenseMain.bend`, not an assumed TypeScript-only game. Its import chain is `DefenseHost` → `monkey-business-bend/NativeRun` → `Engine` → `agent-flow-bend/Canonical.step`. The TypeScript simulation adapter carries shared projections; it does not authorize replacing the reducer with a new ECS business loop.

| Required canonical behavior and source | Existing integrated evidence and exact limits | Remaining owning ticket |
| --- | --- | --- |
| Fixed step: `DefenseMain:50–68` accumulates elapsed time into carry, executes at most eight 20 ms steps per frame and retains the remainder; inactive/paused state clears carry. `DefenseHost:249–275` uses budget256 and endpoint `time*20+20`, returns actual frames/physical deliveries. Do not confuse the host's frame batch with engine work/event budget. | [Public schedules](../reports/public-schedules.md) covers authored phases/conditions/barriers, and [nested provisioning](../reports/nested-provision-completion.md) covers bounded nested requirements. Neither receipt executes the defense clock or proves time-budget equivalence. | **#63** complete public fixed-step simulation; **#34/#35** schedule/reader composition; **#64** canonical clock/input replay. |
| Exact order: `DefenseMain:114–161` renders the current view, receives ordered events from `Window.frame`, records each supported event before applying it, then records/applies clock ticks. `DefenseHost:227–255` consumes actual engine advance, ingests captured rule counts, ingests presentation frames, ticks rules/actors and computes damage in the authored order. | [Explicit command/transaction observations](../reports/query-composition.md) cover committed earlier work, rollback and barriers; current [bundle full22/20 JS](../../experiments/public-bundles/owned-public-result-v1/production-js-v1/RESULT.md) and [Native](../../experiments/public-bundles/owned-public-result-v1/production-native-v1/RESULT.md) preserve physical owner observations. These are their fixed consumers, not this ordered sequence. | **#63/#64**, cross-feature **#61**; no implicit flush/reordering or independently replayed phases. |
| Links and identities: `DefenseMotionTypes:7–10` retains full `WorkIdentity`/predecessor paths; `DefenseMotion:509–516` orders by phase/lane/request/operation. These are game causal links, not automatically Entity hierarchy. Core graphs/ledger/dispatch remain inside the shared engine. | Adopted relation query source plus [current relation qualification](../../experiments/public-relations/timing/current-qualification-v1/phase2/delivery-files.json) has a finite graph/order scope. [Inspector extension map](../../experiments/public-relations/inspector-extension-study-v1/DELIVERY-GAPS-SNAPSHOT-v1.md) separates its experimental readonly bridges. No receipt establishes a mapping from these compound game identities to ECS entity handles. | **#42/#43/#44**, identity **#38**, **#64** exact causal-identity association. Do not infer numeric equality or discard predecessor history. |
| Cleanup/lifetime: `DefenseMotion:501–508,601–616` uses actual path/presentation eligibility and removes only actors rejected by `alive`; `DefenseOutput` exposes retained/ready/pending result facts. A completed visual route and retained business finding are different states. | [Removal readers](../reports/public-removal-readers.md) retain ordered slow-reader/failure/disposal behavior. [Cleanup consumed-closure correction](../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/SCOPE-CORRECTION.md) explicitly limits newer runtime output to the previous implementation; generic adapter execution is not accepted. | **#45** scopes/persistence, **#48/#50/#53** cleanup/capture/event ownership, **#64** presentation-vs-business retention; **#63** actual death/hit removal. |
| Authoritative engine state/output: `Engine:311` calls `Canonical.step`, whose checked boundary at `Canonical:4325–4326` remains the reducer. `DefenseHost.TickObserved` returns full World, ordered frames and physical deliveries. `DefenseConsumerObserved:9–23` retains config/seeds/original inputs, full before/after worlds and each tick's private engine states/frames/physical outputs. | No current Bendvy receipt executes that canonical reducer inside a copied public ECS application. Generic component/resource/transaction evidence supplies building blocks, not a substitute state machine. Canonical original local proofs/performance remain source-bound external evidence. | **#64** exact copied-game equivalence, **#61** cross-feature public applications, **#62** specifically approved proof subjects; migration requires a separate explicit decision. |
| Host input/render/file seams: `DefenseMain` owns `Window`, `Image`, clock and `File`; image/free and close paths remain explicit. `DefenseRender` is readonly projection. `DefenseRecording:5–34` encodes ordered controls and exact tick batches, and replays them through actual `Host`; resume validates build identity and record completeness as described by canonical README. | The [platform inventory](../reference/core-map.md#platform-tracking-не-core-parity) keeps browser/input/Pixi/render adapters deferred. Bend Base has native Window/Image/File primitives, but source availability is not a qualified ECS adapter. Existing public ECS evidence does not cover graphics, journal crash prefixes or external IO rollback. | **#64** isolated host adapter requirements; **#63** headless prerequisite, **#58/#59/#60** only if an independent save/restore mechanism is later proposed. Input journal replay is not automatically ECS snapshot/restore. |

The source world is currently Data; this does not approve Data-only ECS components, affine event fan-out or a new capture/recovery contract. A future ECS adapter must preserve arbitrary Type and actual owner returns where the public API permits them. Rust Bevy's initialized SystemParam access/state and relationship/lifetime architecture guide storage boundaries; they do not replace the canonical game's sequencing, geometry, numeric rules or reducer outputs. TS API resemblance and source accidents are not new contracts.

### Isolated-copy proposal and exact execution prerequisites

Proposed destination only: `/workspace/formal-proofs/bendvy-copies/canonical-defense-64-v1/jev/` (absent when inspected). No directory, copy, dependencies or external repository edits were made. A later approved copy must retain the source tree layout for `prototypes/canonical-defense/../../packages/...` imports, record the full consumed import/package/tool/resource closure and canonical source hashes, and use a separate build/output/recording directory. Never run canonical `run.sh` against the original recording: normal/new launches overwrite it. Explicitly bind copied recording path and prohibit write paths into `/workspace/typescript/jev`.

Before selecting a storage or adapter implementation, complete #61/#63's actual public combinations and freeze required canonical controls, seeds/config, map, event/tick order and full observation schema. Use `DefenseConsumerObserved`'s existing envelope as the source-backed checkpoint basis: all control before/after Worlds and each tick's engine state, returned frames and physical deliveries; additionally retain full game towers/investment/health/rules/actor paths/causal identities and cleanup outcomes. Compare original and isolated copy at identical logical boundaries. Do not replace observations with count/checksum summaries, sort ordered outputs, substitute expected results or normalize business timestamps/IDs. No original/copy or TS execution was performed here.

The headless trace must include ordinary controls, burst/start/pause/resume/reset, map/settings, repair/outage, causal handoff, retained finding and clear cleanup; record exact actual expectations before Bend outputs. The shared agreed TS engine scenario is an additional comparator, not a substitute for the native game's Host/recording/render behavior. Initial comparison can preserve the reducer byte-for-byte; any relocation/import change must be tracked, and reducer migration remains a separate explicit decision. These are preparation scenarios, not newly approved laws or a frozen executable plan.

Only after source/requirements and public owner/access/refusal/mutation boundaries are reviewed should concrete execution plans be admitted: cheapest source checks first, actual complete reference/JS/Native observations, reached omitted-hit/death/implicit-flush and association/order/cleanup controls, and source-current tool/config/environment/raw guards. Keep disabled/render-only and headless workloads explicit. The unchanged #28 gate, specifically approved proof subjects (#62) and full product performance (#21/#23/#24) remain prerequisites; canonical local timing or a headless demo cannot waive them. No numerical target, compiler modification, dependency or migration decision is selected. Publish actual copy/adapter integration tickets only after these requirements are settled; existing #64 owns this preparation meanwhile.

### Exact read-only source pins

Canonical paths below are relative to `/workspace/typescript/jev` at the state above. Only named source portions were inspected; a later execution must independently freeze its complete transitive closure.

| Canonical source | SHA-256 |
| --- | --- |
| `prototypes/canonical-defense/README.md` | `c1b3922f15c77b62acec259ceb7bdfe468c3f01aa01461c173956ec10b66cc72` |
| `prototypes/canonical-defense/DefenseMain.bend` | `f1a15778e64bc1ed51a22b89a187c94a2f727ea6ab7a141ed9e080f8c39bd7c4` |
| `prototypes/canonical-defense/DefenseHost.bend` | `a48ea9481b8ac8d7929341efc32f05232df4f14654b57d09c9880bc9bd00af41` |
| `prototypes/canonical-defense/DefenseModel.bend` | `5f8d32e6a4952ec112baeb7d7b9eefac962878fee1c5f44e5c5d23e470d83e1f` |
| `prototypes/canonical-defense/DefenseMotion.bend` | `a5e2fe4a8221447548ee90693ee6682ba27eb4239bec736c1c4c629d4d5c080c` |
| `prototypes/canonical-defense/DefenseMotionTypes.bend` | `6ca50e25e4c0fc76ecbf8f05b50c4d973aba70c999e2688681c69c7938db4322` |
| `prototypes/canonical-defense/DefenseRules.bend` | `1404a6579840d7d8a2538918ba53910604f2e41437b140a25516e48756f593b7` |
| `prototypes/canonical-defense/DefenseRecording.bend` | `69dda2af16fcec9639783e9b0153c81f043fda78e25d99ccd88b58adbea65e24` |
| `prototypes/canonical-defense/DefenseRender.bend` | `bb60985110b9bef37a754808376f6c6aa852db13bbf16e7e55b6b5e6523437ca` |
| `prototypes/canonical-defense/DefenseOutput.bend` | `ee8903089e5cb73a5d3d1c0f7f74be1b8d76052934391755f5b4bef74a9c1ed3` |
| `prototypes/canonical-defense/DefenseConsumerObserved.bend` | `5ac26e633bf2f8d619de3ea2091c3f260ab750402567f361c9edc62e12d71290` |
| `packages/monkey-business-bend/NativeRun.bend` | `ace7fcc5938334edf7814cfac607c5ae881513cd64142274475370682368a005` |
| `packages/monkey-business-bend/Engine.bend` | `1392c9d269bd0284d9e6621189b2ce5c2aa69ab09961bda73150a48609624fd3` |
| `packages/agent-flow-bend/Canonical.bend` | `05e6e2367d3112c3cd0614acabf71ffa5bc247a4cdd53a2f6916f734e1c3610b` |
| `packages/monkey-business/src/simulation-adapter.ts` | `da6108649f69d7970e32e57b41809e2f6fc53dc27ac27d266db33382e51f15cf` |

Reference checkouts were read only at the tracked exact commits: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend `a950fd683c0d76f09794078e6174fe98a1492876`. Authority and executable-evidence pointers below bind the inspected root snapshot; none is transferred as copied-defense acceptance.

| Existing authority/evidence | SHA-256 |
| --- | --- |
| `.references/bevy-ts/packages/core/src/Schedule.ts` | `ab1610c356bfbcedf6ac85758e04c7032cda1f2458ff13c8a483c53d94b55c2a` |
| `.references/bevy-ts/packages/core/src/Runtime.ts` | `c744aa5c52845bd3323358c5085161b40a452c6802a1653e3851bfd34c69f5b4` |
| `.references/bevy/crates/bevy_ecs/src/system/system_param.rs` | `e7c04fb01eebff746876ab65a5db9e3e36184a872057408f2e8ac11b694a3d26` |
| `.references/bevy/crates/bevy_ecs/src/relationship/mod.rs` | `08ea0566a6c3104bd4433754260cf474fec38ef162a3d572cbaa5ff48493a6e0` |
| `.references/bend2/bend2/base.bend` | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| `docs/reports/public-schedules.md` | `bcc1ac32ba395dfbae20e8a0355882e4b517e4c9cd17c2ef60d3d9f479f212e6` |
| `docs/reports/query-composition.md` | `6bedf75bc65bba631bfdb21f989e362c72bc403ac7572788c6ddb506b5e4629d` |
| `experiments/public-bundles/owned-public-result-v1/production-js-v1/RESULT.md` | `8472467fe1fc79dcd5b4fbfd303b3daf48b9ef4a3610170a00d1c80f9321d7e0` |
| `experiments/public-bundles/owned-public-result-v1/production-native-v1/RESULT.md` | `dacec44d29856bb30329773289916192c0234ecc2d30522ebb4cef0af929fbc3` |
| `experiments/public-relations/timing/current-qualification-v1/phase2/delivery-files.json` | `41dfa6419955deeffe0ad151e78773d78cadc0caed683f698685dcfa8786fbb5` |
