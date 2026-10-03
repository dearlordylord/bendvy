# T12: Спецификация proofs и следующего этапа по evidence

**Status:** опубликован, `ready-for-agent`. [GitHub #13](https://github.com/dearlordylord/bendvy/issues/13).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Получив evidence ближайших проверок, пользователь получает следующую конкретную спецификацию и tracer-bullet разбиение: узкие proof/refinement packages и простая симуляция, либо ограниченный redesign-план для обнаруженного обязательного capability blocker.

## Acceptance criteria

- [ ] Результаты ранних развилок собраны: schema/access, Data/Type, storage, identity, transaction, readers, provisioning и performance. Экспериментальный успех отличён от завершённого исследования с отрицательным outcome.
- [ ] Каждый proof тикет имеет конкретные функции, конечный набор законов, representation/refinement boundary, controls, proof sketch и реальные blocking edges; пакет разделён, если не помещается в fresh context.
- [ ] Конкретные законы явно одобрены до начала proofs. Непроверенный runtime refinement не заменяется совпадением traces и остаётся gate для доказанного runtime API.
- [ ] Для простой симуляции определены наблюдаемые сценарии/входы/выходы и acceptance; начало реализации заблокировано необходимыми capability и proof gates, а не только наличием документа.
- [ ] Native/JS thresholds согласованы либо явно ожидают решения; окончательный performance gate сохраняется. Медленный prototype не трактуется как отмена native speedup/JS comparability.
- [ ] При отрицательном evidence определён минимальный redesign/specification decision и новые blockers; можно подготовить этот документ, не требуя сначала доказать невозможный путь.
- [ ] Общая карта core/follow-ups обновлена: relations/states/tooling и copied canonical-defense имеют зависимости и условия очередной детализации. Original canonical-defense не изменён, parent issue не закрывается и не переписывается.
- [ ] Следующее разбиение показано человеку до публикации; документ не даёт разрешения обойти незавершённые gate или автоматически уменьшить core scope.

## Blocked by

Ниже условные prerequisites обычной ветки proof/simulation specification. Redesign checkpoint открывается сразу по готовому отрицательному report; безусловных native blockers у GitHub issue нет. Обычная ветка ждёт перечисленного evidence.

- T09: Вложенный schedule с provisioning и failure
- T10: Сопоставимые native/JS benchmarks
- T11: Первый конкретный пакет законов и falsification

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
