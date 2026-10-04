# P-OBS stage 3 — contextual proof inventory (before checks)

Exact approved endpoint: `explicit_flush_independent` at original law SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
Own this package only; canonical law/model/spec stay unchanged. Run Bend 2.0.34
version/guide before checks. Every checker/kernel invocation <=5 seconds.

| Proposed narrow link | Subject / role |
|---|---|
| Comparison reflexivity and row-match transport | Nat constructor induction; connect actual comparison decisions to slot identity. Existing lookup comparison symmetry may be imported read-only. |
| Spawn at one observed slot | `S.at(M.apply(Spawn,...),slot)` equals `S.one(Spawn,slot,S.at(rows,slot))`; no freshness premise needed. |
| Target at its own slot | `S.at(M.modify(target,action,rows),target)` equals target effect on original slot; include duplicate rows and despawn-all behavior. |
| Target at a different observed slot | Whole-list modification preserves that slot under inequality; comparison coherence needed. |
| FIFO prefix slot correspondence | Induction on commands links actual whole-list `apply_all` to independent per-slot `replay`; single-command correspondence is its actual dependency. |
| Command-prefix structural invariant | Uniqueness/bounds under admissible initial rows and pending spawns; only contextual flush-prefix obligations, not the unapproved blanket step-preservation law. |
| Observation bridge | Sort applied physical rows vs independent bounded materialization, plus observation of materialized rows. Actual interval/query uniqueness/bounds links required; do not assume the ongoing query theorem is finished. |
| Exact endpoint | Compose links under the original S.When premise; metadata/pending constructor cases. |

Start with actual checked slot/toolkit links. If the interval bridge/invariants
remain unresolved after bounded attempts, persist exact residual statements/goals
and a dependency graph. Neither finite witnesses nor proved partial links complete
the endpoint. No new policy/domain, unapproved catalogue law alias, dependency,
production layout or performance acceptance.
