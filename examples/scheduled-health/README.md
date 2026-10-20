# Run a health simulation with registered systems

This example creates three entities and runs six ticks on JS or Native.
The query declares `write Health` and `read HealthDecay`. The ordinary App entry derives dispatch, registration identities, cursors, and the schedule from the retained registration. A barrier applies queued entities before each tick.

From the repository root:

```sh
bash examples/scheduled-health/run.sh js
bash examples/scheduled-health/run.sh native
```

Use Bend 2.0.37 (`bend` on PATH by default). Node and Clang use PATH by default. Set `BEND`, `NODE` and `CLANG` to
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
- [system.bend](system.bend) defines the opaque-owner `decay_body` and operational component identities.
- [registration.bend](registration.bend) binds those identities to the observable query and calls `Component.add`. Its type aliases name the library-derived owners, observations, plan, dispatcher, and availability observer.
- [application.bend](application.bend) calls the primary `Entry.attach`, `Entry.run`, and `Entry.replan` route. It retains each returned App for the next tick. It does not implement numeric-ID dispatch or cursor transport.
- [schema.bend](schema.bend) contains typed column storage and deferred spawn. These explicit projections remain application setup.

The third entity has no HealthDecay. The query skips it, and a final lookup
using its actual returned handle confirms Health remains 30. The first empty
result confirms that queued entities are invisible before the barrier.

`verify.py` independently calculates all six tick results and checks the full
output structure, including the excluded entity. Values are exact binary
fractions, so the check needs no numerical tolerance.

The [ordinary App guide](../../docs/reference/ordinary-app.md) describes the primary entry without this simulation's solution. Standalone System and Schedule remain available as lower layers.

The [heterogeneous qualification](../../experiments/public-api-usability/health-v2/README.md) adds a separately observed service system, a second nominal schema, affine component and Local owners, provisioning repair, failure, and authority controls. Those finite checks do not establish performance qualification or complete ECS parity.

## Remaining usability check

- [ ] Run a separate blind API audit with a fresh reviewer who has not read this example or the implementation. Give the reviewer the Bevy ECS model, Bend language sources, and the public ordinary App guide. Ask them to build the simulation and record any API or documentation blockers. This source-informed example does not satisfy that audit.

The original [API investigation](../../experiments/public-api-usability/health-v1/README.md) remains historical prototype evidence. Ordinary entry adoption is tracked in [#73](https://github.com/dearlordylord/bendvy/issues/73).
