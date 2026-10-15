# Canonical machine capacity: independent source oracle

This finite oracle binds producer commit 247b73fa374b5664b55c549e96900614e6a85a62,
including queue candidate 0d2da72c5 and fixture d907d363e. The selected `full.bend`
calls preserved `Overflow.parsed(Some{65537})`, so checked count validation and
all actual operations remain reached with no runner argument change. The full
literal import closure has 28 Bend bodies plus 2 World namespace effect bodies;
all 30 original paths/nominal import identities and snapshot copies are pinned.

No backend output, generated source, historical runtime transcript or observed
TS expected JSON was consulted. The old overflow-model.py was read as source,
not executed: it depends on observed TS JSON. The new model derives all fields,
ordered batches and complete deliveries directly from actual operations.
Its literal 22-field inventory is independently checked against the historical
model's AST without evaluating that model. The retained qualified source archive
is used only for source joins: `overflow-core.bend`, CLI `overflow.bend` and
`format.bend` are byte-identical after removing import lines. No candidate stdout
or checksum substitution supplies expected payloads.

## Operational derivation

Both scenarios use actual WorldIO.create sequentially in one fresh process.
Pinned world-namespace.c starts its atomic counter at 1; world-namespace.js uses a
shared Symbol.for slot initialized to 1. No other namespace request is reached,
so nominal SchemaA/SchemaB own actual namespaces 1/2. Seed reserves and activates
entity 1 and populates its affine component Array[10,99] at actual stamp 1. The
physical live array is [false,true], capacity2/depth1; the Column has one physical
Some array cell and stamps[1:1:1]. Owned resource Array[30,130] is preserved.
Registrations are publisher 1 then reader 2, with complete access arrays and real
Registry cursors 0 (the source calls Sys.run, not run_tracked).

Every publisher invocation first frames its actual stream/slot. Its body pulses
resource tick, reads current and queues value+1 through the declared capability.
The real marker drains deferred commands, pulses, applies the captured machine
request, and publishes one actual transition at one further tick. Each publication
therefore adds 3 resource ticks. Every one of the 65,537 loop iterations is retained;
there is no lowered capacity or synthesized batch in place of those operations.

The first failed reader activates real position 2 at cursor 0/registeredAt 2.
Each reader frames first, observes the current stream, then pulses before
Tx.begin. Failure preserves cursor and the pre-transaction pulse; successful
completion commits the actual stream cursor. Full failed delivery remains in
Runtime.deliveries and is serialized, not reduced to a status or checksum.

| checkpoint | tick | frame | retained events | droppedThrough | frameStart |
| --- | ---: | ---: | ---: | ---: | ---: |
| initial | 2 | 1 | 0 | 0 | 0 |
| activated-failed | 3 | 2 | 0 | 0 | 2 |
| 65537-published | 196614 | 65539 | 65537 | 0 | 196611 |
| capacity-frame | 196614 | 65540 | 65536 | 6 | 196614 |
| overflow-failed-reader | 196615 | 65541 | 65536 | 6 | 196614 |
| overflow-successful-retry | 196616 | 65542 | 65536 | 6 | 196615 |
| empty-repeat | 196617 | 65543 | 0 | 196614 | 196616 |

The published snapshot includes complete transitions0→1 through65536→65537 at
ticks6+3v. Its final publication occurs after that invocation's frame, hence all
65,537 events remain until the explicit capacity-frame. Active cursor 0 holds the
expiry boundary at0; capacity then drops exactly the first singleton tick6.
Both overflow failure and retry expose the same complete 65,536 ordered payloads,
1→2 through65536→65537, with lagged=true. Success commits 196616. The final frame
then expires every remaining event through tick 196614; the repeat reads empty,
lagged=false and commits 196617. Previous/current remain65536/65537, pending none;
changed is true only at the post-publication checkpoint, then frame clears it.

## Queue/source applicability

Current canonical Stream owns private Queue(front oldest-first, back newest-first,
size, droppedThrough, batchCount), real positions and frameStart. Publication
increments cached event size and batch count. normalize reverses back only when
front is empty. Read traverses front then reversed back and reverses the result
accumulator, preserving all batch/internal value order. Pure snapshot lowers every
retained batch/value/position/drop/frame field; cached metadata is not substituted
for payloads in observation.

The two trim passes match canonical Ev.past_window then capacity eviction:
expired *prefix* first, whole-batch capacity prefix second. Each pass has
batchCount+1 structural fuel; raw empty compatibility batches remain representable
without an event-size-based fuel underflow. Cached size is the sum of full batch
payload lengths and cached batchCount counts empty batches too. Selftests include
nonmonotonic prefix ordering and empty-batch retention/removal, with substantive
cache invariants. These are source-model checks, not new executable fixtures or
universal proofs.

The qualified old queue combined expiry and capacity conditions in one pass.
That is equivalent for this reached monotonically increasing singleton publication
sequence; it is *not* asserted equivalent for arbitrary ticks. Current two-pass
source restores the canonical ordering on that broader input. Existing source
joins and this full finite oracle do not silently promote the old queue as general
authority. Initial/skip/disposal routes are not reached by this capacity fixture.

## Complete output and limits

Each checkpoint retains all 22 existing observer fields: World allocator/live/store/
stamps, complete affine resource values, slot/stream/frame/tick/error, command
count, registrations/access/order/next ID/World clock/event count, both owners,
actual reader capability, and every complete accumulated delivery/lag flag.
The empty seed history, first failed empty read, failed full delivery, successful
retry full delivery and final empty repeat all remain in order. `Fmt.show` is the
same character-accumulating source as the qualified formatter, preserving brackets
and comma-space separators without recursive growing-left String appends.

`Core.finish` joins seven rows without a trailing LF. IO.print writes
SCHEMA=A + LF + seven rows + LF + SCHEMA=B + LF + seven rows, then appends exactly
one terminal LF. This IO entry emits raw text; no pure String quotes are added.
The compressed artifact contains the entire 19,367,810-byte wire, not an aggregate;
`model.py` reproduces the raw `expected.stdout` beside it for collector use.

Run `python3 model.py` for source/hash/joins/finite state/complete payload checks
and exact raw/gzip/hash reproduction. No compiler/backend is invoked. Sourcecheck
IO/foreign dependency refusals are not mathematical proofs. No claim is made for
performance, arbitrary forged cached metadata, universal queue refinement, or
unreached initialization/foreign-reader/disposal scenarios. The unchanged collector
must compare full actual JS/Native stdout before backend acceptance.
