> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# Ordinary event families

`main.bend` runs five passes of the ordinary public root schedule for Data events
and affine `Array<U32>` events, under two unlike nominal schemas. Each case runs
through both serial and native schedule entries. A publisher, two independent
readers, an admin, a peer, and a registered condition retain their actual Local
owners between passes. The condition skips the slow reader twice.

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

[ORACLE.md](ORACLE.md) derives the complete expected observations independently
of the backend capture. The trace includes partial progress before errors,
resumed execution, retention lag, retained/future reader creation, actual reader
removal, a genuine foreign-log refusal, publication refusal after shutdown,
retired/shutdown owners reused twice, the canonical cache, final cursor owners,
access metadata, condition and peer counts, and preserved handler capture.
`expected.stdout` contains the complete eight-line result, not a checksum.
The source-shared concrete entries in `cases/` preserve the full five-pass state
and both schedule routes while bounding native compiler fanout. Their separate
oracles account for each fresh executable's allocator. The additional Future-fast
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
binds all three brands to the same canonical resource grant. The pure family, view, operations, declarations, and positive
control source-check. Proof-only checking of the executable main reports its
explicit foreign allocator dependency; backend emission checks that executable.
Finite observations do not establish universal correctness or host refinement.

`check.sh` uses the existing `common.sh` build and execution path. It checks source
controls, repeats complete JavaScript observations, and optionally builds native
code for each complete concrete case and repeats its full oracle with one and
four workers. Its first launch
requires the repository's independent runner launch review.
