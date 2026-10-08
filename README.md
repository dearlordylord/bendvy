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

A component is a Bend value; its typed column belongs to the world's store:

```bend
import Base
import ./src/ecs/column.bend as Col

type Schema is Data: Schema{}
type Position is Data: Position{x: F32,y: F32}
type Store is Type: Store{positions: Col.Column<Schema,Position>}
```

For a concrete entity command, the arena example exposes a typed spawn helper:

```bend
import Base
import ./examples/arena/game.bend as Arena

def spawn_actor(world: Arena.World(),body: Arena.Body) -> Arena.World():
  Arena.spawn(world,body)
```

Spawns are deferred until an explicit barrier. See the [arena code walkthrough](examples/arena/README.md)
for its component declarations, entity commands, system capabilities and query.

## Parity and performance

The goal is the full **Bevy ECS subset covered by bevy-ts**, with idiomatic Bend APIs. Remaining work includes debug tooling, snapshots/restore, hierarchy/scopes, broader ownership support and complete cross-feature coverage. See the [parity tracker](docs/parity/README.md) and [spec](docs/SPEC.md).

Performance targets: JS at least as fast as bevy-ts, native at least 2× faster on equivalent workloads. Current benchmark wins are workload-specific; full parity performance is still to be qualified.

## How we're building it

- [Rust Bevy](https://github.com/bevyengine/bevy) for ECS architecture and semantics; [bevy-ts](https://github.com/SandroMaglione/bevy-ts) for inspiration on feature scope and porting ECS to another language; Bend's source/compiler for types and runtime.
- Autoresearch performance loops guided by JS CPU/allocation profiles, native measurements and regression benchmarks.
