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

Remaining implementation includes complete layout recipe composition and
eligibility before projection, complete entity/resource fields and membership
plus component/resource stamps, full ordinary save output, fresh receiver handle
mapping and lifecycle reconstruction, restore without legacy Tx, both resumed
execution forms, unlike schemas and intended ownership controls. The ongoing
taskful executor migration also changes the concrete Scheduled adapter shape.

The four laws in `test-fixtures/execution-save-laws/LAWS.bend` are unapproved,
unproved draft subjects. They describe only exact gate branching and Plain/
Transient owner return. They do not prove that any supplied inventory is correct,
that a callback cannot transform owners deliberately, or that complete save and
restore work.
