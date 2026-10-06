# Explicit typed ECS application API

This is the bounded #26 public interface. It supports caller-authored component
families and closed, repeatedly executable gameplay callbacks. It is not full
Bevy parity or a qualified performance claim.

Declare a nominal Data schema token and family tokens. Declare an ordinary
affine Store containing `Column<Schema,Component>` fields. Components can be
affine Type (including actual owned Arrays) or Data. Each family declaration
supplies closed `take`, `put` and ownership-preserving Data `project` functions.
`Family` indexes those functions and the component/view types. Schema-local
wrappers can bind the repeated template arguments; no generator is required.
Lenses and bundle population/cleanup are trusted provisioning declarations.

Create worlds by threading one affine `World.Factory` through `World.create`.
Handles carry the resulting namespace and local ID. Foreign handles reject
before access/queue mutation even when local IDs coincide. Independent factory
roots and fabricated concrete root owners do not have universal authority
protection; concrete public constructors are not secrets.
The bounded allocator uses monotonic IDs, no reuse and a 131072 entity limit.
Production capacity/growth and exhaustion policy remain full-core follow-ups.

`Query.each_rw_read` iterates ascending live handles. The main family is required
and writable; the auxiliary family is read-only with `Required`, `Present`,
`Absent` or `Optional` selection. Optional presence is represented by
`Component.Access`. Gameplay is universally quantified over an abstract affine
context and erased operation templates. Thread the context through every read
and write. Erased getters can be invoked repeatedly; do not copy runtime affine
function closures. Replacement consumes a newly owned component; the library
retains its old owner for rollback. It does not expose destructive arbitrary
component conversion as a rollback-safe operation.

The broad writable callback bundle grants main replacement, auxiliary read,
resource read/replacement, Data event emission, deferred despawn and typed bundle
spawn. Declare every granted capability when registering this bundle, even if
a body uses fewer operations. More granular operation combinations are an
explicit follow-up. `Query.each_rw_read_resource` grants only main replacement,
main/aux reads and resource read; use it for movement. String registration
metadata alone does not constrain a
concrete runner. `Query.each_read` supplies only main/aux/resource reads and
collects Data output. It supplies no setter, event writer or command operation.
`Query.each_rw_read_events` grants main replacement, main/aux reads, event
emission and current-entity despawn, without resource or spawn operations.
The bounded query combinators cover two component families per callback;
arbitrary typed query tuples and combined multi-family filters remain a
follow-up rather than an implied complete query API.

Bind a closed query runner to a caller-authored rank2 gameplay body, then call
`System.register`. Registration returns the World and an affine
`Registry<...,runner>` owner. `System.run` threads that exact owner through each
invocation and retry; changing its runner index is a type mismatch. Namespace
and exact metadata are checked before execution. Runtime captured affine
callbacks and extensible heterogeneous schedules remain follow-ups. Static
typed products and sequential runner calls provide the bounded schedule.

The query executor owns one transaction across its selected callbacks.
Success publishes events and queues commands; failure restores its own writes
and discards its own tentative events/commands, preserving earlier commits.
Spawn reservations consume IDs even on failure. `World.barrier` applies commands
explicitly; schedule completion does not flush. Schema cleanup on public
despawn releases all component owners. `Structural` queues independent family
insert/remove operations with validation before queuing and at application.

`Events.create/read` threads independent affine reader owners through an
append-only Data event log. Retention, lag and affine event payloads are separate
follow-ups. `System.run_to_cursor` advances its supplied cursor only on success;
failure/refusal retains it. No universal proof/refinement follows from finite
compiler or application tests.
