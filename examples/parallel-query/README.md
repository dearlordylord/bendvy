# Registered affine query execution

`main.bend` runs the original four scenarios through the current Task/IO entry:
First/serial, First/parallel, Second/parallel, and First/error. The first three
execute a registered query system three times; the last stops after its second
execution. `application.bend` sequences registration, execution and foreign-World
refusal with `IO.bind`. `body.bend` returns the existing `Task.TRun`/`Task.TDone`
boundary and invokes its abstract `execution-query.Each` capability once per body.
Gameplay does not split columns, dispatch workers or reconstruct the World.

The declaration is an abstract program over the library's closed Builder. It
selects two component leaves through a route in the closed component layout.
Actual column owners carry their keys in their slot types. Equality checks bind
the complete World storage type and selected pair to that layout. The library
derives both payload types and access keys from that route, then extracts and
rejoins the actual owners. The ordinary entry does not accept an arbitrary
storage lens, capability provider, payload identity or access catalog.

The input projector produces a reusable `U32` view; the closed item body receives
that view and one affine output owner. Both unlike families contain nested affine
token arrays. The library partitions actual child column owners and metadata,
executes parallel calls between chunks, and rejoins the returned owners. Serial
mode uses the same item body and observations. An affine projector can replace
its returned owner, so the declaration requires exclusive input storage access.
An affine return type alone does not prove that arbitrary gameplay preserves the
original owner.

## Read the consumer

- `declarations.bend` binds component identities and the typed layout route.
- `body.bend` invokes the query capability and retains its affine Local.
- `payloads.bend` defines the direct update and owner observations.
- `application.bend` creates the World, registers the system, executes it repeatedly,
  and attempts admission to a second World from the advanced factory.
- `observation.bend` consumes complete snapshots of both Worlds and the returned
  system owner.

Both columns grow from 8 to 32 physical slots. Matching live rows occupy physical
slots 0 and 16, in separate size-eight leaf chunks. Their logical handle indices
are 1 and 17. Physical slot 15 has unmatched input; slot 17 has unmatched output.
The write chunk at physical slots 8–15 is empty, while its input chunk contains
slot 15. Physical slot 30 contains both families but is not live. Selection comes
from the current World's live handles and leaves that inactive row untouched.

The first execution succeeds. The second updates logical row 1, reports its
handled item error, retains the write, and also updates row 17. The third
execution succeeds. Final token/value pairs are `104:19` and `205:35`. The fourth
scenario observes the two-run state immediately after the error, before another
write can mask a stale cache. Each selected output rebuilds its cached Data from
the returned actual owner, including on error. Original added ticks survive;
untouched, absent and nonlive rows retain their caches and stamps.

The full observations include every allocated input/output slot, actual token
projections, cached values, lifecycle stamps, allocator fields and slots,
allocation order, resource owner, pending/event counts, registration metadata,
World clock, system cursor and Local owner. They also include the complete
incoming foreign World after admission refusal. First and Second are distinct
nominal schemas.

## Run the ordinary product

From the repository root, using the preserved Bend 2.0.35 compiler and its matching
resource tree in this local environment:

```bash
BEND=/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35
"$BEND" examples/parallel-query/main.bend -o /tmp/parallel-query.js
node /tmp/parallel-query.js > /tmp/parallel-query-js.stdout
"$BEND" examples/parallel-query/main.bend -o /tmp/parallel-query.native
/tmp/parallel-query.native --threads 1 --gpu off > /tmp/parallel-query-native1.stdout
/tmp/parallel-query.native --threads 2 --gpu off > /tmp/parallel-query-native2.stdout
cmp /tmp/parallel-query-js.stdout /tmp/parallel-query-native1.stdout
cmp /tmp/parallel-query-js.stdout /tmp/parallel-query-native2.stdout
```

The native `-o` route invokes the compiler's ordinary native backend and clang.
The `/tmp` compiler path is environment-local, not a compiler bundle distributed
by this example.

At source commit `dd2da438faeb6fa67e424185ea1ce61b04b2a1cf`, unchanged pinned
Bend 2.0.35 compiled this original entry for JS and native. Each build and each
ordinary run exited zero. Native counts one and two produced the same complete
four-line, 9329-byte stdout as JS; standalone comparisons exited zero. These are
comparisons of actual product outputs, not an independent semantic oracle.

One debugger execution of that existing native artifact additionally observed
actual nested output-token writes for physical rows 0 and 16 on allocator/worker
identities 0 and 1 within the **same First/parallel query traversal**. Existing
scenario entries and the whole `Q.each` call/return bracket distinguished that
invocation from serial mode, other schemas and repeated executions. Actual
mutation instructions, rather than callback symbols alone, established reached
row work. The debugger's all-stop breakpoints perturb scheduling: this finite
observation establishes neither temporal overlap nor speedup or universal worker
placement. There is no GPU claim or universal ownership proof.

The local receipt is outside the repository at
`/home/node/.claude/orchestrate/bendvy-gh78-94/native81-original-query-delivery.md`.
It binds saved outputs, binary and operation trace to that source commit. Those
local artifacts are not a portable qualification bundle and do not transfer to
later source changes.

## Authority controls and historical evidence

The existing `controls/positive.bend` and `controls/layout-positive.bend` express
valid registration/layout cases; the latter uses equal payload types with distinct
keys. Its wrong-key counterpart targets equality against the actual keyed owner
types, independently of payload-type differences. Other control sources target
schema mismatch, undeclared capabilities, replacing a cached Data view with an
affine owner or different view type, copying affine output, escaping scope,
selecting a single leaf as a pair, and duplicate query keys. The shared ordinary
entry's `examples/parallel-execution/controls/forged-declaration.bend` targets a
raw declaration whose exposed resource contradicts its empty access catalog.
These describe the controls' intended authority boundaries; the dd2 product
execution above does not establish fresh acceptance of every control.

Historical receipts for source `8183783` describe an earlier synchronous entry
and its then-existing independent oracles. Those receipts remain historical and
explicitly did not establish actual multiple-worker use. The retired oracle and
check-script commands are not current runnable instructions. Semantic proof work
uses Bend laws: the five approved helper laws do not prove this whole ECS, and
other draft laws have not been approved.

## Affine query outputs and commands

The adjacent `output-declaration.bend` selects the physical layout through the
canonical Builder. Its command Program receives the hidden output type and
canonical command operations at registration. It specializes row body, split and
merge before runtime capabilities are stored. `OutputEach` takes the actual scope
and output owner without a polymorphic runtime callback or raw storage adapter
in gameplay.

`commands.bend` describes six registered command-system scenarios over two nominal
schemas: parallel query with final deferred application, parallel query with final
application suppressed, and serial query with final application. Callbacks update
owned rows and author inserts using genuine selected handles; row 1 returns a
handled error after enqueueing. Observations include columns, caches, stamps,
allocator/resource state, queues, displaced-owner receipts and returned owners.
The raw `test-fixtures/chunk-column/output.bend` consumer also covers an
Array-owning output prefix. These adjacent consumers are outside the dd2 original
`main.bend` execution and worker evidence reported above; historical oracle or
wrapper receipts are not source-current execution claims for them.
