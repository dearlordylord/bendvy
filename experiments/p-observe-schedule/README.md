# P-OBS #18 — exact primitive schedule theorem

**`schedule_execution_exact` is proved at its exact approved domain.** The ordinary
checker and BendTT kernel accept [PROOF.bend](PROOF.bend). Two compiling interpreter
mutants falsify complete true-premise endpoint instances and fail the unchanged
universal induction in this endpoint's dedicated proof section. This proves the
bounded Nat primitive interpreter, not the owned-runtime correspondence theorem,
a real system/transaction scheduler, or the complete ECS.

The original 31-law SHA256 remains
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
[LAWS.bend](LAWS.bend) selects the approved block verbatim, with only import paths
adapted. [subjects.json](subjects.json) freezes law/type/model/spec sources; the
runner refuses any mismatch. No core, approved domain, other catalogue law,
production policy or dependency was changed. The other 24 catalogue candidates
remain unfilled and are not imported as proof assumptions.

## Proof construction

[PLAN.md](PLAN.md) records the initial contextual inventory and its refinements.
Bend 2.0.34/version/guide and the required skills were read before proof work.
Base equality facts and existing query/lookup facts were reused. No local
mathlib was found in the searched locations and none was installed.

- `relation.bend` supplies a finite logical lookup relation `Slots`. The final
  induction covers `[0,limit)` throughout the schedule. Equal namespaces,
  frontiers and pending queues accompany potentially different physical rows.
  `next <= limit` restricts this relation for terminal observation; Reserve
  needs no unproved extension and oracle-world validity is never assumed.
- `allocation.bend` proves the fresh-frontier and appended-queue facts used by
  successful Reserve and authorized Publish. `invariants.bend` proves Bump's
  count/row/pending preservation. `context.bend` combines these separately in
  the actual branch premises and connects terminal model observation to the
  completed query theorem. There is no filled generic preservation-law alias.
- `bump.bend` connects actual physical updates to per-slot immediate semantics;
  `successor.bend` uses checked enumeration inverse/absence to obtain Bump's
  successor relation, both inside and outside the live frontier.
- `barrier.bend` uses actual mixed-command replay, command-prefix validity and
  materialization lookup adequacy from the completed flush lane. It preserves
  the relation and clears pending work only at the explicit Barrier.
- `induction.bend` handles Reserve/Publish decision branches. `schedule.bend`
  dispatches each actual primitive to its proved successor. The required tail
  hypothesis is passed as a function, never filled with an assumption.
- `schedule_related` in `PROOF.bend` is the endpoint's universal authored-list
  induction over both physical layouts. Its base uses actual query observation
  adequacy without flushing. Initialization supplies reflexive logical relation;
  the original true/false `S.When` domain is preserved at the filled endpoint.

The completed query/enumeration dependencies came from commits `8644867` and
`53265cb`; mixed-command/prefix/materialization/flush dependencies came from
`5294bae`, `7edd1e4`, `0c4a74a` and `36d8079`. Full query and flush runners were
rerun successfully in this isolated worktree before composition. The schedule's
own runner records actual dependency file hashes, not trust in those reports.

## Reproduction and mutation evidence

```sh
python3 experiments/p-observe-schedule/verify.py
```

[evidence.json](evidence.json) records 26 ordinary checker/kernel passes, sixteen
concrete control definitions, two contextual mutants, two endpoint mutants and
a forced kernel failure. Each checker uses the existing five-second kill wrapper;
the six-second process watchdog only detects wrapper failure. The recorded regular
checks all finished below one second in this run; timings are not performance
acceptance. Standalone `LAWS.bend` still reports its one unfilled declaration
until `PROOF.bend` is imported, as expected.

| Actual model mutant | Active complete-law witness | Unchanged proof failure |
|---|---|---|
| `M.tick` flushes in its empty-list branch | Successful Reserve without Barrier | `schedule_related`, empty-list case |
| `M.tick` drops its tail after the first operation | Reserve followed by Barrier | `schedule_related`, nonempty-list case |

The runner first checks the unchanged copied proof and original complete-law
instance with the kernel, compiles the mutated model, verifies every copied proof
file hash stayed unchanged, rejects the false full instance, and separately
checks that independent admissibility is still true on the mutant.
`schedule_related` is **the necessary universal induction inside the dedicated
`schedule_execution_exact` section**, not an unrelated shared helper. The final
`L.schedule_execution_exact` wrapper is not claimed as the failure location.
Existing wrong-Bump-ghost and nonadvancing-reservation controls remain contextual
checks, explicitly separate from this endpoint gate.

The controls include physically reordered worlds, duplicate raw lookup, absent
keys beyond the live frontier, foreign publication, successful fresh reservation,
no implicit flush, a mixed multi-Barrier schedule and a separate malformed-world
false-domain control. They supplement the general proof; they do not replace it.

## Limits and process notes

`PLAN.md` discloses one process-order deviation: the Bump/enumeration factorization
was first checked before its extra inventory paragraph was persisted. A proposed
observation-expression expansion did not convert under an abstract computed world
and was discarded; no alternate observer is retained. Subsequent proof inventory
and dependency boundaries are recorded explicitly.

This theorem assumes the exact independent admissibility predicate and observes
the bounded value/tag Nat world. It establishes no unforgeable root authority,
allocator production policy, arbitrary Type payload restoration, reader transaction,
backend/host IO proof or numerical performance guarantee. Owned-runtime schedule
correspondence and the full-core work remain separate open obligations.
