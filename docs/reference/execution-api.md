# Replacement execution API

The ordinary execution contract is the [SPEC replacement amendment](../SPEC.md#ordinary-execution-replacement-user-amendment-2026-10-26-utc).
This page names the current application entries and source modules implementing
that contract. The [capability map](../parity/README.md#replacement-execution-delivery)
records their implementation ownership. Source-bound observations retain the
scope of their actual consumers.

## Application construction and repeated runs

The ordinary host entry is `world-io.create`. It consumes the resource owner and
returns `IO(Creation<...>)`. `Created{world}` contains the new World.
`Refused{resource}` returns the resource owner. Namespace allocation is scoped to
the host allocator's realm or process. Raw constructors and `with_namespace`
remain trusted integration operations.

The [machine main](../../examples/parallel-machines/main.bend) shows this entry.
Its `created` continuation initializes the returned World, binds the
`Scheduled.BuildResult`, and passes `BuildReady{app}` to `execute_prepared`.
The [scheduled implementation](../../examples/parallel-machines/scheduled.bend)
retains the returned application through four updates. Construction and execution
can both return IO, so the caller binds each result before the next operation.

For heterogeneous component and resource layouts,
[`execution-generalized-root-application`](../../src/ecs/execution-generalized-root-application.bend)
provides `build` and `run`. `build` takes the actual World, generalized node facts,
the condition registry, the error handler, dependency edges, and condition
bindings. It returns `execution-parallel-root-application.Scheduled`.
`run` consumes that schedule and returns IO containing the updated schedule and
a `dependency-application.Report`. Repeated runs consume the schedule returned by
the preceding run.

The [health-decay root](../../examples/health-decay/root.bend) supplies concrete
`build`, `dispatch`, `publish`, and `run` functions. Its `Plan.Edge{lid,rid}`
orders the spawn author before the query. `Scheduled.configure` supplies
`execution-deferred-settings.Settings` independently of those dependency edges.

## Retained system and condition compilation

[`execution-parallel-system.define_with_compilation`](../../src/ecs/execution-parallel-system.bend)
consumes a Compilation, the World, a name, and the system's Local owner.
It returns that Compilation paired with `execution-system.Defined`.
`Defined{world,system}` contains the registered owner.
`DefinitionRefused{world,local}` returns the World and the unregistered Local.

`execution-parallel-scope.CompiledBinding` pairs the returned Compilation with
the registered owner. The retained generalized body adapter is
`execution-parallel-scope-registry.compile_retained_generalized_leaf`.
The retained condition adapters are `execution-condition-registry.RetainedSystem`
and `compile_retained_leaf`, or `compile_retained` for a retained selection.
The condition registry derives its access metadata from the actual Compilation
and marks unsupported or writing conditions invalid.

The [captured node definitions](../../examples/parallel-captures/guarded-nodes.bend)
show the body registration and retained leaf adapters. The
[guarded application](../../examples/parallel-captures/guarded.bend) shows the
corresponding condition registration, `CompiledBinding`, and retained dispatch.
These factories supply a closed construction witness for capability selection.
That trusted construction boundary does not prove that arbitrary manually built
bindings agree with a declaration. Current ordinary applications use these
retained registrations.

## Task bodies and execution policy

[`execution-system.Body`](../../src/ecs/execution-system.bend) receives abstract
`Permit` and `H` types, declared capabilities, the scope owner, and Local.
Its result is `execution-reservation-task.Task` containing the returned scope,
Local, and `Completion`. Both `Success{output}` and `BodyError{error,output}`
accompany the body's returned owners. A body error retains writes already performed.
`RunResult.Refused` returns the World and the system without a body completion.

[`execution-reservation-task`](../../src/ecs/execution-reservation-task.bend)
defines `TDone` for a result, `TRun` for a deferred step, `TBind` for a
continuation, `TFork` for branches and their join, and `TNeed` for a reservation
request. The framework supplies declaration-bound reservation authority.
The [event peer body](../../examples/parallel-events/scheduled.bend) uses `TRun`
to defer its Local update until the executor enters that task.

`Task.Policy` has `Parallel` and `Serial` constructors.
[`execution-resource-query-group`](../../src/ecs/execution-resource-query-group.bend)
exposes `run_retained_with_policy`, `run_retained`, and `run_retained_serial`.
`run_retained` selects `Parallel`. `run_retained_serial` selects `Serial`.
The [captured node dispatch](../../examples/parallel-captures/guarded-nodes.bend)
shows both calls on the same retained nodes.

The policy reaches `execution-reservation-driver.run_with_policy` and the common
Task interpreter. Serial lowers each reached `TFork` to left-then-right binds,
including forks returned by deferred steps. Parallel permits eligible branches
to use the parallel path. Selecting Parallel alone does not establish that two
operations execute on different native workers.

### Taskful query rows

`Build.task_general_query` declares a taskful traversal of one sparse component
route. Its closed `Q.TaskGeneralBody` receives the actual handle, cached view,
writable payload `P`, and output owner `O`, and returns
`Task<S,Permit,P & (O & Maybe<&2,E>)>`. It uses the same
`Q.TaskOutputEach` and `Q.each_task_output` capability described below.
The declaration specializes the row callback and output split and merge functions.
`Store.Sparse` is supported. `Store.Whole` returns `LayoutRefused` with the supplied
scope and output retained. See the [reservation contract](../design/reservation-production-api.md)
and [Arena player-row consumer](../../examples/arena/spawn.bend).

[`Build.task_output_query`](../../src/ecs/execution-builder.bend) declares a
traversal of paired read and write columns with a taskful row callback and an abstract
output owner `O`. The callback's `Permit` is the same type supplied to the system
declaration. The existing `Build.output_query` provides the pure callback path.

[`Q.TaskOutputBody`](../../src/ecs/execution-query.bend) receives the actual row
handle, a read view, the writable payload, and `O`. It returns
`Task<S,Permit,Layout.query_output(layout,route) & (O & Maybe<&2,E>)>`.
`Q.TaskOutputEach<S,Permit,H,O,E>` contains the resulting capability.
`Q.each_task_output` exposes its `H -> O -> Task<S,Permit,H & (O & Report<E>)>`
operation. The system body binds that task through the existing Task interpreter
and Driver before constructing its completion.

The [chunk traversal](../../src/ecs/chunk-query.bend) sequences rows within each
chunk. At column branches, the supplied `split` separates the actual output owner
and `merge` rejoins the returned outputs. Parallel traversal defers both `TFork`
children with `TRun`. Serial traversal binds the left branch before the right.
The execution policy described above also applies to these tasks.

The traversal retains the read owner while the callback owns the writable payload
and output across suspension. The returned payload reconstructs the column and
updates its write stamp even when the row reports an error. Invalid targets or
mismatched column layouts return `LayoutRefused` with the supplied scope and output.

The existing [output declaration](../../examples/parallel-query/output-declaration.bend)
binds this capability, and the [command body](../../examples/parallel-query/command-body.bend)
awaits its result. Its [row callback](../../examples/parallel-query/command-row.bend)
returns `TDone` after authoring insertion. The six existing modes produce matching
JavaScript and native output at 9,715 bytes, also matching the prior pure path.
These observations do not exercise row `TNeed` or Spawn, establish native worker
participation, complete GH87, or extend the approved helper proofs to the traversal.

## Returned inventories and registration lifecycle

The generalized Root's `Storage.Present` contains the returned World and displaced
owners. `CutRefused`, `JoinRefused`, and `NestedRefused` retain the corresponding
administration and physical inventory. These refusal variants are not usable
Worlds for later conditions or publication. The returned application retains
those owners rather than constructing a substitute World.

[`execution-resource-query-lifecycle`](../../src/ecs/execution-resource-query-lifecycle.bend)
provides `retire`, `release`, `rebuild`, and `reregister` for retained body nodes.
`Released` contains the actual Compilation, cache context, identity, and Local.
Retirement refusal returns the World and the node. Re-registration refusal
returns the World and `Released`. Successful re-registration restores the same
identity and cursor, then invalidates cached admission for the next inspection.
The [guarded application](../../examples/parallel-captures/guarded.bend) retires a
node, attempts another run, re-registers the returned owner, and runs again.

## Module catalogue

| Application task | Source entries |
| --- | --- |
| Create a World and retain its namespace factory | [world-io](../../src/ecs/world-io.bend), [world](../../src/ecs/world.bend) |
| Declare component and resource layouts | [execution-composer-schema](../../src/ecs/execution-composer-schema.bend), [execution-composer-layout](../../src/ecs/execution-composer-layout.bend) |
| Compile access declarations and retain their actual capabilities | [execution-builder](../../src/ecs/execution-builder.bend), [execution-resource-program](../../src/ecs/execution-resource-program.bend), [execution-declaration](../../src/ecs/execution-declaration.bend) |
| Define returned success or body error and reservation tasks | [execution-system](../../src/ecs/execution-system.bend), [execution-reservation-task](../../src/ecs/execution-reservation-task.bend) |
| Select query families and lifecycle filters | [execution-query](../../src/ecs/execution-query.bend), [execution-query-recipe](../../src/ecs/execution-query-recipe.bend) |
| Retain query systems and compose compatible groups | [execution-resource-query-leaf](../../src/ecs/execution-resource-query-leaf.bend), [execution-resource-query-group](../../src/ecs/execution-resource-query-group.bend), [execution-resource-query-composite](../../src/ecs/execution-resource-query-composite.bend) |
| Register owners and build an application schedule | [execution-parallel-scope-registry](../../src/ecs/execution-parallel-scope-registry.bend), [execution-generalized-root-application](../../src/ecs/execution-generalized-root-application.bend) |
| Declare conditions, dependencies, and deferred policy | [execution-condition-registry](../../src/ecs/execution-condition-registry.bend), [dependency-plan](../../src/ecs/dependency-plan.bend), [execution-deferred-settings](../../src/ecs/execution-deferred-settings.bend) |
| Compose schema fragments and checked feature provisions | [schema-fragments](../../src/ecs/schema-fragments.bend), [feature](../../src/ecs/feature.bend), [execution-composer-schema](../../src/ecs/execution-composer-schema.bend) |
| Author commands through declared permissions | [execution-command-system](../../src/ecs/execution-command-system.bend), [execution-command-permission](../../src/ecs/execution-command-permission.bend), [execution-generalized-command-leaf](../../src/ecs/execution-generalized-command-leaf.bend) |
| Bind relation resources to the original World context | [execution-relation-schema-setup](../../src/ecs/execution-relation-schema-setup.bend), [execution-relation-context](../../src/ecs/execution-relation-context.bend) |
| Read relations or author relation and lifetime-scope operations | [execution-relation-access](../../src/ecs/execution-relation-access.bend), [execution-lifetime-scope-command](../../src/ecs/execution-lifetime-scope-command.bend) |
| Use component states and retained machines | [execution-machine-component](../../src/ecs/execution-machine-component.bend), [execution-machine-access](../../src/ecs/execution-machine-access.bend) |
| Publish and read owned event families | [execution-event-family](../../src/ecs/execution-event-family.bend), [execution-event-ops](../../src/ecs/execution-event-ops.bend) |
| Inspect actual owners without advancing system cursors | [execution-inspector](../../src/ecs/execution-inspector.bend), [execution-inspector-application](../../src/ecs/execution-inspector-application.bend) |
| Save eligible data or stage and publish a restore | [execution-save-plan](../../src/ecs/execution-save-plan.bend), [execution-save-world](../../src/ecs/execution-save-world.bend), [execution-save-gate](../../src/ecs/execution-save-gate.bend), [execution-restore-stage](../../src/ecs/execution-restore-stage.bend), [execution-restore-publication](../../src/ecs/execution-restore-publication.bend) |
| Use explicit application-owned recovery | [recoverable-component](../../src/ecs/recoverable-component.bend), [execution-recoverable-component](../../src/ecs/execution-recoverable-component.bend) |

The [scheduled-health application](../../examples/scheduled-health/README.md)
starts with declaration-derived access and retained command and query owners.
The [captured-query application](../../examples/captured-query/README.md) shows
partial writes after a returned error, affine capture retention, and `Changed`.
The [original mixed applications](../design/execution-original-applications.md)
retain their actual owners through explicit recovery, event publication, graph
commands, and passive inspection. AppB deliberately selects serial execution
and observes its pending machine state without applying a transition.
The modules above preserve the distinction between trusted schema setup and the
abstract capabilities available inside a system body.

## Legacy source removal

The obsolete transactional query runners, `transaction`, `ordinary-system`, and
their ordinary application execution adapters are removed from current package
source. Shared component, resource, machine, event, and relation metadata retain
their original nominal type identities for replacement consumers.

The historical simulation and Workshop callers remain available with their
runtime at the [qualified source revision](https://github.com/dearlordylord/bendvy/tree/1037bab017fcc8037c518fa5d89dfa0c28e9ee30).
Their scenario, reference, expected data, and verifier files retain their original
contract. The old rollback checkpoints do not qualify the replacement executor.

The original parallel-composition consumer now uses the retained Taskful Feature
assembly. The obsolete `feature-legacy`, `schedule-provision`, `schedule` and
`system` executor island is removed from package source. Public Feature metadata,
pure `feature-provision` declared-access binding and current registration lifecycle
operations remain available; the application-owned AppA Journal recovery is
separate from ordinary execution. Historical fixture builders retain their
[original source checkout](../../test-fixtures/HISTORICAL.md).

The unconsumed old owned-event staging, Array journal, single-column recovery,
and bundle installation and undo modules are also retired. Their module paths no
longer appear in the package. The live explicit recovery facility consists of
`recoverable-component`, `execution-recoverable-component`, and `recovery-journal`.
AppA calls it directly before ordinary gameplay. It does not determine the Root
schedule's error or publication policy.

The BendHub exporter includes all remaining source files under `src/ecs`, even
when the aggregate does not import them. Remaining pure helpers have not been
classified as obsolete merely because current applications do not import them.
This source removal does not establish successful execution of every current
consumer or extend the five approved helper laws to the whole ECS.
