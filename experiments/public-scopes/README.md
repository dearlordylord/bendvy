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

## Linked cleanup development observation

`linked-reference.mjs` executes ten complete checkpoints across two roots. A scoped parent owns an unscoped child and grandchild through linked hierarchy edges. Scope cleanup removes all three, including both unscoped descendants; an unscoped survivor with an ordinary relation remains with its complete payload, and its relation to the removed parent is cleared. Deferred and repeated cleanup observations are retained in `evidence/linked-reference-development`.

This follows `internal/World.ts:452` calling `destroyEntity`, whose linked relation traversal at line629 does not test scope membership. Thus unscoped membership alone is not immunity from linked despawn. The phrase “preserving persistent entities” in #45 must be reconciled with this actual pinned behavior before claiming that gate; no new divergence or persistence policy is selected. The initial exploratory run used an invalid spawn argument and failed before observations; its raw failure remains local. Corrected public component-tuple spawning passed the owned five-second Node run. This is development evidence only: source stability and raw streams were checked, without qualifying the full tool/configuration/reference closure or Bend acceptance.
