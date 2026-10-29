# Candidate law checks

The exact five laws are user-approved. `PROOF.bend` fills all five and passes
the matching pinned compiler and BendTT kernel. The literal instances below
remain finite falsification checks. All five isolated proof mutation controls
now pass their expected positive/negative outcomes.
The existing `/workspace/formal-proofs/bendvy/scripts/bend-check` selects the
pinned compiler and serializes its CPU affinity locks.

| Input | Observed result |
| --- | --- |
| `spec.bend` | Exit 0. |
| `PROOF.bend --verdict` with the preserved matching compiler/resource bundle | Exit 0, `ALL PROOFS CHECK`. |
| `BENDTT=/usr/bin/false ... PROOF.bend --verdict` | Exit 1, expected kernel mismatch. |
| `LAWS.bend` | Exit 1, exactly five open TODOs. |
| `falsify-transitions.bend` | Exit 0, 324 literal equalities. |
| `falsify-ready.bend` | Exit 0, 374 literal equalities. |
| `controls.bend` | Exit 0, the five selected counterexample instances on actual source. |
| Each mutated `dependency-executor.bend` or `dependency-plan.bend` | Exit 0, all five modified subjects compile. |

Each `mutants/<name>/counterexample.bend` must exit 1 at the listed equality.
The import changes select a copied, single-defect subject and its matching
nominal result types. The specification's logic stays unchanged.

| Mutant | Actual-source instance | Defect and observed distinction |
| --- | --- | --- |
| `rejection-reason` | `rejected_2` | Replaces `Missing{9,3}` with `Cycle{}`. |
| `body-error-history` | `body_24` | Drops prior `Ran{4,8}` and `Skipped{5}` observations after a body error. |
| `disabled-invokes` | `disabled_18` | Dispatches a disabled body, producing state 100 and `Ran` instead of state 0 and `Skipped`. |
| `condition-error-handler` | `condition_error_13` | Skips the escalating handler and returns `Finished` rather than `Stopped`. |
| `ready-blocked` | `ready_blocked` | Includes blocked node 1 while its predecessor 0 remains pending. |

Run a positive input from the repository root with the existing checker:

```sh
scripts/bend-check test-fixtures/execution-laws/falsify-transitions.bend
scripts/bend-check test-fixtures/execution-laws/falsify-ready.bend
scripts/bend-check test-fixtures/execution-laws/controls.bend
```

Run each mutant's subject first, then its counterexample. A parse, import, or
affine-usage failure in the subject is not a successful defect control.
For example:

```sh
scripts/bend-check test-fixtures/execution-laws/mutants/disabled-invokes/dependency-executor.bend
scripts/bend-check test-fixtures/execution-laws/mutants/disabled-invokes/counterexample.bend
```

The second command must fail at `disabled_18`. These checks do not execute
JavaScript or native code, establish worker use, or verify the complete public
App. No new runner, dependency, compiler, or proof tool is installed.

## Isolated proof mutation controls

Each mutant directory contains a one-law `LAWS.bend` and its corresponding
`PROOF.bend` section. `LAWS-positive.bend` and `PROOF-positive.bend` use the exact
same approved equation and proof against actual production/specification imports.
The mutation copy changes one production line and adjusts only imports needed
for the selected nominal types. All modified production subjects compile.

| Mutant | Positive proof | Mutated proof | Actual failure location |
| --- | --- | --- | --- |
| `rejection-reason` | Exit 0 | Exit 1 | `Laws.rejected_plan_state` |
| `body-error-history` | Exit 0 | Exit 1 | `Laws.body_error_continuation` |
| `disabled-invokes` | Exit 0 | Exit 1 | `Laws.disabled_condition_state` |
| `condition-error-handler` | Exit 0 | Exit 1 | `Laws.condition_error_continuation` |
| `ready-blocked` | Exit 0 | Exit 1 | `keep_actual` within the ready proof section |

`PROOF-CONTROLS.json` binds every selected source and diagnostic. Mutation checks
use the plain checker; the complete actual proof additionally passes the kernel
verdict in both resource closures recorded in `SUBJECTS.json`.

```sh
scripts/bend-check test-fixtures/execution-laws/mutants/disabled-invokes/PROOF-positive.bend
scripts/bend-check test-fixtures/execution-laws/mutants/disabled-invokes/PROOF.bend
```

The first command passes. The second fails at `Laws.disabled_condition_state`.
The other four directories follow the same positive and negative command shape.
These controls prove neither public App reachability nor generic affine-owner
identity; those are outside the approved five equations.
