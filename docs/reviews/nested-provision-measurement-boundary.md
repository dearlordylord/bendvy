# Nested provisioning measurement boundary

Issue #34 requires equivalent feature work, with all observations retained.
The pinned TS Runtime seeds a private resource Map at construction; its initial
resource validation data is not a live public provisioning setter. A declared
write system cannot repair a missing resource because provisioning refuses that
system before dispatch. There is no direct resource-only provisioning setter.
The implementation contains `Runtime.restore`, but its public callable type is
gated by validated or transient component/resource descriptors
(`Snapshot.ts:59–76`, `Runtime.ts:1854–1855`). The current ordinary descriptors
do not satisfy that gate. Discovering the runtime function is not evidence of
a typed-public resource repair route. For eligible schemas, restoration also
clears pending queues/events, advances the tick and despawns/recreates entities
(`Runtime.ts:1818–1833`).

Measure actual common nested execution, duplicate/empty plans and missing
provision refusal, including complete world/queue/service observations. The
supplied retained service object permits publicly observable service repair and
retry; include that common path. Bend same-world resource repair/retry remains a
supplemental semantic control, not an observed paired TS operation.

Snapshot/restore is therefore excluded from the current nested adapter. An
eligible-schema restoration experiment belongs to #58–#60, with all its work
and limitations explicit. Its ratio cannot establish an advantage for identical
operations, and private Map mutation is not an approved public adapter. This
boundary changes no laws, regression contract or full-core performance target.
