# #55 independent source-boundary audit (draft)

Preparation only. Author files are not frozen and no type/backend pass is
claimed. The author preserves source01/02 deadlines and source03/04 refusals;
formatter repairs remain pending. No checker/compiler/reference child is run by
this audit. Rust Bevy semantics, Bend owners/runtime and then TS scenario scope
retain their existing authority order.

The draft semantic model is derived from fixture construction, machine
current_view/is_current, relation-query spec_rows, relation-graph target/inverse
and World handle traversal. Workshop namespace31/base100 and Garden47/base200
remain independently nominal. Each has three live entities, four declared
optional relation cells per ascending row, repeated current-machine projections
and a Flow==7 condition. Link inverse order [3,1] differs intentionally from
Children [1,3]; neither may be sorted. Inspector cursor19 remains separate from
World clock13 and existing stream position5/cursor1/registered1.

Before freezing a complete wire oracle, the owner dump must include:

- All World fields: namespace,nextId,highWater,complete live tree,capacity,depth,
  complete arbitrary affine component/resource trees,events,pending count,
  registration id/name/access,nextSystemId,clock. Pending callbacks cannot be
  serialized as equality; count plus preservation of the owned list is the
  bounded claim. A later actual barrier-effect control would strengthen it.
- Both complete machine Slots: current,pending value/skipSame,previous,changed.
  CurrentView intentionally exposes current only, not pending/previous/changed.
- Every graph edge/inverse in stored order, descriptor key/name/inverseName/kind,
  all source/target IDs and complete inverse source lists.
- Every transition stream batch tick/item order; each Position id/cursor/
  registered; droppedThrough/frameStart; empty Level stream too. Do not activate,
  update or dispose any reader merely to observe this owner state.
- Every Notice variant with its complete payload: Original, RelationFailed
  (descriptor,operation,source,target,error), ComponentRemoved ID, CleanupPaused
  ordered complete frames/descriptors/remaining children. A generic
  "relation-failure" marker loses state and cannot establish full preservation.

Current dump.bend incorrectly substitutes Notice for actual Slot/Maybe<U32>
and U32.show; the author confirmed and is repairing this. Descriptor.kind and
all Notice serialization are also confirmed missing. Only Original17 is seeded
now: implementing a total formatter does not itself execute the other variants.
A representative relation-failure seed/reached serialization control is still
needed for any complete event-payload preservation claim.

The current fixture has only raw World registration metadata, no retained typed
Registry owner. Therefore this model qualifies no actual system cursor even if
World metadata remains equal. It does preserve actual stream cursor/retention
metadata and World clock. Frozen source-only authority controls should target
nominal machine token/schema substitution, relation schema/handle boundaries,
write-through-read and affine World/Frame duplication where the actual API
supports them. Raw machine Declaration constructors and resource-slot lenses,
raw relation Descriptor/Spec and fixture World are trusted; arbitrary raw lens
construction is not evidence of a safe ordinary undeclared-access boundary.

This candidate reads machine CurrentView and ordered relation rows. It does NOT
read transition events or relation failures through a public stream projection,
nor cover NextView, missing-machine condition preflight, relationship/failure
condition categories or runtime same-schema foreign-world handles. Preserving
stream contents while executing no stream read does not qualify stream read
noninterference. Those #55/#54 obligations remain open; no unselected reader
policy is chosen. No #55/#61 closure or #56 automatic dump adoption follows.
