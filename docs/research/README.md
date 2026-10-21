# Research findings

These investigations explain mechanisms and language constraints; they do not
select new observable contracts or establish current performance by themselves.

| Question | Source |
| --- | --- |
| How was Bevy ported to TS, and what changes in Bend? | [bevy-ts analysis](../bevy-ts-analysis.md), [Bend ECS architecture](../bend2-ecs-port.md) |
| What existing Bend code can inform implementation? | [Community catalogues](bend-community-catalogs.md), [Jend optimization patterns](jend-optimization-catalog.md), [product techniques](bend-products-performance.md) |
| Which storage costs were identified? | [Indexed lifecycle metadata](indexed-lifecycle-metadata.md), [packed flags](packed-live-tag-flags.md), [native arrays](native-array-attribution.md) |
| How does ownership affect generated JS? | [Owner transport](js-owner-reuse-language.md), [concrete carrier shapes](native1024-js-carrier-shape.md) |
| What constrains ordinary debug and restore APIs? | [Debug execution seam](debug56-schedule-execution-seam.md), [snapshot readiness](basic-snapshot-readiness-v1.md) |
| What prevents accepting a measurement? | [Compiler blocker](e11-codegen-blocker.md), [mutation audit](query-layout-key-mutation-audit.md) |

Inspect pinned sources and actual generated calls before transferring a technique.
Package availability is not compatibility evidence; fewer allocations are not a
timing result. [Historical profiles and rejected alternatives](../archive/README.md#performance-investigations)
retain the detailed observations.
