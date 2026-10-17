# Genuine foreign pending handle refusal

The actual IO allocator creates two same-schema Worlds. Both reserve their own
index-one, generation-zero entity through actual deferred spawns. The receiver's
actual Tx retains its pending-spawn undo and affine populate callback. The sender
World retains its own complete deferred Batch command stream.

The receiver attempts canonical typed despawn using the sender's actual pending
handle. Complete before/after Tx and sender observations preserve pending queues,
undo callbacks, physical allocator/component/resource owners, events, registrations
and clock. The receiver then cancels its own pending handle and applies the real
FIFO populate/clear barrier. Finally the sender applies its own untouched stream.

The matching physical index and generation make this a reached namespace guard
case, unlike foreign handles whose generations already differ. No fabricated
namespace, handle, receipt, callback result or generic Store substitute is used.
The observer retains opaque callbacks without executing them. Six complete
checkpoints use the unchanged first consumer's owner-preserving observers.

CPU6/default five-second source check reports only four actual IO dependencies;
no type or affine error. Independent oracle and backend execution are pending.
