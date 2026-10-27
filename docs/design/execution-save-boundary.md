# Ordinary save ownership boundary

This checkpoint starts GH91 on the canonical execution core. It is not a complete
save/restore implementation. No runtime or universal proof claim is made.

`execution-save-gate` accepts an actual affine application, a trusted framework
pending fold and its projection. A positive pending result returns that same
application with `RefusedPending` before calling projection. The callback form is
an internal adapter boundary, not authority for gameplay to supply its own
inventory. `examples/parallel-persistence/scheduled.bend` binds full ordinary
persistence to the actual `Schedule.pending` owner fold. It retains
World, command owners, guards, handler, both binding inventories, plan, rules,
settings and unapplied history when reconstructing the application.

The initial metadata-only adapter was replaced by that full-field adapter.
`execution-save-metadata` reads all actual allocator
slots with generation and phase, allocator progress/capacity/depth/free/order,
namespace, clock and lifecycle journal metadata. It returns the same live arrays
and owners. Detached journal registration metadata is not a serialized Reader
owner or cursor. Restore must remap namespace-qualified identities and retain
receiver-owned live callbacks and readers rather than copying this metadata into
their owners indiscriminately.

`execution-save-recipe` retains the ordinary persistence declaration. Plain
returns an explicit refusal. Transient omits a field without invoking projection.
Constructed uses the retained declaration's project and codec and returns its
actual payload and declaration after validation, including invalid projections.
`execution-save-leaf` applies those recipes to actual canonical cached chunk
columns and resource slots. Component reads validate real column arrays and
branch shapes before access, convert canonical logical indices once, preserve
the cached view and avoid lifecycle writes. Resource projection preserves its
actual cached view and slot stamp. Caller binding of nominal declaration key,
origin and persistence kind to the complete closed schema is still required.

The old `Snapshot.save` schema cannot stand in for that complete binding. Its
column wrappers differ from the canonical Layout column owner. Reusing its
detached Raw/codec types does not establish an equality of those owner types.

`execution-save-plan` now binds the complete static persistence extension to
canonical Layout and nominal declarations. Constructed leaves retain their actual
ordinary declaration/codec; the projection code is fixed in the same plan.
`execution-save-world` checks the whole schema for Plain leaves and duplicate
kind-local keys before metadata or payload projections. It traverses actual live
handles in allocator order and exports full keys, field presence, Raw values and
component/resource stamps into version 2 `execution-save-data.Snapshot`.
The Schema and actual World return through all outcomes. Projection callbacks
may deliberately transform payloads; this boundary retains their returned owners
and does not assert arbitrary projections are identities.

The plan traversal is a structural fold with normal erased payload parameters.
It does not attempt to monomorphize local payload variables as closed template
arguments. The field adapter's consuming structural column walk uses one affine
projection on the selected path, with whole actual column validation first. It
preserves untouched branches, cached views and stamp arrays. Both concrete Alpha
and Beta save entries in `examples/parallel-persistence/save.bend` instantiate
unlike nominal schemas with actual Array payloads and compile normally.

Remaining implementation includes complete ordinary scheduled output and pending
refusal consumers using these full fields, fresh receiver handle mapping and
lifecycle reconstruction, restore without legacy Tx, both resumed execution
forms, and intended ownership controls. The ongoing taskful executor migration
also changes the concrete Scheduled adapter shape. Trusted initial population
uses the canonical Pending materializer. Its erased-Type column growth repair
now allows the actual Alpha/Beta population and full-save entries in
`examples/parallel-persistence/save-fields.bend` to compile normally. No runtime
execution result is claimed from that source check.

`execution-restore-admission` observes descriptors from actual retained nominal
declarations and admits version 2 input against exact ordered field shape,
presence/value policy and full codec validation. Duplicate saved full entity
keys are refused. Both concrete nominal admission consumers compile. Input and
actual retained Schema return on either outcome. This is detached admission;
allocator/lifecycle metadata consistency, reversible typed construction,
receiver mutation, fresh handle mapping and resume still require implementation.

`execution-restore-stage` traverses admitted persisted fields with actual typed
constructor state and releases staged owners through retained undo functions on
constructor refusal. It reuses the pure constructor dispatch helpers, not the
legacy Tx restore lifecycle. The concrete `constructors.bend` and `staging.bend`
consumers construct Actor/Config Array payloads from their ordinary codecs and
retain the actual declaration-derived factories, staged records, recovery input
and Schema. Alpha and Beta instantiate this continuation and compile normally.
The raw continuation requires prior admission; `staging.prepare` couples it to
actual Schema/input admission and retains recovery on either refusal. It is not
a public restore operation and has not published payload into a receiver World.

Metadata admission now checks source namespace/journal agreement, quiescent
clock scopes, allocator bounds/capacity/slot count, free/order membership and
duplicate indices, generation/phase agreement with exported live entity keys,
and nonfuture field timestamps. Source journal channels and active reader IDs
remain detached observations; they will not overwrite receiver runtime owners.
The metadata and typed staging continuation compile for both nominal consumers.

Receiver preparation now inspects every actual cached column and asks the actual
allocator for room before mutation. It retains the actual World on pending,
shape and capacity refusal. The scheduled Application adapter must still fold
all actual owner buffers before invoking this additional World-level gate.
The new clear continuation calls canonical command despawn, retains all removed
Type owners in receipts and emits canonical removal/despawn notices. Unexpected
despawn refusal returns an explicit partial outcome and remaining handles.

The concrete restore path also checks the actual allocator's available room
against the saved `next` progress floor before invoking payload constructors.
It uses the existing pure allocator adapters, without invoking legacy transaction
execution or cancellation. After all rows are staged, it advances the receiver's
progress monotonically before the first clear/publication. Receiver namespace,
existing generations, free order and Reader owners are never replaced with the
source metadata. Floor/capacity refusal returns the same receiver and schema.
The ordinary roundtrip exercises its equal-floor path; a distinct higher-source
floor and capacity refusal remain additional concrete observation cases.
Both unlike nominal receiver/clear consumers compile. These pieces have not
yet been connected to complete fresh-handle publication, resource replacement,
ordinary Scheduled restore or resumed execution.

Fresh row publication now reserves actual receiver IDs, marks them Pending and
uses canonical Materializer.apply_at. Only returned receiver handles enter the
saved-key map. Every row retains displaced owners or an explicit refused bundle
receipt; any refusal marks the result partial. The concrete publication consumer
moves actual staged Actor records into bundles and retains their undo records.
Config replacement refreshes its new cache/stamp, returns the complete previous
resource slot, and retains the same transient resource slot. Actual Alpha/Beta
row preparation, materialization and resource replacement compile. These pieces
still need the enclosing restore operation and Scheduled resume adapter.

`examples/parallel-persistence/restore.bend` now connects receiver preparation,
schema/metadata admission, typed staging, row extraction, canonical clear, fresh
materialization/map and Config replacement. Unlike Alpha/Beta World continuations
compile. Refusal before clear returns the actual receiver World. Unexpected
clear/publication/resource interruption has an explicit partial outcome retaining
all live World owners, staged owners, removed/resource receipts, undo records,
Schema and detached input. This is an internal World continuation, not yet the
ordinary Scheduled pending-owner gate or resumed serial/native execution.

`RESTORE.bend` contains three additional unapproved, unproved actual-owner law
drafts for pending receiver refusal and empty clear/publication. Its normal source
check reports exactly three TODOs. These drafts are not behavioral proof evidence.

The ordinary `main.bend` consumer now creates genuine WorldIO namespaces and runs
Alpha/Beta with both serial/native schedule continuations. One normal Bend entry
invocation exited 0 and emitted four actual before/map/after observations: Actor
energy 41 survives restoration, generation 0 maps to fresh generation 1, Config
701 becomes 702 after resume, transient component omission is explicit, captures
101/202/303 survive, both local run counts reach 2, and the retained Reader reads
one despawn notice. The pending-owner adapter returns the actual Scheduled state,
including both binding roles and real reader/handler/system owners. These are
ordinary execution observations, not mathematical proofs or full runtime snapshot
qualification.

The ordinary `pending-main.bend` consumer adds a registered command owner and
disables automatic/final deferred application. Its actual body queues an Actor
with an affine Array containing 515. One normal Bend invocation of this entry
exited 0 for Alpha/Beta serial/native: save returned RefusedPending and restore
returned Pending, the queued Actor remained 515 with zero publication receipts,
captures remained 101/404/202/303, and the actual Reader remained at cursor 0.
The retained original system had run count 0; the author and reader had run count
1. Settings remained automatic=False/finalApply=False and the real unapplied
system IDs remained [2,3]. Both binding lists in this consumer are empty. A
terminal observation, performed after the refusals, exports the actual returned
World: Actor energy remains 41 and Config remains 700, with the source generation
0 and allocator order retained. The typed refusal outcome retains the actual App,
source snapshot, declarations and factories before this terminal renderer consumes
them. This is an ordinary ownership observation, not proof of generic identity or
full runtime snapshot qualification.

The four laws in `test-fixtures/execution-save-laws/LAWS.bend` and two subjects in
`SCHEMA.bend` are unapproved, unproved drafts. They describe exact gate branching,
Plain/Transient owner return and actual schema/World refusal branches. They do
not prove that any supplied inventory is correct,
that a callback cannot transform owners deliberately, or that complete save and
restore work.
