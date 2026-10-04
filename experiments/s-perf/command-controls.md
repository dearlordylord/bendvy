# Indexed command control snapshot

The candidate removes the affine list cursor. Each command addresses its logical
ID directly; changes remain FIFO. `apply_checked` preserves the complete original
world and pending Type queue on an unsupported Spawn ID before applying any prefix.
Its result is `CheckedApply<Schema,M,A,F,L,Mode>`: `Applied{world,changes}`,
`CapacityRejected{world}`, or `InvariantFault{world,row,changes}`. The last result
makes a malformed duplicate Spawn explicit: earlier completed changes, the rejected
incoming owner and every later pending command remain available. It is not a
recoverable public exhaustion or arbitrary-command rollback policy. The actual host
must terminate at its IO capability boundary on either rejection, rather than
converting either into an empty successful barrier or MissingEntity.

Finite controls pass checking under five seconds and full-field Native O3/JS
comparison. Eleven exact lines cover both nominal schemas, descending/repeated
logical targets, remove/reinsert Main, a first-row tombstone and stale subsequent
edit, live Main absence with retained Aux, growth through ID 65537, stamps and FIFO
changes. Unsupported IDs 0, 131073 and U32.max retain all queued payload fields;
a pre-existing live owner's Main/Aux/flag/stamps and ledger/namespace/cursor/mode
are also preserved. Existing Main replacement preserves its original added stamp
and Aux; Main removal clears stamps while retaining Aux and live membership. Two malformed duplicate-Spawn controls preserve old storage,
incoming Main/Aux, later pending Main and prior committed changes. Three compiling
mutants are killed on both backends: reverse FIFO, omit MainChanged, skip despawn.

Replay after candidate storage/identity integration:

```sh
python3 experiments/s-perf/command-controls-run.py --output /tmp/bendvy-command-controls
```

The recorded run used the storage/identity worker snapshot at
`/tmp/bendvy-owned-index/experiments/s-perf/candidate/`; exact hashes are in
`command-controls-evidence.json`. Budgets: checker/runtime 5s, code generation
30s, clang 120s; CPU 10, Native O3, one worker, GPU off. Expectations are the
complete authored fixture output, not a checksum-only validation. This snapshot
has no universal proof, main-trace acceptance, comparative timing or production
adoption claim. Structural InsertMain/RemoveMain now use the dedicated indexed
Main+metadata helper, threading the Aux column unchanged without extracting it.
The superseded transient-row snapshot is retained in Git commit `5c1e586` and
`command-controls-row-snapshot-evidence.json`; its temporary storage source hash
is historical evidence, not current-source acceptance. Current compiling mutant
outputs are retained as full-field text witnesses alongside the exact original
expectation. Flag edits and despawn still reconstruct a single transient row;
metadata-only flag updates remain a concrete optimization follow-up, with the
same full-field controls as the return condition.
