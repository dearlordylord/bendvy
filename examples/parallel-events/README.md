# Ordinary event publication checkpoint

`main.bend` uses a registered ordinary application and the canonical closed-layout
resource grant. Its resource is an affine event family; its pending payload is an
actual `Array<U32>` owner held in the system's `Local`.

The first invocation publishes array value 202 and then returns a handled body
error. Publication has already updated the real resource log. The second
invocation has no pending payload, so it cannot publish again. Inspection of the
returned World drains the actual retained row and reads its array value. The
expected result is independently derived from those authored operations: row 1
holds 202, the publish branch ran once, and the first status is the authored
error. `expected.stdout` records this observation.

This publication is immediate. It does not enter a deferred structural command
journal and is not rolled back on the returned body error.

Run JavaScript through the existing example helper from the repository root:

```sh
bash -c 'source examples/common.sh; example_emit examples/parallel-events/main.bend /tmp/parallel-events.js; example_node /tmp/parallel-events.js'
```

This is a bounded GH84 checkpoint. It does not establish ordinary independent
reader execution, the two nominal schema consumers, scheduler skip/error cursor
behavior, full retention lifecycle observations, or backend parity. Those remain
required before GH84 completion.

The pure `execution-event-family.bend` and capability wrapper
`execution-event-ops.bend` source-check. Checking `main.bend` with proof-only mode
reports its explicit foreign identity allocator dependency. Its executable
JavaScript path uses that allocator through `execution-event-io.bend`, the same
host identity allocator used by World creation.

## Reference behavior

The family implements retained/future reader creation following pinned Bevy
[`get_cursor` / `get_cursor_current`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L172-L184).
Reader advancement is per yielded item, following
[`MessageIteratorWithId::next`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/iterators.rs#L54-L99).
Retirement returns actual payload owners after the two-generation boundary,
following [`update_drain`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L187-L218).
These are source-based semantic decisions; this checkpoint has not run a Rust
reference comparison for the full event scenario.

Every operation conservatively acquires the actual family resource slot
exclusively through the ordinary builder. The reader projection returns Data
while restoring the payload owner. This is not a shared affine read-view claim.
The admin command/outcome API returns reader tokens and retired payload owners
as Type values without duplicating its canonical writable capability.
