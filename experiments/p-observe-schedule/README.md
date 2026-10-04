# P-OBS #18 schedule lane — checked contextual progress

**`schedule_execution_exact` remains open.** This package imports the frozen
subjects and selects that exact approved law. It changes no core, law domain,
production policy or project dependency. It contains universal contextual proofs;
the runner's success is not acceptance of the schedule endpoint or issue #18.

The original 31-law SHA256 remains
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
[subjects.json](subjects.json) freezes canonical sources and the exact selected
block; [PLAN.md](PLAN.md) inventories helper purposes and dependency graph.
Bend 2.0.34/version/guide and the required skills were read before proofs. Base
facts and existing query/lookup contextual facts were inspected and reused;
no mathlib was found in the searched local locations and none was installed.

## Checked results

- `relation.bend`: `Slots` relates finite logical lookup intervals, permitting
  different physical row ordering. `enumerate_related`, `bumped_related` and
  `materialize_related` transport the actual independent oracle computations.
  `Related` adds exact public metadata/queue agreement; `observe_related` proves
  equal independent observations. These facts do not prove model adequacy.
- `bump.bend`: `bump_point` proves actual physical Bump lookup agrees with the
  independent immediate update at every target/observed slot, including duplicate
  raw rows and missing targets. `bump_enumeration` connects independent Bump
  materialization to actual value mutation of ordinarily enumerated rows, using
  actual emitted-row key evidence. It awaits shared enumeration lookup adequacy
  for the full successor relation.
- `invariants.bend`: actual Bump preserves counts, the independent whole-list
  `rows_valid` predicate and pending reservation checks. These narrow links do
  not fill or alias the unapproved all-step `admissibility_preserved` law.
- `transitions.bend`: Reserve and Publish preserve the specified logical relation
  across common metadata and potentially different rows. The successful Reserve
  case explicitly requires relation at the enlarged interval; it does not hide
  that extension obligation or assert the unapproved raw reservation equation.

`verify.py` records ten checker/kernel passes, eight concrete controls (including
physically reordered equal worlds, duplicate lookup, foreign publication,
reservation pending after schedule end and an actual admissibility premise),
two compiling contextual mutants and a forced kernel failure. Every checker
uses `experiments/t01/bend-check` with its five-second kill limit; the six-second
Python watchdog only detects wrapper failure. The wrong Bump ghost fails the
unchanged `bump_point`, and a reserve that does not advance fails unchanged
`reserve_related_case`. These are contextual mutation gates, not the still-open
endpoint's own mutation gate. `LAWS.bend` correctly reports one TODO.

Run from the repository root:

```sh
python3 experiments/p-observe-schedule/verify.py
```

[evidence.json](evidence.json) pins source/dependency/compiler/Base hashes and
records complete diagnostics and timing. The copied mutant positives first pass
the kernel; malformed mutants and unexpected failures fail the runner.

## Remaining composition

The query lane is completing exact query/row equality and enumeration lookup
adequacy. The flush lane owns whole-command mixed-slot replay and command-prefix
invariants. Their unfinished endpoints are not imported or assumed here.
Schedule composition still needs actual model observation adequacy, logical
successor relation (including Barrier), contextual prefix invariant reasoning
and final list induction with no implicit flush. The empty schedule itself needs
query adequacy, not reflexivity between unlike physical representations.

The plan records one process-order deviation: the small Bump/enumeration
factorization was checked before its additional inventory paragraph was persisted.
This is disclosed rather than retroactively described as planned execution.
No runtime ownership, full Type payload, real system transaction, compiler/backend,
host IO, production authority or performance theorem follows from this package.
