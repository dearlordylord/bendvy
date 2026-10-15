# Bounded canonical-stream profiling subject

This fixed entry executes 1,024 actual publication operations in each of two
nominal schemas, obtaining worlds through real `WorldIO.create`. It provisions
real publisher/reader instances, executes Seed, performs one failing reader
activation, calls the existing `Core.loop(1024)`, then retains one complete
physical checkpoint per schema. It uses `Core.finish` and `IO.print`; no argv,
checksum, shortened payload or guessed world identity replaces observation.

`derive.py` uses the source-only Runtime/row model copied byte-for-byte from
independent oracle commit `df3845`. It derives all 1,024 ordered transitions,
physical World/owner fields, frame/tick and reader state for both namespaces.
Expected raw stdout is 33,072 bytes, SHA256
`c9f4249293942059ddcb3acbad7d65e9279d2de464d06adf9b902a3f7aee6c43`.
`python3 derive.py` checks source pins, full bytes and substantive invariants;
`--write` regenerates model artifacts without reading backend output.

`SOURCE.json` pins the actual 27-file consuming Bend closure, model and relevant
Base/print/World namespace effect sources. This is the queue candidate closure,
not qualification of a baseline. The coordinator must separately bind the
canonical batch-list baseline and its observational snapshot adapter, preserving
this same entry, Core operation bodies, count, full oracle and capture contract.
The sampled profile must compare complete same-count outputs; unequal partial
prefixes do not qualify that comparison.

The retained five-second check ends only at the expected four unsafe/foreign
WorldIO definitions (fresh, create, scenario and main). Raw diagnostics remain
in `check.stdout`/`check.stderr`. This is not an approved theorem or backend run.

This is a bounded diagnostic subject, not the 65,537 capacity acceptance gate,
a timing benchmark, an execution receipt, a speed claim or a new performance
criterion. No backend/profiler has run. CPU and allocation capture include the
same complete String rendering/output on both roles; samples are not RSS.
