# T06 candidate transaction obligations — unapproved

Executable subjects: `core.bend` begin/get/set/emit/command/finish/undo_all and the
abstract Step provider. Admissible Stores have two position slots and a four-slot
owned Payload; only position slot 0 and payload slot 1 are writable in this probe.
All writes/publications pass the transaction provider. No raw constructor or
arbitrary captured-closure safety claim is included.

| Candidate obligation | Rationale / finite evidence / proof boundary |
|---|---|
| Read-your-writes | `get(set(t,x,r,p))` returns x/r/p before finish; two failing writes observed as 9/11/17 and 12/13/19; an implementation that silently defers all writes is excluded |
| Successful commit | Success preserves final writes and appends staged publications in order; successful Good and the two-write success control exclude always-rollback implementations |
| Failure restoration | Failure restores component/resource and the owned array's slot to system-entry values; reverse undo preserves earlier Good commit; no-undo and forward-undo compiling mutants distinguish both conditions |
| Earlier-system preservation | Failure of the second system restores 5/7/13, not the initial 1/2/10; whole-schedule rollback compiling mutant is rejected |
| Publication isolation | Failure publishes no new events/commands and keeps earlier publications; actual TS debug queue/reader output and native/JS observations; premature event publication mutant is rejected |
| Unwritten storage preservation | Other position slot and other owned payload slots survive updates/rollback; full projection verifies [10,13,10,10] on failure and [10,19,10,10] on success, other position 1 |
| External IO boundary | The IO driver prints a trace (including an external effect) before finish; this effect remains after rollback; this does not promise restoration of host IO or arbitrary IO defects |

These are proposed general laws, not proofs. Runtime observations are finite.
The proof package must state operation-sequence preconditions, checked storage
bounds, state/publication projection and reachability. A model proof additionally
needs executable-to-model transition correspondence. Reversible U32 writes to an
owned Type payload are supported; arbitrary destructive updates of affine Type
elements are unresolved. No clone of the mutable arrays is used as rollback.
