# Lifecycle notice journal candidate

Status: architecture candidate A, not implemented or approved. This does not
change the GH85 contract or establish a law.

## Ordinary usage

An application declares component layouts and command programs as today. Removing
a present component or successfully despawning an entity automatically appends
lifecycle metadata at the same publication boundary as the actual mutation.
Gameplay never calls an event emitter to make that observation true. The actual
removed affine component owners remain in the existing command receipts.

During administrative application construction, a reader is registered for a
closed component layout leaf or the despawn stream. The resulting affine reader
is placed in the system's actual Local. Its closed Program requests the matching
lifecycle read capability. Each `next` returns the same reader with its cursor
advanced to the yielded item. Returning a body error preserves that Local and
therefore preserves consumed progress. A condition that prevents the body from
running does not consume that body's reader. A condition with its own reader
owns a separate Local and cursor.

## Grounded paths

`execution-command-system.publish` validates the actual command owner's derived
permission and registration before `execution-command-publication.apply_at`.
The latter drains the owned queue in FIFO order. Its family interpreter returns
`Buffer.Applied{handle, previous}` or `Buffer.Refused`; despawn returns actual
`Buffer.Despawned{handle, removed}` or `Buffer.DespawnRefused`. These are the
points at which real mutation and actual removed-owner presence are known.

The root scheduler publishes before dependent systems/conditions execute.
`execution-state.separate` then detaches Administration from storage Scope.
`execution-parallel-rootcut` physically partitions component/resource owners,
while `execution-parallel-scope.allowed` installs each actual owner's captured
execution window. An immutable notice view belongs beside that window, not in a
shared mutable World passed to workers.

Today `World.events` is `List<E>`. `W.emit`, `events_view` and `events_replace`
append, observe and replace that user event domain. Neither an arbitrary E nor
the existing closed command Program can manufacture a lifecycle event value of
E. Legacy `removals.finished` advances only on success and cannot implement the
new per-yield semantics.

## Types and signatures

The following is a design sketch, not Bend source or a new public escape hatch.

```text
EventJournal<S,E> : Data {
  user: List<E>,
  lifecycle: NoticeLog<S>
}
NoticeLog<S> : Data {
  previous: List<Sequenced<Notice<S>>>,
  current: List<Sequenced<Notice<S>>>,
  nextSequence: Nat,
  droppedThrough: Nat,
  nextReader: U32,
  activeReaders: List<ReaderRegistration>
}
Notice<S> : Data = Removed { familyKey, namespace, entityKey, publicationTick }
                    | Despawned { namespace, entityKey, publicationTick }
Reader<S,ClosedStream> : Type { namespace, id, cursor }
View<S> : Data { namespace, retainedRows, droppedThrough, nextSequence, activeReaders }
Read<S,H,ClosedStream> : Type {
  next: H -> Reader<S,ClosedStream> -> H & Reading<S,ClosedStream>
}
Reading<S,Stream> : Type = Item { reader, notice, missed }
                        | Empty { reader, missed }
                        | Refused { reader, reason }
register(World, ClosedStream, Start) -> World & Registration<Reader>
remove_reader(World, Reader) -> RemovedReader | RefusedReader { World, Reader }
append_removed(World, ClosedLeaf, actualHandle, tick) -> World
append_despawned(World, actualHandle, tick) -> World
maintenance(World) -> World
```

`World` keeps its constructor field count, but its events field becomes the
journal. User-facing E event APIs project and replace only `journal.user`.
`Administration` owns the complete journal. `Scope` carries a reusable `View<S>`
snapshot produced by separation after any preceding barrier. Root partitioning
copies only that Data view. The canonical lifecycle grant derives stream identity
and access metadata together from the selected closed layout leaf; despawn uses
a distinct closed stream selector. There is no free String selector in ordinary
Program construction and no caller-supplied World callback.

`Notice` stores the namespace and full entity key taken from the actual command
handle. That includes the generation, so an index reused for another entity does
not alias the old observation. It is an observation of removal, not fresh live
entity authority. The foundation log must not import World because World imports
the log. It can import entity-key and carry the nominal S phantom. The capability
can expose a removal identity directly; any conversion back to W.Handle is an
administrative adapter and cannot resurrect a dead entity.

## Publication ordering and ownership

The family path records whether the queued operation was removal before moving
its incoming payload. An applied insert/replacement does not emit Removed merely
because it returned a displaced payload. An applied remove emits one notice only
when its actual receipt contains a previous owner. Removing a missing component,
a foreign handle, or a stale entity emits none. Refusal preserves the original
payload/queue/receipt behavior.

Successful despawn emits one Despawned notice and one Removed notice for every
actually present family in `Removed(layout)`. A structural traversal threads each
actual Maybe owner back into the same receipt and returns only reusable family
keys for present leaves. It never invokes a refresher, drops an owner to inspect
presence, or duplicates an affine owner. Full handle namespace admission and the
allocator's live-generation check remain before mutation. Repeated stale despawn
therefore emits no duplicate notice.

Notices are appended before returning the published World. Readers admitted after
that barrier see the completed mutation and journal together. Suppressed final
application leaves commands pending and emits no premature notice. Normal body
errors still publish at the applicable barrier/final policy. Invalid schedules,
admission refusal and unexecuted bodies do not manufacture writes or notices.

## Retention, lag and lifecycle

The candidate uses previous/current maintenance generations, matching the pinned
Bevy event/removal model's finite retention rather than success acknowledgements.
The ordinary application maintenance boundary moves current to previous and drops
the older generation once per application update, including updates with handled
body errors. Publication itself appends to current. The exact placement of that
maintenance boundary must be selected in the architecture decision before coding.
A bounded number of generations is not a bounded number of events if an update
can publish arbitrarily many events; a hard item limit requires a separate
explicit contract and must not be silently claimed here.

Dropped sequence progress remains observable. A valid reader behind the retained
floor reports its missed count, advances to that floor, and then yields retained
matching notices one at a time. Independent readers do not mutate each other's
cursor or retain all historical notices indefinitely. A body that consumes two
items and returns an error retains the second cursor. Refused reader access
returns the same token and cursor. Empty reads may acknowledge the retained floor
when reporting lag, but do not claim an unseen matching item was consumed.

Registration belongs to the actual World namespace and a fresh reader ID. Reader
limit refusal precedes registry mutation and returns the unchanged World. A
foreign World rejects the actual reader before inspecting/updating its cursor.
Retirement removes the active registration only when the same namespace/ID is
validated; refusal returns the actual affine reader. Re-registration allocates a
fresh ID, so an old token cannot become active accidentally.

## Migration cost and alternatives

The journal changes the events field type wherever World is structurally
reconstructed. Most forwarding constructors retain their arity and field name,
but detached `events:List<E>` helper parameters must become EventJournal<S,E>.
Creation initializes the journal. User event observations/fixtures that destructure
World must project its user list. W.events_replace must preserve lifecycle state.
Command publication and execution Administration need the same forwarding change.
Scope's added view requires migration of access/query/root split/join constructors
and new cached-view confinement controls, including unlike schemas/family keys.
Existing user-event behavior needs full affected normal checks after migration.

An optional arbitrary publisher callback is smaller mechanically but lets ordinary
applications omit or forge automatic lifecycle observations. Putting mutable log
owners into every worker reintroduces shared state and does not fit physical root
partitioning. A closed recipe-derived resource sink is another viable candidate
if it can prove every ordinary command route installs and publishes through it;
it should be compared separately before selecting this journal.

## Evidence still required

Implementing this shape would still require independent fast/slow readers, lag,
per-yield progress followed by body error, false conditions, admission refusal,
genuine foreign Worlds, retirement/refusal, repeated remove/despawn, stale
handles and index reuse across two nominal schemas. Complete observations must
include actual returned affine payload receipts, the full retained journal,
registration state, cursor state and all affected World/component/cache metadata.
Both parallel forms, JS/native/serial execution and actual reached metadata paths
remain acceptance gates. No finite observation is a universal preservation proof.
