# S-INTEGRATE execution split — draft

Draft guideline for discussion and review; it selects no production layout,
performance threshold or new law. It retains separately approved observable
policies. Implement after #18.
Governing [ticket #19](../tickets/18-integrated-runtime.md),
[reviewed trace](s-integrate-trace.md), [seams](s-integrate-seams.md) and
[measurement draft](s-integrate-measurement.md) retain their full requirements.

## Freeze first

One coordinator owns shared nominal Motion/Health payload and observation types,
owner-return interfaces, transaction/log/dispatcher hooks and exact E0–E11 inputs.
Storage/transactions must agree on extraction, reinsertion, inverse records and
command payload ownership; readers/dispatch must agree on begin/success/failure/
skip boundaries. Draft and falsify integration laws before implementing their
subjects; general proofs require approval of those exact laws.

## Parallel ownership after interface review

All new implementation lives under `experiments/s-integrate/`.

| Responsibility | Owned files/modules | Dependency |
| --- | --- | --- |
| Coordinator | Shared types, contract inventory, integration runner and capability ledger | First; others consume frozen interfaces |
| Storage/identity | Cells, owned-list adapter, identity, commands, queries | Genuine Type payloads and abstract declared providers |
| Transactions | Transaction journal and reversible resource/provider writes | Storage extraction/reinsertion contract |
| Readers | Streams, lifecycle retention and registered reader positions | Transaction publication/mark hooks |
| Dispatcher | Systems, schedule, capture state and provisioning | Transaction and reader boundaries |
| Controls | Negative fixtures, compiling mutants and trace comparator | Actual integrated APIs; both compiled backends |

Interface review is ordinary coordinator/Spec review, not a new user approval
gate. Shared files have one owner. Workers preserve others' changes and use isolated
worktrees. Integration follows dependencies, not simultaneous edits to interfaces.

## Delivery order

1. E0–E1 on Native/JS and identity/access controls.
2. E2–E5: actual transaction, capture and publication parity.
3. E6–E10: readers, lifecycle, disposal, provisioning and ownership controls.
4. E11: real public overflow/retention lanes; internal C3 is supplementary.
5. Evaluate the indexed candidate where applicable; if implemented, require real
   Type relocation and identical traces. Retain the list baseline and record any
   failed capability with its redesign follow-up.
6. Complete compiling semantic-mutant coverage, then equivalent integrated
   measurement workloads. Run each seam's controls and mutants when it first exists.

Foreign commands return `MissingEntity` without changing the receiver queue,
explicitly selected by the user on 2026-10-04. Root authority,
reuse/exhaustion, general Local/destructive recovery, production layout and numeric
performance acceptance retain their separately recorded gates. Existing TS results
are reference inputs, never fresh Bend acceptance. Original Tower Defense stays
untouched. A failed capability gets an explicit redesign follow-up, not a pass.

Astra reviewed this draft on 2026-10-04: scope/dependencies retained; clarified
incremental mutant checks and conditional indexed-candidate evaluation.
