# Health decay: a minimal ECS example

Inspired by the two-component system in [Bevy's contiguous-query example](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/examples/ecs/contiguous_query.rs). This example uses Bendvy's ordinary per-entity query; it does not implement Bevy's contiguous slice iteration.

- Components: independent `Health` and `HealthDecay` values.
- Entities: two with both components, one with `Health` alone.
- Spawn: deferred commands with an application-authored `EntitySeed` payload.
- Query: requires both components; writes `Health`, reads `HealthDecay`.
- Execution: query before the barrier, then two system ticks after it.

## Components and entity payload

```bend
type Health is Data: Health{value: F32}
type HealthDecay is Data: HealthDecay{factor: F32}
type EntitySeed is Data:
  EntitySeed{health: Health,decay: Maybe<&2,HealthDecay>}
```

## System

`apply_decay` runs once for each entity selected by the query. It reads
`HealthDecay`, reads `Health` and writes the updated `Health`.
These definitions are taken from [system.bend](system.bend); `D`, `C`, `Cap`
and `T` are its module imports. `health_cap` and `decay_cap` select the
operations declared in `Ops`.

```bend
type Ops<-H: Type> is Type:
  Ops{health: Cap.Write<H,D.Health,D.Health>,decay: Cap.Read<H,D.HealthDecay>}

def write_health(~H: Type,~ops: Ops<H>,factor: F32,result: H & C.Access<D.Health>) -> H & (T.Outcome<Error> & D.Health):
  match result:
    case (ctx,C.Found{D.Health{value}}):
      +next : D.Health = D.Health{(value * factor : F32)}
      (Cap.set(~H,~D.Health,~D.Health,~health_cap(~H,ops),ctx,next),(T.Success{},next))
    case (ctx,_): (ctx,(T.Failure{MissingComponent{}},D.Health{0.0}))
def read_decay(~H: Type,~ops: Ops<H>,result: H & C.Access<D.HealthDecay>) -> H & (T.Outcome<Error> & D.Health):
  match result:
    case (ctx,C.Found{D.HealthDecay{factor}}): write_health(~H,~ops,factor,Cap.get(~H,~D.Health,~D.Health,~health_cap(~H,ops),ctx))
    case (ctx,_): (ctx,(T.Failure{MissingComponent{}},D.Health{0.0}))
# System: read HealthDecay and update Health for each matching entity.
def apply_decay(~H: Type,~ops: Ops<H>,_: Unit,ctx: H) -> H & (T.Outcome<Error> & D.Health):
  read_decay(~H,~ops,Cap.read(~H,~D.HealthDecay,~decay_cap(~H,ops),ctx))
```

## Query and system execution

The query plan requires both components and grants write access to `Health`
and read access to `HealthDecay`. An entity with only `Health` is skipped.
The [complete plan](system.bend) binds those accesses to the typed columns.
This is the actual function that passes the system to the query executor:

```bend
def tick(world: S.World()) -> Q.Executed<S.World(),Q.Error<Error>,D.Health>:
  Q.each(~S.Schema,~S.Store,~Unit,~Unit,~OpsType,~Unit,~Error,~D.Health,~plan(),~apply_decay,Unit{},world)
```

This example invokes `Q.each` directly. It does not register a system in a schedule.

## Entity creation and execution

These are excerpts from the runnable source, with imports provided in the linked files:

```bend
S.spawn(world,D.EntitySeed{D.Health{10.0},Some{D.HealthDecay{0.5}}})
S.spawn(world,D.EntitySeed{D.Health{30.0},None{}})
Sys.tick(S.barrier(world))
```

Each spawn returns `Spawned{world,handle}` or `SpawnRejected{world,error}`. The returned world must be threaded into the next operation. The fixture numbers are input data; no balancing rules or graphics are involved.

## Source and run

- [components.bend](components.bend): components and the application payload.
- [schema.bend](schema.bend): columns, family projections and deferred spawn.
- [system.bend](system.bend): callback, required-component selection and query plan.
- [main.bend](main.bend): world creation, spawn result handling and execution.

From the repository root:

```sh
bend examples/health-decay/main.bend
bash examples/health-decay/check.sh
```

Expected output:

```text
before-barrier=
tick-1=5,5
tick-2=2.5,1.25
```

The empty first observation shows deferred visibility. The two subsequent observations contain only the entities with both components, in entity order. The check compares the complete output; it is a finite example check, not a universal proof or performance qualification.

## Optional browser demonstration

[The small interactive demo](demo/README.md) lives entirely in `demo/`.
It imports this example; the example does not depend on it.
