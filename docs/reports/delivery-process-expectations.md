# Delivery process: expectations and later observations

Baseline: `30f87151a`, 2026-10-12 UTC. Branch: `infra/delivery-process-controls`.
This records expectations before implementation. Keep these expectations unchanged;
append outcomes and subsequent observations. Main-thread sources, active runners,
the shared heavy lock and existing evidence remain untouched.

| # | Planned change | Expected result | Implementation | Effect observed |
|---|---|---|---|---|
| 1 | Validate existing delivery-plan command roles, labels and artifact paths before execution. | Wrong `.js` Native artifacts and incorrect source-command dispatch fail before launching a compiler. | Implemented; synthetic tests pass | Malformed plans rejected in synthetic controls and historical replay |
| 2 | Add a sequential batch entry using the existing command owner; collectors retain their own heavy lock. | Ready jobs advance automatically after terminal results, without manual release messages or nested-lock deadlocks. | Implemented; synthetic tests pass | Two wrappers run in order; failure stops the batch and retains pending jobs |
| 3 | Add exact owned-file staging validation and a manifest-based staging command. | An accidentally staged independent model or another owner's file is rejected before commit. | Implemented; temporary Git tests pass | Foreign staged paths rejected; literal owned paths staged |
| 4 | Add checks of complete scenario dispatch and negative-control evidence, plus handle-origin review guidance. | A Breadth scenario using Depth, a negative test that succeeds, or an unrelated refusal cannot earn acceptance. Handle provenance is explicitly reviewed. | Implemented; synthetic tests pass | Wrong dispatch and accidental/unrelated negative results rejected |
| 5 | Add source-only reduction and phase-report tooling for the Native decoder blocker. | Produce inspectable smaller candidates and identify the last completed compiler phase without increasing limits. | Tooling and one-case candidate prepared | Historical phase log parsed; compiler blocker not reproduced or fixed |

## Verification and later assessment

Use small synthetic controls and retained historical data. Do not launch compiler,
benchmark or profiler jobs alongside the main thread. Compiler candidates require
the existing independent launch review and serialized execution before adoption.

At the later check, record the time window, actual invocation counts, caught errors,
uncaught errors and remaining manual handoffs. Unit tests show the mechanisms work;
they do not show that future sessions became faster. For #5, reduction tooling alone
does not establish a reproduced or fixed compiler blocker.

## Outcomes

Initial expectations commit: `01fd5b2b5`. Changes were developed in an isolated worktree and integrated into `master`
(`04d0aa9af`, `818f53a94`). Real-session impact has not been measured.

- #1: `scripts/delivery_preflight.py` validates one plan or a `--manifest` containing
  `{"plans": ["/absolute/plan.json"]}`. Retained control results:
  `experiments/delivery-process-controls/preflight-controls.json`.
- #2: `scripts/delivery_batch.py MANIFEST FRESH_OUTPUT` runs an explicit ready batch.
  Each `jobs` entry supplies `id`, `kind: "ordinary"`, `plan`, `planSHA256`, `argv`,
  `cwd`, and `capSeconds`. Collectors retain their own resource admission. It stops
  on first failure and records terminal output plus pending jobs; `WRAPPERS_PASS`
  reports wrapper execution, not feature acceptance. Performance jobs are excluded.
- #3: `scripts/owned_stage.py MANIFEST --add` uses exact `paths`. The hook can check
  ownership via `BENDVY_OWNED_PATHS` and selected plans via `BENDVY_DELIVERY_PLANS`.
  These opt-in selectors are not enabled globally.
- #4: `scripts/scenario_controls.py` compares full expected scenario DTOs and checks
  intended negative diagnostics. Handle provenance is a review criterion in
  `CODING_STANDARDS.md`; it is not mechanically inferred from raw IDs. Existing
  historical collectors are not rewritten or automatically covered by this helper.
- #5: `scripts/native_reduce.py` prepares subsets and reports phase markers.
  `experiments/delivery-process-controls/native-one-case` keeps one of 32 scenarios and pins its
  file-import closure. Helpers and schema branches remain, so this is not a proven
  minimal reproduction. Base/tool dependencies are not frozen. The retained
  historical instrumented log ends at `validation-enter` for `execute`, index 1610;
  this does not establish stock compiler causality. No compiler run was launched.

Light verification: 17 retrofit controls and 14 hook tests pass. The configured commit hook also passed
all ten lightweight suites (119 tests), admission selection and whitespace checks. No benchmark or profiler was run.

Later session assessment: **pending**. Record actual usage, rejected mistakes,
missed mistakes and manual handoffs before judging whether these changes helped.
