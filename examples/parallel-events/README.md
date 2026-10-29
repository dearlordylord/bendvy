> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# Ordinary event families

`main.bend` runs five passes of the ordinary public root schedule for Data events
and affine `Array<U32>` events, under two unlike nominal schemas. Each case runs
through both serial and native schedule entries. A publisher, two independent
readers, an admin, a peer, and a registered condition retain their actual Local
owners between passes. The condition skips the slow reader twice.

The current consumer uses Permit-indexed capabilities and the closed framework
program adapter. Gameplay bodies defer their existing operations with
`Task.TRun`/`Task.TDone`; the original five passes sequence actual root-schedule
IO results with `IO.bind`. The resource layout and its physical-owner equality
proof are supplied to the ordinary root entry. This API migration does not add
an event operation or change the original eight scenarios.

The publisher sends directly into its canonical event-family resource. Its first
invocation publishes two payloads and then returns a handled body error. Both
publications remain visible. This is separate from deferred structural commands
and does not wait for a structural barrier.

The log owns each payload once. Its schema refresh constructs a canonical Data
view while threading every payload owner back into the log. This refresh runs
only at initialization and Writable operations. Ordinary reader capabilities
use `ResourceRead<H, View<S, P, key, U32>>`; they read the structural cache and advance only
their own affine reader token held in Local. A read receives no payload projector
and cannot modify or duplicate an affine payload. The current canonical metadata
conservatively marks all overlapping physical family accesses Exclusive. Readers
have ReadOnly permission; publisher and admin have Writable permission. No
parallel shared ownership of the affine log is claimed.

`execution-event-ops.bend` wraps the actual ordinary builder grant. Its writer
returns either a publication ID or the refused actual payload. Its admin accepts
typed commands and returns registration/removal tokens or actual retired rows.
All outcomes remain Type values. The common writable `own` operation returns
them through the same physical slot authority, without a second access catalog.

`execution-event-io.bend` allocates actual log identities through the existing
World namespace allocator. Tokens bind nominal schema, nominal family key, and
runtime log identity. The foreign token in the example comes from a second
actual allocation and registration. Pure raw constructors remain trusted setup
operations and are not universal host-identity proofs.

The trace includes partial progress before errors,
resumed execution, retention lag, retained/future reader creation, actual reader
removal, a genuine foreign-log refusal, publication refusal after shutdown,
retired/shutdown owners reused twice, the canonical cache, final cursor owners,
access metadata, condition and peer counts, and preserved handler capture.
The source-shared concrete entries in `cases/` preserve the full five-pass state
and both schedule routes. Historical oracle receipts describe their original
source; retired oracle and expected-output files are not current acceptance.
The additional Future-fast
case observes newly published row 2 immediately after the publisher's handled
error in the same schedule pass, then resumes at row 3 on the next pass.

## Bevy behavior

The pinned reference is Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`.
Retained/future creation follows
[`get_cursor` / `get_cursor_current`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L172-L184).
A read clamps to the oldest retained message, reports missed messages, and
advances per yielded item, following
[`MessageIteratorWithId::new` and `next`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/iterators.rs#L54-L99).
A later returned body error does not rewind that returned token.

Updates retire the previous generation after two updates, following
[`update_drain`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L187-L218).
Bend returns the actual retired or shutdown owners explicitly. It does not
invent an automatic IO finalizer. Shutdown and explicit token removal are Bend
ownership operations; no universal Rust Drop equivalence is claimed.

The source controls use actual affine arrays and unlike nominal schemas. They
check undeclared reads, writes through read authority, nominal family mismatch,
reader/payload duplication, abstract-scope escape, an affine payload proposed as a Data read view, and wrapper construction
against the wrong schema, payload type, or nominal family key. The cached view
binds all three brands to the same canonical resource grant. These descriptions
state the existing controls' intended boundaries; the current consumer migration
does not qualify every historical control receipt. Proof-only checking of the
executable main reports its explicit foreign Driver/allocator/IO dependencies;
backend emission checks that executable.
Finite observations do not establish universal correctness or host refinement.

From the repository root, the ordinary product commands are:

```bash
BEND=/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35
"$BEND" examples/parallel-events/main.bend -o /tmp/parallel-events.js
node /tmp/parallel-events.js
"$BEND" examples/parallel-events/main.bend -o /tmp/parallel-events.native
/tmp/parallel-events.native --threads 2 --gpu off
```

The compiler path is local to the preserved development environment. A native
worker count or a schedule entry named native does not establish actual worker
participation; that requires source-bound observation of reached operations.
Historical control receipts require their own current-source reuse assessment.

At current runtime source `4621bdab81d46a0c4a5450f17fa37c8c4c847fd1`, the
original eight-mode entry emitted C with official Bend 2.0.37, compiled with
project clang 19.1.7 C11/O3/pthread/libm and ran with two workers and GPU off.
Every stage exited zero and runtime stderr was empty. Its complete eight-line,
17,291-byte output matched the independently source-derived expected output,
frozen before reading the actual output. The current JavaScript artifact also
matched that full expectation; later control and documentation changes did not
alter its imported runtime code. Expected/output SHA256 is
`97b760755584e75f8af190ec6ac296d136b999792f60f70a8deb02f0362207e3`.
The retained C, binary, individual exits and comparison are recorded in
`/tmp/gh84-current-native/receipt.md`.

A single symbol/thread observation of that same binary recorded actual typed
publication on OS worker 3746868 and the deferred peer callback on OS worker
3746870 within the first A-affine-native schedule invocation of one World.
The first selected-call boundary opened recording and the second closed it.
Event-family users still serialize; this does not claim concurrent log ownership.
GDB all-stop perturbs scheduling. Its diagnostic records interrupted buffered
stdout, so the initial label-only extraction failed; removing only those records
and joining the retained actual continuation fragments recovered all eight lines,
which matched the complete independent expected output. The raw trace, initial
capture failure and successful full comparison remain in
`/tmp/gh84-current-native/operation-receipt.md`. There is no register/heap/ALC
inspection, forced scheduling, temporal-overlap, speedup, GPU or universal
owner-preservation claim.
The earlier `dd0652c354` 2.0.35 eight-line, 11,275-byte receipt remains historical,
including its returned-payload projections; it is not relabelled as the current
17,291-byte independent observation. Historical control receipts retain their
own narrow source-bound reuse requirements.

At runtime source `4621bdab8`, eleven existing intended authority refusals have
narrow current-source reuse evidence, including the separately checked abstract
scope escape. The binding audit compares the unchanged control and endpoint
definitions; it does not promote historical whole import closures or changed
wrapper-selection adapters into current proof-check passes. See
`/tmp/gh84-authority-reuse-audit.md` for the exact scope.
