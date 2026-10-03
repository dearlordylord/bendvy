# Bevy-подобный ECS на Bend2: объём и архитектура

Дата исследования: 2026-10-03. Это анализ исходников и предложение архитектуры; реализации Bendvy и результатов её проверки пока нет.

## Вывод

Скоуп «как у Сандро: ECS и связное» подходит. Переносить следует поведение и принцип проектирования: закрытая схема мира, явно объявленный доступ систем, явные границы структурных изменений. Архитектуру нужно адаптировать к Bend2: типизированные хранилища, передача владения, специализация статических функций. Динамические объекты cell и повторно вызываемые callback-замыкания из TS напрямую не переносятся.

Важно различать первый работающий ECS и полный текущий скоуп Сандро. Последний включает relations, state machines, события с курсорами читателей, rollback отдельной системы, snapshot, validation и debug. Маленький ECS со spawn/query/schedule ещё не даёт паритета.

## Что именно скачано

- `bevy-ts`: `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334` (2026-10-01T02:43:31-07:00), [https://github.com/SandroMaglione/bevy-ts](https://github.com/SandroMaglione/bevy-ts).
- `bevy`: `ad678262ce53b5d142fe49ee5e08caff6f00ab60` (2026-10-03T00:50:35+00:00), [https://github.com/bevyengine/bevy](https://github.com/bevyengine/bevy).
- `bend2`: `a950fd683c0d76f09794078e6174fe98a1492876` (2026-10-03T18:48:23+02:00), [https://github.com/bendlang/bend](https://github.com/bendlang/bend).

Это shallow clones с полным деревом файлов, а не только ECS-папками. В Rust-снимке версия `0.20.0-dev`. Не установлена историческая версия Rust Bevy, с которой начинал Сандро; сравнение ниже относится к скачанным снимкам, а не доказывает происхождение каждого решения.

## Как устроен перенос в TypeScript

[README](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/README.md) и [ARCHITECTURE](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/ARCHITECTURE.md) описывают переосмысление ECS под TS. Путь пользовательской программы:

1. Descriptors задают компоненты, ресурсы, события, services и relations.
2. Фрагменты объединяются и связываются в закрытый `Game` через `Schema.bind`.
3. Query и System создаются в контексте этого Game; callback видит только заявленный доступ.
4. Schedule хранит шаги, systems и объединение requirement tokens.
5. Runtime проверяет предоставленные зависимости; structural commands применяются лишь на markers.

Подробные типы проверяются при создании значения, после этого по композиции переносится компактная информация о требованиях и ошибках. Это снижает стоимость type checker и глубину рекурсивных типов. В Bend2 полезен тот же принцип: проверить схему и план один раз, исполнять простой специализированный план. Не следует воссоздавать TS conditional types.

[world.ts](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts) хранит запись сущности с массивом компонентов по ordinal и индексами membership; [queries.ts](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/queries.ts) выбирает наименьшее множество обязательного компонента, кеширует membership и переиспользует match/cell-объекты. Это отличается от Rust [storage](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/storage/mod.rs) с tables и sparse sets, организованными вместе с archetypes. «Порт Bevy» здесь означает перенос концепций и выбранного поведения, а не копирование Rust storage.

[allocator TS](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/internal/world.ts) выдаёт возрастающие ID; Rust [Entity](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/entity/mod.rs) использует index и generation с оговоркой о переполнении. Для Bendvy можно сохранить монотонные ID ради сходства с TS либо выбрать поколения для повторного использования слотов. Это явное архитектурное решение, не обязательный атрибут любого ECS.

Исполнение TS schedule проходит шаги последовательно: [Runtime.ts](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts). Rust имеет single-threaded и multi-threaded executors: [executor](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/mod.rs). Поэтому старт с последовательным Bend scheduler соответствует модели TS и не требует сразу копировать Rust DAG executor.

Core использует собственный небольшой `Fx`, а не обязательную зависимость от Effect: [Fx](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Fx.ts), [package.json](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/package.json). Для Bend достаточно собственных типизированных Result и IO на границе с host.

## Граница проекта

| Область | Цель Bendvy |
|---|---|
| Entities, components, tags, bundles/spawn drafts | Включить |
| Закрытая schema, fragments, typed queries и access | Включить, с Bend API |
| Resources и local state системы | Включить |
| Commands, applyDeferred, scopes | Включить |
| Schedule composition, порядок, условия, фазы | Включить |
| Added/changed, removed/despawned, reader cursors | Включить |
| Buffered events, retention, lag reporting | Включить |
| Relations, hierarchy, inverse links, cleanup | Включить |
| State machines и explicit transitions | Включить |
| Validation, typed failure, rollback одной системы | Включить в целевой паритет |
| Inspectors, snapshots и headless debug | Включить после ядра |
| Math, fixed step и input model | Следующий слой, отделённый от ECS |
| Browser и Pixi integration | Host adapter; не нужны для первого Bend ECS |
| Rust renderer, PBR, assets, audio engine, editor | За пределами этой цели |

Текущий upstream имеет отдельные core/math/browser/pixi/devtools packages, что позволяет удержать границу ECS независимо от platform: [список пакетов](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/README.md). Rust-модули для сверки поведения: `bevy_ecs`, `bevy_app`, `bevy_state`, `bevy_time`. Не требуется переносить весь App/Plugin framework, чтобы получить явные композиционные schedules.

## Что Bend2 поддерживает и что меняет

[Guide](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/guide/GUIDE.md) задаёт affine ownership: массив и замыкание нельзя копировать; read массива возвращает и сам массив, и прочитанное значение. `Data` можно переиспользовать с `+`. Templates с `~` получают закрытый синтаксический аргумент и специализируются; локально захваченные значения как template argument не подходят. Нет traits, type classes и обычных макросов: [limitations](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/README.md).

| TS/Rust механизм | Предложение Bend2 | Ограничение |
|---|---|---|
| Runtime descriptors и schema bind | Явные типы schema, component keys и специализированные store accessors | Генерацию произвольной схемы ещё нужно проверить |
| Heterogeneous world | Отдельный `Store<T>` на компонент, типизированный World | Не общий `Map<String, Any>` с casts |
| `Query.read/write` cells | Узкие входы системы, возвращаемые writable stores и output | Владение само по себе не делает переданный store read-only |
| Повторно вызываемый callback | Top-level defs и `~` templates; данные конфигурации отдельно | Обычный closure нельзя сохранять и вызывать каждый tick |
| Schedule как список callbacks | Статическая композиция либо tagged SystemId с dispatch | Произвольный runtime plugin API не появляется автоматически |
| Runtime services | IO/host capability на границе + чистые входные данные | Внешние эффекты не откатываются как ECS writes |
| Parallel systems | Разделить World на независимые stores/partitions и соединить outputs | Access metadata без разделения владения недостаточно |

Первая закрытая схема может быть обычным написанным вручную record мира с конкретными stores. Общий schema DSL или генератор добавлять после двух различных игр, чтобы не зафиксировать преждевременную абстракцию. Генератор исходников — возможный внешний инструмент, а не уже существующая возможность Bend templates.

Для v1 компоненты и events разумно ограничить `Data`. Это позволит читать компонент с сохранением в store. Affine `Type` компоненты потребуют swap/take и отдельного договора владения; runtime handles оставить в services. Такая граница ограничивает API относительно произвольных TS values и должна быть документирована.

## Предлагаемое ядро

Это проектный эскиз сигнатур, не скомпилированный Bend-код:

```text
Entity = (world identity, slot, generation)
Store<T> = membership + values + added ticks + changed ticks
World<GameSchema> = entities + concrete stores + resources + pending work
System input = selected data + explicitly owned writable partitions
System output = updated partitions + write delta + commands + events + result
Schedule step = Run(SystemId) | ApplyDeferred | ApplyStateTransitions
```

Начать с per-component storage и простой переборной query. Для каждого store использовать явную capacity, membership и индекс сущности; рост capacity и lookup проверять. Sparse-set layout или membership cache вводить после замеров. Полный archetype engine слишком рано увеличит цену доказательств и структурных операций.

Query — scoped traversal/fold, а не iterator, который удерживает ссылки на world cells между ticks. `read` выдаёт данные, а `write` принимает новое значение или delta. Система, получившая весь writable store, фактически имеет доступ ко всем его сущностям: если требуется точный query-level capability, скрыть store за специализированным traversal. Передача полного World системе разрушает цель declared access.

Если используем reuse слотов, добавить generation и world identity. Spawn-order нельзя выводить из slot: после reuse он меняется. Для паритета с TS нужен отдельный монотонный spawn ordinal. Для U32 generation/ordinal выбрать политику исчерпания; нельзя обещать вечную уникальность с переполнением. Альтернатива — Nat или отказ от повторного использования ID в v1.

Commands держать pending в Runtime между schedules. Reservation при spawn выдаёт ID до flush; reserved ID ещё не доказывает live entity. Spawn/insert/remove/despawn/relate применяются в установленном порядке. Только explicit markers меняют structural membership. `applyStateTransitions` должен сохранить порядок «commands, затем transitions», включая согласованный порядок enter/exit systems.

## Три сложные семантики, которые нельзя потерять

**Видимость.** Change tick и last successful run — отдельные понятия от frame number. Каждый читатель имеет свой cursor. TS видит события ранней успешной системы уже в той же schedule; не только на deferred barrier. Removed/despawned имеют свои журналы. В TS skip по condition выбрасывает накопившиеся events, но не продвигает change detection так же: [правила чтения](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/ARCHITECTURE.md). Эти случаи нужно перенести в таблицу переходов и conformance tests до реализации.

**Rollback.** При failure отдельной системы ECS-owned writes отменяются, её events и commands не публикуются; предыдущие успешные systems остаются committed. Read cursor failed reader не должен продвинуться. Это реализовано в [transaction runtime](https://github.com/SandroMaglione/bevy-ts/blob/3040a3b2a3f28fa8554d856f9ccb6bf5433fa334/packages/core/src/Runtime.ts). Чистая функция над affine mutable arrays не даёт rollback бесплатно: входные arrays могут быть уже изменены in place. Предложение — write delta с чтением собственных записей, затем commit при success; вариант — undo journal. Требуется поддержать read-your-writes и writes нескольких систем к одному компоненту. Clone всего World каждый tick не нужен. Host IO остаётся вне транзакции, как и в TS.

**Retention.** Streams удерживаются с учётом читателей и ограничены capacity; при overflow сообщают lag. Один глобальный drain делает порядок чтения зависимым от scheduler и ломает независимость readers. Event journal, cursor и skip/failure rules должны быть явными данными Runtime. State transitions и relation failures также требуют согласованной видимости.

## Массивы и параллельность

В логическом Base массив — дерево `ALeaf/ANode`: [Base Array](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/base.bend). Это не основание утверждать, что runtime ECS lookup обязательно O(log N): native compiler реализует array intrinsics и блоки ARR/BUF: [compiler и blk runtime](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts). Но произвольный собственный traversal через match на ANode тоже не гарантирует zero-copy split: `blk_half` и `blk_node` выделяют блоки и копируют содержимое. Требуется измерять выбранный traversal в compiled native backend.

Индексы Base Array wrap, capacity — степень двойки. ECS обязан проверять валидность ID и bounds до доступа, иначе invalid entity index может попасть в живой слот. `Array.get` работает с Data; `Array.swap` позволяет вынуть affine value и вернуть owner. Экспериментальные `Array.fork/join` помечены unsafe: не брать их как основание проверяемого ядра.

План параллельности: сначала статически независимые stores или отдельно владеющие chunks, затем fork-join и детерминированное объединение deltas/commands. Чтение общего `Data` snapshot возможно, но расход на reference counting и копирование надо измерить. Две системы, изменяющие разные строки одного общего array, нельзя просто запустить параллельно с двумя ссылками на него.

Bend parallel calls требуют независимой и примерно сбалансированной работы. JS target последовательный; native CPU и GPU ведут себя иначе. Поэтому GPU ECS scheduler не входит в первый этап; GPU имеет смысл для крупных чистых численных kernels после отделения их данных от world orchestration. Преимущество по скорости над TS/Rust здесь не установлено.

## Этапы и критерии готовности

1. **Проверка выразимости.** Две конкретные закрытые schemas, generic Data store, typed traversal read/write, многократный запуск top-level system/template. Успешный пример и compile rejection неверного доступа/схемы. Это снимает главный риск языка до большого DSL.
2. **Минимальное ядро.** Spawn/reserve/despawn, tags, resources, required/optional/with/without query, последовательный schedule, pending commands и marker. Демо headless movement без renderer.
3. **Видимость и транзакции.** Added/changed, lifecycle streams, независимые readers, skip/failure/lag, write delta, commit/rollback. Проверить две schedules с разной частотой.
4. **Связное ECS.** Relations/inverse/cleanup, hierarchy policy, entity scopes, state machines, transition schedules и typed provisioning.
5. **Инструменты и масштаб.** Snapshot/validation/inspector/debug. Membership indexes и query cache по benchmark. Сопоставить spawn order после despawn/reuse.
6. **Platform и compute.** Fixed timestep и input resources; отдельный host adapter. Parallel kernels только после подтверждённых измерений.

Полный текущий скоуп Сандро достигается после этапа 5 для core и после соответствующих адаптеров для всего набора пакетов. Каждый промежуточный milestone объявлять подмножеством, а не готовым портом.

## Проверка поведения и доказательства

Использовать TS tests как исходный каталог контрактов, затем одинаковые operation traces для TS и Bend. Сравнивать нормализованные наблюдения, а не внутренние ID/storage layout. Если intentional divergence — отдельная запись и отдельное ожидание. Особенно полезны traces: spawn до/после marker, событие двум readers, skipped reader, failed writer/reader, despawn relation target, transition вместе с commands, fixed-rate schedule и overflow.

Для будущих LAWS/PROOF кандидатами являются: отсутствие lookup умершей сущности; query membership; frame condition (не изменяются незаявленные компоненты); preservation остальных entities при insert/remove; commands invisible до marker; rollback возвращает наблюдаемое ECS-состояние; readers не потребляют события друг друга; согласованность relation inverse; deterministic replay. Это пока перечень свойств, не утверждение о доказанной корректности.

Связать доказуемую чистую модель с production array storage через refinement/observations. F32 не использовать как базу точных физических равенств: README обозначает floating point как axiomatic. Проверить свойства membership/идентичности/порядка отдельно от численной физики. `--verdict` добавляет проверку отдельным kernel, но не доказывает foreign effects, backend codegen или всю игру.

Локально установлен `bend 2.0.34`; выполнены `bend version` и полностью прочитан `bend guide`. Guide установленного binary и текущего source HEAD местами отличаются, поэтому compiler/base версию будущего проекта надо зафиксировать. Код Bendvy не писался, компиляция предложенных API не проверялась; upstream dependencies/tests/benchmarks не запускались.

## Рекомендуемое решение

Принять headless ECS с закрытой схемой как цель, поведение bevy-ts как primary conformance reference и Rust Bevy как дополнительный источник концепций. Первый implementation milestone — этапы 1–2. До их успешной проверки не обещать универсальный Schema.bind-аналог, runtime plugins, parallel scheduler или parity по скорости. В переносе сильнее всего ценность явных контрактов и проверяемого состояния; storage и API следует выбрать под Bend2.

## Корректировка требований после интервью

Performance — обязательная цель: сборки в низкоуровневые языки существенно быстрее bevy-ts; JS-сборка как минимум сравнима. Численные пороги ещё не заданы; результаты не измерялись. Эта корректировка заменяет прежнее предложение ограничиться измерениями без обязательства по скорости. Превосходство над Rust Bevy не требуется.
