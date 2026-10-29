# Health decay

Three entities demonstrate independent `Health` and `HealthDecay` components.
The first two start at 10 × 0.5 and 20 × 0.25. The third has health 30 and
no decay component, so the required-component query skips it.

The component relationship follows [Bevy's contiguous-query example](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/examples/ecs/contiguous_query.rs).
Bendvy uses ordinary per-entity access rather than contiguous slices.

The application now uses the ordinary replacement execution path. The spawn
system authors real deferred commands. The decay system declares a write query
for Health filtered by HealthDecay and a read query for HealthDecay. Registration
retains both compilations and actual system owners across ticks. The generalized
Root derives planning and capabilities from those declarations and returns the
actual application after execution. No application code splits the World.

The first run suppresses dependency and final deferred application. Its query
therefore sees no spawned rows. The next two runs enable automatic dependency
publication, then multiply each selected Health by its own HealthDecay factor.
A passive inspector reads the resulting components through full entity handles.

From the repository root:

```sh
bend examples/health-decay/main.bend
```

Expected output:

```text
before-barrier=
tick-1=5,5
tick-2=2.5,1.25
```

- [components.bend](components.bend) defines the values and original seed payload.
- [schema.bend](schema.bend) defines the nominal schema and independent owners.
- [spawn.bend](spawn.bend) declares and authors the three deferred spawns.
- [system.bend](system.bend) declares and performs the required read/write query.
- [registration.bend](registration.bend) retains compiled system bindings.
- [root.bend](root.bend) connects canonical execution and command publication.
- [observe.bend](observe.bend) passively observes selected and skipped entities.
- [application.bend](application.bend) runs the original three observations.

The [browser demonstration](demo/README.md) uses the same owners, declarations
and Root. Its initial run publishes the seeds at the final boundary before
rendering the initial values. Each Tick then runs the decay system.

`bash examples/health-decay/check.sh` compiles and runs the CLI, compares its
three output lines with `expected.stdout`, and builds the browser API. It does
not execute the browser adapter.

The CLI and browser API were emitted and run on JavaScript after migration.
These are finite application observations, not formal proofs. The preserved
legacy smoke files use the earlier synchronous API. Their source binding is
documented in the [browser demonstration](demo/README.md).
