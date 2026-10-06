# Explicit typed ECS application API

This is the explicit typed API extended in #26 and #27. It supports caller-authored component
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

Use `Compose.each` with a closed `Plan{caps,select}` and an ordinary caller-defined
`Ops(H)` record. Each field selects an independently typed read/write/optional
capability; the library has no main/aux or fixed tuple-arity limit. `family_match`
and recursive `both` compose required, presence and absence requirements
independently of granted operations. `all` supports empty selection. Optional
reads return `Component.Access` without requiring presence. The Workshop
[declarations](../../examples/query-composition/declarations.bend) show reusable
schema-local binding helpers and named capability records without a generator.

Gameplay is checked for arbitrary affine H and receives only its declared
operations. Thread H through every call; closed getters can run repeatedly.
Aliases of the same component share the current storage through this one owner.
Replacement consumes actual C: Type and journals its old owner for rollback.
Read-only fields have no setter. Resource, event and command operations are
separate opt-in fields. Caller-defined Ops and closed adapters are trusted
provisioning; arbitrary type constructors are not a universal authority theorem.

`Compose.each_since` combines `lifecycle_match(Added/Changed)` with structural
predicates using a runtime reader cursor and authoritative typed column stamps.
Reads leave stamps unchanged; equal-value writes count as changes. Transaction
failure restores old payloads and stamps. The existing two-family `Query`
entry points remain available for earlier consumers; use Compose for new general
selections.

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

`System.cursor` reads the current cursor while returning its registry owner.
Use `System.run_tracked` for lifecycle readers: success consumes the authoritative
post-run clock, including the system's own writes; failure/refusal retains the
old cursor. `System.run_to_cursor` remains an explicit caller-supplied cursor
operation for existing consumers.

`Events.create/read` threads independent affine reader owners through an
append-only Data event log. Retention, lag and affine event payloads are separate
follow-ups. No universal proof/refinement follows from finite
compiler or application tests.
