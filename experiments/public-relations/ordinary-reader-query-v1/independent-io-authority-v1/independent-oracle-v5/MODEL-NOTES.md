# #42 independent IO-authority oracle-v5

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
creates `Position{3,7,5}`. The same successful delivery also activates the
declared Parent domain for failure-reader id 3, even though no failure event
was published. Its source shape is
`[Domain{Key{2},Queue{[],[],0,0},[3]}]`: a one-element domain list containing
an empty queue with one registered reader. That domain is retained by every later runtime state, including the
two positive relation snapshots and the final cleared snapshot. The positive
relation produces no failure event and therefore never changes the domain's
queue.

The component store text deserves one composition detail. `fixture.bend`
defines `tree` as a generic array renderer: its `ALeaf` branch calls the
element `show` function and then `leaf` wraps that returned text in `L(...)`.
`show_components` passes `show_slot` to that tree, so the four physical slots
are rendered as `L(absent)`, `L(P(...))`, `L(P(...))`, and `L(P(...))`. The
payload's own `first` and `second` arrays are separate nested trees and already
carry their own `L(number)` leaves. The live boolean tree, resource number
tree, graph/list renderers, notice/domain/position lists, registration views,
snapshot arrays, argument arrays, and report `Maybe`/list layers were checked
against their corresponding source composition and retain their v3 forms.

The inverse registry cursor is another observed state field. `system.bend`
`run_tracked` preserves a failed cursor but on a successful tracked run uses
the resulting world clock. `consumer.bend` calls the inverse query through
that path, so the inverse cursor remains zero through the pre-query snapshots,
is 10 in the snapshot after the relation query and in the following clear
snapshot, and is 13 in the final snapshot after the second query. The writer
and failure cursor traces remain as in v3. The domain trace is `[]` through
checkpoint 5 and the empty activated Parent domain at checkpoints 6 through
10.

`expected.stdout` contains the two explicit `IO.print` lines rendered by
`render.bend`, and `expected.stdout.gz` is deterministic gzip with `mtime=0`.
No actual stdout, historical output, or runtime measurement was used to fit
these bytes. If the owner changes the copied consumer binding or any pinned
source, this oracle must be regenerated and reviewed rather than reused.

## Source-derived transition audit

The snapshot trace is derived from the operation wrappers, rather than copied
from an execution. `K.with_world` advances the receiver world once before each
tracked writer or inverse query; `Sy.run_tracked` then adopts the resulting
world clock on success. `B.barrier` advances once to its barrier tick and drains
pending commands FIFO. The receiver's initial `F.tick` command is drained at
tick 5 and itself advances the observed world clock to 6. `K.run` then advances
the failure-reader delivery to clock 7, calls `Read.activate` before routing
events, and its tracked registry cursor becomes 7. `Read.activate` delegates
the missing-key case to `D.activate_one`, which constructs the empty Parent
domain with reader id 3. The resulting eleven receiver checkpoints carry the
following state trace:

| checkpoint | source transition | world clock | runtime tick | pending | writer cursor | inverse cursor | failure cursor | domains |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 0 | initial `C.start` state | 0 | 0 | 1 | 0 | 0 | 0 | `[]` |
| 1–4 | four foreign tracked writes | 1–4 | 1–4 | 1 | 1–4 | 0 | 0 | `[]` |
| 5 | barrier tick 5, then queued `F.tick` | 6 | 5 | 0 | 4 | 0 | 0 | `[]` |
| 6 | tracked failure-reader delivery and domain activation | 7 | 7 | 0 | 4 | 0 | 7 | `[Domain{Key{2},Queue{[],[],0,0},[3]}]` |
| 7 | local relation write | 8 | 8 | 1 | 8 | 0 | 7 | `[Domain{Key{2},Queue{[],[],0,0},[3]}]` |
| 8 | relation barrier, then inverse query | 10 | 10 | 0 | 8 | 10 | 7 | `[Domain{Key{2},Queue{[],[],0,0},[3]}]` |
| 9 | local clear write | 11 | 11 | 1 | 11 | 10 | 7 | `[Domain{Key{2},Queue{[],[],0,0},[3]}]` |
| 10 | clear barrier, then inverse query | 13 | 13 | 0 | 11 | 13 | 7 | `[Domain{Key{2},Queue{[],[],0,0},[3]}]` |

The first inverse query sees the applied Parent edge and returns
`Some([Handle{receiverNamespace,1}])`; the clear is still pending in the next
checkpoint, and the second query returns `Some([])` after the clear barrier.
The failure reader's `Position{3,7,5}` remains visible in the subsequent
snapshots. `Snapshot` takes the registry views and domains after each
operation, so the inverse cursor values 10, 10, and 13 and the activated
domain are part of the expected bytes.
