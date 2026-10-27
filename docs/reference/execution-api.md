# Replacement execution API

The ordinary execution contract is the [SPEC replacement amendment](../SPEC.md#ordinary-execution-replacement-user-amendment-2026-10-26-utc).
The implementation and remaining acceptance work belong to
[issues #78 through #94](https://github.com/dearlordylord/bendvy/issues/77).
This page names the current source entries. It does not mark those issues complete.

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
The modules above preserve the distinction between trusted schema setup and the
abstract capabilities available inside a system body.

## Legacy source removal

The `ordinary-app-*`, `ordinary-system`, `compose`, `schedule`, and `transaction`
modules describe the superseded ordinary execution path. They are not the entry
for new application code. Historical examples and evidence retain their original
source and contract.

`component.bend` retains its original family, access, replacement, and result
types. Its historical transaction operations are in `component-legacy.bend`.
`relation-failure-reader.bend` retains the original relation declaration metadata.
Its historical System registration is in `relation-failure-reader-legacy.bend`.

Removal of legacy source is still incomplete. Shared resource, machine, and event
modules still import legacy execution definitions. The BendHub exporter includes
all source files under `src/ecs`, even when the aggregate does not import them.
Changing the aggregate alone therefore does not remove the legacy package files.
