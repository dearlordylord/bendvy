# Ordinary save ownership boundary

This checkpoint starts GH91 on the canonical execution core. It is not a complete
save/restore implementation. No runtime or universal proof claim is made.

`execution-save-gate` accepts an actual affine application, a trusted framework
pending fold and its projection. A positive pending result returns that same
application with `RefusedPending` before calling projection. The callback form is
an internal adapter boundary, not authority for gameplay to supply its own
inventory. `examples/parallel-persistence/save-boundary.bend` binds it to the
actual ordinary machine application's `Schedule.pending` owner fold. It retains
World, command owners, guards, handler, both binding inventories, plan, rules,
settings and unapplied history when reconstructing the application.

The concrete consumer currently captures metadata only. Its result is explicitly
not a restorable snapshot. `execution-save-metadata` reads all actual allocator
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

The four laws in `test-fixtures/execution-save-laws/LAWS.bend` and two subjects in
`SCHEMA.bend` are unapproved, unproved drafts. They describe exact gate branching,
Plain/Transient owner return and actual schema/World refusal branches. They do
not prove that any supplied inventory is correct,
that a callback cannot transform owners deliberately, or that complete save and
restore work.
