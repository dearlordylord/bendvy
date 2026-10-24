<p align="center">
  <img src="assets/bendvy.svg" alt="Bendvy logo" width="120">
</p>

# Bendvy

A Bevy-style ECS built for [Bend 2](https://github.com/bendlang/bend), including its type system, affine ownership and JS/native runtimes. Still a work in progress; the API is evolving.

## Play Nightfall Survivors

[Play Nightfall Survivors in your browser](https://nightfall-survivors-bendvy.leafyyew32.chatgpt.site) — no installation required.
[Source and native launch instructions](https://github.com/dearlordylord/bendvy-ecs-examples/tree/main/examples/survivors).

Nightfall Survivors is an original single-player
survivors game in the separate Bendvy examples repository. It consumes Bendvy's
published BendHub package, so no local Bendvy checkout is required. The native
game uses Bend for simulation, rendering, input, sound and saved profiles; an
optional browser frontend is also available. Follow its linked guide to launch
and play.

## What works so far

- World-scoped entities, typed components and resources.
- Heterogeneous queries with required/optional selections, filters and change detection.
- Declared read/write access, systems, schedules and system-local state.
- Deferred commands, explicit barriers and transactional rollback.
- Typed bundles, directed relations, state machines and transition handlers.
- Read-only Inspector/Check primitives.

These pieces have scoped tests and examples. They don't yet add up to complete parity. Try the [browser ECS example](examples/arena/README.md).

## Code example

See the [examples index](examples/README.md) for the purpose of each example.
Start with [Scheduled health](examples/scheduled-health/README.md) for a complete
CLI simulation using declaration-derived accesses, a registered system and a
schedule. Its runner checks the full output on JS or Native.

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

The goal is the full **Bevy ECS subset covered by bevy-ts**, with idiomatic Bend APIs. The capability deliveries are accepted; current completion work covers public API source documentation. See the [parity tracker](docs/parity/README.md) and [spec](docs/SPEC.md).

Performance optimization and numerical acceptance are deferred in [#21](https://github.com/dearlordylord/bendvy/issues/21). Approximately 3× bevy-ts time is acceptable interim guidance, not a release gate or a claim covering every workload. Correctness, ownership and normal CI remain required; performance work resumes only by explicit user request.

## How we're building it

- [Rust Bevy](https://github.com/bevyengine/bevy) for ECS architecture and semantics; [bevy-ts](https://github.com/SandroMaglione/bevy-ts) for inspiration on feature scope and porting ECS to another language; Bend's source/compiler for types and runtime.
- Feature correctness, ordinary public API examples and source documentation first; measured performance research is deferred.

## License

Bendvy is licensed under either of the following, at your option:

- [MIT License](LICENSE-MIT)
- [Apache License, Version 2.0](LICENSE-APACHE)

SPDX license expression: `MIT OR Apache-2.0`.

Third-party code and assets retain their respective licenses and notices.

### Contributions

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in Bendvy by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.


Optional TS tooling research is preserved in the [TS extension archive index](docs/archive/ts-extension-index.md), with recovery commits and reuse boundaries.
