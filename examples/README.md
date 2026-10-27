# Examples

Start with [Scheduled health](scheduled-health/README.md): world creation,
declaration-derived query access, retained command and query owners, an enabled
condition, automatic barriers and passive observations through the replacement Root executor.

| Example | Purpose | Execution style |
| --- | --- | --- |
| [Scheduled health](scheduled-health/README.md) | Application starting point | Replacement Root, retained declarations, deferred commands and passive Inspector |
| [Captured query](captured-query/README.md) | Affine capture, Changed query and error/retry sequence | Replacement Root, retained declarations and ordinary partial writes |
| [Health decay](health-decay/README.md) | Required-component query and deferred visibility | Replacement Root, retained spawn and query declarations, passive Inspector |
| [Health browser demo](health-decay/demo/README.md) | Interactive view of health decay | Browser host, actual retained application and compiled IO |
| [Arena](arena/README.md) | Playable browser simulation | Replacement Root, real spawn and despawn commands, required Body query |
| [Survivors](https://github.com/dearlordylord/bendvy-ecs-examples/tree/main/examples/survivors) | Vampire Survivors clone; combat queries and entity lifecycles | [Browser demo](https://nightfall-survivors-bendvy.leafyyew32.chatgpt.site) |
| [User simulation](user-simulation/README.md) | Historical transaction, event, and retry checkpoints | Qualified immutable source and original reference contract |
| [Workshop](query-composition/README.md) | Historical query composition and rollback checkpoints | Qualified immutable source and original reference contract |

The advanced regression stories retain their fixed reference checkpoints. Their
handwritten access lists and raw setup are not the application starting pattern.
Each linked README describes the actual API used and its verification command.

## Application APIs

Current applications use the replacement generalized Root executor. The same
compiled declarations retain operational capabilities and supply access metadata
for planning. Root retains system, guard, handler, and command owners between
updates. Returned body errors preserve performed writes and authored commands
under the selected error-handler policy.

The [replacement execution API](../docs/reference/execution-api.md) maps the
current schema, declaration, query, command, condition, inspection, and persistence
entries to their source modules. Start with the registered
[scheduled-health application](scheduled-health/README.md).

Raw storage lenses and arbitrary World callbacks belong to trusted setup. System
bodies receive the abstract capabilities produced by their declarations.
Applications retain and return affine owners rather than copying them.

## Historical applications

User simulation and Workshop preserve fixed reference checkpoints and their
original transactional contracts. Their Bend callers and runtime are retained
in the qualified immutable source linked by each README. Their remaining check
scripts run in that historical checkout, rather than against the replacement core.
Current implementation and acceptance work remains in
[issues #78 through #94](https://github.com/dearlordylord/bendvy/issues/77).

## Running examples

Each migrated example documents its current `run.sh` command and observable
results. These commands compile and run the actual application. Finite output
observations do not replace Bend laws or establish universal correctness.

The existing `bash examples/check.sh` discovers top-level directories with
`main.bend` or `game.bend` and runs each available `check.sh`. Health decay runs
its CLI output comparison and builds its browser API. Arena builds its browser
module without running gameplay or browser checks. Their legacy host checks are
preserved under the source bindings in each example's documentation and are not
invoked by these current runners. Read each example README for its exact coverage.

Set `BEND`, `NODE`, and `CLANG` to select installed tools. Existing Native
example checks use `BENDVY_EXAMPLE_NATIVE=1`. CPU pinning is optional through
`BENDVY_EXAMPLE_CPU`. No numerical performance campaign is part of this migration.
