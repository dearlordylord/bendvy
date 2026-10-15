# Source derivation notes

The logical record order comes from `reference.mjs` and the frozen Bend `app.bend`, `category-run.bend`, `category.bend`, `setup.bend`, `reader.bend`, `union.bend`, `machine-condition.bend`, and `render.bend` sources.

## Lifecycle and category records

Each fresh `Workshop` or `Garden` schema declares `Cells`, `Sibling`, `Owned`, `SiblingOwner`, `Pulse`, `Link/LinkedBy`, and `Parent/Children`. Setup reserves and activates three entities, stores the two component payloads, adds `1 -> 2` and `3 -> 2` for both relations, applies `Flow 4 -> 7` and `Level 10 -> 11`, and queues a `Parent 2 -> 3` hierarchy-cycle rejection. The pending stage also reserves entity 4 and leaves the pending state transition request in the world.

The category order is `Link` then `Parent`; within each relation it is `required_out`, `optional_out`, `present_out`, `absent_out`, `required_in`, `optional_in`, `present_in`, and `absent_in`. Each mode emits an `inspect` record for a fresh `first` inspector and a fresh `second` inspector, then a `check-noop` record for each corresponding condition pass. The seeded graph yields the same logical relation rows for both schemas and both relation declarations. The condition expected counts are the source's row counts, so all four check fields (`called`, `allowed`, `ran`) are true.

## Machine records and failure stream

After categories, each schema emits fresh `machine-inspect` records for `first` and `second`, one `machine-check-noop`, and one `registered-stream-read`. The machine projection reports `Flow = 7`, `Level = 11`, their `4 -> 7` and `10 -> 11` transitions, and the four-cell optional relation projection. The setup cycle mutation is rejected by the hierarchy relation. `Read.map_world`/`Ev.with_world` synchronizes the queued failure before machine inspection; fresh Union inspectors start at cursor zero, and the registered reader observes the later failure after its warm cursor.

The source-derived failure object is:

```json
{"relation":"Parent","related":"Children","kind":"hierarchy","linked":true,"allowSelf":false,"ordered":true,"operation":"relate","source":2,"target":3,"error":{"kind":"HierarchyCycle","entity":2,"target":3,"relation":"Parent"}}
```

The source maps the relation's qualified name to its final component name and maps error fields `_tag`, `entityId`, and `targetId` to `kind`, `entity`, and `target`. No failure or stream field is inferred from generated output.

## Scope

The logical `run(count)` output is shared by the frozen Bend source and the independent TypeScript reference at the declared record level. The app's separate physical report retains actual runtime worlds, event batches, reader registrations, stream positions, cursors, and debug snapshots. Those fields are backend-specific and are not collapsed into this logical oracle; any physical diagnostic must be derived and checked separately for the backend that produced it.
