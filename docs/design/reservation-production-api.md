# Reservation and spawn execution

The ordinary command path supports taskful system bodies and query rows.
A declaration supplies structural permission and a closed spawn operation through
`execution-command-permission`. The operation consumes the caller's actual command
queue and layout-indexed bundle. Resources are outside that bundle.

## Reservation ownership

[`Task.TNeed`](../../src/ecs/execution-reservation-task.bend) suspends the caller
with its declaration-bound permit. The driver takes the actual allocator from
World administration into one `Issuer` and returns it after service. Parallel
`TFork` branches retain separate payload and queue owners. Request service threads
the same issuer through the branches; it does not duplicate the allocator.

[`Buffer.spawn`](../../src/ecs/execution-command-buffer.bend) returns
`SpawnQueued{handle}` only after staging `Spawn{handle,bundle}` in that queue.
The handle contains the actual namespace, index, and generation returned by
reservation. Reservation refusal returns `SpawnRejected{bundle,error}` with the
input bundle and queue retained. No temporary identifier needs later remapping.

A reserved entity is Pending. Ordinary live queries do not include it until
publication. The current query keeps the live handles captured at admission,
including when its callback suspends for another reservation.

## Publication and errors

[`execution-command-publication`](../../src/ecs/execution-command-publication.bend)
passes queued spawn entries to
[`Materialization.apply_at`](../../src/ecs/execution-reservation-materialization.bend)
at the existing command barrier. Publication checks Pending namespace, generation,
and phase before inspecting the bundle. Structural permission, unique component
families, physical index, column shape, and selected-family vacancy are checked
before installation. Missing physical capacity can grow during installation.

The bundle follows the component layout. Each family contains its own optional
affine payload, and a pair retains both children. Successful installation refreshes
selected views, writes lifecycle stamps with the publication tick, and then marks
the reserved entity Live. The receipt contains the handle and previous payloads.
A refused publication returns the World, handle, actual bundle, and typed reason.
It does not implicitly cancel the reservation or partially install the bundle.

An ordinary handled body error retains commands already authored in the owner's
queue. The Task path completes peer ownership joins before the framework applies
its error policy. Whether commands are published depends on the existing schedule
and barrier settings. This behavior does not promise recovery from a fatal host
exception or process termination.

Explicit cancellation uses [`World.clear_pending`](../../src/ecs/world.bend).
It validates Pending authority and marks the reservation Consumed without rewinding
allocator progress or returning that index to the free list. This metadata operation
does not consume a separately retained command queue or bundle. Restore-wide
cancellation is defined separately in `restore-world.bend`.

## Taskful query scope

`Build.task_output_query` supports the paired-column taskful traversal.
`Build.task_general_query` supports a sparse unary component route with an actual
payload, cached view, and caller-owned output. Both use `Q.TaskOutputEach` and
`Q.each_task_output`, with the same abstract scope and permit supplied by the
system declaration. Closed split and merge callbacks divide and rejoin the output
owner; row callbacks return the actual payload through the Task continuation.

The generalized task path currently supports `Store.Sparse`. Its `Store.Whole`
branch returns `LayoutRefused` with the supplied scope and output untouched.
This API does not provide arbitrary taskful whole-layout traversal. Sparse traversal
refreshes each returned view and write stamp and retains row errors in its report.

The [Arena spawn consumer](../../examples/arena/spawn.bend) bootstraps entities in
the system body, then uses the saved actual player handle to select the player row
for projectile requests. Other rows preserve their owners. The first natural frame
authors two requests sequentially from that player row. Their returned handles are
retained in the spawn owner, and publication makes the new bodies visible to Step.

These are source contracts. Selecting a parallel policy does not establish native
worker participation, concurrent allocator ownership, or a speedup. Runtime receipts
and approved proofs have their own finite scopes.
