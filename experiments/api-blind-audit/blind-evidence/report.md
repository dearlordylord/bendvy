# Blind ECS API evaluation

**Verdict: usable bounded structural primitives; not a practical supplied API for the requested independently authored ECS application.** The evaluation stops at real interface/checker limits, without generating engine modules or replacing the library. First impressions and initial verdict were frozen before receiving coordinator hints (none were requested or accepted).

## Inputs and source pins

Only this directory's AGENTS, manifest, Bend guide and library sources; installed Bend/Base and bend-ldd skill; and the three authorized primary reference checkouts were consulted. No parent project history, reports, tickets or benchmarks were read. All 29 supplied library hashes match the manifest (`manifest-check.json`). The installed version is **bend 2.0.35**, Node **v24.20.0**. `bend version` and `bend guide` were run before authoring Bend. No dependencies, compiler, references, library files, laws or proofs were changed.

- Rust Bevy: `ad678262ce53b5d142fe49ee5e08caff6f00ab60`.
- bevy-ts: `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.
- Bend reference: `a950fd683c0d76f09794078e6174fe98a1492876`.

Primary source research: Bevy `examples/ecs/contiguous_query.rs`, `crates/bevy_ecs/src/system/query.rs` (`iter` returns ReadOnly, `iter_mut` retains mutable query data), and `crates/bevy_ecs/src/schedule/executor/mod.rs` (`ApplyDeferred`); bevy-ts `examples/concepts.ts` and `packages/core/src/System.ts` (caller `run` callback); Bend `bend2/bend.ts:3210` and `:3478` (live/dead demand and affine usage accounting), `demos/app_pong_game_2d/main.bend`, installed guide. These sources support separating ECS ergonomics from mandatory Bend ownership; TypeScript references are not a license to alias affine Bend owners.

## Observed capabilities

| Capability | Result | Evidence / limit |
|---|---|---|
| Caller-defined schema and actual affine Type payloads | Pass | `structural.bend` defines Position, Velocity, Stats; no raw arrays or storage constructors in client |
| Deferred spawn with explicit barrier | Pass | `structural.bend`, `[2]` MainAdded/MainChanged events |
| Deferred remove, insert, despawn | Pass | `lifecycle.bend`, second barrier returns `[5]` events: removed, added, changed, removed, despawned |
| Compiled JS structural execution | Pass | `lifecycle.mjs`, Node receipt is Con(5,Nil), runner checks this exact value |
| Independent movement function | Pass, language only | `system-control.bend` defines arithmetic using caller-owned Position/Velocity; it is not a registered ECS system |
| Register caller-authored system | Unsupported | `schedule.register` takes closed BodyKind; passing movement fails expected K.BodyKind / observed function |
| Query traversal with independent constant callback | Pass, narrow | `query-constant-control.bend` returns `[42]`; never reads payload, so not gameplay or payload-query acceptance |
| Payload-reading query / read-only ECS observer | Blocked | `attempt-unerased-query.bend` expects erased getter binder; `minimal.bend` matches -get then live call fails expected -get / observed get |
| Position/Velocity/Health plus optional Armor in one world as independent components | Unsupported in supplied schema | World has main Type, aux Type, flag Data; no third/fourth independent Type slot or generic component family |
| Small resource creation | Pass, narrow | Stats{hits:0} supplied to I.create; resource mutation/read in registered user system untested |
| Separately registered movement and damage, fixed ticks, hit/death observation | Unsupported / blocked | No caller system registrar; payload query blocked. No fabricated simulation result |
| Native build / equivalent-work performance | Untested | JS runs finite structural fixture only; no performance or product acceptance claim |

`consumer/lifecycle.bend` is the runnable partial example. It uses public I.create, C.reserve, C.remove_main, C.insert_main, C.despawn and C.apply_checked. It does not destructure World/Rows, fabricate handles, mutate private storage, invent journals, or copy library gameplay. Output observes library change events rather than independently rereading final payloads. Returning owners and explicit failure envelopes are legitimate affine usage.

## Commands and negative controls

Run `consumer/check.sh`; exact commands and exit codes are in `commands.tsv`, diagnostics in `*-check.log`. All checks use timeout 5s, emission timeout 30s, Node runtime timeout 5s. No timeout occurred. Failed query attempts remain intact; failures were not reclassified as access-safety successes.

| Negative | Positive control | Intended / observed diagnostic | Scope |
|---|---|---|---|
| `undeclared-access.bend` | `read-control.bend` | PositionToken expected, HealthToken observed | Independently typed read callback; language-level token restriction, not a working registered ECS query |
| `write-through-read.bend` | `read-control.bend` | Adding write value to read getter fails expected function / observed Sigma | Read-only callback shape; no supported ECS write method demonstrated |
| `cross-schema.bend` | `schema-control.bend` | S.Handle<Game> expected, S.Handle<Other> observed | Actual public command boundary |
| `duplicate-owner.bend` | `owner-control.bend` | owner consumed more than once | Actual affine World type |
| `system-registration.bend` | `system-control.bend` | K.BodyKind expected, caller function observed | Actual registrar boundary; passing predefined kind does not run authored movement |

The first query failure is a binder-type mismatch, and the corrected signature fails erased/live usage. The ordinary `read-control` accepts the same owner/get-return pattern, and the constant query callback runs, isolating the difficulty to the supplied dependent callback contract rather than ordinary affine ownership. No local checker repair was provided as an evaluation input or attempted.

## Natural reference code shape

The actual bevy-ts Concepts source defines a schema containing Position, Velocity, Health; then registers a function with a declared write Position/read Velocity query and read dt resource. Its natural shape is:

```ts
const Moving = Game.Query({ selection: {
  position: Game.Query.write(Position), velocity: Game.Query.read(Velocity)
} })
const Move = Game.System("Move", {
  queries: { moving: Moving }, resources: { dt: Game.System.readResource(DeltaTime) }
}, ({ queries, resources }) => {
  for (const { data } of queries.moving.each()) {
    const velocity = data.velocity.get()
    data.position.update(p => ({ x: p.x + velocity.x * resources.dt.get(), y: p.y }))
  }
})
const setup = Game.Schedule(Spawn, Game.Schedule.applyDeferred())
```

Rust Bevy's actual contiguous_query source similarly authors health decay and damage functions, registers both through add_systems, and despawns using Commands. A natural equivalent public shape (illustrative, not executed here) is:

```rust
fn movement(mut q: Query<(&mut Position, &Velocity)>, dt: Res<Delta>) {
    for (mut p, v) in &mut q { p.0 += v.0 * dt.0; }
}
fn damage(mut commands: Commands, mut q: Query<(Entity, &mut Health)>) {
    for (e, mut h) in &mut q {
        h.0 -= 1;
        if h.0 == 0 { commands.entity(e).despawn(); }
    }
}
// Register caller functions; an explicit ApplyDeferred can establish visibility.
app.add_systems(Update, (movement, damage, ApplyDeferred).chain());
```

Bend should thread an owner back from reads/writes and avoid Rust/TS-style arbitrary aliasing. Neither that requirement nor one-match-per-def explains an erased getter that cannot be called live, a closed engine-authored BodyKind, or only two independent Type component slots.

## Minimal proposed changes and return conditions

1. Provide a live callable capability contract for generic payload queries; retain opaque owner return and token typing. Re-run the unchanged independently authored observer and all four controls on the supported checker.
2. Expose registration of caller-authored system callbacks with declared read/write/resource/command capabilities. A generic dispatcher requiring the application to build its own engine adapter is not a substitute for this entry point.
3. Provide a typed schema representation with independently selectable affine component families, or explicitly document the two-slot restriction. Packing Position/Velocity/Health into one main payload would be a simplification requiring follow-up; it does not demonstrate independent component lifecycle/access.
4. Once these seams exist, return for the original single-world fixed-tick movement/damage/resource/hit/death/observer scenario, then equivalent-work native and JS measurements. These are return conditions, not acceptance already earned by the structural probe.

This report establishes finite executable structural traces and selected type rejections. It establishes no model proof, executable-function proof, universal runtime refinement, general authority guarantee or performance acceptance.
