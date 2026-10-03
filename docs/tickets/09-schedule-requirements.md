# T09: Вложенный schedule с provisioning и failure

**Status:** опубликован, `ready-for-agent`. [GitHub #10](https://github.com/dearlordylord/bendvy/issues/10).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Повторно запускаемый вложенный schedule получает объявленные resource/service requirements и возвращает ожидаемый typed system failure без выдачи лишнего доступа.

## Acceptance criteria

- [ ] Есть один корректно обеспеченный schedule и controls с missing/incompatible provision; static/dynamic граница зафиксирована по evidence.
- [ ] Вложенность сохраняет порядок и требования; ошибка не теряет identity system и не требует безусловного whole-world access.
- [ ] Host service interaction не обещает ECS rollback внешних эффектов.
- [ ] Публичный пример исполняется native/JS; ограничения affine callbacks и repeated execution проверены.
- [ ] Это минимальная композиция, не полное покрытие fragments/features/phases/conditions.


## Blocked by

- T03: Повторяемая типобезопасная query на двух мирах

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
