# Public query cardinality and lookup contract (#29)

The existing closed heterogeneous `Compose.Plan` is the declaration, including
independent required/optional/with/without and lifecycle predicates. New
`QueryContract.count`, `single`, and `get` thread the original affine World back
on every outcome. An explicit cursor is an input; these operations do not advance
a registered reader.

`count` selects the live ascending handle snapshot and returns its cardinality.
`single` scans all matches before calling the supplied body: zero gives
`NoEntities`, more than one gives `MultipleEntities` with the actual count, and
exactly one invokes the ordinary abstract capability callback. `get` first checks
World-local identity and liveness, then query membership: invalid/stale/foreign
handles give `MissingEntity`; a valid nonmatch gives `QueryMismatch`. Both carry
the actual requested handle ID as `entityId`, retaining diagnostic correlation. Only a
successful check invokes the body. Expected callback/access failures return their
precise nested `Compose.Error`, roll back writes, and discard staged effects.

Selection runs in a temporary transaction which is rolled back before returning
any cardinality or membership observation; the body is invoked once, without
re-running selection. Existing pending commands remain owned by the World and
invisible until its normal barrier. Capabilities retain abstract affine context
confinement and Type-valued components; no storage owner or write grant is added
to a read declaration.

These are executable contracts, not approved universal proof laws. Finite controls
exercise exact errors, complete component views, actual Array owners, aliasing,
structural churn and pending-queue preservation. Compiling wrong-cardinality and
wrong-mismatch mutants must fail those public observations. The reference source
is pinned bevy-ts Runtime `makeQueryHandle`/`resolve` and Query error constructors.
TS lacks World namespace in entity identity; the existing approved foreign-handle
`MissingEntity` divergence remains explicit.

The current count/single scan is linear in the live handle snapshot and does not
introduce a cache. #30 supplies the storage/index integration; full workload
qualification remains #21/#23/#24. This decision does not weaken the unchanged
#28 paired regression gate or authorize any baseline update.
