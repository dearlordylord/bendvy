## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A concrete integration plan identifies the exact ECS contracts needed by a separate copy of Canonical Tower Defense without modifying its original repository.

## Acceptance criteria

- [x] Read the canonical application/reducer and record required fixed-step behavior, order, links, cleanup, host/input/render seams and authoritative outputs. Inspect only; do not modify canonical jev.
- [x] Map every required capability to executable source-current evidence or a blocking ticket. Preserve the authoritative reducer; reducer migration requires a separate explicit decision.
- [x] Produce a concrete isolated-copy destination, trace/equivalence plan and execution prerequisites including required proof/performance qualification. Publish actual copy/integration tickets only when those requirements are known.
- [x] This planning deliverable neither installs dependencies nor changes external repositories nor claims integration complete. Missing platform adapters remain visible separate tasks.

## Blocked by

- #63
- #61

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Concrete copy plan — 2026-10-17

This completes the planning scope, not copied-game integration. #63 is accepted;
**#61 remains an execution prerequisite**. No copy, adapter implementation,
dependency installation, canonical execution or new ticket is delivered.
Earlier inventory/pins are retained in git revision
`49fc6ca100fc7ed6a44d0ff4008b2777acbf84dd:docs/parity/defense-plan.md`;
the mapping below supersedes its October 8–9 application assumptions.
The previous read-only plan `7268b7941` has the same document bytes as the
`81316652` base. Its 26 canonical source pins still match; two added pins bind
the producer-owned compiler version check.

Canonical checkout `/workspace/typescript/jev` reports HEAD
`a0773f79ffa4babdba219c773832fa3a61cc803c`, but relevant application files are
modified and new transport/live-motion/tower modules are untracked. **HEAD is
provenance, not the inspected source identity.** The 28 hashes below identify
working-tree bytes read without modification. This is a selected-source
inventory, not a frozen transitive executable closure or qualification of the
canonical team's unfinished work. Freeze their chosen stable snapshot before
copying; do not discard those local changes or silently copy HEAD instead.

The actual chain remains `DefenseMain → DefenseHost → NativeRun → Engine.step
→ Canonical.step`. The final reducer calls `check_step(state,
step_unchecked(state,event))`; preserve this authoritative reducer and its
business dependencies byte-for-byte. Moving reducer logic into ECS requires a
separate explicit decision. Rust Bevy governs ECS architecture, Bend governs
ownership/runtime constraints, and bevy-ts supplies feature inventory/shared
comparison cases; the game's reducer and Host own game behavior. Reference
HEADs remain Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
`a950fd683c0d76f09794078e6174fe98a1492876`, bevy-ts
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.

Pinned Bevy `bevy_time/src/fixed.rs::run_fixed_main_schedule` accumulates
overstep and runs ordered fixed schedules. The game, rather than the generic
ECS, selects its 20ms step, eight-step frame cap and retained excess carry.
Bendvy source/evidence below is inspected at master `81316652`; the selected
project-local compiler wrapper is distinct from the pinned stock ELF.

### Required seams and evidence boundaries

Canonical names below are under `prototypes/canonical-defense/` unless qualified.
Evidence links are current accepted capability joins, **not execution of this
game in Bendvy**. Optional ECS representations do not become required new APIs.

| Required behavior / exact source seam | Existing capability evidence | Remaining work / owner |
| --- | --- | --- |
| Whole canonical World as one ordinary resource; repeatable input-step and read-only observation systems | [`ordinary-app-resource-field`](../../src/ecs/ordinary-app-resource-field.bend), [`ordinary-resource-field-system`](../../src/ecs/ordinary-resource-field-system.bend) and [selected-resource delivery](../../experiments/public-construction/selected-resource-v1/FINAL-REVIEW.md) qualify declaration-derived grants, updates and sibling preservation. #63 qualifies ordered repeated public systems in a separate application. | #64 must instantiate the actual large game Data type, keep the unchanged Host as business authority and compare complete traces. Generic source signatures and earlier applications do not qualify this instantiation. |
| `DefenseMain.clock_enabled/clock_record`: accumulate carry, at most eight 20ms ticks/frame, retain remainder; inactive/paused clears carry. Playback consumes recorded batches, not fresh wall time. | [#63 simulation](simulation.md#semantic-acceptance-reconciliation): two schemas, fourteen phases, full 97,054-byte JS/Native state plus retained TS/control joins. | #64 must replay the actual clock/input boundary; #61 cross-feature audit. #63 does not prove this clock's equivalence. |
| `DefenseHost.tick_when → bounded_observed → begin_transport → event_loop → finish_transport`: automatic tower intervention and initial transport synchronization; bounded 256-event loop calls `Run.advance(...,1n,until)` at endpoint `time*20+20`; each micro-result ingests rules/actors and synchronizes transport before the next event. Final accounting/movement/damage depends on actual horizon/time advance. | [Schedules](../reports/public-schedules.md), [#63](simulation.md), [bundles #41](bundles.md#semantic-acceptance-reconciliation) establish ordinary ordering/explicit barriers and complete owners in their consumers. | #64 preserve this call order. The old coarse advance-then-render description is insufficient. Do not parallelize/reorder micro-events or add an implicit barrier. |
| `DefenseTransport.synchronize/delay` uses exact `CB.Target`, callback source, `Controls.apply(...,CB.Transport{at},...)`; records `Change{eventCount,target,at}`. Physical arrival can delay callbacks; the transport journal is replay input. `DefenseTowerFire` intervenes in eligible current work without inspecting its captured outcome. | [#71 typed Data events](typed-data-events.md#current-semantic-acceptance--2026-10-15) supports typed streams/readers; [resource confinement #70](https://github.com/dearlordylord/bendvy/issues/70) support ordinary owned state. These do not qualify the game's callback scheduler. | #64 keep canonical callback/transport machinery intact. #50/#53 are conditional blockers only if the adapter introduces affine captures/events; current game records are Data, not permission to narrow generic ECS Type support. |
| `DefenseMotionTypes.WorkIdentity{partition,lifetime,round,operation}` plus full predecessor list; `DefenseMotion.before` orders the complete four fields (old local parameter names are not domain meanings). `DefenseLiveMotion` joins exact callback targets to actual actor/fragment geometry. | [Relations #42](relations.md#semantic-acceptance-reconciliation), [readers #43](relation-readers.md), [hierarchy #44](hierarchy.md#semantic-acceptance-reconciliation) retain qualified finite order/cleanup behavior. [Identity #38](identity.md) is closed with full generation keys, slot reuse and real WorldIO authority. | The first copy keeps these identities inside the canonical World resource. A later entity mirror must retain all four Nat fields and an explicit mapping to actual namespace/index/generation handles. It cannot narrow or replace the canonical key, and must preserve the approved full-generation-wrap exception. |
| `DefenseMotion.tick/alive`, rule fragments, live-mob reconciliation and `DefenseOutput` distinguish completed/retired visuals, pending findings, ready outputs and collection leases. Arrivals/Finish captured-member assembly affect eligibility. | [Scopes #45](scopes.md#semantic-acceptance-reconciliation), #44 and #63 cover ordinary persistent survivors/removal and hit/death controls. | #64 compare full presentation and business retention separately; neither visual despawn nor an ECS scope may delete retained business state. Game cleanup is not inferred from generic scope evidence. |
| `DefenseConsumerObserved.Envelope` retains config/seeds/original inputs, every checkpoint World, and per-tick full engine before/after, ordered frames, physical deliveries **and transport changes**. `Engine.step` delegates to `Canonical.step`. | #63 and [#55](inspect-extended.md#semantic-acceptance-reconciliation) provide patterns for complete logical/ownership observations; no copied-game receipt exists. | #64 actual original/copy full-observation equivalence; #61 audit. TS `simulation-adapter.ts` imports shared generated Engine; it is not an independent replacement reducer or native host oracle. |
| `DefenseMain.events_fold` records supported events before applying them; suppresses X11 stop-key repeat pairs, threads stop-held state, renders before receiving ordered Window events, then records/applies clock batches. `DefenseRecording.apply` replays reset/key/click/move/ticks through Host. | Existing ECS pure scheduling does not cover native Window/File/Image/clock or journal failure semantics. [Platform inventory](../reference/core-map.md#platform-tracking-не-core-parity) remains separate. | #64 host adapter/recording requirements; preserve write-before-state and actual image/free/file/window ownership. No implicit IO rollback. Mouse/move and clock/repeat cases exceed the existing GameKey/Ticks/JevProfile headless consumer. |
| `DefenseRender.view/diagnostics` and `DefenseTowerPreview` read the real geometry/eligibility; preview must not advance time, fire a shot or alter gameplay. | [Current full23 Inspector](../../experiments/public-inspect/ordinary-declaration-v1/current-full23-v1/FINAL-REVIEW.md) has complete JS/Native observations through the selected project-local wrapper, integrated at `81316652`. #55/#56 remain scoped read/debug evidence, not game rendering. | #64 needs a native Window/input adapter and a separate emitted-JS headless adapter. No browser backend is assumed. Direct canonical Data projection is sufficient for the first copy; Inspector is optional and its selected-tool qualification must not be relabeled stock-compiler evidence. |
| Optional ECS tracing of adapter dispatch and explicit barriers | [#57 execution trace](debug-trace.md) and `ordinary-execution-trace.bend` retain actual operation/queue/rollback facts through qualified ordinary consumers. | #64 may opt in without replacing the canonical complete observation. Debug-disabled and enabled owners must preserve game results. Trace facts do not make the game callback scheduler an ECS command queue. |

### Isolated copy and equivalence prerequisites

Destination remains `/workspace/formal-proofs/bendvy-copies/canonical-defense-64-v1/jev/`
(absent at inspection). Preserve `prototypes/../../packages` layout and the exact
chosen complete imports/foreign resources/tools/configuration, including
untracked files **if** they belong to the selected snapshot. Keep builds and
recordings under that copy; never run the original launcher. Bind
`HAPSLAND_GAME_RECORDING` to the copy explicitly: new launch and reset replace
its journal. No directory or dependency installation was created here.

The first copy has one business authority: an ordinary resource named
`CanonicalWorld` containing the complete `DefenseModel.World` Data value.
Use the existing declaration-derived
[`ordinary-app-resource-field`](../../src/ecs/ordinary-app-resource-field.bend)
and [`ordinary-resource-field-system`](../../src/ecs/ordinary-resource-field-system.bend)
with one declared write grant. Register a repeatable pure `Step` system and a
read-only observation step. The ordinary body invokes the copied, unchanged
Host functions; their Engine/Canonical imports remain unchanged. Use actual
WorldIO creation and retain the App, Registry and recipe owners. This plan adds
no actor entities, hierarchy reinterpretation, duplicate business World or
reducer migration. It validates ECS resource/system composition, not an
independent component-storage port of the game.

New integration code belongs under
`jev/prototypes/canonical-defense/bendvy-integration/`. A `headless.bend` entry
replays the complete original `DefenseConsumerObserved` inputs through `Step`.
A separate native entry owns Window, File, Image and clock values. Persist only
frame bookkeeping outside the business resource: last time, carry, quit,
playback mode and held-stop state. Build temporary canonical Frame projections
from the current resource when invoking the existing pure frame functions;
do not keep a second persistent `M.World` mirror.

The native adapter follows `DefenseMain` operation order. Render the current
World, receive the ordered event batch, free the Image, suppress the exact stop
release/press repeat pair, record each supported event, then dispatch its pure
state operation. Record a tick batch before applying that batch. Preserve the
successful IO prefix if a later write fails; an ECS transaction cannot undo a
File write. Neither a batch-wide ECS rollback nor a newly introduced condition
may erase an already recorded/applied input. Playback consumes recorded entries
through `DefenseRecording.apply`; it does not recompute ticks from wall time.
The first headless adapter does not claim to cover this native IO protocol.

Committed services and host-owned File/Window/Image values are not saved game
state. The current [#60 graph restore](restore-graph.md#current-implementation)
and its [final review](../../experiments/public-restore/graph-runtime-v1/FINAL-REVIEW.md)
qualify ordered relation/machine restore and runtime clearing on their own
consumers, integrated at `81316652`. They are not a replacement for the game's
build-bound input journal. #59/#60 are conditional dependencies only if a future
copy explicitly adopts an ECS snapshot format. No save-format migration is
selected here.

### Execution prerequisites

The canonical build currently enforces **Bend 2.0.36, source `ae1101c`** through
`packages/agent-flow-bend/package.json` and
`packages/monkey-business-bend/compiler.mjs`. Bendvy's qualified selected wrapper
uses the pinned 2.0.35 ELF and reviewed CLI recipe. These are different tool
identities. Establish a concrete compatible toolchain before executing the
combined copy; do not bypass the canonical version check, install a compiler,
replace the selected wrapper or infer compatibility from source inspection.
Any concrete tool/dependency change follows the existing SPEC/check-policy
approval and launch review. No such change is adopted by this plan.

`cached-build.mjs` distinguishes its default `bend-native-optimized` build from
opt-in `HAPSLAND_GAME_CPU_BANK=1` Linux register-bank lowering at `-O0` with X11.
`run.sh` also has a Darwin ARM64 Apple-clang21 stack-check workaround. Freeze the
chosen host, compiler, Base/effects, flags, environment and complete FFI resources;
do not silently combine modes or compare unlike artifacts. Native interactive
execution needs a working Window/Image/File/clock path and display, while the
JS target is the full headless observation consumer. Core host-service ownership
is qualified by the existing service APIs, not the availability of a display or
a browser renderer. The missing headless dispatch entry, native input/recording loop and render/IO
adapter remain explicit execution prerequisites retained by #64, with #61 as
the capability-audit blocker. No implementation ticket is authorized by this
plan, and no new platform ticket is created here.

Before any copy launch:

1. Reinspect/freeze the stable canonical closure and tool/platform requirements.
   The current working tree is evolving; historical README receipts (including
   the 82,121,538-byte native/JS comparison) do not qualify today's changed Host,
   transport, callback controls or codecs. Establish source applicability or
   capture the actual new reference before comparing the copy.
2. Extend/reuse the actual full consumer observation at identical logical
   boundaries: complete World and engine state, ordered frames/physical outputs,
   transport journal, actor paths/predecessors, rules, towers/health/investment,
   callback targets/queues, live poses/beams and retained business output. Add
   frame carry/playback/held-key and record-write observations for host cases.
   Derived counts/checksums or sorted output are insufficient; observe ECS owners,
   stamps, registrations/readers additionally where the adapter changes them.
3. Exercise original controls and all three maps; pause/resume/reset, burst,
   outage/repair, exact-target tower acceleration, zero-time callback issuance,
   physical arrival/Finish assembly, retained finding and cleanup. Include ordered
   key/mouse/move batches, stop repeat, catch-up carry and journal resume/replay
   refusal/prefix cases. Obtain actual complete original traces and an independent
   source-derived operation/state oracle before accepting copy outputs; preserve
   timestamps/identities and numeric encoding. A shared TS engine comparison is
   additional evidence, not a replacement for the native game's host behavior.
4. Run the copied complete headless JS/Native consumer and the separately scoped
   interactive host checks through existing runners. Reach a concrete dropped or
   reordered transport update/identity association/cleanup mutation, plus affected
   public schema/authority/owner refusals. No new cap or compiler is selected here.
   Source checks retain the existing five-second cap. #61 must reconcile the
   required capability combinations before execution acceptance. Record which
   delivered #18 proof subjects actually apply and which obligations remain with
   #62. New exact subjects need falsification and human approval before ECS
   proof work; canonical LAWS/PROOF filenames do not establish Bendvy proof
   acceptance. This plan does not add a blanket new-law requirement to a semantic
   run. Approve concrete new dependencies and observable contracts before use.
5. Preserve unchanged #28 for executable core changes and combined #21/#23/#24
   equal-work qualification (JS ≤ TS, Native ≤ 0.5×TS). R7 does not require a new
   comparative campaign for this documentation or each semantic slice. No timing
   was measured here; CPU contention is not grounds to weaken correctness.

The initial storage extent and destination are fixed above. The remaining
execution prerequisites are a stable complete canonical closure, compatible
pinned tooling, #61's current capability audit, actual host adapters and the
original/copy observation entries. Freeze these in the authorized execution
work before launching either reference or copy. Preserve canonical relative
imports and do not point copied writes or build caches back to the original.
No new execution tickets, installation, integration completion, proof acceptance
or comparative performance result is claimed by this planning commit.

### Inspected working-tree source pins

All paths below are relative to `/workspace/typescript/jev`. Hashes were checked
again after inspection; these selected files stayed unchanged during this review.

| Source | SHA-256 |
| --- | --- |
| `prototypes/canonical-defense/DefenseMain.bend` | `57cc150e51c81c9dfb05afbd93c41e6e596f9567f57337de42748ed1e742da14` |
| `prototypes/canonical-defense/DefenseHost.bend` | `1b38db00d919d966fec9d4cd132f3943924dbf3dc61aaaea638ee62f01c20f33` |
| `prototypes/canonical-defense/DefenseModel.bend` | `64249a997c8136adc17975a1ed03f7a9d969529e7dabf91b3cf8f287705cad9e` |
| `prototypes/canonical-defense/DefenseMotion.bend` | `65e6ff05db7ce12161a9223da076ad33e730ceb26b7385d3a331ff6166fecec9` |
| `prototypes/canonical-defense/DefenseMotionTypes.bend` | `0cdb303b0efc40a66d81cac455b1dd8222a535f1d1e84a58122c401f3356a0dd` |
| `prototypes/canonical-defense/DefenseRules.bend` | `a46f5ff00920adbc31a95159cd6b2ae19ce57d957fccf377001195cb14e541e4` |
| `prototypes/canonical-defense/DefenseTransport.bend` | `b37bbdd133cae4f0ca37930b8f9381aa9c01bef4dc85d17e609a10450af36a94` |
| `prototypes/canonical-defense/DefenseLiveMotion.bend` | `9f9d613eade8d39a65a512057b4f0124c7e1e24b363a9a2d457992e4cef3b3a4` |
| `prototypes/canonical-defense/DefenseLiveMotionTypes.bend` | `8a75c426d72b06d3bb3029b750ec6c096cee864c2e5a8018cb79c222ff454305` |
| `prototypes/canonical-defense/DefenseTowerFire.bend` | `b585bb2457ab77a17e66176c55efea4857606bbc4e04e78bfeaa204e08c1bd20` |
| `prototypes/canonical-defense/DefenseTowerPreview.bend` | `1942e8cc2635ea8b23bf0fdcd8cd12d826a3c25c5683c098af6289e706f5cac8` |
| `prototypes/canonical-defense/DefenseRecording.bend` | `69dda2af16fcec9639783e9b0153c81f043fda78e25d99ccd88b58adbea65e24` |
| `prototypes/canonical-defense/DefenseRender.bend` | `623dfa59c16f55c232a50a8153d0a04edbbb7bc5053bf181810028df768eb2e8` |
| `prototypes/canonical-defense/DefenseOutput.bend` | `ee8903089e5cb73a5d3d1c0f7f74be1b8d76052934391755f5b4bef74a9c1ed3` |
| `prototypes/canonical-defense/DefenseConsumerObserved.bend` | `236de3b289609e70385419071e4c086c0725a20c789e1e6097231cca924bdf0b` |
| `prototypes/canonical-defense/DefenseConsumerCodec.bend` | `20e69bd1a63ad325b0c2325ab5f3182d6912c77ee8820eb66801e155b70e8a16` |
| `prototypes/canonical-defense/README.md` | `b49ffbbbe166cc748fd2eef43e25dfab33c3875996cf09572e077e0625e3269a` |
| `prototypes/canonical-defense/run.sh` | `d77a2535c5beab3f9227789d7de5955a7a6d07d2eafd2728ed09daef93853e67` |
| `prototypes/canonical-defense/recording-launch.mjs` | `a14afc4c0a04cfc6eabfbad189ca5b7503c642c4e5149ce2f3f5f2edc614f4d4` |
| `prototypes/canonical-defense/cached-build.mjs` | `3050525ce57f4377f3fe59d37d403d65387a4b3225fee454a1abebd9540e1a16` |
| `packages/agent-flow-bend/Canonical.bend` | `c5b08371df7f6ce42938b61f6f871ab08f720264225017eb947f13feee7d51fe` |
| `packages/monkey-business-bend/NativeRun.bend` | `ace7fcc5938334edf7814cfac607c5ae881513cd64142274475370682368a005` |
| `packages/monkey-business-bend/Engine.bend` | `1392c9d269bd0284d9e6621189b2ce5c2aa69ab09961bda73150a48609624fd3` |
| `packages/monkey-business-bend/Callbacks.bend` | `e27ac3b261b04e12f0452a27f0af279b65bdf42b92529cbca11ab571bc1e1bcf` |
| `packages/monkey-business-bend/NativeRunCallbackControls.bend` | `d113cb72219049a087389526483e53051457c8de27a5c86b80998d5e07cfe615` |
| `packages/monkey-business/src/simulation-adapter.ts` | `da6108649f69d7970e32e57b41809e2f6fc53dc27ac27d266db33382e51f15cf` |
| `packages/agent-flow-bend/package.json` | `9b433fbb7be080466c99238488c5d8d64ca7e0c50dfec39725bd74025a86cf70` |
| `packages/monkey-business-bend/compiler.mjs` | `bcb0508a15d00b8fe5471ccd4c7f4702fcdba27ea0a2eca511b9880a0d2a4195` |

### Independent planning review

Spec/Standards review passed for `f4ad915c657fbca0863f4bf0380c0730162a6b2d` (document SHA-256 `6ff4d1a70f695be8fb19361ea3718075c35b0bd6a6474ffd9e618dabc3a281e4`). The reviewer independently checked all four planning criteria, 28 canonical source hashes, three reference pins, 22 local evidence targets and the absent copy destination. This accepts the plan only; execution prerequisites above remain.
