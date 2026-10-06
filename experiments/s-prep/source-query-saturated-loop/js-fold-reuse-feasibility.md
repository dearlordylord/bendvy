# Read-only private Fold reuse feasibility

Actual joined Health final row+pool v3 uses an affine private PrototypeFlatFold
owner. Its closed loop passes the current state once to step and replaces the loop
state with the result. Step destructures fields then calls guard→live→taken→returned.
The opaque authored client receives the private row owner, not the Fold state.
No implementation is made by this review.

The fresh counted nine-world candidate has exactly131072 executed Fold constructors
at prototype_journalledger_health_returned and512 at pack; other Fold sites execute
zero. Thus the success-return constructor is an actual bounded seam, not inferred
from its presence in generated code. It represents one expression/callback in this
probe; no physical allocation or timing saving is established.

A feasible closed-program probe could thread the consumed state as a final argument
through the exact saturated step/guard/live/taken/returned success chain and replace
only returned's Fold literal. Preserve each original argument/projection/branch and
all original returned-field expression evaluation in field order, including Array.set
and fresh Cache/Some/Ledger/Handle constructions, before owner slot assignments.
Then assign only slots proven changed from the original state; selected must change
from the actual returned Handle. The step intentionally discards incoming selected,
so inventing an extra selected read would change the original projection work.

Fallback must stay original: failed validity/live/missing branches reconstruct and
return their complete new state. The carried stale Fold owner is dropped on those
branches, never used to overwrite the returned fallback state. Returned context
mutation/foreign fallback controls must prove this branch distinction. The current
selected/journals/ledger cannot be recovered from incoming owner after callback.

Needed guards: exact current source29/input hashes and entry family; unique static
loop state consumer; exact helper parameters/body branches and saturated call edges;
no helper shadow/reassignment/unknown escape; reserved binders; exact18-field literal
shape/order; scoped projections; original RHS evaluated before writes; unchanged-slot
claims traced through every helper argument to the original state field. No global
sidecar or broad rewrite of other Fold constructors is justified. New parameter
transport can change V8 behavior; measure actual time after finite gates.

This relies on source affine ownership and audited closed flow, not a universal
JavaScript alias theorem. Dedicated retained views, nonidentity fallback, fullfields,
Tx/suppression/live mutants and refusal controls must accompany any implementation.
Native already flattens this transport; do not claim Native savings from this seam.
