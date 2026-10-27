# Bendvy 0.1.0.1 replacement execution entry.
# Import individual modules using the paths in docs/reference/execution-api.md.
# BendHub exports replace hyphens in source paths with underscores.
# scripts/package-bendhub.py still exports every source file in src/ecs.
# This entry selects current APIs; it is not a legacy-source exclusion manifest.
import Base
import ./world.bend as World
import ./world-io.bend as WorldIO
import ./execution-composer-layout.bend as Layout
import ./execution-composer-schema.bend as Schema
import ./execution-builder.bend as Builder
import ./execution-declaration.bend as Declaration
import ./execution-resource-program.bend as Program
import ./execution-system.bend as System
import ./execution-reservation-task.bend as Task
import ./execution-query.bend as Query
import ./execution-query-recipe.bend as QueryRecipe
import ./execution-resource-query-leaf.bend as QueryLeaf
import ./execution-resource-query-group.bend as Group
import ./execution-resource-query-composite.bend as Composite
import ./execution-parallel-scope-registry.bend as Registry
import ./execution-generalized-root-application.bend as Root
import ./execution-parallel-root-application.bend as Scheduled
import ./execution-condition-registry.bend as Conditions
import ./execution-deferred-settings.bend as Deferred
import ./dependency-plan.bend as Plan
import ./dependency-application.bend as Application
import ./feature.bend as Feature
import ./schema-fragments.bend as Fragments
import ./execution-command-system.bend as Commands
import ./execution-command-permission.bend as CommandPermission
import ./execution-generalized-command-leaf.bend as CommandLeaf
import ./execution-relation-schema-setup.bend as RelationSetup
import ./execution-relation-context.bend as Context
import ./execution-relation-access.bend as Relations
import ./execution-lifetime-scope-command.bend as LifetimeScopes
import ./execution-machine-component.bend as ComponentState
import ./execution-machine-access.bend as Machines
import ./execution-event-family.bend as Events
import ./execution-inspector.bend as Inspector
import ./execution-save-plan.bend as SavePlan
import ./execution-save-world.bend as Save
import ./execution-save-gate.bend as SaveGate
import ./execution-restore-stage.bend as RestoreStage
import ./execution-restore-publication.bend as RestorePublication
import ./recoverable-component.bend as Recovery
import ./execution-recoverable-component.bend as RecoveryOperations

def version() -> String:
  "0.1.0.1"
