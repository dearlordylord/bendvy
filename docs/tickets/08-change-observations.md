# T08: Независимые change/removal observations

**Status:** опубликован, `ready-for-agent`. [GitHub #9](https://github.com/dearlordylord/bendvy/issues/9).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Две системы с разной частотой независимо наблюдают added/changed и removed/despawned в маленьком сценарии; пропуск и failure не смешивают жизненные циклы с buffered events.

## Acceptance criteria

- [ ] Добавление и обновление компонента видны каждому reader ровно по reference-позиции; отсутствие structural marker не подменяет commit visibility.
- [ ] Removal/despawn observations доступны после исчезновения сущности и независимы между readers; retention/lag сверены с соответствующим upstream контрактом.
- [ ] Failed reader сохраняет позицию; skip правила проверены именно для change/lifecycle, а не перенесены из event stream автоматически.
- [ ] Native/JS наблюдения совпадают с нормализованным TS reference; controls различают message cursor и change tick.
- [ ] Candidate guarantees и границы доказуемого слоя записаны; это не proof universal refinement.

## Blocked by

- T06: Успешный commit и failed-system rollback

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
