# Finite source reuse joins

`source-reuse-joins.json` binds the historical receipts and archives to their exact normal-stage consumed sources, follows the actual recorded Bend entrypoint imports, and compares those bytes with the current sources. No commands, probes or backends were executed. Import relocation compares the complete source text with only resolved import targets canonicalized; definitions, comments and aliases remain significant.

| Retained finite slice | Consumed closure | Current-byte join | Scope retained |
| --- | --- | --- | --- |
| Registered relation query |25 modules |24 exact; World changed |20 complete normal queries on each historical backend |
| Registered query lifetime |25 modules |24 exact; World changed |66 query shapes and two retained snapshots on each historical backend |
| V5 registered affine cleanup |28 modules |24 exact; three import-only relocations; World changed |36 complete normal checkpoints on each historical backend |

The query and lifetime slices consume the current exact relation types, graph, commands and query modules. They do not consume relation cleanup, providers or either reorder module. The V5 cleanup slice joins types/graph exactly and cleanup/commands/providers through import-only relocation into `src/ecs`; it does not qualify relation query or either reorder module. Each artifact lists those unmatched current relation modules explicitly. All historical normal-stage inventory members were verified against archived query/lifetime bytes or the retained V5 stage; no imported consumed module was missing.

All three historical closures contain an older `world.bend`. The current World adds `string-equality.bend`, replaces String equality with that implementation, and changes registration matching to short-circuit helpers/tail traversal. This is a real source difference, not import relocation. The new equality dependency was not consumed in these old slices. Therefore these joins establish reusable finite relation-module semantics, not execution of the complete current closure. Current application replay evidence must separately cover the changed World; these historical receipts cannot supply it.

The compared installed binary/Base pins still match current file bytes. That is hash evidence only: it does not rerun installed discovery, validate today's resolver/library membership, or transplant prior command acceptance. Historical helpers have changed: query has ten changed/missing helpers, lifetime four, and V5 cleanup four, including their supervisor/tool-pins paths. Their exact historical/current hashes and states are recorded. Runner, environment, configuration and tool-probe acceptance remain attached to the original receipts; no current runner acceptance is inferred.

Original statuses and scopes are preserved. Historical mutant rows are retained by exact result hashes and witness counts, not upgraded to newly run controls. The V4 large receipt remains **FAIL overall**. Its separately recorded observations and131072-node case do not become an all-PASS qualification through source equality or this join. No proof, performance gate, production adoption or full#42 acceptance is claimed.
