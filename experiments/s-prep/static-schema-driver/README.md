# Static schema entry diagnostic

The frozen Motion64 driver calls `choose(0,256,64)`, but C emission includes both
schema branches before clang can propagate the constant. This diagnostic changes
only that main expression to `motion_batch(256,64)` (or the corresponding Health
entry). Both schema definitions remain in the book; all29 core modules, callbacks,
warmup, clock placement, entity/tick/batch counts and full outputs are retained.

```sh
python3 experiments/s-prep/static-schema-driver/materialize.py \
  --driver /tmp/fresh-build/batch.bend --schema Motion
```

The unique original entry is required; original/derived hashes and the recipe
hash are recorded next to the driver. Combined Native Motion check15/Cemit30/
clang120 pass with this entry, whereas the earlier mixed entry exceeded Cemit30.
Full65 observed worlds match fresh TS. This is diagnostic build recovery, not
approval to alter the canonical evaluator, skip schema coverage or claim a
qualified performance result. Health and the full product matrix remain open.
