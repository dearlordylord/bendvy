# Canonical composition source review

Spec: PASS for the additive source seam. Standards: PASS for the reviewed source; executable qualification remains separate. No semantic blocker found. Read-only review of the five WIP modules in `integration-canonical-composed-query`; no compiler or runtime execution.

The original `inspector-query.bend` and `inspector-query-projection.bend` bytes are exact prefixes of their successors. Existing Row/Selection/ReadQuery/grant/each/get/single APIs remain unchanged. New ProjectedRow and DeclaredSelection have separate nominal identities; no fabricated composite lifecycle flags are introduced.

Pair membership short-circuits left then right, projection threads one owner left then right; constrain preserves projection and map preserves membership. Each scans existing World.handles order and reverses its accumulator once. Lookup validates the entity before membership and returns existing MissingEntity/QueryMismatch; single and optional-single retain exact cardinality errors. Empty selection includes every enumerated live entity.

Family adapters retain Store/Rest/Payload as Type and observations as Data. Presence uses Col.present through existing validated take/put, not an application payload projector. Inspector lifecycle filtering first requires presence, then uses its unchanged cursor and existing lifecycle selection. Check gains no lifecycle cursor. World adapters consume and restore the same Frame and cursor. Ordinary factories obtain the family from the retained nominal Binding; no second caller key/family or write grant is added.

This matches staged selection/query/families/traversal/ordinary-selections algorithms and the prior CANONICAL-COMPOSITION-SEAM proposal. Rust Bevy tuple QueryData, With/Without and Added/Changed establish capability direction; pinned Bend affine Type ownership governs representation. TS QueryHandle is third-priority feature inventory. Existing native ordering and errors remain authoritative.

ScanResult is internal by convention and call boundary: public ComposedReadQuery operations return H with detached rows/results, never the recursive carrier. Bend does not enforce module-private visibility; its helper declarations remain nameable. This is not an opaque runtime authority escape: callers still need the relevant typed owner/grant. No language-enforced privacy claim is made.

Remaining acceptance: review migrated full23 consuming callsites and declaration/access lowering, current authority negatives and reached mutants, complete independent JS/Native models, and coordinator-owned regression. Source review does not establish execution, preservation of every affine owner, performance, or full #54/#56 acceptance.

Reviewed SHA256:

| Module | SHA256 |
|---|---|
| inspector-query-projection.bend | 422efbb7c19e8091a77f7e90e7f4e3d95474ae41d46e934b270b89638cd5f561 |
| inspector-query.bend | 7a4c90e0f1e63d6a89aea256bd96c874758db73865dad02481a32c1dded8b58d |
| inspector-query-families.bend | 020a8de48df12369c8709d10d15f0c3d22dcf8a9fb76f3af238ea4a4304edeb8 |
| inspector-query-world.bend | 1c3e6f92ed30cd26ac96d11712ec28eea6099c5103fb153c617d92b68260e65a |
| ordinary-query-selections.bend | 57ee96b72d098d0b3abf0504a166c3a0846c817fcc4cb2f77a9629be501bc755 |

Authority pins: Rust Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60; Bend a950fd683c0d76f09794078e6174fe98a1492876; TS 3040a3b2a3f28fa8554d856f9ccb6bf5433fa334. Sources: Bevy query/fetch.rs tuple implementation, query/filter.rs and system/query.rs; Bend affine quantities; existing canonical component/world/compose modules and the full-consumer stage modules.
