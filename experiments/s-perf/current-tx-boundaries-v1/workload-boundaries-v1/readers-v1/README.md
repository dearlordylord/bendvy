# Actual Readers transaction boundaries — Motion64

Private consumer instrumentation; production ECS and the original canonical runtime are unchanged.

- Preserve the original 193 TxFacts and 84 reader captures, ordinary registrations, affine owners, stream cursors, event/barrier order and Doc/chunk writer.
- Report 193 domain transactions (seed plus 192 Local operations), then 84 actual reader callback transactions. Ordering is chronological within each group, not a claim of global interleaving.
- Reader callbacks have Unit capabilities and empty journals, but actually begin and finish a Tx. Their returned-World witness is captured before reader parameter commit and success/sync. Cursor metadata is explicitly unavailable (`null`).
- Complete original canonical output and all 277 independent boundary records must match on JS and Native. Generic Meter/Tx/Cmd/ordinary-reader-system controls are an external prerequisite recorded in `checks/GENERIC-CONTROL-APPLICABILITY.json`.

History is retained honestly: JS actual01 passed the complete canonical output but emitted invalid JSON (`True`); Native actual01 was never executed. The producer now uses `Meter.boolean`. Independently, the model's two Dispose site labels were corrected from Lifecycle's non-observed variants to the source-reached Readers observed variants. `oracle/SOURCE-AMENDMENT.json` and preserved pre-amendment bytes record this post-observation correction; actual02 uses the corrected gold before execution. The rejected raw output is not repaired or accepted retroactively.

This slice does not qualify Health, larger sizes, other workloads, separate recovery journals, marks, stamp peaks, RSS/allocation or comparative timing. No raw query/relation/owned-decode discard is reached here; no synthetic discard fixture is substituted.
