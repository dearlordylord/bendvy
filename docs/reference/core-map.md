# T02 — полный core: catalogue и gates

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

## Current executable evidence checkpoint

The catalogue above records T02's original source-only status. Current bounded
reports are linked below; passing a probe does not mark its full core row complete.
See [next checkpoint draft](../next-core-checkpoint.md) before selecting a production
API/storage or publishing further implementation/proof packages.

| Core seam | Current bounded evidence | Remaining full-core gate |
| --- | --- | --- |
| Schema/query/capabilities | R-A and R-C1 abstract providers, two schemas and negative controls | General captured systems, schema composition, authority/refinement and integrated scalable storage |
| Data/Type payload | T04 owned array; T06 reversible owned U32 fields | Generic affine restoration, captured/IO payloads and scalable cost |
| Identity/deferred commands | T05; approved foreign-world MissingEntity divergence | Runtime-owned namespace, generation/exhaustion/restore, general bundles and indexed bounds |
| Transactions/publication | T06 prior commits, inverse rollback and staged events/commands | Allocation/mark/local/cursor rollback in an integrated provider/schedule runtime |
| Messages | T07 independent readers, skip/failure, retention/capacity/lag | Generic affine fan-out, reader authority/lifecycle, epochs and scalable layout |
| Changes/removals | T08 independent marks/positions; retained deletion records; individual capacity | General Type marks, sparse indexes, identity/provider/schedule integration and refinement |
| Schedule/provisioning | T09 closed nested callbacks with typed failure | Captured Local, conditions/phases/features/requirement unions and lifecycle |
| Performance | T10 reproducible finite prototype comparison; storage redesign required | Native substantial speedup and JS comparability on approved representative workloads/thresholds |
| Laws/refinement | T11 historical 14-law helper/model controls; public proposal withdrawn after source audit | Connected transition/admissibility package, meaningful falsification, exact approval, general proofs and runtime correspondence |
| Relations/scopes | Retained core, no executable gate completed | Identity/transaction/reader integration, inverse/cleanup/cycle/order scenarios |
| States/transitions | Retained core; only state skip used in TS adapters | Explicit exit/transition/enter failure boundaries and queue/publication laws |
| Validation/snapshots/inspectors/debug | Retained core, no executable gate completed | Payload/identity restoration boundary, validation-before-mutation and observation noninterference |
| Copied Canonical Defense | Not started; original jev untouched | Integrated simulation plus the remaining core contracts actually used by the copied application |
