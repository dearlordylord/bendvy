# Independent small scheduled follow-up oracle

Producer `9834eda56`, entry SHA-256 `7191be1995630f86ca419f398e9a290034f6f9aef53c813370d43bbb07cd0f93`. The immutable source root is `/tmp/bendvy43-scheduled-followup-oracle-source01`: 65 Bend bodies, including the actual entry. All 64 core bodies equal the previously frozen V9 selection. The model verifies 73 source/reference pins: closure, Base, C/JS write effects, three Rust Bevy primary sources and two earlier source-derived model helpers. `serializer-source-join.json` additionally pins the old V9 entry and verifies 70 identical serializer/observer definitions. Historical models and expected bytes remain unchanged.

Expected full raw wire is **26,254 bytes**, SHA-256 `fd4316f0b089ccdd0bec3c06faba92b9096c08e3fd4c4d1d7054e24e505de926`. It contains all 21 trace rows, nine real schedule outcomes and the final physical context. The source deliberately wraps trace objects with raw quotes without escaping; preserve this wire even though the resulting outer String is not valid JSON. No runtime, generated JS/C, compiler output or candidate stdout was consulted to derive it.

## Source operations, authority and observations

Setup uses the pure World factory, namespace1. Its returned source handle1 is activated and stores value42. It publishes the original Value11 and the removal record for handle1, then reserves/activates returned target handle2 and stores value43. It reserves returned missing handle3 without activation. Thus nextId4/highWater3/capacity4/depth2, live slots [false,true,true,false], inactive reservation [handle3], components [(1,42,0,0),(2,43,0,0)], Unit resource and empty graph are actual observed state. The removal publication is synthetic test input; it does not remove the actual stored component42. Plain Col.swap leaves both lifecycle stamps at (0,0). Query selection sees both active components in slot order and projects entity handles only.

The successor fixes target provenance: Ready's actual source, target and missing handles thread through all writer/fast/slow definition continuations into WriteArgs. follow_set_write_args builds Targets from those returned values; write_callback folds that actual list through RelationProvider.Writable. The reached writer never calls the old integer-based write_targets constructor. First list is [(source,target)]; second is [(source,source),(source,target),(source,missing)]. No new public authority contract is inferred.

Writer registry1 has empty access. Fast registry2 and slow registry3 each declare query/two message/removal/two relation keys, with the seven access strings preserved. Their typed reader IDs are 1/2 and 3/4; keyed reader IDs1 and2. Warm actual scheduled reads activate both providers and consume startup publications. The event-family stream retains the Value11 notice, while the journal retains Value11 plus Removed. Startup records have positive epoch1; removals advance their raw-notice offset to2.

| Reached operation | World / route / failure tick after operation | Query cursors writer / fast / slow | Observation and effect |
| --- | --- | --- | --- |
| Warm fast, warm slow | 1/2/2 then 2/3/3 | 0/1/2 | Both full startup views; Sch.Finished with Ran2,Ran3 |
| Committed ordinary writer | 3/4/4 | 3/1/2 | queued1/refused0, pending1, graph still empty |
| Actual barrier plus failure frame | 4/4/4 | 3/1/2 | Applies edge1→2 and inverse sources[1]; empty failure queues; frameStart4/boundary0 |
| Next ordinary writer | 5/5/5 | 5/1/2 | queued3/refused0, pending3; graph retained |
| Actual barrier plus failure frame | 6/6/6 | 5/1/2 | SelfRelationNotAllowed(1,Parent), then successful repeated1→2, then MissingTarget(1,3,Parent); two distinct singleton batches at tick6; frameStart6/boundary4 |
| Fast callback Tx.Failure7 | 7/7/6 | 5/1/2 | Complete failed view returned, no cursor commit or after_success; actual Sys.Failed makes Sch.Failed with Ran4 |
| Separate active-fast condition-false schedule | 7/7/6 | 5/1/2 | Full before/after context and both query cursors identical; Sch.Finished with Skipped2 |
| Separate fast retry | 8/8/8 | 5/8/2 | Same complete failure view as failed attempt; commits fast read cursor7 |
| Separate slow read | 9/9/9 | 5/8/9 | Same complete failures independently; commits slow cursor8 |
| Fast repeat, slow repeat | 10/10/10 then 11/11/11 | 5/10/11 | Both relation arrays empty, typed/removal views empty; separate finished schedules |

Each ordinary writer transaction commits its command list. Self-link and missing-target requests are queued because the source is active and namespace matches; refusal occurs when actual deferred apply_relate executes, producing failure notices rather than a queue-time refusal. The repeated existing edge succeeds and preserves the single edge/inverse. The command-aware barrier collects after each actual closure, so self and missing errors remain separate ordered singleton batches. The explicit frame normalizes them into queue.front; no capacity or history drop occurs. All lag flags are false.

The failure callback has no mutating capabilities; transaction rollback preserves World data after the attempt's clock advance. Prepared reader retention metadata persists, while typed/keyed/removal/query cursor commits are success-only. This follows the pinned Bend implementation and existing reader contract; it is not a claim that Rust Bevy universally rolls back message iteration on a failed system.

The scheduler truly terminates at Sch.Failed. The fixture extracts retained owners/world, records that result, and builds a separate public schedule for the active skip, then separate retry/read/repeat schedules. It does not disguise callback failure as scheduler success, nor introduce an implicit scheduler disposal operation.

## Bevy-first skip and retained state

Pinned Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, single_threaded.rs condition branch marks the system completed then continues before invocation when should_run is false. MessageReader stores Local<MessageCursor>; read mutates that cursor. Therefore a condition-false skip does not consume unread messages. The fixture's skip callback only observes and returns its actual owners. Warm successful reads establish active query/typed/keyed cursors before the skip; unread tick6 errors exist during the skipped call.

Both before/after skip contexts retain graph1→2, complete World allocator/live/component/stamp/resource/registration state, original raw events, typed stream/journal and all keyed queue/domain/position metadata. Keyed positions remain [(2,2,2),(1,1,1)] during failure and skip. Failed view, retry view and slow independent view are byte-equivalent as Data. Final keyed positions are [(2,10,2),(1,9,1)], typed positions [(4,10,1),(3,10,1),(2,9,0),(1,9,0)], and both removal offsets2. Both domains retain reader membership[2,1]. Key1 retains exactly the two singleton batches at6, size2/dropped0; key2 remains empty. Final graph is still edge1→2, raw originals and startup histories remain complete, and pending is empty. Affine owners are source-threaded; this oracle compares their executable Data projections rather than asserting owner equality as a theorem.

## Serializer and terminal effects

The complete physical observer and structured serializers are byte-identical to the source-audited V9 helpers. model.py independently rebuilds source JsonDoc fragments from the new operation-derived states, including nonempty graph/inverse, scheduleOutcome rows and the failed-reader row. It confirms exact raw wire equality, list/field order, literal trace quotes, fragment/chunk packing and fuel sufficiency. This small fixture has structural fuel10671 and 8379 loop visits; all seven emitted chunks are nonempty and at most4096 bytes. Fuel counts the final empty-stack branch and all flush retries. The old decreasing-fuel source check alone is not used as evidence of sufficiency.

The reached main calls write_output_chunks(followup_start(setup())). IO.bind writes head before tail; IO.write adds no newline. The empty chunk-list case writes exactly one LF. There is no IO.print on the reached path and no second schema output. Raw and gzip golden plus expected.sha256 preserve the complete bytes. Run `python3 model.py` for all source pins, serializer joins, full operation/state invariants, timeline equality, fragment IO reconstruction and full raw/gzip equality; `--write` recreates the model artifacts. Python source checks pass.

This is one nominal Schema, one small ordinary consumer and existing contracts only. It does not qualify capacity overflow, disposal, WorldIO namespace allocation/foreign refusal, arbitrary affine payload APIs, cross-schema composition or second-schema automatic authority. Existing IO-authority/disposal evidence has its own source qualification. Source check success is not backend completion or a new formal proof; runtime execution remains the coordinator's next gate.
