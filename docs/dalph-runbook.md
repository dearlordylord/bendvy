# DALPH beta execution

Use an isolated Git clone and state directory for each selected issue root. A textual parent link does not select sibling tasks; native blockers select prerequisites. Keep T12 conditional redesign prerequisites explicit.

Configure remote publication to `refs/heads/master`, exact current base SHA, capacity 1, and activation/cooldown 30 seconds. Keep journal, evidence, task worktrees and integrator state in disjoint paths. Do not enable Dalph Node/pnpm worktree preparation for Bendvy.

Launch Codex with a dedicated provider home, preserving the required authentication and model configuration. Keep credentials outside Git with private directory/file permissions. Shared ambient Codex history stalled `thread/list` during our first integration; a dedicated home resolved it with the original protocol. Recovery of an existing attempt must preserve its exact session rollout and all Dalph state.

Record expected duration and an absolute stop time before each run. After requesting shutdown, prove the process exited and repository ownership was released before another invocation. Preserve unfinished state and reconcile it; do not recreate an attempt because polling timed out.

Delivery requires all three: `RunDisposition: Completed`, independently checked published Git lineage, and intended tracker completion. Exit 0 or empty status entries alone are insufficient. Run task-specific verification from the published commit.

Local retained T01 state: `/workspace/formal-proofs/.dalph-bendvy-beta`. Working executable adapter: `codex-diagnostic-proxy.py`, now metadata logging plus dedicated provider environment only. No protocol rewriting. Original provider home is untouched. Full observations: [DALPH.md](../DALPH.md).

TS reference: existing Node v24.20.0 can import the pinned core directly via `.ts` imports without installing dependencies. Use a small public API adapter for required checkpoints; import success alone does not prove trace observations. Extra upstream test tooling needs approval only when its adoption is actually necessary.
