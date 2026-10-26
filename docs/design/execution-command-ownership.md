# Deferred command ownership

The GH86 modules retain actual affine command payloads separately from gameplay
storage. Closed command-system registration and publication adapters are
implemented, including ordinary scheduler barriers and final-application settings.
Explicit structural despawn and query command authoring are implemented. Removal
notices, worker evidence and full issue acceptance remain pending.

`execution-command-buffer.bend` owns one component family's pending inserts and
removes, and explicitly granted entity despawns. Its removed-owner type is derived
from the complete schema: optional raw owners at leaves and products at branches. Enqueue transfers an incoming `Type` payload into the queue. It cannot
change storage. Publication checks the handle's namespace, generation and live
allocator slot, then applies commands in that buffer's enqueue order. Successful
commands return displaced or removed owners in receipts. Refused commands return
the incoming owner. Receipts remain owned by the buffer until taken.

`execution-command-local.bend` places the buffer beside the system's user local
owner. Its body adapter hides both the gameplay scope `H` and queue `Q`. Gameplay
gets typed insert/remove methods; it cannot inspect the concrete queue or supply
a World callback. The existing `Sys.Owner` returns this local on a body error or
admission refusal. `execution-command-system.bend` wraps that system in a
distinct `Owner` indexed by its complete schema and command route. Registration
binds the canonical concrete queue and command capability before provisioning
query grants. Runtime grants are monomorphic in that queue; the public command
body still receives a hidden `Q` and returns its actual owner.
`Tree.CommandLeaf` binds the physical scope to the same full schema, derives
the deferred system ID and composes the corresponding publisher. An ordinary
`Tree.Leaf` rejects a command owner instead of dropping its deferred inventory.

A declaration requests entity commands through a second abstract affine book `K`,
separate from the physical scope Builder book `B`. The closed entity grant
advances `K` and returns the typed despawn capability together. The adapter derives
permission from that same returned book and persists it beside the actual queue
and user local. Family-only command capabilities have no despawn method. This
permission inventory does not claim physical ownership of unrelated scope data.
Raw constructors remain trusted administrative provisioning; constructor secrecy
is not an authority guarantee. Admission, invocation and publication validate
the persisted permission against the owner's same closed program, without World
projection. A mismatched cache refuses before the affected body or clock advance.

The publisher initializes the schema's cached Data view only for an admitted
insert. Removal unwraps a displaced owner without refreshing it. An absent
component outside the column's capacity is removed successfully without growing
storage. Capacity-refused insertions retain their raw incoming owners. A despawn requires
the actual owner's entity permission and a current live handle. The whole-World
publisher removes all component families without refreshing them, returns each
raw affine owner in the receipt, then releases the cleared allocator slot. Repeated
stale-handle commands produce refusal receipts. Removal notices remain a separate
publication-boundary integration.

`execution-command-lifecycle.bend` retires, restores and rebinds the same
program-indexed command owner. It validates the persisted permission before
metadata changes, retains the actual local queue and receipts, and returns the
actual detached owner on refusal. Rebuilding a Schedule can legitimately produce
empty admitted history beside a retained queue; its exact pending query still
reports that queue. The lifecycle consumer checks this case, metadata/cursor
preservation and registration-exhaustion refusal with actual affine payloads.

The complete World must be reassembled before publication. Root cuts retain the
allocator and administrative state outside gameplay scopes, so a branch cannot
apply structural commands to a half World or duplicate allocator ownership.

## Synchronization behavior

The reference is Bevy commit
[`ad678262ce53b5d142fe49ee5e08caff6f00ab60`](https://github.com/bevyengine/bevy/tree/ad678262ce53b5d142fe49ee5e08caff6f00ab60).
Its [single threaded executor](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs)
marks a system's deferred state as unapplied after a handled body error. Default
final application then publishes that state. Skipped systems do not newly author
commands. This does not establish equivalent behavior for a handler that panics.

`execution-deferred-plan.bend` follows the reference's
[automatic synchronization pass](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/auto_insert_apply_deferred.rs).
It accepts an already validated flattened DAG in topological order and derives
edge boundaries from synchronization distances. An ignored edge carries pending
synchronization forward; an exclusive target overrides edge suppression.
Unconditional explicit barriers can be reused. Disabling automatic insertion
returns no inserted boundaries; final application is a separate executor setting.
The closed registry derives `hasDeferred` from its actual command owners.
It checks eligible IDs and the actual World registration before inspecting
pending queues, so a foreign or unselected retained queue does not advance the
publication clock. The scheduler accumulates admitted, unapplied IDs across
groups until a synchronization boundary; a body error still counts as admitted.
This history can include commandless systems and is not a queue inventory.
`Schedule.pending` inspects all actual closed command owners without projecting
storage, checking World applicability or applying anything. It returns the actual
scheduled owner and exact nonempty-queue status, including retained foreign
queues omitted from the current admitted history.

The planner example covers a chain, delayed synchronization across an ignored
edge, an explicit barrier, explicit barrier reuse, an exclusive target and global
automatic insertion suppression. Its complete output matches the expected file
on JS and native with one and four workers using the matching Bend 2.0.35 bundle.
The focused Rust reference also matched all eight expected observations for
automatic, ignored, disabled and explicit synchronization over two handled-error
runs. See `examples/parallel-commands/bevy-reference/README.md` for the source
binding and development commands.

The ordinary consumers additionally exercise registered owners through native
and serial schedule entry points. They observe retained affine payloads after
handled body errors, remove/insert receipts, automatic and explicit publication
before dependent conditions, ignored edges, final suppression and exact pending
status for commandless bodies. Complete independent oracles match JS and native
one/four outputs. The reviewed normal example check passes these consumers and
intended authority refusals. Equal native outputs do not establish actual
multiple-worker participation. These are normal development checks, not a
canonical qualification packet. No new mathematical law has been approved or
proved for these modules.
