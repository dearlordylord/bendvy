# Affine chunk storage consumer

This development consumer grows an empty column to cover 24 slots, inserts nested
affine owners at slots 1 and 17, and increments only slot 17. Its observation
projects both retained token owners, both values, and the absent slot 8.

The expected line follows directly from those operations. Token 101 retains value
10. Token 202 retains its identity and changes from 20 to 21. Slot 8 remains empty.

Run the existing example execution functions from the repository root.

```bash
export BEND=/home/node/.bend/bin/bend-2.0.35
source examples/common.sh
example_emit test-fixtures/chunk-column/main.bend /tmp/chunk-column.js
example_node /tmp/chunk-column.js > /tmp/chunk-column.stdout
cmp test-fixtures/chunk-column/expected.stdout /tmp/chunk-column.stdout
```

This consumer covers storage behavior. It does not establish ordinary query
execution, unlike-family alignment, native worker use, or the full acceptance
criteria of issue 81. Those require the integrated ordinary application.

## Run the aligned query consumer

`query.bend` runs two passes over unlike affine input and output families in
32 slots. Slots 1 and 17 contain both families. Slot 31 contains only output.
The entire chunk at slots 8 through 15 is empty.

Each body directly increments its output's nested token array and adds the input
step to the output value. The body at slot 1 then returns a handled error.
Both passes retain that mutation and continue to slot 17. The input owner stays
501 with step 3. Output owners become 103 with value 16 and 204 with value 30.
The unmatched output stays 303 with value 30. The first output's added tick
stays zero, and its changed tick becomes two.

The first three lines compare serial execution, parallel execution, and parallel
execution under a second nominal schema. The last line refuses mismatched tree
layouts before any body runs. It retains the incoming output owner 900 and value
99, with both original ticks zero.

The retained matching compiler bundle has a regular copy of the pinned compiler
and a resource inventory in its existing `BUNDLE-PROOF.json`. Revalidate its
compiler and resource hashes before reusing it. The installed resources can
change separately from the preserved compiler executable.

```bash
export BEND=/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35
export CLANG=/tmp/bendvy-clang19-diagnostic/clang19
export BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root
source examples/common.sh
example_emit test-fixtures/chunk-column/query.bend /tmp/chunk-query.js
example_node /tmp/chunk-query.js > /tmp/chunk-query-js.stdout
cmp test-fixtures/chunk-column/query.expected.stdout /tmp/chunk-query-js.stdout
example_emit test-fixtures/chunk-column/query.bend /tmp/chunk-query.c
timeout --signal=KILL 120s "$CLANG" -O3 /tmp/chunk-query.c -o /tmp/chunk-query.native -pthread -lm
timeout --signal=KILL 5s /tmp/chunk-query.native --threads 1 --gpu off > /tmp/chunk-query-native1.stdout
cmp test-fixtures/chunk-column/query.expected.stdout /tmp/chunk-query-native1.stdout
timeout --signal=KILL 5s /tmp/chunk-query.native --threads 4 --gpu off > /tmp/chunk-query-native4.stdout
cmp test-fixtures/chunk-column/query.expected.stdout /tmp/chunk-query-native4.stdout
```

The negative fixtures share the otherwise well-formed query consumer. Check them
with the existing `scripts/bend-check` wrapper. `negative-schema.bend` must reject
`Column<Second,Output>` where `Column<First,Output>` is required.
`negative-duplicate.bend` must reject copying the affine column as `Data`.
`negative-write-through-read.bend` must reject an affine input-owner parameter
where gameplay receives only its reusable `U32` projection.

The query consumer calls the storage traversal directly. It does not establish
ordinary registered-system integration, all public authority boundaries, every
slot's full observation, or actual work on multiple native workers. Running with
four workers alone does not establish worker use. Those remain issue 81 gates.
