# Bendvy

A Bevy-style ECS built for [Bend 2](https://github.com/bendlang/bend), including its type system, affine ownership and JS/native runtimes. Still a work in progress; the API is evolving.

## What works so far

- World-scoped entities, typed components and resources.
- Heterogeneous queries with required/optional selections, filters and change detection.
- Declared read/write access, systems, schedules and system-local state.
- Deferred commands, explicit barriers and transactional rollback.
- Typed bundles, directed relations, state machines and transition handlers.
- Read-only Inspector/Check primitives.

These pieces have scoped tests and examples. They don't yet add up to complete parity.

## Parity and performance

The goal is full **bevy-ts ECS core parity**, with idiomatic Bend APIs. Remaining work includes debug tooling, snapshots/restore, hierarchy/scopes, broader ownership support and complete cross-feature coverage. See the [parity tracker](docs/parity/README.md) and [spec](docs/SPEC.md).

Performance targets: JS at least as fast as bevy-ts, native at least 2× faster on equivalent workloads. Current benchmark wins are workload-specific; full parity performance is still to be qualified.

## How we're building it

- [Rust Bevy](https://github.com/bevyengine/bevy) for ECS architecture, [bevy-ts](https://github.com/SandroMaglione/bevy-ts) for executable behavior, and Bend's source/compiler for language and runtime details. [Reference versions](.references/sources.json) are pinned.
- Law-driven development: falsification, approved laws, proofs where available, and mutation tests.
- Independent API reviews and complete reference comparisons, including ownership and error cases.
- Autoresearch performance loops guided by JS CPU/allocation profiles, native measurements and regression benchmarks.

Contributions, advice and awkward ECS edge cases are welcome!
