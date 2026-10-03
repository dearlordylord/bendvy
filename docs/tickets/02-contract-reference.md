# T02: Карта core и reference traces

**Status:** опубликован, `ready-for-agent`. [GitHub #3](https://github.com/dearlordylord/bendvy/issues/3).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Можно увидеть все обязательства полного core и воспроизвести небольшие эталонные сценарии bevy-ts, которые будут сравниваться с Bend.

## Acceptance criteria

- [ ] Каждая core-область из parent покрыта строкой карты: contract/source, статус, следующий этап и условие возврата; platform tracking отделён.
- [ ] Нормализованные наблюдения не зависят от физического storage или encoding ID; включают liveness, membership, порядок, публикации, failure и состояние.
- [ ] Подготовлены эталонные trace descriptions для reservation/flush, component read/update, rollback, независимых readers и provisioning; неоднозначности подкреплены upstream evidence.
- [ ] Поздние relations/states/snapshots зафиксированы до уровня влияния на ранние контракты; это не полная спецификация всех поздних edge cases.
- [ ] Запуск TS reference выполняется лишь после согласования необходимых зависимостей; неполученные наблюдения явно помечены и блокируют соответствующие downstream acceptance.


- [ ] Карта ограничена catalogue уровня всей цели и шестью ближайшими reference traces; полный harness поздних core-сценариев не реализуется в этом тикете.

## Blocked by

None (can start immediately).

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
