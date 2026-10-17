# Retained cleanup continuation after slot reuse

This consumer reproduces the independently identified stale cleanup path using
actual returned owners and continuation frames. An IO-created ordinary World
spawns an affine two-cell array through Batch and a canonical component binding.
`Cleanup.drive` runs two steps from the actual handle, returning an actual
`Incomplete` finish continuation. That exact frame list is retained unchanged.

A separate ordinary typed despawn clears the old payload and stamps and releases
the slot. Another ordinary Batch spawn reuses the index at the next generation.
`Cleanup.units` then resumes the retained old finish frame against the returned
new World. Full-key validation must precede the schema clear callback. A final
ordinary component read observes the new payload.

Eight complete checkpoints preserve and render the physical allocator, full
keys/order/free lists, physical component array and lifecycle stamps, all returned
affine arrays, schema-clear/populate trace, graph edges and inverses, events,
pending callbacks, resource array, registration metadata, clock and actual
continuation frames. Opaque callbacks remain unexecuted by observation. The graph
is empty and the descriptor list is empty; this is the reached finish boundary,
not a relation-mode inventory.

The fix is the isolated full-key guard in relation-cleanup, cherry-picked as
95342180f from the core owner. Pure fixture and observer checks pass on pinned
CPU6/default five seconds. The concrete IO entry reports only three actual foreign
dependencies. Independent expected output and backend runs remain pending.
