# Ordinary lifetime scopes — private #45 candidate

`src/ecs/lifetime-scope.bend` supplies schema- and namespace-bound named scope
metadata around arbitrary affine component storage. It uses the existing world
reservation/activation and transaction queue. Scoped membership appears only
when the deferred spawn applies; cleanup selects membership at its own deferred
queue position and delegates the installed #44 linked cleanup. A scope is neither
a component nor proof that an entity is live. Same-world equal names select the
same membership group. Foreign namespaces reject with the existing MissingEntity
outcome; a rejected scoped spawn returns its incoming payload.

The first consumer uses trusted pure world setup, six real deferred spawns,
three relations and five complete physical observations. Scoped parents remove
linked descendants; ordinary unscoped survivors retain their payloads, while
references to deleted targets and inverse rows are cleared. This does not grant
an unscoped descendant immunity from linked despawn.

The existing #44 component-clear fixture hands each removed affine payload to a
retained owner list once. Complete observations return all active and removed
owners. This checks callback/removal disposition, not effectful Rust Drop or an
IO finalizer. The API introduces no finalizer policy, laws or proofs.

Reference order and commits: Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`
(state-scoped deferred despawn and recursive hierarchy despawn), Bend
`a950fd683c0d76f09794078e6174fe98a1492876` plus the pinned 2.0.35 guide, then
bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. The TS scope/failure/linked
preparation receipts remain their historical scope. The independent ordinary
oracle is authored before execution from the current operation and renderer
sources; no runtime output supplies expected values.

Remaining acceptance after this initial consumer includes ordinary app/provider
composition, actual IO-created independent worlds, foreign/schema/type controls,
failed/retried work and queue-position cases, a reached persistent-survivor
mutation, full feature timing and the unchanged #28 regression gate. No production
adoption, performance or full #45 closure is claimed by source checks.
