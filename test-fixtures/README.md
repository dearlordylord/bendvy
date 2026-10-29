# ECS fixtures and preserved source

Current replacement fixtures and historical runtime fixtures have different source
contracts. Historical runtime imports deliberately do not resolve against the
replacement core. They are not current compilation targets or replacement
acceptance evidence. See [historical replay](HISTORICAL.md) before running them.

| Fixtures | Source contract |
| --- | --- |
| execution-* | Current replacement implementation, including the five approved helper laws and separate unapproved law drafts; each directory retains its own approval status |
| actor-lookup-boundaries, chunk-column, common, component-read-custody, dependency-schedules, parallel-systems | Retained current source fixtures; import closure is present, which does not establish successful compilation or execution |
| diagnostic-refusals | Preserved diagnostic text consumed by scripts/test-retro-controls.py; no Bend runtime import |
| connected-performance, ordinary-app, public-clock-events, public-clock-system, public-inspect, public-save-pending, public-schedule-readers, public-schedules, public-scopes, query-composition, query-pair-v1 | Historical runtime cohorts; use their original source checkout |
| public-nested-provision, public-schema-fragments | Original provisioning/benchmark cohorts; preserved with historical replay, not replacement qualification |

The five approved execution helper laws remain byte-for-byte unchanged. Other law
directories do not inherit their approval. Original benchmark models, expected
outputs, capability controls and diagnostic evidence remain preserved; they do not
assert compatibility with ordinary execution after its transactional API removal.

Normal CI continues to compile and execute the current runnable examples through
`examples/check.sh`. Import availability alone does not discharge Native execution,
machine execution or any other outstanding capability gate.
