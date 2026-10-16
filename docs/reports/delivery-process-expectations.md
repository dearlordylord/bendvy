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

Later session assessment: recorded below in the dated delivery observations and
retrospective reconciliation. Real use is established for several controls;
overall delivery-speed improvement remains unmeasured.

## Version 1+1 — additional improvements

Added 2026-10-12 from the session retrospective. These additions are approved for
implementation; they are not implemented by this table. Preserve the original
expectations above. Sequential batching remains original item #2; its later
real-session adoption is recorded below, not introduced as a new item here.

| # | Planned change | Expected result | Implementation | Effect observed |
|---|---|---|---|---|
| 1+1.1 | Use the pinned parity compiler in the lightweight development check. Repair parser/type/affine errors through that check, retaining diagnostics; prepare the frozen acceptance package after source success. Existing acceptance gates remain unchanged. | Development and acceptance use the same compiler identity; ordinary typing repairs avoid repeated acceptance preparation. | Implemented in isolated branch; four focused controls pass; Integrated at `3ad937194`; configured hook 123 tests PASS | Baseline: missing-resource consumer required eight source attempts, each with a frozen plan and guards. The development wrapper calls the floating `bend` alias, currently 2.0.36; parity uses 2.0.35. No improvement measured yet. Actual: pinned 2.0.35 wrapper check-only passes; four focused controls pass; no repair-speed measurement. Real session: #46 shallow-error repair used pinned checks (tiny 0.527s, full32 1.448s) before frozen backend plans; #54 setter source07 passed before oracle/consumer preparation. No comparative repair-speed measurement. 2026-10-14: the private #63 tuple-fusion candidate passed the same pinned development check in 0.59s before backend-plan preparation; this is source/type evidence only. |
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
| B. Detached inspection observations | #54 | No new held-view contract for the current Data projection API; reconcile existing evidence | Host retains detached Data observations across subsequent ECS operations while each call returns affine owners. Reuse current preservation evidence; arbitrary borrowed Type views would be a separate proposed capability. |
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
| 1+1.2 coordination table | Current table has 21 data rows, 8,740 characters total and a maximum row length of 896. Approximately 81% fewer characters than the original approximate 45,700-character baseline. | Direct measurement of `docs/parity/README.md`, excluding header/separator. The earlier 7,966-character observation remains historical. Reduced document size is established; navigation time is unmeasured. On 2026-10-15 the guard refused an over-1,200-character #56 integration row; a concise current row plus the existing history link passed. This is an actual bounded refusal, not a navigation-speed measurement. |
| 1+1.4 infrastructure CI | Two subsequent master jobs completed successfully within the unchanged five-minute limit: 84s and 88s. | [38330369008](https://github.com/dearlordylord/bendvy/actions/runs/38330369008): 01:04:32–01:05:56 UTC; [38331207282](https://github.com/dearlordylord/bendvy/actions/runs/38331207282): 01:14:56–01:16:24 UTC. Earlier successful job [38327219219](https://github.com/dearlordylord/bendvy/actions/runs/38327219219) took 275s. These are whole-job durations including checkout; different hosts and uncontrolled conditions prevent causal speedup attribution. |

No overall delivery-speed improvement is established by these observations.
At this observation point, real adoption/effect of #2 batching, #3 ownership
staging and #4 scenario helper was still unverified. Later delivery observations
below establish bounded adoption; this is a historical status, not the current
summary. #5 had no demonstrated blocker fix and 1+1.3 remained a draft.

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

### Retrospective actions — 2026-10-13 (side-thread handoff)

This assessment is not an implementation or a replacement for the active #54
experiment. Preserve current owners, live runs and their frozen inputs.

| Priority | Concrete action | Completion evidence |
|---|---|---|
| 1 | Inspect existing preflight coverage for the retained artifact-parent, inherited compiler-provenance and import-order mistakes. Extend the existing validator only for uncovered deterministic invariants; reuse its tests and CI. | Integrated from reviewed implementation `ea866de668`; 23 focused metadata/control tests pass. Malformed artifact-parent, current-C/compiler provenance and importClosure-order fixtures reject before batch output or child execution; valid successor fixtures pass. The saved emit-only profile successor passes metadata validation but remains outside ordinary runtime-role admission. Generic provenance and ordinary unpinned fresh outputs remain accepted. No compiler or new approval stage. |
| 2 | Reconcile current coordination rows: state the actual remaining blocker and executable next action; link accepted history. Mark earlier pending retrospective observations as historical where later evidence supersedes them. | Reviewed against the current coordination rows. #54 still holds comparisons for a quiet host and leaves #38 identity/adoption open; #56 retains its full-contract/coverage/overhead gates, and its original mixed-reader collector receipt remains INCOMPLETE. The shared table stays with the main-thread integrator. |
| 3 | Reconcile draft A–H against integrated acceptance evidence and present only remaining coherent child tasks for the existing approval. | The dated reconciliation below reuses accepted bounded evidence for A, B and D, retains C and E–G only with their existing contract dependencies, and keeps H on performance HOLD. Draft only; no child issue is published. |

The preflight change and focused tests are integrated from `ea866de668`. They
validate declared metadata bindings; actual bytes, runtime and terminal guards
remain the collector’s responsibility. Acceptance gates and live runs are
unchanged. Do not infer delivery acceleration or Native acceptance from these
controls.

Saved-plan replay anchors are retained under `experiments/public-inspect/promotion-stage/`
in the `observable-query-boundaries` worktree. Committed tests use isolated
deterministic reductions; manual metadata replay matched these exact originals:

| Saved plan below that prefix | SHA-256 | Metadata result |
|---|---|---|
| `missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/operation-interval-v1/timed-v1/pure-factor-v1/profile-v1/PLAN.json` | `8f6f41e68397b01456ece7f9da4eb41587f9d83009e084448f2b2d0f6bf70dbb` | Reject artifact root |
| `missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/operation-interval-v1/timed-v1/pure-factor-v1/profile-v2/native-output/plan.json` | `22006b470add5619d4c7930d2201191fcfc98d8d437c5dba4a230662b6e7adf1` | Pass bindings; emit-only runtime role rejected |
| `missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/operation-interval-v1/timed-v1/direct-recursive-box-v1/current-o3-stack-v1/plan.json.provenance-predecessor` | `a669b3a2634f774090d6d7c9a2ea268b447a013b8e7b528f041510ce49eece53` | Reject incomplete compiler provenance |
| `missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/operation-interval-v1/timed-v1/direct-recursive-box-v1/current-o3-stack-v1/plan.json` | `21d84ebc05f11ebcfc3a9d8d2072b2462e2881ab4d62314752dfdcba6eed05af` | Pass bindings |
| `missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/operation-interval-v1/runtime01/js/plan.json` | `947b06abf02d2f1627d871a4e6db8fd28e6590cf80e6a3b86b1ee32133eb90ae` | Reject import order |
| `missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/operation-interval-v1/runtime02/js/plan.json` | `c6405cccac0afe763fccb6268c0a474cddfece1f5d4004e9a64998c6277384e1` | Pass bindings |

### A–H reconciliation — 2026-10-14 (proposed, not published)

This updates the draft's current disposition without creating child issues or
changing parent acceptance. Rows already covered at an accepted bounded scope
are recorded for reuse rather than repeated as work items.

| Draft item | Current disposition | Remaining action or boundary |
|---|---|---|
| A. Optional/required resource absence | Reuse the accepted ordinary missing-resource registration and direct Inspector/Check observations. They cover optional and required execution in the recorded worlds, including refusal before the callback. | No new absence policy or duplicate child task. Broader #54 composition, proofs and performance remain open. |
| B. Detached inspection observations | Reuse the current Data-projection evidence: calls return affine owners and retained observations are detached Data. | No held-view contract applies to this API. Arbitrary borrowed Type views would be a separate capability proposal. |
| C. Multiple retained Schedule access indexes | Still open under #56. The accepted result covers one retained Schedule. | Obtain the existing ordinary multi-Schedule ownership/composition contract before extending the consumer. |
| D. Mixed-reader dump Native reached control | The complete retained Native output has a separately reviewed source-derived QName presentation rebase: all 228,202 counter bytes match and the 234,338-byte normal output is rejected at byte 355. | Preserve the original collector receipt as INCOMPLETE; do not call it a collector PASS or repeat the unchanged build. This closes only the bounded reached-output control. |
| E. Non-Column population and dump | Still unqualified; current accepted population/dump evidence is scoped to the supported Column/Product and aggregate-store bindings. | Agree the supported storage/iteration contract before adding another backend. |
| F. Native debug lint contract and execution | Remaining diagnostics and handling depend on an approved lint contract. | Resolve triggers, severity and handling through the existing SPEC process before implementation. |
| G. Native naming/replacement contract and execution | Remaining behavior depends on an approved naming/replacement contract. | Resolve the contract before adding a new consumer or implementation. |
| H. Inspector/debug performance qualification | Still on HOLD for the existing same-pipeline comparisons; host contention prevents comparative execution. | Reuse current semantic evidence and run only under the existing measurement criteria and a quiet admission window. No speed or adoption claim follows from the bounded functional packets. |

No issue is published by this reconciliation. Parent #54/#56 requirements,
existing approval boundaries, #38 independent-identity work, and #21/#23/#24
performance gates are unchanged.

### LLVM pass-manager trace — 2026-10-13 UTC

Producer `4d37847d` retains20 owned paths and148 archive members. Logged O3
build reaches the120s deadline, with clean guards and no binary/consumer. Raw
stderr70,136,619 bytes contains656,610 lines and261,853 pass starts across59
names; last entry begins MemCpyOptPass on a178-instruction query function.
This establishes reached optimization context, not individual cost or causation.
Configured hook, selected checks, streaming verifier and independent final review
pass for diagnostic scope only. Supplemental source mapping `a49009296` shows
spin817317→4611 instructions across Inliner with four incoming callees absorbed.
INLINE is ordinary static inline, not always_inline. Next factor introduces a
HOST-only ordinary-spin boundary; performance/acceptance remain unproved.

The admitted HOST-only ordinary-spin factor reached the same build120 deadline
(receipt `e4323971`, clean guards, no binary/consumer). The single serialized
ordinary run and existing collector were used; no unchanged retry or broader
qualification was started. This does not establish relative compile speed or
identify the dominant remaining cost. Retention review and source-backed next
factor selection continue under #54.

Unused incoming parameter names passed HOST/DEVICE finite ABI controls. The
HOST control retained C23-extension warnings; the source-only `__extension__`
successor also retained them. The prospective stop condition prevented both
full runs, avoiding warning-heavy qualification. This is observed runner use,
not evidence of faster delivery or Native qualification. A narrowly scoped
source diagnostic pragma is the next #54 candidate.

The scoped HOST C23 pragma passed its finite ABI consumer with empty stderr,
then the ordinary full O3 build reached build120 (receipt `c024abdc`, clean
guards, empty streams, no binary/consumer). The existing serialized sequence
was used without another admission or unchanged retry. Next evidence must test
whether unnamed parameters reduce frontend IR operations; compile speed and
full Native qualification remain unproved.

The tiny named/unnamed frontend IR pair completed through two bounded cap5
commands. Direct, frame and bridge instruction hashes/counts are identical;
removing names does not remove their prologue allocas/stores. This finite
mechanism test rejects the unused-name factor and prevents another unchanged
whole-world attempt. It does not establish general compile-time causation.

The heap_alloc mechanism controls passed hot/miss state/output equality and
showed optimized caller IR reductions (21→3 and 26→4 instructions), with a
shared 24-instruction helper. The conditional full ordinary O3 build/runtime
then passed the unchanged 226,096-byte oracle (`693d1158`). This qualifies saved
derived C, not regeneration or runtime speed. Tiny TU split/monolithic outputs
also match; its configured hook required static sparse-fixture reconciliation
after two missing-input failures. Broader TU work is held while the simpler
source-regeneration path is pursued. No overall delivery-speed claim follows.

The same candidate then completed regeneration from the pinned 63-file Bend
closure, ordinary O3 build and full consumer. Emitted C matched the qualified
derivative exactly; all 226,096 output bytes matched the unchanged oracle.
Independent final review accepted this current pipeline scope. Numeric, JS,
repetition/composition, performance and adoption gates remain separate; no
overall delivery-speed or full #54 completion claim is made.

The ordered current-candidate batch completed full JS and numeric JS/Native
through the existing serialized runner. Full output matched 226,096 oracle
bytes; both numeric outputs matched the existing 369 bytes. Portable evidence
verification passed 215 archive members. The prior full Native receipt was
reused rather than rerun; final review and single-process repetition remain
separate. This records batch/evidence reuse, not a speed or adoption claim.

The admitted existing enum repetition batch passed all 12 selector controls,
the timer protocol, full JS/C emission and generated boxed-barrier checks.
Ordinary Native O3 reached build120 with empty raw streams and clean guards
(receipt `b579b40a`); the runner stopped and did not execute any 1/2/4 runtime.
No unchanged retry is authorized by this result. The next work compares the
failed enum source/generated C with the qualified pure consumer.

The minimal enum query-helper successor completed the existing 28-command
batch, including ordinary O3 and all nine JS/Native/TS single-process 1/2/4
full-oracle runs (`1330c298`, clean guards). Source expansion was independently
checked against the unchanged original declaration. This is observed reuse of
a qualified source factor and unchanged runner, not a comparative speed or
compiler-cost attribution. Independent final evidence review passes.

The two-schema constructor precedence consumer passes complete JS/Native
observations; its copied fallible guard-bypass counter passes both backends and
rejects the structurally rebased normal term. Metadata preflight failures and
one oracle-digest mismatch remain preserved. The exact source with a final
blank line is archive-bound rather than normalized. The real recovered wrapper
also completes stock-check/private-emitter/full-JS observation. These are bounded
delivery results, not overall delivery-speed or comparative performance claims.

The existing #56 reached zero-limit Native control completed emit, ordinary O3
build and consumer with exit0 and ten clean guards. Its original collector
receipt remains INCOMPLETE because fixture relocation changed QName printing.
Independent review accepts a separately labelled retained-output qualification:
a source-path-derived reversible transform of both full independent oracles
matches all228202 counter bytes and rejects full234338-byte normal at byte355.
Reusing the preserved output avoids repeating identical compilation; no
collector PASS, comparative speed or complete #56 acceptance is claimed.

### Actual delivery usage — 2026-10-14

#38 and #63 used exact owned staging (27 integration paths and 896 retained
packet paths), configured hooks, independent final reviews and successful CI
`38578782976` / `38582275392`. Existing coordination rows were updated.
The #63 packet reuses v6 normal evidence and successful retained hit output;
only the remaining death consumer needed execution. Its first successor still
missed an emitter/output-root mismatch during review; the unchanged collector
refused artifact capture, and that attempt remains INCOMPLETE.

These deliveries used their existing runners and full scenario validators;
`delivery_batch.py` and `scenario_controls.py` were not directly invoked.
The generic preflight runtime dialect does not admit the combined simulation
plan, so this is not evidence of generic preflight coverage for that dialect.
No overall delivery-speed improvement is inferred.

Before the first #45 backend launch, manual operation/state/observation/oracle
reconciliation caught an independent oracle using the old observer DTO. The
current consumer renders different complete Array/World strings, and the oracle
source basis omitted its entry and renderer. No backend ran; the proposal stays
preserved while a source-only successor binds the actual consumer and renderer.
This is observed early manual coverage, not an automated preflight check or a
measured delivery-speed improvement.

The ordinary #45 frontend qualification exposed an oracle access-name assumption:
`ordinary-system.access` uses the bare declaration name. The independent author
corrected that source assumption without consulting output. Full retained JS
was revalidated separately, preserving the original INCOMPLETE receipt; only
the pending Native emit/O3/consumer ran. Native matched all2328 bytes. The
frontend also uses canonical lifecycle insertion and an actual survivor query.
These are bounded semantic results and observed reuse, not full #45 acceptance.

The matched #45 scope adapter used exact owned staging (32 paths), the existing
feature Harness and independent source oracles. Review caught noncompact JSON;
the first actual check then caught an import-alias collision. Both were repaired
without weakening validation. The successor passed all52 records/12932 bytes on
TS, JS and ordinary O3 Native. Generic batch/scenario helpers were not invoked;
this establishes bounded correctness, not comparative speed or faster delivery.

#55 also exposed a launch-review gap: plans pinned the policy-aware collector,
but execution called an older collector that rejected its declared telemetry.
Preserve the failed receipts; the successor review must trace the actual launcher
through the selected collector and strict stderr validator, not only plan hashes.
That successor passed all147180 JS oracle bytes and seven guards. Native then
reached its unchanged emit30 deadline with empty diagnostics and clean guards;
no O3 build or Native consumer ran. Compiler-source diagnosis is the next action.

The #42 IO-origin delivery used exact owned staging (58 integration paths), the
existing collector, a 122-member retained packet and independent final review.
A source-only oracle correction enabled separately labelled full retained-JS
revalidation; only Native needed a fresh emit/O3/consumer run. Both match all
18546 bytes. Integration CI `38636917989` passed. Subsequent source/tool/resource
joins reused existing relation and cleanup controls rather than adding fixtures.
Batch/scenario helpers were not invoked; no delivery-speed gain is measured.

The #55 source-profile diagnostic localized repeated query specialization. A
three-module runtime-Data-spec candidate then passed the unchanged full136-call
JS/Native consumer, including stock C emission and ordinary O3 under30/120/5 caps.
Reachability review caught root imports before candidate execution; the coherent
83-module stage and independent review bind the actual replacement. The compact
master selection retains raw data only in its archive. Protected #28 reuse is
bound to its unchanged23-source workload; no overall delivery-speed or Inspector
runtime-performance improvement is established.


### Retrospective reconciliation — 2026-10-14 local session

This reconciles the existing tables with later delivery observations and the
session conversation. It adds no runner, approval stage or acceptance criterion.
Distinguish a mechanism that failed, one not invoked, and an unmeasured benefit.

| Existing improvement or practice | Observed outcome | Remaining limitation / next action |
|---|---|---|
| #1 preflight | Works for covered invariants: the integrated 23 focused controls reject artifact-parent, compiler-provenance and import-order mistakes. | Coverage is not universal: the combined simulation dialect is unsupported, and #55 review pinned one collector while its launcher invoked another. Trace the actual execution chain and extend existing checks only for a concrete uncovered invariant. |
| #2 sequential batches | Real runtime02 JS → Native sequencing completed automatically; later deliveries also used existing serialized runners. The 2026-10-15 #56 matched batch used delivery_batch.py with actual collector bindings: TS → JS → Native completed all six commands without a manual stage handoff. | Whole-queue manual handoffs remain. A delivery using another runner is not a failure of `delivery_batch.py`, nor evidence that it was used. Reuse the appropriate existing runner; time saved is unmeasured. |
| #3 exact ownership staging | Applied to real #46, #38, #63 and #42 integrations with exact owned sets and configured hooks. On 2026-10-15, #56 staged 24 producer paths plus explicit review/docs; #43 staged 14 producer paths plus explicit review/docs. Both configured 134-check hooks passed. | No accidental staging error caught in these deliveries or comparative time saving is established. This is demonstrated adoption, not pending implementation. The reader/debug integration used exact manifests for the seven-file retention packet and 23-file debug delivery; sparse checkout initially refused experiment paths after staging five owned core files. Materializing the declared directory allowed the remaining 18 owned paths to commit; no unrelated paths were staged. This is an observed tooling limitation, not an atomic-staging guarantee. |
| #4 scenario controls | Two real #46 expected-diagnostic checks passed. Other consumers used their existing full-output validators. | Before the next #56 backend freeze, source comparison caught a raw Bend resource mutation versus a TS declared System; the new matched fixture now uses declared systems on both sides. No backend pass is claimed for that fixture yet. Plain String output does not require a duplicate scenario DTO. Non-use of this helper is not missing validation when the existing oracle covers the complete observation. |
| Evidence reuse | Retained outputs are revalidated without repeating unchanged compilation; original INCOMPLETE receipts stay intact. The 2026-10-15 mode/scaling packet verifies 1,157 commands, 1,065 full outputs, eight profiles and nine malformed controls offline. Exact staging selects 30 source/harness plus seven packet paths. | Reuse is demonstrated; total delivery acceleration is unmeasured. A two-function allocation candidate showed no consistent timing gain and remains archive-only; full feature-performance acceptance is open. |
| Independent final review | Runtime Inspector packet review caught missing joins between command stream metadata and archived raw streams; the successor added path/size/digest rejection controls before integration `654863f3f`. | Check whether the existing verifier primitives can cover the same joins elsewhere; do not invent another evidence framework or repeat an already fixed defect as an open implementation task. |
| Bevy-first guidance | Did not prevent a redundant user question about duplicate Schedule names, despite the existing Bevy-first policy. | Apply the existing priority: ask only when sources leave a real choice or Bend requires an observable divergence. New API surface alone is not a new semantic decision. |
| Task-local blockers | Did not prevent stopping the whole goal while comparative measurements waited on CPU contention; the user had to intervene. | Keep that measurement lane on hold and continue independent semantic/implementation work. Reconcile the executable frontier before treating the whole objective as blocked. |

The pinned development check, reduced coordination table and active infrastructure
CI also have demonstrated use, as recorded above. No new generic tooling is
justified solely by the remaining failures. Prioritize task-local blocker handling,
correct use of Bevy authority, and concrete gaps in existing checks. The initial
retrospective overlooked some later observations and proposed work already done;
future assessments must reconcile this document before recommending replacements.


### Targeted follow-up — launcher and raw-stream joins

Read-only inspection and offline checks following the local 2026-10-14 retro;
no compiler, benchmark, collector child or live queue was launched. Only this
report is updated. Historical packets, verifier identities and receipts remain
unchanged.

| Subject | Checked result | Disposition |
|---|---|---|
| Runtime-entry stream joins | `experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/verify.py --selftest` passes. `verify_command_join` compares the complete receipt stream path with manifest `sourcePath`, byte count and SHA against decoded archive bytes; malformed path/count/digest controls reject. | Already fixed and tested; no new task to repair this packet. |
| Runtime08 retained qualification | Its existing offline `delivery-v1/verify.py` passes. The archived `LAUNCH.json` collector object equals the JS plan's `collectorBinding.collector`; the command template selects that collector path. | The inspected successor declarations are consistent. This comparison does not independently reconstruct the OS-level historical invocation or prove the old launcher mistake cannot recur. |
| Runtime08 stream path identity | The verifier locates command streams with `PurePosixPath(ref["path"]).name`, then checks publication, bytes and SHA. An in-memory control executed that exact existing AST loop against the archived JS receipt after changing only one stdout parent directory; it still passed. Archive and receipt files were not changed. | Concrete missing semantic check: bind the full receipt path to the selected manifest member's `sourcePath`. Contents are verified; this is not evidence of corrupt output or a forged archive passing all integrity gates. A future reviewed verifier successor should add the path join and a same-basename/wrong-parent refusal, preserving the historical verifier and its pinned identity. |
| Generic batch launcher binding | `scripts/delivery_batch.py:run_batch` validates each plan digest and role shape, then executes independently supplied `job["argv"]`. Its guard freezes manifest/plan bytes and published streams; it does not compare selected wrapper/collector/interpreter bytes with a declared launch binding. Existing tests intentionally allow generic wrapper commands. | A frozen plan alone does not establish which collector is invoked. For collector-backed jobs, reuse the existing launch binding in review and any focused check; generic wrappers need not be banned. This is a bounded code-inspection finding, not a demonstrated wrong launch in the current packet or a reason to rewrite historical runners. |

Main-thread batch follow-up (2026-10-15 UTC): `delivery_batch.py` now checks the
existing opt-in `collectorBinding` against the actual interpreter/collector/run/
plan/digest argv, including the declared transparent taskset prefix. Referenced
interpreter, collector and support bytes are guarded before output creation,
between jobs and at finalization; wrapper receipts retain argv/cwd/cap. Generic
plans without that binding retain their existing arbitrary wrappers. All 28
focused retro controls pass, including same-basename/copied-byte substitutions,
dependency drift and terminal-receipt preservation. Independent Spec/Standards
review passes (`5c7beb85c481d0222901b517cbb300f96212741867e55a6311821ac3e4b477c6`).
These controls establish bounded refusal behavior; the bound-child tests stub
execution, so live collector adoption and delivery-speed improvement remain
unmeasured. No compiler or benchmark is used by these targeted checks.

The full Runtime08 stream-path join and wrong-parent control remain required in
its next maintained, reviewed verifier successor. Preserve the historical
archive-bound verifier identity. Do not add another approval layer or infer
complete capability acceptance from these offline checks.

2026-10-15 integration effect: root relocation of the #43 packet exposed a verifier reading producer-local ownership paths. A three-file successor uses checkout-relative owned paths and passes relocated-copy and local-drift refusal controls; historical runtime evidence was reused without recompilation. Named-schedule and reader slices are integrated at `6a037719b` and `898f268d1`. Their fresh combined220 unchanged #28 gate passes independent final review (123 commands, 110 complete outputs, 20 pairs/backend). Full feature timing remains open; no overall delivery-speed improvement is inferred.

The next #56 three-role batch exposed one concrete preflight gap: the existing collector supports consumer-only TS, but batch preflight required emit. The explicit TS role now validates its sole five-second consumer and exact taskset/Node/entry argv; generic wrappers and JS/Native/source dispatch remain supported. All 31 focused retro controls pass, and independent source review accepts this bounded change. Inventory and byte pins remain checked by the collector. Actual three-role batch execution subsequently passed: WRAPPERS_PASS, no pending jobs, all three collector receipts COMPLETE_CONSUMER_DEVELOPMENT_PASS. Each backend produced the full 30,216-byte independent oracle (SHA `5321aca3b050c1fa14fa923297cf34edbe73913da180fcbe0076703392e6d8aa`); all six commands and post-run pins pass. This demonstrates actual bound-collector batch adoption, not comparative performance or total delivery acceleration. The compact packet and runnable sources are now integrated after independent final review: 167 retained members, 12 malformed controls, relocated-checkout positive/local-drift refusal, and all 64 relocated Bend source bodies match. Original receipts and unsuccessful historical attempts remain unchanged.

2026-10-15 targeted follow-up application: the resource-observation delivery integrated at `95829f93f` uses full receipt-stream sourcePath joins and a same-basename/wrong-parent refusal. Independent final Spec/Standards reviews and offline verification pass (599 members, five roles, seven malformed/relocation controls); CI 38739505266 passes. Historical Runtime08 verifier remains unchanged, so its successor obligation remains open. This is bounded verifier adoption, not measured delivery acceleration.

2026-10-15 next adoption: the #43 full-capacity successor applies full receipt-path/manifest joins and same-basename/wrong-parent refusal to 942 logical paths and 21 retained roles. Relocated-copy and source-drift controls, independent final Spec/Standards reviews and 137 infrastructure tests pass. Existing runtime outputs were reused without compilation or benchmarks. Historical Runtime08 remains unchanged and its successor obligation remains open; no aggregate delivery-speed gain is established.

2026-10-15 scheduled-reader delivery: `ca17e431a` reuses the ordinary collector for four JS/Native success roles and two current-source JS mutant controls. The single retained packet checks 583 full paths, 263 objects and ten roles including failed/unexecuted history; same-basename/wrong-parent, relocation and drift controls pass. Independent final Spec/Standards review, eleven infrastructure scripts and CI 38762806597 (functional 2m04s) pass. All 77 unrelated tracked workspace states were preserved. This confirms another concrete application of bounded staging and stream joins; it does not measure aggregate delivery acceleration or repair the historical Runtime08 verifier.

## Delivery-cost reduction — 2026-10-15 execution checklist

User-requested follow-up to the side-thread retrospective. This section is today's
execution reference in the existing report; it adds no separate plan or reporting
system. Preserve earlier observations. The user requested coverage of every
identified source of work, including deletion of checks with no incremental value.
The rows below are implementation candidates, not claims of completed changes.
Main-thread owners and live frozen runs retain their assignments and inputs.

Inspection baseline: `.githooks/pre-commit` runs eleven infrastructure test scripts
for any staged Python file or change under scripts/benchmarks/hooks/workflows.
CI explicitly runs those suites, and also invokes a staged-only hook after clean
checkout. That hook invocation does not inspect the PR diff. This is NOT eleven
duplicate CI suite executions: the hook's broad branch normally skips on an empty
index. Coordination validation is duplicated by the explicit CI command and
`test-retro-v1plus1.py:test_current_table`. Seven experimental admission suites
share broad helper triggers. Tracked experiments/scripts contain 1,955 Python
paths, 157 `verify.py` paths and 239 `FINAL-REVIEW.md` paths, including historical
copies; these counts are an inventory signal, not proof that those files are
redundant or actively maintained. No runtime costs were measured in this audit.

| ID / priority | Files and source of work | Change / removal candidate | Expected saving and retained protection | Completion / current status |
|---|---|---|---|---|
| R1 / first | `.githooks/pre-commit`, `scripts/test-pre-commit.py`; eleven suite commands also listed in `.github/workflows/infrastructure.yml` | Remove the all-Python => all-infrastructure-suite local trigger. Keep staged syntax/policy, whitespace, explicit ownership/preflight, and affected controls. Keep complete infrastructure suites in CI; exercise changed shared infrastructure locally where useful. Update tests that currently require broad dispatch. | Fewer unrelated suites per oracle/fixture edit. Full infrastructure coverage still runs before delivery through CI. Local feedback moves later for unrelated failures; do not call this zero tradeoff. | Implemented locally; focused selection controls pass. Demonstrate experiment-only, core-only, shared-helper and hook edits select intended checks; preserve complete CI suite membership. Record skipped invocations and one real commit's duration. |
| R2 / first | `.github/workflows/infrastructure.yml`, `scripts/check-python-source.py`, `.githooks/pre-commit`, `scripts/test-pre-commit.py` | Replace CI's staged-only hook invocation with checks against actual changed committed files. Use PR merge-base and push before/after with sufficient fetched history; define initial/missing-base fallback. Reuse the existing Python checker and whitespace check. | Removes a misleading no-op and validates the submitted change without rerunning the local hook. This improves coverage; time saving is not assumed. | Implemented locally; focused controls pass for changed Python rejection from a clean index, valid changes, deletions, unusual filenames, and base fallback. Preserve the AST source policy and explicit infrastructure suite run. |
| R3 / first | `scripts/run-admission-controls.py`, `scripts/test-pre-commit.py`, every `CONTROL_SETS` entry and its declared dependencies | Audit all seven groups: chunked-output preservation, lowering-cost source, Inspector preparation, TS fullcapacity admission, simulation sampling, timing and after-profile. Remove unrelated shared-helper triggers; keep real execution/import dependencies. Retire a historical group from routine dispatch only after locating current consumers and retained evidence users. | Fewer historical experiments run for unrelated helper changes; active caller compatibility and exact staged-byte checks remain. | Partially implemented locally (two groups); account for each existing dependency edge as kept/removed with its source reason. In particular inspect receipt-helper triggers for pure source-preservation checks. Selection controls must demonstrate both affected execution and unrelated omission. No blanket removal of all seven groups. |
| R4 / small | `.github/workflows/infrastructure.yml`, `scripts/test-retro-v1plus1.py`, `scripts/check-coordination.py` | Remove the separate CI table-validation command; retain `test_current_table`, malformed/sprawl controls and the staged table check. | One redundant CI invocation removed; same current-table predicate remains. Small saving only. | Implemented locally; retained test invokes the same `check` on the current table; confirm malformed table remains rejected. |
| R5 / high | `experiments/**/verify.py`, `**/FINAL-REVIEW.md`, `**/LAUNCH-REVIEW.md`, packet builders/manifests and their callers; `docs/parity/*.md`, `docs/reference/core-map.md`, `docs/check-policy.md` | Classify selected current evidence, actively reused prerequisites, and historical attempts through existing capability links. Stop updating historical verifiers to today's infrastructure by default. Delete redundant live copies only after checking imports, manifests, CLI entrypoints and source pins. Preserve historical content in Git/archive and its existing reference. Reuse existing verifier primitives when touching a current verifier. | Less packet/version maintenance and repeated review. Current evidence must still establish source, execution and full oracle equality. Preserve original failed outcomes. | Pending inventory, not permission for bulk deletion. For every proposed deletion identify its surviving check and users, or mark the missing coverage. Do not build a new evidence framework or migrate all 157 verifiers. |
| R6 / high | `docs/agent-workflow.md`, `docs/check-policy.md`, `docs/reference/evidence-runner-details.md`, current capability consumer/oracle/serializer files and linked review packets | Apply existing small ordinary-consumer-first workflow. Keep complete relevant observation; separate semantic fixtures from capacity/scaling volume. Freeze acceptance packaging after the consumer works. One final review/package per integrated slice; remove extra manual stage admissions for unchanged reviewed runners. Reuse valid outputs after documentation-only changes. | Fewer serializer repairs, frozen-plan successors and review handoffs before a useful feature lands. Small fixtures do not substitute for explicitly required capacity gates. | Pending next-delivery observation. Name the public operation delivered, reused evidence, actual new checks and final integration. Do not add another report per intermediate stage. |
| R7 / high, acceptance amendment | `docs/parity/relation-readers.md` delivery requirements and other feature specs with timing/scaling clauses; governing GitHub issues; `docs/SPEC.md`, `benchmarks/README.md`, #21/#23/#24 and #28 references | Prepare one coherent amendment moving mandatory per-feature comparative timing/scaling to combined full-feature qualification. Keep functional boundary/scaling correctness where contract-sensitive, targeted measurements for hot-path changes/regressions, and existing combined #28 regression. Align all affected issue/spec requirements before treating a feature as accepted under the new boundary. | Removes repeated timing campaigns as a barrier to each semantic delivery. Final JS <= TS and Native <= 0.5 * TS goals and statistical criteria remain. Tradeoff: some feature-specific performance defects are discovered at combined qualification. | Approved by the user’s subsequent "Ну давай, вперед" after presentation of the exact amendment. Applied to27 feature specifications, SPEC and benchmark policy; issue synchronization is recorded below. |
| R8 / medium | `scripts/check_preflight.py`, `scripts/owned-tool-pins.py`, existing collectors using them, `docs/reference/evidence-runner-details.md` | Inspect repeated full environment/resource discovery and avoid incidental-shell invalidation by using the same explicit execution environment for preparation and execution. Reuse existing PinnedTools only where its closed inventory is already justified. Remove duplicate probes only after tracing their inputs; avoid a new resolver-inventory project without measured benefit. | Fewer repeated probes and avoidable receipt invalidations. Compiler, resolver inputs, generated artifacts and meaningful environment changes still invalidate evidence. | Investigation pending. Identify an actual current caller and probe counts first; preserve drift/refusal controls. Never merely drop environment keys from a receipt while allowing those keys to affect execution. |
| R9 / high operational | `docs/parity/README.md`, linked capability status/issue requirements, `docs/agent-workflow.md`; existing batch manifests and `scripts/delivery_batch.py` | Keep contention HOLD local to comparative measurements; continue independent semantics/features. Use existing sequencing for ready ordinary jobs. Reconcile old A–H drafts with current accepted work before creating tasks; keep remaining gates visible in existing rows. | Fewer idle handoffs and repeated planning. Preserve heavy-run serialization, owners and failed-stage stops. | Existing mechanisms; next delivery must show actual use. Record a concrete delivered capability while timing waits. No new scheduler, tracking layer or broad task fan-out. |
| R10 / medium | `scripts/test-retro-controls.py`, `scripts/test-retro-v1plus1.py`, shared validators and current packet negative controls | Distinguish duplicate checks from checks at different trust boundaries. Consolidate repeated same-input/same-predicate tests where the surviving test covers the actual caller. Keep real wrong-path, wrong-collector, stale-source, affine/authority, rollback and reached semantic-defect controls. | Lower maintenance without deleting unique failure detection. A unit test alone does not replace a caller integration test. | Pending targeted review alongside R1–R5, not a new exhaustive testing project. Each deletion records the surviving failure detector; tests solely asserting obsolete broad dispatch change with R1/R3. |
| R11 / continuous | This report, `docs/parity/README.md`, capability docs, `docs/agent-workflow.md`, `docs/check-policy.md` | Keep implementation result and review requirements in their existing homes. Replace repeated historical narration in active status with links. Remove duplicate instructions where one authoritative rule suffices. Report product capability and remaining gate before receipt/archive counts. | Less reading, rewriting and context recovery. History remains accessible; existing acceptance status remains truthful. | Pending edits only where touched by this work. No new global instructions, document split or recurring reporting obligation. |

Execution order: R1–R4 as one focused infrastructure change with existing tests;
R5/R6/R8/R10 only against the next selected live delivery, so cleanup does not
become a replacement product; R7 as one explicit requirements amendment; R9/R11
apply during ordinary delivery. Shared infrastructure edits must be coordinated
with the main-thread owner before modifying frozen inputs or a live execution.
The side thread currently owns only this appended report section.

For every row update this table in place with the actual files changed/deleted,
commit, retained failure coverage, focused check result and observed effect.
Use existing logs/CI durations to record elapsed time, suite/probe invocations,
manual handoffs and useful integrated result. Record unmeasured savings as
unmeasured; do not infer speedup from file counts or compare contended runs as a
controlled experiment. No new telemetry runner or benchmark is needed for this
cleanup. An item may finish as "keep" with a concrete reason; no source of work
above should disappear merely because deletion was unsafe.

Implementation update (2026-10-15, side thread; local, not committed):

- R1 implemented in `.githooks/pre-commit` and `scripts/test-pre-commit.py`:
  eleven broad infrastructure-suite invocations removed from local commits.
  Staged policy/whitespace, ownership/preflight and selected admission controls
  remain. All eleven infrastructure suites remain explicit in CI.
- R2 implemented in `.github/workflows/infrastructure.yml` and
  `scripts/check-python-source.py`: CI checks committed Python bytes and whitespace
  using PR merge-base or push before/after, with full history checkout. A missing
  base conservatively checks the full tree; an invalid head fails. The old
  staged-only CI hook invocation is removed. Full-tree fallback may expose
  historical policy violations; it fails visibly rather than skipping checks.
- R3 partially implemented in `scripts/run-admission-controls.py`: source
  preservation and lowering-cost controls no longer depend on receipt logging or
  evidence-boundary helpers. Their actual task-runner dependency remains. Those
  two helper edits select five suites instead of seven. The other five groups
  remain unchanged pending dependency inspection; no historical test was deleted.
- R4 implemented: remove the separate CI coordination command; the existing
  `test-retro-v1plus1.py:test_current_table` and staged check retain validation.
- Focused controls in `scripts/test-pre-commit.py` cover clean-index committed
  syntax failure, unusual filename, deletion, missing-base fallback, merge-base,
  invalid head, and working-tree repair failing to conceal bad committed bytes.
  Selection controls cover omitted source suites and retained task-runner fanout.
- R5–R11 remain as listed above. Acceptance amendments are not applied. No
  compiler, benchmark, live queue, staging or commit was invoked. Counts removed
  are established from dispatch; end-to-end delivery savings are unmeasured.

Validation: 16 hook/diff/selection tests and four pinned-wrapper/table tests PASS;
selected Python source-policy checks PASS. Whitespace check PASS after removing
a trailing blank line. GitHub CI has not run for these uncommitted changes.

### R1–R11 disposition after implementation and dependency inspection

Side-thread continuation: the preceding final message did not start background
work. The interval before this continuation contained no side-thread execution.

| Item | Concrete outcome / remaining boundary |
|---|---|
| R1/R2/R4 | Implemented locally in the files listed above. All eleven configured infrastructure suites were executed once and PASS. Committed-diff/hook controls:16 PASS; table/pinned-wrapper controls:4 PASS. CI still needs to run after main-thread integration. |
| R3 | All seven groups inspected. Preserve task-runner dependency for chunked-source and lowering-cost callers; remove their unrelated boundary/log dependencies. Inspector preparation loads task_runner and evidence_boundary, not receipt-logs: remove the latter. Sampling receipt control evaluates a pure admission predicate from prepare-sampling: remove all three runtime-helper triggers. TS fullcapacity actually loads runner/boundary/logs/comparator: retain them. Timing dispatch covers run-delivery, and after-profile remains coupled to that collector's output: retain those conservative caller triggers. Result: task_runner edits select6 groups, evidence_boundary4, receipt-logs3, previously7 each. All groups still run for selector edits; direct collector/validator triggers remain. Historical test bodies are unchanged. |
| R5 | Inspected selected #43 scheduled-followup delivery README and verifier. It checks current normal, independent-world and two semantic-mutant evidence; predecessor outcomes and disposal applicability have distinct roles. No whole verifier or archive was established redundant. Keep this selected verifier. check-policy now limits maintenance to selected current packets and actually reused prerequisites; no bulk historical migration. Historical files remain recoverable and unchanged. |
| R6 | Existing workflow already requires a small ordinary consumer before large packages and one final review. Retain those rules rather than invent another admission. The selected #43 small consumer is26,254 bytes; the current packet reuses a disposal bridge instead of replaying it. No reason to rewrite that consumer/serializer or remove its full observation. Future capacity checks remain separate where required. |
| R7 | Approved and applied to the27 matching feature specifications, SPEC and benchmark policy; corresponding issue bodies are synchronized before publication. Retains correctness, #28 and final performance criteria; no issue is automatically closed. |
| R8 | `experiments/public-simulation/delivery-v1/installed-config.py:environment` already provides an explicit stable mapping. No shell-variable fix is needed there. Its candidate explicitly says the installed resolver inventory is unadmitted; `run-delivery.py:ordinary_guard` therefore keeps ordinary tools.verify discovery. Retain it; do not delete guards or launch a resolver inventory project without measured cost/benefit. This is a keep decision, not an unimplemented promised optimization. |
| R9 | agent-workflow now makes backend blockers local to their capability and directs independent work to continue. Keep existing delivery_batch and its stop-on-failure/locking behavior. Current semantic delivery and queue operation remain owned by the main thread; no new batch service or duplicate task inventory. |
| R10 | Removed duplicate CI table invocation and obsolete broad-hook assertions. Preserve wrong-parent, wrong-collector, source drift and runtime semantic negatives: they exercise different boundaries. The selected #43 packet's wrong-reader and premature-publication mutants detect different defects; no safe merger demonstrated. |
| R11 | Removed stale17-line "Adoption by #48" instructions from evidence-runner-details (historical PR/worktree state, imperative after-pull steps and repeated gate prose). Generic opt-in PinnedTools guidance remains. Corrected the failure-injection description from commit hook to CI. Existing coordination assignments and A–H drafts were not rewritten from stale side-thread knowledge. |

One local full infrastructure pass took about16.6s total suite wall time:
runner11.04s, hook controls3.94s, remaining suites about1.6s. This is a single
uncontrolled observation, not an end-to-end delivery speedup or CI prediction.
For a local Python-only commit that previously ran all eleven suites, those
suite invocations are now absent; selected admission and staged checks remain.
No benchmark, compiler, profiler or heavy-run lock was invoked.

### R7 approved acceptance replacement

Replace the repeated requirement "Add equivalent complete feature-specific
TS/JS/Native observations and timing/scaling evidence without dropping work" with:

> Add equivalent complete feature-specific TS/JS/Native correctness observations
> without dropping work. Keep feature boundary and capacity correctness checks.
> Qualify comparative timing/scaling on the combined feature workload under
> #21/#23/#24; individual semantic delivery need not repeat that campaign.
> Consequential hot-path changes and detected regressions still require targeted
> performance investigation. The combined #28 regression, final JS <= TS and
> Native <= 0.5 * TS goals, and agreed statistical criteria remain unchanged.

The original clause is present in these27 files under `docs/parity/`:
`affine-events.md`, `bundles.md`, `captured-schedules.md`, `captures.md`,
`component-state.md`, `coverage.md`, `debug-trace.md`, `debug.md`, `defense-plan.md`,
`features.md`, `fragments.md`, `handlers.md`, `hierarchy.md`, `identity.md`,
`inspect-extended.md`, `inspect.md`, `laws.md`, `machines.md`, `recovery.md`,
`relation-readers.md`, `relations.md`, `restore-basic.md`, `restore-graph.md`,
`scopes.md`, `simulation.md`, `snapshot-export.md`, `validation.md`.

After accepting this placement change, reconcile their linked issue bodies,
`docs/SPEC.md`, `benchmarks/README.md` and remaining-gate status text; preserve
historical measurement claims and explicit exceptions. Semantic completion must
not be reported as full-project performance acceptance. The user subsequently approved this amendment; the changed placement now governs
individual semantic delivery. No new numerical tolerance is proposed.

### Publication checkpoint — 2026-10-15

User approved proceeding after the exact R7 proposal. The27 repeated clauses in
feature docs and GitHub issues #38–#64 are now amended; each remote issue body
was fetched again immediately before replacement, preserving other content.
SPEC and benchmarks/README record the same scope. No issues were closed and no
historical measurements relabelled. Remaining status text referring to full
feature timing denotes combined qualification, not a prerequisite to individual
semantic delivery under this dated amendment.

Source/Spec self-review: local hook retains staged policy, whitespace, ownership,
preflight and actual caller admission; all eleven infrastructure suites remain in
CI. New committed-diff checks validate committed bytes with clean index and fail
on invalid head. Removed helper edges have source-backed non-use; reached defect
controls remain. Runtime/ECS code, benchmark tolerances and frozen experiments
were not modified. All eleven local suites PASS; selected Python policy and
owned-diff whitespace checks PASS. Independent agent review remains for the main
thread: side-thread instructions prohibit subagents. CI publication outcome will
be appended after the exact pushed commit is checked.

Publication follow-up:218b5b548 was pushed and all27 remote issue clauses were
read back successfully. Initial CI38791219738 exposed an unnecessary full-history
checkout while still in checkout; local Git packs total2.93GiB (not a measured
network transfer). Corrected checkout to depth2 and fetch the base commit at
depth1 only if absent. Push comparisons need endpoint trees; GitHub pull_request
runs use the synthetic merge commit with its base parent available at depth2.
A failed required base fetch fails CI; zero/absent base retains the explicit
full-tree validation fallback. No full-history transfer is required.

CI outcome: code/policy commits `218b5b548` and `fad6e9c5d` are on origin/master.
[Run38791374316](https://github.com/dearlordylord/bendvy/actions/runs/38791374316)
passes the committed-source/whitespace step and all infrastructure suites for exact
head `fad6e9c5dda611364270f54a58f614efd7d51832`; functional job took3m13s.
Superseded full-history run38791219738 was explicitly cancelled. The shallow
checkout/older-base fetch was also exercised in a disposable local repository.
This establishes successful integration checks, not faster whole-job delivery.
This result note is left for the main thread's next documentation commit; it does
not require another identical code qualification. Independent review remains a
main-thread handoff; no independent reviewer was invoked in this side thread.

Main-thread independent review of `ca436d224..fad6e9c5d` found no blocking process/CI regression: staged checks and selected admission remain local, all eleven infrastructure suites remain in CI. Clarified the umbrella remaining-core specification to match the approved consolidated-performance policy. On the next #43 acceptance reconciliation, existing complete observations and source/artifact applicability were reused without another compiler or benchmark run; a timing-only administrative blocker was removed after independent semantic audit. This is an observed acceptance effect, not a measured delivery-speed improvement. #48 development continues through the ordinary consumer path; its oracle worktree now uses the reduced hook.

Next ordinary delivery (#48 initialization) used the existing collector and reduced hook: complete JS/Native correctness and a reached semantic mutant passed before integration review, without a separate comparative timing/scaling campaign. Existing #28 evidence was reused after checking all 23 protected source bindings. Missing type-check logs required focused recapture; deadlines under contention were retained as inconclusive, and successful type-boundary diagnostics were preserved. This records actual use of the shortened path, not a measured delivery-speed improvement.


The next #48 condition-composition delivery used one complete JS/Native consumer,
then one reached eager-RHS mutation and independent review through the existing
collector. The 82-path producer graph was adopted through a 68-body source join
and a successful relocated entry check; review found duplicate backend runs
unnecessary for this path-only adoption. The protected #28 inventory still
matches. Capacity evidence from a different experimental representation was
explicitly excluded from canonical acceptance. No comparative campaign or new
runner was added, and no delivery-speed improvement is claimed.


The #48 canonical FIFO delivery reused the existing collector for complete
capacity, boundary and ordinary-adoption observations. A reached no-eviction
mutation rejected the normal oracle. Focused before/after CPU and allocation
profiles used the existing profiler after independent launch review; all four
outputs matched. The protected #28 source inventory still matches, so unchanged
Workshop compilation and timing were not repeated. The earlier CI outcome and
process review were already committed and were reused. This records actual
application of the reduced path, not measured delivery acceleration.

FIFO integration `17ac51620` passed independent final review, relocated evidence
verification and CI38815107631 (functional job 2m0s). The seven packet files
reuse historical source bytes from Git where current root files have changed;
current adoption hashes remain separate. No unchanged backend was rerun for
packaging, and no overall delivery acceleration is inferred.

The next #48 Bundle adoption reused the historical full oracle after independent
source review, then passed one complete JS/Native pair through the unchanged
collector. Only fixture imports, exhaustive source arms and snapshot observation
changed. Root adopted identical bodies and reused protected #28 applicability;
no production core change or comparative campaign was needed. Reconciliation
identified an actual missing ordinary machine-reader lifecycle adapter, rather
than treating additional repeated verification as feature delivery.

Bundle integration `4e5f945a5`: CI38816522497 attempt1 reached the full
infrastructure job but an unchanged Node lowering-cost control hit its five-second
cap. The same focused five-test suite passed locally in 0.052s; a single unchanged
CI retry passed (attempt2, functional job 1m55s). No limit or test was changed, and the original failure remains
in the CI history. This is not an ECS runtime failure or a delivery-speed claim.

2026-10-15 ordinary machine-reader delivery: the existing collector completed
the primary two-schema consumer on JS/Native (105,004 bytes each), actual
WorldIO foreign/disposal on JS/Native (17,347 each), and a reached JS disposal
mutation (17,433 bytes, rejected by the normal oracle). No runner or limit was
changed. Existing marker, failed-writer, capacity and executed TS evidence was
reconciled instead of rerun; all 23 protected #28 source pins remain unchanged.
Portable retention and bounded final review pass. Review identified one precise
remaining scenario: a registered reader skipped before its first activation.
These are observed avoided reruns, not a measured aggregate delivery-speed improvement.

Reader integration `5e83795b3` passed CI 38822275712 (functional 2m15s). The
review-discovered first-use skip case subsequently passed complete JS/Native
13,717-byte observations using the same collector and limits; no core repair
was needed. Only those two new roles were executed; the five qualified roles
are reused in the selected packet. Overall delivery acceleration remains unmeasured.

#48 semantic acceptance is integrated at `4b2d1bc1b` after seven-role packet
verification and independent issue-level review. CI 38823080584 passed in 2m02s.
The final first-use case reused the implementation unchanged; two new backend
roles completed the specific gap without repeating the previous five. #49 now
has a complete current-source component-write JS/Native pair (24,422 bytes each);
its wider acceptance reconciliation continues. No comparative speed claim.

#49 acceptance reconciliation reused the six historical failure positions and
three named controls through exact reached-source bridges, plus retained TS and
requirements evidence. Only the current-source First-Transition JS/Native pair
was rerun; complete 24,422-byte outputs and independent final review pass. No ECS
core code, runner, cap, performance threshold or historical receipt was changed.

#49 integration `b78be08c4` passed CI 38823741359 and the semantic issue closed.
#54 reconciliation identified a genuine remaining stock-Native gate: the full
23-grant consumer's stock emit timeout is not superseded by the smaller stock
formatter case or the later private-compiler run. Work continues on preserving
the full consumer while applying the already qualified source-only formatter.

The formatter and subsequent one-use Frame-thunk attempts each match the full
5,077,477-byte independent oracle on stock JS; each stock Native emit reaches
the existing 30-second deadline without C output. No retry with unchanged source,
limit increase or partial consumer is counted as acceptance. The next source
candidate targets query callback specialization. No delivery-speed gain is claimed.

#46 acceptance reconciliation reuses the stock 32-case TS/JS/Native public views
and complementary 92/22/40 state/owner controls. Independent review found no
missing native operation requiring another backend run. The documentation keeps
private compiler evidence and archived JavaScript host interop separate; combined
performance remains required. This checkpoint changes documentation only.

#46 reconciliation `a2442d48d` passed CI 38825895705 (functional job 1m58s);
the English criterion-level report was posted and #46 closed. This checkpoint
reused existing execution evidence; CI duration is not an overall delivery-speed
measurement.

During #54 callback preparation an oracle pin file was amended after readiness
while the collector was acquiring its lock. The guard refused before compiler
execution; the failed receipt is retained and a fresh successor binds the final
oracle commit. No backend result is attributed to that rejected attempt.

The callback successor reached the stock Native emit deadline, but its final
guard also refused: a parallel oracle owner reapplied sparse-checkout patterns
in the shared worktree, removing 63 pinned oracle files. Root restored their
exact committed bytes without rewriting the INCOMPLETE receipt. The producer
closure was unchanged; no clean Native qualification is claimed. This is an
observed coordination failure, not an acceptance or delivery-speed improvement.

#45 delivery adds only the missing source-level survivor-deletion control: four
stock JS/Native normal/counter runs match complete independent oracles. Existing
ordinary, foreign-world, affine, reference and #28 evidence is reused through
exact applicability joins. Independent joined semantic review passes; no
production source or performance threshold changed. Root verified the retained
packet and all normal/mutant source bytes, without replaying backends.

#45 integration `05dd2b753` passed CI 38828003993; the English criterion-level
report was posted and the issue closed. The self-contained eight-file evidence
packet retains exact source snapshots; duplicate loose copies were omitted
rather than normalizing their historical whitespace or bypassing the hook.

#44 reconciliation reuses retained complete traversal/reorder/cleanup results and
compiling controls. Independent review verified their current source joins and
actual executable identities; an old per-command version-probe note does not
identify an uncovered execution risk. The historical later child-set timeout
remains failed and is covered only by its existing successor. No new backend or
performance cohort ran for this documentation checkpoint; all three native
semantic criteria pass.

#44 reconciliation `a8090c7e8` passed CI 38829031368; the English completion
report was posted and the issue closed. No backend or benchmark was rerun for
this checkpoint. Total delivery-speed improvement remains unmeasured.

#41 reconciliation joins qualified heterogeneous bundles, ordinary duplicate
admission, constructor/retry, WorldIO and complete matched application evidence.
Independent review confirms current source applicability and all three semantic
criteria. Inventory publication predates production adoption; chronology before
initial experiments is not claimed. No backend, performance or private compiler
experiment was rerun to close this documentation checkpoint.

#41 reconciliation `76c1735b8` passed CI 38829653048 and the issue closed.
Qualified execution evidence and independent source review sufficed; no unchanged
compiler/benchmark run was repeated. This records fewer required runs, not a
measured end-to-end speedup.

#54 coherent runtime-callback candidate `cc617c302` preserves all 47 frozen
inputs except the composition kernel, with independent join `9e9d51785`. The
complete JS oracle (5,077,477 bytes) passes; stock Native emission still exceeds
30 seconds with clean source guards and no generated C. Further representation
guesses stop pending per-pass specialization/layout attribution. No acceptance
limit changed, no speedup claimed, and #55 fixture/oracle work continues independently.

The #54 per-pass diagnostic reached its cooperative cutoff and retained the CPU
profile, but its validator rejected a truncated 1,376,256-byte summary line. The
copied diagnostic logger ignored `writeSync` partial-write counts; the failed
receipt stays INCOMPLETE. A focused durable-write repair and actual pipe control
are required before retrying. Complete preceding phase events and the separately
parsed profile support only partial analysis; counter totals are not accepted.

The focused logger successor passed synthetic short-write/error controls and a
4,200,112-byte real Bun pipe capture. Reviewed diagnostic attempt02 then passed
with a complete summary: 3,185 family rows, no attribution overflow, and exact
global/pass/family reconciliation. Three complete emission passes each visited
5,646 definitions and made 146,315 body calls before a partial fourth pass.
This supports targeting the Inspector lookup/scan execution boundary; it does
not establish stock timing, a dominant CPU bottleneck or Native acceptance.

The resulting #54 private execution-callback experiment reduces complete-pass
emitter visits by 8.58% (146,315 to 133,765), but leaves 5,646 definitions and
2,260 new native-cache entries per pass unchanged. Full JS remains correct;
stock Native still misses emit30. This is measured compiler-work reduction,
not delivered Native acceptance or a runtime speedup.

The first #55 full physical JS comparison caught source-model errors omitted
by the earlier logical-only oracle: Base boolean spelling and Array backing-tree
capacity. All 136 logical records match, but physical acceptance remains failed
until an independently source-justified oracle successor and full comparison.
Native was not launched against the known-invalid physical expectation.

The #55 successor now passes the complete 271,299-byte physical oracle on stock
JS and Native. Independent review verified all three semantic criteria and the
relocated 493-object packet, including ten malformed controls and preserved
failed-model history. The existing collector, reduced hook and source-applicability
joins avoid another comparative campaign or backend rerun for packaging. This
records actual use of the shortened path, not measured delivery acceleration.

The #55 packet integrated at `3a0d0e26d`; CI38834835781 passed and the issue
closed after its English completion report. A checkpoint independent review of
`218b5b548` and `fad6e9c5d` found no blocking Spec/Standards issue: all eleven
infrastructure suites remain in CI, and correctness, unchanged #28 and final
performance goals remain binding. The earlier CI38791374316 note is preserved.

The next #58 delivery reconciles existing complete two-schema save evidence
with current sources and an independent final review. All four semantic criteria
pass without compiler or benchmark repetition: the only changed dependency
preserves the empty pending-list path actually reached by this consumer. Original
failed receipts and posthoc mutant validation retain their recorded limits. This
is another observed evidence-reuse outcome, not a measured delivery-speed gain.

The #58 reconciliation integrated at `b8c7cde5b`; CI38835649996 passed and
issue #58 closed after its English completion report. #54 remains open: actual
Frame transport preserves full JS but still exceeds stock Native emit30. Its
separate diagnostic reached four complete passes before an uncovered cooperative
cutoff path; no full counter or profile comparison is claimed from that failure.

The #54 tail diagnostic captured complete counters/profile, but root invoked
the pinned collector directly instead of the reviewed collect wrapper. The
wrapper-only artifact sidecar is absent; original receipts remain unchanged and
independent review evaluates actual retained evidence separately. Subsequent
launches must execute the existing LAUNCH.launchArgv verbatim. No rerun solely
to manufacture missing historical metadata is credited.

Independent review `77e138efb` joins the actual direct invocation: all 159 plan
pins, eight guards, exact child argv, complete raw summary and captured profile
match. A reconstructed profile inventory is explicitly posthoc. These records
support bounded copied-compiler observations only; they do not repair the outer
launch provenance or qualify stock compilation. The next hypothesis is the
existing isolated order-preserving graph-index optimization, not another ECS
representation change or a relaxed deadline.

The #63 ordinary simulation now passes full stock JS/Native observations and an
independently modeled lifecycle mutation. One portable packet and final review
reuse the prior TS, hit/death and authority controls through source joins, without
repeating those backends or a comparative campaign. Historical #28 evidence has
an explicit World-source timing limitation; this batch changes no production
hot path. This records actual use of the shortened path, not measured acceleration.

#63 integrated at `687abb043`; CI38839033849 passed before the English completion
report and issue closure. Early operation/state/observation review on the next
#38 delivery found absent changed-stamp observations before freezing backend
plans. Fixture-only observers and an independent model are being completed;
no new runner or process layer is needed to address that concrete gap.

The #38 successor completed all four stock backend roles on the first attempt:
full authority and rollback on JS/Native, including the stamps added after the
pre-freeze review. The existing ordinary collector and portable verifier were
reused; no production core, new runner or comparative campaign was needed.
This demonstrates a concrete missing-observation repair before backend execution,
not a measured overall delivery-speed improvement.

The #38 authority/rollback packet integrated at `831c9b332`; CI38839909825
passed and the governing issue received the bounded completion report. The issue
remains open for its other criteria and unresolved identity policies.

The #38 scan-owner audit reused the superseding owner-extension evidence instead
of repeating a large run for a stale report. The genuinely missing public
fork/join handoff received one JS/Native pair through the ordinary collector;
both full outputs passed on the first attempt. Anonymous-task ordering is handled
by moving complete sessions, and the report excludes physical allocator races.
This records targeted new coverage and avoided duplicate work, not timed savings.

#71 semantic acceptance reused complete normal, second-schema, affine, capacity,
authority and mutation evidence after checking 171 current input bindings and
independent final review. No compiler or comparative campaign was repeated for
this documentation-only reconciliation. Historical feature slowdowns remain
visible under the approved combined-performance policy. This is concrete evidence
reuse, not a measured delivery-speed improvement.

The #38 fork/join integration CI38841376108 passed on rerun; its first attempt
was cancelled during checkout before tests executed. Code and limits were unchanged.

#71 reconciliation integrated at `4ffa0a9a5`; CI38842756621 passed and the
English issue report closed semantic acceptance. The #54 budget0 discriminator
used one reviewed emission-only run: C grew 8.18%, so no speculative build was
added. Independent review `1fadd0009` verifies artifact difference only; budget
permutations stop pending current Clang-cost evidence. No speedup is claimed.

#59 used the ordinary collector for one complete detached constructor before
expanding to a reached preservation defect. A first JS oracle-rendering mismatch
was corrected from compiler source without changing the consumer; the original
failure remains. Corrected normal and defect pairs pass stock JS/Native. One
portable packet reuses the existing verifier pattern and independently checks
complete owners; root offline verification passes without recompilation. No
comparative campaign or measured delivery-speed claim accompanies this slice.

#59 prerequisite integrated at `c96a86676`; CI38844439235 passed and the
bounded English report was posted without closing full restore. #54 current
Clang evidence redirected investigation from the old formatter sample to lazy
call-graph traversal. An isolated host function-table lookup boundary passed
the full consumer under unchanged caps. The copied generator then emitted the
identical qualified C, allowing reviewed build/runtime reuse instead of another
compilation. This is a concrete candidate result, not measured acceleration,
stock acceptance or compiler adoption.

The #54 protected-workload bridge reused byte-identical JS instead of another
regression cohort. Changed Native C received one build and full 231,190-byte
correctness observation through the existing collector; both passed under the
original caps. The ELF differs, so old Native timing evidence is not reused.
Comparative measurements remain deferred under CPU contention. This records
actual avoided duplicate work, not measured delivery acceleration.

Checkpoint `3772334a1` passed CI38846886015. Independent review `e2d24f3b3`
confirms the protected Native correctness/ELF distinction and source-derived
full54 JS reuse, and accepts the current #64 requirements as planning only.
No compiler or workload run was repeated for these reviews.

The next #61 delivery used one source check and one stock JS/Native pair through
the existing collector; all 5,281 bytes matched the independently derived
failure oracle on the first attempt. The complete rollback/cursor/error
observation was fixed before execution. Independent final review passes.
The #54 protected default and targeted compiler comparisons both passed after
fresh qualitative CPU11 admissions; one retained packet preserves 220 complete
outputs. This resolves the earlier protected regression-pending checkpoint,
not compiler adoption or full-feature performance. No delivery-speed estimate
is inferred. CI38847248022 for `83d40b939` also passed.

The combined candidate-evidence/AppA failure delivery integrated at `68efe3f98`;
CI38848592760 passed. English bounded reports were posted to #54 and #61; both
issues remain open. Shared ECS and the selected compiler pin are unchanged.

The next delivery removes an unnecessary #50 general ownership question:
pinned Bevy retains FunctionSystem captures and returns RemovedSystem on
unregister. The existing approved Bevy-first direction therefore selects explicit
affine capture persistence and owner-returning unregister without inventing
automatic finalizers. Implementation proceeds via existing Local machinery;
#52 arbitrary inverse trust remains a separate observable boundary.

Checkpoint `ee12c1687` passed CI38849444025. The #50 ordinary consumer passed
stock JS/Native on its first pair: five commands, all 3,749 oracle bytes equal,
original limits and existing collector. This precedes expanded schedule and
authority controls. Verified source/tool bindings allow reuse of the actual TS
reference and stock combined220 #28 evidence: its 23-source closure is unchanged
and imports neither new capture module. The existing stock artifact identity
bridge applies; the copied-compiler cohort is not substituted. No new runner,
unchanged infrastructure rerun or comparative campaign was added. These are
observed avoided checks, not measured delivery acceleration or capture performance.

The first #50 API integration `ea88404fa` passed CI38850872625. Its scheduled
successor then matched all 6,169 oracle bytes on both stock backends. Scope review
identified the remaining ordinary query capture accumulator, so #50 remains open
and the work stays in that issue rather than moving it to composition #51.

The scheduled/authority batch integrated at `79e50c731`; CI38851950845 passed.
Its ten normal/control backend commands used the existing collector and full
independent oracles; protected regression and actual TS evidence were reused.
Independent final review preserved the query-capture gap in #50.

The #50 repeated-unregister delivery uses four existing-collector roles and one
independent final review. Both normal and reached-defect outputs match their
complete oracles on JS/Native. No production source changed; protected #28
evidence remains applicable. Query JS also matches its complete oracle, but its
Native runtime timed out after a successful build under heavy host contention;
that result remains inconclusive and is preserved for artifact-only diagnosis.

Repeated-unregister integrated at `be9156014`; CI38853899329 passed. A reviewed
Native runtime-only successor reused the exact query ELF and passed all 7,441
oracle bytes under the unchanged 5s cap, avoiding another emit/build. The
original timeout remains INCOMPLETE. The actual TS query witness passed all 8,785
bytes after repairing a callback return-value mistake; its failed predecessor
is preserved. These results establish scoped correctness, not comparative speed.

The #50 App successor used the existing collector for five successful commands
and 17 unchanged guards; both full4,961-byte outputs match its independently
authored model. Automatic debug bindings and separate cursors are observed. The
joined independent review accepts #50 semantics. The protected23-source workload
is unchanged, so its qualified regression evidence is reused. No broad local
infrastructure or comparative timing campaign was added; delivery acceleration
remains unmeasured.
