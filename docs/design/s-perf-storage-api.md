# Indexed candidate implementation boundary

Experimental #20 contract, following the independent architecture review. No new
universal law, production adoption or performance threshold is approved here.

`storage.bend` owns `Rows<M,A,F>`, `Row`, `Placement` and the six-field World.
Separate affine Main/Aux arrays and Data metadata share balanced depth/capacity.
Supported experimental IDs are 1..131072; zero/larger IDs reject before subtraction,
doubling or swap. This covers E11, not a public allocator exhaustion policy.

All helpers take explicit M/A/F type parameters:

| Helper | Result and obligation |
| --- | --- |
| rows_empty | Empty Rows, small balanced capacity |
| rows_high_water | Rows & U32; reservations do not change committed high-water |
| rows_extract(rows,id) | Rows & Maybe<Row>; bounds/live checked; caller owns extracted row |
| rows_restore(rows,row) | Rows; trusted same-ID restoration after extraction |
| rows_remove(rows,id) | Rows & Maybe<Row>; tombstone, preserving unrelated slots |
| rows_place(rows,row) | Placed{rows} or Rejected{rows,row}; no incoming owner loss |
| rows_can_place(rows,id) | Rows & Bool; non-consuming placement-domain preflight |

Extraction's temporary empty Type slots cannot escape a completed operation.
Main-only access and rollback touch Main and metadata only. Query traversal scans
ascending IDs through high-water, skips tombstones, and restores every transient
row. Live rows with Main absent remain live and return Mismatch for Main access.

Growth transfers each old owner once into the left half and creates a fresh,
equal-depth right half for every column. It changes no lifecycle stamps, reader
positions, command order or reservation IDs. Finite controls cover rollback across
growth and consumed failed-reservation holes.

Commands preflight the complete pending queue before applying its FIFO prefix.
Private checked apply returns Applied{world,changes} or CapacityRejected{world};
rejection preserves the entire original pending queue and all owned payloads.
Unsupported inputs must become an explicit harness capability failure, never a
successful no-op or MissingEntity. Legacy pipeline wiring requires an explicit
failure boundary or a validated supported-domain gate.

Files under `candidate/` override an immutable copied baseline import closure.
The original S-INTEGRATE sources remain available for comparison. High-water
scanning, tombstone capacity, compaction/remapping and general exhaustion are
recorded follow-ups; direct ID slots do not use Bevy's compact sparse-set layout.
