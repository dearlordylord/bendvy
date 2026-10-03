# T05: Reservation, lookup и явный structural barrier

**Status:** опубликован, `ready-for-agent`. [GitHub #6](https://github.com/dearlordylord/bendvy/issues/6).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Через экспериментальный API резервируется сущность, становится live лишь на marker, затем удаляется; lookup и query дают правильные результаты до и после каждого действия.

## Acceptance criteria

- [ ] Сценарий показывает pending spawn, live handle, stale и foreign handle; storage bounds проверяются до array access.
- [ ] Schedule completion не flush-ит pending commands; следующий schedule может применить их явным marker.
- [ ] Insert/remove/despawn и порядок query сохраняют ожидаемые наблюдения; reuse/exhaustion policy не выбрана без явного обоснования.
- [ ] Native/JS trace совпадает с TS reference после нормализации; reservation не трактуется как доказательство liveness.
- [ ] Кандидатные законы identity, membership и commands представлены с plain-language смыслом; proof ещё не пишется.


## Blocked by

- T03: Повторяемая типобезопасная query на двух мирах

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
