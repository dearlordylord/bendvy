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
