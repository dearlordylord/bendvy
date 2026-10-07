# Scope reference observations — #45 preparation

Executed pinned public TS runtime: two nominal roots, three deferred spawns,
queued cleanup, barrier visibility and repeated cleanup. The unscoped entity
survives. Two calls to `Game.EntityScope('scene')` select the **same scope key**:
`EntityScope.make` uses `Symbol.for` by name; cleanup deletes both scoped entities.
The token does not establish liveness. Membership belongs to each runtime world.

Run: `timeout 5s node experiments/public-scopes/reference.mjs`.
Exact source/output hashes and exit status: `evidence/reference/receipt.json`.

Initial exploratory assertion failed: the query row exposes `entity.id.value`,
not `entity.value`, and same-name scopes are canonical rather than fresh tokens.
The corrected oracle follows the actual implementation and independently asserts
all ten live-ID snapshots.

This is preparation, not #45 completion: linked cleanup, inverse/removal streams,
failed/retried work, actual foreign-world controls, affine disposal, Bend backends,
negative typing, mutations and equivalent timing remain required. Node type
stripping establishes no compile-time nominal restriction. #44 remains prerequisite.
No laws, proof approval, dependencies or new policy are introduced.

## Failure and independent runtime observations

`timeout 5s node experiments/public-scopes/failure-reference.mjs` executes
18 snapshots across two nominal roots. Failed cleanup contributes no deferred
command; a successful retry removes only scoped members at the barrier. Earlier
successful pending spawns survive a later system failure. A second actual
same-schema Runtime retains colliding local IDs when the first Runtime is cleaned.
This observes world-local scope membership, not foreign-handle rejection.
Receipts: `evidence/failure-reference/receipt.json`. The original reference cohort
is preserved separately. These observations are not Bend acceptance for #45.
