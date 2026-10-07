# Feature API coverage and implementation boundary

Pinned bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend `a950fd683c0d76f09794078e6174fe98a1492876`; installed Bend 2.0.35. Existing reference and evidence remain unchanged.

| Public surface | Source behavior | Required Bend observation |
|---|---|---|
| `Feature.define` name/schema/requires/build | stores authored definition, default requires empty; output type witness has no runtime value | independently authored metadata and closed builders |
| `Feature.compose` selection | selected-name insertion order; duplicate scan before all dependency checks | first duplicate and duplicate-before-missing; no builder effects |
| Direct dependencies | checks each selected feature's authored requires by name against entire selection | first absent dependency; owner return/retry before builders |
| Fragment merging | `buildSchema` applies actual fragment collision rules before builders | actual SF validation; returned complete typed owners |
| `FeatureBuildGame` | static own schema plus recursive dependency closure; Runtime omitted | actual typed/rank-2 grant boundary; undeclared/foreign/read negatives |
| Builders | execute selected order, not topological dependency order | Combat before Core even when Combat requires Core; actual counter/order |
| Outputs | preserves additional fields; absent bootstrap/update normalize empty arrays | arbitrary affine Type output packs; actual cells and empty output |
| Aggregated schedules | concatenates bootstrap/update in selection order; nested schedules retained | actual P.Plan aggregation and registered runner execution, requirement union |
| Root binding | final merged Game is nominally rooted | two nominal schemas, foreign-root rejection |

`Feature.ts` runtime passes the final Game to builders; Node type stripping does not demonstrate the static restricted-access boundary. Bend uses trusted closed schema provisioning plus opaque gameplay; metadata alone is not authority. Rust `bevy_app/plugin_group.rs` provides explicit ordered plugin grouping, not an equivalent FeatureBuildGame typed dependency API. We retain Bevy's ordered ECS initialization architecture without inventing topological scheduling.

Initial experimental metadata and generic typed composition have been checker-prototyped; this table precedes application integration. No complete parity, law approval, production delivery or performance acceptance follows from those checks.

Repeated direct dependency references are observed in `dependency-reference.mjs`: Core is selected and built once despite two Combat requires references. Raw authored visibility retains both descriptors; access-scope provisioning deduplicates exact kind/key/name only. A different name at the same kind/key remains a conflict and returns the original affine owner.

The recipe-only requirements observer is authored metadata, not a provisioning union: `schedule-provision.bend:57` `requirements` returns each Entry list and concatenates Sequence left/right. Combat declares `[2,1]` in each phase (`combat-feature.bend:13`); Core declares `[1]` in each (`core-feature.bend:14`). Consequently the raw combined observer is exactly `[2,1,1,2,1,1]`. `schedule-provision.bend:68` `build` separately calls `unique(requirements(plan))`; the actual registered-application observer remains `[2,1]`, with all 14 literal records unchanged. The v7 failure exposed the incorrect raw-recipe oracle, not a production deduplication defect. Only the two recipe selected-row literals were corrected; output shaping and authored builders are unchanged.
