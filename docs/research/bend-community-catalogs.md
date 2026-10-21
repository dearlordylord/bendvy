# Каталоги и поисковые индексы сообщества Bend

Дата проверки: 2026-10-07. Основной фокус — Bend 2; наш Bendvy не считается сторонней реализацией.

## Поиск определений: JendHub

- [JendHub — инструкции для агентов](https://jend.leeeet.dev/llms.txt).
- Поиск по назначению, имени или типу: `GET https://jend.leeeet.dev/search.txt?q=<query>`.
- Ответ содержит ранжированные определения, import, декларацию, авторский комментарий, краткое описание и ссылку на исходник. По инструкции возвращаются лучшие 10 определений.
- Файлы пакета: `GET https://jend.leeeet.dev/src/<package>/`.
- Исходник файла: `GET https://jend.leeeet.dev/src/<package>/<file>`.
- Одно определение: `GET https://jend.leeeet.dev/src/<package>/<file>?def=<name>`.

JendHub ищет определения Base и пакетов BendHub. Это основная точка входа для поиска конкретной функции или типа; соответствие результата задаче нужно проверять по исходнику.

## Каталоги и реестры

| Источник | Назначение |
| --- | --- |
| [Официальный Bend Hub](https://hub.bend-lang.com/) | Публикация и поиск пакетов |
| [Официальный JSON-индекс](https://hub.bend-lang.com/index.json) | Машиночитаемый список публикаций |
| [Awesome Bend](https://github.com/777genius/awesome-bend) | Подборка библиотек, инструментов, демо и ресурсов для Bend 2 |
| [Bend Packages](https://777genius.github.io/bend-packages/) · [репозиторий](https://github.com/777genius/bend-packages) | Каталог сообщества с поиском, фильтрами и import; включает ссылки на Git-проекты |
| [bend-catalog](https://kbrianps.github.io/bend-catalog/) | Альтернативный индекс Hub: хеши, laws, размер и import; ссылка найдена в Awesome Bend, страница в этой проверке не загрузилась |
| [Bend Docs](https://bendlib.github.io/bendlib/) | API опубликованных пакетов, поиск деклараций и laws, результаты проверки компилятором |
| [Built with Bend](https://builtwithbend.com/) | Каталог приложений и демо |
| [GitHub topic: bend](https://github.com/topics/bend) | Дополнительный поиск репозиториев; может смешивать версии языка и несвязанные проекты |

## Результат поиска сторонних ECS

На дату проверки сторонняя публичная ECS-реализация на Bend не найдена. Это ограниченный результат поиска, а не доказательство отсутствия.

- В Awesome Bend отдельная ECS-библиотека не указана.
- В официальном `index.json` получено 508 записей; поиск по JSON по словам `ecs`, `entity-component` (с вариантами разделителя), `archetype`, `bevy` не дал совпадений. Число записей не означает число уникальных библиотек.
- [Запрос JendHub: entity component system ECS](https://jend.leeeet.dev/search.txt?q=entity%20component%20system%20ECS) исполнен. Первые 10 результатов включают архитектурный `Arc.System`, игровой `Physics.Player`, определения инструментов и MIME; они не подтверждают наличие ECS. Остальные страницы выдачи и все исходники пакетов не проверялись.
- Веб-поиск по Bend/Bend2 и ECS не выявил подтверждённого стороннего проекта.
- Закрытые проекты и сообщения внутри Discord не проверялись.

Близкие игровые проекты, которые сами по себе не подтверждают наличие ECS:

- [jonlib](https://github.com/jonathanperis/jonlib) — графика и математика, цель raylib parity.
- [godot-bend](https://github.com/aricarmo/godot-bend) — экспериментальная GDExtension-привязка Bend к Godot.

При повторном поиске начать с JendHub, затем проверить Hub, каталоги и исходники найденных кандидатов. Не считать совпадение по имени `World`, `Entity` или `System` доказательством ECS.
