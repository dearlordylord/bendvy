# T02 — полный core: catalogue и gates

For current implementation status, use the [current parity checkpoint](#current-parity-checkpoint--2026-10-06) below. The T02 catalogue is historical.

Источники требований: [parent #1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../SPEC.md), [T02/#3](https://github.com/dearlordylord/bendvy/issues/3). Это карта всей цели, не сокращённая спецификация первого среза. Числа US ниже — User Stories parent. Статус каждой строки относится к T02: **catalogued / runtime unverified**; исходник не подтверждает Bend capability. «Позже» означает сохранённое обязательство. Platform вынесен отдельно.

Все пути `src/`, `test/`, `dtslint/` ниже относительно `packages/core/` pinned [bevy-ts 3040a3b](https://github.com/SandroMaglione/bevy-ts/tree/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core). Коммиты всех трёх references проверены в [report](report.md). Воспроизводимые описания ограничены [шестью traces](traces.md); поздний harness не реализован.

| Core / parent US | Contract и source | Статус T02 | Следующий этап | Условие возврата / закрытия gate |
|---|---|---|---|---|
| Identity, reservation, liveness, exhaustion (1–2,15) | World-scoped stable handles; dead/foreign/pending lookup fallible; encoding/reuse — технические решения. `src/Entity.ts`, `Command.ts`, `internal/world.ts`, `Runtime.ts:resolve`; `test/Runtime.query-lookup.test.ts` | Catalogued; foreign-runtime ambiguity D1 | T05; R1 | Определены exhaustion/reuse и runtime-world boundary; получен R1 и controls stale/foreign/pending |
| Components, tags, bundles (3,31–32) | Typed heterogeneous values; Data-only не одобрено. `src/Descriptor.ts`, `Command.ts`; `test/Runtime.commands.test.ts`; Bend kinds дополнительно SPEC | Catalogued; ownership open | T03/T04 | Data и affine Type доступ, update cost, rollback совместимы; restriction требует решения |
| Schemas и composition (4–5,33) | Две схемы; fragments/features, dependencies, duplicate descriptor rejection. `src/Schema.ts`, `Feature.ts`, `internal/fragments.ts`; `test/Feature.test.ts`; `dtslint/Schema.tst.ts` | Catalogued; явные declarations сейчас | T03; затем composition | Две схемы и negative cross-schema fixture; второй application для F01/DSL; core feature composition остаётся обязательным |
| Queries, lookup и порядок (6,16) | Required/optional, with/without, cardinality errors; spawn order независимо от порядка insert. `src/Query.ts`, `internal/queries.ts`; `test/Runtime.query-lookup.test.ts`, `Runtime.storage.test.ts` | Catalogued; R2 описан | T03/T05 | R2 исполнен; churn/remove/reinsert порядок проверен перед storage API; не сортировать фактический ordered result в normalizer |
| Declared capabilities (7–8) | Check-time undeclared access, cross-schema, writes-through-read rejection по intended reason. `src/System.ts`, `Query.ts`; `dtslint/System.tst.ts`, `Cells.tst.ts`, `Identity.tst.ts` | Catalogued; TS не доказывает Bend rejection | T03 | Три negative controls и положительные примеры на двух схемах; runtime traces не заменяют compile fixtures |
| Resources и per-system local state (9) | ECS resources rollback; private state ownership явно. `src/System.ts`, `Runtime.ts:journalStoreWrite`; `test/Runtime.resources.test.ts`. Dedicated Local API поиском не найден: callback captures не считать доказанным ECS local contract | Catalogued; Local unresolved | T06/T09; T12 decision | Установлены lifetime, повторяемость и failure rules local state; host capture не подменяет transactional ECS state |
| Host services / provisioning (10) | Services вне rollback; checked requirements до исполнения. `src/Requirement.ts`, `Runtime.ts:tryRunSchedule`; `test/Runtime.requirements.test.ts`, `Runtime.resources.test.ts` | Catalogued; R6 описан | T09 | R6 исполнен; nested union requirements и compile boundary проверены |
| Repeatable systems (11) | Повторный запуск с affine closure/state ownership. `src/System.ts`, `Runtime.ts:slotOf/runSystem`; `test/Runtime.storage.test.ts` | Catalogued; Bend expressibility open | T03/T04/T09 | Один system value повторно работает, не теряя ownership |
| Schedules, phases, conditions, nesting (12) | Authored deterministic order, no implicit grouping; flattening и duplicate checks. `src/Schedule.ts`, `Condition.ts`; `test/Runtime.scheduling.test.ts`, `Schedule.when.test.ts` | Catalogued; CPU sequential initially | T09 | Nested schedule/phase provisioning и failure tested; parallel revisit после native workload evidence (F04) |
| Deferred commands / barriers (13–14) | Commit публикует очередь, marker применяет; очередь между runs. `src/Runtime.ts:runSystem/applyDeferred/runSteps`, `Command.ts`; `test/Runtime.storage.test.ts` | Catalogued; R1/R3 описаны | T05/T06 | Исполнены R1/R3; отсутствие implicit flush и сохранение earlier pending work проверены |
| Added/changed visibility (17) | Независимый reader per system; failure не продвигает cursor; first run sees existing. `src/Runtime.ts:runSystem`, `internal/world.ts`; `test/Runtime.lifecycle.test.ts` | Catalogued; R5 описан | T08 | R5 исполнен, skip/failure/overwrite controls; не смешать commit и structural visibility |
| Removed/despawned (18) | Records после удаления, independent readers, slow/skip retention. `src/System.ts`, `internal/world.ts`; `test/Runtime.lifecycle.test.ts:105–201` | Catalogued; поздняя детализация | T08; lifecycle block | Readers и cleanup согласованы с handles/barriers; preserved backlog при skip подтверждён |
| Events, retention, lag, skip/failure (19–21) | Ordered buffered publication per successful system; independent readers; registered slow-reader retention, capacity lag; skipped event-reader discards backlog. `src/internal/streams.ts`, `Runtime.ts`; `test/Runtime.events.test.ts` | Catalogued; R4 описан; skip отличается от removals | T07 | R4 исполнен; capacity/different-rate/skip/failure факты затем проверены, без объявления unlimited retention |
| Typed failures / transactions / publications (22–24) | Read-your-writes; failed system rollback only; earlier commits preserved; events/commands/machine queue drop; host IO excluded. `src/Runtime.ts:995–1063,1387–1438`; `test/Runtime.stability.test.ts`, `Runtime.events.test.ts` | Catalogued; R3 описан | T06 | Combined R3 и successful retry исполнены; affine payload rollback работает; universal refinement отдельный gate |
| Relations, inverse, hierarchy (25) | Source/target consistency, cycle checks, failure streams и cleanup. `src/Relation.ts`, `internal/world.ts`; `test/Runtime.relations.test.ts` | Catalogued; later | Relations package после identity/commands/streams | До раннего API закрепить handle references и publication boundary; затем полный cleanup/cycle/order scenarios |
| Lifetime scopes (26) | Scope cleanup не удаляет persistent entities. `src/EntityScope.ts`, `Command.ts`; `test/Runtime.stability.test.ts:98` | Catalogued; later | Scopes после relations/lifecycle | Despawn semantics и inverse cleanup готовы; ownership scope не заменяет liveness |
| Component states, global machines (27) | `src/Descriptor.ts`, `Machine.ts`, `Runtime.ts:applyStateTransitions`; `test/Descriptor.State.test.ts`, `Runtime.state-machine.test.ts` | Catalogued; early impact D3 | T09 minimal queue; затем states | Exit/transition vs enter failure boundary учтён до transaction API; позже полный state harness |
| Validation / typed input errors (28) | Constructed/raw boundary explicit, no partial invalid restore. `src/Decode.ts`, `Descriptor.ts`, `Snapshot.ts`; `test/Decode.test.ts`, `Runtime.commands.test.ts` | Catalogued; later | Validation совместно с payload/restore | Typed constructors и failure preservation определены; new dependencies approval |
| Snapshots / restoration (29) | World save ≠ runtime checkpoint; transient omission, validation before mutation. `src/Snapshot.ts`, `Runtime.ts:1723–1835`; `test/Runtime.snapshot.test.ts` | Catalogued; early impact D4 | Snapshots после identity/relations/states | Handles, streams, pending queues и cursors boundaries заданы; позже полный restoration package |
| Inspectors, debug, tooling (30) | Read-only inspection не consumes system visibility, inspector не holds retention. `src/Inspector.ts`, `Debug.ts`; `test/Runtime.debug.test.ts`, `Runtime.events.test.ts:191`; `packages/devtools` | Catalogued; later | Tooling после readers/restore | Noninterference и отдельный inspector cursor проверены; opt-in debug overhead измерен |
| Follow-ups / scope completeness (34) | [F01–F06](../follow-ups.md), эта карта; упрощение не уменьшает parent | Catalogued | T12 и каждый поздний checkpoint | Каждая deferred строка детализируется по своему return condition; divergence явно согласована |
| Native/JS performance (35–37) | Native существенно быстрее TS; JS comparable; equivalent work, timing/memory/scaling, per-workload regressions. SPEC; `packages/core/bench` | Mandatory; **не измерено T02** | T10 → T12 threshold approval | Численные thresholds согласованы; final representative workload evidence, не prototype-only |
| Laws, proofs, refinement (38–40) | Falsification + planted defect → human approval → proofs + meaningful mutation; model/function/finite traces/universal runtime refinement различны. SPEC; bend-ldd | No ECS law approved/proved T02 | T11 → T12 proof packages | Specific laws одобрены; proof/mutant gates и runtime representation obligations пройдены отдельно |
| CPU fixed-step simulation (41) | Spawn/move/damage/removal/hit/death deterministic public traces. SPEC; `examples/top-down/test/simulation.test.ts` prior art | Deferred, mandatory | T12 → simulation | Required capabilities, proofs и reproducible inputs/outputs готовы |
| Copied canonical-defense integration (42–43) | Separate copy, authoritative reducer сохранён; order/fixed-step/links/cleanup. SPEC, F02/F06 | Deferred, mandatory | Integration после headless core | Нужные core capabilities подтверждены; original jev/dalph неизменны; reducer migration — отдельное решение |

## Platform tracking (не core parity)

| Область / source | Статус | Следующий этап / возврат |
|---|---|---|
| Browser loop/input/capture: `packages/browser`, `PLATFORM.md` | Deferred adapter, console CPU first | F03: при integration потребностях fixed-step/input |
| Math values: `packages/math` | Deferred host support | При конкретном simulation/application контракте; dependencies согласовать |
| Pixi/render sync: `packages/pixi` | Deferred adapter | F03 после headless и cleanup semantics |
| Parallel compute / GPU orchestration | Initial slice исключает; full parallel scheduler не gate первого среза | F04 после equivalent native measurements и ownership partition evidence |
| Rust renderer/PBR/assets/audio/editor | Out of scope по parent | Не заявлять как deferred core или как достигнутую parity |

## Ранние specification decisions из upstream

**D1 — world identity.** `Runtime.ts:855–880` resolves `target.value`/`handle.value`; `internal/world.ts:316–320` allocation starts в отдельном world. Numeric handle encoding не несёт runtime world token. TS nominal typing не подтверждает rejection handles другого runtime с той же схемой. Parent требует world-scoped safety: перед T05 определить runtime identity/check, добавить same-schema foreign-world negative control; TS parity этого случая не объявлять. Нельзя «исправить» normalizer так, чтобы скрыть ошибочный lookup.

**D2 — readers и Local.** Event skip advances `streamLastRun` (`Runtime.ts:1388–1395`); removal reads use change cursor (`Runtime.ts:1356`), retained on skip (`test/Runtime.lifecycle.test.ts:170`). Failure advances neither successful cursor (`Runtime.ts:1426–1428`). Поэтому единый «skip consumes everything» контракт неверен. Для per-system local state dedicated API не найден; до T06/T09 явно решить, что ECS-owned, а что host capture, не обещать rollback произвольных closures.

**D3 — states влияют на ранние transactions.** `applyStateTransitions` (`Runtime.ts:1521–1596`) сначала вызывает `applyDeferred`; transitions обходятся в machine definition order. Exit/transition failure возвращает queued transition; successful earlier handler writes сохраняются. Enter failure происходит после current-state commit и transition-event publication, не возвращает old state. Pending transitions, созданные handlers, относятся к следующему marker. Whole-marker/schedule rollback не является reference contract. Relation failures также отдельный stream после structural application: не смешать их с `SystemFailure`.

**D4 — restore влияет на identity и visibility.** `snapshot` сохраняет entities/relations/non-transient resources/current machines и allocator progress, но не services, closures, reader positions или runtime queues. Значения shared, поэтому JSON round trip нужен для независимого save. `restore` validates before mutation, очищает pending commands/machines/events/transition/relation-failure streams и выполняет despawn/spawn lifecycle. Он не создаёт новый Runtime и не очищает system slots: не утверждать full runtime recovery/reset всех cursors. Fields ресурсов/machines вне snapshot не объявлять сброшенными: apply пишет только validated entries. Условия свежести старых handles после restore требуют отдельного решения до универсального world-scoped API.

Эти записи — ограниченные decisions/blockers, а не одобренные новые законы или полная спецификация поздних edge cases. Если требование невыразимо, T12 redesign открывается сразу; implementation/proof acceptance остаётся заблокированным.

## T12 evidence overlay (2026-10-03)

[T12 redesign checkpoint](../t12-redesign-decision.md) фиксирует T03 constructor
capability bypass: report завершён, authority gate FAILED. Статусы каталога выше
не превращаются в runtime passes. Ordinary proof/simulation specification ждёт
capabilities и #10/#11/#12; next action — локальный R-A provider probe для review.
Relations/scopes, states, validation/restore/tooling и copied canonical-defense
сохраняют return conditions выше, дополненные [F07–F11](../follow-ups.md).
Runtime refinement и mandatory final native/JS performance остаются отдельными gates.

## Current parity checkpoint — 2026-10-06

This section supersedes the historical status columns above for current planning.
The full contract remains [SPEC](../SPEC.md) / GitHub #1. **No full-core row is
accepted merely because a historical probe or a bounded ticket closed.**

Status vocabulary: **Public bounded** means the current application API has
source-bound executable evidence; **Experimental** means separate probe/runtime
closures have evidence that must be integrated and replayed; **Not delivered**
means no complete executable package for that capability is recorded. A mixed
row names both. None of these labels implies universal proof, production adoption
or full performance qualification.

| Core capability / parent user stories | Current status and evidence | Remaining acceptance work |
| --- | --- | --- |
| Identity, reservation, liveness (1–2,15) | Public bounded: shared affine Factory, pending/dead/foreign rejection; foreign commands leave queue unchanged [#26](../reports/user-system-api.md) | Independent-root authority, capacity/growth, exhaustion and restore identity policy; current monotonic IDs stop at131072 |
| Components, tags, bundles (3,31–32) | Public bounded: independent typed families, Data and actual affine Array owners, trusted population/cleanup [#26](../reports/user-system-api.md) | General reusable bundle/provisioning contracts, broader payload/recovery boundary, optimized scalable storage integration Owning published slices: #41/#46/#47/#52. |
| Schemas and features (4–5,33) | Public bounded nominal schema separation and caller-defined stores; fragments/features not delivered | Feature composition, requirement dependencies and duplicate rejection through public application use; ergonomics decisions use independent applications |
| Queries and order (6,16) | Public bounded heterogeneous queries, required/optional/with/without combinations, aliases and ascending order [#27](../reports/query-composition.md); count/single/entity lookup and exact diagnostics delivered [#29](../reports/public-query-contract.md) | Selected optimized storage delivered [#30](../reports/p-compose-storage-completion.md); scaling, qualified performance and broader full-core contracts remain |
| Declared access (7–8) | Public bounded: actual undeclared access, cross-schema and writes-through-read negatives [#26/#27](../reports/query-composition.md) | Preserve these controls on every extension; trusted provisioning is not universal malicious-root authority |
| Resources and Local (9) | Public transactional resources and isolated affine per-instance Local [#36](../reports/public-local-owner.md), including approved persistence on failure, skip and disposal | General runtime captures, destructive Type/IO recovery and broader integration |
| Host services and provisioning (10) | Experimental requirement/service traces [T09](../../experiments/t09/README.md), joined host [#19](../reports/s-integrate-completion.md) | General public requirements, nested unions and pre-execution rejection; services remain outside ECS rollback |
| Repeatable systems (11) | Public bounded closed rank2 runners with affine indexed Registry, retry and namespace checks [#26](../reports/user-system-api.md) | Ownership-preserving runtime affine captures and registration/disposal lifecycle; general extensible schedules Owning published slices: #50/#51. |
| Schedules/phases/conditions/nesting (12) | Public static typed phases, authored order, conditions, explicit barriers, failure/repeated runs and identity checks [#33](../reports/public-schedules.md) | Nested schedules and requirement unions (#34), transactional reader composition (#35), runtime heterogeneous captures |
| Deferred commands/barriers (13–14) | Public bounded explicit World.barrier, queued spawn/insert/remove/despawn and cleanup [#26/#27](../reports/query-composition.md) | Preserve full contracts across schedules, relations, states and restore; generic bundle and allocation policies |
| Added/changed (17) | Public bounded typed stamps, composable lifecycle selection, independent transactional post-success reader cursors [#27](../reports/query-composition.md) | Reader disposal/epochs, broader integrated schedules and scalable indexes; full reference lifecycle coverage |
| Removed/despawned streams (18) | Public registered ordered removal/despawn streams after barriers, independent slow readers, skip/failure backlog, disposal and affine cleanup [#32](../reports/public-removal-readers.md) | Composition through schedules (#35), broader lifecycle/identity coverage and full-core qualification |
| Events/retention/lag (19–21) | Public registered Data event readers, bounded retention/lag, lazy registration, disposal, exact skip/failure/retry semantics and stored values [#31](../reports/public-event-readers.md) | Composed reader scheduling (#35), affine message fan-out and full-core qualification; no final Data-only restriction Owning published slices: #53. |
| Transactions/publications (22–24) | Public bounded whole-query transaction, full Array replacement rollback, earlier commits and retry retained [#26/#27](../reports/query-composition.md); Experimental joined trace [#19](../reports/s-integrate-completion.md) | General recoverable Type operations, Local/allocation/lifecycle integration, machine queues, source-current complete connected gates and universal refinement |
| Relations/inverses/hierarchy (25) | Not delivered | Public source/target links, inverse consistency, deferred failure publication, deletion cleanup, cycles and observable order Owning published slices: #42/#43/#44. |
| Lifetime scopes (26) | Not delivered | Scene/group cleanup with persistent entity preservation and relation/lifecycle consistency Owning published slices: #45. |
| States/machines/transitions (27) | Not delivered; upstream failure order documented in D3 above | Component states, machine queues and ordered exit/transition/enter handlers; distinct failure and publication boundaries Owning published slices: #47/#48/#49. |
| Validation/typed input errors (28) | Not delivered as general public boundary | Reject malformed constructed/raw inputs without partial mutations; payload ownership and typed diagnostics Owning published slices: #46. |
| Snapshots/restore (29) | Not delivered; reference boundary documented in D4 above | Save supported fields, validate before restore, preserve explicit omissions; identity, allocator, streams/queues/cursor effects Owning published slices: #58/#59/#60. |
| Inspectors/debug (30) | Not delivered | Read-only observations without consuming system visibility or retaining events; optional debug overhead measured Owning published slices: #54/#55/#56/#57. |
| Performance/memory/scaling (35–37) | Experimental optimized Dense cohorts [latest Native1024](../reports/native1024-continuation.md); Public bounded Workshop baseline gate [#28](../reports/performance-regression.md) | #21/#23/#24: full source-current connected gates, five workloads×three sizes, equal timed work/forcing, occupancy, memory, noise/resolution; JS/TS<=1 and Native/TS<=0.5 |
| Laws/proofs/refinement (38–40) | Seven exact approved observation subjects delivered with proof/mutation gates [#18](../reports/p-observe-completion.md); older proposal withdrawn | 22 supporting candidates remain unapproved; broader exact laws require drafting/falsification/approval before proof. Current general API and backend refinement are not proved by #18 Owning published slices: #62. |
| Fixed-step console simulation (41) | Experimental integrated traces; public movement/damage/rollback Workshop and independent consumer [#26/#27](../reports/query-composition.md) | Complete intended spawn/move/damage/removal/hit/death simulation through integrated public contracts; proof and performance prerequisites remain explicit Owning published slices: #63. |
| Copied Canonical Defense (42–43) | Not started; canonical jev unchanged | Establish required capabilities, run a separate copy preserving authoritative reducer, compare fixed-step behavior/order/links/cleanup Owning published slices: #64. |
| Follow-up completeness (34) | Historical [follow-ups](../follow-ups.md) and current evidence retained | Reviewed tracer-bullet tickets with true blockers for remaining rows; no postponed row disappears from #1 Owning published slices: #61. |

### Performance preservation for parity work

Approved policy: **no statistically confirmed slowdown** against the fixed
Workshop baseline; its bounded contract has no small percentage allowance. The
user separately permits up to10% aggregate loss at full parity, with final
JS<=TS and Native<=0.5TS; this does not change the bounded gate. Run the
[#28 paired gate](../../benchmarks/README.md) for executable public-core changes.
This protects existing work, including process startup/output, and does not cover
new capabilities or the optimized five-by-three matrix. New feature slices must
add exact equal-work TS/JS/Native observations and representative feature timings;
no historical baseline is invented for functionality that did not exist. New
numerical thresholds, dependencies and specific laws require their own approvals.

The fast public Workshop ratios are not interchangeable with large optimized
Dense ratios. The latest reviewed concrete-v3 Native1024 raw cohort is about1.92×
faster than TS and therefore misses the approved2× target. No favorable subset
or timing-control run closes #21/#24 or full-core #1.

### Published implementation frontier

The user approved publication on 2026-10-06 after Astra review. See the
[breakdown and retained later scope](../design/parity-ticket-breakdown.md).

| Issue | Vertical slice | Current status / dependency |
| --- | --- | --- |
| #29 | Public query cardinality and exact entity lookup | Closed; delivered on master in [bfb4360d](https://github.com/dearlordylord/bendvy/commit/bfb4360d), with fresh semantic/timing evidence and independent review |
| #30 | Public Compose on exact optimized owned storage | Closed; restored selected source passes bounded TS criterion, unchanged default gate and independent reviews; [completion](../reports/p-compose-storage-completion.md) |
| #31 | Registered event readers, retention and lag | Closed; delivered on master in [bfb4360d](https://github.com/dearlordylord/bendvy/commit/bfb4360d), with fresh semantic/timing evidence and independent review |
| #32 | Registered removal/despawn readers | Closed; delivered on master in [bfb4360d](https://github.com/dearlordylord/bendvy/commit/bfb4360d), with fresh semantic/timing evidence and independent review |
| #33 | Basic deterministic phases/conditions/barriers | Closed; delivered on master in [bfb4360d](https://github.com/dearlordylord/bendvy/commit/bfb4360d), with fresh semantic/timing evidence and independent review |
| #34 | Nested schedules and checked requirement unions | Prerequisite #33 delivered; not started |
| #35 | Transactional reader visibility in schedules | Prerequisites #31/#32/#33 delivered; not started |
| #36 | Per-system affine Local lifetime/retry/disposal | Closed; delivered on master in [bfb4360d](https://github.com/dearlordylord/bendvy/commit/bfb4360d), with fresh semantic/timing evidence and independent review |

Six bounded slices (#29/#30/#31/#32/#33/#36) are delivered and closed. #30 retains complete indexed owner/capture/provider controls and the unchanged default regression pass. Under the explicitly amended bounded TS criterion, selected Workshop JS/TS is 0.548940 and Native/TS is 0.072534. Historical failed Bend comparisons remain unchanged. See [completion](../reports/p-compose-storage-completion.md) and [acceptance ledger](../reports/parity-frontier-implementation.md).

#34/#35 are ready next slices. Remaining full-core capabilities now have [published vertical slices #38–#64](../parity/README.md) under [remaining-core specification #37](../parity/remaining-core-spec.md): features/bundles, relations/hierarchy, lifetime scopes, states/machines, validation, snapshots/restore, inspectors, allocator/root policies and general payload/capture recovery. Specific proof and copied-integration execution tickets follow their explicit subject/requirements decisions; those obligations are retained. Full parity is not reached by completing the immediate eight-ticket frontier.

Existing #21/#23/#24 retain optimization/qualification responsibility; feature
slices do not duplicate those tasks or blanket-block independent feature work on
final performance. Later rows remain full-core obligations with return conditions,
not completed capabilities. Platform adapters, a schema generator and parallel/GPU
orchestration remain separate revisit items, not hidden core parity blockers.

Full-parity performance clarification: the user permits up to10% aggregate loss after all features, with final JS<=TS and Native<=0.5TS retained. See SPEC; this does not amend the existing bounded #28 contract or qualify current intermediate providers.
