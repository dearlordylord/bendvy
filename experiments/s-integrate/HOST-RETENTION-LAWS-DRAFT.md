# E11 joined retention operation drafts

Status: exact public input matrix and comparison preparation. The Host's real
parameterized bulk invocation is still a dependency. No E11 Bend execution or
acceptance is claimed by this draft, input declarations, or an oracle self-test.
No new dispatcher BodyKind is declared here.

Subject to be bound: factory-created affine Motion/Health worlds, actual reserve
and command application, `Host` + `D.tick`, stable registered Fast/B/Late bases,
actual reader Run completion, actual frame holders, nominal Ping logs and actual
Handle lifecycle logs. Capacity is the source's public 65536. Trusted setup bounds
all finite counts/ticks before mutation; no production bounds are approved here.

The authoritative programs are the ten public cases in
`../s-integrate-trace/reference-retention.mjs` (pinned bevy-ts commit
3040a3b2a3f28fa8554d856f9ccb6bf5433fa334). Each schema executes five fresh worlds:

| Lane | Exact critical sequence and observations |
| --- | --- |
| message | Seed one full bundle/barrier; prime Fast then B; publish one 65536-value Ping batch; Fast reads it; publish one more; empty dispatch trims; B fails then same base retries with only last value and lag; Fast independently reads last value without lag; publish one oversized 65537-value batch; empty dispatch; B/Fast see empty with lag; genuinely late reader sees no historical lag and surviving added/changed marks. |
| removed | Prime Fast/B; reserve 65537 full bundles then barrier; both read full query/added/changed; remove Main for every actual handle, barrier and Fast in the SAME dispatch before the next frame; empty dispatch trims exactly first record; Late sees remaining records without historical lag; B fails/retries same records with lag; Fast independently sees empty without lag. |
| despawned | Same as removed, using actual despawn; both Main removal and despawn streams contain actual handles in original order, trim one record independently, and report lag independently. |
| unheld | Spawn two full bundles/barrier; remove first Main and despawn second/barrier; three empty dispatches; first Fast sees no historical records/lag. The first entity survives without Main; there is no arbitrary world replacement. |
| marks | Prime Fast; spawn one full bundle/barrier; Fast sees initial marks; actual declared write replaces slot0 by11 while preserving slots1..3=11,12,13 and all auxiliary/flag/metadata; three empty dispatches; first B sees old surviving added AND changed rows, complete current fields, no lifecycle loss. |

All query variants in E11 use Main required with optional Aux/Flag; full schema
fields match the source fixture. Every actual row/handle/message must be compared
before compact range output. A compact range is evidence only after every element
and all payload fields have been validated. Capture invocation counts come from
real base instances; B's first failing invocation counts and is not reconstructed
from successful completion. Actual public lag/diagnostics and dispatcher failures
are compared, not manufactured from input expectations.

Draft exact outcomes: failed read preserves saved boundaries and its registration;
independent Fast completion cannot complete B; skip semantics remain the existing
frozen contract; publication batches trim whole, lifecycle records trim individually;
registration affects historical lag but not retained-record visibility; no reader
registration means no retention holder; live added/changed marks do not expire
with sparse lifecycle logs. These are runtime equations to falsify, not approved
universal proofs.

Required compiling subject mutations once bound: advance B on failure; complete
all readers; split an event publication batch; group same-tick lifecycle records;
ignore registration; ignore actual holders; erase old surviving marks; corrupt a
nonzero payload cell or final row/handle; drop a snapshot dispatch. The comparison
preparation also perturbs ordered public evidence, including the last large-range
element, full payload metadata, lag, failure, and base count. Oracle sensitivity
alone is not subject mutation acceptance.

## Compact actual-Data interchange agreed with renderer owner

This is an optional E11 serializer path, not a runtime replacement. Empty sequences
are `[]`; an empty row sequence has no observed metadata to invent. A nonempty
row sequence is `query-row-range` with the **actual first complete QueryRow as
`template`**, namespace, idFirst/idLast, xFirst/xLast, count, and slot0 rule `x` or
`constant` carrying the actual first cell. Derive x from actual main cell1 minus1
only when subtraction is valid. Visit every actual row and validate:

- namespace equals the actual template; IDs and x ascend exactly1 without wrap;
- main cells1..3 equal x+1,x+2,x+3; cell0 follows the selected actual x/constant rule;
- all actual schema metadata, optional Aux fields and optional Flag fields equal
  the complete actual template, including absence/presence and every array cell;
- count and endpoints are accumulated from traversal, never caller expectations.

The decoder additionally verifies that the template is exactly the first expanded
row and endpoints/count agree. Metadata is retained from actual input, not schema
fixture constants. Motion frame and Health reserve/class are always retained.
Persistent marks `[11,11,12,13]` compress as x10/constant11; a first cell differing
on any later row is nonrepresentable unless it follows the selected rule.

Actual handle sequences use `handle-range` with derived namespace/first/last/count.
Nominal Ping sequences use `inclusive-contiguous-range` over actual codes. Every
member must be checked in original order without wrapping. `Read` scalar fields,
lag and actual Run boundary and `ReadDone` outcome/frame/tick are unchanged.
Any violated condition emits explicit `unrepresentable` with reason/index and
cannot compare successfully. No checksum-only or endpoint-only validation is
accepted. Decoder/encoder corruption controls remain distinct from actual joined
E11 executions and compiling runtime semantic mutants.
