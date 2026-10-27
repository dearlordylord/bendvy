# Ordinary notice scenario checkpoint

This private source fixture continues GH85 from frozen588 in a separate worktree.
It does not modify the approved588 foreign Prepared fixture, its oracle, the
qualified external collector, or the deferred approved launch plan.

The current concrete `First` specialization is source-checked with qualified
Bend2.0.35, the existing70-resource bundle, CPU0/shared actual-uid lock and15s
compiler cap. Logs: `/tmp/gh85-notice-source/scenario6.{stdout,stderr}`; actual
exit0, ALL PROOFS CHECK. No C/JS emission or backend execution has occurred.

`notice-scenario-core.bend` uses a real query writer over affine Input/Output
Arrays in the left physical partition and Unit-local metadata readers in the
right partition, sharing the full global Store authority. It declares the
ordinary author→reader edge, so actual deferred publication precedes the read.
The ordinary command grant and query grant are retained together in the writer's
closed capability record. Setup supplies actual live handles through World.handles;
no gameplay callback receives a World. The first body queues output removal at
entity1 and despawn at entity17, then writes actual query Output owners. Its
retained query-body error does not discard these commands. Publication returns
the actual removed Output1 plus unlike Input17/Output17 owners in typed receipts.
There is no direct Notice.append or synthetic journal row in the fixture.

Four completed public updates exercise independent fast/slow output readers,
an unrelated input-family reader and a despawn reader. The slow reader remains
dormant for two updates; the fast reader advances once per yield even when its
first body returns an error. The final observation includes all physical column
slots/caches/stamps, allocator slots/generations/free/order, retained command
receipts and handles, Local affine tokens/runs, system and reader cursors,
complete reader history, handler count, registrations, clock, unapplied inventory
and authoritative journal channels/floors/active identities.

`notice-scenario-oracle.py` derives the four updates from declared initial owners,
live entities, command order, barrier and Finished retention policy. It reads no
captured implementation output. Initial oracle SHA256:
`cccfb2fa4d831a436dd5268bbd6d5718d9b3cefe270734b84b6e0e2abf8ec0cd`.
Initial expected stdout SHA256:
`36fc7176320c4912de01e6d3b55783a4a364d8cb8410edb1711dd2ec1eeae1d9`.
These are pre-capture development bindings, not backend qualification.

Still in this first scenario: genuinely created same-schema World B with matching
family sequence numbers; retire/release A reader Local and freshly register B
system with it. Actual system admission must succeed, Notice.read must refuse
ForeignWorld and preserve each reader cursor, while normal invocation advances
system cursor and body-authored token/runs. No implicit reader reset is selected.
The original system owner in A must not be used to mask this operation with a
Prepared namespace-admission refusal. The real IO driver and intended authority
controls still need source checks and full frozen observation before capture.

Both ordinary parallel forms, mixed physical/query/resource declarations,
canonical origin/refresher/classification controls, retirement/exhaustion and
remaining Finished/Stop/Invalid policy cases remain full-GH85 gates. This fixture
is not issue completion or a universal affine/concurrency theorem.
