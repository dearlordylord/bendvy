# Design decisions and investigations

Contract priority is **Rust Bevy architecture and ECS semantics, then Bend types,
ownership and runtime constraints, then bevy-ts feature coverage and porting
inspiration**. The [specification](../SPEC.md) records the binding decisions and
approval boundaries. Do not infer a new contract from an experimental layout.

| Subject | Design or contract | Evidence and limits |
| --- | --- | --- |
| Query selection, cardinality and access | [Public query contract](public-query-contract.md), [query composition](../reference/query-composition-contract.md) | [Query contract report](../reports/public-query-contract.md), [composition report](../reports/query-composition.md) |
| Affine components and closed capabilities | [User-system API](user-system-api.md), [owned query proposal](cohesive-owned-query.md) | [User-system evidence](../reports/user-system-api.md); proposals do not establish universal refinement |
| Persistent per-instance Local | [Selected Local policy](public-local-policy.md) | [Local report](../reports/public-local-owner.md); World rollback and Local persistence are separate |
| Schedule execution and independent readers | [Schedules](public-schedules.md), [event readers](public-event-readers.md), [removal readers](public-removal-readers.md) | [Schedules](../reports/public-schedules.md), [events](../reports/public-event-readers.md), [removals](../reports/public-removal-readers.md) |
| Storage and lifecycle cost | [Indexed lifecycle boundary](indexed-lifecycle-metadata.md), [indexed storage design](s-perf-indexed-storage.md) | [Lifecycle investigation](../research/indexed-lifecycle-metadata.md), [storage evaluation](../reports/s-perf-completion.md) |
| Captures, affine events and restore | [Capture ownership draft](../parity/captures-contract-draft.md), [affine events](../parity/affine-events.md), [basic restore](../parity/restore-basic.md) | Open decisions remain governed by their issues; this index makes no selection |
| Debug without repeated metadata declarations | [Ordinary schedule seam](../research/debug56-schedule-execution-seam.md) | [Debug capability](../parity/debug.md); a low-level adapter alone does not meet ordinary-user delivery |
| Native calling conventions | [Approved isolated Clang diagnostic plan](clang19-diagnostic-plan.md) | Private extraction approval is not performance acceptance or permission for a global toolchain change |

## Findings worth retaining

- Optimizing generated transport is useful only when the actual application
  reaches it. Trace callback ownership and emitted JS/C before selecting a change.
- Allocation traffic, live heap, peak RSS and elapsed time answer different
  questions. Fewer allocations do not establish a speedup; compare equivalent
  work with the unchanged observation oracle.
- Representation changes must preserve arbitrary affine payloads, identity,
  order, lifecycle visibility and exact rollback. A successful small fixture does
  not establish the general public API.
- Historical proposals to improve against an old Bend baseline are distinct from
  the agreed product goals against bevy-ts. Old time windows and attempt counters
  never authorize another run.

The underlying investigations, rejected alternatives and measurements remain in
the [performance archive](../archive/README.md#performance-investigations).
Other files in this directory remain subject-specific proposals or contracts;
their titles and governing issues determine approval status.
