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

## Playable example

[Survivors](https://github.com/dearlordylord/bendvy-ecs-examples) is a Vampire Survivors clone demonstrating Bendvy ECS. Currently the examples repository contains this one game. [Play in your browser](https://survivors.dearlordylord.com/).

<a href="https://github.com/dearlordylord/bendvy-ecs-examples"><img src="assets/survivors-example.png" alt="Survivors ECS example with enemies, projectiles and XP pickups" width="480"></a>

## Code example

See the [examples index](examples/README.md) for the purpose of each example.
Start with [Scheduled health](examples/scheduled-health/README.md) for a complete
CLI simulation using declaration-derived accesses, a registered system and a
schedule. Its runner checks the full output on JS or Native.

The runnable [health-decay example](examples/health-decay/README.md) creates
three entities with independent components and retains two compiled systems
inside the ordinary generalized Root. One system authors deferred spawns; the
other declares a Health write query filtered by HealthDecay and a HealthDecay
read query.

```bend
# components.bend
type Health is Data: Health{value: F32}
type HealthDecay is Data: HealthDecay{factor: F32}
type EntitySeed is Data: EntitySeed{health: Health,decay: Maybe<&2,HealthDecay>}
```

The [system declaration](examples/health-decay/system.bend) supplies both access
planning and runtime capabilities. Its body reads the decay factor through the
selected entity's full handle and modifies that entity's actual Health owner.
The arithmetic helper is:

```bend
def multiply(+factor:F32,value:Value.Health) -> Value.Health & Unit:
  match value:
    case Value.Health{value}:(Value.Health{F32.mul(value,factor)},Unit{})
```

The [spawn author](examples/health-decay/spawn.bend) queues the three original
payloads through the canonical command capability. Its declaration and the
query declaration are compiled once during registration. The actual owners,
compilations and command buffer remain inside the returned application between
runs. [Root setup](examples/health-decay/root.bend) orders spawn completion
before decay and uses canonical deferred publication at that dependency.

```text
before-barrier=
tick-1=5,5
tick-2=2.5,1.25
```

The first run suppresses deferred application and observes no visible rows.
The next two enable dependency publication before the query. A passive inspector
reads both matching rows; the entity with only Health remains untouched at 30.
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
