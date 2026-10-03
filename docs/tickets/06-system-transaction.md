# T06: Успешный commit и failed-system rollback

**Status:** опубликован, `ready-for-agent`. [GitHub #7](https://github.com/dearlordylord/bendvy/issues/7).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Одна система сохраняет изменения; следующая читает собственные записи, повторно обновляет компонент/resource, создаёт event/command и падает. Снаружи остаётся только результат успешной системы.

## Acceptance criteria

- [ ] Раздельно наблюдаемы read-your-writes, successful commit и typed failure; earlier commits сохранены.
- [ ] Отменены ECS component/resource writes и pending публикации failed system; host IO явно вне транзакции.
- [ ] Проверен rollback для выбранного Data-пути и влияние Type-payload probe; если affine rollback не поддержан, это явное нерешённое ограничение.
- [ ] Чистая сигнатура функции не принимается за evidence rollback mutated arrays; strategy показана рабочим примером.
- [ ] Native/JS trace сопоставлен с TS; draft guarantees охватывают preservation и отсутствие публикаций, не rollback всей schedule.


## Blocked by

- T04: Affine payload без потери владения
- T05: Reservation, lookup и явный structural barrier

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
