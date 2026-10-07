# Phase2 source contract — no execution acceptance yet

Source-only approved extension of #42's finite boundary anchor. The committed phase1 handoff remains immutable; no shared/core/dependency/criteria changes.

## Runtime interface

Both emitted Bend and Node consume `family population span payloadSeed` at runtime, before setup/operation Begin. Seed is a full-range U32; all extra-payload arithmetic uses Bend U32 wrapping and TS `>>>0`. Family/case validation rejects an invalid tuple before Begin.

| Family | Logical population in each nominal world | Span | New topology |
| --- | --- | --- | --- |
| population |64,256,1024|0|Original three hierarchy edges only.|
| fanout |256|1,16,128|Extra entities6..5+span become ordered children of parent1.|
| depth |256|1,16,128|Extra entities6..5+span form a chain beneath original child4.|

One input creates one Workshop and one Other world; every world has the actual stated population, rather than repeated five-entity worlds. Entities1..5 retain original payloads/empty5; every extra entity has its own affine four-cell Payload owner derived from runtime seed/id. Phase6 reserves population+1, never the old literal6.

## Setup and operation boundary

Parsing, world/schema allocation and registered deferred spawn/seed occur before operation Begin and are counted separately: per nominal world, one creation, two registered setup systems, population spawn commands, population−1 payload owners, five seeded relations and two barriers. Status failures refuse the normal fixture.

After Begin, retain all seven actual registered writers, fifteen registered observations, eleven query shapes per observation, full component/query cells and N/N+1 target/inverse lookup columns. Original rollback903, self-relation failure, exact child-set reorder, future spawn/relation, deferred visibility, linked cleanup and retained immutable snapshot remain. Fanout reorders the entire declared child set; depth cleanup visits the real chain. Retained rows come from the initial observer's existing optional query, avoiding phase1's additional Bend-only capture query.

Every input returns exactly thirty complete records across both roots. The trace also contains the runtime input and separately labelled setup counts. Full output is serialized after completion and independently validated outside execution. Physical metadata qualification remains separate; this source design adds no lifecycle equality claim.

## Complete forcing

Derive conservative walk/serialization fuel from the declared schema and runtime population (including the future entity), not a fixed100,000 cutoff. Each record has a bounded number of query rows/fields and total inverse members linear in the population; the implementation records that structural bound. An exhausted traversal returns an explicit Incomplete result and never emits normal completion or a zero Summary. Every valid observed case must finish its whole-tree traversal and match independent counts plus its complete oracle. The serializer also rejects exhaustion; a valid prefix is not accepted.

## Independent oracle and admission

A separate dictionary/list chronological model emits every payload, selected row, relation order, graph field, failure, removed/despawned owner and retained snapshot. Derive actual row/cell/command/cleanup counts from that chronology; expected snapshots never come from Bend output or its graph helpers. Same-artifact controls perturb population and independently seed, compare all fields, and review generated actual ECS/forcing order. Last-leaf and moved-walk controls remain.

Untimed empty/sparse/non-power-of-two controls need separate fixtures whose writers target existing entities; they must not silently weaken the declared fifteen-record operation sequence. This nine-case model is source-only until admitted cheap consumers, Native/forcing controls and complete receipts run. No timing/profiling or larger cohort is admitted during contention; caps remain source/runtime5, emission30 and compilation120 seconds.
