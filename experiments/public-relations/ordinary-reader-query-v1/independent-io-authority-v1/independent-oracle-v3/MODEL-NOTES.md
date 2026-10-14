# #42 independent IO-authority oracle-v3

This leaf is a source-derived finite oracle. It was generated from the current
`consumer.bend`, `main.bend`, and `render.bend`, the copied
`mutation-composition-v1` fixture/operation/consumer, and the pinned ECS
world, namespace, system, transaction, relation, event, and failure modules.
The oracle does not invoke Bend, a compiler, a generated backend, or a runtime
and does not read candidate output.

`main.bend` executes Workshop and Garden in one process. The host namespace
allocator starts at 1 and is shared across the nominal schemas, so the outer
WorldIO handles are `(1,1)/(2,1)` for Workshop and `(3,1)/(4,1)` for Garden.
Each created world is seeded with IDs 1, 2, and 3. The full report keeps the
eleven checkpoints, six writer results, two inverse-query results, and one
delivery result for each schema. The first four writer requests are foreign
namespace refusals. The positive suffix uses the receiver's local ID 1 and
second reserved ID 2, so the same-world Parent relation is queued, applied at
the first positive barrier, queried as `Some([Handle{receiver,1}])`, then
cleared at the second positive barrier and queried as `Some([])`.

The target IO consumer's `own_lookup` at line 139 passes the canonical
WorldIO-created receiver to `W.enqueue` and then to the copied
`writer_registered`/`inverse_registered`/`failure_registered` helpers. The
imported mutation consumer's `start(~S)` at line 48, which calls
`F.fixture(~S,1)`, is not called by this target entrypoint. Therefore the
receiver state is namespace 1 for Workshop and namespace 3 for Garden, with
the target-created empty store, resource `[77,88]`, pending `tick`, and
registrations `ForeignParentWriter` id 1, `ParentInverse` id 2, and
`ParentFailures` id 3.

The four foreign writer requests reject correctly for the intended cross-world
reason: `ForeignSource` and `ForeignTarget` each include the peer namespace,
and both `ForeignClear` requests target the peer handle. The `queue_namespaced`
gate compares both endpoints (or the clear source) with the canonical receiver
namespace before staging a transaction, so each result is `MissingEntity`.
`LocalRelate` and `LocalClear` pass that gate and enqueue one relation command
each. `World.barrier` drains those commands FIFO; the first positive snapshot
after its barrier contains the Parent edge `1>2` and inverse sources `[1]`,
while the final snapshot is empty again.

The registered receiver's pending `tick` closure is retained through the four
foreign writes. Each accepted tracked system run advances the receiver clock
once (0 through 4), the deferred barrier advances it to 5 and drains `tick`
to 6 while retaining runtime tick 5, and the tracked failure-reader delivery
advances it to 7. The positive write advances to 8 and leaves one relation
command pending; its barrier advances to 9, applies the relation, and the
query advances to 10. The clear write advances to 11, its barrier advances to
12, and the final query advances to 13. The corresponding snapshot clocks are
`[0,1,2,3,4,6,7,8,10,11,13]`, runtime ticks are
`[0,1,2,3,4,5,7,8,10,11,13]`, and pending counts are
`[1,1,1,1,1,0,0,1,0,1,0]`. The writer cursors are
`[0,1,2,3,4,4,4,8,8,11,11]` and the inverse cursors are
`[0,0,0,0,0,0,0,0,10,10,13]`; the failure cursor remains 7 after delivery.
The missing Parent domain yields one empty `Reading{Key{2},[],False}` and
creates `Position{3,7,5}`. The positive relation produces no failure event.

`expected.stdout` contains the two explicit `IO.print` lines rendered by
`render.bend`, and `expected.stdout.gz` is deterministic gzip with `mtime=0`.
No actual stdout, historical output, or runtime measurement was used to fit
these bytes. If the owner changes the copied consumer binding or any pinned
source, this oracle must be regenerated and reviewed rather than reused.
