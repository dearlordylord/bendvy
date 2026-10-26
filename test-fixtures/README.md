# Executable ECS fixtures

Retained because current code executes these scenarios, not because of their history.
No historical receipts, copied libraries, compiler outputs or evidence object stores.

| Fixtures | Current consumer / reason |
| --- | --- |
| public-nested-provision, public-schedule-readers, public-schema-fragments | benchmarks/parity-features: composed provisioning, readers and fragment workloads |
| public-scopes/feature-timing-v1 | benchmarks/parity-features: scope lifecycle and cleanup workload |
| public-inspect/graph-stream-public-bridge-v1/feature-timing-v1 | benchmarks/parity-features: complete runtime Inspector workload |
| public-schedules/named-app-v1 | benchmarks/parity-features: named schedules and debug overhead workloads |
| query-composition/public-controls | scripts/query-controls.py: positive and rejected public capability usage |
| ordinary-app | docs/reference/ordinary-app.md: component-query and service-counter consumer |
| diagnostic-refusals | scripts/test-retro-controls.py: distinguish parser/arity failures from intended type refusals |

Remove a fixture when its current consumer is removed. New fixtures need a concrete
behavior and a runnable consumer; archived execution alone does not qualify.
Relocation invalidates old source/path-bound receipts; reruns must freeze current inputs.
