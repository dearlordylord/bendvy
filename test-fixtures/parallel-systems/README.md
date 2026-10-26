# Retained owners across a physical system partition

`main.bend` runs two nominal schemas through the public typed parallel App facade.
Each App owns one World with two independent component columns and two affine
resources. The gameplay bodies receive abstract capabilities. They do not split
storage, dispatch tasks, or reassemble the World.

Each schema executes three runs in serial and native mode. The left body returns
an error after its second component and resource writes. The right body still
runs, and both bodies run again. A World returned by a second creation then
refuses the original registered owners before either body runs. The observation
includes every slot and lifecycle stamp in both 32-slot columns, payload and Local
tokens, cursors, resources, administrative time, pending work, and registration
and live-entity counts. `reference.py` derives `expected.stdout` from this scenario
without importing Bend source or executing the candidate.

This fixture covers the typed physical partition and retained-owner facade.
Dependency ready groups, conditions, conflicting accesses, and the ordinary
Schedule integration remain separate required gates for #80. Running with several
configured workers alone does not prove that several workers execute the bodies.
A source-bound runtime-worker diagnostic remains required. Deferred publications
and commands remain with their owning follow-up issues.

Check the entry with `scripts/bend-check test-fixtures/parallel-systems/main.bend`.
Regenerate its oracle with `python3 test-fixtures/parallel-systems/reference.py`.
Compare complete JavaScript and native stdout with `expected.stdout` through the
existing reviewed execution recipe and a matching compiler/resource bundle.
