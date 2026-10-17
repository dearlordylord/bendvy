# Run a health simulation with registered systems

This example creates three entities and runs six ticks on JS or Native.
The query declares `write Health` and `read HealthDecay`. Its accesses and
registration metadata come from those declarations. A registered system runs
in an explicit schedule with a barrier before each tick.

From the repository root:

```sh
bash examples/scheduled-health/run.sh js
bash examples/scheduled-health/run.sh native
```

The script prefers the workspace Bend 2.0.35 if installed, otherwise `bend` on
PATH. Node and Clang use PATH by default. Set `BEND`, `NODE` and `CLANG` to
select other binaries. With the private workspace Clang wrapper, also export
`BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root`.
Generated files stay in ignored `build/`. If another backend check holds the
shared lock, the script exits 75 without starting competing work.

Expected output, followed by a verification result:

```text
before-barrier=
tick=1 health=5,5
tick=2 health=2.5,1.25
tick=3 health=1.25,0.3125
tick=4 health=0.625,0.078125
tick=5 health=0.3125,0.01953125
tick=6 health=0.15625,0.0048828125
untouched=30
```

## Change the simulation

- [components.bend](components.bend) defines independent Health and HealthDecay.
- [main.bend](main.bend) creates the world through `world-io.create` and queues
  three entities. Change the starting health and decay factors here.
- [system.bend](system.bend) declares the query using `ordinary-query-declaration`
  and registers it using `ordinary-system.define`. `decay_body` receives an
  opaque owner and only its declared component capabilities.
- [application.bend](application.bend) runs the registered system before the
  barrier, then builds a schedule from the actual registration namespace/ID.
  Six runs of `[Barrier, System]` update the same world and registration owner.
- [schema.bend](schema.bend) contains typed column storage and deferred spawn.
  These explicit projections remain application setup; the example does not
  hide them behind a new wrapper or manually duplicate query metadata.

The third entity has no HealthDecay. The query skips it, and a final lookup
using its actual returned handle confirms Health remains 30. The first empty
result confirms that queued entities are invisible before the barrier.

`verify.py` independently calculates all six tick results and checks the full
output structure, including the excluded entity. Values are exact binary
fractions, so the check needs no numerical tolerance.

This covers registered query systems and the public `schedule` API. It does
not demonstrate the larger SchemaApp composer, resources, events, failure
rollback, or performance qualification. For direct query execution without
registration, see [Health decay](../health-decay/README.md).

Verified in this workspace on 2026-10-17: Bend 2.0.35, Node 24.20.0,
Clang 19 with `-O3`; full JS and Native outputs agree and pass the independent
finite model. Modified-tick and modified-sentinel controls are rejected.
This is correctness evidence, not a performance measurement.

## Remaining usability check

- [ ] Run a separate blind API audit with a fresh reviewer who has not read this
  example or the implementation. Give them the Bevy ECS model, Bend language
  sources and the public usage documentation; ask them to build the same small
  simulation and record where the documentation or API stops them. The current
  example was adapted from existing source and does not satisfy this audit.

The explicit dispatcher and column projections here are observations about this
registered-ECS example, not proven mandatory user boilerplate. Compare the
ordinary App composer before deciding whether a library change is needed.
