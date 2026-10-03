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
