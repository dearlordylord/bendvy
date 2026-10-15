# Independent actual-operation TS oracle

Frozen adapter producer `25ff2790b4be7247f55db44e93f37f7e2ed1955d`, SHA `7db32292758a7e46e554c56036ff6c2592549ecf56524710c84ce2750252574f`. The immutable model-source snapshot is `/tmp/bendvy43-scheduled-matched-ts-oracle-source02`: exact adapter plus 33 imported source bodies and package.json (35 pins). Original import strings remain unmodified because this is an observation basis, not a runnable copied resolver. ts-source-freeze.json retains original identities. The historical freeze01 without successful link is not this oracle's source.

Expected stdout is **27924 bytes**, SHA-256 `4b1042baf8ad009674acffbeda7f6a0649b26a7293017968bca2a83f527d409f`. It contains the complete 34 observations (17 per root), every delivery DTO, debug world and debug stream record, and console.log's single final LF. There is no timing-dependent trace field. Both ReadersAlpha and ReadersBeta execute the same public APIs with separate Runtime.make worlds and descriptor identities; entity IDs restart at1. No Node execution, candidate stdout, generated backend or runtime receipt was consulted.

## Actual operations and state

Source root names are nominal type roots; descriptor names remain exactly Stock, Ping, Parent/Children and runtime system names remain fast/slow. Seed queues two actual spawn commands and applies them, giving source1 Stock42 and target2 Stock43. Warm fast and slow observe both added/changed. Actual commands.remove removes Stock from target at deferred application; both readers then see only source1 and removal[2]. Actual insert restores target Stock44; both readers then see target2 added and changed. The successful-link system queues/applies source1→target2. This edge persists in every later complete world dump.

A real empty doomed entity3 is spawned, then really despawned. It had no Stock, so it adds no Stock removal record. The same returned doomed handle supplies the later missing-target command; no guessed inactive ID is substituted. The writer queues self1→1 then source1→despawned3 and emits actual Ping31/Ping32. Transaction commit publishes the two events and advances the world once; applyDeferred later applies two commands, publishing the two ordered failure records. Full failures include operation, descriptor name, source, target and original tagged error fields. World graph remains source1→target2.

Fast is already active when its condition becomes false. Pinned Runtime.ts1394 advances only streamLastRun to current tick on skip; no system callback is invoked, lastRun stays11, no world tick advances, and no delivery is appended. This intentionally discards fast's unread events/relation failures while preserving its change/removal cursor. It differs from Bevy/Bend skip preservation and must not be erased to claim equality.

Slow callback then observes the complete events[31,32] and two failures, stages999 and returns Fx.fail77. The delivery DTO was appended before failure and remains visible as application observation. Runtime rollback clears emittedEvents; event999 is never published and consumes no publication tick. Slow lastRun/streamLastRun stay12. Retry sees identical event/failure content and succeeds. Fast subsequently observes empty event/failure arrays because of its deliberate TS skip. Both repeats are empty.

| Phase | Frame | World tick | Committed reader change / stream cursors |
| --- | --- | --- | --- |
| seed | 1 | 2 | none |
| warm-readers | 2 | 4 | fast3/3, slow4/4 |
| remove-target | 3 | 6 | unchanged |
| read-removed | 4 | 8 | fast7/7, slow8/8 |
| reinsert-target | 5 | 10 | unchanged |
| read-reinserted | 6 | 12 | fast11/11, slow12/12 |
| successful-link | 7 | 14 | unchanged |
| spawn-doomed | 8 | 16 | unchanged |
| despawn-doomed | 9 | 18 | unchanged |
| writer-queued | 10 | 20 | unchanged; events published at20, two pending relate commands |
| writer-published | 11 | 21 | failures at21, pending empty |
| fast-active-skip | 12 | 21 | fast11/21, slow12/12 |
| slow-failed | 13 | 22 | unchanged |
| slow-retry | 14 | 23 | fast11/21, slow23/23 |
| fast-success | 15 | 24 | fast24/24, slow23/23 |
| fast-repeat | 16 | 25 | fast25/25, slow23/23 |
| slow-repeat | 17 | 26 | fast25/25, slow26/26 |

## Full public debug derivation

Runtime.tick invokes advanceFrame once before every schedule, including skipped and failed schedules. internal/world.ts retains the prior frameStart as the window boundary, then records current tick as new frameStart. internal/streams.ts trims complete batches through min(window boundary, every registered streamLastRun). Removed records use lastRun instead. The model derives those exact frame/tick boundaries in ts.timeline.json, not a Bend clock mapping.

World dump field order follows Runtime.dump: version, frame, tick, entityCount, sorted entities, resources, machines, pendingCommands. Entity components and relations are complete; resources/machines are empty in this fixture. Pending tags and system origins come from actual command queue order: two spawn, remove, insert, relate, spawn, despawn, then two relate. After each immediate flush, pending is empty; writer-queued retains exactly the two actual relation commands.

Stream dump order is event Ping then relationFailure Parent. Streams become visible with empty retained logs after warm registration; both reader records appear in activation order fast then slow. Each keeps exact system/unread/lagged fields. heldBy is present only when source conditions hold: an oldest retained publication is at/before the frame window and an actual reader cursor is behind it; the minimum reader is selected in registration order for ties. Ping values are one batch at20; failure values are singleton batches at21. They remain held through slow failure/retry, then the next frame can trim them because fast skipped through21 and slow committed23. No lag is introduced. Stream sizes remain retained sizes rather than unread counts, and heldBy is omitted (not null) whenever absent, matching JSON.stringify(undefined).

Query rows are ascending IDs with actual scalar payloads. Added/changed filters compare active component marks against prior completed system lastRun. Seed marks are2; reinsert marks are10; removing target excludes it from all active query rows. Removed[2] is retained through both reads under actual lifecycle cursors; later deliveries are empty. The model does not invent physical arrays, raw queue layouts, allocator slots or affine ownership in TS debug, which does not expose them.

## Checks and scope

`python3 ts_model.py` checks all selected source/package hashes, exact 17-phase source order, the successful link, actual rollback callback and final serializer call. It derives complete raw bytes, compares raw/gzip/timeline artifacts, and checks two-schema isolation, actual removal/reinsertion query effects, retained successful graph, failed/retry event/failure equality, skip discard, no999, empty repeats and final stream trim. `--write` regenerates only model artifacts. Python source checks pass.

This oracle qualifies TS's complete reported public state and explicit shared DTO. It is not Bend affine/clock/physical queue equality and does not resolve the intentional skip discrepancy. Source check and this finite model are not runtime acceptance; the unchanged collector must establish that separately. Bend's actual-operation successor will have its own frozen source and full independently derived backend state before any comparison claim.
