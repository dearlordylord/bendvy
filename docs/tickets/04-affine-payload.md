# T04: Affine payload без потери владения

**Status:** опубликован, `ready-for-agent`. [GitHub #5](https://github.com/dearlordylord/bendvy/issues/5).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Установлено, как тот же экспериментальный ECS принимает компонент с owned array и читает/изменяет его, либо получен минимальный воспроизводимый отказ, объясняющий границу поддержки.

## Acceptance criteria

- [ ] Проверены Data payload и Type payload с owned array; kind storage отличён от kind component value.
- [ ] После нескольких обновлений наблюдаемое содержимое ожидаемо; повторный вызов, read semantics и ownership документированы на native/JS.
- [ ] Без unsafe aliasing или casts исследованы swap/take/traversal варианты; closure/IO-handle payload не объявлены поддержанными из одного array-примера.
- [ ] Невозможность выразить нужный API оформлена как evidence и решение для пользователя, а не молчаливый Data-only scope.
- [ ] Стоимость потенциального клонирования фиксируется для benchmark; F05 получает конкретный результат/условие следующей проверки.


## Blocked by

- T03: Повторяемая типобезопасная query на двух мирах

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
