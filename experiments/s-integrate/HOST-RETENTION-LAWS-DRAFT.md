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
