# Two nominal schemas: automatic ordinary public dump oracle

Producer commit `c59953d61998073d0e65d8ef2ac68cf9f845eee0`, main SHA256
`08ec81d7072e073f3ec2d718d2b9273ace872b5c325fee955d10b8bfadd54a35`.
Source freeze manifest SHA256
`c23a8d98f527b7efe1c9a0141055858610afb3ac8cfd54ac72e2cf07fe83206f`.
Before calculation, all93 actual source bodies and the freeze manifest were
copied unchanged into `/tmp/bendvy56-two-schema-oracle-source01`.
No runtime output, generated JS/C or receipt was consulted and no backend ran.
Earlier oracle artifacts remain unchanged.

Complete raw stdout:21,996 bytes; SHA256
`d332408d79ccb29bc3dff64cbd93a01add72d7d07157c96cba3f14f04505ef4a`.
All14 complete records, provider owners/facts, World fields, shared metadata,
dump rows/values/resources and every ordered event/error are retained. Each
instance's computed String ends in LF; **each** of the two sequential IO.print
effects appends another LF. Output is therefore two identical10,998-byte
segments, each ending in two LFs. It is not one combined print or a checksum.

## Source-backed reuse and nominal independence

The renderer computation was reused from the prior independently source-derived
single-instance `derive.py.source` **source code**, not from its expected or
runtime files. The pinned source code's `build_output` renders the seven-record
argument String. Its byte construction was read against this actual fixture,
public dump API, observer and definition callgraph. The reused pure helpers and
builder have no output-input dependency; no prior golden is read or executed.

`SOURCE-FREEZE.nominalSourceCopyMap` lists five nominal modules: fixture,
declarations, observer, registration, dump. Self-test verifies every recorded
old/new SHA, removes only import lines and checks all remaining body text
exactly equal. It additionally compares each corresponding import alias and
resolves dependency targets: an imported nominal module must point to its exact
beta clone; all other imports must resolve to the same canonical core module.
Thus beta's actual `type Schema is Data` declaration is in its distinct fixture
module, and its declaration/registration/dump lenses remain consistently bound
to that nominal schema. This is not merely printing one schema twice or relabeling
an output. Both instances use the same canonical ECS implementation.

Main imports First public dump and Original fixture, then beta Second dump and
Beta fixture. `IO.bind(Unit,Unit,IO.print(First.ready(Original.setup())),second)`
finishes the first print before `second` calls
`IO.print(Second.ready(Beta.setup()))`. Both fixture setups use their own actual
pure `W.factory()` (not WorldIO). Each factory starts namespace1 and creates
entity1; nominal separation therefore changes types while public numeric names
remain equal. No global namespace effect is invoked or inferred here.

## Exact shared computation for each instance

Actual setup reserves/activates entity1 and stores42 in the sole column leaf,
with no lifecycle stamps. World namespace1, nextId2/highWater1, live
`[false, true]`, capacity2/depth1, Unit resource, clock0. It publishes, in order,
original Value11, original Removed(entity1,value), and the complete Parent
hierarchy self-relation failure. `Mixed.start` leaves typed journal/batches and
keyed domains/positions empty, all runtime clocks0.

Public dump `ready` detaches the actual World, queues a real deferred closure
which would publish original Value999, then rejoins. It calls actual
`P.define_all(...,"public-dump-reader")`: canonical Declared query + two same-
domain message readers + removal + keyed relation product, with automatic
`RF.define_mixed` provenance. One actual registry1 is created. Access order
`[value,values:read,values:read,removal,value,Parent:read]` retains duplicates.
Uses retain component/query/value/with, event/message/values/read twice,
event/removal/value/read and event/relation-failure/Parent/read. Query owner is
Unit; message IDs1/2 have registryId1; removal has registry1/name value/cursor0;
relation owns Some1/keys[1]. Every owner retains actual registry facts. Registry
and reader cursors remain0; nextSystemId2, leaf nextReader3, keyed nextReader2.
No callback/prepare/ingestion/frame/barrier/disposal occurs.

`attached` uses the actual operational component binding identity once to build
the schema and uses actual `RF.attach` over the registered provider and shared
metadata. The public dump receives the schema-bound count/presentation operations
from that binding. `value_view` returns the actual U32 owner unchanged while
presenting its Data value; `Provision.values` renders42. No parallel hand-authored
debug registration or cached dump supplies the rows.

The exact record continuation is before/no-dump, all, repeat, filtered,
zero-limit, disabled, reenabled. Before records actual physical state before
calling dump. All scans actual live entity1 and renders
`dump(1,[row({"namespace":1,"id":1},[value("value","42")])],[])`.
Repeat and selected ID1+required value+limit1 produce the identical dump.
Zero-limit returns `dump(1,[],[])`: alive count1 is measured before selection and
limit, rather than replaced by selected row count. Disabled returns none;
reenabled returns the original complete dump. Unit resources yield no values.

All physical observations are identical across all seven calls: pending count1,
original three events, no999 publication, actual column some42, unchanged live
array/stamps/resource, one actual registration, unchanged monotonic allocators,
empty typed batches/journal/positions and keyed domains/positions, clock0 and
route0. Dump is observational: it neither executes the pending closure nor
invokes a reader, advances a cursor, consumes an affine component owner, changes
provenance, resets allocation or drains any history.

## Serialization, pins and checks

Public dump `record_physical` adds a LF to every record. It embeds actual
`P.physical`, whose provider renderer includes registry identity/access/cursor,
parameter access, complete ordered declared uses and actual reader facts/owners.
Observer `world_final` includes every World field, the full live list, actual
column tree/stamps, Unit resource, complete events, pending count, registrations,
nextSystemId and clock. Its shared state renders all stream/failure metadata.
Source compact-list punctuation and the Base List.show comma-space in live bits
are preserved. The two print effects append their own LFs independently.

`source-pins.json` verifies all93 immutable bodies plus manifest, installed Base,
actual print.js/print.c and the independently source-derived model source:98 pins.
`source-freeze.json` records producer commit and immutable/original roots.
`python3 derive.py` verifies those pins, five import-only body equalities and
alias/target dependency equivalence, two distinct fixture Schema declarations,
exact IO sequencing, complete expected bytes, seven labels per instance,
repeat/filter/reenable equality, zero-limit/disabled values, all physical snapshots
identical, actual pending999 unexecuted, stream allocator/failure metadata,
14 records and both independent double-LF print boundaries. Python source check
passes. `--write` regenerates only from this source calculation.

This expectation does not establish actual JS/Native execution, arbitrary affine
payload presentation, graph/machine dump coverage, runtime-world foreign handle
isolation, negative authority controls, feature timing/scaling or full#56.
Pure trusted factories and existing U32/Unit presenters are the precise source
scope; no new contract, law, dependency, numerical limit or runtime flag follows.
