# DALPH beta-test journal

## Scope and authorities

- Goal: execute the approved Bendvy tickets #2–#13 through `/workspace/typescript/dalph`, retain all observations/problems here, and stop/report a complete obstruction.
- GitHub owns ticket lifecycle and native prerequisites; Git owns accepted commits and integration; Dalph's journal owns workflow history. This file is operator feedback, not another task-status database.
- Original canonical-defense and Dalph source repositories are not modified by target application work. Target tasks may modify their exact Dalph-owned worktree only.
- Specific law approvals and new dependency approvals remain gates. Publishing tickets and starting Dalph do not approve laws or waive capability/performance acceptance.

## 2026-10-03 — discovery and admission

- Dalph source observed clean at `c0219c729f3a1b5e698c387d5c581ea55f3f9699`; existing built CLI is present. Node observed as 24.20.0; workspace Codex CLI as 0.160.0, authenticated. No rebuild or qualification of Dalph source is claimed.
- Read Dalph working rules, README, navigation, production walkthrough, graph/claims architecture, production configuration, and exact executor/integrator prompts.
- `mise exec -- node packages/dalph/dist/bin/dalph.js --help` and `run --help` succeed. Built diamond `--dry` invocation exits 0 with semantic trace output. This only checks the controlled interpreter, not production delivery.
- Operator error: invoked the pnpm Codex shell shim through `node`; this produced SyntaxError. Correct invocation is direct execution under `mise exec --`. This is not a Dalph defect.
- Documentation discrepancy for beta adoption: the production walkthrough permits only a disposable single unblocked issue, while the product README and graph adapter support graph delivery. The user explicitly requested running real Bendvy work; use an isolated local clone/private-state boundary, preserving the real tracker and avoiding the full-scope parent as a runnable root.
- Graph selection caveat: authored `Parent` links are not GitHub sub-issue edges. Root #1 would not select all twelve children; #13 has conditional textual prerequisites and no native blockers, so choosing it early would schedule specification work without its ordinary evidence. Start #2 and #3 separately, then select only a root whose actual prerequisite graph matches the intended frontier.
- Worktree preparation is opt-in through `worktreePreparation: dalph-worktree` and assumes Dalph's own Node/pnpm helper. Bendvy is a Bend project; do not opt into that repository-specific helper. Existing ambient executor defaults and target instructions apply.

## Initial production timebox

Before starting a live command, append its exact target, non-secret config/state paths, expected duration and UTC stop time. Keep stdout/stderr and durable state outside the target repo. At the stop time send graceful SIGTERM, verify the process disposition/owned writers, preserve evidence, and diagnose rather than restarting from a silent observation timeout.

No production task has yet been started or completed at this entry.

### Issue #2 launch intent

- Target: `github:dearlordylord/bendvy#2`; capacity 1; expected duration 5–15 minutes.
- Recorded UTC: `2026-10-03T20:44:23.656762+00:00`; hard operator stop UTC: `2026-10-03T21:04:23.656762+00:00` (20-minute budget).
- Config: `/workspace/formal-proofs/.dalph-bendvy-beta/issue-2.json`; state/evidence retained under `/workspace/formal-proofs/.dalph-bendvy-beta`. Local integration clone is separate from the shared user workspace. Remote publication goes to Bendvy `master`.
- Commands use the existing built Dalph and its workspace Codex CLI. GitHub credential is loaded into the child environment from the existing gh login without printing or persisting its value.

### First live observations

- Issue #2 selected an allocated Run and started an executor turn in a separate exact worktree. Read-only inspection found new canary artifacts; no completion is claimed yet.
- Usability: deterministic attempt refs/worktree locators encode the whole opaque Run and task identity and are split into multiple long `part-*` path components. They are valid, but hard to read/refer to manually. A short operator-facing locator would improve diagnosis without changing durable identity.
- Usability: `executor-private-state.json` is an append-only sequence of integrity-wrapped JSON records, not a single JSON document. A normal JSON reader fails with `Extra data`; treating records separately works. A `.jsonl` suffix or explicit inspection command would make this clearer. This is an observation, not state corruption.
- Production stdout provides semantic snapshots rather than task-agent prose. For beta monitoring, actual process liveness and read-only Git/worktree observations are needed alongside public status; a live status stream alone does not prove task progress.

### Production T01: executor completed, delivery still pending

At approximately 20:50 UTC the executor returned accepted candidate `174caf68a397998fd44558d15c5d122542388d46`. Its T01 report records passing native/JS output and true/false checker controls. Remote master remained `4959a24` and issue #2 remained open; executor completion is not delivery completion.

Observed tracker evidence at positions 116 and 118 reports `CircuitOpen`: "GitHub request circuit is open after 120 requests in 60 seconds; retrying is locally deferred for 30 seconds". This is a concrete adapter-side polling problem, not evidence of GitHub credential failure. Current-status entries sometimes become empty while the Run remains live. Investigation continues within the original timebox; no replacement Run or manual publication was started. A read-only SQLite query also returned `database is locked`; journal was not modified.

### T01 delivery stall: bounded graceful stop

At 20:55 UTC integrator state was still `CandidateReady` (revision 3), last written at 20:48:41 UTC. Its worktree remained clean at the original base `4959a24`; no merge candidate or remote publication had appeared. Coordinator continued appending status/history events, often with empty delivery entries. Thus a live process did not demonstrate integration progress. After more than six minutes without candidate-state progress following executor completion, the operator requested graceful application Exit with SIGTERM rather than launch another Run or manually integrate. State and task candidate are retained for diagnosis. This is a delivery stall; the precise root cause has not been established, and CircuitOpen is an observed symptom rather than a proven causal explanation.

Graceful Exit observed at 2026-10-03T20:55:00.419234+00:00: `ApplicationExitDisposition/Succeeded`, direct child exit 0. No `RunDisposition/Completed` was observed. Independent post-exit checks: issue #2 OPEN, remote master unchanged at `4959a24d10c7661c2366ccdd0b3224d536ba3d99`. Post-exit read-only SQLite query succeeded. Integration evidence stops at positions 417 `IntegratorSessionFixed` and 418 `IntegratorRunStarted`; subsequent records contain tracker activity, with no integrator result or publication evidence. Preserve `/workspace/formal-proofs/.dalph-bendvy-beta` intact for reproduction/recovery; candidate `174caf68a397998fd44558d15c5d122542388d46` is retained in its Git object database. Operator journal changes remain local to avoid changing the remote baseline of the retained Run. Tasks #3 onward were not launched.

### Post-stop revalidation

2026-10-03T20:56:12.681962+00:00: direct child PID 2425807 absent; exit record remains 0; issue #2 still OPEN and remote master still `4959a24`. Dalph source advanced to `027bb726a3cabdda71a249141c670a0cc363f749`, but its only intervening commit changes tests and acceptance/scenario documentation, with no production-source repair. The dist entry timestamp is now 20:51:09 UTC, so a future invocation must not assume the original build artifact identity. This supplies no evidence that the integrator stall was repaired. Retained Run was not restarted, in accordance with the user instruction to stop on a complete jam.

### Configuration diagnosis and retained-Run recovery

The previous "complete jam" conclusion was premature: configuration and provider boundary had not been isolated. User explicitly requests configuration repair. Resume exact retained root #2, preserve journal/worktrees/base, change activation/cooldown to 30 seconds, and use an executable transparent Codex proxy logging only method/id/timestamps and response presence (no payloads/tokens). Expected 2–5 minutes; absolute stop 2026-10-03T21:15:50.837296+00:00. This is a diagnostic recovery, not a second allocated Run or manual integration.

Protocol probe: minimal unfiltered `thread/list` returned immediately; exact scoped query did not respond within 20 seconds; broad sourceKinds query eventually returned. Diagnostic configuration now uses a compatibility proxy which removes server-side cwd filtering, filters returned `data` by the exact cwd locally, preserves server pagination/cursors and sourceKinds, and asks for 100 results per page. This preserves complete scoped enumeration rather than fabricating absence. First diagnostic process exited gracefully before changing its executable.

Further discrimination: `thread/list` with sourceKinds and no empty modelProviders filter returns successfully. Proxy now omits `modelProviders: []` (uses the API default) and requests pages of 10; local exact-cwd filtering and original cursors remain. Recovered Run protocol at 21:10:11–13 UTC returned successful first and second pages, replacing the previous unanswered request. Root cause not yet fully isolated between cwd filtering and the empty provider filter. One diagnostic relaunch was attempted before the previous five-second drain was proven complete and was correctly rejected with `startup.ownership_conflict`; operator sequencing mistake. Previous PID exit and absence of repository lock were then checked before the next invocation. The launcher was fixed to avoid replaying old log records as current events.

Dedicated provider home recovery: use private 0700 `codex-home`, copy only auth/config and the exact accepted executor session rollout, with auth/config files 0600. Do not copy the global history/database or mutate original home. Remove protocol parameter rewriting; proxy now only logs metadata and supplies isolated provider environment. Full original Dalph thread/list semantics retained. After SIGTERM graceful Exit reported TimedOut and process remained live while provider list continued; SIGTERM sent to exact dedicated process group to stop own adapter processes (no global daemon targeted). New diagnostic stop deadline 2026-10-03T21:22:42.391076+00:00.

### Configuration repair verified: T01 delivered

Dedicated provider home with original protocol parameters enabled integration immediately: integrator turn completed at 21:13:30 UTC. Dalph then published merge `1d2c7e7681c665429a09a748632bcc3ba2b0c769` with exact parents `4959a24d10c7661c2366ccdd0b3224d536ba3d99` and task candidate `174caf68a397998fd44558d15c5d122542388d46`. Independent GitHub read confirms #2 CLOSED, remote master matches merge; same retained Run emitted `RunDisposition: Completed` and direct child exited 0. Main worktree pulled fast-forward; coordinator reran `./experiments/t01/run.sh`, exit 0 with true/false verdicts and matching native/JS output 42.

Correction: this was not a demonstrated complete jam. Operator should have isolated the provider home and diagnosed protocol calls before declaring blocked. The repair is configuration-only: isolated Codex home, original protocol, 30-second activation/cooldown. The earlier parameter-rewriting workaround was removed. Evidence supports shared-home thread enumeration as the failing boundary; its precise internal Codex cause is not established. Source repositories Dalph and jev were not edited.

### T02 configured using repaired provider setup

Issue #3 uses separate clone/state `/workspace/formal-proofs/.dalph-bendvy-beta-issue3`, base `ab41a899ec3cb44558e3f1a9c7eccd41c5cb2122`, capacity 1, 30-second activation/cooldown, and the verified dedicated-provider-home executable adapter. T01 Run has terminal completion and exit before starting T02. Expected 5–15 minutes; absolute stop 2026-10-03T21:36:12.898900+00:00. Dependency adoption still requires concrete approval, as required by #3; unavailable trace observations must stay explicitly unverified.

Operator reference-runtime check: existing Node v24.20.0 imports pinned bevy-ts `packages/core/src/index.ts` directly (13 exports, exit 0); no package installation needed. Worker had provisionally interpreted reference execution as dependency-blocked. Attempt to deliver evidence through a separate Codex `turn/steer` client returned `thread not found` because that client does not own the active provider thread. No turn was duplicated or resumed; active executor left intact. Operator feedback: beta host lacks an obvious public route for safe in-flight task steering. Scope still permits source-derived trace descriptions, but dependency-free runtime verification should be considered before any downstream gate is called blocked.

### T02 delivery verified with repaired configuration

Issue #3 Run completed, direct child exit 0, independent tracker read CLOSED; remote/master `0d52cd7d6930961606b07a7da43080fce23f6d9a` has parents `ab41a899ec3cb44558e3f1a9c7eccd41c5cb2122` and accepted candidate `424018ac781cecd7144793aab99128e77d800f42`. Main checkout pulled fast-forward. Independent review found a rollback bootstrap ambiguity, which worker repaired before final review. Deliverables are `docs/reference/{core-map,traces,report}.md`; runtime TS goldens remain missing, as explicitly reported. This catalogue completion is not a comparison gate pass. Dedicated provider home works for both executor and integrator of the fresh Run.
