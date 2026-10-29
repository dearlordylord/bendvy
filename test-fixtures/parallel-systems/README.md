> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# Systems over retained physical owners

The gameplay bodies receive abstract capabilities. Library code registers the
actual `Sys.Owner` values, derives access metadata from their closed Programs,
detaches administration from one World, and returns the actual affine owners.

| Entry | Behavior | Independent oracle |
| --- | --- | --- |
| `main.bend` | Two physical halves, body error after writes, foreign World refusal | `reference.py` |
| `scheduled.bend` | Ordinary sealed registry and ready-group schedule for two halves | `scheduled-reference.py` |
| `overlap.bend` | Three actual systems; IDs 1 and 3 share the same Position and Counter owners, ID 2 owns independent storage | `overlap-reference.py` |
| `overlap-conditions.bend` | A registered condition reads that same Position before ID 2; disabled and error outcomes retain condition Local | `overlap-conditions-reference.py` |
| `overlap-getters.bend` | A heterogeneous same-owner leaf reads through writable capabilities without modifying the owner or its lifecycle stamp | `overlap-getters-reference.py` |
| `overlap-refusal.bend` | A second factory-created World refuses all three original owners and retains their Local and cursors | `overlap-refusal-reference.py` |
| `query-native.bend` | Serial root scheduling with parallel query traversal, actual output owners and command buffers | `query-reference.py native` |
| `query-serial.bend` | Serial root scheduling and serial query traversal over the same owners | `query-reference.py serial` |

The system entries run two nominal schemas in serial and native mode. The root-cut
schedule derives both body and condition footprints from the same closed
registration source. Its scope tree threads one physical owner serially through
same-owner leaves. The root cut can fork independent physical scope trees.
Conditions finish before the selected group starts. All group body completions
are retained before error handlers can escalate.

Observations include all 32 slots in each column, actual payload tokens and
values, lifecycle stamps, capacities, resources, Local tokens and counters,
cursors, live handles, allocator slots and order, registration metadata, the
clock and its run scopes, namespace, pending commands, and event counts. The
Python models import no candidate source and do not execute the implementation.

The original condition baseline caught a preserving read that marked the
component changed at tick 10. Its failure receipt remains retained. The cached
Data-view successor matches the unchanged last-write expectation at tick 9 in
finite JS and native development runs. The writable-capability getter case
separately expects its last write at tick 7 after a getter at tick 9. These
expectations have not been changed to accept getter-induced writes.

`overlap-native.bend` and `overlap-serial.bend` each execute only one schema and
one World. They isolate the semantic path for worker diagnostics. Configuring
several workers does not prove that several workers execute the bodies.
`instrument-workers.py` is a source-hash-bound offline C transformation with
boundary controls in `test-instrument-workers.py`. It marks exact generated
semantic cases and a scoped native fork branch; applying it does not launch a
diagnostic. Instrumented compilation and execution require the workflow's
independent launch review. No diagnostic run has been claimed by this fixture.

The focused query entries each use one schema and one World. Their closed
declaration selects the query mode independently of root scheduling. Two runs
update both live matching rows, retain the row error and author four commands
through the actual affine query output. The full oracle observes publication,
the returned queue, receipts, owners, caches and lifecycle stamps. Parallel
traversal crosses three branch nodes per run. The diagnostic therefore expects
four owner updates, four lifecycle writes, four insertions and six query forks
at four workers. Serial traversal and the one-worker fallback expect no query
forks. Actual worker participation remains a separate measured requirement.

Check an entry with `scripts/bend-check test-fixtures/parallel-systems/ENTRY.bend`.
Regenerate its oracle with the corresponding Python model. Compare complete
JavaScript and native stdout through the existing reviewed execution recipe,
with a matching compiler/resource bundle and complete source bindings.
Deferred publication and commands remain with their owning follow-up issues.
