# T11: Первый конкретный пакет законов и falsification

**Status:** опубликован, `ready-for-agent`. [GitHub #12](https://github.com/dearlordylord/bendvy/issues/12).

## Parent

https://github.com/dearlordylord/bendvy/issues/1

## What to build

Пользователь получает первый конечный пакет кандидатных законов для экспериментальных identity/query/commands: с объяснениями, falsification/control и эскизами proof. Пакет задаёт достаточно точные обязательства для спецификации отдельных proof-тикетов.

## Acceptance criteria

- [ ] Указаны конкретные функции/интерфейсы и конечный список general laws; проверены полнота membership, preservation и bounds, а не только soundness.
- [ ] Для каждой law указан предмет: исполняемая функция либо отдельная модель. Для модели заданы runtime-to-model mapping, допустимые состояния и обязательства correspondence/preservation переходов.
- [ ] Runtime traces — конечное test evidence, не universal refinement proof; недоказанный refinement не позволяет объявить runtime API доказанным.
- [ ] Falsification охватывает premises и границы, посаженный компилируемый дефект обнаруживается; skips/error/coverage gaps записаны, checker runs ограничены 5 s.
- [ ] У каждой law есть plain-language rationale, controls и proof sketch; dependencies proof пакета следуют именно используемым определениям и representation choices.
- [ ] Пакет представлен для явного approval; при требуемом пересмотре типов/storage ожидается соответствующее evidence, а не blanket approval.
- [ ] Законы transaction/readers/provisioning подготавливаются по готовности их собственных модулей, без общей блокировки benchmark; их точные review/proof тикеты оформляются следующим checkpoint. Нынешний тикет не пишет proofs и не превращает неопределённые пакеты в ready-for-agent задачи.

## Blocked by

- T02: Карта core и reference traces
- T03: Повторяемая типобезопасная query на двух мирах
- T05: Reservation, lookup и явный structural barrier

## Outcome gates

Исследование может завершиться воспроизводимым отрицательным результатом: это завершённый report, но не пройденный capability gate. При невозможности обязательного поведения немедленно готовим ограниченный redesign/specification decision; зависимые implementation/proof работы остаются заблокированы. Follow-up не означает, что поведение принято или исключено из цели.
