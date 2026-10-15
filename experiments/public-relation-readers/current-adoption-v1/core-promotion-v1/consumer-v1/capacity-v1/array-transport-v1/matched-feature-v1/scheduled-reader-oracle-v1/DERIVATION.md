# Scheduled ordinary reader source oracle

The complete expected stdout is independently derived from the frozen ordinary
consumer source, before backend execution. No candidate stdout, generated JS/C,
backend receipt, or old expected output was consulted. The model does not execute
Bend or a candidate runtime. It implements the finite sequence of source
operations and the consumer's exact JSON serialization.

Entrypoint: sibling `ordinary-scheduled-reader-consumer.bend`, commit
`155a88735608a41203d48730faa0ed5c01e3ea79`, SHA256
`0d110a15ceef95541ece9676cddb17aae898446b20139f83d3c1443c468ef32c`.
`source-pins.json` binds every recursively resolved actual import body:63 Bend
files, plus installed Base and both print effects (66 total). Absolute paths bind
the actual held source closure, including uncommitted dependency bytes. The
oracle owns only this leaf in the independent worktree.

The expected output is4402 bytes, SHA256
`7ae4988abd31de1f08f45b152b651f49b49f47283d29ea8ef72132d8d847992d`.
It is one complete JSON object followed by the LF added by Base `IO.print`.

## Source derivation

Source names below identify pinned files; ECS files are below `src/ecs/` in the
source worktree. All consumer-local functions live in the entrypoint.

1. `setup` through `setup_stored` creates namespace1/entity1, marks it live,
   swaps42 into the sole component column, and publishes original Value11 and
   original Removed(entity1,value), in order. Its store is the actual
   `Notice.Store{column,Graph{[],[]}}`. No relation notice is seeded.
   `define_all` runs twice, naming affine registrations A and B. Each product has
   a With(value) query, two independently allocated values message readers,
   one removal reader, and one separately allocated keyed relation reader.
   A leaf IDs are1/2, B IDs3/4; keyed IDs are1/2. Initial cursors are0.
2. `schedule_relation`, `relation_attempt`, `relation_body`, `self_targets` invoke
   the real `RelationProvider.Writable` request at self targets(entity1,entity1).
   `relation-providers.bend` `relate_tx` calls `relation-commands.bend`
   `queue_relate`, whose namespace check accepts both targets and returns Queued.
   `transaction.bend` `stage` stores the actual closure; `finish_world` with
   Success enqueues it through `commands.bend` `enqueue`. The second invocation
   also returns Queued but finishes with Failure77, discarding its staged command.
   Thus mutation report is queued/success and queued/{failure:77}; exactly one
   command is pending, with no relation error or graph change yet.
3. `before_barrier` invokes A successfully. `ordinary-reader-system.bend`
   validates registration and the complete reader product, invokes
   `event-notice-runtime.bend` `before_attempt`, and prepares all views.
   `before_state` ingests initial originals at positive epoch1, increments World
   clock to1 and route tick to2. `sync_events` forwards only Value to the message
   stream; the typed journal retains both publications. A sees entity1/null,
   both message readers see complete original Value11, removal sees the complete
   removal, and relation key1 has an empty reading with lagged=false.
   A succeeds, committing query cursor1, message cursors1, removal count2,
   and keyed cursor1. The pending command remains1: this run has no implicit
   barrier. `after_success` ingests again at route epoch2 without duplication.
4. `barrier_after_first` uses `W.barrier` on that same World. `world.bend`
   `barrier` empties its pending accumulator and `drain_fifo` executes the sole
   closure. `relation-commands.bend` `apply_relate` validates both live handles,
   calls `relation-graph.bend` `relate`, and `publish_relate` appends the complete
   SelfRelationNotAllowed failure. Graph `checked` retains both empty arrays.
   Barrier itself does not advance the clock (still1).
5. `after_barrier` drives the remaining source sequence. A fails with7, retries,
   repeats; B runs first, then repeats. A's failed run ingests the new error at
   epoch2 into descriptor1's queue and removes it from the World ordinary log.
   World clock becomes2, route tick3. Both message cursors1 and removal cursor2
   suppress old originals. Keyed cursor1 sees the complete epoch2 error.
   Failure commits no provider/reader cursor, so retry returns exactly the same
   complete view and then consumes it successfully. A-repeat has empty streams.
   B's initial cursors0 still see Value11, removal, and that same error once;
   B-repeat has empty streams. All six query views retain entity1/null.
6. Clock values are `[1,2,3,4,5,6]`; observed provider query cursors are
   `[1,1,3,4,5,6]`; observed pending counts `[1,0,0,0,0,0]`.
   All observed World event arrays contain the two originals in initial order;
   every observed graph has complete empty edges and inverses arrays.
   `ordinary-reader-stream-parameter.bend` `prepare_event` sets readThrough to
   routeTick-1; `event-stream.bend` `advance` activates before updating; commits
   occur left-to-right (`reader-parameter.bend` `pair_commit_fn`). Final leaf
   positions are `(4,6,4),(3,6,4),(2,4,0),(1,4,0)`. Keyed commit uses the
   pre-increment failure tick; final keyed positions `(2,6,5),(1,4,1)` and
   `domains.bend` prepends descriptor reader IDs, yielding `[2,1]`.
7. `observation_context`, `world_observation_json`, `view_json` and their helpers
   specify every field and order: phase/status/error/clock/queryCursor/view/world;
   query/eventA/eventB/removals/relations; namespace/clock/pending/graph/events.
   Every lagged flag is false (no capacity trim/frame/drop occurs), errors are
   represented completely, and Unit query projection renders null while the
   affine component owner retains42. `drive` builds one comma-separated array,
   with no internal line endings. Installed `base.bend` `IO.print` imports the
   pinned `print.js` and `print.c`, each adding exactly one LF.

Rust Bevy semantic reference remains the manifest revision
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`; message cursor independence is described
in `crates/bevy_ecs/src/message/message_cursor.rs`. This oracle derives exact
bytes from the actual Bend product consumer, including its explicit
commit-on-success behavior; it does not assert automatic rollback of a directly
used Bevy MessageCursor. No bevy-ts behavior changes that priority.

## Verification and scope

`python3 derive.py` verifies all66 source hashes and exact complete expected bytes.
Substantive invariants assert rollback state equality, only one committed pending
closure, no implicit barrier, exact one-error publication and graph preservation,
failed/retry full-view equality, late-reader visibility, stream independence,
repeated empty readings, journal nonduplication, complete event order, separate
clocks/cursors, and final position order. `--write` regenerates output from source
semantics. No candidate runtime output participates in either path.

The output is an expectation awaiting actual JS/Native comparison. It covers
this bounded scheduled consumer; it does not establish cleanup/disposal,
arbitrary schedule combinator behavior, performance, or combined regression
acceptance. World observations here are exactly the fields exposed by the
consumer's WorldObservation serializer; component storage/allocator metadata is
not represented as additional invented stdout.
