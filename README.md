<p align="center">
  <img src="assets/bendvy.svg" alt="Bendvy logo" width="120">
</p>

# Bendvy

A Bevy-style ECS built for [Bend 2](https://github.com/bendlang/bend), including its type system, affine ownership and JS/native runtimes. Still a work in progress; the API is evolving.

## What works so far

- World-scoped entities, typed components and resources.
- Heterogeneous queries with required/optional selections, filters and change detection.
- Declared read/write access, systems, schedules and system-local state.
- Deferred commands, explicit barriers and transactional rollback.
- Typed bundles, directed relations, state machines and transition handlers.
- Read-only Inspector/Check primitives.

These pieces have scoped tests and examples. They don't yet add up to complete parity. Try the [browser ECS example](examples/arena/README.md).

## Code example

The runnable [health-decay example](examples/health-decay/README.md) creates
entities with independent components and runs a system over a query.
The excerpts below come from its source files; imports and column bindings
are in the linked example.

```bend
# components.bend
type Health is Data: Health{value: F32}
type HealthDecay is Data: HealthDecay{factor: F32}
type EntitySeed is Data: EntitySeed{health: Health,decay: Maybe<&2,HealthDecay>}
```

The system declares **write Health, read HealthDecay**. `apply_decay` is its
entry point; the two preceding functions read the components and write the
updated health. `health_cap` and `decay_cap` select the declared operations.

```bend
# system.bend
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

The query requires both components. `tick` passes `apply_decay` to `Q.each`,
which executes it for each matching entity:

```bend
def tick(world: S.World()) -> Q.Executed<S.World(),Q.Error<Error>,D.Health>:
  Q.each(~S.Schema,~S.Store,~Unit,~Unit,~OpsType,~Unit,~Error,~D.Health,~plan(),~apply_decay,Unit{},world)
```

This example runs the query directly, without registering a system in a schedule.
The [query plan and bindings](examples/health-decay/system.bend) are in the
complete source.

```bend
# main.bend: reserve an entity and queue its components.
S.spawn(world,D.EntitySeed{D.Health{10.0},Some{D.HealthDecay{0.5}}})

# Make deferred spawns visible, then run the system.
Sys.tick(S.barrier(world))
```

`S.spawn` returns a world and entity handle, or an explicit refusal.
The [complete main](examples/health-decay/main.bend) handles that result and
threads the world through the operations. An entity with only health is skipped.
Run it with `bend examples/health-decay/main.bend`.

The optional [minimal browser demo](examples/health-decay/demo/README.md) shows
three entities and a **Tick** button. Display code lives separately in `demo/`.
The [browser arena](examples/arena/README.md) provides a larger interactive example.

## Parity and performance

The goal is the full **Bevy ECS subset covered by bevy-ts**, with idiomatic Bend APIs. Remaining work includes debug tooling, snapshots/restore, hierarchy/scopes, broader ownership support and complete cross-feature coverage. See the [parity tracker](docs/parity/README.md) and [spec](docs/SPEC.md).

Performance targets: JS at least as fast as bevy-ts, native at least 2× faster on equivalent workloads. Current benchmark wins are workload-specific; full parity performance is still to be qualified.

## How we're building it

- [Rust Bevy](https://github.com/bevyengine/bevy) for ECS architecture and semantics; [bevy-ts](https://github.com/SandroMaglione/bevy-ts) for inspiration on feature scope and porting ECS to another language; Bend's source/compiler for types and runtime.
- Autoresearch performance loops guided by JS CPU/allocation profiles, native measurements and regression benchmarks.
