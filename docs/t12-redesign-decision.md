# T12 / #13: authority redesign checkpoint

Дата: 2026-10-03. Base: `f754d45679b8d0b77a6ae5686344b9dbe734b649`.
Источники: [issue #13](https://github.com/dearlordylord/bendvy/issues/13),
[parent #1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](SPEC.md),
[T03 negative report](../experiments/t03/README.md), [core catalogue](reference/core-map.md).

**Локальный кандидат для рассмотрения человеком; не опубликованные новые tickets,
не approval законов и не разрешение implementation. Выбрана только redesign-ветка.**
Готовый отрицательный T03 report открывает её без ожидания #10–#12.
Обычная proof/simulation specification остаётся заблокированной их evidence и
остальными required capabilities. Полный core остаётся целью, parent не меняется.

## Evidence ledger

Статусы ограничены содержимым этого Base и повтором T03 в этой задаче. OPEN issue
не доказывает отсутствие внешних результатов; перед следующим checkpoint следует
забрать новые интегрированные reports. Чужие passes не являются acceptance T12.

| Развилка | Доступное evidence | Outcome / незавершённый gate |
|---|---|---|
| Toolchain | [T01](../experiments/t01/README.md) elementary true/false и native/JS canary | Infrastructure smoke только; совместимость automated falsifier не установлена |
| Schema/access | T03: прямые undeclared/read-write/cross-schema negatives отвергнуты с positive controls; `forge.bend` принят и печатает 99 | Завершённый отрицательный report; authority gate FAILED. Это constructor-API counterexample, не невозможность Bend |
| Data/Type | T03: affine Type world, U32 Data fields, closed system templates, три исполнения на каждой из двух схем | Бounded успех; affine Type **payload**, captured state и ownership-safe rollback ещё не проверены; Data-only не одобрено |
| Storage/query | Одна явная строка на схему; TS/native/JS final outputs `6,2` и `11,3,1` | Нет membership/traversal architecture, optional/tag/order/intermediate R2 evidence; layout не выбран |
| Identity/commands | [R1 и D1](reference/core-map.md), source-derived descriptions | Runtime R1 отсутствует в worktree; reservation/live/stale/same-schema foreign world/exhaustion/restore решения открыты (#6) |
| Transaction | [R3/D2/D3](reference/core-map.md), source-derived | Нет исполненного rollback/read-your-writes/retry report (#7), включая affine payload и Local ownership |
| Readers | [R4/R5](reference/traces.md), source-derived | Независимые cursors, skip/failure/retention/removal gates не исполнены (#8/#9); единое правило skip неверно |
| Provisioning | [R6](reference/traces.md); #10 body прочитан, OPEN | Нет nested schedule/missing/incompatible provision execution report; closed T03 templates не покрывают #10 |
| Performance | #11 body прочитан, OPEN; T03 compilation/runtime разделены, timings не измерены | Нет equivalent workloads/memory/scaling; native/JS capability и final acceptance открыты |
| Laws | [T03 candidates](../experiments/t03/CANDIDATE-LAWS.md); #12 body прочитан, OPEN | Authority confinement falsified; остальные не approved, finite examples не universal proofs; первого полного пакета #12 здесь нет |

## Минимальное решение и запрос пользователю

Не продвигать exported-constructor API в public authority boundary. `bad(ReadMotion)`
может прочитать вход и изготовить `WriteMotion`; signature не ограничивает полученную
власть. Это не демонстрирует запись в независимо хранимый world, но достаточно,
чтобы отвергнуть этот способ выдачи grants. Не требуется доказывать заведомо ложный
confinement law или ждать benchmarks для данного решения.

Сначала исследовать безопасную provisioning boundary без доступного приложению
live constructor. Base opaque IO declarations — prior art, не доказательство, что
user-defined provider выразим. Не использовать unsafe/foreign или unfilled laws
как authority escape hatch. Если provider не получается, сравнить checked,
schema-indexed action representation, исполняемую trusted orchestration. Это
альтернатива для оценки, не молчаливая замена произвольных callbacks.

**Точный specification request, pending:** если безопасный callback/provider путь
не установлен, разрешает ли контракт System checked action representation вместо
произвольного callback, при сохранении declared access, repeated execution,
affine payload, transactions и provisioning? Или требуется compiler-level opacity
с отдельным language blocker? Evidence R-A/R-B ниже должно предшествовать выбору;
этот документ не фиксирует ответ. Approval зависимостей и новых конкретных законов
запрашивается отдельно, когда известен exact набор. Никаких зависимостей не добавлено.

## Следующее tracer-bullet разбиение для человеческого review

Это локальные package IDs, не GitHub issues и не ready-for-agent proof tickets.
Публикация coordinator допускается только после того, как человек рассмотрит этот
документ. Каждый пакет помещается в отдельный fresh context: SPEC, T03 report,
только его fixtures и короткий report. При необходимости второй representation
или несколько независимых failure boundaries выделяются в отдельные пакеты.

| Package | Узкий результат и acceptance | Реальные blocking edges |
|---|---|---|
| R-A: provider expressibility | Один safe provider + один read/write callback на Motion; повторить три раза. Direct negatives с парными positive controls и **reconstruction bypass** должны отвергаться по intended type boundary. Native/JS exact checkpoints. Если не проходит: сохранить минимальный counterexample/diagnostic и предел вывода, а не pass | Начинается по T03 negative report; нет зависимости от proofs/benchmarks. API выбор ещё не разрешён |
| R-B: action alternative | Только если R-A отрицателен/недостаточен: two schema-indexed declarations, read/update actions, controlled interpreter. Undeclared/cross-schema/write-through-read и fabrication controls; Type payload consume/return и repeated execution. Записать, какие callbacks/captures ещё не представлены | R-A report; продуктовая замена callbacks ждёт explicit specification decision; новые dependencies ждут approval |
| R-C: authority integration checkpoint | Выбранный человеком вариант повторяет full R2 public checkpoints, затем storage/affine payload, identity, failed-system rollback, readers и nested provisioning в отдельных исходных probes #5–#10. Нет unconditional whole-world access; host IO вне rollback | R-A safe result либо R-B + explicit decision; R1–R6 execution и D1–D4 решения по соответствующим пакетам. Отрицательный report снова открывает redesign |
| R-D: ordinary specification return | Собрать #10/#11/#12 и все capability reports; выбрать concrete functions/representations; показать человеку finite law sets, refinement boundaries, controls, proof sketches и actual dependency edges. Только затем публиковать отдельные proof tickets и simulation specification | Capability gates R-C; comparable benchmark report #11; candidate/falsification package #12; approval exact laws до любого proof |

R-A/R-B — probes, **не proof tickets**. Сегодня отсутствуют concrete выбранные
identity/query/command functions и approved laws; выдумывать их ради заполнения
proof шаблона нельзя. Следовательно executable/model proofs здесь не начаты.
R-D обязан отделить: (1) model theorem, (2) theorem исполняемой pure функции,
(3) finite public trace comparison, (4) universal runtime refinement. Для модели
нужны допустимые states и mapping runtime→model, initial correspondence,
preservation каждого публичного transition и agreement observations; unsafe/foreign
и backend assumptions записываются отдельно. Совпадение R1–R6 не закрывает (4).
Непроверенный refinement сохраняется gate доказанного runtime API. Mutant должен
компилироваться, иметь true-on-original/false-on-mutant input и ломать нужный закон;
checker/verdict и mutation checks ограничены 5 s, skip/error не считается pass.

## Simulation и performance: условия возврата

Simulation implementation **заблокирована** authority/storage/identity/transaction/
reader/provisioning capabilities, approved specific laws и соответствующими proof/
refinement gates. Документ не открывает её. R-D должен задать фиксированный шаг,
точные начальные entities/resources, команды по tick, move/damage arithmetic,
барьеры, fail/retry и читателей; expected ordered live rows, pending handles,
hit/death events, typed failures и cursor observations на каждом checkpoint.
Обязательные сценарии: spawn pending→barrier→live, движение, nonlethal/lethal damage
и removal, failed system после предыдущего commit, retry без потери events,
different-rate readers. Конкретные числа/outputs сейчас не утверждаются: они
зависят от ещё не выбранных representation и arithmetic contracts. Acceptance:
replay одинаковых входов TS/native/JS даёт согласованные deterministic observations,
без скрытого flush/rollback; intentional divergences требуют отдельного решения.
Это условия будущей спецификации, а не выполненная ordinary-ветка T12.

Native substantial speedup и JS at least comparable остаются mandatory.
**Численные thresholds pending, не предложены и не согласованы.** После #11
показать per-workload ratios/variability и предложить native minimum speedup,
JS tolerance, масштаб/память и правила материальных regressions для approval.
Sparse/dense traversal, updates, churn, readers и rollback выполняют одинаковую
логическую работу; compilation/checker/setup отделены, workers/warmup/repeats
фиксированы. Медленный prototype — evidence для optimization/redesign, не отмена
требования. Даже approved prototype thresholds не закрывают final representative
full-core performance gate.

## Полная цель и follow-ups

[Core map](reference/core-map.md) сохраняет каждый контракт; новые зависимости
этого checkpoint записаны в [follow-ups F07–F11](follow-ups.md).
Relations/inverses/hierarchy/scopes ждут identity, barriers и lifecycle streams;
states ждут transaction/publication boundaries, nested schedules и уточнения D3;
validation/restore/tooling ждут ownership, D1/D4 и independent reader visibility.
Ни один из этих обязательных core блоков не исключён отрицательным T03 outcome.
Copied canonical-defense ждёт работающий headless slice и именно используемые им
links/resources/order/cleanup capabilities, затем отдельную integration
specification с preserved `Canonical.step`. Оригинальные jev/dalph не изменяются;
перенос reducer — отдельный условный F06 после F02.

## Evidence и пределы этой задачи

Read-only GitHub: `gh issue view {1,13,10,11,12} --repo dearlordylord/bendvy --json ...`;
прочитаны SPEC, T01/T02/T03 reports, candidates, core-map, traces и follow-ups.
`bend version` → 2.0.34; `bend guide` прочитан, без изменения Bend файлов.
`./experiments/t03/run.sh` повторяет controls и compiled native/JS/Node adapter,
сверяет три HEAD с [.references/sources.json](../.references/sources.json) и Base
hash; каждый checker/build ограничен 5 s. Ожидаемый результат: exit 0,
`6,2`, `11,3,1`, `99`, `T03 capability gate FAILED`. Этот повтор проверяет trigger
redesign, не превращает прежние результаты в новый capability acceptance.
Документационные links и `git diff --check` проверяются перед commit.

Новые proof/simulation tickets не опубликованы; документ предоставляется человеку
через task candidate, не считается рассмотренным/одобренным по факту commit.
Нет изменения master, parent, DALPH.md, claims, references, original canonical-defense
или dependencies. Dalph-related проблем не наблюдалось. Ordinary acceptance T12
остаётся условной и неполной; результат этой задачи — bounded redesign candidate.

## R-C1 evidence update (2026-10-03)

[R-C1](../experiments/rc1-query/README.md) now supplies bounded abstract query
integration on two distinct component compositions, including full post-setup R2
ordered public checkpoints, 28 paired type controls and a compiling detected
mutant. This is a candidate experimental return gate, subject to independent
coordinator verification. It does not select production storage/API, approve laws,
close affine Type payload/identity/transaction/reader/schedule/refinement or
performance gates, or reopen simulation implementation without those prerequisites.
See the [updated evidence map](follow-ups.md#r-c1-bounded-query-evidence-2026-10-03).
