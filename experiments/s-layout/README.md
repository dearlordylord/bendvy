# S-LAYOUT — owned indexed storage investigation

[Issue #16](https://github.com/dearlordylord/bendvy/issues/16),
[SPEC](../../docs/SPEC.md). **Research deliverable verified; final performance capability not passed.**
Bounded experimental implementation; no ECS proof,
production adoption, universal confinement/refinement or performance acceptance.

## Reproduce

```sh
BENDVY_CPU=11 python3 experiments/s-layout/verify.py
BENDVY_CPU=11 python3 experiments/s-layout/run.py
BENDVY_CPU=11 python3 experiments/s-layout/owned-measure.py
```

Existing Bend 2.0.34, Base, clang 14 -O3, Node 24 and Python only; no dependencies
installed. Reference execution uses the absolute pinned original checkout, which
is read-only. Each checker has an explicit five-second deadline; code generation
30 s, clang 120 s, semantic runtimes 5 s, benchmark runtime 15 s. Native workers 1/GPU off;
JS/TS single event loop. Optional CPU 11 affinity avoids sibling workers; shared
host activity and clock granularity remain limitations. The initial prototype
preceded persistence of candidate guarantees; no law-first history is claimed.

## Representation, ownership and limits

`core.bend` owns one `Array<Row>` of 2048 slots. Row's fields are Data; Array and
World are Type. A checked logical ID maps to reversed physical slot
`limit - 1 - id`; every dynamic array access goes through `id < limit`, and
setup checks `limit <= 2048` before filling. Tested n 64/256/1024 and capacity 2048;
2049 and U32.max capacities reject before array filling. Valid clocks/round counts
in these workloads remain below U32 wrap. Fixed trusted constructors establish
array depth; this is not a theorem about arbitrarily fabricated malformed Worlds.

Sorted membership lists contain exactly component-present IDs, independent of
physical slots. Sparse rows retain live entities with absent components. Initial
unreserved slots use a vacant sentinel in the identity fixture. Removal of a
component retains its entity; despawn sets its slot vacant. `identity.bend`
transfers namespaces from actual T05 single-lineage Factory creation, reserves
monotonically, binds commands to the handle's slot and checks namespace/bounds
before lookup. Explicit capacity/no-reuse here is a bounded probe, not approval
of eventual allocator reuse/exhaustion policy. Creating independent Factory roots
is still outside the bounded identity contract.

Commands remain pending across a next-schedule operation, then explicit flush
applies them FIFO. Indexed command execution delegates each actual singleton row
transition/log update to committed T08 functions and writes the resulting row back;
query traversal and storage are indexed. No direct overwrite plus fabricated
removal-count substitute is used. Membership head removal/insertion uses affine
continuations to avoid eagerly visiting the entire tail. General insertion/removal
can still traverse/rebuild membership; there is no general O(1) sorted insertion.
The benchmark churn targets ID 0, so it measures the favorable head case.

`relocation.bend` separately owns a row array and explicit ID→slot map. It moves
logical ID 1 from physical slot 1 into vacant slot 5, updates the map, checks ascending
ID/value queries, removes/reinserts that relocated component, and rejects occupied
or out-of-range targets. The stale-map compiling mutant loses the moved member and
is detected. Relocation/mapping costs are untimed and not included in the fixed-map
benchmark. Dynamic compaction plus indexed providers/readers is a future seam;
this implementation does not claim measured compaction or arbitrary slot reuse.

`owned.bend` separately stores genuine Type Cell/Payload elements in an owned
`Array<Maybe<Cell<Schema>>>`. It swaps a cell out with explicit None, calls a closed
application callback checked for arbitrary P, and restores the returned owner into
the same slot. Read callbacks receive numeric projections; write callbacks receive
two fresh setters and two fresh getters, never duplicated closures or raw payload
ownership. Each setter journals the actual old numeric field. Failure applies the
inverse journal to the original owned payload array; it cannot clone that Type
payload. Success clears the journal. Payload arrays have fixed four-slot depth;
slot 1 is the declared update, full snapshots verify slots 0/2/3 remain intact.
Successful structural removal transfers the cell out, projects its last value and
explicitly disposes that owner once, leaving None. General destructive rollback,
external IO disposal, captured state and allocation/mark rollback remain open.

Two nominal schema tokens (Motion/Health) share this fixed owned-column shape;
paired controls instantiate actual indexed read provisioning on both. They cover
write through read, undeclared concrete getter, foreign schema token, fabricated
cell and reconstruction from observed data; each is paired with a working read.
The runtime executes legitimate writes on both schemas. This is finite confinement
evidence, not universal parametricity or a general multi-component schema planner.

## Semantic evidence

`verification.json` contains fresh exact Native/JS/actual pinned TS transcripts:

- 17 owned-payload checkpoints: prior successful commit, two attempted writes,
  failure restoration, retry, full four-slot snapshots and structural disposal;
- 21 independent reader checkpoints on indexed rows: fast/slow registration,
  added/changed/removal/despawn/message observations, failed read/retry and skip
  advancing only message positions; both reader positions remain independent;
- 12 lifecycle checkpoints: pending/no implicit flush, live, remove and reinsertion,
  FIFO overwrites, ID bounds, despawn and the internal bounded no-reuse control;
- nine relocation checkpoints, with the five logical query projections compared to
  actual TS (its physical layout is not asserted);
- foreign same-schema colliding-ID lookup yields MissingEntity while actual TS
  resolves local7: the explicitly approved divergence, validated separately.

The semantic reader adapter materializes Data row projections for T08's actual
reader wrapper and restores the indexed world owner. Timed message work remains a
minimal immediate log microkernel, not a two-reader schedule performance claim.
Full generic reader/schedule/provider/Type-payload composition remains S-INTEGRATE.

Meaningful compiling mutants target selected-reader and skipped-reader routing, slot mapping, query order, no-op attempted
write, absent rollback, absent churn, stale relocation map, wrong inverse-journal
order and absent owned restoration. Native and JS agree on each divergent result;
parse/type failures are not credited. Ten newly executed paired provider controls
are recorded with their exact positive/negative sources and diagnostics in
`controls.json`; prerequisite probe passes are not substituted for this acceptance.

## Measurements

`results.json` compares the indexed candidate with freshly built committed T10
list and actual bevy-ts, six Data kernels × 64/256/1024, 2000 rounds. Every exact
input and every timed sample checks ordered final IDs/values plus the relevant
query/reader/attempted-write/removal count. Failed writes observe actual newly
stored values before restoring the inverse journal, so replacing the setter with
identity is detectable. Separate untimed reader/lifecycle/owned controls inspect
intermediate success/failure/retry and preserve earlier commits.

Three fresh-world warmups run in each process, five samples in fixed-seed randomized
backend order. Build/setup/initial flush are outside the timed region; final exact
projection is inside. Bend IO.now has 1 ms granularity; zero/sub-ms timings are
unresolved, never infinite speedups. Raw samples, ranges, zero-round costs, compiler,
Base/source/reference pins and exact observations are retained. Earlier timings
were invalidated and freshly rerun after making churn real, recording actual own
reads and avoiding eager membership-tail work.

`owned-results.json` separately measures two cells with genuine four-slot Type
payload arrays: one earlier commit, 10000 failed systems with two writes and actual
own-read observation, restoration and earlier-commit retention. It compares indexed
Native/JS, a new T04-style owned linked-list counterpart using the same Cell
operations/callbacks, and actual TS. This owned list is explicitly distinct from
committed T10's Data list. It has the same three warmups/five randomized samples;
no affine/list result is inferred from Data-row timings. Median owned-kernel times
are 3 ms indexed Native, 18 ms indexed JS, 2 ms owned-list Native,
13 ms owned-list JS and 48.709 ms actual TS. The indexed two-cell
provider is slower than the owned-list counterpart on both targets; it is a
bounded ownership result, not evidence that indexing helps a two-cell world.

RSS is wait4's exact child-lifetime ru_maxrss, including the inherited Python
launcher before exec, setup/three warmups, VM/JIT and allocator retention. It is
neither per-component bytes nor runtime-only allocation; the inherited floor can
dominate native. Benchmarks compare equivalent logical observations but trusted
Bend storage primitives omit TS's public scheduling/provider/transaction overhead;
owned kernels separately include their bounded abstract provider. These are
prototype comparisons, not representative full-core or game acceptance.

### Measured Data tradeoffs

| Data workload | Size | Indexed Native / JS ms | List Native / JS ms | TS ms |
| --- | ---: | ---: | ---: | ---: |
| dense | 64 | 1 / 6 | 2 / 4 | 5.542 |
| dense | 256 | 7 / 27 | 7 / 23 | 17.704 |
| dense | 1024 | 44 / 114 | 41 / 98 | 37.208 |
| sparse | 64 | 1 / 1 | 1 / 2 | 5.362 |
| sparse | 256 | 1 / 4 | 5 / 12 | 4.214 |
| sparse | 1024 | 4 / 16 | 37 / 51 | 11.203 |
| update | 64 | 2 / 4 | 10 / 3 | 21.538 |
| update | 256 | 12 / 14 | 35 / 21 | 71.106 |
| update | 1024 | 49 / 101 | 204 / 276 | 394.145 |
| churn | 64 | 1 / 9 | 29 / 13 | 27.585 |
| churn | 256 | 1 / 9 | 53 / 41 | 26.53 |
| churn | 1024 | 1 / 6 | 456 / 229 | 24.6 |
| events | 64 | 2 / 7 | 1 / 3 | 35.785 |
| events | 256 | <1 / 7 | 1 / 2 | 33.055 |
| events | 1024 | <1 / 1 | 1 / 1 | 37.362 |
| rollback | 64 | 9 / 9 | 22 / 5 | 63.765 |
| rollback | 256 | 30 / 29 | 66 / 67 | 118.106 |
| rollback | 1024 | 105 / 307 | 320 / 307 | 249.914 |

At 1024, indexed dense is slower than TS on both Native (44 versus 37.208 ms) and
JS (114 versus 37.208 ms); its final query/formatting path still scales with all
members. Sparse skips holes and improves over list, but JS remains slower than TS
(16 versus 11.203 ms). Update improves both baselines on these inputs. Native rollback
improves, while JS rollback remains slower than TS (307 versus 249.914 ms). Head churn
now avoids eager tail traversal; its 1 ms Native result cannot support a precise
multiplier. Immediate-message Native results below 1 ms are unresolved microkernels.
No average hides these regressions. Large sample ranges on the shared host prevent
interpreting the medians as stable production thresholds; raw dispersion is retained.

## Decision and next interface

Read per-workload medians/ranges in the raw JSON before choosing storage. Favorable
sparse/update/rollback kernels do not remove dense/query or other regressions, and
head-churn and immediate-message results do not establish general throughput.
Native substantial improvement and JS comparability remain mandatory for the final
product; numerical thresholds are still unapproved. No production layout is adopted.

Proposed integration interface returns the world owner beside observations, retains
abstract schema-specific handles, checks namespace/ID→slot correspondence before
access, exposes declared projections/two-write inverses rather than cloning Type
payloads, stages publications until success and preserves independent change/message
positions. Integrate only actual required seams: dynamic map/relocation and ordered
membership, identity/capacity, rollback allocations/marks/publications, independent
registered readers and closed repeatable systems. S-CAPTURE governs restoration of
captured or destructive affine state; it is not a blanket dependency for numeric
owned-payload research. General laws/proofs wait for the separately reviewed #12
package and exact human approval. Relations/states/tooling and copied Tower Defense
integration remain in full scope; the original jev repository was untouched.
