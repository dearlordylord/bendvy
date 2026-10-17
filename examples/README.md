# Examples

Start with [Scheduled health](scheduled-health/README.md): world creation,
declaration-derived query access, a registered system, an explicit schedule,
deferred spawn and complete output checks on JS and Native.

| Example | Purpose | Execution style |
| --- | --- | --- |
| [Scheduled health](scheduled-health/README.md) | Application starting point | Ordinary declarations and registered schedule |
| [Health decay](health-decay/README.md) | Small query mechanics example | Direct query execution |
| [Health browser demo](health-decay/demo/README.md) | Interactive view of health decay | Browser host, direct query execution |
| [Arena](arena/README.md) | Playable browser simulation | Browser host, direct query orchestration |
| [User simulation](user-simulation/README.md) | Transaction/event/retry regression story | Explicit provider and runner integration |
| [Workshop](query-composition/README.md) | Query composition and rollback regression story | Explicit query/provider and runner integration |

The advanced regression stories retain their fixed reference checkpoints. Their
handwritten access lists and raw setup are not the application starting pattern.
Each linked README describes the actual API used and its verification command.

## API levels

Bevy exposes an application level (`App::add_systems` / `App::update`) and an
ECS level (`World` plus `Schedule::add_systems` / `Schedule::run`). App delegates
to ECS schedules; these are layers, not competing engines. See the pinned
[App source](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/app.rs)
and [Schedule source](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/schedule.rs).

In Bendvy, `ordinary-system` with `schedule` exercises registered ECS execution.
`ordinary-app-*` composes schema, registration, provisioning and observation on
top of that execution. Scheduled health currently demonstrates the first layer;
it is not evidence that every application must author its dispatcher or that
the larger SchemaApp surface is equally convenient. The browser examples
instead use direct query execution inside an external interactive loop.

Bend's affine owners must be threaded rather than copied, and its erased
operation indices require explicit types. The library may still derive storage
projections, registration metadata and dispatch from declarations. The manual
boilerplate in one example does not establish a language requirement.

## Keeping examples executable

`bash examples/check.sh` discovers every runnable top-level example and requires
its `check.sh`. It compiles current sources and checks full scenario output or
the existing gameplay/host controls. The nested health browser adapter and
separate timing entries are included by their parent checks. No benchmarks run.

The existing Infrastructure checks workflow runs this on every push to master
and pull request, with pinned Bend 2.0.35 and Node24.20.0. It also checks the
scheduled simulation on Native with Clang19 `-O3` and compares JS/Native output.
A broken example therefore fails CI when the core changes. This detects drift;
it cannot prevent arbitrary future mistakes or guarantee maintainers fix a red
build. Real-browser checks remain optional and are not implied by Node host tests.

Locally set `BEND`, `NODE` and `CLANG` to select installed tools;
`BENDVY_EXAMPLE_NATIVE=1` enables the Native example. CPU pinning is optional via
`BENDVY_EXAMPLE_CPU`; the default works on CI machines with fewer CPUs.
