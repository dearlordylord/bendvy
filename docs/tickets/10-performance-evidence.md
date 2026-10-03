# T10: Сопоставимые native/JS benchmarks

**Status:** опубликован, `ready-for-agent`. [GitHub #11](https://github.com/dearlordylord/bendvy/issues/11).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Разработчик воспроизводимо сравнивает bevy-ts с native и JS экспериментальным ECS на одинаковых операциях и видит стоимость traversal, updates, churn, readers и rollback.

## Acceptance criteria

- [ ] Результаты всех измеряемых workloads предварительно совпадают по наблюдениям; benchmark не упрощает semantics ради выигрыша.
- [ ] Входы и среды закреплены; compilation/checker/setup отделены от исполнения; worker count, JS warmup, повторения и разброс опубликованы.
- [ ] Есть sparse/dense traversal, updates, structural churn, event reads и rollback на нескольких размерах; измерение памяти описывает метод и ограничения.
- [ ] Численные критерии native significant speedup и JS comparability предложены с обоснованием для согласования; performance requirement не отменено.
- [ ] Отчёт не требует уже готового full-core engine. Медленный prototype не скрывается: записаны конкретные проблемы, альтернативы и что это блокирует.
- [ ] Микронагрузки не используются как доказательство окончательного performance acceptance; полные workload gates остаются follow-up.


## Blocked by

- T04: Affine payload без потери владения
- T05: Reservation, lookup и явный structural barrier
- T06: Успешный commit и failed-system rollback
- T07: Два event reader, retry и retention
- T08: Независимые change/removal observations

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
