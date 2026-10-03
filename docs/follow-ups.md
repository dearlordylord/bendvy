# Bendvy: отложенные задачи

Черновик. Каждое принятое упрощение получает запись здесь; завершённое отмечаем со ссылкой на проверку. Открытый вопрос не считается согласованным упрощением.

| ID | Сейчас | Follow-up | Когда вернуться | Статус |
|---|---|---|---|---|
| F01 | Явные типы и состав мира без DSL/генератора | Оценить повторяющиеся декларации на двух схемах; решить, нужен ли schema DSL/генератор | После проверок выразимости и второго сценария | Отложено |
| F02 | Простая симуляция в репозитории | В отдельной копии canonical-defense проверить ECS для игровых сущностей/систем, сохранив reducer; оригинальный jev не менять | После рабочего headless-среза и необходимых ему ECS-возможностей | Отложено |
| F03 | Консольный CPU-сценарий | Определить нужные host/input/render adapters для canonical-defense | При планировании внешней интеграции | Отложено |
| F04 | Предлагается последовательный scheduler; решение ещё обсуждается | Оценить независимые workloads, безопасное разделение владения и пользу parallel compute | После воспроизводимых native CPU-замеров | Открыто |
| F05 | Представление компонентов и storage ещё не выбрано | Проверить Data и affine Type, стоимость traversal/update и совместимость rollback; выбрать границы API | До закрепления component/query/write API | Открыто |
| F06 | При внешней интеграции сохраняем Canonical.step | Решить, нужен ли перенос самого reducer в ECS; отдельная задача только при обоснованной необходимости | После результатов F02 | Отложено |

Достижение полного core отслеживаем отдельно таблицей паритета: последующие core-блоки не исчезают из цели. Численные критерии performance и критерии закрытия этих задач ещё обсуждаем.

## T12 negative-evidence checkpoint

[T12 redesign candidate](t12-redesign-decision.md) использует отрицательный T03 report;
новые package IDs пока локальные, до человеческого review не публикуются.

| ID | Сейчас | Follow-up / зависимости | Когда вернуться | Статус |
|---|---|---|---|---|
| F07 | Constructor-based authority falsified | R-A safe provider; при отрицательном outcome R-B checked action comparison и explicit System specification decision | До фиксации query/System/Schedule API и любых dependent proofs | Blocked capability; redesign открыт |
| F08 | Relations/scopes остаются core | Identity/commands + lifecycle/removal streams + authority integration; затем cleanup/inverse/cycle/order packages | После соответствующих capability reports, до copied integration | Обязательный поздний core |
| F09 | States остаются core; D3 влияет на ранний API | Transaction/publication + nested provisioning; exact exit/transition/enter failure boundaries и queue laws | При фиксации transaction API; full state package после capability evidence | Открыто |
| F10 | Validation/restore/inspectors/debug остаются core | Affine ownership + D1/D4 identity/restore + readers; noninterference и snapshot limits | До restore/tooling API; overhead затем в representative benchmarks | Открыто |
| F11 | Ordinary proof/simulation specification закрыта | R-C capability reports, #10/#11/#12; concrete law approval и отдельный runtime refinement gate; threshold approval для final performance | После evidence, новый человеческий review до ticket publication | Blocked; finite traces не заменяют refinement |

F02 дополнительно зависит от F08/F09/F10 в объёме реально используемых copied
canonical-defense контрактов: integration planning определяет этот объём после
headless simulation. Original jev/dalph остаются неизменны; F06 не разрешён автоматически.
