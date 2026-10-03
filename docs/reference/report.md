# T02 evidence report

Дата: 2026-10-03. Base: `ab41a899ec3cb44558e3f1a9c7eccd41c5cb2122`. Scope: [issue #3](https://github.com/dearlordylord/bendvy/issues/3), [parent #1](https://github.com/dearlordylord/bendvy/issues/1) и локальный [SPEC](../SPEC.md). GitHub title/body прочитаны через `gh issue view {1,3} --repo dearlordylord/bendvy --json title,body`; parent не изменялся.

Результат: [полный core catalogue](core-map.md) с источниками/статусом/next/return, отдельный platform tracking, [нормализация и шесть ближайших trace descriptions](traces.md), upstream decisions для early interfaces. **Preparation report complete; TS observation/capability gates не пройдены.** Ни runtime impossibility, ни успешный runtime experiment не установлены. Не требуется ждать implementation для ограниченного specification decision D1–D4.

## Provenance и выполненные проверки

| Read-only checkout | `git -C <path> rev-parse HEAD` output | Manifest match |
|---|---|---|
| `/workspace/formal-proofs/bendvy/.references/bevy-ts` | `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334` | Да |
| `/workspace/formal-proofs/bendvy/.references/bevy` | `ad678262ce53b5d142fe49ee5e08caff6f00ab60` | Да |
| `/workspace/formal-proofs/bendvy/.references/bend2` | `a950fd683c0d76f09794078e6174fe98a1492876` | Да |

Tracked manifest: [sources.json](../../.references/sources.json). Только TS исходники/тесты использованы для oracle candidates; Rust Bevy — secondary reference, не parity target. Absolute checkout locations не являются переносимыми: на другой машине fetch exact manifest commits в disposable directories и проверить HEAD перед replay. References здесь не изменялись.

Commands: `rg --files docs`, `cat docs/SPEC.md`, `cat docs/planning-scope.md`, `cat docs/tickets/02-contract-reference.md`, `cat docs/follow-ups.md`; `rg --files <bevy-ts>/packages/core/{src,test,dtslint}`; `rg -n` и `sed -n` по sources/test ranges, указанным в карте и traces; `cat <bevy-ts>/{package.json,vitest.config.ts,vitest.shared.ts,packages/core/package.json}`. Initial lookup `Runtime.test.ts` дал file-not-found; actual suite split в `Runtime.*.test.ts`, их пути проверены. Это навигационная ошибка, не failure reference runtime.

`node --version` → `v24.20.0`; `command -v pnpm` → `/usr/local/share/npm-global/bin/pnpm`. Это discovery, не pinned TS execution environment. Проектных зависимостей не установлено, TS/Bend runtime не запускались. Skill `/home/node/.codex/skills/bend-ldd/SKILL.md` прочитан; Bend code/laws/proofs не добавлены, поэтому Bend checker и version/guide не запускались в этой documentation-only задаче. Перед последующей Bend работой обязательны `bend version`, `bend guide` и checker timeout 5s. T01 results не засчитаны как T02 evidence.

## Точный dependency approval request (не получен)

Для запуска существующих pinned upstream test anchors запросить: **разрешить в отдельной disposable копии bevy-ts установить test-only toolchain `vitest@4.0.18`, `vite@8.0.3`, `vite-tsconfig-paths@6.0.5` и совместимые transitive dependencies по pinned upstream lockfile, с записью exact resolved versions/lock hash.** Это нужно, потому что tests импортируют vitest и `@typeonce/bevy-ts` через tsconfig paths; core сам не имеет runtime dependencies. Optional peer TypeScript >=5.9 не означает разрешение установить compiler. Root `pnpm install` подтянул бы также Effect/Pixi/Matter/tooling и **не разрешён этим request**. Если isolated subset не запускается без дополнительных packages, представить concrete revised request; не устанавливать молча. Для будущего custom transcript adapter отдельно выбрать runner (например upstream `tsx@4.21.0`), установить только после approval его exact dependency set.

Согласование установки — правило AGENTS/SPEC и bend-ldd, не inference риска. Request записан здесь в соответствии с task instruction; не является полученным approval. Пока можно завершить catalogue/descriptions, но observed goldens и downstream comparison gates закрыты.

## Replay после approval

Не исполнять до approval. Read-only source copy использовать лишь как источник; запуск в disposable workspace, чтобы не писать caches в references. Record source HEAD, approved versions, lockfile hash, Node/OS, exact commands, exit codes, selected input schedules и raw stdout/stderr. Ниже команды для утверждённой test-toolchain в копии, не для install:

```sh
pnpm exec vitest run packages/core/test/Runtime.storage.test.ts packages/core/test/Runtime.query-lookup.test.ts
pnpm exec vitest run packages/core/test/Runtime.stability.test.ts packages/core/test/Runtime.events.test.ts
pnpm exec vitest run packages/core/test/Runtime.lifecycle.test.ts packages/core/test/Runtime.requirements.test.ts
```

Это anchor tests R1/R2, R3/R4, R5/R6 соответственно, а не новый full core harness. При необходимости ограничить `-t '<exact test title>'` из traces. Самые маленькие исходные fixtures целиком находятся в pinned checkout; не требуется копировать весь upstream test suite в Bendvy. Existing test passes подтверждают только их inputs. Для combined R1–R5 и R6 extra checkpoint нужен маленький public API adapter с точными schedules из descriptions и normalized transcript; dependency choice approval отдельный. Не называть stdout `vitest` normalized semantic output: нужно записать значения checkpoints отдельно.

Acceptance ledger всех R1–R6: expected source-derived; raw runtime output **missing**; normalized runtime output **missing**; TS/Bend equality **blocked**. T03 может изучать expressibility, но comparison acceptance R2 не пройден; T05 ждёт R1/D1; T06 ждёт R3; T07 ждёт R4/failure; T08 ждёт R5; T09 ждёт R6/D3. T10 equivalent workloads и T11/T12 соответствующие law/proof/simulation decisions не получают acceptance от каталога. Эти edges не изменяют Dalph claims или GitHub native blockers.

## Follow-ups и limits

- Dependency approval и небольшой adapter для шести combined transcripts: вернуться после approved concrete runner/toolchain; сохранять source-derived и observed evidence раздельно.
- D1 world identity/exhaustion/restore handle safety и D2 local ownership: вернуться до фиксации T05/T06/T09 API; без решения не ослаблять parent.
- D3 states и D4 snapshot boundaries: уточнить early transaction/identity contracts сейчас; полный late harness после relations/lifecycle/states prerequisites. Отложенное не approved parity/divergence.
- R4 capacity/skip и R5 removals/lag follow-ups: T07/T08; поздние edge cases не охвачены шестью trace descriptions.
- Schema DSL F01 и parallel F04: evidence двух schemas/второго application и native workload; Data-only не принят.
- Laws остаются candidate/falsification/approval gate T11; здесь нет закона или proof. Finite trace match не доказывает model theorem, executable-function theorem или universal runtime refinement; каждый требует собственного evidence.
- Native существенный speedup и JS comparability остаются mandatory final gates; numerical thresholds не предложены и не утверждены T02. Нет timing/memory/scaling claims.
- Нет изменений original jev/dalph, DALPH.md, master, reference checkouts или coordinator state; публикация/close issue остаётся integrator.

Documentation verification: relative links и все source file paths проверяются перед commit; `git diff --check` должен пройти. Fresh independent review проверяет `Base..HEAD` перед accepted result; findings фиксируются ниже после review. Dalph-related execution problems кроме отсутствия автоматической передачи dependency approval не наблюдались; отсутствие approval ожидаемо по gate и не объявляется Dalph defect.

## Candidate verification и независимый review

- Проверка Python standard library (`pathlib/re/json/subprocess`): относительные Markdown links разрешаются; explicit `src/`, `test/`, `dtslint/` paths существуют в pinned core; simulation source проверен отдельно; все manifest commits совпадают; headings дают ровно R1–R6. Output: `PASS: relative links, pinned commits, explicit core source paths, exactly six trace descriptions`. Первый regex ошибочно считал вложенный `examples/top-down/test/simulation.test.ts` core path; исправлена проверка границы path, source существовал.
- `git diff --check`: exit 0. Документационный check не является TS/Bend execution или acceptance traces.
- Round 1: fresh reviewer, inherited same model, medium reasoning, Base..`fd7e39158469314392fddb362cfcd84f1705296d`. Один blocker: R3 registration не задавал empty callback branch; также уточнить separate Ping read/write slots и explicit ObserverPing registration. Исправлено: host phase bootstrap читает и succeeds без mutation/publication, registration schedule вызывает оба readers, attempt phase activates fail-once writes. Остальных reasonable blockers reviewer не обнаружил. Исправленный candidate подлежит fresh round 2 до accepted result.
