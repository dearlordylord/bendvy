# Private transaction runtime tranche

Actual code, not a proof. `transaction.bend` retains an affine world, selected
actual handle, automatic inverse journal, Type command owners and staged Ping/mark
values. Setters call actual storage extraction/reinsertion with payload slot0 swap;
clients receive fresh operations over arbitrary opaque Tx, never undo/restore.
Failure traverses the prepended numeric journal, drops staged owners and retains
current world allocation state. Success transfers publications; `storage_commit`
converts chronological staged commands once into storage's reversed queue,
publishes marks only on success and returns staged Ping values to the log adapter.
Readers/clock/capture owners stay in their owning modules.

Run `python3 experiments/s-integrate/transaction-runtime-run.py`. It uses the
existing dependency-free t05 helpers: every checker and runtime invocation <=5s,
C/JS generation <=30s and clang build <=120s (separate build work). Processes own
their groups; temporary fixtures/build outputs are removed. Installed compiler
2.0.34; no diagnostic compiler patch is needed by this module. Evidence pins every
Bend input used by the runner, with Native/JS equal outputs per case.

Two executable subjects:

- Generic retained Type-array journal canary:20→30→50 and Ledger101→201 restore
  20:101 while preserving allocation6; real staged Type command/Ping is discarded.
- Actual Motion/Health store joins: actual factory/create/reserve provides the
  selected handle; trusted fixture seeds one live row. Actual storage hooks and
  complete nominal payload owners restore every Main/Ledger array field and
  metadata. Real reservation inside Tx yields failedID2; genuine Type Spawn is
  staged; failure preserves next3. The same final fields appear on Native/JS.

Five compiling mutants change the actual store result: FIFO inverse replay,
omitted Main inverse, omitted Ledger inverse, reservation counter reissue and
failure committing. The identity mutant correctly leaves the independent generic
array canary unchanged; its actual world case kills it. No checker failure is
counted as a semantic mutant kill.

This is not full E2/E3 acceptance. The live fixture is seeded, not yet created by
actual structural apply; Ledger101 represents the earlier committed prestate.
Actual A commit/publications, complete query/Aux observations, selected-reader
failure/retry, lexical captures, foreign-command rejection, structural disposal and
full Ping/lifecycle trace still require the dispatcher/storage/readers composition.
No full runtime refinement, production layout, allocator reuse/exhaustion or
arbitrary destructive Type recovery is claimed. No general ECS law was proved.
