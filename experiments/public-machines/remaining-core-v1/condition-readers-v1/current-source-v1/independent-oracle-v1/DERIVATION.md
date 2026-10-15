# Independent current ordinary condition/reader oracle

The oracle is derived from the complete checked ordinary consumer and its
literal import closure, before any candidate backend output. `source-freeze.json`
binds 68 unique relative file bodies and all 82 actual absolute import paths.
Some unchanged ECS dependencies are reached through both the consumer worktree
and absolute root imports; their bytes match, and `sourceOrigins` records every
alias. The immutable snapshot preserves source text, including absolute import
paths. `source-pins.json` checks both actual origins and snapshot copies, plus
Base, compiler pure-value presentation, and pinned Bevy reference sources.

Run `python3 model.py` in this directory to verify source pins, finite state and
serializer invariants, and reproduce complete stdout/gzip/hash/timeline. This
executes Python source models only; it invokes no compiler or backend.

## Historical reuse and changed operations

Before reuse, the earlier model's pure render was independently checked against
its retained 3,957-byte golden, SHA
`ab4bc9d3df7f6a92b4163efab168ec97bfaed8a3f90e00be5dba0237c5d4e5d7`.
That equality is checked again by this model. The historical scenario and golden
remain unchanged. They establish matching List.show/stream conventions only;
the new expected output is independently derived from the new public init,
registration, composition, App schedule, callbacks and observer sources.

The historical model used Stream.skip both for successful completion and false
condition skips. Current source separates them: successful callbacks update the
active position, while condition-false dispatch never invokes the reader.
The current fixture uses actual Init cells/revisions and fresh Initial events,
not the historical manually seeded slot/current/pending/stream fixture.

`main.create` creates an empty World and publicly initializes Flow=Play at clock1
and Level=Low at clock2. Actual systems register fast1/slow2; changed-condition
owners register Level3/Flow4. The same normal ordinary App schedule binds fast1
and slow2 by those actual IDs, each with opaque step condition slot0, no resource
requirements, and its own owner-threaded guard. The schema fragment inventory is
explicitly empty; no schema declaration is fabricated in debug output.

The fast guard is `in_state(Flow,Play).and_then(state_changed(Level))`; the slow
guard is `not(in_state(Level,High)).or_else(state_changed(Flow))`. Their ordered
leaf descriptions/access lists come directly from Comp constructors. The wanted
High token renders as `2`, not the provisional word Loud.

The reached trace executes exactly:

1. `initial-run`: at clock2 both readers run. Level.changed observes revision1;
   slow's left OR is true, so Flow.changed retains revision0/cursor0. Fast reads
   Initial Low and slow reads Initial Play. Their real stream positions and
   system cursors commit2, registeredAt2.
2. `flow-pause-level-high`: occupied insert Flow Pause at3 then Level High at4
   replaces each affected stream's messages while preserving positions. Fast's
   left AND is false: schedule skips system1, preserving its Level condition
   revision1/cursor2 and reader cursor2/last Low reading. Slow's OR left is false,
   so Flow.changed observes revision2/cursor4 and its body reads Initial Pause.
   Level's fresh Initial High remains unread at tick4.
3. `flow-play-repeat`: only Flow is inserted at5. Level's unread tick4 batch and
   reader position remain untouched. Fast now evaluates its previously skipped
   RHS, observes Level revision2/cursor5 and reads retained Initial High; slow
   observes Flow revision3/cursor5 and reads fresh Initial Play. Both run and
   commit their own real registry/stream cursors5.

Thus Level condition revisions are 1/1/2 and Flow condition revisions 0/2/3;
schedule observations are [ran:1,ran:2], [skipped:1,ran:2], [ran:1,ran:2].
The skipped owner's unread history survives insertion of the *other* machine.
No occupied same-machine insert is claimed to preserve its cleared messages.
Reader callbacks do not advance World.clock. No marker/frame is invoked;
frameStart/droppedThrough remain0 and every slot retains pending/previous none,
changed true. Default closures return pure values with no additional observable
side effects; no fabricated default-effect counter is serialized.

## Complete observation and wire

`observer.py` models every observer field: physical World namespace/allocator/
live/store/stamps, both actual Init slots/streams/revisions, complete batch and
position ordering, pending command count, World registration metadata/order/next
ID/clock/event count, reader registry and stream identities/cursors/last values/
lag flags, and both condition owners' actual revisions/cursors.

`debug.py` mirrors the full pure serializers for schema entries, all DTO body
bindings/clauses, complete rows and rendered strings, planned steps and every
requirement, schedule placements/names, condition bindings/access/leaves and
condition placements. Actual App snapshots return observer world text as both
rows and the sole rendered element; neither copy is omitted. Changed-condition
registries remain real World registrations and condition leaves/owner snapshots;
the body-binding fold intentionally returns only the two actual body instances.
The shallow trace reconstruction helpers preserve all affine owners and fields;
the model represents their executable Data observations, not copied affine owners.

The entry returns a **pure String**, concatenating SchemaA then SchemaB traces.
Each independently uses W.factory(), so both namespace values are1 with genuinely
distinct nominal schema types; this is not WorldIO provenance coverage. Each
trace has three line terminators inside the returned value. The compiler's
`show_val` wraps that String in quotes and `show_chr` escapes the six LF chars;
`io_exit` appends one physical terminal LF. There is no IO.print call or extra
print newline in this entry. All selected characters are printable ASCII or LF,
so the modeled JSON String quoting exactly matches both pure-value printers.

## Reference scope and limits

Pinned Bevy condition.rs AndThenMarker/OrElseMarker establishes lazy RHS
execution; its state_changed condition observes each system's resource changes.
Current supported Changed.run always returns a successful bool, including false
for a missing state. Stale/foreign registration refusal remains a separate
fail-closed authority result; no arbitrary failing ordinary condition leaf is
invented. This finite consumer reaches only valid registered guards/readers and
finished schedules, not error, foreign, missing-resource, disabled-debug or
capacity/frame stress paths. Separate qualified evidence supplies other gates.

A source hash check or this finite model is not backend acceptance or a universal
proof. The unchanged collector must compare complete actual stdout on each
required backend. No candidate stdout or generated artifacts were consulted.
