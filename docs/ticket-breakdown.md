# Ближайшие тикеты Bendvy

**Согласовано пользователем и опубликовано после review Астры.** [Parent #1](https://github.com/dearlordylord/bendvy/issues/1) задаёт весь core. Детально разбит ближайший экспериментальный этап до конкретных законов и следующей спецификации. Proofs и симуляция получают точные тикеты в T12, после evidence и определения законов; это не исключение proofs из цели.

На GitHub опубликованы задачи #2–#13 с ready-for-agent и native blocking edges для безусловных зависимостей. Для T12 (#13) prerequisites обычной ветки указаны в тексте, чтобы не заблокировать немедленный redesign по отрицательному evidence. Parent не изменён. Approval конкретных законов, новых project dependencies и изменений требований остаётся отдельным gate.

T01/T02 — verifiable preparation, остальные — узкие публично наблюдаемые пробы или evidence/specification результаты. Исследовательский report с отрицательным outcome может быть завершён, но capability gate остаётся закрытым: сразу готовим ограниченный redesign decision, не ждём невозможных proofs. Technical downstream не стартует от одного закрытого issue, если нужный gate не пройден. T12 может оформлять redesign по готовому отрицательному evidence.

| Тикет | Заблокирован | Результат |
|---|---|---|
| [#2 / T01: Воспроизводимый native/JS и proof canary](https://github.com/dearlordylord/bendvy/issues/2) | — | Разработчик запускает один маленький чистый пример в native CPU и JS и проверяет известную истинную и ложную claim; окружение и способ проверки воспроизводимы. |
| [#3 / T02: Карта core и reference traces](https://github.com/dearlordylord/bendvy/issues/3) | — | Можно увидеть все обязательства полного core и воспроизвести небольшие эталонные сценарии bevy-ts, которые будут сравниваться с Bend. |
| [#4 / T03: Повторяемая типобезопасная query на двух мирах](https://github.com/dearlordylord/bendvy/issues/4) | T01, T02 | Две разные маленькие схемы выполняют несколько шагов чтения и обновления Data-компонентов через узкий API; запрещённый доступ невозможно проверить успешно. |
| [#5 / T04: Affine payload без потери владения](https://github.com/dearlordylord/bendvy/issues/5) | T03 | Установлено, как тот же экспериментальный ECS принимает компонент с owned array и читает/изменяет его, либо получен минимальный воспроизводимый отказ, объясняющий границу поддержки. |
| [#6 / T05: Reservation, lookup и явный structural barrier](https://github.com/dearlordylord/bendvy/issues/6) | T03 | Через экспериментальный API резервируется сущность, становится live лишь на marker, затем удаляется; lookup и query дают правильные результаты до и после каждого действия. |
| [#7 / T06: Успешный commit и failed-system rollback](https://github.com/dearlordylord/bendvy/issues/7) | T04, T05 | Одна система сохраняет изменения; следующая читает собственные записи, повторно обновляет компонент/resource, создаёт event/command и падает. Снаружи остаётся только результат успешной системы. |
| [#8 / T07: Два event reader, retry и retention](https://github.com/dearlordylord/bendvy/issues/8) | T06 | Два независимо запускаемых event reader работают с разной частотой; failed reader повторяет чтение, skipped reader и overflow ведут себя по reference-контрактам. |
| [#9 / T08: Независимые change/removal observations](https://github.com/dearlordylord/bendvy/issues/9) | T06 | Две системы с разной частотой независимо наблюдают added/changed и removed/despawned в маленьком сценарии; пропуск и failure не смешивают жизненные циклы с buffered events. |
| [#10 / T09: Вложенный schedule с provisioning и failure](https://github.com/dearlordylord/bendvy/issues/10) | T03 | Повторно запускаемый вложенный schedule получает объявленные resource/service requirements и возвращает ожидаемый typed system failure без выдачи лишнего доступа. |
| [#11 / T10: Сопоставимые native/JS benchmarks](https://github.com/dearlordylord/bendvy/issues/11) | T04, T05, T06, T07, T08 | Разработчик воспроизводимо сравнивает bevy-ts с native и JS экспериментальным ECS на одинаковых операциях и видит стоимость traversal, updates, churn, readers и rollback. |
| [#12 / T11: Первый конкретный пакет законов и falsification](https://github.com/dearlordylord/bendvy/issues/12) | T02, T03, T05 | Пользователь получает первый конечный пакет кандидатных законов для экспериментальных identity/query/commands: с объяснениями, falsification/control и эскизами proof. Пакет задаёт достаточно точные обязательства для спецификации отдельных proof-тикетов. |
| [#13 / T12: Спецификация proofs и следующего этапа по evidence](https://github.com/dearlordylord/bendvy/issues/13) | T09, T10, T11 | Получив evidence ближайших проверок, пользователь получает следующую конкретную спецификацию и tracer-bullet разбиение: узкие proof/refinement packages и простая симуляция, либо ограниченный redesign-план для обнаруженного обязательного capability blocker. |

## Изменения после review Астры

- Event readers и change/lifecycle разделены: разные контракты, независимые пробы после transaction.
- Proof тикеты не публикуем абстрактными пакетами: T11 задаёт конкретный первый law package; T12 специфицирует ограниченные proof/refinement задачи по полученным определениям. Review других законов не ждёт benchmark без фактической зависимости.
- Различены доказательство модели, tests runtime traces и universal refinement. Их нельзя засчитать друг вместо друга.
- У отрицательного experiment outcome есть немедленный путь к redesign, без автоматического уменьшения scope и без требования пройти невозможный proof.

T12 — обязательный checkpoint следующей спецификации. В каждом последующем горизонте повторяется этот переход; поздние core-блоки остаются в общей карте.

Performance остаётся обязательством: native существенно быстрее TS, JS как минимум сравним. Текущие пробы должны дать evidence и численные критерии; закрытие отчёта benchmark не означает, что полный продукт уже прошёл performance acceptance.
