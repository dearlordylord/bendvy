# T03: Повторяемая типобезопасная query на двух мирах

**Status:** опубликован, `ready-for-agent`. [GitHub #4](https://github.com/dearlordylord/bendvy/issues/4).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Две разные маленькие схемы выполняют несколько шагов чтения и обновления Data-компонентов через узкий API; запрещённый доступ невозможно проверить успешно.

## Acceptance criteria

- [ ] Публичный экспериментальный API повторно исполняет систему с read-only и writable компонентами; итог совпадает с соответствующим reference trace.
- [ ] Вторая schema отличается составом компонентов, а не только именем; между схемами нельзя подменить component token.
- [ ] Незаявленный доступ, cross-schema misuse и запись через read отвергаются по намеренной причине; каждое отрицательное fixture имеет положительный control.
- [ ] Владение storage сохранено, runtime результат подтверждён native/JS; whole-world access не выдаётся вместо declared capabilities.
- [ ] Пробы и кандидатные гарантии помечены экспериментальными; candidate laws формулируются до proofs, сохраняются для общей falsification/review.


## Blocked by

- T01: Воспроизводимый native/JS и proof canary
- T02: Карта core и reference traces

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
