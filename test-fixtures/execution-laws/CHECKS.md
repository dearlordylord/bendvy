# Candidate law checks

The exact five laws are user-approved. `PROOF.bend` fills all five and passes
the matching pinned compiler and BendTT kernel. The literal instances below
remain finite falsification checks; proof-level mutation controls are pending.
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
