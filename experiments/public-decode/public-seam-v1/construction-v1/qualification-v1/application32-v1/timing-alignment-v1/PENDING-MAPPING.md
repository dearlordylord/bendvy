# Pending observation mapping (source-only candidate)

A receipt describes one accepted application operation with complete payload, not
one opaque World closure. A successful main Spawn therefore has two logical
receipts pending (preexisting Marker + Spawn) but three native pending closures.

Pinned current source: commands.bend28–31 creates one spawn_apply closure when
reservation succeeds; bundle-batch.bend109–111 invokes it with Unit, then
bundle-batch.bend71–79 adds actual payload delivery with B.enqueue. The queue
provider stages one Marker closure. TS commands.spawn is one debug command; its
actual debug dump remains in the complete TS supplement.

Common candidate fields: logicalPendingCount counts actual app FIFO receipts;
receiptLoweringMatches checks the source-bound relationship to actual pending
storage. Native weights are two for ComponentPayload spawn and one for Marker;
TS additionally checks real debug command tags/origins and count. These bounded
instrumentation checks do not inspect closure payloads or equate internal queues.
Full native Snapshot.pending, Store.receipts and TS pendingCommands are retained.
No ECS policy, owner or delivery semantics changes. Whole independent models
must assert every queued owner and actual barrier effect separately.

Unknown receipt kind/system/payload combinations are Unsupported/throw and fail
acceptance; there is no default lowering weight. Independent reviewer confirmed
this bounded mapping before the observer edit. Full model freeze remains pending.
