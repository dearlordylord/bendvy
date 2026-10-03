# T02 — шесть ближайших reference trace descriptions

**Все R1–R6: `not-observed / dependency-approval-pending`.** Ни одна ожидаемая строка ниже не получена запуском. Это source-derived oracle candidates, не готовые goldens, Bend acceptance или approved ECS laws. Описание, public API recipe и pinned upstream test дают воспроизводимый вход; небольшой adapter и фактический transcript остаются следующему этапу после dependency approval. Полного позднего harness здесь нет.

Source root: `/workspace/formal-proofs/bendvy/.references/bevy-ts`, commit `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. Ссылки `test/` и `src/` ниже относительно `packages/core` этого checkout. [Core catalogue и upstream decisions](core-map.md), [approval/replay report](report.md).

## Нормализация публичных наблюдений

Одна запись на именованный checkpoint:

```json
{
  "trace": "R1", "step": "after-flush", "status": "source-derived-unobserved",
  "world": "W", "outcome": {"kind": "ok"},
  "lookups": [{"handle": "a", "query": "Positions", "result": "match"}],
  "live": ["a"], "membership": {"Positions": ["a"]},
  "queryOrder": {"Positions": ["a"]},
  "state": {"components": {"a": {"Position": {"x": 1}}}, "resources": {}, "machines": {}},
  "publications": {"events": [], "commands": [{"kind": "spawn", "entity": "a", "stage": "applied"}], "transitions": []},
  "readers": [], "hostCalls": []
}
```

- World names `W/V` и entity labels `a/b/c` назначает input script **при reservation**, до flush; adapter хранит mapping opaque returned handle → logical input label. Labels не выводятся из `.value`, addresses, array slots или descriptor ordinals. References в resources/events/relations преобразуются тем же mapping. Повторное использование физического ID не объединяет разные logical reservations; unknown handle → normalization error, а не silently new label. При cross-world lookup mapping сохраняет original world. Не добавлять identity-check в adapter вместо runtime.
- `live` — множество успешно разрешаемых сущностей, probe через all-entities query; query mismatch не означает dead. `membership` — множество labels, можно канонически сортировать; `queryOrder` — **реальный ordered result `each()` без сортировки**. Отдельные tagged/optional/presence/absence query names фиксированы входом. Absent optional slot — `{present:false}`, не потерянный key/null payload. Dead/pending lookup reference `MissingEntity`, live-but-nonmatching `QueryMismatch`; Bend typed error переводится в тот же semantic category, исходный tag сохраняется в raw evidence.
- `state` — значения компонентов/resources/committed machines, читаемые через public read-only inspector/lookup, не storage dump. Map keys сортируются, ordered payload arrays сохраняются; schema descriptor label известен из input. Для traces только integers/strings/plain records, нет float tolerance или alias equality. Not provisioned = `{present:false}`, а не нулевое значение.
- `outcome` отличает ok, skipped system, typed `SystemFailure` с logical system label/error payload, missing provisioning и thrown defect. Для missing requirements сравнить set `(kind,name)`; original order сохранить в raw transcript. Undefined success value опускается. Defect не нормализовать в expected failure; callback после failing system в той же schedule не считается выполненным.
- Publications различают intent, successful-system **queued/published**, marker **applied**, failed-system **discarded**. Intent из host recording полезен только как diagnostic, не ECS commit evidence. Commands наблюдаются по state до/после marker и публичному opt-in Debug, когда нужен точный queue audit; event publication — через dedicated declared reader. Failed callback host log может сохраниться: это `hostCalls`, не событие ECS. Machine queued value не означает committed state; verify marker outcome отдельно.
- `readers` — system label, ordered messages/added/changed/removed/despawned и `lagged`; независимость/advance выражены следующими reads. Private cursor/tick ordinal не сравнивать. Сохранять multiplicity и порядок publication; события одинакового payload не deduplicate.
- Checkpoint names задаёт script; никаких implicit ticks/flush для observation. State inspector cursor независим от system cursor. Event observation не выполняется inspector вместо registered system-reader: это изменило бы retention. Если нужны probe systems, явно включить их в input schedule и raw transcript. Public debug — opt-in, timings/stack/physical ticks не входят в semantic golden.
- Missing observation = `not-observed` и reason. Это не `[]`, `ok` или default state. Каждая executed запись сопровождается commit/runtime versions/command/input hash/raw output; source-derived expectations хранятся отдельно. Divergence не переписывает expected результат автоматически.

## Общий public API recipe

`Descriptor.Component<{x:number}>()("Position")`, tag `Descriptor.Component<{}>()("Tag")`, resource `Descriptor.Resource<number>()("Count")`, event `Descriptor.Event<number>()("Ping")`; `Schema.bind(Schema.fragment({components:{Position,Tag},resources:{Count},events:{Ping}}))` даёт `Game`. `Game.Runtime.make({services:Game.Runtime.services(),resources:{Count:0}})`; schemas каждого trace содержат только нужные descriptors. Descriptors без constructors здесь допустимы для constructed input, но не демонстрируют validation/restore.

Queries `Positions` read Position; `Writable` write Position; `Tagged` read Position + `with:[Tag]`; `Optional` read Position + optional Tag; `Untagged` read Position + `without:[Tag]`; `All` empty selection. System declares queries/resources/events; spawn через `commands.spawn(Game.Command.spawn([Position,{x}]))`, insert/remove/despawn через commands; flush marker `Game.Schedule.applyDeferred()`. Lookup `lookup.get(id,query)` или `lookup.getHandle(Game.Entity.handle(id,Position),query)`; `get/update/set` — cell operations. Machine `Mode = Game.StateMachine("Mode",["Ready","Broken"])`, provision initial Ready, write через `nextMachines`, apply через `applyStateTransitions`. `runtime.tick(Game.Schedule(...))` boundary всегда явно записана ниже. Host logs — append-only diagnostic arrays; fail-once flag вне ECS нужен исключительно для deterministic retry input.

## R1 — reservation / pending across runs / explicit flush / stale lookup

**Input:** пустой W; Position; labels a,b в порядке reservation; каждый system instance reusable. Последовательность calls:

1. `tick(Schedule(SpawnAB, ObservePending))`: SpawnAB reserves a:x=1, b:x=2. ObservePending records `All`, Positions и lookup a/b. Ожидание: handles возвращены, live/membership/order пусты, оба MissingEntity; queued spawns, не applied.
2. `tick(Schedule(ObservePending))`: всё ещё пусто/MissingEntity, schedule completion не flush.
3. `tick(Schedule(applyDeferred(), ObserveLive))`: live={a,b}, Positions ordered [a,b], x=[1,2], оба match; applied spawn publications.
4. `tick(Schedule(TagReverse, applyDeferred(), ObserveTagged))`: insert Tag b затем a; Tagged **[a,b]**, не [b,a]. Optional Tag у обоих present, Untagged пуст.
5. `tick(Schedule(RemoveA, ObserveLive))`: RemoveA queues despawn a; a ещё live, order [a,b].
6. `tick(Schedule(applyDeferred(), ObserveLive))`: a MissingEntity, b match; live={b}, order [b]. Durable handle a остаётся именованным a, не доказательством liveness.

**Evidence:** `test/Runtime.storage.test.ts:33,51,99`; `test/Runtime.query-lookup.test.ts:578`; `src/internal/world.ts:316–349` separates allocation/spawn. Точная foreign-world/exhaustion проверка пока decision D1, не ожидание parity.

**Replay anchors:** upstream tests “keeps queued commands pending across schedule runs until applyDeferred()”, “returns matches in spawn order even when components are added out of order”, “getHandle resolves durable handles explicitly and reports stale handles safely”. Combined a/b transcript нужно получить adapter после approval; passing anchors alone не заменяет его. **Blocks:** T05 identity/barrier/order acceptance; R3 structural claims.

## R2 — component read/update / optional membership / repeatability

**Input:** a:Position{x:0}+Tag, b:Position{x:10}; Spawn+flush setup. Read system queries Positions, Tagged, Untagged, Optional. Step declares Writable и increments x каждого match на 1, immediately calls cell.get() для read-your-writes; later Read system в той же schedule. Run **тот же Step value** три раза отдельными ticks.

| Checkpoint | Positions order / x | Tagged / Untagged | Optional Tag |
|---|---|---|---|
| setup | [a,b] / [0,10] | [a] / [b] | a present {}, b absent |
| Step1 own read и later Read | [a,b] / [1,11] | [a] / [b] | unchanged |
| Step2 own read и later Read | [a,b] / [2,12] | [a] / [b] | unchanged |
| Step3 own read и later Read | [a,b] / [3,13] | [a] / [b] | unchanged |

Lookup b with Tagged → QueryMismatch при live b; lookup b with Optional → match с absent Tag. Writes commit без applyDeferred, membership не меняется. Не наблюдать cache identity (`matches[0] === matches[2]`) из upstream: это storage-specific assertion.

**Evidence:** `test/Runtime.storage.test.ts:74` reads [0,1,2] from same repeated system; `test/Runtime.query-lookup.test.ts:288,341,391,450,509`; `src/internal/cells.ts`. Read-through-write сама по себе не проверяет writes-through-read prohibition: T03 должен отдельно выполнить Bend compile controls undeclared/cross-schema/write-through-read и two schemas; Data-only restriction не одобрена.

**Blocks:** T03 runtime comparison, T04 access/update cost; finite outputs не доказывают affine API или universal runtime refinement.

## R3 — earlier commit / read-your-writes / rollback / retry / publication

**Input:** a:Position{x:1}, Count=1, Mode=Ready; Ping; ReaderFail declares separate event slots `{read: Game.System.readEvent(Ping), write: Game.System.writeEvent(Ping)}` и Writable/Count/next Mode. Seed+flush setup; host input phase первоначально `bootstrap`: ReaderFail читает пустой Ping и немедленно возвращает `Fx.succeed(undefined)`, **без writes, emits, commands или machine queue**, не меняя fail-once flag. Этим успешным run регистрируется reader. Выполнить `tick(Schedule(ReaderFail, ObserverPing))` в bootstrap phase: ObserverPing также явно регистрируется своим empty read. Затем host input phase переключается в `attempt`; только эта ветка выполняет описанные ниже изменения. Fail-once flag — host input, первая attempt fails, вторая succeeds. Successful Earlier sets a.x=2, Count=2, emits Ping=7, queues spawn c:x=3. ReaderFail first reads Ping, sets a.x=99/Count=99, immediately gets both values, emits Ping=9, queues spawn d:x=99, queues Mode=Broken, then returns `Fx.fail("Rejected")`. On retry он делает те же writes/publications и succeeds. Host diagnostics записывают input/read-your-writes, не откатываются.

1. `tick(Schedule(Earlier, ReaderFail, MustNotRun, applyDeferred()))` → SystemFailure(ReaderFail,Rejected); MustNotRun/marker не исполнены. Expected self-read [99,99] и Ping [7]. After-failure inspector: a.x=2, Count=2, Mode=Ready; c,d not live. Earlier Ping7 committed; Ping9 не published; Earlier spawn c остаётся pending; d discarded.
2. `tick(Schedule(ReaderFail))` successful retry → **снова Ping [7]**; failed-run cursor не consumed. State a.x=99, Count=99, committed Mode ещё Ready; Ping9 теперь published, d-retry queued. Не повторять Earlier: otherwise ввод другой. Reservation d первой попытки и d-retry — разные logical handles, даже если backend reuse выбран иначе.
3. `tick(Schedule(ObserverPing))` → Ping [7,9] в порядке publication (он был registered до Earlier и с тех пор не выполнялся). Mode всё ещё Ready. Event visibility не требует deferred marker.
4. `tick(Schedule(applyDeferred(), ObservePositions))` → Positions [a,c,d-retry], x=[99,3,99]; failed d never live. Count=99; Mode Ready. Queue contents подтверждать публичным Debug либо этими effects, не чтением pendingCommands array.
5. `tick(Schedule(applyStateTransitions(), ObserveMode))` → committed Broken. Failed attempt не оставил дополнительной transition publication; successful transition event Ready→Broken один.

**Evidence:** `test/Runtime.stability.test.ts:6–96` rollback component/resource/event/command/machine queue; `test/Runtime.events.test.ts:61–81` failure redelivery; `src/Runtime.ts:995–1063,1387–1438,1630–1639` per-system journals, publish/advance only success, preserve earlier systems; `src/internal/world.ts:393–427` commit marks vs rollback. Combined Earlier/retry/own-read transcript ещё **не исполнен** и требует adapter; individual tests не содержат всего scenario.

**Blocks:** T06 transaction acceptance, T07/T08 failure cursor acceptance, T09 queue boundary, T11 laws и T12 normal proof/simulation branch для этих contracts. IO rollback не требуется: host diagnostics survive. Typed failure и thrown defect — разные outcomes; defect test остаётся follow-up к T06.

## R4 — независимые event readers / разная частота

**Input:** event Ping; Emit payload [1,2]; A/B — два distinct system values и log sinks. Сначала `tick(Schedule(A,B))` registers both, both []. Затем:

1. `tick(Schedule(Emit,A))` → A [1,2] без marker, B не выполнялся.
2. `tick(Schedule(A))` → A []; B backlog сохраняется.
3. `tick(Schedule(A,B))` → A [], B [1,2].
4. `tick(Schedule(A,B))` → оба [].

No capacity overflow; B действительно registered, retention не приписывается ещё не существующему reader. Обязательные дальнейшие controls (T07, не дополнительные trace packages T02): skip discards events; failure retries same events (R3); never-read stream current/previous frame retention; oldest-batch capacity drop reports `lagged`; emitter sees own emitted events только next run. Факт capacity не численный performance threshold.

**Evidence/replay:** `test/Runtime.events.test.ts:38,99,119,141,170`; `src/internal/streams.ts:1–68`, `Runtime.ts:1388–1395`. Existing upstream “delivers every event exactly once to each reader, independently” имеет first-use B variant; “holds events until every reading system has run, for schedules ticked at different rates” имеет slow registered reader. Наш ordered [1,2] combined transcript ещё не observed.

**Blocks:** T07 equivalent visibility/retention acceptance; inspector вместо B не эквивалентен registered reader.

## R5 — независимые added/changed readers / barrier visibility

**Input:** Position; Added/Changed queries как в `test/Runtime.lifecycle.test.ts:15–30`; A/B observers distinct reusable values; spawn a:x=1 и Move increments x by 10.

1. `tick(Schedule(A, SpawnA, applyDeferred(), B))`: A added=[],changed=[]; B added=[a:1],changed=[a:1].
2. `tick(Schedule(Move,A))`: A added=[a:11],changed=[a:11]; A ran before creation on first call. State x=11; B ещё не consumed эту запись.
3. `tick(Schedule(B))`: B added=[],changed=[a:11].
4. `tick(Schedule(A,B))`: оба added=[],changed=[].

State/membership всё время после setup live a; update не новый spawn. Readers возвращают current value, не history каждого write. Upstream two independent tests: “shows each addition to each system exactly once, after the commands are applied” (`:40`) и “gives independent readers their own view of the same changes” (`:53`). Combined before/after/move expectation подкреплена `Runtime.ts:1400,1426–1428`; требуется фактический transcript после approval.

**Blocks:** T08 lifecycle/change acceptance. Removal/despawn order/slow readers, overwrite counts changed-not-added, skip preservation и failed writes controls остаются T08 (`test/Runtime.lifecycle.test.ts:74–201`). Их каталогизация не является выполнением позднего harness.

## R6 — provisioning preflight / complete retry

**Input:** ровно fixture `test/Runtime.requirements.test.ts:6–55`: Counter resource 0, Logger service logs numeric value, Phase machine Ready/Running. Run system declares write Counter, Logger, read Phase; increments Counter then logs. Same schedule used for incomplete и complete runtimes.

1. Incomplete runtime: services empty; Counter/Phase отсутствуют. `tryTick(schedule)` → MissingRuntimeRequirements set {(service,Logger),(resource,Counter),(stateMachine,Phase)}, callback not invoked, hostCalls=[], state absent, no publications. Preflight failure **до advanceFrame** (`Runtime.ts:1671–1686`). Не считать это SystemFailure или write rollback.
2. Complete runtime: provision Logger.log → host array, Counter=0, Phase=Ready; `tryTick(schedule)` → ok, Counter=1, hostCalls=[1], committed Phase Ready.
3. Optional same-value repetition input: `tryTick(schedule)` → Counter=2, hostCalls=[1,2]; не required assertion existing upstream test, source-derived extra checkpoint.

**Evidence/replay:** “reports missing nominal requirements before executing an erased schedule”; `src/Requirement.ts`; `test/Runtime.resources.test.ts:282,329` service identity; `dtslint/Runtime.tst.ts` static provision constraints. Dynamic erased preflight не заменяет Bend compile-time declaration checks. Nested schedules/conditions/features union requirements остаётся T09.

**Blocks:** T09 provisioning acceptance; related failures должны distinguish authored missing requirement от runtime system error.

## R-C1 observed R2 checkpoint (2026-10-03)

The initial `not-observed` status above is historical. The R2 component/query
recipe has now been executed in [R-C1](../../experiments/rc1-query/README.md), with
[actual Node transcript](../../experiments/rc1-query/observed.txt), matching native
and JavaScript observations. It includes all setup/three-step own-read and later
reader checkpoints, presence/absence/optional traversals and live-b lookup,
without sorting query order or flushing after component writes. A second
HitPoints/Damage/optional-Armor composition has its own executed inputs and
checkpoints. R1 and R3–R6 are not upgraded by this report. Bend structural setup
parity, lifecycle identity, rollback/readers, universal refinement and performance
remain open; no source-derived description is relabeled as executed evidence.
