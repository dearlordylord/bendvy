# Bendvy: схема разработки

**Черновик для дальнейшего обсуждения.** Это предварительный гайдлайн; скоуп, порядок и архитектурные решения ещё обсуждаем.

Глубина планирования и область будущего интервью: [рамка планирования](planning-scope.md).

Цель: реализовать в Bend2 полное подмножество Bevy ECS, охваченное bevy-ts. bevy-ts — пример выбора возможностей и переноса ECS в другой язык; Rust Bevy — источник архитектуры и семантики ECS. API и хранение проектируем под типовую систему, владение и runtime Bend2. Исходные версии: [sources.json](../.references/sources.json); обоснование: [анализ](bend2-ecs-port.md).

## Весь целевой скоуп

- Ядро: entities/handles, components/tags/bundles, schema/fragments, queries/read/write, resources, local state систем, services и проверка зависимостей.
- Исполнение: systems, schedules/условия/фазы/композиция, deferred commands и явные барьеры.
- Семантика: added/changed/removed/despawned, events и независимые курсоры, retention/lag, typed failures и rollback системы.
- Связи и состояния: relations/hierarchy/inverse/cleanup, entity scopes, state machines и transitions.
- Инструменты: validation, snapshots, inspectors, debug/devtools, feature composition.
- Отдельный следующий слой: math, fixed timestep, input и host adapters; объём аналога browser/Pixi ещё обсудить. Полный движок Rust Bevy вне цели.

## Порядок работы

1. Составить таблицу паритета по всему скоупу, включая следующий слой: контракт → ссылка на проверку → статус → этап/условие возврата; зафиксировать версии Bend и исходников.
2. Проверить две разные схемы, отклонение неверного read/write-доступа, владение stores и повторный запуск систем. Определить ID, storage, границы IO, commit/rollback и видимость изменений.
3. После проверки минимального rollback/visibility и composition/provisioning закрепить API записи и storage; реализовать entities, components, queries, resources и последовательные schedules с commands/barriers; собрать headless-демо.
4. Добавить visibility, streams/cursors и failure/rollback; затем relations, scopes и state transitions.
5. Закрыть composition/provisioning, validation, snapshots и инструменты; проверить весь core по таблице паритета.
6. По замерам улучшать storage/query cache; отдельно обсудить parallel compute и platform adapters.

Для каждого блока следуем bend-ldd: контракт и кандидатные законы → falsification → согласование законов → реализация/доказательства → mutant checks и сверка одинаковых сценариев TS/Bend. Технические пробы могут предшествовать согласованию; доказательства — только после него. Согласованные расхождения отмечать отдельно от достигнутого паритета. Этапы — части общей цели; отложенное остаётся в таблице с причиной и условием возврата.

Открыто: schema DSL или явные типы; ограничения компонентов Data/Type; стратегия rollback; ID/reuse и порядок query; объём адаптеров и параллельности. Эти решения черновик не закрепляет.
