# Independent public ECS consumer

Run from the repository root:

```sh
python3 experiments/user-api/fresh-consumer/check.py
```

The independent application was authored against public pin `7279c98`, then
the public restricted damage addition `2a31548`. Only public source declarations
and their README were supplied; no gameplay body was copied. Reference study
used the pinned absolute `.references/bevy`, `.references/bevy-ts` and
`.references/bend2` locations in the primary checkout. The isolated worktree
does not carry those excluded reference directories.

`arena.bend` supplies four nominal component families: Position, Velocity,
Health and Armor. Every component owns an actual `Array<U32>` and has kind
`Type`. Schema-local closed lenses and ownership-preserving projections are
trusted provisioning. Gameplay consists of two independently authored closed
rank-2 callbacks. They see abstract affine contexts and erased operations,
without destructuring a concrete context, world, store or journal.

Movement declares Position write, Velocity read and resource read. Damage
declares Health write, optional Armor read, Hit emission and current-entity
despawn. Damage does not use its granted despawn. Both registrations are reused
through the public affine `System.run` result. Trusted setup reserves and
activates entities through public World operations and populates families
through public Component replacement. No application-owned journal exists.

Two actors start with `(position, velocity, health, armor)` values
`(0,2,30,2)` and `(10,1,20,absent)`. Resource delta is 2. The six runs are
movement, damage, movement, damage, failing damage, retry damage. Damage removes
`5 - armor` health and emits Hit before its optional failure. All three execution
lanes produce:

```text
SSSSFS:position1,position2,health1,health2=8,14,21,5,events=6
```

The final Health values distinguish rollback from retaining the failed write;
the event count distinguishes discarding the failed emission from publishing
it. Both armored and unarmored actors participate in successful damage runs.
The native lane compiles the generated C with Clang `-O2 -pthread -lm`; the
JavaScript lane imports the generated module and invokes the same `scenario`.
The receipt records commands, output, exits, elapsed time and source hashes in
`evidence/results.json`. Every Bend invocation is wrapped in `timeout 5s`.

Five separate expected compile failures test abstract-context undeclared
access, using a read operation as a setter, cross-schema handles, copying a
Type component owner, and changing a registry to a different closed runner with
the same argument type. These are type-shape controls, not universal authority
proofs or runtime attack coverage.

Actual failed authoring attempts were retained here:

- Destructuring the computed pair `get(ctx)` was rejected by Bend's parameter
  scrutinee rule. Dedicated parameter helpers corrected the shape.
- A projector declared with a reusable parameter did not match the ordinary
  resource-projector function signature. An ordinary input with a local
  reusable Data view corrected the signature.
- Reusing an unmarked Data handle in provisioning failed the affine usage
  check; its binding was marked reusable.
- The first registry control merely forwarded the exact same runner and was
  accepted by definitional equality. The final control uses a different no-op
  runner and rejects. Renaming a definition is not a behavior change.
- Direct `bend ... -o binary` first succeeded within five seconds but a repeated
  invocation timed out during native compilation. The repeatable checker path
  emits C within five seconds and invokes host Clang separately; the checker
  limit was retained. This is not a performance measurement.

The final source uses the restricted damage entry point. The earlier broad
damage bundle also produced the same observed output in ordinary Bend, but
its transient run is not the final receipt or an additional acceptance claim.

Usability costs remain substantial: four family declarations require explicit
take/put/project/rest/token definitions; query calls repeat the same indexed
arguments; ordinary gameplay requires helper definitions for each sequenced
result; even restricted callbacks still require unused population, cleanup and
resource-projector template arguments. Schema-local wrappers help but do not
remove this authoring cost. Query composition remains a main/aux pair rather
than Bevy's general tuple and filter system. A marker beyond that pair cannot
be independently selected in the same query by this API.

This report establishes finite application execution and compiler controls.
It makes no new ECS law, proof, universal runtime refinement, production API,
Bevy parity, performance-threshold or full-core completion claim. Owned arrays
here each have one cell; large payloads, payload preservation across richer
updates, command visibility, cleanup execution, capacity failures, independent
world namespaces and heterogeneous schedules need separate consumer probes.
