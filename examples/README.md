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
| [Survivors](https://github.com/dearlordylord/bendvy-ecs-examples/tree/main/examples/survivors) | Vampire Survivors clone; combat queries and entity lifecycles | [Browser demo](https://nightfall-survivors-bendvy.leafyyew32.chatgpt.site) |
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

## Compact registered component systems

For canonical component writes, owned resource writes and their pairs,
[recognized-query-declaration](../src/ecs/recognized-query-declaration.bend)
retains the capability owner type before registration. Build its declarations
from the same component bindings, then register through
[recognized-app-component](../src/ecs/recognized-app-component.bend). The generic
system body, ordinary scheduling, cursor tracking and metadata stay unchanged.
The [Sparse declaration](../test-fixtures/connected-performance/sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion.bend)
and [App setup](../test-fixtures/connected-performance/sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-driver.bend)
show this supported path with affine component and resource payloads.

The supplied observable query contributes inspection only; operational grants,
selection and access metadata come from the recognized declaration. With tracing
enabled, execution uses the existing ordinary runner with that same operational
declaration. Raw/custom declarations, mixed unsupported forms, captures and the
existing ordinary query builders retain their ordinary execution paths. This is
an additive setup option for the listed forms, not automatic recognition of
arbitrary grants. Manually constructed raw carriers remain trusted adapters.

## Finding the application API

These are the primary declaration and execution entry points. Their source comments
state ownership, refusal and visibility contracts. This table is a navigation map,
not a list of every runtime helper or a claim that all capability APIs are covered.

| Application task | Entry points |
| --- | --- |
| Name components and compose a schema | [ordinary-declaration](../src/ecs/ordinary-declaration.bend), [ordinary-schema](../src/ecs/ordinary-schema.bend) |
| Bind schema storage during trusted setup | [ordinary-component-binding](../src/ecs/ordinary-component-binding.bend) |
| Declare component access, filters and inspection | [ordinary-query-declaration](../src/ecs/ordinary-query-declaration.bend), [ordinary-query-observable](../src/ecs/ordinary-query-observable.bend) |
| Compose prepared read/optional queries | [ordinary-query-builder](../src/ecs/ordinary-query-builder.bend) |
| Register a component system | [ordinary-app-component.add](../src/ecs/ordinary-app-component.bend) |
| Register a system with retained affine capture state | [ordinary-app-capture-query.add](../src/ecs/ordinary-app-capture-query.bend) |
| Register the supported recognized write forms | [recognized-query-declaration](../src/ecs/recognized-query-declaration.bend), [recognized-app-component.add](../src/ecs/recognized-app-component.bend) |
| Derive a schedule and execute the registered application | [ordinary-app-run.attach/run](../src/ecs/ordinary-app-run.bend) |
| Supply explicit plans or retain typed condition bindings | [ordinary-app-schedule](../src/ecs/ordinary-app-schedule.bend) |
| Handle execution results and detached trace batches | [ordinary-app-execution.Run](../src/ecs/ordinary-app-execution.bend), [ordinary-app-schedule.RunResult](../src/ecs/ordinary-app-schedule.bend) |
| Declare whole-resource or selected-field access | [ordinary-app-resource-declaration](../src/ecs/ordinary-app-resource-declaration.bend), [ordinary-app-resource-field-declaration](../src/ecs/ordinary-app-resource-field-declaration.bend) |
| Compose explicit recoverable operations | [ordinary-recovery-declaration](../src/ecs/ordinary-recovery-declaration.bend) |
| Compose bundles, fragments and owned features | [ordinary-bundle](../src/ecs/ordinary-bundle.bend), [schema-fragments](../src/ecs/schema-fragments.bend), [feature](../src/ecs/feature.bend) |
| Declare typed streams and retain readers | [ordinary-event-declaration](../src/ecs/ordinary-event-declaration.bend), [ordinary-event-family](../src/ecs/ordinary-event-family.bend), [ordinary-app-event-family-reader](../src/ecs/ordinary-app-event-family-reader.bend) |
| Compose owned event publication declarations | [ordinary-owned-event-declaration](../src/ecs/ordinary-owned-event-declaration.bend) |
| Spawn or clean up scoped entities | [ordinary-lifetime-scope](../src/ecs/ordinary-lifetime-scope.bend), [ordinary-lifetime-scope-io](../src/ecs/ordinary-lifetime-scope-io.bend) |
| Read machine state, queue transitions and run handlers | [ordinary-machine-declaration](../src/ecs/ordinary-machine-declaration.bend), [ordinary-machine-operations](../src/ecs/ordinary-machine-operations.bend), [ordinary-machine-handler-bundle](../src/ecs/ordinary-machine-handler-bundle.bend) |
| Inspect values or evaluate cursor-free checks | [inspector](../src/ecs/inspector.bend), [check](../src/ecs/check.bend) |
| Save eligible world data and validate/apply a restore | [snapshot.save](../src/ecs/snapshot.bend), [restore-public](../src/ecs/restore-public.bend), [restore-save](../src/ecs/restore-save.bend) |
| Create a runtime World or integrate a raw transaction | [world-io.create](../src/ecs/world-io.bend), [transaction](../src/ecs/transaction.bend) |
| Consume detached traces or format a filtered dump | [execution-trace](../src/ecs/execution-trace.bend), [ordinary-app-dump](../src/ecs/ordinary-app-dump.bend) |
| Integrate registered ECS systems below App | [ordinary-system](../src/ecs/ordinary-system.bend), [system](../src/ecs/system.bend) |
| Use lower-level component operations or deferred commands | [component](../src/ecs/component.bend), [commands](../src/ecs/commands.bend) |
| Build or execute a lower-level schedule | [schedule](../src/ecs/schedule.bend), [world](../src/ecs/world.bend) |
| Invoke declared grants or bounded direct queries | [capabilities](../src/ecs/capabilities.bend), [query](../src/ecs/query.bend) |

Raw storage lenses, constructors and arbitrary world-transforming callbacks are
trusted setup/adapter APIs. Use the declared capabilities inside system bodies;
they preserve the distinction between read and write access. `execution_*` type
and callback projections are advanced application plumbing, not extra gameplay
metadata to maintain. Mechanical callback continuations are implementation helpers.

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
