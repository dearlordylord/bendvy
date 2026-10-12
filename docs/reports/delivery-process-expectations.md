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

## Version 1+1 — additional improvements

Added 2026-10-12 from the session retrospective. These additions are approved for
implementation; they are not implemented by this table. Preserve the original
expectations above. Sequential batching remains original item #2, with adoption
and real-session assessment still to check; it is not a new item here.

| # | Planned change | Expected result | Implementation | Effect observed |
|---|---|---|---|---|
| 1+1.1 | Use the pinned parity compiler in the lightweight development check. Repair parser/type/affine errors through that check, retaining diagnostics; prepare the frozen acceptance package after source success. Existing acceptance gates remain unchanged. | Development and acceptance use the same compiler identity; ordinary typing repairs avoid repeated acceptance preparation. | Implemented in isolated branch; four focused controls pass; integration prepared from PR #72; branch hook 123 tests PASS | Baseline: missing-resource consumer required eight source attempts, each with a frozen plan and guards. The development wrapper calls the floating `bend` alias, currently 2.0.36; parity uses 2.0.35. No improvement measured yet. |
| 1+1.2 | Reduce the existing coordination table to current owner, actual blocker, state and next action. Link historical evidence through existing capability documents; add a deterministic structural check for the agreed table format. | Agents locate the current frontier without rereading accumulated delivery history; the table remains concise after updates. | Implemented in isolated branch; table and refusal controls pass; integration prepared from PR #72; branch hook 123 tests PASS | Baseline: 24 coordination rows total about 45,700 characters; the longest row is 6,856 characters. The existing instruction to omit historical milestones is not being followed. No improvement measured yet. |
| 1+1.3 | Reconcile the remaining acceptance criteria of #54/#56, then draft and approve complete tracer-bullet child tickets with genuine blocking edges. Keep parent scope and all required gates; reuse completed evidence. | Each remaining capability has an explicit completion boundary, owner and dependency; progress and parent closure requirements are visible. | Draft A–H prepared below; review before publication | Baseline: independently accepted bounded slices accumulate inside open broad tickets. The exact remaining breakdown has not been established; ticket creation alone is not a delivery improvement. |
| 1+1.4 | Activate the prepared infrastructure GitHub Actions workflow using the existing lightweight checks, once the required workflow permission is available. | Pull requests and master pushes execute the prepared infrastructure checks automatically. | PR #72 workflow active; GitHub run 38215857178 SUCCESS; integrated master result pending | Baseline: local pre-commit is configured, but the prepared workflow is outside `.github/workflows` and is inactive. No CI run or delivery-speed effect measured yet. |

### Version 1+1 outcomes

Update each row after implementation with the exact commit and relevant checks.
Record real-session effects separately from synthetic success, using existing
logs and receipts. Keep unmeasured effects explicit and the original expectations
unchanged. No new telemetry, performance tolerance or recurring report is added.

## Version 1+1 implementation handoff

Isolated branch: `infra/retro-v1plus1`; worktree: `/tmp/bendvy-retro-v1plus1`.
Development wrapper reads the existing parity compiler path without executing
configuration code. Coordination history is retained in the existing checkpoint
history; the staged guard checks five nonempty cells and the documented row limit.
The prepared CI workflow now has an active-path copy. Remote activation and its
first result must be recorded after integration. Workflow scope is now available.

### Child-ticket breakdown — draft for approval

These are candidates, not published issues or new approved contracts. All retain
existing JS/Native, scoped TS, authority, reached-control, review and applicable
performance gates. Existing completed evidence is reused at its exact scope.
Parents #54/#56 and their requirements are unchanged. Contract-dependent items
remain blocked until the native contract is approved.

| Candidate | Parent | Blocked by | Complete result |
|---|---|---|---|
| A. Optional/required resource absence | #54 | None; existing work underway | An ordinary registered application observes absence safely; required execution refuses before callback, preserving affine owners and pending work. Complete qualification and integration of the current candidate. |
| B. Held inspection views | #54 | Approved held-view ownership/invalidation contract | Host retains the agreed detached inspection value across actual subsequent ECS operations; the value obeys the approved lifetime/aliasing semantics on both backends. |
| C. Multiple retained Schedule access indexes | #56 | Approved ordinary multi-Schedule ownership/composition contract | One ordinary App retains and executes multiple schedules, deriving each access index from actual placements without user metadata duplication. |
| D. Mixed-reader dump Native reached control | #56 | None; qualified normal adapter exists | The actual public filtering defect is detected by a complete Native counter trace, with exact source restoration; preserve existing normal JS/Native and reached JS evidence. |
| E. Non-Column population and dump | #56 | Approved supported storage/iteration contract | An ordinary application using the agreed non-Column storage derives population and filtered dump from its operational binding, preserving affine owners and order. |
| F. Native debug lint contract and execution | #56 | Approved lint triggers, severity and handling | Debug reports the agreed Bevy-grounded operational access/schedule diagnostics from normal declarations, with complete positive/negative observations. |
| G. Native naming/replacement contract and execution | #56 | Approved naming/replacement behavior | Ordinary declarations derive the agreed naming/replacement output while schedules continue executing with unchanged operational identities and ownership. |
| H. Inspector/debug performance qualification | #54/#56 | The functional slices included in the agreed measurement scope | Repeated ordinary inspections/dumps retain system visibility; enabled overhead, feature timing/scaling and unchanged combined regression are measured against existing criteria. Functional leftovers remain visible; Workshop alone does not close the parents. |

Stateful condition ownership remains with existing #34/#55; it is not duplicated
here. Universal proofs remain subject to existing law approval. Before publication,
review candidate granularity, actual blockers and whether any item is already
qualified by newer main-thread evidence. No child issue has been created.

CI correction: infrastructure suites run explicitly on clean checkout; staged-only
hook selection is insufficient for CI. Independent integration review and the
actual GitHub run remain required before recording remote success.

Implementation commit: `3f0d6fa64`. Full configured hook: 123 tests PASS.
PR: https://github.com/dearlordylord/bendvy/pull/72
First CI run: https://github.com/dearlordylord/bendvy/actions/runs/38215764728
These establish implementation/check execution, not real-session speedup.
Main must reconcile its current coordination/history edits during integration.

### Integration observation — 2026-10-12

PR #72 (`e8274ad1f`) is reconciled against master `625180bb2`. The existing untracked checkpoint history is preserved verbatim; the complete pre-integration map is appended with its SHA256. Current #54 producer/model worktrees and their idle handoff, both Native deadlines, and the unfrozen Unit-filter repair are recorded. #56 uses current combined213 evidence. Historical assignments remain archived. No A–H child issue is published; A already has newer accepted evidence and the draft requires reconciliation before publication.

Observed 1+1 effects: four focused wrapper/table controls pass. The wrapper resolves the existing 2.0.35 path without executing config or using the floating alias. The concise table passes its guard; its current row lengths are measured below. PR CI [run 38215857178](https://github.com/dearlordylord/bendvy/actions/runs/38215857178) completed SUCCESS. No development repair speedup or delivery acceleration has been measured. Master CI and integration checks will be recorded after completion.

Integration measurement: the current coordination table has 21 data rows, 7,966 row characters in total, longest row 613 characters (header/separator excluded). The original approximate baseline is retained unchanged. All 123 infrastructure tests passed locally across the full hook and the repaired sparse-fixture test-pre-commit rerun; initial sparse-checkout missing-fixture failures are not product failures and are retained in the session log. The merge commit runs the configured hook again.
