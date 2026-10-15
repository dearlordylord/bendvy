Frozen source-only authority oracle for producer bae0ed70d. source-freeze.json
binds all 38 literal Bend imports (independently traversed, compared to producer
FOREIGN-SOURCE-FREEZE.json, and copied without rewriting). source-pins.json also
binds both actual World namespace host effect bodies and Base/IO.print effects.
No generated source, candidate stdout or backend execution is an input.

foreign-disposal.main sequences run(SchemaA), then run(SchemaB), then one print.
Each run sequences two real WI.create calls. The C atomic allocator starts at 1;
the JS shared Symbol registry starts at 1 in a fresh process. Consequently local
and foreign namespaces are 1/2 for A and 3/4 for B. No literal namespace-seeded
World creation or schema erasure claim is involved. Each actual World begins
empty and Fixture.initialize publishes Initial A at World clock 1, revision 1,
default effects 1. No marker is bound/run; the only registrations are first ID1
and survivor ID2, in reverse allocation metadata order. Local nextSystemId stays
3 after both disposals; foreign nextSystemId is 1. Empty live/store arrays retain
their actual single leaf; all events/pending/component values remain unchanged.

The reached nested scenario evaluates: registered snapshot; failed first read;
foreign read; foreign disposal; retry; own first disposal; swap survivor into the
active owner field; survivor read; survivor empty repeat; own survivor disposal;
final complete local/foreign World images. These are nine observed checkpoints
plus a final image, per schema. Observed strings are appended without separators;
only each scenario's final image ends in LF. IO.print adds one further LF after
the two scenario strings. The complete expected bytes preserve that framing.

read preflight checks actual namespace/registry/port before activation. First
failure activates [1,0,1], returns attempted Initial A and failure text, retains
Registry cursor 0. Both foreign operations refuse before cleanup/activation and
preserve World and affine owner data. Retry returns Initial A, commits position
[1,1,1] and Registry cursor 1. Accepted disposal removes only registry/position1;
the surviving ID2 and unread publication remain. Survivor receives Initial A,
commits [2,1,1], then receives an empty reading without changing clock/position.
Its accepted disposal removes registry/position2. Publication remains retained:
disposal does not trim the stream, reset its loss/cache, or increment World clock.

State/render are reused from the prior independent finite initialization model;
model.py derives this new reached call chain independently. Selftests verify all
pins, operation anchors, foreign preservation, failed/retry cursor separation,
survivor identity and final cleanup. The complete executable Data projection is
modeled; affine owners are threaded in the Bend source, not copied by Python.
Finite source expectations are not backend acceptance or universal proof.
