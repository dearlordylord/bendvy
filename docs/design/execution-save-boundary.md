# Ordinary save and restore ownership boundary

GH91 now has an executable ordinary save/restore/resume path on canonical cached
Layout owners. GH92 has an executable ordinary graph, machine and lifetime-scope
restore path with retained receiver owners and subsequent scheduling. Ordinary entry
observations are not mathematical proofs or full runtime snapshot qualification.
All new persistence laws are unapproved and unproved; the five approved execution
helper laws retain their original scope.

## Schema, ownership and save

`execution-save-plan` binds persistence eligibility, nominal declarations, codecs,
projection and actual canonical Layout. Plain, Transient and Constructed each
retain an explicit access policy, orthogonal to persistence kind. Layout and
constructed traversal preserve that policy in the complete owner origin. Ordinary
examples explicitly choose Ordinary. Representing a protected resource does not
itself grant a protected restore write.

`examples/parallel-persistence/scheduled.bend` folds actual canonical Scheduled
command-owner buffers before any World projection. Pending save returns the same
actual App and Schema with RefusedPending; pending restore returns the same App,
source input and declaration/factory receipt with Pending. It preserves World,
system/command/guard/handler owners, both binding inventories, plan, rules,
settings and unapplied history. Save never flushes or discards commands. The
additional World.pending gate is distinct from that real owner fold.

Before metadata or payload projection, `execution-save-world` rejects Plain leaves
and duplicate keys across each complete component/resource layout. Transient is
omitted without projection. Constructed uses the actual retained codec and
projection, returning its payload and declaration even on invalid projection.
Projections may deliberately transform their returned owner; arbitrary callbacks
are not asserted to be identities.

The consuming traversal validates actual column arrays and bounds, performs the
canonical logical-to-physical conversion, and preserves untouched owners, cached
views and stamps without lifecycle writes. Snapshot version 2 contains full saved
keys, ordered fields/presence/Raw values/stamps, actual allocator next/high,
capacity/depth, every slot generation/phase, free/order lists, namespace, clock and
detached lifecycle journal metadata. Arrays and live owners remain in the World.
Detached metadata is not a serialized Reader or authority to restore callbacks.

## Restore and recovery

`execution-restore-admission` derives descriptors from the actual retained Schema
and validates metadata, version 2, duplicate full saved keys, exact ordered field
shape and presence/persistence policy, and complete codec values. Metadata checks
include source namespace/journal agreement, quiescent clock scopes, allocator
bounds/capacity/slot count, free/order/generation/phase consistency and nonfuture
field stamps. Canonical skipped Consumed slots from advance_floor may be absent
order; they cannot be free or live. Source journal registrations remain detached.

Receiver preparation rejects actual pending work and nonempty execution-clock
scopes before column inspection, constructors or clock-floor mutation, then
validates actual columns and allocation room. ActiveExecution returns the same
receiver World and enclosing App, including the active captured tick.
The concrete restore preflights room using the saved next-progress floor and
entity count before payload constructors. Typed construction stages all persisted
payloads through actual declaration-derived reversible factories before live
mutation; failures retain recovery and release staged owners through their undo
functions. Transient component payloads are not reconstructed.

After successful staging, actual allocator progress advances monotonically through
existing pure allocator adapters. No legacy transaction execution or cancellation
is invoked. Canonical command despawn produces lifecycle notices and owned removed
receipts, then actual reserve_id/mark_pending/materialization publishes rows and
returns saved-key-to-fresh-handle bindings. Source keys are detached mapping tokens;
receiver namespace and generations are never overwritten. Config replacement
retains its complete previous slot and preserves the actual transient resource.

Pre-mutation refusals return actual receiver owners. Unexpected post-clear
refusals are explicitly partial and retain remaining rows, removed owners,
publication receipts, mapping, source input, declarations, factories and undo
records. No whole-restore rollback is claimed. Scheduled reconstruction retains
original registrations, Local/captures, guard/handler owners and actual Reader IDs
and positions. Resume runs serial/native only after Restored.

## Ordinary consumers and observed scope

All entries are under `examples/parallel-persistence`; terminal renderers consume
owners only after their typed APIs have returned them. They contain no expected
output oracle or host test harness.

- `main.bend`: Alpha/Beta serial/native. Actor energy 41 survives, saved generation
  0 maps to actual generation 1, Config 701 becomes 702 after resume, the transient
  component is omitted, captures 101/202/303 survive, both locals reach run count
  2 and the original Reader observes one despawn notice.
- `pending-main.bend`: actual registered command body queues an Actor Array 515
  with automatic/finalApply disabled. On its earlier core, both save and restore
  refuse, the actual queue remains 515 with zero receipts, captures remain
  101/404/202/303, Reader cursor stays 0, both binding lists remain empty and
  unapplied IDs remain [2,3]. Actor 41/Config 700/generation 0 remain in the returned
  World. The current resource-policy caller reaches a shared relation dispatcher
  compile-time-route error; the earlier runtime receipt does not qualify that
  changed dependency.
- `floor-main.bend`: real source floor 4, separately created receiver namespace,
  actual mapping 1:0 to receiver 4:0, and resumed Config 700 to 701 for both schemas.
  An independently exhausted receiver at next 131073 refuses before constructors
  or resume, retaining Config 700, transient resource 909, two registrations,
  captures 101/202/303 and Reader cursor 0.
- `retry-main.bend`: two independent complete saves, invalid Config.limit codec
  input refusal, and retry of the second valid save into the same App. Rejected
  input and actual declaration/factory receipt remain owned while valid retry
  maps generation 0 to 1 and resumes. Only duplicable codec declarations are
  copied; affine payloads, factory states and App owners are not duplicated.
- `plain.bend`: generic World eligibility refusal for both nominal schemas,
  retaining actual Config Array 777 and cache 777. This is separate from Scheduled
  command-owner gating.

Each unblocked entry above completed an ordinary invocation with exit 0 within
its recorded source scope. Finite observations do not establish generic ownership
identity. Maximum-size source metadata export reached a machine stack failure;
that production limitation remains unresolved, with no increased limit or retry
campaign. Constructor-failure cleanup observations, source-current access/ownership
controls, independent Spec/Standards review and formal laws remain incomplete.

## Graph and machine extension

`execution-restore-extended-data` carries modern basic snapshot data, saved relation
groups, committed machine value/revision/stamp data and named lifetime membership
with complete saved entity keys. It excludes live callback,
pending transition, Reader and failure-channel ownership. This is a detached
representation, not a serialized executable App.

`execution-restore-extended-graph` adapts modern saved entity keys to the existing
pure graph validator and reuses its hierarchy/cycle checks. Existing graph mapping
rebuilds target edges and inverse ordering from actual fresh publication bindings.
No old World, transaction or runtime execution is invoked. This internal boundary
grants no protected resource access. Actual protected binding/publication must
preserve receiver failure channels, namespace and Reader IDs. Modern Cell
publication preserves receiver streams and nextStamp, installs admitted committed
value/revision/stamp and clears source pending intent. No old Init.State installer
substitutes for the actual Cell ownership shape.

The concrete `extended-main.bend` now executes real source-to-distinct-receiver
World restoration for Alpha/Beta. Its source owns Array-backed parent/child Actors
41/52, a hierarchy authored through canonical protected publication, and a
committed Waiting Cell at revision 7 with actual source transition history. The
target is independently created with Running revision 99, performs two real
transitions and registers an actual relation failure Reader before
restore. Complete basic/graph/closed-mode codec admission precedes construction
and mutation; receiver resource namespaces are also checked without changing
owners. Staged Actor owners publish through real fresh allocation, graph mapping
rebuilds the hierarchy, and trusted protected-slot/Cell continuations install it.
Every preparation, constructor, mapping and partial publication outcome retains
its actual owners and source data; no old transaction runtime is invoked.

The ordinary entry exits 0 for both nominal schemas: source keys 1:0/2:0 map into
receiver namespace 2/4 at full keys 2:1/1:1 after actual receiver despawns. Complete
Actor fields, hierarchy inverse ordering and Waiting revision 7 are observed.
These finite observations are not full GH92 qualification or mathematical proofs.

`execution-relation-restore` supplies the trusted protected-slot continuation:
Refused returns the same slot and affine source, while Ready installs an already
validated and remapped graph, returns the previous graph, refreshes the actual
cache and updates the slot stamp at the supplied publication tick. Its origin
must carry the exact ProtectedRelation policy. Store namespace, failure channel,
sequence and nextReader remain receiver-owned. Source validation and fresh-handle
mapping must precede calling this internal helper; its Ready constructor is not
a proof or a gameplay grant. Source well-formedness alone does not establish the
combined ordinary graph restore or its runtime behavior.
## Receiver history, scheduling and refusal

The ordinary `parallel-persistence/extended-main.bend` path now performs real
administrative machine transitions before save and before receiver restore. The
source commits Waiting at revision 7/stamp `0:8`; the receiver retains its own
two-event stream, sequence 2 and nextStamp `0:2`. Its actual pre-restore time is
`0:5`; committed restoration floors time to the admitted saved clock and advances
the publication boundary to `0:9`. Receiver cursors are not rebased and historical
events are not replayed. Restore clears pending transition intent.

Before restore, a registered receiver failure Reader observes an actual protected
self-relation refusal being published. The returned World retains channel size 1,
sequence 1 and nextReader 2; the original Reader retains its namespace/id/cursor.
Target entities are genuinely despawned and source handles map to fresh generation
1 target handles. These are bounded ordinary execution observations for Alpha and
Beta, not proofs. The actual retained failure Reader subsequently reads one
message, advances its cursor to 1 and reports no missed messages at time `0:9`.

`parallel-persistence/extended-resume.bend` builds the receiver's actual Scheduled
App before restore. Its actual pending fold precedes World admission. The adapter
retains system Local arrays 603/703, state-condition Local array 903, handler array
803 and its original registered failure Reader, both binding roles, rules and
deferred settings. The serial Alpha and native Beta ordinary runs observe restored
Waiting, execute a new Running transition at revision 8/time `0:12`, handle a real
body error and return all those owners. Receiver machine stream sequence/size
advances from 2 to 3, rather than resurrecting the source's four-event history.
This is a subsequent genuine schedule execution, not a replay of source intent.
The reader then consumes the retained receiver relation failure at time `0:12`.

`parallel-persistence/extended-refusal.bend` submits a self-membership hierarchy
using an actual saved full-generation key. Complete graph admission refuses it
before receiver mutation or factory construction. Input, namespace, receiver,
staging and row refusals rejoin the actual Scheduled App with both binding roles
and all its owners; post-mutation partial outcomes explicitly retain Held plus
the entire low-level publication outcome. The invalid-graph observation exports
the actual refused receiver: time remains `0:5`, both generation-0 entities remain,
the graph remains empty and the receiver remains Running/revision 101. A retry
with the retained valid snapshot on that same App restores and runs the genuine
subsequent transition, condition, handler and original Reader described above.
The malformed input and refusal reason remain in the typed retry result.

The actual third resource carries ProtectedLifetimeScope policy. Source setup
assigns the live parent through canonical namespace/liveness checks. The extended
snapshot exports `working:1:0`; complete admission rejects missing or duplicate
entity memberships before mutation. The same fresh binding map remaps it to
`working:2:1`. Trusted protected-slot publication preserves receiver namespace
(2/4), rebuilds the cached View, advances only its change stamp to the committed
boundary `0:9`, and returns previous members alongside the previous graph.
Source namespace and live scope capabilities are never imported. The enclosing
pending gate and original failure/retry and Scheduled transitions remain intact.
`extended-scope-refusal.bend` rejects duplicate scope key `1:0` and stale generation
`1:1` before receiver mutation, then restores valid membership and resumes the
same actual App. `extended-active.bend` opens a canonical execution scope before
restore: typed ActiveExecution refusal retains scope `[0:6]`, clock `0:6`, all
Local/guard/handler run counts 0, original Reader cursor 0, both binding roles,
receiver machine revision 101/stream 2 and scope change stamp `0:0`.

Modern scope queue/controller cleanup integration remains separate work. Scope
metadata currently imports the existing lifetime-scope Data definitions, which
still transitively import legacy modules; pure canonical type extraction is
coordinated separately and does not imply legacy runtime execution here.
These finite ordinary runs
do not establish exhaustive graph validation, rollback of partial publication or
formal owner preservation.

