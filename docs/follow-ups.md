# Bendvy: отложенные задачи

Черновик. Каждое принятое упрощение получает запись здесь; завершённое отмечаем со ссылкой на проверку. Открытый вопрос не считается согласованным упрощением.

| ID | Сейчас | Follow-up | Когда вернуться | Статус |
|---|---|---|---|---|
| F01 | Явные типы и состав мира без DSL/генератора | Оценить повторяющиеся декларации на двух схемах; решить, нужен ли schema DSL/генератор | После проверок выразимости и второго сценария | Отложено |
| F02 | Простая симуляция в репозитории | В отдельной копии canonical-defense проверить ECS для игровых сущностей/систем, сохранив reducer; оригинальный jev не менять | После рабочего headless-среза и необходимых ему ECS-возможностей | Отложено |
| F03 | Консольный CPU-сценарий | Определить нужные host/input/render adapters для canonical-defense | При планировании внешней интеграции | Отложено |
| F04 | Предлагается последовательный scheduler; решение ещё обсуждается | Оценить независимые workloads, безопасное разделение владения и пользу parallel compute | После воспроизводимых native CPU-замеров | Открыто |
| F05 | Представление компонентов и storage ещё не выбрано | Проверить Data и affine Type, стоимость traversal/update и совместимость rollback; выбрать границы API | До закрепления component/query/write API | Открыто |
| F06 | При внешней интеграции сохраняем Canonical.step | Решить, нужен ли перенос самого reducer в ECS; отдельная задача только при обоснованной необходимости | После результатов F02 | Отложено |

Достижение полного core отслеживаем отдельно таблицей паритета: последующие core-блоки не исчезают из цели. Численные критерии performance и критерии закрытия этих задач ещё обсуждаем.

## T12 negative-evidence checkpoint

[T12 redesign candidate](t12-redesign-decision.md) использует отрицательный T03 report;
новые package IDs пока локальные, до человеческого review не публикуются.

| ID | Сейчас | Follow-up / зависимости | Когда вернуться | Статус |
|---|---|---|---|---|
| F07 | Constructor-based authority falsified | R-A safe provider; при отрицательном outcome R-B checked action comparison и explicit System specification decision | До фиксации query/System/Schedule API и любых dependent proofs | Blocked capability; redesign открыт |
| F08 | Relations/scopes остаются core | Identity/commands + lifecycle/removal streams + authority integration; затем cleanup/inverse/cycle/order packages | После соответствующих capability reports, до copied integration | Обязательный поздний core |
| F09 | States остаются core; D3 влияет на ранний API | Transaction/publication + nested provisioning; exact exit/transition/enter failure boundaries и queue laws | При фиксации transaction API; full state package после capability evidence | Открыто |
| F10 | Validation/restore/inspectors/debug остаются core | Affine ownership + D1/D4 identity/restore + readers; noninterference и snapshot limits | До restore/tooling API; overhead затем в representative benchmarks | Открыто |
| F11 | Ordinary proof/simulation specification закрыта | R-C capability reports, #10/#11/#12; concrete law approval и отдельный runtime refinement gate; threshold approval для final performance | После evidence, новый человеческий review до ticket publication | Blocked; finite traces не заменяют refinement |

F02 дополнительно зависит от F08/F09/F10 в объёме реально используемых copied
canonical-defense контрактов: integration planning определяет этот объём после
headless simulation. Original jev/dalph остаются неизменны; F06 не разрешён автоматически.

## R-C1 bounded query evidence (2026-10-03)

[R-C1 report](../experiments/rc1-query/README.md) records this task's executed
62 ordered native/JS/Node-reference checkpoints and 28 paired type controls.
Subject to coordinator verification, the experimental two-schema typed-query/R2
return gate passes. This does not accept a production API, Data-only payloads,
universal confinement/refinement or performance. Historical T03 remains a failed
constructor-boundary design; R-A/R-C1 are separate bounded evidence.

| Gate / simplification | Exact new coverage | Remaining blocker / return condition |
|---|---|---|
| F07 authority integration | Abstract per-row read/write callbacks; two composed schemas; constructor, nested query/lookup, malformed returns and cross-schema controls | Broader callbacks/captures, language-wide confinement and approved laws; return before production API selection |
| F01/F05 storage/query | Fixed two-row ordered traversal; required/present/absent/optional and live-b mismatch/optional lookup; immediate and later reads across three steps | Affine Type payloads #5, identity/barriers #6, dynamic/scalable layout and update/rollback costs; fixed fixtures are not final storage |
| Closed callbacks / finite operations | Repeated closed Step templates; two separate affine readers before/after a write; no copied world/row/cell | Captured state, errors, general operation sequences and nested schedules/provisioning #10 |
| Transactions/readers | Only successful component-update visibility without structural flush | Rollback #7 and independent event/change reader gates #8/#9 unchanged |
| F11 proof/performance return | Finite runtime comparison and compiling no-update mutant; candidate statements recorded before proof | #11 representative performance and approved thresholds; #12 exact law approval; model/executable proofs and universal refinement absent |
| Full core F08/F09/F10, F02/F06 | No scope reduction or integration claim | Relations/scopes, states, tooling and copied canonical-defense retain their original prerequisites |

The original dependent probes #5, #6, #10 and #12 may resume only through the
coordinator's independently verified return decision. The parent remains open.

## T04 affine-payload evidence (2026-10-03)

F05 remains open. [T04 report](../experiments/t04/README.md) records freshly executed native/JS/TS observations: an affine Type Payload containing Array<U32> survives three updates through the R-C1 world; a Data record containing an owned array rejects at the kind boundary. Read callbacks receive a projection and an abstract handle, not a mutable owned-array alias. Separate affine-element swap/take/traversal controls work; closure/IO-handle payloads and rollback remain unestablished.

Return before selecting component/query/write APIs: establish general Type read/write and failure restoration contracts, measure scalable traversal and explicit cloning/copy costs on equivalent native/JS/TS workloads, and obtain approval of specific falsified laws and numerical performance thresholds. If retained no-copy `Cell & OwnedArray` reads are required, request a bounded redesign; rejection is not approval to adopt Data-only scope. Fixed rows/slot update and Data projection are experimental simplifications, not removal of the full core.

## T05 direct lifecycle return gate

[T05 report](../experiments/t05/README.md) passes the bounded lifecycle probe:
80 ordered native/JS/actual-reference observations, explicit approved foreign-ID
divergence, seven boundary scenarios, two paired intended-type controls and four
compiling mutants. T06 transaction and T11 candidate-law work may use this
experimental lifecycle surface; this is not production identity acceptance.

Return before production identity/storage selection: runtime-owned namespace
creation across independent bootstrap roots; general component/affine payload
commands; integration with actual typed schedules; declared structural authority;
scalable layout with explicit bounds before array access; reuse/generation and
exhaustion policy; representative performance. Linked-list traversal and decimal
keys are measured prototype costs, not waived performance requirements.

## T06 transaction return conditions

[T06](../experiments/t06/README.md) implements inverse-journal restoration for Data
component/resource writes and reversible U32 field writes into an owned Type
payload, staged event/command publications and preservation of earlier commits.
Keep separate return gates for generic affine element restoration, captured/IO
payloads, allocation/membership/change-tick rollback, integrated schedules and
scalable journal/layout cost. Fixed slots and two command-intent kinds are probe
boundaries, not full-core exclusions or approved proofs.

## T07 event-reader return conditions

[T07](../experiments/t07/README.md) passes 24 ordered native/JS/reference
observations and detects six compiling mutants. Preserve separate production
gates for generic keyed streams, reader lifecycle and declared authority, affine
message fan-out, captured callbacks, integrated schedules, clock exhaustion and
scalable retention costs. Public runtime retention and internal small-capacity
boundaries are distinct evidence; event skip does not advance change/lifecycle
positions. T08 establishes those positions separately.

## T08 change/lifecycle return conditions

[T08](../experiments/t08/README.md) passes 31 ordered native/JS/reference
observations and detects nine compiling mutants. Change/lifecycle positions are
independent of message positions; failure preserves both, skip advances messages
only. Singleton lifecycle log entries implement individual-record capacity.
Return before production API selection: general affine payload marks/restoration,
declared readers and reader lifecycle, integrated schedules/identity, scalable
sparse storage, allocation/tick rollback, nonwrapping epoch policy and refinement.
The Data row projection and trusted fixed-command driver do not approve Data-only
components or replace T04/T06 ownership evidence. T10 may now measure these
experimental paths; performance thresholds and exact laws still require approval.

## Current proof/performance checkpoint

[T10](../experiments/t10/README.md) keeps the mandatory performance target open:
current sparse/churn paths regress and require a bounded indexed/ordered storage
comparison. [T11](../experiments/t11/README.md) provides exact draft subjects,
falsification and correspondence obligations; no general ECS proofs are approved.
[Next checkpoint](next-core-checkpoint.md) retains full core and copied-integration
prerequisites. Earlier F07/F11 blocked entries describe the historical checkpoint;
provider probes now pass bounded gates, while general authority/refinement,
production layout, performance acceptance and simulation readiness remain open.


## T11 source-audit correction

[Luna research](reviews/laws-source-research.md) and [Astra decision](reviews/laws-decision.md)
adjudicate all fourteen candidates. Withdraw the old public ECS-law approval request;
retain d4a8510 equations and finite controls as historical/internal evidence. The
replacement must cover complete transitions, computed world/availability guards,
positive membership/lookup/reservation behavior, independent command semantics,
U32/admissibility and ownership-preserving runtime correspondence. Cursor helpers
remain distinct from transactional reader wrappers. Rust Bevy's order/deferred/
read-time cursor differences do not silently replace the agreed TS target.
