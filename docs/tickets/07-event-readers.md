# T07: Два event reader, retry и retention

**Status:** опубликован, `ready-for-agent`. [GitHub #8](https://github.com/dearlordylord/bendvy/issues/8).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Два независимо запускаемых event reader работают с разной частотой; failed reader повторяет чтение, skipped reader и overflow ведут себя по reference-контрактам.

## Acceptance criteria

- [ ] Один reader не расходует данные другого; commit event виден по reference-порядку без привязки к structural flush.
- [ ] Failed reader не продвигает cursor; skip rules различают messages и change detection.
- [ ] Retention/capacity/lag проверены на маленьких граничных входах; native/JS наблюдения сопоставлены с TS.
- [ ] Candidate laws ограничены buffered event readers; change/lifecycle observations — отдельный тикет, transition/relation streams остаются в карте core.


## Blocked by

- T06: Успешный commit и failed-system rollback

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
