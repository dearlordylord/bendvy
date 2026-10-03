# T01: Воспроизводимый native/JS и proof canary

**Status:** опубликован, `ready-for-agent`. [GitHub #2](https://github.com/dearlordylord/bendvy/issues/2).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Разработчик запускает один маленький чистый пример в native CPU и JS и проверяет известную истинную и ложную claim; окружение и способ проверки воспроизводимы.

## Acceptance criteria

- [ ] Зафиксированы Bend/Base, native toolchain, JS runtime, команды запуска и worker count; guide прочитан для выбранной версии.
- [ ] Один вход даёт одинаковое наблюдение native/JS; checker ограничен 5 s, false claim отвергается, verdict проверен.
- [ ] Совместимость falsification/mutation tools проверена либо явно описана; skipped/error не считаются успехом. До новых зависимостей запрашивается отдельное согласование.
- [ ] Это smoke/canary инфраструктуры, не доказательство ECS или утверждение performance.


## Blocked by

None (can start immediately).

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
