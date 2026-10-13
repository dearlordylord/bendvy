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
| 1+1.1 | Use the pinned parity compiler in the lightweight development check. Repair parser/type/affine errors through that check, retaining diagnostics; prepare the frozen acceptance package after source success. Existing acceptance gates remain unchanged. | Development and acceptance use the same compiler identity; ordinary typing repairs avoid repeated acceptance preparation. | Implemented in isolated branch; four focused controls pass; Integrated at `3ad937194`; configured hook 123 tests PASS | Baseline: missing-resource consumer required eight source attempts, each with a frozen plan and guards. The development wrapper calls the floating `bend` alias, currently 2.0.36; parity uses 2.0.35. No improvement measured yet. Actual: pinned 2.0.35 wrapper check-only passes; four focused controls pass; no repair-speed measurement. Real session: #46 shallow-error repair used pinned checks (tiny 0.527s, full32 1.448s) before frozen backend plans; #54 setter source07 passed before oracle/consumer preparation. No comparative repair-speed measurement. |
| 1+1.2 | Reduce the existing coordination table to current owner, actual blocker, state and next action. Link historical evidence through existing capability documents; add a deterministic structural check for the agreed table format. | Agents locate the current frontier without rereading accumulated delivery history; the table remains concise after updates. | Implemented in isolated branch; table and refusal controls pass; Integrated at `3ad937194`; configured hook 123 tests PASS | Baseline: 24 coordination rows total about 45,700 characters; the longest row is 6,856 characters. The existing instruction to omit historical milestones is not being followed. No improvement measured yet. Actual: 21 current rows, 7,966 row characters, maximum 613; staged guard passes; full prior map and assignments preserved. |
| 1+1.3 | Reconcile the remaining acceptance criteria of #54/#56, then draft and approve complete tracer-bullet child tickets with genuine blocking edges. Keep parent scope and all required gates; reuse completed evidence. | Each remaining capability has an explicit completion boundary, owner and dependency; progress and parent closure requirements are visible. | Draft A–H prepared below; review before publication | Baseline: independently accepted bounded slices accumulate inside open broad tickets. The exact remaining breakdown has not been established; ticket creation alone is not a delivery improvement. |
| 1+1.4 | Activate the prepared infrastructure GitHub Actions workflow using the existing lightweight checks, once the required workflow permission is available. | Pull requests and master pushes execute the prepared infrastructure checks automatically. | PR #72 workflow active; GitHub run 38215857178 SUCCESS; master successor 38256910663 SUCCESS at `d4c4a8227` | Baseline: local pre-commit is configured, but the prepared workflow is outside `.github/workflows` and is inactive. No CI run or delivery-speed effect measured yet. Actual: PR run SUCCESS; master workflow launched after integration, first master run cancelled; successor SUCCESS after scope-preserving inventory repair. Real session: master infrastructure run `38327219219` SUCCESS at `10585fdee`; no delivery-speed effect measured. Follow-up: `0dd4c6ef1` hoists invariant source scope outside AST traversal; all 123 local checks pass and CI `38330369008` SUCCESS, with runner29 at 10.553s versus prior CI 191.626s (different hosts, no controlled speedup factor). Five-minute CI limit and coverage unchanged. |

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

Observed 1+1 effects: four focused wrapper/table controls pass. The wrapper resolves the existing 2.0.35 path without executing config or using the floating alias. The concise table passes its guard; its current row lengths are measured below. PR CI [run 38215857178](https://github.com/dearlordylord/bendvy/actions/runs/38215857178) completed SUCCESS. No development repair speedup or delivery acceleration has been measured. The merge hook passed all 123 tests; first master CI was cancelled at its five-minute job deadline.

Integration measurement: the current coordination table has 21 data rows, 7,966 row characters in total, longest row 613 characters (header/separator excluded). The original approximate baseline is retained unchanged. All 123 infrastructure tests passed locally across the full hook and the repaired sparse-fixture test-pre-commit rerun; initial sparse-checkout missing-fixture failures are not product failures and are retained in the session log. The merge commit runs the configured hook again.

Integrated merge: `3ad9371949a56ad8a9158385c9fd3fd8cd72b757`. GitHub marked #72 merged at 2026-10-12 13:28:32 UTC. Configured merge hook passed all 123 tests. Independent [launch review](../reviews/pr72-infrastructure-launch.md) binds unchanged infrastructure sources; master [CI run 38255941653](https://github.com/dearlordylord/bendvy/actions/runs/38255941653) was launched automatically.

Master CI follow-up: run 38255941653 completed `cancelled` at the five-minute job deadline; checkout and coordination guard passed, the first infrastructure suite had not completed. Existing workspace repair to `test_current_entrypoints_use_one_process_implementation` replaces filesystem recursion with `git ls-files -z` and the same `entrypoint_scope` predicate. Independent Spec review confirmed exact tracked-file scope, unusual-filename handling and sparse absent-file behavior. This is a targeted inventory-discovery repair; test coverage and timeout remain unchanged. Runtime cause is provisional until successor CI completes.

Final master result: [run 38256910663](https://github.com/dearlordylord/bendvy/actions/runs/38256910663), commit `d4c4a8227b754a23a40c8134109062bc10331313`, **SUCCESS**, functional job 2026-10-12 13:36:52–13:41:30 UTC. Checkout, complete infrastructure sequence and cleanup all passed under the unchanged five-minute job limit. This establishes active master CI after the inventory repair, not a quantified causal speedup; the earlier cancelled run remains linked above. This documentation-only recording reuses the exact qualified infrastructure source.

### Confirmed observations — 2026-10-13 UTC

Read-only assessment of retained evidence and GitHub job metadata; no new compiler,
benchmark or test runs. Original expectations remain unchanged.

| Item | Confirmed result | Evidence and limits |
|---|---|---|
| #1 delivery preflight | Six real invocations completed successfully in the inspected compiler-candidate subtree. Historical replay rejects the Native plan with a `.js` artifact. | `experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/compiler-candidate-v1/` contains 27 inspected receipt files and six recorded `scripts/delivery_preflight.py` commands, all exit 0 without failure. `experiments/delivery-process-controls/preflight-controls.json` records the historical rejection. This establishes use and replay detection, not newly prevented errors or time saved; counts cover this subtree only. |
| 1+1.1 pinned development check | Actual #46/#54 repairs use installed 2.0.35 source checks before frozen backend plans. | Retained observations in the 1+1.1 row include #46 checks at 0.527s/1.448s and #54 setter source07. Development-tool consistency and workflow use are established; comparative repair speed remains unmeasured. |
| 1+1.2 coordination table | Current table has 21 data rows, 8,740 characters total and a maximum row length of 896. Approximately 81% fewer characters than the original approximate 45,700-character baseline. | Direct measurement of `docs/parity/README.md`, excluding header/separator. The earlier 7,966-character observation remains historical. Reduced document size is established; navigation time is unmeasured. |
| 1+1.4 infrastructure CI | Two subsequent master jobs completed successfully within the unchanged five-minute limit: 84s and 88s. | [38330369008](https://github.com/dearlordylord/bendvy/actions/runs/38330369008): 01:04:32–01:05:56 UTC; [38331207282](https://github.com/dearlordylord/bendvy/actions/runs/38331207282): 01:14:56–01:16:24 UTC. Earlier successful job [38327219219](https://github.com/dearlordylord/bendvy/actions/runs/38327219219) took 275s. These are whole-job durations including checkout; different hosts and uncontrolled conditions prevent causal speedup attribution. |

No overall delivery-speed improvement is established by these observations.
Real adoption/effect of #2 batching, #3 ownership staging and #4 scenario helper
remains unverified; #5 has no demonstrated blocker fix and 1+1.3 remains a draft.

### Nearest delivery assessment — 2026-10-13 UTC (in progress)

The #54 operation-interval consumer has a frozen ordinary JS → Native batch
through existing `scripts/delivery_batch.py`; the first actual invocation terminated with exit 1 (0.590 seconds for the recorded JS wrapper), before
emission: the JS collector rejected an import-closure mismatch. Native remained
pending and did not run. Raw wrapper stderr and terminal receipt are retained in
`operation-interval-v1/runtime01/batch-output/` in the #54 worktree. Its collectors retain their own lock and full-byte oracle
checks; the batch stops on JS failure. A manual queue handoff was still needed:
#46 released its reservation because package authoring had no live heavy stage.
The observed effect is fail-stop sequencing on a real pre-execution refusal;
a successful automatic JS → Native sequence and any time saving remain unverified.

`scenario_controls` scene mode is not applicable to #54's plain String output:
there is no JSON scenario-map DTO. Complete 226,096-byte oracle equality remains
the primary check; no duplicate DTO layer is added. Actual #46 negative-control
helper checks and exact owned staging are being checked for this delivery.

The #54 refusal was a plan-ordering mismatch: the same 63 absolute import paths
were in insertion order, while the existing collector compares sorted paths.
Coordinator compared both successor plans to the failed plans: only sorting and
fresh output paths changed; source/tool/oracle/resource bindings and stage caps
were identical. The failed packet remains immutable; no guard was weakened.

#46 used current committed `owned_stage.py --root <worktree> --add` for its
90-path leaf manifest; coordinator validation of the actual staged set also
exited 0. The older worktree hook remains unchanged; current-hook ownership
validation will run on integration. Two actual `scenario_controls.py --stderr`
invocations exited 0 for the retained request/resource read-capability compiler
refusals, with explicit expected diagnostics and empty helper stderr. Inputs,
commands and outputs are retained in `authority-controls-v2/scenario-controls-v1/`.
This demonstrates bounded real adoption; no caught accidental staging error,
newly prevented semantic error or time saving is claimed.

The preserved runtime02 successor completed `WRAPPERS_PASS`: JS then Native
advanced automatically, with no manual release between jobs. Both actual consumer
receipts report complete pass and outputs match the independent 226,096-byte
oracle (SHA256 `fea8df01c26bf7141798bd2b45b4e4139e5bbe2b54af9c53674117be662245a9`).
Native used standard `-O3` within existing caps. Coordinator checked the terminal
batch receipt and both actual output files. This establishes one real successful
sequence plus one earlier fail-stop; comparative delivery time remains unmeasured.

#46 producer commit `6fb739056e687503b3d58b3d33ae00964a48472c` contains exactly
its 90 owned leaf paths. Its unchanged legacy configured hook exited 0; current
ownership-aware integration hook is the next check. The independent review covers
the finalized package, including the two scenario checks and ownership manifest.

Integration `af7832abdf860cf65cb12c4b59060d7b5de957ef` preserved the observations
above. Current hook with `BENDVY_OWNED_PATHS` validated exactly 93 staged paths
(90 producer files, final review, existing coordination table and this report),
and all 123 selected infrastructure tests passed. No unrelated paths were staged.
Master CI [38346105776](https://github.com/dearlordylord/bendvy/actions/runs/38346105776)
**SUCCESS**: functional job 04:22:14–04:24:01 UTC (107 seconds), including
checkout and cleanup under the unchanged five-minute limit. This confirms remote
integration checks; different hosts/conditions still preclude an overall delivery
speedup claim.

### Inspector timing-canary blocker — 2026-10-13 UTC

The first #54 timing canary completed INCOMPLETE: timer protocol exit 0, then
`inspectors-1-check` hit its unchanged five-second child deadline. No emit, build
or consumer ran. The unconditional terminal record reports no pin drift and an
unchanged Harness postguard. This was a real terminal failure, not an observation
timeout or cancellation. The legacy `execute_completed` path retains the exception
but does not publish raw child streams on deadline; no missing output is fabricated.

Before that failure, the parent had read 6.43 GB logically / 3.80 GB physically
(`/proc` observation at 12 minutes). Source inspection shows overlapping complete
resource/tool snapshots around each command; 22 commands would entail about 66
such traversals. This is a concrete runner-cost candidate, not proof of the
source-check timeout's cause. A scoped successor will reuse existing PinnedTools
and split-result publication, preserving all hash/membership/resolver checks and
all stage caps. No speedup or successful feature timing is established yet.

The #54 scoped successor caller passes five actual focused failure controls
(success, supervised deadline with both raw streams, combined child/postguard,
publication collision, receipt-write failure) plus a separate postguard-only
control. Both exercise the real caller class extracted from its AST. Selected
Python checks pass. Independent review found one remaining plan mismatch:
`scales: [1,2,4]` while this first ordinary probe runs only `[1]`; the probe plan
must match its actual commands. No successful timed consumer is claimed.

### Current lifecycle/scaling outcomes — 2026-10-13 UTC

#46 producer `0cca016b` contains exactly 283 owned paths. Existing ownership staging
and validation and the configured producer hook passed. Existing scenario controls
classify the retained expected FFI refusal; they do not establish a gameplay
negative or a proof. Independent final review accepts the complete 32-case
JS/TS/Native lifecycle oracle. Repeated/scaling performance remains open.

#54 scoped raw publication and barrier repairs produced a successful full scale1
timed consumer on JS, TS and standard -O3 Native. The scale2 build then reached
the unchanged 120-second deadline, with raw outputs and terminal receipt retained.
One runtime-selected repetition entry is under development; separate processes
are not substituted for the planned one-process scaling check. No overall delivery
speedup or full-feature performance qualification is claimed.

### Repeated lifecycle delivery — 2026-10-13 UTC

#46 reuses the accepted emitted JS/C and standard -O3 binary for all six scale2/4
consumers. Complete independent outputs and interval validation pass on JS, TS
and Native. Producer `d80c7c195` contains exactly78 owned paths; existing staging
and validation pass. Its first configured hook rejects whitespace after tests
pass; deterministic gzip preserves original source/stderr bytes, the next staged
whitespace check and configured hook pass. One final independent review accepts
the bounded packet. No repeated emit/build was needed; no general delivery
speedup or comparative performance result is asserted.

### Inspector enum / JS-TS delivery — 2026-10-13 UTC

#54 original private compiler emits the enum entry on both backends and the strict
generated barrier passes. The unchanged120s -O3 cap stops Native build, so Native
runtime remains untested. Reusing emitted JS gives six complete JS/TS1/2/4 oracle
passes without repeating emit/build. Existing staging/whitespace checks and
configured scoped hooks pass for82 +9 owned paths; separate final reviews accept
those bounded scopes. No shared runner changes trigger the full infrastructure
suite. Earlier layout-key experiments are rejected, not adopted.

#46 source/controller review accepts the258-command equivalent paired plan, but
its5s CPU11 probe alone does not establish quiet admission: target CPU is idle
while host load is10–11/12 cores and pressure data is unavailable. Comparative
execution is held; current codec-variant semantic coverage continues. No new
noise threshold, full delivery speedup or feature performance verdict is claimed.

### Codec variants and Native build control — 2026-10-13 UTC

#46 producer `667645b1` owns exactly101 paths. Ownership staging, whitespace and
the configured producer hook pass; one independent final review validates complete
40-row public constructor/resource observations on JS and standard -O3 Native.
Both match the21,488-byte independent oracle. Earlier failed Native arity emission
and source diagnostics are preserved. No shared core change or comparative
performance result is claimed.

#54 reuses the existing collector for one baseline C build control. Launch review
catches a source-label branch that bypasses artifact verification; the preserved
successor uses the existing build label and passes focused review. Previously
accepted C also hits the unchanged120s -O3 deadline with no fresh binary and
unchanged guards. The current host/build context is therefore inconclusive; no
causal claim about enum ownership differences or overall delivery speed follows.
Further Native builds are deferred pending meaningful conditions change.

#54 producer `cfc31dc13` retains31 owned paths and a62-member portable archive;
selected source checks, the read-only verifier, ownership staging, whitespace and
the configured hook pass. One final independent review accepts diagnostic scope.
The root batches these retained outcomes with #46, without rerunning compiler
experiments or changing shared runners.

### Source applicability and reference completion — 2026-10-13 UTC

#54 current public reader-consumption mutation was already reached by qualified
JS/Native event/Schedule consumers; reusing it avoided a duplicate fixture. The
actual gap was TS discovery-only scope. An independent source-only oracle author
derived58 observations before one existing Node collector executed. Full9,584-byte
equality passes, the21-path producer hook and separate final review pass, and root
integration `2ef73499c` has successful CI `38438370405`. Trace-shape differences
are explicit; this is no universal or full-feature speed claim.

#46 applicability review identified one changed source body in the45-file handle
consumer closure. Reusing its22-case80,800-byte oracle, the current pinned check
and both JS/standard -O3 Native consumers pass. Existing schema-classification
evidence stays separately scoped: the changed provisioning branch is not called
by these22 cases. Producer `e73060c98` owns52 paths; ownership, whitespace, the
configured hook and one final review pass for108 manifest rows/99 archive objects.
A missing sparse-checkout leaf was fixed by including only that assigned path;
no source or contract changed. No general delivery acceleration is inferred.

### Current pure-source gate — 2026-10-13 UTC

#54 source applicability investigation distinguishes old timed source05 from the
current enum and pure complete consumer. Historical pure source03 lacks sufficient
command/input/environment provenance for reuse. One actual current pure check
therefore uses the existing pinned wrapper and unchanged5s compiler cap; it is
INCOMPLETE with child-9/owned-descendant refusal, empty raw streams and unchanged
75 input guards. No timed FFI refusal is presented as a source success or current
enum failure. Producer `fe8808eaf` owns10 files; ownership, whitespace, configured
hook and79-member archive verification pass. Independent review accepts the
failure record, not the source gate. No source edit, cap increase, repeated
checker run or overall delivery-speed claim follows.

### Private source factor — 2026-10-13 UTC

One private helper replaces three identical nested query tails; all24 original
declarations remain. Its three expansions reproduce the original source bytes.
The candidate current pure check passes the unchanged5s cap, and one existing
JS collector passes the full226,096-byte oracle. Native emit-only reaches its
unchanged30s deadline before producing C; pass markers are retained, without
convergence/cause or speedup claims. No -O3 build/runtime occurs for this source.
Producer `b7ae10e1f` owns67 paths; selected checks, source expansion/archive
verification, exact ownership, whitespace, configured hook and final review pass.
Ignored runtime artifacts were staged with the exact ownership manifest only.
The helper remains experimental; original harness, core and installed tools are
unchanged. Neither this bounded success nor host contention waives full delivery.

### Current Native emission profile — 2026-10-13 UTC

One diagnostic reuses the existing outer controller and guarded collector.
Launch review catches mismatched artifact parents and compiler metadata before
execution; the preserved successor repairs only those bindings. Actual profile
is valid (1,469 samples/20,079,010 sampled microseconds) and covers setup/pass1/
partial2. Layout-key stringify contributes2.045 sampled seconds under its nearest
parent; inclusive totals overlap. No matched before/after, fullpass8 cause,
Native acceptance or speedup follows. Producer `357724bd` owns26 paths;133 archive
members, receipts/guards, selected checks, ownership, configured hook and final
review pass for diagnostic scope. Raw profile is archived without tracked duplication;
raw diff whitespace is retained under the configured evidence scope.

#46 provenance audit reuses current handle-admission's22-row JS/Native oracle
and41 exact source joins: both same-schema worlds reserve/populate live ID1,
and foreign targets/nested payloads originate from the second reservation.
This avoids another fixture; it does not establish independent-root/process-wide
namespace uniqueness or foreign resource replacement.

### Direct recursive BOX candidate — 2026-10-13 UTC

One private compiler helper reads only warm constructor metadata and returns the
existing BOX for a direct self-ADT witness; uncertain preceding fields retain the
old path. Eleven independent actual-function differential cases and seven owner
controls pass. The reviewed conditional batch executes full JS first:226,096 bytes
match the unchanged oracle. Native emission completes all8 passes and writes
23,882,225-byte C; standard Clang19 -O3 build reaches the existing120s deadline.
No binary/runtime or speedup/adoption evidence follows. Producer `7c923440b` owns
46 paths;156 archive members, portable verifier, selected checks, ownership,
configured hook and final review pass for partial scope. No repeated build.

A source-only census finds9,554 generated WL_CASE blocks; FORMAT_ROW_1 is49 lines
before macro expansion. This is not LLVM function size or build-cost attribution.
The earlier stack snapshot therefore remains a hypothesis: inspect runtime-helper
inlining and aggregate code before another compiler experiment.
Current source inspection also finds host task_node/ctr_take already FAR/noinline;
FORMAT_ROW_1 calls no ctr_take or term_keep. The old pre-outline task_node-inlining
explanation cannot be applied directly to this generated row. Current-stage
compiler/CPU evidence is needed before choosing another patch.

### Current-C compiler snapshot — 2026-10-13 UTC

The existing bounded SIGQUIT diagnostic executes once on current emitted C;
launch review repairs stale inherited provenance before execution. Raw stack
samples cc1 per-file LLVM IR generation at a composed query constructor,
ConvertType/CreateIRTemp/StartFunction, not the earlier SelectionDAG formatter.
Two same-process observations retain14.52 CPU seconds at20.88 wall and28.15 at
79.76 wall; no complete compilation CPU or scheduling/IO cause is inferred.
The runner refuses the killed command/owned descendants; all named processes
are absent afterward. No passing binary/runtime or ordinary build acceptance.
Producer `d098b6b65` owns29 paths;149 archive members, portable verifier, source
checks, exact ownership, configured hook and final review pass for diagnostics.

Source inspection finds a shared46-parameter WL ABI for9,554 functions, with
max41 live arguments in two joined world observers and31 result words. This
supports testing representation cost; neither the stack nor these counts prove
a dominant bottleneck or justify changing acceptance limits.

### Rejected inline-layout15 trial — 2026-10-13 UTC

One-literal private candidate31→15 passes finite layout boundaries and unchanged
full226,096-byte JS oracle. Native emit fails with an explicit null-layout-arms
TypeError; it is not a timeout. No C/ABI/build/runtime output; conditional numeric
roles remain NOT_RUN. Producer `fca09b1e3` owns43 paths;190 archive members,
portable verifier, selected checks, exact ownership, configured hook and final
review pass for retaining the rejected candidate only. Failed synthetic control
metadata was corrected with actual All telescopes before launch; logs retained.

A separate actual-parser/pinned-Base reproducer executes in0.37s within5s cap: old
virtual Word spine widths32→31→30 have arms, while budget15 produces TOP2 then
BOX1 and the next val_arm throws the same error. It proves this helper regression,
not a stack attribution for the complete consumer or a corrected implementation.
The next proposal must preserve virtual numeric bits until the existing physical
conversion boundary; no fake-pointer unboxing or budget/gate relaxation.

### Virtual word-spine correction trial — 2026-10-13 UTC

Only lay_match_word changes atop rejected budget15. Actual pinned-Base controls
compare all33 U32/F32 virtual levels and physical conversion with old31 behavior;
no fake BOX-pointer unboxing. Full226,096-byte JS oracle passes. Native emission
reaches its unchanged30s deadline with owned-descendant/pipes cleanup refusal;
raw pass1 begins at22.235752 CPU seconds. No C/ABI/build/runtime; numeric NOT_RUN.
Later no-process observation does not clear the recorded refusal.
Producer `cd9ed1def` owns51 paths;214 archive members retain the original Base
reproducer and corrected controls. Portable verifier, selected checks, exact
ownership, configured hook and final review pass for unqualified evidence.
No identical retry or causal/runtime-performance claim. Profile current setup
and emission before selecting another representation change.

### Source-current CPU profile retained — 2026-10-13 UTC

Producer `955bc9e26` retains21 owned paths and153 archive members; configured
hook, portable verifier and independent final review pass for diagnostic scope.
The child exits77 at the cooperative cutoff: collector INCOMPLETE, no C/native
artifact. Valid profile has1,747 samples across20.067517 sampled wall seconds.
Layout-key stringify under lay_of accounts for2.583458s; virtual word spine43.037ms
and val_box79.046ms are overlapping sampled-wall attributions, not CPU totals or
causal speedups. Next source-only candidate interns names in layout cache keys
while preserving normalization and distinguishing all selected names. Actual AST
collision/mutation/epoch controls precede the existing full consumer batch.
No acceptance, runtime performance or compiler adoption is established.

### Layout-name key candidate outcome — 2026-10-13 UTC

Producer `1dfa0de9` retains23 owned paths and198 archive members. Actual
55-term/3,025-pair controls cover reserved names, mutation, epoch reset through
file_book and nested/recursive physical layouts; full226,096-byte JS passes.
Native emits no C before unchanged30s child deadline, with clean guards. Numeric
stages correctly remain NOT_RUN. Configured hook, selected checks, portable
verifier and final independent review pass for partial evidence only. No identical
retry, speedup or adoption claim. Next source-only transplant keeps budget31
to isolate the key change from the blocked budget15 representation.

### Budget31 key-factor outcome — 2026-10-13 UTC

Producer `c41c648d` retains19 owned paths and194 archive members; selected checks,
configured hook, portable verifier and independent final review pass. The same
key-only change atop original budget31 passes the full226,096-byte JS oracle,
but Native again reaches emit30 child deadline at pass1 with clean guards. No C,
byte-identity comparison, build/runtime or numeric results exist. This experiment
does not establish improvement or regression under current host contention.
No unchanged retry. Source investigation now checks existing frame lowering and
the shared Native ABI; acceptance limits and installed compiler remain unchanged.

### Sequential private observer outcome — 2026-10-13 UTC

Producer `1230bdd8` retains34 owned paths and184 archive members. Pinned source
check03 passes63 files after two retained parser repairs; full226,096-byte JS
passes. Each original Dump call remains once, with all13 World fields restored.
Native emit reaches pass3 before the unchanged30s child deadline; no C/build/runtime
or measured bank/ABI exists. Additional reconstruction allocation cost remains
unmeasured. Selected checks, configured hook, portable verifier and independent
final review pass for partial evidence only. No unchanged retry.

Owner read-only reconciliation reports all63 old successful f686 source pins
still match, and all63 staged pins match. Relocating the private source paths
leaves62 files identical, including shared core; only world-observer changes.
This rules out unnoticed source drift in that comparison, not the deadline cause.

### Full-C frontend IR diagnostic — 2026-10-13 UTC

Producer `f08a5ae44` retains21 owned paths and106 archive members. Exact saved
23,882,225-byte C emits296,816,109-byte LLVM IR through Clang19 -O3 with LLVM
passes disabled; command exits0, guards unchanged. No command timing/CPU was
recorded. Collector generic success is explicitly FRONTEND_IR_ONLY, with no
consumer, optimizer/backend, full Native build/runtime or causal speed credit.
The IR has5,940,518 opcode starts:1,113,664 alloca,1,466,718 load,973,547 store.
These are syntactic pre-optimization counts, not runtime heap allocations. Largest
spin functions are mapped next to exact C before choosing a patch. The full IR
is retained inside the33.6MB compressed archive; selected checks, configured
hook, streaming verifier and independent final review pass.

### Borrow-location helper experiment — 2026-10-13 UTC

Producer `0808b9f04` retains33 owned paths and187 archive members. Saved C has
6114 reversible lookup-chain replacements; host and DEVICE-macro controls each
pass48 cases, including q=0 and lazy fallback. Full ordinary Clang19 -O3 reaches
the unchanged120s deadline with clean guards and no binary/consumer. Two raw
same-PID/start observations report compiler CPU40.65→106.37s and RSS1,822,868→
2,833,112kB; these are not ECS heap allocations or a performance comparison.
Selected checks, configured hook, portable reversal verifier and independent
final review pass for partial evidence. No regenerated pipeline/adoption credit.
Pinned cc1 help supports fdebug-pass-manager; next bounded diagnostic logs reached
LLVM passes on the derived C, preserving ordinary acceptance gates.
