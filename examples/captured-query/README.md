# A query with retained owned state

This example runs a read-only audit and a captured Changed query through the replacement Root executor. The query retains the original `Pack` containing two affine arrays. Its component stores four-cell arrays under the nominal `Workshop` schema. Registration retains each actual declaration compilation and uses its assigned system ID.

Run the ordinary application from the repository root:

```sh
bash examples/captured-query/run.sh js
```

The four checkpoints show the initial state, a deliberate second-row error, a successful retry, and a run without new component changes. Each visited row reads its initial value, writes initial + 10 and reads it, then writes initial + 20 and reads it. The typed error carries those three observations. Both callbacks update the retained capture.

Ordinary errors keep completed writes. After the deliberate failure, the first cells are 20 and 21, both capture arrays have advanced twice, and both row outputs remain available. The default handler continues the Root and reports the body error. This replaces the former transaction rollback behavior under the [replacement amendment](../../docs/SPEC.md#ordinary-execution-replacement-user-amendment-2026-10-26-utc).

Retry changes `failAt` from 1 to 999 and resubmits both current component values through canonical publication under an explicit direct-write clock boundary. It retains the executed failure's cursor. Retry then produces first cells 40 and 41. The last Changed query selects no rows, clears its output list, and leaves both capture arrays unchanged.

Bevy's executed-system cursor behavior is described by the pinned [`FunctionSystem::run_unsafe`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/function_system.rs). The affine `Pack`, explicit returned owners and retained compilation nodes are Bend adaptations.

Read the files in this order:

1. `payload.bend` defines the original affine arrays and owner-preserving projections.
2. `schema.bend` defines the nominal schemas, declaration layout and actual reservation/publication setup.
3. `audit.bend` and `body.bend` declare query access and implement the audit and captured writes.
4. `app.bend` registers both owners, retains their compilations and builds the library Root with audit-before-query ordering.
5. `observe.bend` preserves the actual nodes while showing rows, captures, arguments and cursors. Its explicit retry operation resubmits component inputs.
6. `scenario.bend` runs the failure, retry and unchanged sequence and prints actual Root reports.

`run.sh` builds and executes Bend directly. The pre-existing `verify.py`, `expected.py`, `expected.stdout` and `checks/` preserve the former rollback contract's finite evidence; the ordinary runner does not invoke them. The current application run is a finite observation, not a mathematical proof or full capability acceptance.
