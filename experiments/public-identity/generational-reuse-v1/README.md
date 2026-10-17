# Ordinary generational reuse consumer

The actual World IO namespace allocator creates two same-schema Worlds. Ordinary
Batch spawn uses one typed component declaration/binding and affine arrays.
Schema cleanup retains the removed arrays, clears stamps, emits the old full
identity, then releases the physical slot. Query order follows logical creation
order. Plain liveness deactivation retains its slot and opaque component storage.

The source performs A/B activation; queued A cleanup and C reservation before
that cleanup executes; D reuse after cleanup; stale A read/write/despawn and
foreign-world despawn refusal; E deferred spawn/cancel FIFO; failed recycled
reservation with returned array; plain D deactivation; and another ordinary
spawn that cannot reuse either the consumed failed slot or D's retained slot.

Every checkpoint observes both actual Worlds, complete physical allocator slot
arrays, generations/phases, free/order lists, physical component arrays/stamps,
returned owners, trace, resource array, events, retained command count,
registrations, write clock, all returned handles and actual query order. Opaque
callbacks are counted and returned unchanged. The physical column observer
supports the ordinary Column/Indexed forms used here; prepared columns are not
created by this source. Refused write and failed Batch returned arrays are
explicitly handed into the store's retained owner list after observation.

Pinned CPU6 five-second source checks pass for the pure fixture, observer and
scenario. The concrete IO entry reports only its four actual foreign-dependent
definitions. This freeze contains no expected output or runtime result; the
independent oracle and first JS/Native pair are pending. Relation, scope,
snapshot/decode and other dependent migrations remain work before integration.
