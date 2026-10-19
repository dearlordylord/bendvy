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
| 2026-10-18 #21: 1+1.1 development checks and 1+1.4 CI | Pinned source checks precede three-role method runs; Health, Sparse and actual Dense-boundary slices reuse existing collectors and validators. | `b849f9012`, `024249aa8`, `37fdb5e59`, `2172cf917`; CI39117879624/39118905686/39119222929 pass. Immutable JS output was reused after one source-backed oracle repair. Queue handoffs remain manual; automatic batching and overall delivery acceleration are not claimed. |
| 2026-10-18 FailedTxn: ordinary consumer, ownership and controls | Motion and Health complete methods and actual-boundary consumers passed before additional controls or scoped reuse; all four slices received independent final review. | `bbb997334`, `336677724`, `e7ac196c2`, `2e66dca54`; exact ownership prefixes were integrated separately. Existing runners and qualified accounting controls were reused; archives needed no backend reruns. Combined #28 source pins match with the existing foreign-source exception. No delivery-speed improvement is measured. |
| 2026-10-18 Lifecycle/Readers: ordinary consumers and source-bound reuse | Accepted Motion/Health methods and actual-boundary slices pass full ordinary consumers before additional checks, with one final review per slice. | Latest `068211677`, `c9cc34fb9`; complete evidence and prior commits are recorded below. Existing runners and generic controls were reused without extra launch admissions for routine ports. Historical failures/provenance qualifications are retained. Packaging required no backend replays; queue handoffs remain manual. No delivery-speed improvement is measured. |

| 2026-10-16 #53 delivery: #2 batching, #3 ownership, #4 scenario controls and 1+1.4 CI | One exact 4,172-file owned integration delivers 24 new ECS modules; unrelated WIP is excluded. Five canonical consumer/control pairs qualify stock JS/Native; integration CI passes. | [32539b721](https://github.com/dearlordylord/bendvy/commit/32539b7210aaff94fb956edda8abe0040e3c644f), [CI38883496921](https://github.com/dearlordylord/bendvy/actions/runs/38883496921), and the existing final-review artifact retain the evidence. Focused checks and reached scenario controls were used; six oracle defects were fixed before reader execution. Protected #28 evidence was reused without another benchmark. Overall delivery acceleration is unmeasured. |

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

#50 query completion integrated at `34d7712cd` after independent joined review.
The next implementation is #51, reusing the delivered capture lifecycle and
existing schedule/requirements machinery. CI38855954288 passed and #50 was closed after its English acceptance report; no compiler
or benchmark is repeated for this status note.

#51 first consumer `28b1a2e9b` passed stock JS/Native against all 6,161
independent oracle bytes on its first pair: five successful commands under the
existing limits. It composes distinct query Pack/resource Array capture types
through generic products and observes every changed state before expanded
conditions/admission/disposal checks. No new runner or preliminary review stage
was added; this is a bounded feature result, not full #51 or measured speed.

#51 expanded consumers passed their full independent oracles on both stock
backends: admission 15,793 bytes, lifecycle 4,217 and stateful conditions 13,895.
The admission consumer retains a real deferred Counter+37 operation and observes
its terminal drain, so pending preservation is checked by effect as well as count.
Stateful conditions reuse #35 semantics and observe machine state, queues and
separate cursors. Existing collectors and limits were reused; no comparative
performance or overall delivery-speed claim follows.

#51 final review accepts its semantic criteria. Root also checked all seven
portable packets offline: 3,099 per-packet compressed objects, 31 successful
commands and 106 unchanged guards, including exact full-path raw joins and
complete consumer oracle equality. This reused the completed runs; no backend
was repeated for retention or review. One coordination delay came from sending
messages to a completed helper; resuming it with followup_task resolved it.
No new process document or check stage was introduced.

#51 integrated at `1bcf107fa`; CI38859172838 passed, its English acceptance
report was posted and the issue closed. The next owner proceeds to #52 with the
existing exact-recovery requirement and host-IO boundary; ordinary #50 capture
persistence is preserved. No numerical performance criterion changed.

The first #52 ordinary resource consumer passes stock JS and Native -O3 against
the independently derived complete 6,951-byte owner trace. Five commands and 17
guards use the existing collector; source-current checks reuse the unchanged
23-body protected #28 closure and its reviewed stock artifact bridge. No extra
benchmark or infrastructure campaign was run for this additive slice. Actual
rank-2 authority controls pass/reject at their intended boundaries. Component and
opt-in capture recovery remain in #52; this is another observed reuse of the
shortened delivery path, not measured delivery acceleration.

The requested checkpoint review of `218b5b548`/`fad6e9c5d` again finds no remaining
Spec/Standards blocker. Follow-up `804554913` already repaired the umbrella
remaining-core timing clause. CI38791374316 and its earlier report note remain
valid without reruns; correctness, #28 and final performance goals are unchanged.

The reviewed first #52 resource slice integrated at `c8f5b4c5c`; CI38861304008
passed and an English bounded report was posted without closing the issue.
The TS applicability note reuses existing actual executions with explicit runner
and ownership limits, avoiding another unchanged reference run.

The next #52 consumer passed stock JS and Native against all 13,009 independent
bytes on its first backend pair, covering component stamps, affine owners and
explicit capture rollback. The isolated commit-owner-loss defect also passed
its full 6,631-byte countermodel and rejected the normal trace on both backends.
Both use the existing collector and unchanged caps; new authority checks cover
the affected boundaries while unchanged resource controls are source-bound reuse.
The protected23-source regression closure remains unchanged. Heterogeneous
ordinary-family composition remains within #52; no delivery-speed claim follows.

#52 now passes joined semantic review after the general heterogeneous and mixed
consumers. Stock JS/Native match all 13,523 and 16,673 independent bytes; mixed
includes nine interleaved operations in one journal. Actual run plus ten intended
authority negatives pass, and earlier owner-loss/TS/stock #28 applicability is
reused with explicit limits. The real builder specialization blocker was fixed
with an erased type index supported by the pinned Bend compiler; no compiler
change, higher cap or runtime Lens duplication was needed. Both first backend
pairs passed without source/model repairs after freeze. The current report
records successful CI38862946527 for `f818fa192`; final integration CI remains
pending. This is observed semantic delivery/evidence reuse, not measured speed.

The general #52 integration `d38025142` passed CI38865825685. Before closure,
the literal independent-application requirement exposed a provenance gap: the
consumer and core shared an implementation owner, although the oracle was
independent. One fresh no-history application owner now exercises the ordinary
API, including present-component None removal with rollback/commit. This focused
gate preserves the existing matrix and is not a core defect or a new campaign.

The independent #52 application's first stock JS execution found a fixture
indexing error before Native was launched: canonical Column access maps a
positive entity ID to physical index id-1; the seed and oracle had assumed
id-padding. The failure did not exercise present removal. A source successor
will correct the seed and enumerate all physical slots through valid IDs. The
failed source, oracle and receipt are retained; no acceptance gate is relaxed.
The reduced local checks and existing collector were used; delivery-speed
improvement remains unmeasured.

The corrected independent consumer passed both stock backends against the fresh
complete 2,276-byte oracle, with unchanged compiler/caps and no production source
repair. The first failed JS attempt remains historical; its Native run was
avoided. Existing #52 authority, reached owner-loss, TS applicability and #28
evidence remain reusable. This records actual use of the shorter delivery path;
it does not measure total delivery-speed improvement.

Independent final addendum accepts the #52 writer/removal evidence. The requested
checkpoint review also confirms prior reviews apply to `218b5b548`/`fad6e9c5d`: all
eleven infrastructure suites remain in CI, with correctness/#28/final performance
goals preserved. No unchanged process tests or benchmarks were repeated.

#52 closed after combined integration `8b80a21ba`, successful CI38868650606 and
the English acceptance report. No per-feature comparative timing/scaling campaign
was required; correctness, independent application, reached mutation, current TS
applicability and protected #28 evidence remained binding. #53 is the next active
implementation. This is a completed delivery under the shorter policy, not a
measured speedup or final performance qualification.

#53 first ordinary and independently authored applications execute on both stock
backends with complete 24,875/9,107-byte observations. The existing import guard
refused an incomplete independent-app inventory before any child; a metadata-only
successor added six unchanged transitive sources. The ordinary oracle confused
reported boundary with effective retention cutoff; its source-derived successor
matched retained JS bytes, so JS was not replayed. Original failures remain
immutable. Existing runners/caps were reused without added infrastructure. Full
#53 still requires family isolation, query/resource composition and authority/loss
controls; this first slice is not full acceptance or measured delivery speedup.

The #53 query/resource+publication consumer passed both stock backends against
its full 6,877-byte independent oracle on the first attempt. The next three-family
consumer hit Bend’s 32,768-character specialization-key guard. Removing unused
row/plan template arguments repaired the concrete source check (0.91 s) without
changing behavior, compiler identity or limits. Source `e1b1023b5` then passed both stock backends against the corrected
21,529-byte source-derived oracle. Retained JS output was reused without replay;
the original failed-oracle attempt remains immutable. Per-family reader source
`21ddb0860` and final-family blind app `aed70b746` pass concrete source checks
and await independent oracle/backend qualification. Reader/query/resource
composition, authority and mutation remain acceptance gates. These
are observed delivery steps and preserved checks, not an overall speedup measure.

The final-family blind application `aed70b746` passed stock JS and Native on
the first attempts against its complete independent 10,193-byte oracle
`b42f24158`. Packet `68a1d9f3f` preserves both results; no output/model repair
or replay was needed. Actual-entry authority controls `4538fedbe` passed two
positives and rejected nine intended misuse cases. The unchanged collector and
focused pinned checks were reused; combined reader/query/resource delivery and
final acceptance remain pending, with no measured process-speedup claim.

Combined reader/query/resource source `edc8fb566` passed stock JS and Native
first attempts against all 48,711 independently derived bytes (`4ce4d58be`);
portable packet `a4561ad39` retains both results. Direct nominal IO chains removed
a development-only template-depth failure without changing the compiler, limits
or scenario; original diagnostics remain preserved. Combined-grant controls
`cc2fa3125` pass two positives and reject eight intended misuses. Independent
review confirms the unchanged 23-source protected regression closure and reuse
applicability. Full reader lifecycle and reached-retirement-loss checks remain.

The independent final review found source/model mismatches in the first normal
family-reader oracle `53ce7a6d9` before execution: capacity units, retention
boundary and nested projection (lag and line framing were also flagged for
recheck). Plans `09a0d6173` were sealed but held without launching either backend.
The original model/plans remain immutable; correction follows frozen source,
not runtime output. This is a concrete defect found by the existing review,
not evidence of measured overall delivery acceleration.

The corrected reader oracle `1a117f417` passed its first actual JS/Native
executions (90,973 complete bytes); the reached retirement-loss variant
`465683a90` passed both 90,719-byte counters and rejected the complete normal
result. Packets `022650a66` and `0a18bc059` retain all raw joins. The single
independent final Spec/Standards review is PASS with no unresolved finding.
No compiler, runner, acceptance cap or performance threshold changed. Exact
owned integration preserves unrelated WIP; configured integration CI follows.
These outcomes show actual use of focused checks, batching and source-bound
scenario controls; overall delivery speedup remains unmeasured.

Integration `32539b721` passed CI38883496921; #53 is closed with all four
criteria checked and English completion report
https://github.com/dearlordylord/bendvy/issues/53#issuecomment-6212941919.
The final status-only documentation update reuses the unchanged source/backend
evidence; no compiler or benchmark rerun is needed for this CI note.

The next #61 AppA cross-feature successor uses the same shortened path: ordinary
main/IO entry source checks pass at stock five seconds; the complete independently
derived 18,892-byte oracle matches stock JS and Native on their first pair
(five successful commands, seventeen unchanged guards). Only after that pair was
the portable packet retained for the single final review. All eighty imported
ECS bodies are unchanged from master; protected #28 applicability is reused and
no per-feature comparative campaign is needed. This records actual first-pair
delivery and reuse, not a measured overall delivery-speed improvement.
Independent final Spec/Standards review accepts this bounded AppA pair and its
complete portable joins. Full #61 and combined product qualification remain open.
Integrated `57c7cba80` passed CI38887245781. The unchanged full infrastructure
suite stayed in CI; source-handoff/backend evidence was reused for this commit.

The next AppA owner-handoff consumer also passed its first stock pair against
all 46,717 independently modeled bytes. One final Spec/Standards review joins
the actual component rollback/retry/publication/reader/query operations to complete
owner observations and retained evidence. Its protected #28 reuse follows the
current combined220 source/artifact bridge, including the already reviewed
unreached pending-length helper difference; no raw whole-source identity with
historical combined185 is claimed. No new runner, comparative campaign or replay
was needed. Delivery-speed improvement remains unmeasured.
Owned-handoff integration `637e87135` passed CI38888837157.

The concrete Product-field recovery gap is now implemented through the existing
canonical binding and inverse/journal path. Normal stock JS/Native match all
10,339 bytes on their first pair; only then were affected authority controls
and the compiling owner-loss variant prepared. Both variant backends match the
9,763-byte countermodel and reject normal. Source/model review corrected the
returned-record order before execution; actual returned payloads feed retries.
One final independent review joins normal/control/mutant evidence and existing
protected #28 applicability. No shared runner or comparative campaign changed;
no overall delivery-speed improvement is inferred.

Resource-field integration `88dcbb68e` passed CI38890020198. Independent source
census review also accepted the existing coverage document's counted routing:
687 library export-path keys, 67 bound keys and 35 test/static/helper files
(251 test cases, 40 suites, 133 rejection markers). The archive's 688th semantic
key is a test helper; it is not a new Bend requirement. Counts and classified
routes do not close unexecuted predicates, full #61 or product qualification.

The automatic Recovery-to-App/debug composition passed its first stock JS and
Native consumer pair against all 30,271 independent oracle bytes, using the
existing collector and unchanged caps. Affected authority, metadata mutation,
compatibility and final review remain; this is not integrated acceptance. The
checkpoint review reused the prior independent review of `218b5b548`/`fad6e9c5d`:
all five executable process files are unchanged, all eleven infrastructure suites
remain in CI, and correctness/#28/final performance criteria remain binding.
The CI38791374316 success note was already committed and is preserved. No unchanged
process tests or timing/scaling campaign were repeated. This records actual use
of the shorter path, not a measured delivery-speed improvement.

Automatic Recovery-to-App/debug now passes independent semantic review: the first
stock JS/Native pairs match complete 30,271-byte normal, 16,673-byte current classic
compatibility, 30,283-byte reached metadata defect and 5,447-byte opaque-refusal
oracles. Eight intended authority refusals and positive entries retain the actual
API boundary. Existing collector, caps, full #28 applicability and retained evidence
were reused; no comparative campaign or new runner was required. One formatting-only
canonical oracle-copy repair preserved all frozen bytes in the evidence and
reproduced the complete outputs without backend replay. Integrated `85cf9aa2c`;
CI38894048915 PASS. Full #61 remains open. This is a concrete semantic delivery under the shorter
checks policy, not a measured delivery-speed improvement.

The next ordinary Check-to-condition/App delivery passes independent semantic
review. All first stock JS/Native pairs match complete normal104,475,
interoperability48,757 and reached eager-RHS105,097-byte oracles; the normal
mutant baseline is rejected. The narrow actual TS reference matches38,458 bytes
and retains its eager-preflight difference. Three positive/ten intended authority
checks pass. Before backend freeze, API review found and repaired missing
interoperability with existing conditions; actual registered StateChanged and
unbound-system execution now qualify it. Existing collectors/caps and #28
applicability were reused. The TS adapter changed only its scope prose and
received the existing changed-portion launch review. No backend replay, new
runner, comparative campaign or extra tracking layer was required. Integrated
`bd1e2f67c`; CI38898093454 PASS. Full #61 remains open and delivery-speed
improvement is unmeasured.

The canonical component-query Check delivery used the existing collector and
unchanged caps: first stock JS/Native normal96,029, reached constrain-omission
98,819 (normal rejected), and current resource-compatibility104,475-byte pairs
all pass. Five positive/ten intended authority controls cover the new API; the
actual TS reference matches23,512 independently derived bytes. Complete
observation and API review preceded backend freeze, and the existing #28
applicability was checked against all23 unchanged protected bodies. The sole
TS adapter prose change received changed-portion launch review. No new runner,
comparative campaign or unchanged-process rerun was needed. Final review caught two arity failures
miscounted as write-through-read refusals; only those controls were corrected
and rerun, retaining the predecessor diagnostics and exact applicability of the
other thirteen checks. Independent final review passes; integrated `c524034d2`, CI38901764699 PASS.
This is actual use of the shorter path, not measured delivery-speed improvement.

The described machine/query/resource Check delivery again ran the complete
ordinary consumer before expanding controls: first stock normal119,419 bytes,
current query/resource compatibility96,029 and reached availability defect119,371
(normal rejected) match on both backends. The actual TS reference matches36,126
independent bytes; five positive/ten actual type-or-affine refusals pass. Existing
runners/caps and exact source reuse are retained. Several source checks initially
competed on CPU5 and hit the unchanged five-second cap; those attempts are retained
unqualified, and only the affected checks were recaptured serially without a
source or limit change. The TS adapter's scope-only change received the existing
launch review. Independent final review passes; integrated `88645bf21`, CI38906069050 PASS.
No new runner, comparative campaign
or measured delivery-speed improvement is claimed.

The machine delivery's pre-commit table guard rejected an overlong coordination
row. The row was shortened using existing API/review links, then committed with
the normal hook; no contract, evidence or assignment was removed. CI38906069050
passed. This is an observed guard effect, not a measured delivery-speed gain.

The described relation Check delivery reused the existing collectors, unchanged
limits and full machine/query/resource compatibility oracle. The complete ordinary
consumer ran before expanding to eight modes. The historical mode fixture needed
migration to the current stream representation; logical observations were retained
and complete physical queue observations added at entry and exit. Independent
oracles distinguish routing direction and preserve the different RequiredOut and
RequiredIn historical subjects. No new runner or comparative timing campaign was
introduced; no delivery-speed improvement has been measured.

Relation Check integrated `521b7dec5` with independent Spec/Standards PASS and
normal pre-commit PASS; CI38910846706 PASS. The unchanged protected23-source
closure permits exact combined220 reuse without another benchmark run.

For checked ordinary readers, the first full59,015-byte normal consumer passed
JS and Native before affected controls were expanded. Observer preparation ran
in a separate worktree while the owner completed the scenario. The new transport
is the only core addition, allowing unchanged prior API evidence to be reused
through exact closure checks rather than another compatibility backend cohort.
The TS evidence review retained its actual registered-reader discard behavior
and explicitly separated source-only never-activated behavior. No new runner,
limits or measured delivery-speed improvement is claimed. Normal59,015, reached
fold-tick59,039 (normal rejected) and attachment32,103-byte pairs all pass on
JS/Native, along with four positive/six intended transport refusals. Independent
Spec/Standards review passes; integrated `77beba95a` with normal pre-commit PASS,
CI38914934433 PASS.

### Selected constructed-resource delivery checkpoint

The #61 selected-resource consumer composes existing public APIs without a core bridge. Both normal JS/Native outputs match the complete 26,673-byte independent oracle; the reached admission-omission pair matches 26,453 bytes and rejects normal. An independently authored observer and oracle exposed and corrected an observation assumption before execution: the actual clock/cursor stay zero and pending count stays one. Current authority controls, exact unchanged-core reuse and separately scoped actual TS evidence avoid redundant compatibility/reference runs. Independent final review passes; integrated `0b025defe`, CI38919912200 PASS. No new runner, limits or approval stage was added. Delivery acceleration has not been measured.

### Two-application current-source checkpoint

The next #61 gap was current applicability, not a missing cross-feature operation. AppA reuses its complete owned-handoff observations after exact metadata-only reconciliation; AppB repairs unused renderer APIs and passes one current JS/Native pair against its full independent source-derived oracle. Historical mutation/authority controls retain explicit unchanged-boundary joins. No additional Cartesian scenarios, benchmark, runner or approval stage was introduced. Independent final review passes; integrated `0ee4562f4`, CI38921620111 PASS. Existing lossless inventory/group routes also reconcile every frozen key/case/marker without another fixture or tracking layer. No delivery-speed improvement is measured.


### Pending-spawn cancellation delivery checkpoint

The first complete ordinary consumer passed stock JS/Native before three
addressed controls were expanded: reached live-only admission, actual foreign
pending authority and both lifetime producers. Independent oracle authoring and
portable retention ran alongside implementation/review. Existing AppA/AppB
entrypoints were re-executed because World/commands changed their physical
observations; historical byte-identity reuse was not claimed. All six semantic
pairs pass through the existing collector and unchanged limits. One unchanged
combined #28 run passes on the four-file integration (123 commands/110 complete
outputs, no confirmed regression on either backend); no separate comparative
timing/scaling campaign or additional runner was added. The earlier successful
CI38791374316 note remains preserved. Delivery acceleration is not measured.

The normal staged-source check rejected two direct subprocess calls in the new
offline model self-check. The targeted repair evaluates the already pinned pure
models in-process; both complete reproductions and the staged-source check pass.
No ECS, frozen oracle, backend receipt or regression input changed, so those
executions were reused rather than repeated. This is a concrete local detector
effect, not a measured end-to-end delivery gain.

The reviewed four-core fix integrated at `f1fac4e90`; CI38929736000 passed.
English bounded reports were posted to #38/#61 without closing either issue.
The existing full infrastructure suite stayed in CI; local acceptance reused
the exact backend evidence after the offline-only verifier repair.


### Ten-hour reassessment and next-check expectations — 2026-10-16

Assessment window: approximately06:00–16:10 UTC; integration follow-up checked
at16:59 UTC. This section records outcomes and proposed next-delivery practices,
not new acceptance gates. Earlier expectations and observations remain historical.

**Confirmed successes.** #51/#52/#53 closed during the window. Ordinary consumers
preceded expanded controls; unchanged evidence was reused, and separate comparative
timing/scaling campaigns did not block semantic delivery. Local hooks retain
staged-source and affected checks while full infrastructure suites remain in CI.
Independent review caught reader-oracle errors before execution; guards caught
incomplete imports, table sprawl and prohibited subprocess calls. The pending
spawn fix subsequently integrated at `f1fac4e90`, CI38929736000 PASS, after six
complete semantic pairs and one unchanged #28 cohort. Its offline verifier repair
required no backend replay. These establish delivery and actual detector/reuse
effects, not a causal end-to-end speedup.

**Incomplete or unsuccessful outcomes.** Fixture/oracle mistakes still caused
avoidable rework (Column id-1 indexing, retention boundaries and physical state).
Two arity refusals were incorrectly credited as write-through-read controls until
review. Concurrent source checks on CPU5 timed out and needed serial recapture
without code or limit changes. Evidence packaging remains substantial: roughly
2,600 retained files for the four-core pending fix; file count alone does not
establish redundant coverage. The report now exceeds1,600 lines; the coordination
table measured27 rows/17,105 characters, about63% below its original45,700-character
baseline, rather than the earlier81% reduction. Status-only commits still generate
full CI runs. Automatic queue handoff and overall delivery acceleration are not
established by this window's evidence.

Rework should address these causes through existing tools and review, not another
runner, tracking layer or approval stage. At the next check, assess the next two
integrated deliveries; if a delivery stalls, record its actual blocker instead of
waiting for two completions.

| Area | Next-delivery expectation | Evidence to inspect at the next check |
| --- | --- | --- |
| Resource scheduling | Serialize source checks sharing one pinned CPU; parallelize authoring and checks only with genuinely separate resources. Keep existing caps and heavy-run locking. | Existing argv/receipts identify CPU assignments, contention timeouts and retries. Distinguish an external load change from self-contention. |
| Models and negative controls | Before freezing plans, reconcile operations, physical layout, ownership and complete observations with the independent model. Verify that each intended refusal reaches its stated type/access boundary. | Count model/fixture repairs before versus after freeze; name unrelated refusals and any avoided backend runs. First-attempt success is an observation, not a mandatory gate. |
| Evidence cost | Reuse qualified packets/helpers and maintain only the selected packet and used prerequisites. Before removing a live check, identify its surviving detector and callers. | Record new versus reused backend roles, packaging/review repairs and any safely removed duplicate. Explain necessary regeneration; do not target an arbitrary archive/file-count reduction. |
| Queue handoff | Use the existing batch path when jobs are already frozen and independent of predecessor outcomes; retain manual decisions where later jobs depend on results. | Name the actual batch receipt or necessary manual handoffs. Do not infer automation from serialized execution alone. |
| Documentation and CI | Fold status-only notes into the next suitable delivery commit where practical. Keep current coordination rows concise, with history behind links; retain full CI coverage. | Count standalone status-only commits/CI launches and remeasure current table size. Preserve useful history; keep the next assessment to one concise reconciliation here. |
| Delivery cost | Use existing receipt/Git/CI timestamps to distinguish backend execution, packaging, review and waiting where available. | Report observed intervals and missing timing information. Do not sum overlapping jobs or claim a speedup without a comparable baseline. |

Correctness, authority/ownership checks, independent final review, unchanged #28
and final JS <= TS / Native <=0.5*TS requirements remain binding. Remaining #38,
#54/#57/#59/#60 and full #61 contracts are not resolved by process improvements.


Reassessment implementation follow-up: `docs/agent-workflow.md` now explicitly
serializes source checks sharing a CPU across worktrees, calls for physical
index/retention/owner reconciliation before plan freeze, and folds routine
status-only notes into the next suitable delivery commit. `CODING_STANDARDS.md`
explicitly rejects arity/parse/missing-symbol failures as evidence of an access
or ownership boundary. These are working-instruction changes, not new gates or
new evidence that the next delivery has improved. Runner/compiler files, active
frozen inputs and CI coverage were not changed; next-delivery observations above
still determine their practical effect.


Concrete scheduling repair: `scripts/bend-check` now takes cross-worktree CPU
locks before starting the existing pinned compiler/timeout. Overlapping affinity
sets serialize; disjoint sets remain independent. Locks survive exec through
compiler completion, acquire in sorted order and release on process exit. An
unpinned invocation locks its full allowed set; external caller deadlines still
include queue wait. Synthetic controls cover waiting before compiler entry,
lock inheritance, disjoint execution, exit propagation and pinned alias selection.
No Bend compilation/benchmark was launched for this repair. Independent review
of the changed wrapper remains required before its first compiler launch under
the existing check policy; historical frozen packets are not rewritten.


User decision after the scheduling repair: waive the separate independent launch
review for this specific CPU-locking development-wrapper change. This supersedes
the pending-review requirement immediately above; it is not a general review or
acceptance waiver. Seven synthetic controls, source-policy and shell-syntax checks
pass. Continue ordinary ECS delivery and assess actual scheduling/retry, model,
packaging and status-commit outcomes at the next retrospective in approximately
eight hours. No deliberate idle period or demonstrated speedup is implied.

Generational delivery checkpoint (2026-10-17 UTC): #38 closed after
`6ad552b14` / `fe9a8f3c2`, independent joined review and CI38985163067 PASS
(functional job 2m13s). Exact ownership staging selected 10,204 delivery paths;
unrelated workspace edits stayed unstaged. Frozen semantic roles used the existing
collector and serialized heavy queue; the short six-role orchestration did not
use `delivery_batch.py`, so it establishes no adoption of that batch interface.
Seven authority refusals reached their intended boundaries, and current AppA,
AppB and snapshot successors retained complete prior observations. Source/model
review caught the AppA host-entry mismatch before backend execution. A profile
tool-guard CPU mismatch stopped before profiler children; a reviewed one-line
successor passed all four complete runs. CI exposed copied historical EOF bytes;
four exact-path attributes preserved frozen hashes and kept the ordinary-source
control rejecting the same defect. Neither repair needed a Bend/benchmark replay.
The unchanged #28 completed 123 commands and 110 full outputs. Packaging and CI
cost remain observable work; no comparable end-to-end baseline or overall delivery
speedup is established.

Restore delivery work (2026-10-17 UTC): the unchanged ordinary collector reached
its Native emission deadline for the combined two-schema fixture, including a
CPU11 placement retry. Independent translation-unit entries `867c005fd` preserve
all eleven checkpoints and complete owners in both schemas; their stock JS/Native
-O3 pairs pass independent 38,882/38,880-byte oracles under the same stage caps.
Garden's first deadline remains historical; its single fresh retry passes.
Portable packet `90457949b` reproduces both models and retains their original
parent dependency without relabeling executed plans. No runner or acceptance
criterion changed. Raw restore and remaining #59 gates are still open; this is
a resolved compilation blocker, not a measured delivery-speed or ECS speedup.


Trace delivery checkpoint (2026-10-17 UTC): #57 reused complete qualified
consumers through explicit current-source applicability maps, with a fresh
merged-query JS/Native pair for each schema and an affected restore pair.
The same independent final review covers implementation and retained evidence.
The enabled/disabled measurement completed 98 commands; portable verification
retains full outputs, separate CPU/heap profiles and recomputed summaries.
The unchanged combined #28 completed 123 commands and 40 pairs with no nonzero
exit or statistically confirmed regression; all 339 monitored source identities
still match. Ownership staging, master hooks and CI remain pending. These facts
show actual evidence reuse and combined gating, not an established reduction in
end-to-end delivery time. No runner or acceptance limit changed for this batch.


Trace delivery completed: `e9096051b` passed actual master hooks and
CI39003777004 (functional job 117 seconds); #57 closed with its English evidence
report. Explicit ownership staging preserved unrelated edits. The staging helper's
five-second `git add` budget expired before updating the index; after confirming
the child was terminal and removing its stale empty lock, direct Git with the
same exact NUL-delimited path list succeeded. One generated ignored Python cache
was excluded from the live source inventory, while immutable archived evidence
remained intact. No runner, compiler limit or acceptance criterion changed.


Current Inspector follow-up: the full current-source JS consumer passes its
6,731,751-byte independent oracle. Stock and plain graph/lookup candidate Native
emission first reached the unchanged deadline; instrumented candidate emission
then completed and retained the full C artifact. This is emission evidence only.
A fresh plain attempt was coordinator-aborted because its declared launcher
still named the earlier plan: a shell continued after a failed binding assertion.
The owned process group was stopped and no child remained; that attempt is not
a compiler verdict. Review and launch are now separate calls. No runner change,
new approval stage or cap increase was added for this orchestration error.

Combined #54/#60 checkpoint: the unchanged default #28 gate passed (123 zero-exit commands, 110 complete outputs, 40 pairs). A separately reviewed same-current-source stock/selected compiler comparison also passed (115 zero-exit commands, 110 complete outputs, 40 pairs). Both report `NO_CONFIRMED_REGRESSION`; neither establishes full-parity performance. Exact protected-source affinity allowed reuse of the prior stock artifacts, avoiding another compilation. Post-run source/resource/artifact guards passed. Independent final reviews retain both results; master delivery and CI remain pending. No end-to-end delivery acceleration is claimed.

The combined semantic delivery is committed/pushed as `81316652e`; configured master hooks and CI39010187646 passed. #54/#60 are closed with English acceptance reports. The batch reused source-qualified stock artifacts and previous unchanged consumers, while retaining complete new consumer and regression results. Live Python caches were excluded from ownership staging; immutable evidence stayed intact. This demonstrates actual batching and reuse, without an end-to-end delivery-speed claim.

Final #61 affinity review found a concrete acceptance risk: the older independent AppA/AppB observers consume callback lists, while current World pending entries are Deferred.Command owners. The census alone does not qualify those applications on current source. The existing #61 owner is preparing narrow consumer successors and independent full oracles before JS/Native execution; no new matrix or runner is introduced.

The #64 plan and final #54/#60 review assurances were batched in `a969f8c00`; actual hooks and CI39010684455 passed. The plan-only delivery needed no compiler or benchmark rerun. Canonical jev was read only; source-current #61 consumer qualification continues separately.

The #61 carrier gap is resolved by additive ordinary consumers: AppA/AppB pass all four stock JS/Native roles and complete independent 48,145/14,577-byte observations, with all ten commands successful. No ECS core or runner changed. Independent review verified both portable packages and the final matrix; unchanged source-bound #28 and authority/mutation evidence are reused under their exact scopes. Integration hooks/CI remain pending.

The final #61 batch `74a44d552` passed actual hooks, push and CI39011485053, then closed with an English report. The unrelated core-map archive-link edit remained unstaged. Parent #37 was synchronized with its already approved tracked reference order and combined-performance scheduling amendment. The #62 proposal falsification then used the same collector: normal stock JS/Native and four JS mutants, all thirteen commands successful; no core, runner, cap, law approval or numeric criterion changed.

The #62 draft package `291704538` passed actual hooks, push and CI39012265766. Exact four-law approval was requested after source review and executed falsification; proof sketches are included in the existing issue report. The four subjects remain unapproved while the independent numeric-workload adoption continues; no proof or new measurement loop has begun.

Canonical numeric-workload adoption first executed complete ordinary Dense64 consumers on both stock backends before extending qualification. Motion/Health match independent 89,017/88,773-byte observations; all ten commands succeed with unchanged collector limits. One heavy owner serialized all four roles. Portable retention and final review follow; no timing or delivery-speed claim.

Dense64 correctness delivery `d33affb91` passed actual hooks, push and CI39013375873, with an English #21 report. It reused unchanged protected-workload evidence instead of another benchmark. Runtime-fed Dense source preparation continues in the same direction; no full numeric or overall delivery-speed acceptance is claimed.

The runtime-input Dense consumer passed both schemas/backends at64 and256;256 reused the same generated JS/Native artifacts through existing consumer-only plans. At1024 both Native outputs match complete independent oracles, while both JS processes exit1 with a machine-stack fault and zero stdout. All twelve receipts remain distinct; no deadline increase or oracle reduction is justified. Source diagnosis replaces repeated unchanged runs, and final delivery remains pending.

Runtime1024 premise check: making lifecycle clear/get stack-safe was not sufficient to remove the JS failure. Two source-preserving diagnostic copies exposed clear then get; the combined candidate still faults, so its next stack and the complete remaining recursion chain must be inspected before another core change. These candidates remain unaccepted, with original failures and exact oracles preserved.

The later row-parent diagnostic exposed six retained query-continuation frames per row (38 at row1, 416 at row64); this justified replacing the traversal chain rather than another isolated leaf repair. The coherent two-file tail candidate now passes all twelve runtime-fed Dense roles through1024 and the two raw-loop controls (23 commands), with complete independent observations. Failed attempts remain distinct. Combined #28 completed with123 successful commands/40 pairs and NO_CONFIRMED_REGRESSION; source/tool post-guards match. Existing trace/reader evidence applies with explicit scope; final Spec/Standards review18d90cb94 passes. Integration hooks/CI are pending. This establishes correctness at those sizes, not speedup or an overall delivery-time effect.

Runtime Dense delivery `cc951d346` passed actual hooks, push and CI39017290965 (functional2m2s). Exactly914 owned files were staged; foreign workspace edits stayed out. The combined #28 decision and full fourteen-role correctness packet were reused at integration, without rerunning unchanged backend work for the commit. Sparse canonical-consumer preparation continues; no overall delivery-speed improvement is inferred.

Sparse adoption completed both64 consumer pairs before extending to256/1024. All12 roles/18 commands pass complete source-derived oracles; four emits/two Native builds produced the exact artifacts reused by eight later consumer-only roles. The existing collector and guard/producer bindings handled the larger runtime arguments without runner changes. All351 protected source bodies match the qualified #28 gate; final Spec/Standards reviewa42acebcd passes. Integration hooks/CI remain; no timing or overall delivery-speed result follows.

Sparse delivery `5957a1b08` passed actual hooks, push and CI39018233334. Exactly701 owned files were staged; unrelated root changes remained untouched. The earlier Dense CI note was folded into this delivery. No new compiler/benchmark execution was needed for the documentation or exact protected-source reuse. Lifecycle consumer work now uses the accepted once-system registration seam rather than a copied dispatcher.

Lifecycle first Motion64 consumer passed stock JS and Native against the complete14,774,371-byte model after its ordinary Local/scheduler source checks. A prematurely bound plan was rejected before helper import when only the oracle whitespace metadata changed; zero child commands ran, and both original plans remain separately classified. The successor binds the final metadata and succeeds without source/model/output changes. This guard refusal is not an ECS backend failure or an additional approval stage. Health preparation used an isolated worktree so its additive files could not drift the Motion producer bindings.

Lifecycle Health64 also passed the unchanged collector on stock JS/Native: five commands succeeded, empty runtime stderr, both complete14,844,490-byte outputs match the independent pre-execution oracle (SHA256 `dce258d9da2f9168fa21c41f50ac8c148715be004bbecda79750b75ad23e0f66`). The larger-input matrix will reuse those actual producers without recompilation; no comparative timing result follows.

Lifecycle Motion256 reused the exact qualified64 producers: JS passed the complete58,307,231-byte oracle; Native hit the unchanged five-second consumer limit before stdout (`actual01`, retained INCOMPLETE receipt). Source inspection identifies repeated full linked-String copies and whole-report native IO materialization; this is a concrete hypothesis, not measured dominance. The existing owner is preparing a consumer-only successor that writes the identical full report in chunks after the same ECS operations, using existing IO.write. No deadline, observation, ECS contract or expected output changes. Health256 plans remain unexecuted.

The first chunked Motion successor (`ecac5c911`) passed source/wire applicability review but its first JS64 consumer failed with the runtime's generic machine-stack overflow diagnostic (exit1, zero stdout); emission succeeded and Native remains unexecuted. This is a preserved failed candidate, not a successful fix. The owner is tracing the hidden RangeError before another repair; the complete oracle and stage limits remain unchanged.

A reviewed reporting-only JS copy exposed the precise chunked-render failure: repeated `$List$append$` frames at generated lines1304/1310. The existing collector diagnostic passed its expected exit1/RangeError control under CPU11/five seconds (`COMPLETE_SOURCE_CONTROL_PASS`), which is diagnostic evidence only. The owner is replacing this newly introduced recursive chunk-list concatenation with a stack-safe same-order operation; no additional scenario or ECS change is needed.

Stack-safe chunk concatenation successor `a033ff62d` passed complete Motion64 and Motion256 on both backends, including all58,307,231 bytes for256 within the unchanged cap. This resolves the original Native256 deadline without reducing observations. Motion1024 Native still times out at five seconds before stdout; JS1024 is unexecuted. The owner is preparing a narrow actual profile/stack diagnostic before another repair. Health same-repair successor `23aa56107` is sealed and its first JS64 run is in progress. No comparative timing result or full-family acceptance is claimed.

Health chunk-tail also passed both complete64/256 backend pairs (14,844,490 and58,475,231 bytes). Motion1024 JS shares the Native five-second deadline before stdout, so the remaining blocker is not established as Native-specific. The current exact-binary PC diagnostic reuses the existing #43 sampler; root will execute only after focused binding review. No Health1024 run or acceptance is claimed.

The first exact-binary Lifecycle profile retained3,997 valid PCs (no setup error/zero samples/overflow), with2,768 samples in String.append/its continuation and778 in rfc_wrap. It samples the early window, not caller stacks or complete-run wall time. Same-boundary captured World/store chunks (`9be3f7989`) preserve full wire and pass64 on both backends, but Native1024 still reaches5s before stdout. The same sampler on this exact successor retained3,971 valid PCs, including2,654 String.append/continuation and807 rfc_wrap samples; it again timed out at5s before stdout. This confirms the early-window string-cost premise but establishes no speed ratio or unique caller. Source inspection locates repeated tree-substring concatenation in the remaining local observer path; the owner is preparing a linear-construction consumer successor before another acceptance attempt.

The tree-chunk successor `cb8309239` passed64 on both backends but1024 still timed out before stdout. The unchanged sampler's next packet retained3,864 valid PCs:687 String.append/continuation,1,430 rfc_wrap,686 in generated chunk-list reverse/append helpers and324 heap_alloc_miss. These early-window counts are not speed ratios. They show a changed cost distribution: repeated character copies were replaced by chunk-link/refcount work. The next consumer-only design uses persistent Data text nodes with constant-time concatenation and an explicit-stack writer, retaining the complete wire and original capture points.

Rope successor `8679d706f` also passed64 on both backends but1024 still timed out before stdout. Its same-protocol diagnostic retained3,990 valid PCs, including1,249 String.append/continuation,808 rfc_wrap and667 heap_alloc_miss samples. Static source and generated C show four allocated rope objects per physical leaf and ten per binary node; this is not a unique dynamic-caller attribution. The next local representation fuses physical tree nodes, preserving complete wire/capture timing and testing the concrete allocation multiplication. No general speedup or1024 acceptance is claimed.

Fused physical tree nodes (`be8cb22f9`) passed64 on both backends but Native1024 still timed out before stdout. Ordered phase diagnostic `b5db55d2e` reached all four markers and emitted13,537,166 exact old-report prefix bytes before the same5s deadline (plus114 marker bytes). It remains INCOMPLETE, not full-oracle acceptance. Generated C optimizes the Prepared carrier away; markers do not prove recursively captured fields were fully forced. This exposes host forcing/lifetime differences and motivates streaming real report segments at natural phase boundaries rather than additional representation changes or empty-IO barriers.

Meaningful streamed host `77085463f` passed64 on both backends and emitted23,318,528 matching old-oracle prefix bytes before the1024 Native timeout; still incomplete. Timestamp diagnostic `263d42135` records109ms to the bootstrap marker,4ms across prefix write,2,227ms between loop markers and2,268ms to the pre-writer marker, then times out with18,644,403 stdout bytes. These are instrumented combined gaps, not deep-forcing or performance qualification. A source-bound LC1 typed lossless wire is now proposed to remove verbose representation overhead while retaining every observed field, shape, order and repeated record. Its independently derived expected/actual outputs must strictly decode to all old oracle bytes; unchanged limits and collector equality remain. FirstMotion64 precedes wider work.

LC1 independent typed-model controls reconstruct all14,774,371 Motion64 old-oracle bytes (SHA256 cad24d935375352a1741d354c5ca4181a17141ae6054a80005c0f861d90993e9) after encoding and strict decoding; omitted calls and changed physical stamps fail whole-output comparison. Root separately ran six primitive control groups and the unchanged-observation typed-capture selftest, both passing. This is offline oracle evidence; the LC1 subject JS/Native pair remains unexecuted pending final consumer source freeze.

LC1 firstMotion64 source293a083e6 and independent model8c87db821 passed the unchanged collector on stock JS and Native in `/tmp/bendvy21-canonical-lifecycle-lc1-motion64-actual01`: five commands exit0, both complete7,297,970-byte outputs SHA256 d344134b5a4973d1b2bb199242e3d900c6e3dd68d76a18e2e336e15d0fc44a88, empty runtime stderr. Root separately strict-decoded both actual outputs to all14,774,371 immutable old bytes without differences. Wider sizes and Health remain pending; this is finite correctness/deadline evidence, not a speed measurement.

LC1 Motion1024 first reuse pair remains INCOMPLETE: both children hit the unchanged5s deadline with empty stderr; JS259,978 and Native258,048 bytes are exact compact-oracle prefixes. Root parsed the independent field boundaries: registered state ends at259,977, so JS reached the real final-state `T` write in `loops_done` before timing out during deferred state/encoding work. This locates an IO continuation, not deeply forced loop completion. The full105,713,138-byte compact oracle strictly expands to all235,001,897 old bytes; no actual1024 acceptance or speedup follows. Author investigates the concrete final-state forcing/encoder path before another successor.

LC1 Health64 source d8c5298f6/model742558ce3 also passes both stock backends: allfive commands exit0, full7,504,674-byte oracle equality (SHA256 3fb1cc9df9a978c26010e3368fce7bb84ef38cd9a7567f7296d3ad43f9cfc2d6), empty runtime stderr. Root strict-decoded both actual outputs to all14,844,490 old bytes. Final-state sequential-record IO repair is in progress for the concrete Motion1024 whole-Rope assembly blocker; no wide acceptance claimed.

Sequential actual-record writer7ba46b081 passed firstMotion64 on JS/Native (allfive commands exit0, same fullLC1oracle, both actual strict old-byte expansions PASS). At1024 both still hit5s: Native35,749,888 and JS13,128,129 exact compact-oracle prefix bytes, empty stderr. Entire final-Rope assembly was removed, allowing real final-body progress, but this does not establish a speed ratio or complete qualification. Reuse the existing source-current native PC sampler before further representation changes; retain every attempt unchanged.

Current7ba Native PC diagnostic v5-current-oracle (plan a0655ae98c4af6563be8c74c7ad9f0e751a33b4d2918e2352fedbd47bc3e2b05) retains3,941 valid early-window samples, no setup/overflow/zero/hole errors; consumer remains timeout/INCOMPLETE. Nearest symbols include rfc_wrap898, Rope.write_go519, term_drop318, Rope.join wrapper247, io_cbuf232, String.append/continuation449 and String.concat98. Counts are not elapsed-time ratios or caller stacks. Source inspection confirms64 tiny-text-token flushes and no pinned stdout byte-buffer effect. Next isolated repair changes only writer accumulation to a bounded reversed-character buffer; all encoder fields, record streaming, work validation, outputs and limits remain.

Bounded4096-Char writer d378e80b2 passes firstMotion64 on JS/Native and both strict old-wire expansions, but1024 remains INCOMPLETE under5s: Native27,459,584 and JS11,098,335 exact-prefix bytes, stderr0. These failed partial runs do not establish comparative speed or justify adoption. Before another writer patch, test the shared premise that this105,713,138-byte String report can fit the gate: a focused output-only control will separate fixed-data Bend IO cost from ECS/typed encoding. Same stock backends/collector/limits, no ECS acceptance or general lower-bound claim.

Output-only control91ba8d6be/model32d135f3d passes both stock backends via the unchanged collector: five commands exit0, all105,713,138 bytes match independent SHA256 911e898a4341ad1334b3797683ac2e15289ea4105e0d73cefdfcb6b95a4f7ce0, runtime stderr empty. This concrete fixed-data path disproves an absolute volume-only prohibition in this setup; it is neither a strict lower bound nor ECS/performance qualification. Before another product patch, isolate the existing encoder's per-token Rope forest/traversal from strict demand of all actual encoded characters using a bounded count/rolling-hash diagnostic, keeping the ECS/capture/numeric-string path explicit.

Strict-character Stats diagnostic a0a3ab4c4/modelbc916a428 uses the same293a ECS/capture/encoder with a bounded polynomial monoid replacing only private Rope. Native1024 passes allthree commands and exact109-byte independent two-summary oracle SHA256 e76537f6e2434496d97fd558c6486c8e470faa58962d814ecb36c97de927410e. JS emits the correct54-byte firstsummary+rawT then hits5s; both stderr empty. Native supports feasibility of this different demand path without report forest/largeIO; JS remains unresolved and hashing itself adds work. Fingerprint collisions prevent treating this as full-observation acceptance. Next collect source-current JS CPU evidence before a direct encoder rewrite; preserve product gates and fullwire oracle.

Existing timeout-safe V8 --prof path collected both currentJS diagnostics (plans292658f82, unchanged artifacts/cap5); both consumers remain INCOMPLETE, logs retained. Offline processors exit0: Char3,785 ticks/no unaccounted, GC category1,172; Stats4,146/no unaccounted, GC774. Source maps identify writer/codec cat/u, String.reverse and ordinary declaration assembly; category counts are not additive speed ratios or full-run attribution. Complete logs, analyses and hash joins are retained in both `/tmp/bendvy21-lifecycle-{char,stats}-v8-prof-diagnostic01` directories. Next isolated candidate threads a bounded per-record buffer directly through the existing typed encoder, removing Text/Join construction while preserving LC1 bytes/captures/owners. Read-only audit examines repeated query declaration assembly; no core change authorized by this observation alone.

Direct per-record Buffer source6d879104b passes firstMotion64 JS/Native (five commands exit0, full7,297,970-byte LC1 equality and both strict old-wire expansions). Its same64 producer at1024 now passes Native: complete105,713,138-byte oracle SHA256 569e19981c8f22e65f3ea4f2867cc3d1fc949bff57c872c6e874952048963163, stderr0, unchanged5s cap. Root strict-decodes the actual output to all235,001,897 immutable old bytes without differences. JS still reaches5s with22,801,245 exact-prefix bytes/stderr0. First full Native1024 acceptance is finite correctness/deadline evidence, not a comparative speedup. Profile current DirectBuffer JS before further changes; all prior source stages remain immutable.

Current DirectBuffer V8 diagnostic9797131b (plan1a9e0042...) remains timeout/INCOMPLETE; offline processing succeeds with3,941 ticks/no unaccounted. Samples now identify String.reverse.go134, directencoder.u121, ordinarypair120, U32.show80, optional80+63, tree51 and text37; GC category1,046. The removed Rope walker/cat no longer heads this source profile. Next investigate the pinned String.concat lowering for a bounded actual-string-piece buffer, avoiding manual per-character reversed String work while keeping exact LC1 bytes and per-record streaming. Counts describe this partial diagnostic window, not a speedup or whole-run bottleneck proof.

Read-only query allocation audit traces per-entity `inspection(Logical.declaration())` rebuilding to `inspector-query.bend` composed_scan, `ordinary-query-observable.bend` inspection/pair and `inspector-query-projection.bend` pair closures. Generated JS constructs unused operational Declaration records while accessing inspection. Bend callbacks/declaration bundles are affine Type even when captures are Data: neither a source let nor runtime sharing establishes a safe cache. Data names/clauses/identity metadata may be separated; generic callback lowering needs an explicit quantity-checked design and generated-callsite evidence. No core edits, new contract or extra ticket follows from these samples; this remains a candidate under existing #21.

Two-level piece buffer f07a92c3 passes firstMotion64 both backends and strict old-wire expansion, but1024 is INCOMPLETE on both: JS24,590,967 and Native61,063,168 exact-prefix bytes, stderr0. Do not adopt it over6d879's complete Native pass. Further buffer tuning stops. The next isolated representation repair targets repeated decimal scalar formatting observed in current V8: a canonical printable-ASCII varint LC2 fixture wire with unchanged typed fields/shapes/order/duplicates, independent expected bytes and strict recovery of every LC1/old-verbose byte. This is not a public ECS contract, observation reduction or new numerical criterion; source/model feasibility review precedes implementation and first64 pair precedes larger preparation.

LC2 source119deff59/modelefaad4620 passes firstMotion64 both stock backends: allfive commands exit0, complete3,848,488-byte independent oracle SHA256 ff435edc418dbded9b6e76106da002fbe1058f919879f065fb6281c4f58cca05, stderr0. Root strict-decodes BOTH actual outputs to all7,297,970 LC1 bytes and14,774,371 verbose bytes without differences. This confirms finite lossless source execution, not a comparative speedup. Independent1024 expected output is prepared from sealed LC1 expected data; no ECS model regeneration or large subject launch before this pair.

LC2 Motion1024 source119deff59/model4600233ad runs through unchanged consumer-only reuse plans in `/tmp/bendvy21-canonical-lifecycle-lc2-motion1024-actual01`: Native passes all57,594,965 independent bytes; JS hits5s after23,043,415 exact-prefix bytes, both stderr0. The smaller lossless representation alone does not clear the JS deadline. Root checks complete Native expansion; next use the existing source-current V8 profiling path before another repair. No comparative speed or full Lifecycle acceptance claimed.

Root strict-decodes LC2 Motion1024 Native actual bytes to the entire105,713,138-byte LC1 and235,001,897-byte verbose expected streams, exact PASS (decoder exit0). Native finite correctness/deadline gate is met for this source/size; JS remains incomplete and no full matrix or comparative performance claim follows.

Reviewed LC2 V8 plan4500d026 executes unchanged JS under the existing diagnostic path; timeout receipt remains INCOMPLETE with10,763,807 stdout bytes/stderr0. Offline processor exits0:3,737 ticks, none unaccounted. Highest named JS entries include ordinary declaration pair134 and optional115+79; varint continuation73/u32_go54 and String.reverse60; Buffer.text6. GC category1,107 overlaps execution categories and is not additive wall time. Analysis SHA25656d9da6a22c928da8fd0e53832ee5553128d8193dff20d248f215cab6b71d010. Investigate repeated declaration construction with quantity-checked inspection lowering; no callback/World cache, core patch or speedup claim established yet.

Source/generated audit identifies eager unused operational lowering in Observable.pair before inspection discards it. The isolated repair candidate keeps Declaration affine Type and the existing eager constructor, adds private deferred lowering representation, and invokes only the selected Unit thunk. This changes allocation timing of pure declaration construction, not World reads; callbacks remain one-shot and all current validation/projection order remains required. One historical raw-constructor mutant explains preserving its source shape. Quantity checks and generated-callsite evidence precede subject qualification; no speed benefit established.

Deferred lowering source6a037dbb/freeze252bee7c with applicabilitydd7a6bbe0 passes Motion64 JS/Native: allfive commands0/full3,848,488 LC2 bytes and both actual strict LC1/verbose expansions PASS. Generated JS pair6319–6325 stores N.pair only inside operational run_clo; inspection6122–6129 invokes its selected thunk. Inspection declaration rebuilding per target remains. Larger source-current reuse follows; core is isolated, not integrated, and regression applicability/gates remain.

Deferred Motion1024 actual `/tmp/bendvy21-canonical-lifecycle-deferred-query-motion1024-actual01`: Native full57,594,965-byte oracle PASS; JS deadline5s after21,701,728 exact-prefix bytes/stderr0. Native output is byte-identical to the previously strict-expanded LC2 actual, so whole old-wire applicability is reused without another decoder run. The lazy-unused-arm repair alone does not clear the gate and is not integrated/adopted. Investigate whether pinned Bend can pass static selection workers without reifying per-entity declaration graphs; source evidence, not another buffer variant/profile sweep, governs next action.

Pinned2.0.35 bounded static-field feasibility rejects runtime use of erased function fields (`expected -run / observed run`); constructor `~` fields are unsupported by pinned parser. A direct erased-record destructuring probe also fails inference, so no static-record hoisting is claimed. Next bounded probe tests a closed callback expression forwarded to an erased worker parameter and inspects emitted code; this is not permission to erase affine callbacks or change the public ECS contract.

Root emits the quantity-checked worker-forward probe with unchanged pinned compiler/CPU11/30s path (exit0). Generated JS170–182 still calls field(declaration()) and constructs Ops+run_clo inside apply_worker; forwarding a closed getter as an erased parameter does not remove runtime reification. Do not implement that wrapper as an optimization. Next inspect concrete discarded construction or fused selection lowering while retaining public signatures, calls, ownership and order.

Further generated inspection shows P.pair already eta-expands its child getters inside chosen callbacks; another lazy wrapper would add closures rather than remove the claimed eager child graph. Lifecycle live Main targets mostly match (optional Aux/Flag accepts), so moving unused projection construction behind False is not a material-path repair. No such patch is made. Since the5s V8 log covers only10.7MB of57.6MB, one unchanged-artifact diagnostic with15s cap is prepared/reviewed to cover later formatter work; required consumer acceptance remains5s and no timing comparison follows.

Longer LC2 diagnostic7237c1fd/plan0b27cbe9 COMPLETES with exact57,594,965-byte oracle and stderr0; acceptance5s remains unmet. Offline V8 processor0:6,650 ticks,0unaccounted; full-run named JS samples u32_go303, varint continuations281+92, String.reverse283, BufferCodec.u148 versus querypair130/optional83+63. GC1,531 overlaps other categories. Analysis SHA2562ebe5bccb8a547bdfbff453cc03eb1170971a1b0022d26476dd184ff72435911. This reverses the early-window priority: stop core-query redesign; next isolated private U32 codec removes bounded-group Natfuel/continuations/reversal while retaining exactLC2 bytes and all ECS observations. No speed ratio or5s acceptance inferred from the diagnostic.

Bounded U32 source1f32d239/freeze6c7366d3/applicability3361c5391 passes firstMotion64 both stock backends in `/tmp/bendvy21-canonical-lifecycle-u32-bounded-motion64-actual01`: allfive commands0/full3,848,488-byte LC2 equality/stderr0. GeneratedJS U32path uses static bounded helpers and bitwise masks/shifts, removing Natfuel/continuations/reversal; Nat implementation is unchanged. Exact matching bytes reuse prior full LC1/verbose expansions. Separate actual-source scalar boundary controls and1024same-artifact gate remain; no speedup claim.

Bounded U32 Motion1024 actual `/tmp/bendvy21-canonical-lifecycle-u32-bounded-motion1024-actual01`: Native whole57,594,965-byte oracle PASS; JS5s deadline after31,837,656 exact-prefix bytes/stderr0. This is incomplete, not a speed ratio or gate success. Buffer.text generatedJS3031–3051 uses plain Number remaining/decrement, so a BigInt-counter hypothesis is contradicted by actual output. Qualify separate scalar boundary IO controls and obtain one current full-source V8 diagnostic before further private writer work; no core query redesign adopted.

Actual separate15-boundary U32 consumer `/tmp/bendvy21-u32-primitive-actual01` passes JS/Native (allfivecommands0,72exact independently literal bytes,stderr0), including every5bit length transition andMAX. Current1f32 full15s diagnostic5c2186eb/plan8aae1679 also completes whole57,594,965-byte oracle; processor0,5,421ticks0unaccounted. U32go35 replaces prior303+continuations; named reverse217/go74, BufferCodec.u146/tree158/text82, querypair128/optional95+84, GC1,281overlap. Profilecounts are not paired speed measurements. Analysis SHA25684c9274e90834a31ec7340fd43409608268c77c6ceaa8ec07d9d1a4c49273e59. Pinned Base/generated String.reverse directly calls its reverse.go without a length pass, rejecting a known-length shortcut premise. Next private source candidate writes bounded U32 groups directly into the unchanged4096-Char buffer, avoiding intermediate scalar Strings/charAt/slice. Core API untouched;5sJS gate remains open.

Direct Buffer U32 source409312b0/freezeeeb04efb/applicability340ad46f passes firstMotion64 JS/Native in `/tmp/bendvy21-canonical-lifecycle-buffer-u32-motion64-actual01` (allfivecommands0/full3,848,488 bytes/stderr0). GeneratedJS scalar branch4124–4128 directly calls B.char then bounded quotient helper; no intermediate Var.u32String/B.text split. Separate actual-source `/tmp/bendvy21-buffer-u32-primitive-actual01` also passes bothbackends/allfivecommands0/full8,279 independent bytes (15U32 transitions/MAX plus4095/4096-prefix flushcrossings). Next1024gate remains; no speedup or completed matrix claimed.

Direct Buffer U32 Motion1024 `/tmp/bendvy21-canonical-lifecycle-buffer-u32-motion1024-actual01`: Native complete57,594,965-byte oracle PASS; JS5s deadline after43,950,861 exact-prefix bytes/stderr0. No partial-output ratio is reported as speedup. Next private feasibility replaces per-character reversed Strings plus final reverse with affine Array<U32> scratch storage at the same4096-Char boundary and oneStringconstruction perchunk, preserving allChars, actualcapture fields/copies, IOorder and publicECS. Quantity/Arrayownership/Charroundtrip review precedes backend/sourcefreeze. Previouscandidates andallreceipts remainimmutable.

Array scratch sourcec790b0e9/freeze4c4f4052/applicabilityc1a1a3c93 passes Motion64 JS/Native, allfivecommands0/full3,848,488 bytes. Actualseparate8288control also passesbothbackends/allfivecommands0, coveringused0emptywrite,15U32boundaries/MAX,4095/4096flushcrossings andfiniteAα😀Z. Root+independentread-onlygeneratedinspection confirmsJS Numbers/Nativeu32 copiedinto completedStrings beforeArrayoverwrite/drop; Native spin543/544→542 completesbefore541→545 writesindex0. Motion1024binding019149369 then passes BOTH backends underoriginal5s cap withcomplete57,594,965-byte oracle SHA24c5b13acdd5ffd6cfa9181bb99f8c160b4899fba1f52a88183d2b5aba50966a/stderr0. Equalbytesreuse prior strict105,713,138LC1/235,001,897verbose expansions. Stopoptimization; finishMotion256andHealthmatrix, retainpacket/finalreview/integrate. This establishesfinitecorrectness/deadline,notcomparativeperformance/fullparentcompletion.

Array Motion256 binding2ac7d7e1d passesbothstockbackends in `/tmp/bendvy21-canonical-lifecycle-array-buffer-motion256-actual01`: complete14,372,070-byte LC2oracle SHA8189f8014728da73657aea2ed95e56b5c80f30edc8cc2c34561b9ee2a145c62d, consumerexit0/stderr0 underoriginal5s. MissingLC1256 intermediate was derivedONCE withunchangedindependentreport(256,64), notclaimedpreexistingreuse; strict26,474,201LC1→58,307,231oldverbose andLC2→botholdstreamsPASS. Motion64/256/1024 matrix nowcomplete forselectedc790source; Healthfirst64pending. No comparativeperformanceclaim.

Health sourcea7ad536c/freezef785bb02 with independent76b02323d LC2oracle passes first64 bothstockbackends in `/tmp/bendvy21-canonical-lifecycle-array-buffer-health64-actual01`: allfivecommands0/full3,904,540 bytes SHAc30881d63a508601b736a6fa5973237ed6ec1afd800c9da265ad8c8aa8e7a851/stderr0. TypedLC2 expansion matchesentire7,504,674LC1and14,844,490verbosebytes; Health-specific Vitalsreserve/class/Armorgradecontrols pass. HistoricalHost01diagnostic restoredactualHealthforeignVitals9/class2 beforefreeze. ProceedHealth256/1024 viaone-time missingindependentLC1derivationsandstrictoldwirechecks; no fullmatrix/numericclaimyet.

Health256 independent972e34aa3 passes JS/Native in `/tmp/bendvy21-canonical-lifecycle-array-buffer-health256-actual01`: full14,649,881-byte LC2oracle SHA159f4cf175f2b605200a7ab26df21051c27ae76d766ee10b98cde58b46fb3b29/stderr0 underoriginal5s. Missing27,493,722-byte LC1 intermediate was derivedonceunchangedmodel andstrictlymatchedall58,475,231 oldverbosebytes beforeLC2transcode/strictboth. SelectedLifecyclematrix now10of12PASS; Health1024 independentpreparationlive, no repeatedgeneration or numericclaim. Rootpreintegrationaffinity finds61existingBendbodiesidenticaltocurrentmaster+14new perselectedschema, zeroexistingbodydifferences.

Health1024 independent87d90c9c2 strictly expands all109,985,140LC1 and235,557,738verbose bytes. Actual01 Native passes full58,759,817-byte oracle SHAb29e11da6067af6c3433e7c6679b0ba9d57dc3ff828c03b8c01ece333d109ec0 under5s/stderr0. JS actual01 hits unchanged5s deadline after58,285,303 exact-prefix bytes/stderr0; final matrix is11/12PASS, not complete. Preserve this failed attempt; retention remains held. Author investigates only a source-backed private writer repair, no public/core contract or acceptance-limit changes.

Single-counter private writer691ee245 (Motioncompanionec7dd528) passes Health64 stockJS/Native complete3,904,540bytes; Health1024JS actual01 again hits5s after19,231,640 exact-prefix bytes/stderr0. Notadopted; no furthermatrix launches. Generatedread-onlycomparison shows newper-characterfive-argument code_at helper while oldbranchinline; materialize/scalar/text/write functions byte-identical, no measuredattribution yet. ExistingfullV8profiles predate Arraywriter, so preparecurrenta7adHealth full15sdiagnostic throughsame reviewedpath, acceptance5s unchanged. Retentionheld; currentchosenpredecessormatrix11/12, no comparativeclaim.

Currenta7adHealthArray fullV8diagnostic d00bdcef independentlyreviewed337pins/75imports/349resources, actual15scap source-controlPASS androotfull58,759,817expected equality/stderr0. Profile4442ticks/0unaccounted: materialize_go214,codec_u123,text115,querypair111,code7;GC1049overlap,notcausalelapsedshares. Analysis/plan/receipt/raw/log retained in `/tmp/bendvy21-lifecycle-array-health-v8-prof-diagnostic01`. Onefreshunprofiledoriginalsource actual02 also5stimeout48,514,731bytes/stderr0; bothfailuresremain, no unchangedreruns orstabilityclaim. Counterrepairrejected; investigateprofile-supportedmaterialization only. SeparateReadersaudit locatedhistoricalprivateWT, no currentcanonicalfullconsumer; firstremainingReadersgate isordinaryMotion64+independentfulloracle+stockpair, nottiming.

Drain-onlyHealth2cd81679/b41dfed0 preserves originalArrayBufferlayout/inlinecode; changesonlymaterialize traversal toderiveArrayindexfromshrinkingNat. FirstHealth64JS passesfull3,904,540byteoracle; actualgenerated3695 confirms3arg self-tail loop andrest>>>0 intrinsic, redundantU32index/subtractgone/noadditionalper-characterhelper. Nativeordinarybuildlive; largeracceptancepending. Read-onlygeneratedbinding `/tmp/bendvy21-materialize-generated-js-review.json` retainedforfinalpacket. Readerssecondowner `/tmp/bendvy-canonical-readers` branchperf21/canonical-readers-runtime-v1 ownsnewordinaryfixtureonly,sharedcoreunchanged; no expectedoutput self-authoring orheavylaunch.

Drain2cdHealth64stockpairpasses; Health1024JS5stimeout32,026,698bytes/stderr0, noadoption. Currenthostload11.22(previous4–5), unrelatedvitestworkersactive;cpu.maxunlimited/nr_throttled0; no causal attribution/performancewinner frompartialbytes. Stopfurtherprivatewriterchanges/reruns. Preparehonestboundedoriginalc790/a7adLifecycle source/evidence delivery:11/12ordinaryrolesPASS, selectedHealth1024JSactual01+02deadline preserved; full15sprofileoraclePASSseparately, never5sacceptance. #21/parents andoriginalgate remainopen; Readersordinaryconsumercontinues. Existingretentionhelperwill distinguishselectedPASS/incomplete/history; nofake12PASSscope/newframework.

Bounded Lifecycle package cfc3fcbf6 and final independent review3a5796cbe are complete. Review verified12,739bindings/5,939losslessobjects/23externalELF identities, source/plan/receipt/raw/guard/producer joins,25selectedfixturebodies/67productionunion/351protected bodies; elevenordinaryPASS andoneHealth1024JS5sINCOMPLETE remain distinct fromfull15sdiagnostic. Strictdecoder replay Motionall3+Health64 passed; Health256/1024 prelaunchstrict receipts were reused aftersource/raw/hashjoins. Existingunchangedprotected#28 evidence is reused; no benchmark/source/compiler reruns. Readers ordinaryconsumer remains active. Researchc799d19f8 confirms Ritmo rename is not itself a semanticfork; keep qualified3040, classify newopt-inTS policies separately, no benchmark/reference repin. Root integrates only owned leaf/source-review/two status docs; foreignworkspace changes preserved.

Integration checkpoint: masterfac6ec22dc1f6897410e51fc72cb58c52f5ab3bd pushed; normal root hooks and Infrastructure CI39037389118 PASS. English partial#21 report: https://github.com/dearlordylord/bendvy/issues/21#issuecomment-6234584180 . No parent closed. Readers Motion64 source d80d3912d/freeze4073ce70 is held aftercurrentpure/hostboundary checks; independent oracle owneridentity38_gate_audit verifies102literal members/88extra pins and derivesfirstfullMotion64 model withoutsubjectoutput access. Foldthisstatusnoteintonextdelivery; no unchangedruns orstandaloneCIcycle.

Readers source-affinity audit `/tmp/bendvy21-readers-current-source-affinity.json` confirms82current dependency bodies unchanged and20newreachedfixtureBendfiles, freeze4073ce70. Existingoccupancycountermutants do not reachnew193before-finishcaptures; afterfirstpositivepair, one metric-onlyundo-countcontrol is planned withoutchangingactualTxowners/ECS effects. Independentoraclemode derivesnormalexpectations separately fromBendsource. Secondsource directionFailedTxn startswithsamefrozenstory, genuinefreshwarmup/measuredWorlds inoneprocess andcompleteforcedobservations; no expected/backend/self-model orlargematrix beforefirstMotion64pair.

Readers Motion64 first complete ordinary consumer passed JS and Native on 2026-10-17: source `d80d3912d`, independent oracle `e72907775`, actual receipts `/tmp/bendvy21-canonical-readers-motion64-actual01/normal/{js,native}/receipt.json`. Both complete outputs are 8,151,458 bytes, SHA256 `dd4777aba5ca3c0d605afb135f4b659f5b3e1fab59fbba0e77a27dbf92a37778`; all command exits zero and stderr empty. Existing emit30s/build120s/consumer5s limits preserved. This establishes one correctness pair, not full Readers qualification or comparative performance. Next: reached metric observation control, then remaining affected scenarios.

Readers reached undo-count observation control passed on both stock backends: independent counter `d98a730fe`, source `41908c677`, receipts `/tmp/bendvy21-canonical-readers-undo-count-actual01/normal/{js,native}/receipt.json`. Both full outputs match the 8,151,457-byte counter SHA256 `a96d5f2b140b324c70f8a379c97e14e3243727e00ddb00c336f8c7c79857b220` and reject normal at byte 5,423; all commands exit zero with empty stderr under unchanged caps. The mutation changes only reported undo count; actual transaction execution and owners are preserved. This covers observation sensitivity, not performance qualification.

Readers Health64 first ordinary JS/Native pair passed against independent oracle `cad94c7da`, source `9901f7b43`: 8,077,591 complete bytes each, SHA256 `159139269b00038c4d1220a835c75adb65389446c5f61eb5b2dfce8db799a9e5`; all commands zero and stderr empty, unchanged limits. Actual receipts `/tmp/bendvy21-canonical-readers-health64-actual01/normal/{js,native}/receipt.json`, portable packet `readers-runtime-v1/runtime-v1/health64/actual-attempt01` in source worktree. Remaining 256/1024 models sealed independently at `5b1a09196`; larger runs reuse exact first64 artifacts instead of emitting/building again. No comparative timing qualification claimed.

Readers 256 actual01 reuses unchanged first64 compiled artifacts: both JS complete outputs match independent wide oracle `5b1a09196` (Motion29,864,938/Health29,692,447 bytes), but both Native consumers hit the unchanged five-second child deadline with zero stdout/stderr. Receipts retained under `/tmp/bendvy21-canonical-readers-{motion,health}256-actual01`. The 1024 plans are prepared but UNEXECUTED while this concrete blocker is investigated. Source driver builds the entire report before its first IO.print; this is a source-backed hypothesis, not yet a proven bottleneck. Source owner investigates an observer-only repair; no ECS operation, full observation, cap or product timing criterion is reduced.

Readers private streaming report repair: candidate `9f04eb355` preserves the original full oracle and passes Motion64 and Motion256 on JS/Native under unchanged caps; Health port `55731d310` passes Health64 on both backends. Native Motion1024 remains INCOMPLETE at5s with no output. One existing PC-sampler diagnostic (plan `f5bfc1f6`, unchanged original ELF) retained3996 samples:2556 self-PCs in String.append/continuation, all mapped to main ELF, no holes/overflow/setup errors. It supplies no caller stacks, full-tail observation or elapsed-time share. Nonzero previousAlarm4 remains explicit (consistent with preload through taskset). Profile/source inspection directs the next private capture-Doc representation repair; no ECS work, output fields, codec or thresholds change. FailedTxn ordinary source `d76fab513` is sealed for independent modeling, including two actual WorldIO creations and generation-aware full handle observations; no backend credit yet.

Readers capture-Doc successor `bbd6c0892` passes the first Motion64 stock JS/Native pair against unchanged 8,151,458-byte oracle `dd4777ab`; actual receipts `/tmp/bendvy21-canonical-readers-capture-doc-motion64-actual01/normal/{js,native}/receipt.json`, all command exits zero/stderr empty with existing30/120/5 limits. Independent source rebind `080aac8e` preserves complete physical snapshots and old wire. Prelaunch review found two provider-delimiter omissions and incorrect buffer provenance in unexecuted `10a2`; successor fixes both and uses exact integrated buffer0796e163. Native1024 target remains next, not yet qualified. FailedTxn service controls `5eea885dc` source-check affine input/output and four intended grant authority refusals while preserving all232 full-consumer pins.

Doc Motion1024 first ordinary attempts remain INCOMPLETE at5s: Native emits an exact41,074,688-byte prefix of the unchanged117,889,515-byte oracle with empty stderr; JS emits zero bytes/empty stderr. These are not full-correctness or timing qualification. Existing PC diagnostic successor plan `bd690e36` on exact Doc64 ELF retained3957 PCs, no setup errors/zero/holes/overflow; inherited previousAlarm4 remains explicit. No unchanged consumer retries. Source owner analyzes this packet before another representation change.

Public owned service-request control passed stock JS/Native through actual Sys.register/run: full128-byte independent oracle SHA954d2fb4978172341ae27e555f9197c67c33394dc5f0934c57b906d3182d6a4d, sourcefreeze734e24b0/sourcecandidateeee039017, independentmodel899d66d47. Receipts `/tmp/bendvy21-service-request-control-actual01/normal/{js,native}/receipt.json`, all exits zero/stderr empty, existing30/120/5 limits. Actual affine Array exchange returns old service owner and retains input in slot; missing service returns input. Four intended grant authority source refusals remain5eea885dc. This does not qualify full FailedTxn rollback or complete API integration; first full same-process model remains pending.

Packed Doc firstMotion64 passes both stock backends against unchanged8151458/dd4777 oracle (receipts `/tmp/bendvy21-canonical-readers-packed-doc-motion64-actual01/normal/{js,native}/receipt.json`). Source5d175/independentbindingbe812 corrects a prelaunch entrypoint-worktree mismatch rejected by the existing exact import-closure guard; rejectedc1a/223e were never executed. FirstNative1024 remainsINCOMPLETE5s with an exact73,326,592-byte prefix of117,889,515 bytes and empty stderr; this is not a speedup or full-correctness claim. Generated Native code disproves the persistent-trie allocation hypothesis: writes already use direct blk_at/blk_write, followed by direct reads during materialization. A bounded reversed-String scratch buffer is an unproven alternative, trading these accesses for string construction and reversal; test it without changing observations or limits. No unchanged retry. Successor4e6f35799 passes primitive Unicode/chunk-boundary controls (12,314 bytes, SHA0bee33af) and full Motion64 (8,151,458 bytes, SHAdd4777ab) on stock JS and Native, with independent binding247ef59a and unchanged caps. First Native1024 is INCOMPLETE at5s with a 64,901,120-byte exact prefix (SHA49b4a719), empty stderr; JS1024 remains UNEXECUTED. The candidate does not resolve the deadline and is not adopted as its fix; prefix lengths do not establish comparative performance. Leaf-specialization2fc68e542 passes its105-byte grammar control and fullMotion64 on both backends (independent81ba94f5), but Native1024 still hits5s with a92,078,080-byte exact prefix and empty stderr; JS1024 is UNEXECUTED. Profile the current ELF before another repair to distinguish private observation from actual ECS costs.

FailedTxn first ordinary Motion64 attempt02: JS exits0/stderr0 with38,459,780 bytes and final Complete, but disagrees with model635089ce. Independent source audit found model-only repeated full Frame.calls at every boundary and incorrect List.show commas; source observes registered owners at boundaries and the full call history once in final owners, retaining all64 iterations/256 boundaries. Native emit/build succeed but consumer hits5s with19,226,624 bytes/stderr0. Correct the oracle from source and repair private report construction; no source semantics or limits reduced. Attempt01 was rejected before execution because oracle aliases were symlinks; regular-file successor preserves bytes and the existing runner. Stream successor8a8bf7d with independent413d1d8b now passes full38,459,780-byte/28595ef3 ordinary JS and Native under unchanged30/120/5 caps. Existing old-source JS output independently matches corrected modelb5063a28 in full; its original INCOMPLETE receipt is retained. Portable packetddfc52d8 and independent final review4399a3fee pass. Combined root retains all351 protected #28 source bodies and its29-file frozen import closure excludes the new service module; original123-command gate is reused without a new timing claim. Hooks/CI follow bounded API integration; full#21 qualification stays open.

Bounded FailedTxn/API integration bf63bd2be passed normal hooks and CI39046338886; #21 partial report posted without closing the issue. Readers Indexed Motion64 (10,810,200 bytes) and actual full-key rollback/stale-owner control (3,861 bytes) pass JS/Native. Native1024 still hits5s with115,449,856 bytes of its new158,696,224-byte physical oracle. PC04 observes no Plain lifecycle-scan samples, with buffer/IO work in the suffix; this supports the selected route, not a speed ratio or full qualification. Source/PC/control packetac87fe2f7 is retained. Next deliveries reuse this evidence; no unchanged compile/timing rerun for this note.

FailedTxn Health64 delivery: both ordinary backends match all 38,400,832 independently modelled bytes (`a20f7dcc…`); incremental final review `8e9c88126` passes. Additive Health sources and portable evidence preserve the accepted Motion/service API. The protected #28 sources remain unchanged; reuse applies to that workload only. Wide 256/1024 and final comparative timing remain open.

FailedTxn256 follow-up: unchanged-artifact JS/Native runs for both schemas exceeded the ordinary 5s cap (sealed wide packet `fa97c6d7f`). The array character-accumulator candidate passes Motion64 and a valid affine nested-array control on both backends, but Motion256 still times out and is unadopted. The invalid unbalanced predecessor control fails before the serializer and remains preserved. Existing Native PC samples did not identify an exclusive append caller; existing Node `--prof` caller chains then witnessed the candidate’s full-text reversal during physical World capture. The next bounded repair replaces character accumulation with string pieces; no elapsed speedup, GC attribution or full qualification is claimed.

Whole-Doc follow-up: held `d2487f9f` preserves the prior complete Motion64 oracle on both backends; independent source-equivalence review confirms character-length prefixes, owner returns and capture/IO ordering. Motion256 remains INCOMPLETE on both unchanged 5s gates. This candidate is not adopted as a deadline repair. Existing Native PC and JS V8 diagnostics are being rebound to the current source before further representation changes.

KnownLength private FailedTxn checkpoint: source `68cd0c797` passes ordinary Motion64 (38,459,780 bytes) and text controls (122,320 bytes) on both backends. Packet `e981bc61e` preserves source-current profiles and failed predecessors; root and final reviewer `419c000c5` independently passed its offline verification. Motion256 still misses5s; separate reviewed15s diagnostics match all118,614,122 bytes, including both fresh phases, without numerical performance credit. All351 protected #28 source hashes and receipt/manifest/archive identities match; reuse is limited to that unchanged workload. This delivers private qualification preparation, not a production optimization or #21 completion.

WholeFit follow-up: private source `d98c7a6d9` changes only the known-length fit test to allow a complete string within the remaining4096-character chunk. The additive control covers a whole4096-character append and partially filled fits/fallbacks. Both backends pass122,320control bytes and38,459,780Motion64 bytes. Motion256 still exceeds5s: JS emits the exact59,307,060-byte warmup prefix; Native emits an exact60,338,176-byte prefix of118,614,122. Neither is acceptance or a speed ratio. Rebind existing full-coverage V8 diagnostic before another source change; no repeated archive/CI checkpoint for this failed deadline repair.

WholeFit full V8 diagnostic completes118,614,122bytes against unchanged oracle. Its7122ticks/0unaccounted include331Doc.write_go (146 via measured_created),156String.take,74Buffer.text_go and106row render_chunks. GC2209ticks overlaps categories and does not identify allocation ownership. Next source-supported hypothesis changes report transport retention: drain completed4096-character chunks during Doc traversal while preserving original capture/IO chronology and exact work accounting. No deadline or comparative performance credit from this profile.

StreamChunks source `7d81a6254` drains completed chunks during Doc traversal; ordinary Buffer and ECS bodies stay unchanged from WholeFit. Both backends match122,320control bytes (including an exact4096-character Doc end) and38,459,780Motion64 bytes. Motion256 remains INCOMPLETE at5s, stderr empty: JS59,307,060 andNative95,948,800 exact-prefix bytes of118,614,122. These partial bytes are not elapsed ratios or full acceptance. Existing15s V8 protocol is rebound to this source before another repair; no archive/CI cycle for a failed deadline candidate.

DirectDrain `de6b67bd4` removes per-Doc transport wrappers; LeafFusion `f392ae322` reuses observed leaf character counts and emits the physical leaf prefix directly. Both retain ordinary Motion64 equality on JS/Native; LeafFusion text-edge and arbitrary affine Type-array controls also pass both. LeafFusion Motion256 still exceeds5s (JS59,307,060/Native107,679,744 exact-prefix bytes). Its reviewed15s JS diagnostic matches all118,614,122bytes with empty stderr. Source-current V8 profile has5123ticks/0unaccounted: write_go436, concat130, String.take154; GC877 overlaps categories and establishes no allocation owner. The reached leaf-prefix mutation is rejected by the unchanged affine oracle while returned-owner observation stays unchanged. Next repair removes concat singleton identity nodes; no comparative speed or final acceptance claim.

ConcatIdentity `d0849cbf7` returns the actual singleton Doc instead of allocating an empty-text Join. Both ordinary Motion64 backends match38,459,780bytes. Ordinary256 still times out at5s with empty stderr: JS matches a79,578,164-byte prefix; Native matches the entire118,614,122-byte oracle but has no successful process exit. Full stdout alone is not acceptance. Receipts and OUTPUT-COMPARISON.json retain both results. Before another source repair, test the premise that formatter allocation is the remaining blocker using source-current allocation sampling including collected objects; CPU GC samples alone cannot establish that premise.

Source-current allocation sampling on ConcatIdentity completes all118,614,122bytes with exit0/stderr0 under the reviewed15s diagnostic cap. Exit/error controls preserve their actual codes and synchronously publish profiles; timeout control remains INCOMPLETE without a profile. Profile SHA c7a40927816f819a2fffc774df45c1bbcb97b14377a9dbe44dd6d2171f8d8091 includes minor/major collected objects and379,501samples. Statistical self-size estimates place write_go at6.47GB of24.97GB cumulative allocation across preload/runtime/warmup/measured work; these are not exact totals, RSS or GC causality. Emitted JS confirms Buffer reconstruction on every Doc step, including Join. Next focused repair threads private Buffer fields directly; public query declarations and affine owner semantics remain unchanged.

Combined candidate218fd317c passes Motion64 on JS/Native and, for the first time in this sequence, ordinary Motion256 Native within5s with exit0, empty stderr and complete118,614,122-byte oracle equality. JS256 remains INCOMPLETE (69,874,740 correct-prefix bytes); no elapsed ratio or TS comparison follows from this result. Actual emitted JS passes the original immutable Data Buffer on Join and delays operational query construction behind an unselected affine thunk. A preceding pattern-reordering attempt passed JS64 but still reconstructed Buffer in emitted code; it was not credited. The combined public query lowering is held off master pending allocation-after diagnosis, Type/access controls, affected #28 regression and final independent review.

Combined source-current allocation-after diagnostic matches the complete oracle; estimates include17.83GB cumulative sampled self size (271,017samples), with prior eager operational pair/optional allocation frames absent. These are two diagnostic estimates, not exact totals/RSS or a speed comparison. Writer self remains6.23GB, and actual JS still creates2stack cells perJoin. Independent current CPU diagnostic also matches full oracle:4510ticks/0unaccounted, write_go353, String.take166, known98, text_go91; GC666overlaps categories. Next private repair carries current Doc separately from pending rights, with unchanged exact work/chunk budget. Public query Type/access validation uses existing controls while shared source is held.

CurrentDoc `8296cf0e1` preserves ordinary Motion64 equality on JS/Native and Motion256 Native completion within5s. JS256 remains incomplete. Existing text-edge and arbitrary affine Type-array runtime controls pass both backends; all eight current public query authority/source controls pass after repairing the stale Caller fixture (earlier unrelated-arity refusals receive no credit). Full V8 diagnostic matches118,614,122bytes; processing exits0 with an unknown-code-move warning retained. Its4422ticks include373writer samples; Node shared-library caller chains also identify physical Array observers and recursive show_rest. Emitted JS confirms Array branch slice/concat copies and temporary three-element Doc lists. Next bounded repair removes only those temporary lists; no timing ratio or full acceptance claim. Root is now sole Git-index writer in the shared CurrentDoc worktree after concurrent staging combined two owners’ files in9d217d612; history and all evidence were preserved, and subsequent authoring uses separate worktrees.

DirectShow `0ebd46e328` removes only temporary three-element Lists from show/show_rest and preserves the exact Doc tree. Actual ordinary Motion64 completes on JS/Native with38,459,780byte oracle equality and exit0/stderr0. Both256 attempts remain INCOMPLETE at5s (JS59,307,060/Native70,029,312 correct-prefix bytes); these are not speed comparisons or evidence that the earlier CurrentDoc Native pass transfers. No repeated campaign or diagnostic for this microcandidate. The next source-backed investigation targets reached balanced physical-array observers, whose JS deconstruction/reconstruction uses slice/concat; arbitrary-Type ownership and complete physical observations remain required. Optional-inspection mutation attempt01 stopped before execution because its artifact parent was missing; preserved as a preparation failure with no semantic-refusal credit.

Lazy inspection reachability control attempt02 now executes successfully (emit/consumer exit0, empty stderr, seven unchanged guards) and the unchanged oracle rejects the intended Optional→Required mutation. Actual output33,891,616bytes first differs at5,494,614: empty rows replace expected entity rows. ROOT-SEMANTIC-COMPARISON.json retains the exact streams/hashes; collector correctly remains INCOMPLETE for this negative control. This establishes the reached finite inspection path, not universal API refinement or performance acceptance.

IndexedData `5fc4aef9e` replaces only reached balanced Slot/U32 physical-array traversals with owner-threaded indexed reads and detached binary Doc carry. Both ordinary Motion64 backends match38,459,780bytes with successful exits. Actual emitted six specialized functions contain no slice/array_node and forward the same Array; generic/Maybe<Type> paths remain unchanged. Ordinary256 remains INCOMPLETE5s (JS59,307,060/Native118,312,960 correct-prefix bytes); proximity to full stdout is not successful completion or comparative speed. The remaining reached Maybe<Type> copy path is investigated through None extraction, one projection and same-index restoration before the next callback, retaining generic fallback and all original physical observations.

IndexedType `fcc7556f7` additionally scans balanced Maybe<Type> slots via extraction/projection/restoration, preserving actual owners even on invalid fuel branches. Ordinary Motion64 passes both backends; the independent mutating-owner control137c58c7 passes229bytes on both and confirms updated111/121payloads with unchanged12/22andNone slots. Actual generated code restores the returned owner before the next extraction and avoids slice/array_node in all three new Type instantiations. Motion256 remains INCOMPLETE5s on both; no ratio is inferred. Current full V8/allocation diagnostics both match118,614,122bytes. V8 has4681ticks/0unaccounted, processing stderr0, writer376/carry169; collected-object allocation sampling estimates17.07GB cumulative self size, writer6.23GB (not RSS/exact totals/latency). Removing Array copies did not establish the ordinary deadline. Next single source-backed writer hypothesis fuses physical-node pending frames; a growing String accumulator is rejected as automatically better because Native append copies the left operand.

PendingFrames integration checkpoint (2026-10-17): selected source7011ec9ee preserves Motion64 on both backends and completes Native256 within the original5s limit (118,614,122-byte full oracle). JS256 remains INCOMPLETE. Affected Health64 successor changes only the public query module across117 source members and passes both backends against38,400,832 bytes; portable supplement c637070d verifies538 bindings/495 objects. Selected packet945987db verifies5,582 bindings/1,309 objects, eleven full comparisons, two reached observation mutants and eight source-authority checks. The optional-scan mutant changes a nonlast None rendering; it does not test restoration failure. Independent final Spec/Standards review passes; its Caller-control authorship limitation and coordinator source review are explicit. Public lazy lowering is a separate semantic delivery under the existing amendment, not a #21 performance keep: raw Declaration fields become affine Unit factories, while ordinary factories/accessors keep their signatures. The stale private automatic-app prototype is excluded and restored unchanged.

Fresh unchanged combined #28 ran123 successful commands and110 full ten-application observations: NO_CONFIRMED_REGRESSION (receipt db75402f; archive bcf7f36f, manifest ae030438). This qualifies only protected Workshop scope under external contention, not the final TS comparison. Type-before/Pending-after collected-object allocation estimates are17.07/16.40GB, writer6.23/5.58GB; these are sampled cumulative estimates, not RSS, exact allocation or latency. Full15s profiles match the oracle but do not satisfy ordinary JS256. Delivery reused source controls, models, runners and earlier diagnostics; only affected Health and the combined gate were executed for integration. No new gate or tracking layer was added. Readers1024, remaining wide schemas, full numerical matrix and exact #62 law approval remain open.

Checkpoint delivery ea87225f6 passed configured hooks and CI39063223483; #21 remains open with the bounded completion report. This actual delivery used one final review and one fresh combined gate after consumer evidence, with no repeated compilations for documentation notes. CI included repository checkout and cannot be treated as isolated check latency; no aggregate delivery speedup is established.

RowJSON source5560fdfe9 changes only private typed row formatting to right-associated bounded String.append calls. Actual emitted row callbacks bypass Dense per-character push/reverse; unchanged U32 and boolean formatting preserve all fields/order. Motion64 and256 now pass complete ordinary JS and Native within the original5s cap (38,459,780 and118,614,122bytes). An independently generated1024 oracle preserves444,624,902bytes; JS1024 expires before output, Native expires after85,372,928correct-prefixbytes. Neither gets full1024 credit or a speed ratio. Independent bounded source/evidence review passes; current protected #28 monitored353hashes remain byte-identical, so its actual gate is reused without another campaign. Health does not import the changed module. The existing model, collectors and64artifacts were reused for wide consumers; no new check or tracking layer. Next investigation separates pre-first-output construction from writer costs; old256profiles do not establish the1024 cause.

RowJSON checkpoint4bc6da6f8 passed actual hooks, master push and CI39064204139; #21 report records both new256 passes and unmet1024 gates. No unchanged-source benchmark or compilation was repeated for this status note.

1024 premise under review: local formatter repairs alone are sufficient to clear the unchanged complete-output gate. RowJSON and the held four-leaf Data specialization both preserve64/256 but leave1024 incomplete; no third repair starts before testing the remaining pre-output-construction versus output-runtime cost. The complete FailedTxn wire is444,624,902bytes, including same-process warmup and fresh measured World. An ideal Base IO replay may test an output-only bound; it cannot establish ECS throughput, identical allocation pressure or a quiet-host timing result. Ordinary acceptance caps and full observations remain binding.

The favorable IO-volume control completed on both JS and ordinary Native -O3 within the unchanged 5s cap: all 444,624,902 bytes match independent oracle214a2c6c. Generated JS/Native reuse the prebuilt 4096-character chunk and phase tails; per-write encoding/reference-count work remains. This rejects output volume alone as a sufficient explanation for the current failure under the tested conditions; it establishes neither an ECS speed ratio nor enough remaining time for construction. The next repair targets source-backed construction costs, without changing output or acceptance limits.

Readers current-source 15s V8 diagnostic produced the full 158,696,224-byte oracle output. Processing its byte-exact first 5,000,000-microsecond logger prefix succeeded once within 5s (3,258 ticks, no unaccounted/excluded ticks). Recursive physical-array Doc builders appear in both flat samples and caller chains and emit array slices. This supports an owner-preserving indexed-observer candidate; it does not establish an exclusive bottleneck, ordinary 5s completion, allocation totals or a speedup. No additional workload run was needed to process the retained log.

The held balanced-capture candidate (source ff2153050) removes carry construction and preserves exact semantic writer fuel. Ordinary64 JS and Native match all 38,459,780 bytes. Native256 matches 118,614,122 bytes; JS256 reaches the 5s deadline after 74,523,700 exact-prefix bytes. Both 1024 backends remain incomplete (JS 0 bytes; Native 57,454,592 exact-prefix bytes). All executed command stderr is empty and source guards pass. No new complete gate was gained, so master keeps RowJSON. This is not comparative speed evidence under contention. The next FailedTxn investigation addresses eager whole-phase construction before first IO; no further writer variant or profiling run was launched for this result.

Readers indexed Data traversal passes complete corrected 64 and 256 JS and Native oracles. 1024 remains incomplete on both backends. The corrected helper accepts a detached Data renderer rather than claiming to preserve arbitrary returned-owner mutations. One malformed successor plan kept old artifact paths inside argv and overwrote its predecessor JS before the collector rejected the missing new artifact; that historical generated JS is explicitly lost, while its receipt/output/guards remain. The existing preparer now checks artifact edges before saving plans, rejects that preserved bad plan and accepts the fresh successor paths. FailedTxn cell fusion passes 64 and the existing 229-byte mutating affine-owner control on both backends but gains no complete wide gate; it is not adopted. Next work stays with the same two owners: canonical affine indexing in Readers and explicit writer traversal state in FailedTxn. Source counts and sampled allocation ancestry motivate the latter, without predicting a speedup or resolving eager capture.

Traversal/affine-indexing checkpoint (2026-10-17): existing consumer-only plans reused the successful64 artifacts without recompilation. Readers indexed optional256 completes both full40,177,844-byte oracles;1024 hits5s on both, with exact prefixes27,257,430 JS and69,447,680 Native bytes. FailedTxn traversal256 hits5s on both, with exact prefixes59,307,060 JS and94,707,712 Native bytes;1024 plans remain unexecuted. Root independently compared all six outputs against their existing gzip oracles. Writer Join no longer reconstructs Buffer, but emitted traversal wrappers add allocations; this supports rejecting its adoption, not a measured regression attribution. External CPU contention is present. Selected4bc6da6f8 remains unchanged; no numerical performance claim, acceptance waiver or parent closure. Next work uses the same two owners and existing profiles/affine controls.

Shared framing checkpoint: source6866e5bbd passes64 on both backends and256 JS with complete unchanged oracles. Native256 reaches an exact118,317,056-byte prefix then the existing5s deadline; no1024 attempt or performance adoption. Generated JS constructs three immutable framing Docs once per optional traversal and forwards them through all three specialized loops; actual owner projection/restoration stays in place. Root independently verified retained packet3894b2bc9 (565members/525objects/25guards). Readers affine control attempt02 emits/runs successfully in JS and matches all135 expected bytes, but the collector receipt remains INCOMPLETE because its plan supplied plain text where the runner requires gzip; preserve that failure and reuse the emitted artifact in a corrected consumer-only successor. Root rehashed all353 protected #28 sources with zero mismatches; no unchanged regression run is needed for this checkpoint.

Readers bounded delivery: selected packet338c434ad retains1,016members/687objects, six complete oracle matches and two1024 exact-prefix deadlines. Both135-byte affine returned-owner controls pass. Final independent Spec/Standards review594c35d1 passes the complete25-file consumer plus control and current106-file dependency closure. Two plan preparation failures remain explicit; JS emission was reused for the corrected oracle successor. Root reused the exact353-source protected #28 evidence. This integrates correctness coverage and current consumer sources, not a performance keep or #21 closure;1024 and numerical qualification remain open.

Readers checkpoint89afe1e4e passed configured hooks, master push and Infrastructure CI39071307140; English partial #21 report: https://github.com/dearlordylord/bendvy/issues/21#issuecomment-6241468657 . Delivery used exact ownership staging for726paths, reused the105/63-file consumer/control source-bound runs and unchanged353-source #28 evidence, and completed one independent final review. The two control-plan errors were fixed locally; the successful JS emission was reused. No aggregate delivery speedup is established. Fold this status note into the next suitable delivery; do not rerun unchanged checks for it.

Current-source diagnostic checkpoint: Readers V8 successordf67a486 passes the full158,696,224-byte oracle under the existing15s diagnostic cap; its ordinary5s1024 role remains incomplete. The first profile plan failed before child execution because two namespace sidecars were included in the Bend import inventory; the successor uses the existing collector validate_imports result (105files) and pins sidecars separately. A byte-exact first5,000,000us logger prefix processes once under CPU9/cap5 (3,112ticks,0unaccounted); no elapsed-time or old-profile attribution claim. FailedTxn opaque-buffer source179e4b69 passes64both and256Native, but256JS hits5s with90,453,044 correct-prefix bytes. Its collected-allocation diagnostic completes the full256oracle: sampled writer-inclusive estimate7,882,518,848 versus stableRow7,848,611,616, with total14,729,600,496 versus14,677,104,976. These statistical cumulative estimates show no demonstrated allocation reduction; they are not exact/RSS/peak/speed measurements. Generated Join forwarding succeeds, but the intended aggregate allocation premise does not. Candidate remains unadopted; no1024 retry or wrapper variant follows from this result.

FailedTxn opaque-buffer CPU follow-up: the existing15s diagnostic matches the complete118,614,122-byte oracle. Its exact first5,000,000us logger prefix processes once within5s on CPU9 (3,519ticks, zero unaccounted/excluded; receipt `/tmp/bendvy21-failedtxn-opaque-buffer-v8-prefix5000000us01/prof-process.receipt.json`). Flat samples include write_go194, carry_go117, String.take104 and Buffer.known83; caller analysis remains pending. This does not reverse the negative allocation result or qualify an ordinary deadline. No additional consumer run or source variant was needed for prefix processing.

Readers iterative Data candidate3ce88f239 passes ordinary64 on JS and Native with all10,810,200 oracle bytes (183936740ad2407530099198388cc87d872b121fa0681a3a7777ec42797b83ce); root independently compared both complete outputs. Generated JS82011d3b uses a direct loop in the selected indexed_data_scan, without the old right-child continuation; the structural fallback remains. Native uses the unchanged ordinary build/consumer caps. Wider reuse checks and acceptance are pending; this is not a measured speedup or adoption.

Readers iterative Data wider check: unchanged64 artifacts were reused once for256. JS reaches5s with zero stdout/stderr; Native reaches5s with28,114,944 exact-prefix bytes (ffdb79c2937fd7c108ef35bf7130839ba126b2129084ac8ba6867d24c15974a8) of40,177,844, stderr empty. Root compared both outputs; an empty prefix provides no semantic coverage. Host load rose above37 on12CPUs; a later one-second /proc/stat sample showed91.5%aggregate busy but assignedCPU11 idle100%, so neither hostload nor these deadlines establishes the cause or a comparative regression. No new complete wide gate was gained; candidate remains unadopted and both1024 plans unexecuted. Source-current Native PC binding for selected FailedTxn is being prepared through the existing runner, with no changed caps or benchmark launch.

Selected FailedTxn RowJSON Native PC04: independent binding review passed plan dd6eef2738a2689fb0916d921726012204455fe34cb6d4a4fae5b9736846ea83 (119 Bend imports plus2 sidecars,428 pins). After a fresh one-second CPU11 sample showed100%idle, root ran the unchanged diagnostic once. Consumer remains INCOMPLETE at5s, but the alarm packet retained3,982 samples with setupError/prefixHoles/overflow/zero all0. Root verified21,684,224 output bytes as the exact prefix (16ea18ea8cccbb07b795d47acdce01de376187150f43daaae6d94d7d93c2e8f1) of444,624,902. Current self-symbol counts include heap_alloc_miss703, String.append618 plus continuation236, rfc_wrap582 and String.length418. These locate sampled runtime costs, not callers, timing dominance or numerical acceptance; source-callsite investigation continues. No consumer retry or acceptance-limit change.

Premise check after repeated writer candidates: the assumption that further writer-state repairs address the remaining sampled cost is insufficient. Current Native String.length dispatcher callsites resolve to O.audit_effect and Doc.text, not Buffer/IO; cached Doc length/work accessors do not scan text. DW.resources still calls lift(O.resources): the latter renders the complete growing Recorded effect list into one String, then Doc.text measures that aggregate again. This source-backed construction seam is distinct from writer reconstruction; flat PC samples alone do not attribute its cost. Investigate structured resource Docs using existing audit/show helpers while retaining every actual owner/projection/effect, capture order and exact wire. No protocol/acceptance change or speed claim follows. Readers unadopted packetd6a3872ea independently verifies (681members/526objects); its256 failures and unexecuted1024 plans remain explicit.

ResourceDoc candidate1f36296c changes only private motion-doc-world observation helpers. Both ordinary64 backends pass complete38,459,780-byte oracle28595ef3734a1b4772e43d01b63806120db6c452207c31caaddd3d50cb45e3f0; root independently streamed both comparisons. Generated JSafd18347 confirms selected DW.resources bypasses aggregate O.resources and builds exact Recorded list grammar from existing Doc helpers, retaining actual effects and returned ledger/slot owners. Pinned Base List.show grammar was independently checked. Source check passed; host01 external137 with emptylogs is retained, host02 returned the expected9foreign checks after a resource recheck. No toolchain, public API, writer, full oracle or acceptance-cap change. One consumer-only256 attempt per backend remains INCOMPLETE5: JS84,878,388 bytes/881f73f9c3645c8fc545d39224a6e1087bc6b46c8c8e96fa61d3b288f93170ea and Native97,148,928 bytes/8c4b2ad6f84161f2bbbaa45d9c301232922ddd7ba7a14600708332592ceef1c9 are exact prefixes of118,614,122. No1024ordinary or mutation launch followed. Reviewed PC05 ran once: INCOMPLETE5 with3,952 clean self-PC samples and34,435,072 exact-prefix bytes/09786256ffc7e8d37c35153b2a3beb5c36fd9ee4f1b254d95487e7126ce0c7a0 of444,624,902. Current Native lowering bypasses aggregate O.resources as intended, but prominent sampled families persist: heap_alloc_miss683, String.append624 plus continuation239, rfc_wrap568, String.length470. The sampled windows need not cover identical work, so these are descriptive counts, not elapsed ratios or caller attribution. This intervention has not demonstrated a complete gate benefit; candidate remains unadopted. Further formatter variants wait for a discriminating observation.

Tail-count feasibility: private report-doc helper71f0db2e replaces Base String.length only for Doc.text, preserving actual Unicode codepoints and original String. Both tiny ordinary backends match the independently authored55-byte oracle2c87ea0bb1b0d29ff8d9f0c6dcea96a6fb291a36c3dfec7cd1b6118cc5c5d5d6 (empty/ASCII/BMP/astral/combining/mixed, nonzero accumulator, retained values). Actual JS is a codePointAt/slice tail loop without spread; suffix-string allocation remains a tradeoff. Native is direct tail iteration without per-character increment continuations; transitive term_peek/rfc_view reads may use atomics/fences but allocate nothing. Text entry/exit still performs owner keep/sink and constructs Text. The first oracle location caused existing preparer broad-parent scanning; stopped before any subject and corrected via nested immutable literal basis, with identical expected bytes and no runner change. Motion64 subsequently passed both ordinary backends with all38,459,780 bytes matching the unchanged oracle. Consumer-only256 reused those artifacts: both reached the5s deadline, JS105,202,740 bytes/8936ac783b2ca5a19aa37787777b24432ce97bee628d975a39137cd3a819e360 and Native59,305,984 bytes/ee89721e1ca7c0ce377abd66042fd6478d0d544919e3ef4b63db1f90153557bf. Root compared both exact prefixes against the full118,614,122-byte oracle; stderr was empty. No1024 or repeat profile was launched. The candidate remains unadopted: removal of the identified length mechanism has not demonstrated a new complete gate or a comparative speedup.

Root independently verified the retained tail-count packet945e7cca:612 members/559 objects/42 guards, four complete controls/64 consumers and two256 exact-prefix deadlines. No adoption or repeated regression run. Next core delivery is user-assigned #73, starting from prototype3f2fa7518; FailedTxn phase analysis continues read-only.

Current RowJSON V8 prefix reinspection distinguishes sampled capture paths (`data_scan`, `carry`, physical world and row Doc construction) from writer traversal, but the first5s logger prefix has no joined first-stdout timestamp. It therefore does not establish a pure pre-output phase or elapsed cost split. Historical array-writer/world-doc/opaque profiles bind different artifacts. Any further phase diagnostic must observe program entry/return and first actual IO on one clock; no new workload/profile was launched for this read-only finding.

#73 delivery checkpoint (2026-10-17): reused the existing example runner for eight full JS/Native scenario pairs and the migrated user example, then qualified a separately authored blind consumer. One independent final review covered the implementation and retained evidence. The combined unchanged #28 gate ran once after core integration: 123 commands succeeded, 110 complete outputs matched, no confirmed regression. Core CI39079114169 passed both jobs. Unused-import removal and subsequent documentation changes reused applicable evidence; no unchanged backend campaign was repeated for status notes. This records actual reuse and delivery, not a measured overall delivery-speed improvement.

FailedTxn same-clock diagnostic (2026-10-17): reviewed copied-artifact instrumentation preserved original JS67777ae6 and full stdout. Exit/result-identity and thrown-sentinel controls passed before the subject. In the single15s diagnostic, warmup Scenario.program took8.491301351s; the first actual fd1 write began10.707622ms after return. The next program entered at13.713841770s after222,312,450 stdout bytes. Root streamed those bytes against the full444,624,902-byte oracle and verified both hashes. The deadline remained INCOMPLETE; no ordinary5s or numerical performance acceptance. Instrumentation and external contention bound these observations. They distinguish substantial pre-output construction from first-write preparation; the later interval also includes subsequent World setup. Next investigation targets eager capture/retention, not another formatter-only variant.

FailedTxn staged-report checkpoint: candidate20da2e429 preserves capture points and streams detached report segments through one partial buffer. Existing runner and oracles qualify both feed controls (122,320 bytes) and full64 consumers (38,459,780 bytes); independent review passes that scope. Reused64 artifacts for256 without recompilation: both hit5s, JS59,540,532 and Native116,977,664 bytes, each an independently checked exact prefix of118,614,122; stderr empty. Candidate remains unadopted. No1024, unchanged retry or comparative speed claim; inspect lowering and profile before another implementation.

Staged-report allocation diagnostic completed the same full256 oracle with the unchanged collected-object sampler; root verified profile2baff1c0 and fullwire41a05457. Estimated cumulative allocation remains about14.6GB versus selected14.7GB, with no demonstrated reduction. Scenario.program ancestry shrinking merely reflects Program.loops moving into an IO continuation; loop ancestry remains about6.2GB. Compile-only V8 inspection of exact artifactd4e2b645 found write_go CreateBlockContext at bytecode0 and JumpLoop back to0. Investigate extracting IO closures from pure traversal before another runtime candidate; this bytecode fact does not establish optimized-runtime allocation cost or speedup.

Direct erased-resume IO-helper feasibility87706ad3 was rejected at the intended compiler boundary: passing `~write_go` to the helper requires a filled definition while the recursive body is still being checked. Actual source/error retained; no backend launched. Independent review accepts investigating a pure traversal that suspends only at existing chunk IO boundaries, with unchanged fuel/order/errors/final flush. Implementation must first eliminate loop-head contexts in actual lowering before normal controls and full64 backend qualification.

Suspended writer checkpoint: source6665e157 passes the checker with an internal driver budget derived from the exact original fuel. Actual JS c7a1f674 has no closure/context bytecodes in advance_go and a direct backedge; registers rise84 to159. Existing text controls and full64 JS/Native pass with independent review. Reused artifacts for256: both5s deadlines, exact prefixes81,261,620 JS and111,960,064 Native; no1024 or adoption. Ordinary packetdd3a86d33 independently verifies978members/608objects/39guards. One reviewed collected-allocation diagnostic completes the unchanged118,614,122-byte oracle; profileec34619e. Estimated cumulative self allocation14,677,104,976 to11,755,035,032 bytes; writer-inclusive7,848,611,616 to4,988,267,232, while observation/render remains about6.2GB. Buffer.known attribution is included in the new writer union. One profile each establishes a descriptive difference, not statistical timing, live-memory or exclusive-cause proof. Allocation packet6e344f468 retains full bindings. Next inspect current CPU costs before another source change.

Current CPU and enum-mode follow-up: reviewed plan22838489 completed the full256 diagnostic oracle (118,614,122 bytes/41a05457) with empty stderr. Its complete V8 log processed within the existing5s offline limit: 4,422 ticks, none unaccounted; advance_go319, String.take160, capture carry_go144, text_go102 and known79 self ticks. Shared-library attribution52.2% limits exclusive attribution; GC670 ticks overlap category totals. This is not an ordinary5s pass or a timing comparison. Private candidatee8d083fa6 replaces four U32 traversal modes with Data constructors. Actual JS245e96f5 removes8u32_to_word and4word_to_u32 calls; bytecode9695→8188, registers159→147, no closure/context instructions. Complete64 and text-edge controls pass both backends. Ordinary256 remains INCOMPLETE5: JS59,307,060/8ebd75e2 and Native104,710,144/db3b9f2d are exact prefixes of the unchanged oracle. No1024, retry or adoption. Repeated writer-only fixes have not cleared the gate; the next isolated investigation targets the capture carry loop's unnecessary reconstruction of an unchanged stack. Selected4bc remains the baseline; contention prevents a speed conclusion from these partial outputs.

Capture follow-up: carry-only570044fc2 preserves the original stack on the False path in actual JS; full64 passes both, but256 remains incomplete (JS102,822,964/23275ece, Native111,255,552/57af7367). Packet9cfe069db verifies931members/573objects/22guards. Direct Data leaf9ce401898 also removes the temporary Text on valid Data render paths; arbitrary Type observation/restore is unchanged. Full64 passes both and ordinaryJS256 passes the complete118,614,122-byte oracle. Native256 stops at118,325,248/c5030e0e under5s. Ordinary packet530a12b62 verifies924members/569objects/22guards. The same65536 collected-object allocation protocol completes the full256 oracle; profile15fc63b2, packet518e5bd8 verifies1334members/670objects/7guards. One profile each estimates total14,677,104,976→14,487,552,800, capture/render6,260,007,648→6,112,589,400, writer7,848,611,616→7,810,392,456. This small descriptive reduction is not elapsed speed, live memory, exact allocation or causal qualification. Existing baseline profile is reused; unchanged text controls are outside the affected capture closure and are not claimed as new evidence. Neither capture candidate is adopted. Current cached-buffer writereb22d2cf1 carries an exact chunk-presence predicate, preserving fuel/IO/error priorities; source and independent design review pass. Actual lowering removes hot-loop Buffer field inspection; text controls, Motion64 both backends and Native256 pass, while JS256 reaches the exact112,321,588-byte prefix under5s. Ordinary packet9c108ef1 independently verifies981members/610objects/39guards. CPU phase packetc6927f7 independently verifies912members/563objects/12guards and full118,614,122-byte output: one instrumented diagnostic records5.244s marked wall and5.146s process CPU, including3.388s program phases. It is not an ordinary5s pass or exclusive bottleneck evidence. The next reviewed private candidate compresses uniform U32 observation blocks while reading every actual value and preserving exact wire; no production adoption. Site counts do not establish dynamic allocation frequency; prior ordinary Join paths already used the original buffer. Suspended CPU evidence1daa3870b independently verifies934members/580objects/4guards. No1024 or unchanged retry was launched.

Uniform U32 block candidate26a96fb69 reads every actual value and preserves exact wire/owner state; only four U32 observer fields change. Corrected controls pass both backends (19,231 bytes), full Motion64 passes both (38,459,780 bytes). The first fixture incorrectly constructed unequal Array branches and failed before observation; its14,210-byte exact prefix, source versions and raw failure remain retained. Consumer-only256 reuse hits the unchanged5s cap: JS70,726,708/03540f66 and Native117,227,520/27a769a0, both complete exact prefixes with empty stderr. Packet55793e77 verifies1004members/625objects/49guards. No1024, unchanged retry, adoption or comparative speed claim. Inspect complete-oracle block distributions before another representation change.

Uniform-block premise falsified by complete-oracle analysis:397,056 Position and133,128 Velocity arrays all have4leaves; no Indexed metadata appears. All530,184 observations take the fallback, with zero eligible32blocks, probes or cache hits. This establishes absent compression opportunity, not elapsed-time causation. Candidate is rejected for the current workload; next design must target reached four-leaf observations or plain columns.

Quad U32 candidate1c8f7a461 targets the reached4-leaf arrays: one exact Text, allfouractualreads and returnedowner, other sizes use prior measured fallback. Controls1340bytes and Motion64 both pass complete independent oracles. Consumer-only256 JS passes118,614,122bytes; Native hits5s with exact76,742,656/99bbd3c8 prefix. Packet6e42bb54 independently verifies967members/600objects/42guards; retention review passes. No1024/retry/adoption. Static generated Native analysis finds direct4blk_read operations but eight String.append calls materializing physical punctuation; JS uses native string+ instead. This is a source-backed tradeoff hypothesis, not proof of timeout cause. Collected allocation diagnostic is prepared with explicit combined cached-writer+quad versus retained direct-leaf/older-writer scope; it cannot isolate either change.

Quad collected-allocation diagnostic948d017c completes the full118,614,122-byte oracle. One sample per side estimates combined cached-writer+quad10,585,320,352 versus direct-leaf/older-writer14,487,552,800 cumulative bytes; observation/render5,872,395,536 versus6,112,589,400 and writer union4,176,186,808 versus7,810,392,456. This is not an isolated quad effect, Native profile, live-memory or timing result. Independent design review permits a single PhysicalQuad constructor with actual four strings/counts and nine existing buffer feeds, avoiding prior concatenation; exact4096 crossing/end controls are required before ordinary64 JS/Native.

PhysicalQuad candidatebebf0bfd retains four actual digit strings/counts in one private Doc and feeds nine existing buffer pieces without pre-concatenation. Source/design review and complete13977-byte boundary controls plus Motion64 full JS/Native pass. Consumer-only256 Native completes118,614,122/41a054; JS hits5s with exact76,842,036/2a0f5b38 prefix. Neither this result nor the preceding opposite backend outcome establishes comparative speed under contention. No1024, unchanged retry or adoption. Inspect actual JS lowering before further variants; backend-specific representation is only a research question, not a new compiler/API contract.

Fused quad-buffer6bc5479d removes repeated fitting-buffer updates while preserving the crossing path. Full18095-byte controls and Motion64/256 pass both stock backends; packetb4758d3b verifies971members/602objects/42guards with independent final retention review. Actual ordinary JS a32dd7e3 confirms one fitting Buffer construction, no intermediate Buffer rebuild. First1024 artifact reuse remainsINCOMPLETE5: JSnooutput, Nativeexact63,959,040/4da2663d prefix of444,624,902; stderr empty. No unchanged retry or adoption. Next current1024 CPU diagnostic targets the pre-output capture phase; no further source variant before fresh cost evidence.

Current fused1024 V8 diagnostic62922b6d reaches the15s diagnostic deadline with exact307,394,562/ceffe6de prefix; full13,454,337-byte log60d3f468 is retained, not complete-case coverage. Standard full-log processing01 and supported empty-native-symbol-provider successor02 each hit the unchanged5s offline cap before output. Native symbol suppression therefore does not resolve this attempt. Reviewed next analysis tests a caller-stack projection retaining every tick header/code event/time range, with explicit unfiltered sampled-PC scope; tiny full-versus-projected controls precede any real-log processing. No new ECS source variant is authorized by an unprocessed profile.

Offline-budget correction: SPEC77 and #21 bind Bend checker/runtime5s, codegen30s and Clang120s; prior5s Node profile-processing budgets were frozen diagnostic plan choices, not acceptance requirements. After two offline deadlines, source review permits a preserved30s offline-only full-raw-log successor. Tiny sampled-PC projection controls pass exact independent counts after correcting invalid CRLF fixture grammar; the prepared real projection remains unexecuted. Prefer the existing complete raw-log processor over further analysis infrastructure. Ordinary consumers and all performance targets remain unchanged.

Counted U32 digits0cb381cc removes four generated string-spread length expressions with exact integer thresholds; actual ordinary JSc291f828 confirms four renders/counts and unchanged reads/owners. Full20345-byte decimal-boundary/chunk controls and Motion64/256 pass both; packet6230f6e8 verifies967members/601objects/42guards. First1024 remainsINCOMPLETE5: JS0bytes, Nativeexact45,060,096/05fe90a5 prefix. One noisy attempt per variant cannot establish a regression or speedup. Next two complete256 collected-allocation diagnostics compare fused writer before/after the sole quad count change; no further source variant before feedback. FullrawV8 evidence81ef9a5b independently verifies1045members/675objects/32guards with scoped final review; all11200ticks accounted,4797JS/6403shared/2177GC(overlap), not a complete-case or exclusive-bottleneck claim.

Matched writer allocation pair77f6128c/9f954cc5 completes both full118,614,122-byte oracles. The122-file runtime closures differ only in quad-u32-doc. Sampled cumulative self estimates10,834,523,128→10,647,609,056 (-1.73% descriptive); capture5,779,107,104→5,615,247,888 and writer4,514,564,040→4,486,386,040. One profile each does not establish elapsed improvement/statistical confidence/exact heap or live RSS. Complete-wire count analysis finds4656 optional arrays with917256None/661764Some. Reviewed next hypothesis reuses three immutable framing Docs per array and directly builds the same two Some Joins; actual payload projection/restoration, Type ownership, fuel and errors remain unchanged. Source-operation opportunity2226816repeatedTextcalls+1985292Listcells is not a measured heap reduction.

Optional framing1243c7f3 reuses immutable boundary Docs while retaining arbitrary affine payload projection/restoration and the same Some Join tree. Ordinary controls and Motion64/256 pass both stock backends; six-pass packeta035cfad and first1024 negative packete3e0b529 pass independent retention review. Motion1024 remainsINCOMPLETE5: JS4,558,848/05f308f6 and Native85,389,312/a67d1ecd exact prefixes. Root confirms all79 imported ECS source files match current master/workspace after #73; actual GitHub #73 is closed. Allocation diagnostic4c551f25 completes the full118,614,122-byte oracle with profilef891f26e. Against reused matched digit-after15fcd5b2, sampled cumulative estimates10,647,609,056→10,168,724,888 (-4.50% descriptive); observation5,615,247,888→5,123,513,440, writer4,486,386,040→4,502,887,480. One sample each is neither a speedup nor statistical/exact/live-memory evidence. Allocation retention966b186f2 verifies1597members/688objects/7guards under manifestf09ac0d1; independent focused review passes, and root repeats the portable verifier without workload reruns. Investigate private chunk materialization using the existing typed IO mechanism; no new source variant accepted yet.

IO-pieces source1cd78550f and freeze68af7232a pass the reviewed eight-plan batch: complete IO146,951-byte independently authored Unicode/NUL/chunk/shared-Doc oracle, affine optional2,268-byte and quad20,345-byte controls, and Motion64 on both stock backends. Conditional artifact reuse passes full Motion256118,614,122 bytes on both; no recompilation or timing claim. New local sidecars are explicitly guarded; source mathematical foreign-code refusal is retained, not reported as proof PASS. Scope check: canonical FailedTxn uses current ECS bytes through explicit schedule/provision/dispatch; this does not establish performance of #73 ordinary automatic App entry. Reconcile that final-entry qualification before full-parity speed claims; bounded observer diagnostics remain source-bound.

IO-pieces10PASS retention2fd7f72d verifies1050members/663objects/76guards and passes independent final review. First1024 reuse867c9c94/beb72620 remainsINCOMPLETE5: JS0bytes; Native49,319,936/8a8c3887 exact prefix of444,624,902, separately streamed against oracle by root; stderr empty. No retry, adoption or speed claim. Stop adding observer variants before the ordinary-entry gap is addressed. Read-only mapping identifies affine Local Args/Out transport, executable existing reader registration and typed phase selection as the concrete bridge work; original IDs/order, transaction boundaries, failed B stop, all observations and fresh-world warmup/measured protocol must remain unchanged. Existing#73 bounded acceptance remains valid; these diagnostics do not establish its ordinary-entry performance.

IO1024 negative retentiona1f36bc9 passes1073members/681objects/8guards and independent final review; root repeats both ten-pass and negative portable verifiers without consumers/compilation. Ordinary-entry implementation now has separate owners: capture_carry_order owns core adapters/Entry setter in perf21/ordinary-existing-entry; uniform_u32_blocks owns consumer motion registration/schedule/system/program and necessary scenario/stream callsites in perf21/ordinary-failedtxn. Both start from current13206f035; old4bc has identical canonical consumer files but lacks five later ordinary-App module revisions, so old candidate branches are not the core basis. Reuse actual registrations/owners and complete historical wire; no wrapper re-registration or Data narrowing.

### 2026-10-18 — Recorded execution budgets and ordinary App checkpoint

The user authorized practical timeout increases, recorded in `docs/limits.md`.
Checker15s and consumer30s replace the earlier5s defaults for new plans.
The same frozen FailedTxn1024 artifacts complete eight full oracle-checked runs
within30s (JS13.78–18.01s; Native13.60–15.44s). Evidence-only commits
`c00761aff`, `1bcb9a3e6`, `93f55b13a` preserve the earlier failures and
complete outputs; independent final review and integrated portable verification
pass (1,225 members,802 referenced objects,56 guards). This establishes an
operational budget, not comparative ECS performance or adoption of private IO.

The ordinary App Motion64 successor separately passes complete38,459,780-byte
JS and Native oracles. Existing-registration authority and reached routing
controls, final review, integration and combined #28 remain pending. No new
Bend compilation or benchmark was needed to integrate the boundary archive.
CI39099716969 passed for the checker/budget change `5d31908d6`.

### 2026-10-18 — Ordinary existing-registration App delivered

Integrated at `88611af9e`: registration-derived composition/routing, persistent
ordinary App execution and the unchanged complete FailedTxn Motion64 observer.
JS/Native both match the full 38,459,780-byte oracle. Actual affine Local/token
normal/failure/refusal controls and a compiling library routing mutation pass
on both backends. Independent final Spec/Standards review reports no findings.
Portable packets pass: ordinary consumer 975/607/17; controls 739/548/50
(members/referenced objects/guards). The earlier pre-emission runner binding
error is retained; its successor adds the required expectedExit field.

The unchanged combined #28 gate passes on the merged source:
NO_CONFIRMED_REGRESSION, 20 pairs/backend, 123 successful commands and 110 complete
Workshop observations. Results are retained in
`experiments/public-api-usability/health-v2/existing-registration-controls/results/regression28/`.
Pinned Bend 2.0.35, Node 24.20.0 and Clang 19.1.7 were used. External contention
remains; this is the protected whole-process workload, not final full-parity
performance qualification. No claim of overall delivery acceleration is made.
Boundary integration CI 39100852005 passed. Ordinary Motion 256/1024, the second
schema, remaining workload adaptations and full #21 qualification remain open.

### 2026-10-18 — Ordinary Motion size coverage

The exact qualified ordinary Motion64 artifacts also pass complete independent
256 and 1024 oracles on JS and Native: 118,614,122 and 444,624,902 bytes respectively,
with empty stderr. No source change, emission, Native build or budget increase
was needed. Evidence integrated at `f93f8ecdb`; independent final review GO and
portable verification PASS (1,024 members, 646 objects, 16 guards). This extends
full-wire correctness only, not timing qualification. Matching earlier source
and oracle evidence was reused; #28 is unchanged because executable sources
did not change. Core/App integration CI 39101313702 passed both jobs. Health
ordinary entry and Dense adaptation are the two active implementation directions.

### 2026-10-18 — Ordinary Health64 delivered

Health source and full two-backend evidence integrated at `8cf421057`. Both
JS and Native match the unchanged 38,400,832-byte independent oracle with empty
stderr; all source/emission/build/consumer stages pass their original limits.
Portable verification passes (586 members, 546 objects, 23 guards); independent
final review GO confirms owner/reader preservation and complete observation.
The unchanged-core #28 receipt remains applicable: all 356 recorded source hashes
and the full core inventory match after integration. No duplicate benchmark or
generic authority matrix was run. Larger Health and the Dense ordinary path
are next; comparative performance remains unqualified.

### 2026-10-18 — Dense ordinary App and larger Health checkpoint

Dense Motion64 is integrated at `d037b06eb`: both backends match all 89,045
independent oracle bytes with empty stderr. Final source/evidence review GO;
portable packet PASS (944 members, 628 objects, 17 guards). A helper variable
shadowed the declared oracle hash during preparation; root inspection caught
this before any launch. The corrected helper uses semantic names and a final
post-pin-loop oracle assertion. Incorrect unexecuted drafts remain historical.

Health256 both backend passes are retained/integrated; unchanged Health64
artifacts produced all 118,451,494 oracle bytes. Independent Health1024 oracle
`105366bbc` reuses the qualified Python model and first reproduces the complete
64/256 reference streams. Health1024 JS passes all 444,047,554 bytes; Native
times out at 30 s with zero stdout and empty stderr. The timeout is preserved;
shared consumer 60 s is recorded in `docs/limits.md`. The owner identified an
unintended final-observer construction change (aggregate owner String versus
original chunks); a narrow restoration is being checked. It is not yet proved
to explain the timeout. Earlier successful outputs remain correctness evidence,
not proof of equivalent construction cost or comparative performance.

After Dense integration, all 356 protected #28 source hashes and the complete
core inventory still match; no duplicate benchmark was needed. Health
integration CI 39101829608 passed both jobs. No overall delivery speedup is
claimed.

### 2026-10-18 — Full ordinary FailedTxn/Dense and Sparse integration

FailedTxn now has complete ordinary-entry correctness evidence for both schemas
and all three sizes on JS and Native. The restored Health observer preserves
its original chunks. At the recorded common 180 s cap, Health1024 completes its
444,047,554-byte independent oracle in one fresh child per backend: JS 29.00 s,
Native 83.28 s. Peak child RSS is 2,933,828 / 5,225,128 KiB respectively, not
allocation volume. These full-output completion measurements do not establish
comparative ECS performance or prove the cause of earlier timeouts. The old
30/60 s failures remain unchanged. Source and packets were independently
reviewed and integrated through `7b4e0492d`; dated limits are in `docs/limits.md`.

Dense both schemas and all three sizes also pass full unchanged independent
oracles on both backends, with final review and retained packets integrated
through `80e0ad3ab`. Sparse Motion all three sizes and Health64 are accepted
through `d5fdcbb2c`; final review confirms three fresh postcommit scans,
postfilters and cumulative audit remain. Sparse Health256/1024 is next.
Lifecycle first Motion64 and Health64 pairs pass full LC2 oracles; their family
packet and larger cases remain pending, so this is not integration acceptance.

The 1+1 effect is concrete reuse: larger cases consume qualified first-size
artifacts, and the source-current #28 packet still matches all 356 hashes and
the complete core inventory after the merged consumer changes. No unchanged
Bend builds or comparative benchmark were repeated merely for documentation.
CI 39102381112 passed both jobs; successor 39104659229 is running on the pushed
integration `6eeb0ba5b`. Overall delivery acceleration and final #21 performance
qualification remain unproven. Two implementation directions remain active:
Sparse and Lifecycle; Readers follows completion of Sparse.

### 2026-10-18 — Lifecycle ordinary family accepted

Lifecycle is integrated through `97bd16f9a`: both schemas at 64/256/1024 on JS
and Native match all twelve complete independent LC2 oracles. Independent final
Spec/Standards review accepts the source and all retained plan/receipt/source/
artifact joins and66 guards. Portable verification passes1001 members/735
objects/66 guards. Four original Local registrations, all six named schedules,
both barriers, domain phases, genuine IO foreign-world provenance and existing
codec/chunk construction are preserved.

The unchanged generic routing mutant is reused only for its identical core
callsite and old microconsumer; no new Lifecycle-body mutation or universal
proof is claimed. Deterministic decoder controls are reused for exactly equal
complete LC2 streams. This avoids repeating matching evidence, not acceptance.
The protected #28 receipt still matches all356 hashes and the full core inventory.
Sparse integration CI39104843645 passed; full comparative timing remains open.

Readers is the remaining ordinary workload migration. Source-only support found
reusable historical Health source/models, plus a stale nested Motion oracle
metadata record. The owner preserves historical packages and must bind exact
framing and source provenance in the successor. Single-world correctness bytes
cannot qualify a future separate warmup/sample comparison. No candidate Bend
output is used to author oracle expectations; no new tracking layer was added.

### 2026-10-18 — All ordinary workload families integrated

Readers is accepted through `86cdfc00f`: both schemas at 64/256/1024 on JS/Native
match all twelve complete independent textual oracles. Independent final review
passes source, provenance, plan/receipt joins and84 guards. One portable verifier
passes1622 members/965 objects/84 guards. This completes the sixty ordinary
correctness cases across FailedTxn, Dense, Sparse, Lifecycle and Readers; it does
not complete the full performance/proof goal.

Motion Native initially stopped at the30 s emission deadline. The same source
completed emission, ordinary Clang-O3 build and full10,810,200-byte execution with
the recorded60 s successor. Earlier failure remains unchanged. Health preserves
String captures/append order; Motion preserves Doc captures/prepend order. The
oracle successor binds the correct10,810,200-byte selected stream and preserves
stale nested historical metadata explicitly. Two135-byte affine controls are
reused only for their exact63-source semantic closure/tools/artifacts; the old
unused checker-wrapper policy is not claimed current. The historical undo-counter
run retains its original String representation scope. No LC2 decoder was invented
for this plaintext family. No unchanged compiler/control matrix was rerun.

The combined #28 receipt still matches all356 source hashes and the complete core
inventory after integration; the new consumer sources do not change that core.
CI39105574088 passed the budget checkpoint; Reader integration CI is next.
Current code-generation budget60 s is recorded in `docs/limits.md`.

A bounded source audit narrows #21 diagnostics: logical Tx lists grow until their
terminal boundary in the reached workloads, so terminal observations can provide
logical peaks without append-by-append meters. Missing nonzero boundaries include
FailedTxn seed, Dense/Sparse seed and query loops, and Lifecycle command paths.
Canonical lifecycle stamps are distinct from the old experimental staged-mark
queue; logical lengths, stamp occupancy, allocation volume and RSS are separate.
The next two isolated implementations start with one DenseMotion64 diagnostic
consumer and one matched common-observer B1 method pilot. Existing prototypes do
not approve a new observer grammar, longer batch, uncertainty margin or full
comparative campaign. Four exact #62 law subjects remain pending human approval;
no proof against them has begun.


## 2026-10-18 — Actual Dense terminal transaction metrics

Integrated `08c28343c` after independent final Spec/Standards GO. Normal JS and
Native preserve the complete 89,045-byte canonical oracle and match all 65 actual
terminal transaction samples: seed undo/commands/events = 64/64/0; each of the
64 query loops = 128/0/0. Owner-preserving traversal observes before finish.
A compiling reporter-only undo+1 defect keeps canonical output unchanged and is
rejected by the metric oracle on both backends. The existing collector is unchanged.

The [portable packet](../../experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/tx-peaks-v1/results/ordinary01/RETENTION.json)
passes 1,024 members, 679 objects and 46 guards, including produced sidefile paths,
bytes, hashes and verifier results. This is DenseMotion64 logical-list occupancy,
not allocation/RSS, lifecycle stamps, other workloads or universal peak proof.
The unchanged #28 receipt still matches all 356 sources and the full core inventory;
its existing scoped result is reused. No limits changed. Matched timing pilot,
remaining workload metrics and final comparative qualification remain open.


## 2026-10-18 — First matched-method pilot integrated

Integrated `0dd014f1d` after independent final review. TS, JS and Native each
complete one same-process warmup and fresh sample. All six actual 5,448-value
common tuples match the independently sealed model; full canonical records remain
checked. The [packet](../../experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/matched-timing-v1/runtime-v1/actual-attempt01/RETENTION.json)
passes 627 members, 580 objects and 21 guards, including raw clock sidefile joins.
The existing runner and public ECS are unchanged. Protected #28 remains exact
for all 356 sources/full core inventory. Prior diagnostic integration CI39108569102
passed both functional and runnable-example jobs.

Raw warmup/sample clocks are JS 74/30 ms, Native 19/19 ms, TS 7.857237/4.175996 ms.
These are one method pilot under external CPU contention, not qualified ratios,
speed rankings, precision or final performance acceptance. Full repeated comparison,
resolution/batch approval and clean-child RSS remain open. Next: CPU and allocation
profiles of the same qualified JS artifact with unchanged full-output validation.
No new limits or protocol tolerances were introduced.


## 2026-10-18 — Dense transaction metrics cover both schemas and all sizes

Integrated `41d4d2a6f` after independent final review. Ten new complete-output
JS/Native cases join the original Motion64 pair: both schemas at 64/256/1024 now
match independent actual-metric oracles. Seed undo/commands/events are N/N/0;
each of 64 query transactions is 2N/0/0. Arbitrary affine owners, Health declarations,
payloads and String observations are preserved. The unchanged reporting seam
reuses the original compiling counter defect with exact source/dependency binding.

The [family packet](../../experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/tx-peaks-v1/results/family01/RETENTION.json)
passes 1,171 members, 791 objects and 79 guards. Scope remains terminal logical
list counts, excluding allocation/RSS, lifecycle stamps and universal peaks.
Shared core is unchanged; all 356 protected #28 sources/full inventory remain
exact. Prior checkpoint CI39109064236 passed. Next: equivalent Sparse observations
and the already-admitted CPU/allocation profiles of unchanged qualified JS.
No limits or acceptance criteria changed.


## 2026-10-18 — Sparse metrics and same-artifact profiles integrated

Sparse `7e26c472a` passes all 12 complete canonical/metric cases, with independent
final review. Actual seed undo/commands/events are N/N/0; 64 query transactions
each contain 2*ceil(N/8)/0/0. Three fresh postcommit scans, filters, payloads,
affine owners and cumulative observations remain intact. The
[packet](../../experiments/s-perf/canonical-api-v1/sparse-runtime-v1/diagnostics/tx-peaks-v1/results/family01/RETENTION.json)
passes 1,321 members, 805 objects and 102 guards; unchanged reporting code reuses
the pinned compiling counter defect.

Profiles `3433e78c5` use the identical qualified JS artifact and preserve complete
outputs and all four actual common tuples. The
[packet](../../experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/matched-timing-v1/profiles-v1/runtime-v1/actual-attempt01/RETENTION.json)
passes 632 members, 587 objects and 14 guards, accepted by independent review.
CPU: 855 samples; allocation sampling estimate: 574,161,672 bytes. These are
whole-process instrumented diagnostics, not exact allocation, live heap, RSS,
timed-region costs or speed comparisons. Raw time deltas and phase ambiguity are
retained. Generated JS confirms repeated declaration construction in actual
per-row paths. The independently reviewed isolated candidate `8f7c658e5` consumes
one declaration in `ordinary-system.plan`; its generic Type source check passes.
It is not adopted in master; full consumers, authority checks and before/after
profiles remain required. No speedup is established.

CI39109350865 failed only on a new EOF blank line in the Dense Health readable
fixture. `c72de1d47` removes exactly one final LF; independent applicability review
passes. Original producer and frozen archived source remain unchanged:
`af373e4ade371ca1143a0ab4310be93f9494f3d62fe6131719adc9e7adde6cc4`.
The normalized readable copy is
`fbd29b494009c51425607b2fb99b9b016e67312258c4aafd8f6e0c1b4d712569`;
old receipt pins are not claimed equal to it. The exact CI source/whitespace check
now passes locally. No Bend recompile was needed for the EOF-only correction.
Protected #28 still matches all 356 sources and full core inventory. Existing
limits, contracts, proof approvals and final performance gates remain unchanged.


## 2026-10-18 — Single-evaluation query plans integrated

`caa2811dc` integrates ordinary and observable query-plan extraction without
changing public signatures or affine ownership. The reached normal, arbitrary
Type and failure consumers pass on JS/Native; five intended authority refusals
and independent final review pass. Evidence `30e547948` preserves two actual
source epochs: earlier regular-plan profiles and the amended observable-plan
controls. Earlier unaffected sanity cases are not credited as affected checks.

Whole-process sampled allocation estimates are 574,161,672 before and
408,790,136 bytes after. These single instrumented observations under contention
are neither exact allocations nor a qualified speedup. Full #21 qualification
remains open.

Fresh combined #28 `2e82d6fea` retains 123 completed commands, 110 full outputs
and 40 pairs. Verdict: NO_CONFIRMED_REGRESSION. JS has 14/20 slower pairs
(p=0.057659, median ratio 1.074284); Native has 9/20
(p=0.748278, median ratio 0.981523). This protects Workshop only; its runtime
does not import the changed query-plan helper. The retained receipt matches
all 356 current sources and the full core inventory.
[Receipt and archive manifest](../../experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/matched-timing-v1/plan-once-v1/results/regression28/MANIFEST.json).
CI39112377804 passed both functional checks and runnable examples on
`dc5bfd392`. Existing limits and final JS/TS and Native/TS targets are unchanged.


## 2026-10-18 — FailedTxn actual seed metrics integrated

`4cf5d2238` integrates the twelve-case FailedTxn metric family after independent
final Spec/Standards review. Both schemas at 64/256/1024 pass full JS/Native
canonical output, two actual pre-finish seed samples and a componentwise maximum
join of reached callback facts. Repeated snapshots are not summed. Combined
logical undo/commands/events maxima are N/N/1. The
[packet](../../experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/diagnostics/tx-peaks-v1/results/family01/RETENTION.json)
passes 1,485 members, 903 objects and 138 guards. Existing canonical archives
are reused by exact content hash. No new runtime, compiler or benchmark limit
was needed.

Frozen receipts retain their 3433 source epoch. The explicit
[applicability record](../../experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/diagnostics/tx-peaks-v1/checks/CORE-APPLICABILITY.json)
traces unchanged Local, mixed-reader, raw disposal and Inspector paths and
separately binds the current query-plan controls. The reviewer accepted this
reuse without relabeling old receipts as current-source executions. Protected
#28 still binds all 356 sources/full core inventory after integration; the exact
CI source check passes. CI39113003771 passed both jobs on `9cab47ca6`.

Readers already samples its reached seed. Lifecycle still lacks actual active
Tx observations at seed, foreign seed, reserve and disposal. Its Select path
creates and rolls back a real Tx: read-only zero applicability must be explicit,
not described as absence of a transaction. No allocation, RSS, universal peak
or full #21 performance qualification follows from these terminal metrics.


## 2026-10-18 — Protected #28 applicability to tracked master

The immutable receipt `f6e4cfb8b748e81b63fe2a81f1f13e02d77edbb341946920af68412165b97110`
records the actual 356-file workspace. Independent source review compared it
with published `9cab47ca6`: all 355 tracked recorded paths are byte-identical.
The sole extra is foreign, untracked work:
`src/ecs/ordinary-execution-trace.bend`, SHA256
`961967e42485d2774ba71055bd12541402a2e7cc9f8ec9c4c5beec572d7afdc7`.
Its bytes are archived; the file remains untouched and is not published here.

The reviewer reconstructed the actual retained timing entry's recursive import
closure: 29 files, no unresolved imports, unchanged bytes, no dependency on the
extra file. Scoped runtime reuse therefore applies to tracked master. This is
not a clean-checkout replay or strict 356-file inventory equivalence: the strict
checker would report the extra path absent from that checkout. No frozen
receipt/archive was rewritten and no benchmark was repeated. Evidence remains
in the existing [manifest](../../experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/matched-timing-v1/plan-once-v1/results/regression28/MANIFEST.json).

CI39114145854 passed both jobs on `75c739e75`; no unchanged benchmark rerun was needed for this provenance correction.


## 2026-10-18 — #62 proposal delivery acceptance

The governing ticket requires presentation of exact law candidates, not approval
or proof acceptance. Presentation already occurred in its English
[delivery report](https://github.com/dearlordylord/bendvy/issues/62#issuecomment-6231034442).
Independent completion audit confirms all four proposal/falsification criteria
are met and the full 13-file law-source closure is byte-identical to reviewed
`291704538`. Existing normal JS/Native, four compiling JS defects, 519 bindings
and CI evidence apply without a backend or benchmark rerun.

The presentation checkbox is corrected. The four subjects remain UNAPPROVED;
no proof is accepted or attempted. Existing seven subjects and two arithmetic
approvals remain distinct from the 22 legacy and 11 separate metadata drafts.
Deferred proof/refinement stays explicitly under #1 until exact approval and
a separately scoped slice. No acceptance criterion or approval requirement
changes. This resolves proposal delivery, not universal ECS refinement.


## 2026-10-18 — Lifecycle and Readers terminal diagnostics integrated

`e3d1a8c57` integrates Lifecycle after independent final review: all 12 normal
schema/size/backend cases and two compiling reporter defects pass their intended
checks while retaining complete LC2 output. Each normal case has 130 grouped
actual samples: main/foreign seeds, 64 reserves and 64 disposals. Terminal
undo/commands/custom-events maxima are N/N/0. Group order is not chronological;
real read-only Select transactions retain explicit zero source applicability.
The [packet](../../experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/diagnostics/tx-peaks-v1/results/family01/RETENTION.json)
passes 1,111 members, 791 objects and 125 guards. The undo+1 counter expectation
was derived post-run from the presealed normal model and prefrozen mutation;
its provenance is explicit, not retroactively called presealed.

`aa10c246d` integrates Readers after independent final review: all 12 normal
cases and two compiling reporter controls pass, preserving complete original
streams. The 277 actual samples combine 193 existing domain facts with 84 real
reader-callback Tx traversals. Before/prepared-running/after reader states,
cursors, Local arrays, barriers and owners stay intact. Maxima are N/N/1.
The [packet](../../experiments/s-perf/canonical-api-v1/readers-runtime-v1/diagnostics/tx-peaks-v1/results/family02/RETENTION.json)
passes 1,336 members, 915 objects and 131 guards. Counter controls preserve full
canonical output, reject normal metrics and exactly match the presealed wrong
reporter oracle.

The first Readers 30 s offline retention timeout is preserved. User-authorized
120 s successors are recorded in [limits](../limits.md). The reviewed successor
reuses already hash-verified identical pin keys; different source versions and
all bindings remain checked. Retention completed within 120 s without an elapsed
record. Portable verification measured 4.39 s. An unavailable optional external
time wrapper failed before verification; that launcher diagnostic is retained.
No backend replay or isolated performance claim follows from this repair.

This batch changes private diagnostics, not production core. Current workspace
#28 source binding still passes; tracked-master applicability retains the explicit
355-file/unused archived-file exception above. Exact CI source checks pass.
Combined CI remains to be checked. Actual after-append/transfer/discard records
remain a #21 gate: source research found real command reset/replay in
`bundle-batch.stage`, so terminal monotonicity must not be generalized. Stamps,
RSS, full measurement protocols and product speed qualification remain separate.

#62 is now closed as proposal/falsification delivery after CI 39114729049 passed
and its English completion report was posted. The four laws remain unapproved;
future proof/refinement is still gated under #1.


## Health B1 complete-observation method — 2026-10-18

Integrated `b849f9012` (worker `efd979353`) after independent launch and final reviews. The ordinary Health64 consumer passed on JS, Native and TS: complete Bend streams 226,886 bytes and TS record 90,224 bytes, both complete 5,512-value tuples per role, six raw clock sidecars. Portable packet [actual-attempt01](../../experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/matched-timing-v1/health-v1/runtime-v1/actual-attempt01/RETENTION.json): 610 members, 572 objects, 21 guards; manifest `8ad0eed31de8301fd1af8cbb1f30dabd40b4fbab4a5f067046ce5260be57e9ef`.

Independent gold preceded subject authoring; all original workload operations and full-field observations remain. Sixteen finite model sensitivity controls are not compiling mutants. Prelaunch environment/load snapshot is unavailable; no reconstruction, timing ratio, precision or RSS qualification is claimed. Offline verifier 1.85 seconds is not consumer runtime. Existing budgets sufficed; no backend reruns or new checks were added. Product core is unchanged, so the existing source-bound #28 evidence remains applicable. Previous combined CI39116724863 passed; new combined CI follows this integration.

Actual delivery effect: the existing collector and byte-identical generic validator handled all three roles; one batched launch review and one final review sufficed. This demonstrates reuse on this delivery, not a measured overall delivery speedup.


## Actual Dense Tx boundaries — 2026-10-18

Integrated `024249aa8` (worker `21f9ec761`) after independent launch, changed-portion and final reviews. Private sixth-field metering leaves product core and authored trace behavior unchanged. DenseMotion64 now retains 65 actual seed/query Tx reports, every reached append, owner-preserving terminal list traversal, actual begin/end World ticks and completion. Append tick is explicitly unavailable. Full ordinary consumer output remains 89,045 bytes. Two compiling missing-resource-hook controls preserve that output and are rejected by normal metrics while matching the separately sealed counter-model.

The original JS collector rejection is preserved: its oracle named the wrong resource-write path. Source tracing justified changing exactly 4,096 site labels, without changing counts/order/context. Separate validation reuses the immutable JS output against that post-observation correction; Native02 passes the corrected pre-execution oracle. Original Native01 was never launched. [Packet](../../experiments/s-perf/current-tx-boundaries-v1/results/dense64-first01/RETENTION.json): 1,176 members, 741 objects, 52 guards; manifest `019b7ea0dd1db8d47866997c7f8c288b916538b262cf8afae25d56f39b826708`.

Mixed append, command transfer/reset/replay, raw discard, remaining counter controls and families remain open; no full #21, marks, RSS or universal-peak claim. Existing limits sufficed. Integration preserves two frozen owner-handoff copies through exact-path blank-EOF attributes, independently reviewed; committed Python/whitespace checks pass. No product-core change requires a new #28 run. Previous combined CI39117879624 passed; next combined CI includes this slice. Delivery reused actual JS output instead of rerunning the unchanged backend after the model correction; no general delivery-time improvement is measured.


## Sparse Motion B1 complete-observation method — 2026-10-18

Integrated `37fdb5e59` (worker `7ecd0182b`) after independent launch, repair and final reviews. JS/Native match the full 1,071,136-byte record; TS matches 695,984 bytes. All six complete 35,061-value tuples and raw clock sidecars pass the unchanged generic validator. [Index](../../experiments/s-perf/canonical-api-v1/sparse-runtime-v1/diagnostics/matched-timing-v1/runtime-v1/actual-attempt02/INDEX.json) binds current packet `077eeb62bf6d31037fd595b7083cd3af31cf706467da9d8cc8672bec274082d7` (627 members, 580 objects, 21 guards) and historical packet `589e558fff187ac0d32e4bde5ae3c4a36efb0ce1721fe8581e5a33c8c633d091` (597 members, 562 objects, 11 guards).

The first JS failure is retained. A single catch-stack diagnostic confirmed recursive List.append overflow. Private tail-safe concatenation fixes it; exact formatting also uses a tail-safe traversal as prevention, not as an observed fault cause. Full fields and gold remain unchanged. Historical codec bytes are recovered from their exact Git object and explicitly distinguished from current filesystem bytes. Old Native/TS drafts were unexecuted.

Original Bend three full scans/postfilters and TS three original queries are preserved. Common rows use an actual no-intervening-writes snapshot correspondence; score namespace mapping is reversible, with raw namespace/scores/cumulative in full records. These strategies are not described as identical internal work. Finite sensitivity controls remain model-only. No ratios, precision, RSS or full qualification is claimed. Existing limits sufficed; no stack raise, product-core edit or new #28 run. Combined CI39118905686 passed before this integration; next CI includes it. Delivery fixed a specific generated-code blocker and reused the existing collector/validator; overall delivery acceleration remains unmeasured.


## Sparse Health B1 complete-observation method — 2026-10-18

Integrated `2172cf917` (worker `54b052e14`) after independent launch and final reviews. JS/Native match all 1,115,471 bytes; TS matches 736,456 bytes. The unchanged validator matches six complete 37,629-value tuples and clock sidecars. [Packet](../../experiments/s-perf/canonical-api-v1/sparse-runtime-v1/diagnostics/matched-timing-v1/health-v1/runtime-v1/actual-attempt01/RETENTION.json): 612 members, 574 objects, 21 guards; manifest `d0a1b9f765e75fdce02476a7fd7ff9fd6c8b17e48911ec4a6347af537e922cd5`.

All Health payload fields, raw scans/scores/cumulative, ledger, audits and statuses remain observed; namespace correspondence is reversible and original query-strategy asymmetry explicit. Finite sensitivity controls are model-only. No statistical speed, precision or RSS qualification; limits unchanged. Existing collector, tail-safe codec and validator were reused without backend reruns. Product core is unchanged; #28 reuse remains scoped as above. Combined CI39119222929 passed before this integration; next CI includes it.


## Mixed transfer/reset and accounting controls — 2026-10-18

Integrated `4f7eb12fd` (worker `7066e70fe`) after independent launch and final reviews. Normal JS/Native match all 2,446 canonical bytes and 2,899 metric bytes. Real ordinaryApp execution preserves affine Local/packet owners, stages payload100 then200, publishes nonpalindromic events[7,7,9], resets/replays commands, rolls back failure and observes actual zero-selector discard. Physical allocator, generations, columns and stamps remain observed; stamp peak metrics are not qualified.

All six reached accounting controls are validated: omitted reset, wrong event category and corrupted cached undo, each on JS/Native. Business output is unchanged; normal metrics reject and exact source-derived wrong models match. Original omitted-reset JS collector remains INCOMPLETE because the old wrong-gold file lacked final LF. New files add only LF; separate immutable-output revalidation passes without a JS backend rerun. Five original draft plans remain unexecuted. [Packet](../../experiments/s-perf/current-tx-boundaries-v1/mixed-reset-v1/results/first01/RETENTION.json): 1,779 members, 872 objects, 110 guards; manifest `25354f80e95b47fc388cb414a214d7fd4a4adf0488872c38a6c71a19ea873a66`.

Source audit of the five normal workloads at `1dd16e12c` (unchanged product source) finds only Lifecycle's actual `domain.select -> query-contract.scan/unselect` raw-discard path, with read-only empty journals. `query.read_world`, relation-query.finish and owned-decode abort are not invoked by these workload stories. Their global behavior is not proved; unrelated new decode fixtures are not required for this workload-specific metric gate. Nonempty workload settlement runs through Cmd.tx_finish/transaction.finish_world, especially FailedTxn B failure/retry. Next instrumentation covers those actual five-workload paths and Lifecycle's actual zero witness.

Product core is unchanged. All 356 retained #28 workspace source pins were rehashed and match; the previously reviewed foreign/untracked trace exception remains explicit. No benchmark rerun, new limit or numerical qualification is claimed. Existing committed-source checks pass. CI39119734918 passed before this integration; next CI includes the mixed slice. Delivery reused one immutable failing-backend output after a framing-only model repair; overall delivery acceleration remains unmeasured.

## FailedTxn method and actual transaction boundaries — 2026-10-18

Independent final reviews accepted two private slices, integrated at `bbb997334` and `336677724`. The complete Motion64 method passes JS/Native (69,682,490 bytes each) and TS (36,985,248 bytes), with six full 3,504,864-value tuples. Portable verification: 732 members, 644 objects, 21 guards; manifest `9c6aec788ed736f7b71ab8be04b539e29fea16f5cc86f1a5ad37f23a8b3bc87a`. Raw clocks and whole-process TS RSS remain observations, without speed, precision or memory qualification. Additional projections and different actor-map construction remain explicit.

The execution did not freeze the complete ancestor Node package/configuration scope. The child environment is explicitly bound by the plan: the pinned runner passes that mapping directly to `Popen(env=...)`, so absent `NODE_OPTIONS` and `NODE_PATH` are cleared rather than inherited. Full-gold correctness is established for the actual runs; complete package-scope isolation and comparative qualification are not. A future comparative cohort must freeze the operative package scope and retain the explicit child environment. This corrects the earlier, overly broad environment limitation; existing receipts remain unchanged.

Actual FailedTxn Motion64 boundary diagnostics pass both stock backends with the original 38,459,780-byte canonical output and 774 complete transaction reports. Both reached tick-only controls preserve that output, reject normal metrics and match the independent wrong model. Returned World witnesses precede reader commit/synchronization. Portable verification: 1,617 members, 825 objects, 52 guards; manifest `149f1aa0221ac5908c676cdc23a9b0be7d996d9083243bdbbf58249e44dc3ca9`. Other families, schemas, sizes and Lifecycle's zero-journal discard remain open.

Delivery effect: the first full consumer pairs ran before extra controls; existing runners and source-bound accounting controls were reused. One independent final review per slice completed; packaging required no backend reruns. No delivery-speed improvement is measured. All 356 retained #28 source pins still match after integration; the previously documented foreign/untracked source exception remains. Existing scoped regression evidence is reused, without a new performance claim. Limits were unchanged. CI for the combined delivery follows this checkpoint.

## FailedTxn Health method and transaction boundaries — 2026-10-18

Independent final reviews accepted the Health64 method (`e7ac196c2`) and actual boundary diagnostics (`2e66dca54`). Method JS/Native match all 70,498,700 bytes each; TS matches 38,129,202 bytes. All six complete 3,608,414-value tuples match the presealed model. Portable verification: 695 members, 645 objects, 21 guards; manifest `e815b24a814b256b5bf3823f87a7fdec52169faa9487b1b2de56d0eb1792fa75`. Original Health String captures and chunked final output remain intact. Generated evaluation order does not establish when V8 flattens ropes. Closest Node package configurations, reference source membership and the explicit child environment are bound for these new runs. Raw clocks and whole-process TS RSS do not qualify speed, precision or memory.

The two normal boundary backends preserve the complete 38,400,832-byte canonical output and independently match all 774 transaction reports. The unchanged generic accounting/settlement controls are reused through five exact source joins to the separately accepted Motion prerequisite; this is not a new Health mutant campaign or self-contained verification of that prerequisite. JS02 pins CommonJS configuration; prepared JS01 remains unexecuted. Portable verification: 1,373 members, 798 objects, 23 guards; manifest `71081a921d4d823365ad37926cba6c92d07e6601c4444efc0ed540671dbcfe67`.

Delivery reused the existing collectors, validators and qualified controls after the first full consumers, without backend reruns for packaging. Both implementation owners delivered through final review and integration; no delivery-speed improvement is measured. All 356 retained #28 source pins still match, with the existing foreign/untracked source exception. Public runtime sources and limits are unchanged; scoped regression evidence is reused. Other workload boundaries, schemas/sizes, Lifecycle discard, remaining methods and comparative qualification remain open. Combined CI follows this checkpoint.

## Lifecycle Motion64 method — 2026-10-18

Integrated `c9548df27` after independent final review. JS/Native each match all 26,249,413 oracle bytes; TS matches 17,437,766. Six shared 2,044,440-value tuples and six own-role/world foreign tuples pass; foreign tuples intentionally differ. Portable packet: 705 members, 641 objects, 21 guards, manifest `b18010dae8ff22d5b6724dabe62a66effc23e8e54678931a2a1136cca95801dd`. Original six-stage work, affine owners and Rope output are preserved. Added TS observer work and genuine foreign lookup differences remain explicit qualification constraints.

Existing runners completed the first full consumers before finite fixture controls. Packaging required no backend replay; one final review accepted the slice. No delivery-speed improvement or ECS speed/RSS qualification is claimed. All 356 protected #28 source pins still match, with the existing foreign/untracked exception; scoped regression evidence is reused. Limits are unchanged. Actual Lifecycle boundaries are a separate in-progress delivery; Readers method and full comparative qualification remain open.

## Lifecycle Motion64 actual boundaries — 2026-10-18

Integrated `3f8d3de4d` after independent final review. Both normal backends retain the complete 3,848,488-byte LC2 output and match 4,226 independently derived reports, including 4,096 actual zero-journal unselect rollbacks. A reached reporting defect changes only their `committed:null` to `false`: both compiled controls preserve canonical output, reject normal metrics and match the exact countermodel. Reports retain actual rollback-returned worlds and grouped owner-local ordering. The structural overlay is distinguished from immutable core dependencies; prior generic controls remain an explicit external prerequisite.

Portable verification passes 1,503 members, 879 objects and 52 guards; manifest `ade519749f8b1f0bf0733c9e78747b5f4d516b92fb1ee879a8ef22f81b4aed5d`. First full consumers preceded the narrow additional control; existing runners and unchanged generic controls were reused. Packaging required no backend reruns. No delivery-speed improvement is measured. All 356 protected #28 pins still match after both Lifecycle integrations, with the existing foreign/untracked exception. Limits and public runtime are unchanged. Wider workload/schema/size, memory and comparative qualification remain open; Readers method preparation is the next direction.

## Readers Motion64 method — 2026-10-18

Integrated `ef277835a` after independent final review. JS/Native each match all 30,103,222 oracle bytes; TS matches 8,945,548. Six complete 946,819-value tuples agree. Portable verification: 745 members, 661 objects, 21 guards; manifest `c615572f3e9b70fce95b322ffd34d9760784e5a5b5a448bdd3943a27b4530eb8`. Original 192 Local calls, 193 transaction facts, 84 reader captures and terminal capture remain intact. A source audit corrected unsupported TS removed/despawned lag flags before any backend run; the unexecuted draft is retained. Equal common tuples do not qualify equal observer cost or speed; actual Bend private cursor/lag state remains in its full role stream.

First complete consumers preceded 44 finite model-only controls. Existing collectors/validators and one final review were reused; packaging required no backend retry. No delivery-speed improvement is measured. All 356 protected #28 source pins still match, including the existing foreign/untracked exception; scoped evidence is reused. Limits and public runtime are unchanged. Lifecycle combined CI39128295053 passed. Readers actual-boundary delivery, remaining Health methods, broader cases, comparative protocol, rotations and qualified memory/performance remain open.

## Health Lifecycle method and Readers boundaries — 2026-10-18

Integrated Health Lifecycle method `ab47f1909` after independent final review. JS/Native each match all 27,037,861 oracle bytes; TS matches 18,117,576. Six shared 2,123,109-value tuples and six own-role/world foreign tuples pass. Portable: 685 members, 634 objects, 21 guards; manifest `39ba12e8b8f0b8a0871b141875649f9b50ea8f520d521432b2721966a14720b6`. Full Health payload fields, original 384 Local/schedule captures, affine owners and Rope output are preserved. Forty-two controls are model fixtures only; equal shared records do not qualify equal observer cost, foreign footprint, speed or clean RSS.

Integrated actual Readers boundaries `607a3a96b` after independent final review. Both normal backends preserve the complete 10,810,200-byte original output and match 277 reports: 193 domain and 84 real empty callback transactions, including returned World before reader commit/sync. Portable: 1,444 members, 831 objects, 33 guards; manifest `9ba18fdf93561b1b414c07b04d8a89c748e64a2d16202f5ffa50fcbd987b84fc`. Initial JS invalid JSON remains rejected; Native01 remains unexecuted. The formatter repair and independently source-derived post-observation oracle amendment are separate: exactly 128 observed-disposal site labels changed, with all other fields and old gold retained. No transformed historical output is accepted. Four exact source joins reuse generic controls as an explicit external prerequisite.

First complete consumers preceded additional checks. Routine source ports reused the reviewed execution path and one final review, without another launch admission. No delivery-speed improvement is measured. All 356 protected #28 pins match after both integrations, with the existing foreign/untracked exception; scoped regression evidence is reused. Limits and public runtime are unchanged. Readers method CI39129364833 passed; combined CI follows. Remaining Health methods/boundaries, broader scenarios, comparative protocol, rotations and qualified performance/memory stay open.

## Health Readers method and Health Lifecycle boundaries — 2026-10-18

Health Readers method integrated `068211677` after independent final review: complete JS/Native streams each 24,939,472 bytes, TS 9,271,522; six 982,498-value tuples pass. Portable: 695 members, 627 objects, 21 guards; manifest `783898054ca99d223d5cb172537ab5958d655f637cd0837485d51f099e1038d8`. Original String captures, append chronology, 192 Local calls, 193 transaction facts and 84 reader captures are retained. The immutable plan has an inherited checker-label error naming pilot01; authoritative frozen metadata points to qualifying pilot02, both logs remain, and the packet explicitly rejects any pilot01 pass claim. No source or backend replay was needed for that annotation.

Actual Health Lifecycle boundaries integrated `c9cc34fb9` after independent final review: both backends preserve the full 3,904,540-byte Health LC2 output and match all 4,226 independently Health-derived reports. Portable: 1,403 members, 812 objects, 23 guards; manifest `8219f5375e79b749a0381946a0cb281fc6d1fd468ef8d350a8c45232df530006`. Generic/null controls are reused through exact source/body joins as an explicit external prerequisite. Early helper-file staging and final pre-execution gold sealing are distinguished; no history rewrite or false single-commit provenance claim was made.

Full consumers preceded additional checks; existing runners and one final review per slice were reused. No delivery-speed improvement is measured. All 356 protected #28 source pins still match, including the existing foreign/untracked exception; scoped evidence is reused. Limits and public runtime are unchanged. Prior combined CI39130631948 passed; the new combined CI follows. The historical occupancy documents now distinguish absent Tx mark journals from persistent added/changed metadata and scoped raw-discard reachability. Health Readers boundaries and per-column metadata occupancy are active; wider cases, aggregate peaks, comparative protocol, rotations, clean RSS and final product targets remain open.


## Health Readers boundary delivery — 2026-10-18

Integrated `9a0755d06` after independent final review of `649c576ff`. JS and Native preserve the complete 8,077,591-byte original Health String output and match all 277 independently derived boundary reports. Portable verification passes: 1,381 members, 793 objects, 23 guards; manifest `ffa04e7cb1ec887a01b669c9d7916380387a640a44d0e21513e33f3401fa4314`. Exact generic-control source joins remain an external prerequisite. Both backends passed on the first attempt. All 356 protected #28 source pins match, retaining the existing foreign/untracked exception. CI39132447354 passed for the preceding integrated checkpoint; successor CI follows.

This delivery reused the existing collector, oracle and one final review. No backend replay was needed for packaging, and no delivery-speed improvement is measured. Persistent per-column metadata observation is the remaining active implementation direction; wider workloads, aggregate peaks, clean RSS and final comparative qualification remain open. The execution-limit history now explicitly records each increase before its successor and its eventual outcome.


## Clean-child RSS method pilot — 2026-10-18

Integrated `18a0a4470` after independent final review of `393dd072a`. Both ordinary DenseMotion64 JS/Native invocations preserve the complete 226,988-byte oracle, fresh clock sidecars and clean-child RSS records. Six finite parent-floor controls and seven sidecar refusal/positive controls pass. Portable verification: 789 members, 605 objects, 36 guards; manifest `aacb1c9e36c1789948e8e39044ff11020e02b9691454783b0bfd3f262f0c7bfe`.

The existing qualified epoch8f consumer artifacts were reused, with exact historical source recovery and independently checked import-only guard rehoming. Only the small unchanged launcher and allocation-control payload were compiled. This is scoped historical-source evidence, not a byte-current whole-core run. The controls receipt's generic consumer status is not canonical-output proof; the two ordinary invocations independently supply that proof. RSS includes child startup, warmup, setup, observations and output. No seven-sample memory comparison, allocation count or product performance claim follows.

First complete consumers preceded finite controls. One batch launch review covered the new sidecar verifier and generated-artifact prerequisites; exact prerequisite joins were checked without a second admission. One final review accepted the combined result. No delivery-speed improvement is measured. All 356 protected #28 source pins match, retaining the archived-extra exception; matching scoped evidence is reused. CI39133630124 passed for the preceding checkpoint; successor CI follows. Metadata ownership/rollback controls are now running; full comparative qualification remains open.


## Persistent metadata observer delivery — 2026-10-18

Integrated `288cb63ef` after independent final review of `84856b827`. Six complete JS/Native subjects pass: ordinary ReadersMotion64 preserves all 10,810,200 canonical bytes and the independent 67,575-byte trace; eight affine/metadata fixtures match all 4,981 bytes; the reached reporter defect preserves canonical output while rejecting normal metrics and matching the independent 67,581-byte counter gold. Portable verification passes: 1,790 members, 1,155 objects, 69 guards; manifest `4520aae4ff87c6adc22cd31adca477205e5b35329cfb8f09848b4608ae7b1e7c`.

The 366 recorded states support per-column maxima over completed hooks only. Shape occurrences are not unique allocations; evacuated current/handoff/history owner storage and aggregate-world peaks are excluded. Fixtures return arbitrary affine payloads, invoke their owned-array closures once, retain Prepared wrappers/owners and exercise actual component transaction failure. Two earlier plans remain unexecuted; exact historical source bytes are retained separately. No universal law, dependency, public API or performance criterion changed.

Ordinary consumers preceded focused controls. Existing runners, bounded retention and one final review were reused. No delivery-speed improvement is measured. All 356 protected #28 pins still match, including the archived-extra exception; matching scoped evidence is reused. CI39135035663 passed for the preceding checkpoint; successor CI follows. Current #24 work reconciles the historical catalogue with actual App execution, reusing matching evidence and addressing genuinely uncovered callbacks/failure routes. Full comparative timing, larger diagnostic coverage and qualified memory remain open.


CI39135833737 passed examples but rejected the integrated whitespace range: the byte-identical private `owner-handoff.bend` copy has its production blank line at EOF. A path-specific `.gitattributes` entry preserves those frozen source bytes, following the existing archive-copy policy. The full failed source/whitespace command then passed locally. Final-staged whitespace alone had missed this earlier source commit; integration now checks the complete delivery range. No backend or oracle replay is needed for this packaging correction.


## Current App rollback and Sparse boundary batch — 2026-10-18

Current App capture failure/retry evidence integrated at `b2a368628` after final review of `26c520e98`. Both normal backend streams match the full 3,401-byte oracle; three authority refusals hit intended diagnostics. Both private inverse-order defects match the independent 3,403-byte counter oracle and reject the normal result, exposing intermediate component values/stamps after failure. Portable: 784 members, 573 objects, 47 guards; manifest `4305bd8c376f26bb3d4c7d1e06da85e2817151cf674d2b65e7d957bbbb82668d`. This proves the actual App route and returned affine capture/rollback behavior for the authored adapter. Its deliberate Unit output/error mapping establishes no general channel preservation, staging coverage, full22 aggregate or performance qualification.

Sparse Motion64 boundaries integrated at `87c14c784` after final review of `728110b98`. Both backends preserve all 413,934 canonical bytes and match the independent 109,024-byte metric oracle: 65 actual transactions and 1,152 append boundaries. All three original postcommit scans, filters, weights and order remain unchanged. Portable: 1,437 members, 750 objects, 23 guards; manifest `8f71462b75946a401d57862b33bd48ad597498d5e981cd6ec0f90aeeb2340bcc`. Exact accepted Dense generic hook controls are reused through explicit body/Meter/dependency joins, without claiming a new Sparse discard/transfer case.

First complete consumers preceded controls; one final review accepted each slice. Both packages reuse existing runners and appropriate evidence. The full combined delivery-range Python/whitespace check passes, including exact-copy attributes; all 356 protected #28 source pins match with the archived-extra exception. CI39136203922 passed after the earlier packaging correction; successor CI follows. No delivery-speed improvement is measured.

The #24 source review also found an ordinary API gap: captured-query metadata registration did not derive executable App wiring. Existing #73 was reopened, retaining prior component/service acceptance. Its next implementation owns a library helper analogous to `Component.add`, with automatic plan/dispatch/cursor handling and existing typed error/output policy. No new ticket, facade, contract or numerical criterion was introduced. Sparse is a bounded missing-family diagnostic; the comparative protocol, larger cases, rotations and qualified memory remain open. Source-representation mapping does not require inventing aggregate metrics or rerunning unchanged matrices.


## Captured-query ordinary App delivery — 2026-10-18

Integrated `77b82945e`, `1c83a602c` and `b72b0a0f7`: public captured-query registration now derives execution alongside component systems. Full Workshop/Garden, typed outputs/errors, Type-capture failure/retry, intended authority refusals and unchanged-owner registration refusal pass JS/Native. The separate blind greenhouse and runnable example pass their complete oracles. One independent final review gives GO; the portable packet reproduces three independent models (seven cases, six backend streams, 52 guards). Long erased aliases and capture inspection remain documented costs.

The required combined #28 remains **failed**, so #73 remains open. Attempt01 mistakenly selected Bend 2.0.37 from PATH; its result is retained separately. Corrected attempt02 uses pinned 2.0.35 and confirms JS slowdown versus the frozen Bend baseline: 16/20 slower pairs, median paired ratio 1.0432622582, exact p=0.0059089661. Native has no confirmed regression. Both full runs are archived losslessly. No threshold, baseline, workload or source fix was substituted; exact-artifact CPU/allocation diagnosis follows. Root CI is pending. These are not final #21/#24 performance results.

Existing batch/ownership practice was used: separate author, blind and docs worktrees, one shared-core integrator, sequential backend leases, then one final review and combined gate. The guide/example shell's missing `-o` was corrected before its successful successor; the failed invocation remains recorded. This checkpoint does not establish overall delivery acceleration.


## Profiled validation follow-through — 2026-10-18

Prior API delivery CI39140222295 passed both jobs. World-only field passing is integrated at `b043b3656` after four full JS/Native streams and independent final review. It removes the intermediate constructor without changing identity predicates or affine owners; sampled total allocation did not decrease. Required pinned #28 attempt03 still confirms JS regression (15/20, median paired ratio1.0242454458, p=0.0206947327); Native passes. The failed run is archived losslessly. #73 remains open; the next bounded candidate is the analogous allocator reconstruction already reached in the same profile. No unchanged gate repeat or threshold change.

The concrete PATH-selection error is prevented in `51f818f1e`: the regression runner defaults to pinned2.0.35, records the resolved executable/hash and rejects another version before workload preparation. Independent launch review and a real2.0.37 rejection control pass. The next gate exercised the positive default and recorded2.0.35. No dependency upgrade, workload reduction or overall speedup claim.


## Validation experiment decision — 2026-10-18

Allocator field passing passed the four complete semantic streams but combined #28 attempt04 still confirms JS regression (18/20 slower pairs, median paired ratio 1.0277409120, p=0.0002012253); Native has no confirmed regression. Neither field-passing experiment demonstrates a total allocation reduction. Direct V8 graph evidence shows the original intermediate constructors are eliminated in optimized code; it does not establish early-run allocation costs. Independent review accepted restoring only those two production changes to their exact pre-experiment source. The ordinary captured-query API remains integrated; #73 remains open against pinned02's unchanged-source regression.

The runtime-counter diagnostic produced complete correct output but no counter table, so that route stopped. No further flag campaign, threshold change or unchanged gate replay follows. Prior and pinned02 emitted JS are byte-identical on both sides; this excludes the new unused helper as an emitted-code cause on this fixture, without waiving the observed regression. CI39141434012 passed the prior checkpoint. Diagnostic commits ffdf72222 and 7c80be1c4 retain the evidence in Git history.


## First-order visibility traversal — 2026-10-18

Integrated `2b32889c5` at `94fc35a96` after one independent final review. The entity-key walk now threads its affine allocator/list state through a direct tail loop. It preserves each ordered validation and returned owner. Full Workshop (231,190 bytes, `fd860b27…`) and current identity (23,126 bytes, `133f44d1…`) match their unchanged oracles on JS/Native; generated JS has zero per-key closures/trampolines, replacing them with one state tuple. Root rechecked actual source, plans, receipts, artifacts and complete outputs. Existing runners were reused from immutable evidence into disposable temporary directories; no new runner or tracked archive. Source15s/emission60s/build120s/consumer180s/profile15s limits were unchanged.

The narrow matching CPU/allocation diagnostics are descriptive single samples: estimated collected allocation 59,066,912 before / 54,559,192 after. They do not establish causal speed, exact heap or RSS. Required integrated #28 attempt05 still fails: JS 15/20 slower pairs, median paired ratio 1.0498169362, exact p=0.0206947327; Native has no confirmed regression (7/20, ratio0.9753496849). All complete outputs pass. Raw receipt/output remain at `.artifacts/regression73-20261018-visible-state05/`; source/artifact identity is bound there, including pinned2.0.35. Host load was9.03 on12 allowed CPUs before launch; paired randomization reduces but does not eliminate contention effects. No unchanged replay, threshold change, full performance claim or #73 closure follows.

The #24 report now reconciles all eleven historical obligations with actual ordinary routes, immutable semantic evidence and exact consumed-source joins; historical aggregate statuses are not promoted. Separate author/support worktrees, one shared-core integrator, sequential heavy jobs, full consumers before focused checks and one final review were used. No overall delivery acceleration is measured. Restoration checkpoint CI39143921539 passed both jobs; successor CI follows.


## Dense64 common-clock bridge — 2026-10-18

Integrated source `16e7176d7` after one final independent Spec/Standards review. Durable inputs live in `test-fixtures/connected-performance/dense-motion64/`; the harness clock is in `benchmarks/connected-clock/`. JS/Native match all 226,988 oracle bytes, TS all 89,186; each process preserves two complete 5,448-cell observations (warmup then fresh sample). Every field is forced before the end clock; complete canonical transport follows. TS uses the previously qualified synchronous write loop, preserving bytes/order while ensuring warmup writes reach the OS before fresh sample creation. No experiment archive was restored.

The new clock returns checked elapsed nanoseconds within Bend's 48-bit Nat range; absolute uptime nanoseconds would overflow that representation. Original normal clock source remains unchanged after its first successful pair. Offline admission joins exact consumer argv to full sidecar paths, coordinator freshness records and raw clock hashes; bad path, missing file, float, zero and overflow controls reject. Focused JS/Native delay and state-error controls pass with generated-artifact producer/consumer hashes. The first focused attempt was unexecuted; the second JS control failed because Base IO.sleep loads Bun FFI under Node, leaving Native unexecuted. A control-only Node Atomics.wait/POSIX nanosleep replacement repaired that failure without changing the production timer.

Four existing-protocol CPU/allocation diagnostic processes also preserve their complete oracles. Their clocks are ignored. Profiles cover imports, setup, warmup, sample, transport and GC; sampled allocations are not live heap or RSS. Current raw plans/receipts are in `/tmp/bendvy21-dense64-ns-normal-actual01`, `...controls-actual03` and `...node-profiles-actual02`. The method establishes neither nanosecond accuracy nor comparative performance. Limits15/60/120/180s and diagnostic15s were unchanged; heavy jobs ran serially. No elapsed delivery acceleration is measured.

This fixture retains the historical manually composed App recipe. It reaches real App/query/transaction code but does not qualify the automatic primary entry delivered in #73. Next under existing #21: migrate that driver without changing gameplay or complete gold; investigate reached repeated declaration construction separately. Wider independent gold, approved comparison/precision protocol, seven rotations, all workload/schema/size outcomes and memory qualification remain open. The unchanged production-core #28 attempt05 remains failed; harness/doc changes do not justify replay or close #73.


## Automatic Dense entry and lifecycle reuse — 2026-10-18

Integrated `245ef9856`, `23082c37e` and README correction `243539267` at `ba85ff4ce`, after one independent final Spec/Standards GO. Dense now registers once through `Component.add`; generated execution supplies routing. Its actual invocation token, operational fields, arguments and outputs survive observation. Business body, declaration, storage and full gold are unchanged. Combined JS/Native each match all 226,988 bytes and both 5,448-cell tuples. Evidence: `/tmp/bendvy21-dense64-primary-normal-actual02/`, RESULT SHA256 `be073e4a9ad1c4ab308a66fc56d28f5aefffbfd3653d318cedc65dabb4964d4b`.

Lifecycle clearing retains immutable entries instead of rebuilding them; validation, scans, duplicate removal and order remain unchanged. Isolated full consumers and six literal boundary cases pass both backends. Reached generated JS retains the original entry. One collected-allocation sample estimates 407,271,712 before / 385,669,888 after; lifecycle clear attribution 65,903,952 / 43,925,440. These are whole-process sampling estimates, not live heap, RSS or demonstrated speed. Raw profiles/controls: `/tmp/bendvy21-lifecycle-retain-followups-actual01/`. The erased-capability-helper alternative was rejected because reached emitted code still rebuilt the plan; no affine function cache was adopted.

Required combined #28 attempt06 passes `NO_CONFIRMED_REGRESSION`: JS 12/20 slower pairs, median paired ratio 1.0334838625, p=0.2517223358; Native 8/20, ratio 0.9814522491, p=0.8684120178. All 40 pairs and 123 commands pass complete observations using pinned 2.0.35. Receipt: `.artifacts/regression73-20261018-lifecycle06/receipt.json`, SHA256 `bcf7a16f2fee625433691e3e175e0a96187fafdefefb8b73abd928f79573a450`. Host load 6.57/12 before launch; the fixed paired test reduces but does not eliminate contention. This passes the approved statistical gate; it proves neither equivalence nor causal acceleration. Earlier failures remain unchanged.

Two implementation owners, one integrator, serialized heavy jobs and existing runners were used; the primary pair consumed the combined source to avoid a second integration replay. Limits were unchanged. No overall delivery acceleration was measured. #73's remaining integration gate is CI; full #21/#23/#24 workload/schema/size, protocol, rotations and memory qualification remain open.


## Indexed Dense and automatic Sparse — 2026-10-18

Prior CI39149828014 passed; #73 is closed. Integrated Dense configuration/model `c02dcb3ac` at `bd60d3630` and Sparse primary `91b343800` at `4f31ab060`, after one independent final review. Dense opts into existing indexed columns at three initializers; the library default, core API and business logic are unchanged. The independent model reproduces the original Plain stream, then derives all Indexed arrays, holes, capacities, depths and exceptional metadata across five phases/two namespaces. Both backends match the complete 261,774-byte physical oracle (`be10d124…`), retaining identical 5,448-cell logical tuples and TS gold.

Matching primary-route CPU/allocation diagnostics pass their complete oracles. One collected-allocation sample estimates 407,173,720 bytes Plain / 361,126,584 Indexed; clear_reversed attribution 45,695,504 / 0 sampled bytes. This includes startup, warmup, GC and canonical transport; physical wire sizes differ 226,988 / 261,774 bytes outside the timed common forcing. It proves neither speedup, isolated business cost, live heap nor RSS. Raw actuals: `/tmp/bendvy21-{dense64-primary-plain,indexed-primary}-node-profiles-actual01/`; bounded analysis SHA256 `6e3d24ce0e230f7fef0461ea12c9d385a855a99b418546f96ce29aec63783246`.

Sparse Motion64 now registers once through Component.add and generated execution. Its original three fresh postcommit scans, ordered cumulative audits, statuses, actual invocation owners and physical observations remain. Both backends match all 1,071,136 oracle bytes (`d5539a7c…`) and two complete 35,061-cell tuples. Raw receipts: `/tmp/bendvy21-sparse-primary-normal-actual01/`. Historical TS strategy differences remain explicit; no new TS timing qualification, Health or wide-case claim.

Root rejoined all 128 Dense and 140 Sparse imported source bindings to the integrated files; no mismatches. Core and protected benchmark inputs are unchanged, so passing #28 attempt06 is reused without another cohort. Existing runners/limits, two implementation owners, separate independent oracle, one integrator and serial heavy queue were used. No elapsed delivery acceleration is measured. CI follows; full workload/schema/size, comparative protocol, seven rotations and clean memory qualification remain open under #21/#23/#24.


## Health primary consumers and TS correspondence — 2026-10-18

Prior CI39151041252 passed. Integrated Dense Health source/model `4594188f8` at `c7956262e` and Sparse Health/TS bridge `13b4cff0b` at `3589bcb85`, after one independent final Spec/Standards GO. Both use genuine Health business definitions and one Component.add registration; all levels, reserve/class, Armor grade, actual affine invocation owners and Sparse's three fresh postcommit scans remain. The independent models were sealed before execution, reproduce historical Health canonical/TS streams and reuse current generic model helpers without changing Motion expectations.

Seven actual roles pass complete independent outputs and two full logical tuples each:

| Subject | Full bytes | Logical cells per world |
| --- | ---: | ---: |
| Dense Health JS / Native | 261,672 each | 5,512 |
| Dense Health TS | 90,224 | 5,512 |
| Sparse Health JS / Native | 1,115,471 each | 37,629 |
| Sparse Motion TS | 695,984 | 35,061 |
| Sparse Health TS | 736,456 | 37,629 |

Raw receipts remain in `/tmp/bendvy21-{dense-health,sparse-health}-primary-normal-actual01/`, `/tmp/bendvy21-dense-health-primary-ts-actual02/` and `/tmp/bendvy21-sparse-ts-primary-normal-actual03/`. Source joins rechecked 128 Dense and 140 Sparse imported modules against integration with no mismatch. Sparse TS changes only the measured hrtime.bigint seam and the accepted synchronous writeAll loop; reverse-delta checks preserve all other reference bytes, setup clock, business queries and full output. Unexecuted drafts with missing git/manifest pins remain preserved; successors pin both actual dependencies before execution.

Core/protected #28 inputs remain unchanged; passing attempt06 is reused. No limit increase, comparative timing, timer-accuracy, query-cost equivalence or memory claim follows. Existing runners, two implementation owners, independent oracle support and one serial heavy queue were used. CI follows. Dense/Sparse now have ordinary consumers at 64 entities for both schemas; larger sizes, the other three families and full comparative/memory qualification remain open. Overall delivery acceleration is unmeasured.


### 2026-10-18: typed existing-registration adoption

The new ordinary App factories derive fields and routing from actual Local, System and Reader registrations. Lifecycle and FailedTxn Motion64 retain the original callbacks, affine owners, App validation, phases, barriers and full observations. Independent models reproduce the historical gold without restoring experiments. All four Bend roles and both four-case routing/refusal controls pass their complete oracles. One independent semantic review reports GO. FailedTxn TS also passes its full independent oracle. Current fixtures are in `test-fixtures/connected-performance/{lifecycle-motion64,failedtxn-motion64}`; source bases are `e687064f` and `ece6e2d8`.

Combined #28 attempt `.artifacts/regression21-20261018-adoption07` reports REGRESSION: JS is slower in 17 of 20 pairs, with median paired ratio 1.130656. Native has no confirmed regression. Both emitted JS and C artifacts are byte-identical to passing attempt06, so this run does not establish a regression caused by the new unused factories. The failed verdict remains unchanged. Fresh CPU and allocation diagnostics match the complete oracle. They identify a redundant intermediate World reconstruction as one bounded candidate, not a proved explanation of the cohort difference. Performance acceptance remains open; no issue closes on these results.

The delivery reuses six unchanged execution and authority modules and four existing controls instead of rebuilding a broad matrix. The first static-record candidate passed semantic checks but still allocated Binding objects in generated JS; the integrated direct-function factories remove that representation. Ordinary forwarding closures remain. No execution limit changed, and no general delivery speedup is claimed. CI and the performance repair are the next checks.


### 2026-10-18: validation experiment history and current delivery

Adoption commit `d73f52bb4` passes CI39155503017. The later World field-passing candidate `702eb9ca9` passes complete Lifecycle and FailedTxn oracles and the existing routing controls, but is not adopted. Related World/Allocator variants `b59740940` and their successor failed #28 and were restored by `f6f064f1e`. Historical optimized IR removes the intermediate allocations after tiering; materiality in the ordinary cold process remains unproved. The old unused helper was absent from emitted JS, so deleting that source helper does not establish a new runtime-cost premise. The candidate and all checks remain in Git and temporary evidence. Master World source stays unchanged. Failed #28 attempt07 remains open; no further cohort repeats this allocation premise.

Lifecycle Health and Readers current runnable qualification continue separately. Readers already has twelve historical normal backend cases and two reused controls; those cases are not repeated. New fixtures preserve the original per-schema representations, including Indexed Motion and Plain/String Readers Health. The workflow now names affected-file history before performance retries and the missing `read-tree -mu HEAD` materialization step for new sparse worktrees. No new runner, approval stage or execution limit is introduced.

### Current #21 acceptance boundaries — 2026-10-18

Lifecycle six-role semantic integration `9bc9e3342` and checkpoint `c2ede75ca` pass CI39158767450/39158897581. Readers Motion Native emission300 successor `fa1cfb9a` passes the full 30,103,222-byte oracle after retained60/120 timeouts; TS also passes its full8,945,548-byte oracle. No comparative speed or clean-RSS qualification follows.

Independent clause5 audit retains earlier source-bound append/finish diagnostics but finds no current full-matrix after-append qualification. Terminal-count matrices are insufficient substitutes. Reuse qualified hooks/controls for missing Health Dense/Sparse and wider current routes under #21/#22. Current `transaction.Tx` has undo, commands and events, but no separate mark journal; mark-journal occupancy is representation-N/A, while persistent metadata and retained-reader/world-queue measurements remain distinct.

Lifecycle Motion256 passes full JS/Native99,547,484-byte and TS65,306,588-byte independent oracles using the qualified64 Bend artifacts without emission/build. Final Spec/Standards review GO covers count parameterization and exact64 preservation; nine wider roles remain unqualified. Readers integration61c1ed814 passes CI39159969717. No unchanged #28 rerun or comparative claim follows.

Lifecycle Health256 passes full JS/Native102,657,815-byte and TS67,864,756-byte independent oracles,2×8,204,399 shared scalar cells per role. Final review GO covers exact producer reuse and metadata-only count results; no emission/build or performance claim. Six1024 roles remain open. Both incomplete Motion1024 model attempts120/300 are preserved; a recorded900 s source-generation trial is pending.

FailedTxn Health64 passes its first full JS/Native70,498,700-byte and TS38,129,202-byte independent oracles;965 records and3,608,414 scalar cells per world. Final review GO confirms genuine Health String/chunk behavior, exact owner/error/cursor paths and canonical-first model. Core and runners are unchanged. This completes the current64 fixture pair for all five families, not the wider matrix or performance qualification. Previously approved workflow/report notes are preserved in the same delivery.

FailedTxn256 now passes both schemas on JS, Native and TS: Motion 228,252,352/129,123,660 Bend/TS bytes; Health 231,464,976/133,557,212 bytes. Independent final Spec/Standards review approves consumer commits 64e32d2c2/eefdd8334 and model chain 575f2289a–478c37fe5; integrated at 21a443af5. Four Bend roles reused exact qualified 64-entity artifacts without emission/build. Health preparation first exposed a pending seed list sized to 64 even for larger worlds; the source-backed count repair preserves the 64-entity result and matches the historical 256-entity canonical hash. The pre-command path refusal and owner-interrupted Native attempt remain unqualified; all six final accepted receipts are complete. Both schemas at 1024, comparative/clean-RSS gates and failed #28 remain open.

Lifecycle Motion1024 independent gold completed under the recorded 900 s cap. Its first ordinary JS attempt reported heap OOM after the warmup clock; the outer wrapper also expired, so those facts remain separate. Candidate 7bef507ce changes only post-clock tuple output into bounded chunks and passes four fresh full 64-entity JS/Native controls. Before/after CPU diagnostics retain every sample, including one raw negative time delta, and permit sample-count analysis only; allocation sampling does not show a total-allocation reduction. Motion1024 JS now completes on the default heap with all 396,386,802 oracle bytes; Native and TS remain pending. Moving installed Bend resources were detected before execution; a byte-identical private 2.0.35 binary/resource bundle supplies the frozen closure without changing installed state. Execution budgets and outcomes are recorded in [limits](../limits.md); no comparative speed or delivery-time improvement is claimed.

Lifecycle complete semantic matrix is integrated at e90938bce after one final independent Spec/Standards GO: 12 current-writer Bend roles, two corrected TS1024 roles and four qualified TS64/256 reuses. All sizes retain complete tuples, owners, canonical fields and original timer boundaries. Both 1024 schemas complete on the default Node heap; four affected 256-entity Bend roles use the new artifacts without emission/build. The joined packet f2ba02ce retains original OOM/deadline, strict diagnostic refusals and incomplete-auxiliary TS predecessor separately. Profiles show bounded text-chunk assembly, not reduced cumulative allocation, clean RSS or comparative speed. FailedTxn256 checkpoint a56660660 passes CI39165770754. Before new FailedTxn1024 subjects, source inspection found the same unbounded tuple String pattern; those old plans remain unexecuted while its owner applies the same bounded transport with before/after profiling. Full numerical qualification and failed #28 remain open.


FailedTxn now completes all 18 semantic roles at 64, 256, and 1024 entities for Motion and Health on JS, Native, and TS. Integration commits `70e35cca4`, `31565be7b`, and `3398bffc8` preserve the reviewed source and result bytes. Independent final review approved packet `fa55c4da…`: twelve fresh Bend roles, two fresh TS1024 roles and four qualified TS64/256 reuses. The bounded writer changes only post-clock tuple output. Original callbacks, owners, canonical Doc and String work, encoding, folding, and timer boundaries remain unchanged.

The first current Motion1024 JS run exhausted the default heap before FORCE. Its failed receipt is retained. The recorded 8192 MiB old-space trial completes both JS schemas and TS references at 1024 entities against full independent oracles. Before and after profiles support analysis of sample counts and sampled allocation estimates. They do not show an allocation reduction. All historical refusals, interruptions and unexecuted plans remain distinct.

This delivery reused qualified artifacts from 64 entities for wider consumers and used existing runners. Committed `src/ecs` is unchanged. Failed #28 attempt07, equivalent timed-work correspondence, comparison margins, rotations, occupancy and clean child RSS remain open. CI follows. Dense separately repairs two confirmed host-stack failures in fixture-local concatenation and post-clock formatting. No general delivery acceleration or comparative speed is claimed.


Dense completes all 18 semantic roles after independent final review of packet `0d4421dd…`. Integration through `6a6eb1cf2` matches both complete reviewed fixture trees. Twelve fresh Bend roles, four wider TS roles, corrected Motion TS64 and one qualified Health TS64 reuse pass full independent gold. Both schemas at 1024 complete with the default heap and stack limits.

Two actual failures guided the local repairs. A stack trace identified List.append during common encoding; tail-safe concatenation preserves scalar order. The next failure reached FORCE and Clock.end before overflowing in List.show. The accepted bounded writer replaces only post-clock tuple output. Original business operations, owners, encoding and folding semantics, complete observations, and timer boundaries remain intact. Failed attempts, catch-only diagnostics and unexecuted predecessors remain separate from accepted results.

Wider Bend roles reused the new qualified artifacts without emission or compilation. Committed `src/ecs` and protected regression inputs are unchanged. Failed #28 attempt07 remains open; this delivery adds no comparative speed, allocation, RSS or general delivery-time claim. CI follows. Sparse is the next active family alongside completion of Dense integration.


Sparse completes all 18 semantic roles after independent final review of packet `542eb5cf…`. Integration through `aff039d12` preserves all reviewed consumer, model, and result files. Four fresh Bend roles at 64 entities, twelve wider roles and two qualified TS64 reuses match full independent gold. Models reproduce retained 64-entity bytes, applicable wider canonical controls, five Plain physical phases, and reversible namespace-score correspondence.

The accepted bounded writer changes only post-clock tuple transport. Original three fresh scans, postfilters, weighted and cumulative scores, owners, encoding, folding, FORCE, and timer boundaries remain unchanged. This delivery has no backend failure, retry or limit increase. The superseded unexecuted model plan is retained under its exact hash. Wider Bend roles reuse the fresh artifacts from 64 entities without emission or compilation.

Committed `src/ecs` and protected regression inputs remain unchanged. Failed #28 attempt07, equivalent timed-work correspondence, comparison margins, rotations, after-append occupancy and clean child RSS remain open. CI follows; no comparative speed or delivery-time improvement is claimed. Readers count-model generation is the remaining semantic family work.


Readers completes all 18 semantic roles in packet `dd00dd5c…`: six source-bound 64-entity reuses and twelve fresh wider roles. Both schemas pass complete independent oracles at 64, 256 and 1024 entities on JS, Native and TS. Count models preserve complete 64-entity bytes and distinguish current Indexed Motion from Plain Health; the old Plain Motion256 byte anchor is explicitly inapplicable to the current Indexed representation.

Bend sources, callbacks, owners, timer boundaries and qualified artifacts remain unchanged. No emission or Native rebuild was needed for the wider roles. The initial helper's shadowed oracle hash was caught before execution; those plans remain unexecuted. Motion1024 JS exhausted its default heap after warmup FORCE and end-clock, before tuple output. The recorded 8192 MiB old-space successors complete both JS and TS schemas without changing stack limits or sources. The failed receipt remains distinct.

The final packet reuses completed full-output verifications with exact receipt/result/raw identities. Two redundant aggregation drafts exceeded a local 30-second cap; aggregation completed under the existing 120-second offline budget without repeating subjects. Final independent Spec/Standards review is GO. Integration through `e1fc1cdb3` matches both complete reviewed fixture trees; committed `src/ecs` is unchanged. Checkpoint `578994977` passes CI39176525860 (functional and examples). The finite semantic matrix is now 90 roles; equivalent timed work, comparison margins, rotations, after-append occupancy, clean child RSS and failed #28 attempt07 remain open. No comparative speed, memory reduction or delivery-time improvement is claimed.


DenseHealth64 now qualifies finite actual after-append transaction reports and prefinish simultaneous metadata vectors through the ordinary Component.add path. Packet `c097b6d2…` joins full normal JS/Native output (261,672 bytes) and independent sidecars (3,022,657 bytes). Each world has 65 transaction reports and 8,320 append records; separate completed-column histories contain 4,161 / 23 / 22 snapshots. These are finite structural observations, not unique-cell/global peaks, allocator bytes, payload retention or RSS.

One reached JS reporter control preserves the full original output, fails the correct sidecar oracle and matches the presealed counter oracle. Exactly 130 populatedTotal fields differ by +1. The second Native control was not run. Independent final Spec/Standards review is GO; integration through `2122b862c` matches the reviewed source/model union. Production core and original consumer/method trees remain unchanged. Checkpoint `a14e5b3cd` passes CI39178170451. Existing runners, full oracle and prerequisite generic controls were reused without new infrastructure.

The first independent model attempt failed before output because it collected an expected_common helper world plus the two emitted worlds. Its successor asserts complete helper/warmup state and report equality before selecting the emitted pair. Source/prelaunch repairs and unexecuted predecessor plans remain distinct; no subject failed and no limit increase was needed. Wider workloads/sizes, retained-reader/world queues, other journal categories and full #21 qualification remain open.

The user-endorsed comparative-boundary direction and Astra review retain business operations, actual public reads, required intermediate snapshots and full common forcing inside timing; verification-only expected generation/assertions and genuinely private diagnostics remain in unchanged semantic qualification. Source correspondence and new full-gold JS/Native/TS acceptance precede comparative cohorts. This is not numerical-margin approval, a speed claim or a waiver of failed #28 attempt07.


DenseHealth256 occupancy now passes on JS and Native after a confirmed post-clock history stack failure. The original JS attempt reached FORCE, then failed with the runtime's generic memory-fault message; its clocks had not yet been transported. A copied-generated-artifact diagnostic changed only the RangeError catch to print its stack and identified repeated metadata.tail frames. The failed receipt and old unexecuted Native plan remain preserved. This was host JavaScript recursion, not an established heap OOM or Bend-machine stack limit.

Integration through `a649c827f`, independently reviewed in packet `18c3f756…`, changes four executable private files: detach actual histories as Data and stream them after the unchanged timer in bounded64-piece chunks. Original World/owners, hook paths, prefinish metadata, body, FORCE and timer definitions remain unchanged. Fresh JS/Native64 match the original261,672-byte stdout and3,022,657-byte sidecar; fresh JS/Native256 match1,033,206-byte stdout and12,218,661-byte sidecar. Each256 world has65 reports/33,280 append records and histories16,641/87/86. No limit increase, optimization speedup or memory reduction is claimed.

The independent count model first reproduces complete64 normal and both sidecar controls before deriving256. Its new worktree preserves every original producer pin; the separate old-worktree restore commit is not integrated. The reached populatedTotal control is reused only for its byte-identical prefinish source/caller path. Exact reviewed source/model union and unchanged production/original consumer trees were checked after integration. Existing runners and reviewed data-only artifact reuse sufficed; no new framework or control campaign was added. Checkpoint `3fc9a0ca1` passes CI39180245284.1024, other families/queues/journals, global/unique peaks, clean ECS child RSS, full comparative qualification and failed #28 remain open.


The first FailedTxn Motion64 comparative adapter passes JS, Native and TS after the user-endorsed boundary and Astra review. Final packet `1a9cb33d…` joins exact full Bend61,433,187-byte and TS47,654,772-byte outputs, complete common and own-role public tuples, both actual FORCE writes, fresh clocks and source/tool provenance. The independent model first reproduces the original complete canonical/Bend/TS observations, then verifies unchanged965 common records/3,504,864 cells before deriving supplementary public snapshots.

Source specialization removes private Facts observation capabilities rather than inventing values. It preserves actual first/repeated public reads, Local/Reader owner and cursor flow, Dispose statuses/outcome, App.describe, registration/schedule/barrier order and original error/continuation guards. TS public reads embedded in assertions remain actual reads; its outcome-supplying listener remains reached. Expected-state generation and genuinely private capture/formatting are excluded from the new interval. Both complete carriers are materialized/forced inside timing; transport and validation follow it.

Independent final Spec/Standards review is GO. Integration through `5aef0a2a4` matches the complete reviewed leaf; production core and original semantic consumer/method/model trees remain unchanged. Current correspondence02 and the separately preserved frozen model-pinned correspondence01 are explicitly distinguished. Existing collector, complete-wire oracle and tuple admission were reused. Checkpoint `a9e2fa163` passes CI39181284376. This finite Motion64 adapter does not qualify performance, Health/wide/other families, seven rotations, numerical margins, child RSS or failed #28.


DenseHealth's finite after-append/prefinish slice now passes JS and Native at64,256 and1024. New packet `f62c85dc…` adds two1024 consumers reusing the qualified bounded64 artifacts: exact4,315,238-byte normal output and50,396,983-byte sidecar,65 reports/133,120 appends and histories66,561/343/342 per world. Both consumers complete under existing360/480-second limits and default Node settings; no source, writer, kernel or limit change was needed.

The one1024 model generation uses the existing900-second budget and unchanged reviewed source, first preserving full64 normal/stats/counter and then joining the accepted1024 normal oracle. Data-only plan changes and every old producer/source pin were checked; the result metadata lives in a separate worktree. Independent final Spec/Standards review is GO. Integration `5d257e221` appends only1024 metadata, preserving64/256 entries exactly and leaving production core untouched. Earlier repaired64/256 evidence and reached shared reporter control remain explicit prerequisites. CI follows. This does not qualify other workloads/journal categories, retained readers/world queues, global/unique peaks, ECS child RSS, comparative targets or failed #28.

### 2026-10-18 — Health64 comparative adapter integrated

Final independent review accepts packet `961247cc…`: JS89676, Native91295 and TS78540 all exit0 with empty stderr and complete independent-gold/common/public matches. Integration `df7a8ab4c` through `cb19ef65e` preserves the exact reviewed leaf and unchanged production ECS/original semantic consumer trees. Existing runner and qualified Motion projection were reused; no repeated launch admission or giant rerun was required. DenseHealth all-size checkpoint `cb7977433` passes CI39182553494; Motion comparative checkpoint a9e2fa163 passes CI39181284376. Health checkpoint `1a964d196` passes CI39183165258. This is finite correctness/correspondence evidence, not a speed, memory or full-goal result. Next two directions remain wider FailedTxn comparative adapters and DenseMotion64 actual occupancy.

### 2026-10-18 — Motion256 comparative input integrated

Packet `27e6f743…` passes JS58809, Native85305 and TS16111 against full independent gold. Independent model preserves complete64 comparative wires and original256 semantic streams before additive public derivation. The existing parameterized consumer and qualified artifacts are reused unchanged with256/64, avoiding emission/build and duplicate source wrappers. Final independent review GO; integration `d65cd8ec5` through `01d0ce60b` matches the reviewed leaf and preserves production, original semantic and comparative64 trees. Health checkpoint1a964d196/CI39183165258 SUCCESS is folded here without repeated runs. No performance/RSS or overall delivery-speed result is claimed; remaining qualification gates and failed #28 remain unchanged.

### 2026-10-18 — DenseMotion64 actual occupancy integrated

Final review GO for packet `cfbab54c…`; JS94143 and Native42164 both match full Indexed normal261,774 bytes/be10d124 and independent sidecar3,022,657 bytes/03dadff6, with empty consumer stderr and all stages0. Genuine Motion payloads and ordinary invocation owners reach immutable accepted append/prefinish hooks and token harvest/reset. Independent derivation preserves complete current normal before/after instrumentation and derives65 reports/8,320 appends per world, with chronological column histories4,161/23/22. The reached reporter control is reused only for the byte-identical generic seam; this concrete Motion callsite is newly qualified. Integration `c851f76da` through `f4e6a7c91` matches the reviewed leaf, preserving production/original consumers and accepted Health instrumentation. Motion256 checkpoint4c10d4268 passes CI39183818129. No new runner/control campaign or repeated compile is required for integration. Wider Motion, other families/categories, retained reader/world queues, global/unique peaks, child RSS, comparative targets and failed #28 remain open.

### 2026-10-18 — Health256 comparative input integrated

Final independent review GO for `d16775f7…`; JS60307, Native34444 and TS2678 match full independent wires/common/public carriers with empty stderr and all consumers0. Integration `be5609ab1` through `af091a805` matches reviewed leaf432e70ae3 and preserves production/original/qualified64 trees. Genuine Health runtime/artifacts already support dynamic256/64, so this delivery needs no emit/build or duplicate runtime wrappers. Complete64 comparative and original256 semantic preservation precede additive model derivation. DenseMotion64 checkpoint7644e5a36 passes CI39184124995. No speed, RSS, overall delivery acceleration or #28 waiver is claimed. Remaining1024/families, rotations/margins and memory qualification stay open.

### 2026-10-18 — DenseMotion256 occupancy integrated

Final independent review GO for packet `449b7e47…`; JS61163 and Native34509 plus joined verification22284 all pass. Full normal1,033,438 bytes/1d2fed36 and sidecar12,218,661 bytes/6227d88e match independent gold;65 reports/33,280 appends and histories16,641/87/86 per world. Exact qualified64 artifacts/source/owners/hooks are reused, avoiding emit/build. Independent model preserves full64 normal/stats/counter then original256 normal before/after additive observation. Root caught unintended iterations256 CLI admission before generation; corrected successor02 restricts64, and oldplan01 remains unexecuted. Integration `838921e79` through `2caafdba2` matches reviewed model/result and preserves production/original/qualified runtime. Health256 checkpoint783632d74 passes CI39184682378. Existing controls/runners reused; no speed, global peak, RSS, overall delivery acceleration or #28 waiver is claimed.1024 and broader memory/performance gates remain open.

### 2026-10-18 — Motion1024 oracle prerequisite reuse

Independent comparative model plan7558e840 reaches its900-second limit (owned91792, exit124, empty stderr). Complete prior64/256 comparative and original1024 semantic prerequisite bases finish; fresh public1024 basis does not. The failed plan and partial outputs remain unchanged and do not qualify the adapter. Source audit verifies existing immutable prerequisite gold against current model hashes, allowing a fresh successor to stream-check those accepted full outputs and reuse observer fixtures while still deriving new1024 public observations and checking every record/map/common cell. No subject/backend ran and no correctness gate or numerical target changes. DenseMotion1024 independent model takes the released queue. DenseMotion256 checkpoint8bfa00bda passes CI39185177466.

### 2026-10-18 — DenseMotion1024 occupancy integrated

Final independent review GO for packet `f1b1279c…`; JS12284, Native44548 and joined verification42549 all pass. Full normal4,315,984 bytes/8e223e8a and sidecar50,396,983 bytes/1fe318b6 match gold, with65 reports/133,120 appends and histories66,561/343/342 per world. The unchanged64 artifacts run1024/64 under default Node and existing360/480-second limits; no emission/build, source/heap/stack change or rerun was needed. Independent model preserves complete64/256 normal/stats/counter before actual1024 derivation. Integration `22060dba1` through `6dfbb5906` matches reviewed model/result and preserves production/original/qualified runtime. Dense Motion and Health now cover all3sizes for this finite actual append/prefinish and column-history slice. Other families/journal categories, retained readers/world queues, global/unique peaks, child RSS, comparative targets and failed #28 remain open. No broad memory bound, speed or overall delivery acceleration is claimed.

### 2026-10-18 — Motion1024 comparative input integrated

Final review GO for packet `6c37f771…`; JS39230, Native92363 and TS94331 all match complete independent role gold/common/public tuples with empty stderr. Integration `db18ab2e2` through `8dccec2e0` matches the reviewed leaf and preserves production/original/qualified64 trees. Exact parameterized64 artifacts avoid emission/build. Source-bound reuse of accepted prerequisite full streams/canonical/source hashes removes repeated model reconstruction while retaining fresh1024 Observer and exact record/map/common/public equality. The earlier model900 timeout and JS8192 pre-FORCE OOM stay failed; fresh actual03 completes with user-authorized16384 MiB equally on JS/TS, logged in limits before launch. Native remains unchanged. Dense all-size checkpointc3b3c3d8f passes CI39186581570; limits checkpointdcfdcc730 passes CI39187069461. No performance/RSS qualification or #28 waiver follows. Next two directions remain Health1024 comparative and Sparse actual occupancy.

### 2026-10-19 — reduced matrix and distinct Plain path delivery

The user retains all90 accepted semantic roles and full parity, with no repeated semantic rebuilds. The existing comparison protocol now specifies seven required speed cases, three backends/seven rotations and unchanged JS/TS<=1, Native/TS<=0.5 and #28.1024 is targeted/nonblocking; no more FailedTxn1024 heap increases merely to finish a matrix. Memory acceptance follows distinct storage/ownership paths, reusing accepted Dense instead of schema/size duplication. Existing #21/#24 are updated; no second plan is introduced.

SparseMotion64 qualifies the distinct Plain path: packet `c3500264…`, JS93838, Native98264 and joined verification41945 pass full normal1,071,136 bytes/d5539a7c plus sidecar345,449 bytes/872fa099. Original three scans/cumulative audit remain exact; actual Plain empty owners are wrapped once and ordered stamps include zero entries. The independent model wrong-base draft was fixed before any generation, with oldplan01 retained unexecuted. Source/model/result union integrated `2ca553a06` through `fb22619d7` matches final independent GO and preserves production/original consumers. Shared reporter seam evidence is reused only where exact. No width/schema replication follows; remaining genuinely different ownership/retention paths and final speed/RSS gates stay open. Selected Dense timed-work audit indicates existing semantic consumers already have verification outside timing, allowing reuse without new runtime wrappers or backend reruns; remaining selected-case correspondence is being checked.

### 2026-10-19 — reuse Readers retention evidence offline

No backend replay or sampler was needed. `/tmp/reconcile21-readers-retention02.py` SHAe53f6e66856d01ee8e2043d777c6ae42704263e511047aa6199ace95ef40be87 derives `/tmp/bendvy21-readers-retention-reconciliation02.json` SHAda6378b7b3bf43906fe1264e4d270154ab804dccef1166002fd06693efe93c8b from accepted full JS/Native canonical10,810,200/18393674, receipts/guards and six exact current non-import source joins. All84 prepared captures distinguish before stored cursor, actual after-prepare running context and returned cursor;252 stream reads/commits match ordered retained batches, registered-aware lag and read-through. One simultaneous snapshot retains4/4/4 stream values; no unique-byte/global-max claim follows. Actual trimming occurs; true-loss/lagged=true is not reached by this story and retains its event-specific semantic coverage. Combined with accepted Indexed/prepared columns, distinct Plain Sparse and source-current FailedTxn774 staging/rollback reports, no new missing sampler field was identified for the observed paths. Opaque closure/payload bytes remain unavailable and separate Tx marks journal is N/A. Whole-child RSS is still collected with the selected qualification, not a new matrix. This demonstrates evidence reuse and avoids replay; overall delivery acceleration remains unmeasured.

### 2026-10-19 — Lifecycle selected adapter delivered

The existing runner qualifies LifecycleMotion256 on JS, Native and pinned TS; packet `fe7a8bbb` joins complete independent gold and zero-error terminal receipts. One independent final review accepts leaf `c72fce237`; integration through `f0d4f54f4` preserves its exact owned files (checkpoint `f41cc5e8d`, CI39190211593 SUCCESS) and leaves original semantic consumers/core untouched. Complete common/public/foreign observations are forced in the timed route; private diagnostics and expected generation stay outside. No old semantic matrix was rebuilt, new runner introduced or duplicate launch stage added. Readers remains the second direction. Seven-case rotations/RSS, the numerical decision rule and unchanged failed #28 remain open; overall delivery acceleration is unmeasured.

### 2026-10-19 — Readers selected adapter delivered

ReadersMotion64 passes the unchanged runner on JS, Native and TS against full independent gold (packet `065f063d`). One independent final Spec/Standards review accepts leaf `962571792`; integration `6124fc131` preserves its exact owned files (checkpoint `7f627c8e1`, CI39190672390 SUCCESS), original consumer/core and all public operations/owners. Model01 manual interpreter typo failed before execution and remains recorded; model02 and all three subject runs pass. Original semantic matrices were reused. All seven selected routes now have qualified correspondence; actual rotations/RSS, the pending decision rule and unchanged failed #28 remain open. No general speed or delivery acceleration is claimed.

### 2026-10-19 — reuse current regression profiles before another candidate

Read-only audit confirms all358 source hashes in the existing adoption07 CPU/allocation packet still match. Passing06 and failed07 emitted identical JS/C; the verdict remains failed. The sampled `compose.outcome` path is business work, but one12,468-us sample interval dominates its17,526-us attributed total. Its source and emitted outcome/completed bodies are also identical to frozen327bec49; no regression-specific cost follows. Row-result fusion could remove at most one temporary outcome wrapper per returned row, but existing allocation samples do not establish material allocation or escape behavior there. No optimization or unchanged cohort rerun was justified by this audit.

### 2026-10-19 — seven-case raw comparison completed

The exact reviewed index03 `bbd062f5` completed147/147 consumer-only observations with full independent gold, fresh clocks and clean-child RSS. Receipt `25da1c76` and raw descriptive summary `df1e9d1b` are in `/tmp/bendvy21-seven-case-comparative-cohort01/`. No compilation, retry or semantic-matrix rebuild occurred. Draft02 remains unexecuted: its stale DenseHealth TS compiler-resource alias was rebound to the exact preserved35 inventory before launch.

Times below are sample medians in milliseconds, seven observations per backend. Ratios are Bend time / TS time, descriptive only; the acceptance decision rule remains pending. They measure the current complete business/observation/forcing route, not isolated ECS execution. Full min/max and whole-child RSS remain in the source-bound summary.

| Case | JS ms | Native ms | TS ms | JS/TS | Native/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Dense-motion-256 | 94.945 | 36.668 | 18.061 | 5.257 | 2.030 |
| Sparse-motion-256 | 152.191 | 70.006 | 31.130 | 4.889 | 2.249 |
| Lifecycle-motion-256 | 6482.301 | 4189.695 | 1061.095 | 6.109 | 3.948 |
| FailedTxn-motion-64 | 2193.990 | 1241.147 | 462.847 | 4.740 | 2.682 |
| Readers-motion-64 | 639.156 | 396.050 | 115.412 | 5.538 | 3.432 |
| Dense-health-64 | 29.786 | 9.011 | 4.506 | 6.611 | 2.000 |
| FailedTxn-health-64 | 2510.232 | 1705.209 | 584.750 | 4.293 | 2.916 |

The observed results do not establish the JS<=TS or Native<=0.5TS goals. Diagnostic Dense JS/TS CPU profiles use the same artifacts/full gold outside the timed cohort; their durations are excluded. Source audit distinguishes eager public snapshots from timed scalar-wire encoding/folding and post-clock textual transport. Astra confirms an exact fused streaming fold could preserve the existing boundary if every field/framing cell is consumed, complete raw snapshots remain inside, transport stays outside and both TS/Bend use that boundary. No optimization is adopted without profile evidence. The failed #28 verdict remains unchanged.

### 2026-10-19 — current Dense CPU diagnostics select a core candidate

Both exact DenseMotion256 JS/TS CPU diagnostic consumers pass full gold and source/profile guards; analysis `bd90e906` lives at `/tmp/bendvy21-dense-motion256-limiter-cpu-actual01/ANALYSIS.json`. JS has1,121 samples under update/audit ancestors versus46 encoder and6 fold samples; these are whole-process stack counts, not timed percentages. Repeated operational query reconstruction is reached from selector and component/resource capability access: ordinary-query-declaration.pair has93 self samples/201 inclusive, constructing grants, selectors and unused clause metadata. Array payload construction and Indexed mutation are also reached. No codec optimization is justified by this pair. A three-line static projection failed the pinned checker before emission; compiler-source audit confirms templates substitute syntax rather than memoize function-bearing declarations. That attempt is preserved and not adopted. The next bounded candidate consumes each child declaration once when pairing, preserving affine grants, selector short-circuiting and ordered metadata; no improvement is claimed before generated-path evidence and full consumers. Raw comparison checkpoint `2e3be6904`, CI39193367632 SUCCESS; unchanged #28 remains failed.

### 2026-10-19 — paired declaration construction integrated

Independent final Spec/Standards review accepts `099628654` and the focused affine fixture `a5d93ef35`; root integrates them as `5d226f6ab`/`b34c26f2f` with all five owned files byte-equal to the reviewed worktree. Ordinary DenseMotion256 JS/Native retain the full1,033,438-byte independent oracle. The three finite Array-owner cases pass the exact361-byte literal on both backends, retaining left-false short circuit, both grants, owner cells and ordered duplicate clauses. All21 focused current-vs-TS observations pass full output/clocks/RSS; sample medians JS95.898 ms, Native31.638 ms, TS16.459 ms. The old147 batch is not a paired baseline, so these numbers establish no causal speedup.

The same-protocol before/after Node heap-sampling pair reports estimated whole-process selfSize1,342,867,208→1,003,926,152 bytes, including collected objects at65536-byte sampling intervals. Ancestry-adjusted constructor/projection selfSize531,627,752→402,189,696 also declines; anonymous forwarding/inlining attribution is retained rather than treating the disappearance of a named function as eliminated allocation. This single diagnostic pair supports a scoped construction/allocation fix, not exact allocation, live heap, RSS or speed guarantees. Reproducible analysis: `/tmp/bendvy21-query-pair-profiles-actual01/COMPARISON.json` (`84e41c56`), generated by `/tmp/analyze21-query-pair-profiles01.py` (`e6e476f2`). CPU and both allocation consumers retain complete independent gold. Existing runners and limits were reused, with no semantic-matrix rebuild. Protected #28 imports neither changed core path; its previous failed result remains open without replay. Full performance targets and parent issues remain open. Checkpoint `dffe9f495`, CI39195791675 SUCCESS (functional and examples).

### 2026-10-19 — Lifecycle profile selects timed encoding

The exact qualified LifecycleMotion256 JS artifact passes its full161,772,113-byte oracle under one CPU diagnostic (`e9e73d78` receipt, `e1b92b29` profile); CPU lease released. Analysis `/tmp/bendvy21-lifecycle-motion256-limiter-cpu-actual01/ANALYSIS.json` (`c3460318`) retains all141,273 samples and a signed -50us delta, using counts rather than attributing exact time. Encoder ancestry has25,913 samples, including JSON rendering, character-to-cell conversion and list reversal; fold has2,778 self samples. These calls are inside the clock. Post-clock tuple/text output is separate; GC42,846 cannot be assigned retrospectively. Query-scan CPS and Plain selection are small observed groups; source audit also rejects the suspected per-selector stamp-list scan and nonempty rollback. No CPS or storage-mode substitution is adopted. Next candidate keeps complete raw observations inside and folds the exact existing wire cells without constructing the intermediate list; TS receives the same boundary. Full cell vectors and canonical output remain available after the clock. No result is claimed before complete backend consumers and review.

### 2026-10-19 — streaming candidate rejected on usefulness

Candidate `6c2f38b25`/`34a809e75` preserves full Bend161,772,113-byte and TS92,284,696-byte gold on all three backends and536-byte exact-cell/seeded-fold controls. Generated code retains every raw field and affine State inside the interval. Independent final review gives semantic GO but adoption NO-GO: whole-process heap-sampling estimates increase47,030,361,672→57,949,402,080 bytes; the second render/encode after end is real extra work, not an eliminated cost. Before/after CPU counts do not establish a speed or peak-memory benefit; historical-core confound and signed sampler deltas are retained. The isolated candidate and profiles remain evidence; master adapter stays unchanged. Final packet `/tmp/bendvy21-lifecycle-stream-fold-final01.json` (`af484689`) joins all nine terminal cases; reproducible heap/CPU comparisons `5655ebd0`/`09ba29b5` retain the limitations. Reviewed focused21 index `ba7e3209` remains unexecuted rather than spending a cohort on an unsupported optimization under load51–54/12CPUs. Next source-only feasibility check: one retained affine cell array, with no duplicate JSON render.

### 2026-10-19 — retained cell-array candidate also not adopted

Source `047c79a1c` passes complete JS/Native161,772,113-byte gold; exact TS source/runtime/full92,284,696-byte result are reused under `2864dafa`. Both713-byte controls preserve ownership, Unicode/framing, seeded fold, logical7/8/9-cell bounds and padding exclusion; overflow/overrun/incomplete cases refuse. Same arrays are folded and retained inside, then transported after end without a second render. Fold/print interleaving changes, while all folds and FORCE IO remain inside with identical output order. Independent final review gives semantic GO, adoption NO-GO: whole-process sampled allocation estimates47,030,361,672→50,535,449,560, with higher source-mapped encode/fold and writer groups and no established CPU benefit. One sampled historical/current pair does not prove a causal regression or peak-memory result. Final packet `22c7bd70` at `/tmp/bendvy21-lifecycle-cell-array-final01.json` joins all six actual cases and TS reuse; code remains isolated (`perf21/lifecycle-cell-array`, `a393b4e2e`). No cohort or integration follows.

Astra recommends an explicit user decision before replacing timed character-wire work with complete immutable typed observations/structural forcing and post-clock JSON. The concrete proposal is in the existing comparison protocol; no boundary change is adopted while the answer is pending. Independent approved work continues with a tiny boxed-versus-function capability probe. Source research finds unary function aliases plausible under closed-template substitution; two-operation Write and nominal authority distinctions remain separate constraints. No public capability API, laws, compiler or thresholds are changed by the probe.

### 2026-10-19 — unary capability lowering probe

Probe `be8964aa5` passes the same286-byte literal oracle on JS and normal Native-O3: two actual provider reads, counter2 and a third retained affine Array payload read. Receipts `c55b29ef`/`e28df157` bind actual02; result `a12edf1d5` is preserved in the isolated worktree. The first attempt omitted the seed barrier and produced MissingEntity; its failed receipt and frozen inputs remain, with no Native continuation. The repaired setup publishes the original six queued spawns before either path, without changing expected output. Reached JS removes only the outer Read object/get projection; both variants still create the provider closure on each access. Generated C already flattens the box and retains closure application in both paths. This is bounded lowering evidence, not a speedup, allocation profile or authority/API acceptance. No core migration follows; direct closed-provider substitution remains a separate source-level question.

Direct-binder successor `4d70271bb` changes only the two template arguments from function_factory() to provider. Both backends retain full286-byte gold; receipts `d5b88b17`/`2b7030b0` and result `9c683c0ed` bind actual03. Reached JS now calls provider directly; the C edge passes context scalars directly to provider without closure application or heap reboxing on that edge (the conditional nonsequential task branch remains). This confirms direct closed-binder lowering, not a speedup or allocation reduction over the whole provider. Independent final review accepts only this bounded claim. Source audit of the actual ordinary chain (declaration grant → paired grants → Cap field projection → Compose provider) finds no justified small patch: function-bearing constructors are excluded from constant unfolding. Another erased projection repeats the prior failed premise; exploiting the direct binder would require a coordinated representation/provider-index migration. No such migration is adopted. Public API, compiler, semantic90, timing boundary and #28 are unchanged.

### 2026-10-19 — concrete typed-observation proposal checked

Retaining rendered strings is source-feasible and could remove the streaming candidate's post-clock rerender, but repeats its already measured timed path without positive CPU evidence. Source review therefore rejects another serialization campaign; it does not explain the current timed gap.

Reviewable local branch `proposal/typed-observation-v1`, commit `bbc8d3aa1`, combines unchanged checked Bend53ef64d4 and TS1586def60 runtime files, a reproducible independent model and supported literal inputs. Actual Lifecycle Motion256/64 normal consumers pass full independent gold on JS/Native161,772,146 bytes (`1d33b649`) and pinned TS92,284,729 (`3f5c5518`). Bend packet `3daec96a` and TS packet `9bf14aaf` bind all five terminal plans; stages exit0 with empty stderr. Independent final Spec/Standards review gives GO as a bounded correctness proposal. All typed fields are traversed inside; actual raw snapshots and affine State remain, with full JSON/wire after end. TS snapshots are detached/frozen; generated JS confirms the reached forcing order. Legacy M.collect still Nat.show-formats cached fuel inside capture, and TS clone/freeze is a chosen implementation cost. Fresh clock grammar establishes no timing accuracy or speed claim. The combined independent model matches corrected literal controls; actual full-gold derivation is unchanged. The proposal remains unadopted pending user choice; no seven-case cohort, new memory campaign, semantic90 rebuild or #28 replay follows.
