# A query with retained owned state

This ordinary App runs two registrations: a read-only component audit and a query that retains two owned arrays. Both use library-generated registration, schedule and dispatch aliases. No caller supplies numeric system IDs, a cursor or routing code.

Run it from the repository root:

```sh
bash examples/captured-query/run.sh js
bash examples/captured-query/run.sh native
```

The output shows four checkpoints: initial state, deliberate failure on the second row, successful retry, and an unchanged run. On failure, both rows' component writes roll back while the owned capture keeps the changes made by both callbacks. The typed error includes the failed row's before/intermediate/after values. A failed run clears row outputs; retry retains both successful outputs. The last run's changed filter selects no rows, so its output list is empty and the capture remains unchanged.

Read the files in this order:

1. `payload.bend` defines owner-preserving projections for the component and affine capture arrays.
2. `schema.bend` defines the nominal schema, binding, seed and actual component observation.
3. `body.bend` declares read/write capabilities and the captured callback. Every branch returns its opaque owner and capture.
4. `app.bend` names generated aliases, calls `Component.add` then `Captured.add`, attaches the schema and runs the App. Retry changes only repeatable arguments through `Captured.with_arguments` and `Entry.update_owners`.
5. `scenario.bend` observes returned owners and reports the actual schedule result. Its explicit owner reconstruction is diagnostic projection, not execution routing.

`check.sh` runs JS and checks every output byte. Set `BENDVY_EXAMPLE_NATIVE=1` to check Native too. `expected.py` is a finite declared-operation model adapted from the non-blind captured-query acceptance consumer; its expected output is sealed independently of the example's runtime output. It is not a proof for arbitrary callbacks. The wider authority, refusal and alternate-schema controls remain in the captured-query qualification evidence.
