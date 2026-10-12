# Work3: expectations and later observations

Baseline: `30f87151a`, 2026-10-12 UTC. Branch: `infra/retro-work3`.
This records expectations before implementation. Keep these expectations unchanged;
append outcomes and subsequent observations. Main-thread sources, active runners,
the shared heavy lock and existing evidence remain untouched.

| # | Planned change | Expected result | Implementation | Effect observed |
|---|---|---|---|---|
| 1 | Validate existing delivery-plan command roles, labels and artifact paths before execution. | Wrong `.js` Native artifacts and incorrect source-command dispatch fail before launching a compiler. | Pending | Not measured |
| 2 | Add a sequential batch entry using the existing command owner; collectors retain their own heavy lock. | Ready jobs advance automatically after terminal results, without manual release messages or nested-lock deadlocks. | Pending | Not measured |
| 3 | Add exact owned-file staging validation and a manifest-based staging command. | An accidentally staged independent model or another owner's file is rejected before commit. | Pending | Not measured |
| 4 | Add checks of complete scenario dispatch and negative-control evidence, plus handle-origin review guidance. | A Breadth scenario using Depth, a negative test that succeeds, or an unrelated refusal cannot earn acceptance. Handle provenance is explicitly reviewed. | Pending | Not measured |
| 5 | Add source-only reduction and phase-report tooling for the Native decoder blocker. | Produce inspectable smaller candidates and identify the last completed compiler phase without increasing limits. | Pending | Not measured |

## Verification and later assessment

Use small synthetic controls and retained historical data. Do not launch compiler,
benchmark or profiler jobs alongside the main thread. Compiler candidates require
the existing independent launch review and serialized execution before adoption.

At the later check, record the time window, actual invocation counts, caught errors,
uncaught errors and remaining manual handoffs. Unit tests show the mechanisms work;
they do not show that future sessions became faster. For #5, reduction tooling alone
does not establish a reproduced or fixed compiler blocker.

## Outcomes

No implementation or later-session observation recorded yet.
