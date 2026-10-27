# Registered affine query execution

`main.bend` runs the original four scenarios through the current Task/IO entry:
First/serial, First/parallel, Second/parallel, and First/error. The first three
execute a registered query system three times; the last stops after its second
execution. `application.bend` sequences registration, execution and foreign-World
refusal with `IO.bind`. `body.bend` returns the existing `Task.TRun`/`Task.TDone`
boundary and invokes its abstract `execution-query.Each` capability once per body.
Gameplay does not split columns, dispatch workers or reconstruct the World.

The query itself uses pure Bend parallel calls in `chunk-query.output_pair`.
The outer `Task.TRun` defers the body, but this main does not traverse query rows
through `TFork`. The adjacent taskful query engine uses `TRun` and `TFork` for its
branches and needs its own execution evidence.

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
allocation order, resource owner with its actual Unit cache and lifecycle stamp,
pending/event counts, registration metadata, World clock, system cursor and Local
owner. The terminal observer also consumes the full lifecycle Journal: namespace,
next-reader id, active reader ids/selectors, and every channel's selector, next
sequence, previous/current rows and dropped-through sequence. Each row includes
its full entity namespace/key/generation, tick and sequence. The Journal contains
no reader cursor field; cursors belong to separately owned Reader values. This
observer neither reads a Reader nor advances retention. These observations also include the complete
incoming foreign World after admission refusal. First and Second are distinct
nominal schemas.

## Run the ordinary product

From the repository root, use Bend 2.0.37 and project clang 19. Set `BEND` or
`CLANG` to an explicit executable path when needed:

```bash
	BEND=${BEND:-bend}
	CLANG=${CLANG:-clang-19}
	"$BEND" examples/parallel-query/main.bend -o /tmp/parallel-query.js
	node /tmp/parallel-query.js > /tmp/parallel-query-js.stdout
	"$BEND" examples/parallel-query/main.bend -o /tmp/parallel-query.c
	"$CLANG" -std=c11 -O3 /tmp/parallel-query.c -lpthread -lm -o /tmp/parallel-query.native
	/tmp/parallel-query.native --threads 1 --gpu off > /tmp/parallel-query-native1.stdout
	/tmp/parallel-query.native --threads 2 --gpu off > /tmp/parallel-query-native2.stdout
	cmp /tmp/parallel-query-js.stdout /tmp/parallel-query-native1.stdout
	cmp /tmp/parallel-query-js.stdout /tmp/parallel-query-native2.stdout
```

## Current observations

The original `main.bend` output is four lines totaling 9,873 bytes. An independent
expectation derived from source before reading outputs matched JavaScript and
Bend 2.0.37 native runs with both one and two workers. It includes the full
terminal observer described above, the state retained after an item error, and
the incoming foreign World returned after admission refusal. Temporary Python
helpers used for the derivation and comparisons were deleted after use.

A GDB trace of symbols and threads in the unmodified native artifact reached the
closed row-body closure that consumes `Output` and invokes its payload update. Two OS
workers executed that closure within query invocation 7, the first
Second/parallel traversal. IO sequencing places that invocation after three
First/serial and three First/parallel calls. Both worker observations occurred
before invocation 8 began, within the same World and query invocation.

The source selects only two live paired rows, at physical slots 0 and 16. The
current trace did not measure runtime row indices, allocator identities, heap
identity, or allocation behavior. All-stop breakpoints perturb scheduling, so
the observation establishes neither temporal overlap nor speedup or universal
worker placement. There is no GPU claim or universal ownership proof.

At historical source `dd2da438faeb6fa67e424185ea1ce61b04b2a1cf`, Bend 2.0.35 JS
and native runs matched an earlier four-line, 9,329-byte observer. Its debugger
trace observed physical rows 0 and 16 and allocator/worker identities 0 and 1
within one First/parallel traversal. That trace belongs to its original artifact.
It does not provide current row-index or allocator measurements. The later
terminal observer adds resource cache/stamp and complete Journal fields.

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
These describe the controls' intended authority boundaries. The product
observations above do not establish fresh acceptance of every control.

The retired oracle and check-script commands are not current runnable
instructions. Semantic proof work
uses Bend laws. The five approved helper laws do not prove this whole ECS. Draft
laws still need specific user approval before proof.

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
Array-owning output prefix. These adjacent consumers are outside the original
`main.bend` execution and worker evidence reported above. Historical oracle or
wrapper receipts are not source-current execution claims for them.
