# S-PREP bounded candidate proposal — unapproved

Source pin `56b72f6`, #22 child of #21. This is one concrete design for independent design/Spec review before implementation. No core, law, proof, dependency or production layout changes accompany it. The source-supported motivation is `candidate/query.bend:read_rows_start/read_rows_go`: queries increment every logical ID through committed high-water; `rows_extract` probes metadata and transfers/restores both affine columns for each live row. This establishes operations performed, not a measured bottleneck. Failed large Readers output phases additionally implicate authored observation/transport work; membership changes alone have no demonstrated deadline remedy.

## One change: ordered occupancy tree with an affine column zipper

Keep direct `id-1` mapping and balanced Main/Aux Type arrays. Add a balanced Data occupancy tree aligned with column capacity: each node caches the number of **live entities**, each leaf records live membership. A node whose count is zero can be skipped; traverse left then right to retain ascending logical IDs. Do not use dense insertion order, a Data copy of payloads, or a mutable callback-visible iterator. Occupancy includes entities with Main absent; Required selection still skips those through existing Main-presence behavior. Flag/Aux and added/changed metadata predicates remain unchanged.

Walk the aligned Main/Aux/metadata trees together, carrying an affine zipper of sibling subtrees and the logical base offset. Each visited leaf is consumed once; the existing rank-2 client receives abstract Main/Aux providers, returns both owners, and the rebuilt leaf receives exactly those returned owners. Rebuild each traversed node once on return. Empty occupancy subtrees are returned unchanged with all their Type owners. This avoids repeated root-to-leaf extract/restore for query rows while retaining indexed point access. The zipper is private Type state; it cannot be duplicated, exported through Data observations or retained by client callbacks. Public outputs remain the same ordered Data list. No query mutation queue is flushed implicitly.

Point operations retain explicit namespace, nonzero ID, supported-domain, capacity and live checks **before** index arithmetic/array access. Base masked array addressing is not validation. A stale/foreign/zero/out-of-capacity handle returns the existing Missing classification, original owner and unchanged receiving queue. Whole-queue preflight and FIFO reservations remain unchanged. Logical IDs are never reused or moved.

Committed Spawn adds one live leaf; committed Despawn removes one. RemoveMain leaves the entity occupied. Extraction for a callback does not change membership. Reservations and rejected/failed commands do not enter the tree. Rollback must restore occupancy only where actual inverse lifecycle operations demand it, without allocator rewind or deletion of earlier commits. Marks, pending commands, inverse journal, Ping retention and registered readers are untouched.

Growth doubles all aligned trees by attaching old left owners and fresh empty right owners, including a zero-count occupancy subtree. Existing logical offsets never change. Failed placement returns the original store and rejected owned bundle. The current finite domain 1..131072 remains explicit. Tombstones retain empty physical slots; the count tree skips fully dead ranges but does not compact, reuse IDs or promise bounded memory under unlimited churn. Root live count must equal physical live metadata count; this is a checked diagnostic obligation, not an approved law.

## Discriminating finite counterexamples required before extension

| Control | Intended observable failure |
| --- | --- |
| Right-before-left traversal | Ascending query order differs after holes and out-of-order commands |
| Skip a nonempty cached-zero subtree | Missing first/middle/last live IDs despite unchanged point lookup |
| Treat RemoveMain as Despawn | Optional/entity membership, stale classification and reinsertion differ |
| Include reservation before barrier | Queries expose pending IDs and failed reservation owners |
| Grow with reversed old/new branches | IDs 1, capacity, capacity+1 and E11 >65536 alias or lose complete owners |
| Restore Main into Aux/wrong leaf/drop fourth cell | Full Main/Aux payload oracle differs; unrelated owners are checked |
| Forget occupancy rollback | Retry, earlier commit and failed publication trace differ |
| Accept foreign/zero/tombstone ID | MissingEntity/unchanged queue gate fails |
| Leak or duplicate zipper/Type owner | Intended undeclared-access, cross-schema, write-through-read, reconstruction and affine duplication controls reject |

Both Motion/Health schemas and explicit-owner/regenerated capture styles must repeat complete main E0–E10, actual E11, access, ownership, FIFO and lifecycle/reader/effect oracles. Compiling semantic mutants must produce the named field counterexample; timeout/checker/build failure is not a kill. General destructive Type recovery, root authority, parallel compute and universal refinement stay open. Follow-up implementation should first check expressibility under checker5s, then compare finite query visitation counts on dense/live, mostly-dead high-water and clustered/dispersed holes. Only separately measured connected workloads can attribute performance benefit. Independent review must explicitly accept the zipper ownership and occupancy mutation boundary before code is written.
