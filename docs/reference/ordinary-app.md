# Register and run an ordinary App

Use the ordinary App entry to run typed registrations together. The library derives dispatch, registration identities, cursors, and the schedule from the registrations you retain. The existing SchemaApp, Schedule, and execution tracing still perform the work.

World creation and component storage remain explicit. Create each World with [`world-io.create`](../../src/ecs/world-io.bend) and retain its returned handles. Define component bindings and resource or service declarations before registration.

## Build the registrations

Start with `ordinary-app-execution-recipe.empty(~S,~World,world)`. Register systems through these factories. Their declarations supply operational authority and metadata together.

| Factory | Operational inputs | Result |
| --- | --- | --- |
| [`ordinary-app-component.add`](../../src/ecs/ordinary-app-component.bend) | Observable query, renderer, opaque-owner body, repeatable arguments, name, and slot | Calls `done` with the extended registered App, or `failed` with the original App |
| [`ordinary-app-service-registration.add`](../../src/ecs/ordinary-app-service-registration.bend) | Service declaration, its Setup, and name | Calls `done` with the extended App, or `failed` with the original App |
| [`ordinary-app-local-fields.add`](../../src/ecs/ordinary-app-local-fields.bend) | Resource declaration, body, actual Local owner, repeatable arguments, and name | `Appended{app}` or `AppendRejected{app,local}` |

The component body keeps the existing rank-polymorphic shape:

```bend
@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out)
```

`H` is opaque. Use the declared capabilities inside the body. A registration does not provide access to another component, a writable operation through a read capability, or the concrete World.

Component queries keep their existing `Args:Data` and `Out:Data` limits. Component payloads can be affine `Type` values through owner-preserving bindings and Data projections. Service payloads and Local captures remain `Type`.

The reusable scheduled Local factory uses `Args:Data`, as the existing captured Local schedule does. Its `L` and `Out` remain `Type`. The direct Local API still accepts `Args:Type`; the reusable factory adds no policy for generating fresh affine arguments on every run.

## Name the derived Bend types

Bend requires explicit erased indices. Give the returned App type a local alias with `Component.Application`, `Service.Executable`, or `LocalFields.Executable`. These aliases derive the owner product, observation, error choice, and execution recipe.

The factories also provide aliases for each derived index:

| Index | Library alias |
| --- | --- |
| Owner type | `execution_owners(...)` |
| Observation type | `execution_rows(...)` |
| World observer | `execution_observe(...)` |
| Registration fold | `execution_fold(...)` |
| Schedule plan | Component `execution_plan(...)`; Service and Local `composed_plan(...)` |
| Context dispatcher | `execution_dispatch(...)` |
| Availability observer | `execution_provide(...)` |

Pass these library-derived aliases when extending an App or naming its scheduled type. Do not implement a dispatcher, extract numeric IDs for a plan, copy registration metadata, or construct an execution recipe.

The empty registration uses `Unit` owners, rows, and error. Its indices are `Build.empty_observe`, `Records.empty`, and the recipe module's `empty_plan`, `empty_dispatch`, and `empty_provide`, specialized to the schema and World.

## Attach the schema and run

[`ordinary-app-run.attach`](../../src/ecs/ordinary-app-run.bend) takes the ordinary schema, registered App, schedule name, and initial-barrier choice. `True` puts a barrier before the registered systems on each run. `False` leaves queued commands pending until another barrier applies them.

Attachment validates every retained registration's namespace, ID, name, and access list against the actual World. Duplicate identities fail validation. Unrelated registrations in the World are excluded from the derived plan. Systems run in registration order.

Attachment returns `Schedule.Attached{app}` or `Schedule.Invalid{app}`. The invalid result retains the unscheduled registration owners and actual World.

Call `Entry.run` with the scheduled App. It supplies the ordinary always-run condition and delegates to `ordinary-app-execution.run`. The result is:

```bend
Execution.Run{result,batch}
```

The `result` retains the scheduled App in every case:

- `Schedule.Finished{app,observations}` completes the schedule.
- `Schedule.Failed{app,error,observations}` stops at the failed system.
- `Schedule.Rejected{app}` rejects runtime registration or World authority.
- `Schedule.Missing{app,requirements}` reports missing provisioning before any step, including the initial barrier.

Feed the returned App into the next run or retry. Do not create a new World or register replacement owners to retry. Service availability is observed from the current owned slots on each run through the same canonical declaration and Setup.

A condition that skips a system continues to the next step under the existing Schedule contract. A failed system stops the schedule. `Entry.run_when` preserves the explicit-condition route when a condition is needed.

`Entry.replan` rebuilds the plan from the retained owners. It changes the name or barrier choice without registering systems again. `Entry.inspect` threads an explicit World projection through the App and returns the actual updated App with the projection result.

## Observe debug and owned state

`Entry.enabled` enables the existing ordinary App debug path. `Entry.snapshot` returns the App with its current schema, registration, and World observations. `Execution.Run.batch` carries the existing execution trace result.

A component invocation retains its latest Data row-output list. A later run replaces that list. Scheduled Local execution uses the existing output-drop policy while retaining the actual Local capture on success, failure, and refusal. This entry adds no cleanup or host IO policy.

For a complete runnable example, see [Scheduled health](../../examples/scheduled-health/README.md). The [ordinary App qualification](../../experiments/public-api-usability/health-v2/README.md) records the finite heterogeneous, ownership, authority, and retry checks.

The standalone System and Schedule APIs remain lower layers for callers that intentionally supply their own execution composition.
