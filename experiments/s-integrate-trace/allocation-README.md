# #19 reference prerequisite — failed reservation versus publication

**Fresh pinned TS checkpoint passes.** A failed system consumes its reserved
numeric entity ID while its staged spawn is discarded. Subsequent reservation
does not reissue the escaped failed handle. This is a finite reference checkpoint,
not integrated Bend implementation or a general production allocator policy.

Run from the repository root with the existing Node runtime and no dependencies:

```sh
timeout 5s node experiments/s-integrate-trace/reference-allocation.mjs
```

`allocation-evidence.json` contains the executed result on Node v24.20.0, pinned
bevy-ts commit `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, source/adapter SHA256
hashes, raw returned reservations, seven public observation checkpoints and
asserted outcomes. The adapter checks the source commit against the manifest
before execution. The command completed with exit 0 within the five-second limit.

## Exact operations and observed results

1. Create one bound schema with scalar `Payload`. Bootstrap reserves Payload10
   and applies an explicit deferred barrier: seed ID1 becomes live.
2. Execute the actual public schedule `(A, B, Tail)`. A writes seed10→11 and
   reserves Payload20, receiving ID2. Its system transaction commits; spawn2
   remains deferred. B writes seed11→99, observes99 through its writable query,
   reserves Payload30 receiving ID3 and escapes its public durable handle into
   host lexical state. Public lookup reports this reserved handle MissingEntity.
   B returns `Fx.fail({code:7})`; the public dispatcher reports system B failure.
3. A separate public observing system sees only seed1 Payload11. B's write was
   restored; A's earlier write persists; handles2 and3 are both MissingEntity.
   Tail has not run. An empty schedule followed by another public observation
   leaves this membership unchanged, establishing no implicit structural flush.
4. Apply an explicit deferred barrier. Seed1 Payload11 and A's entity2 Payload20
   are live. Escaped failed handle3 still resolves MissingEntity, showing B's
   spawn was discarded while A's successful publication survived.
5. A succeeding system reserves Payload40 and receives ID4. Public membership
   remains `[1,2]`, including after an additional empty schedule; lookup4 remains
   MissingEntity until the next explicit barrier.
6. Apply that barrier: public membership is `[1,2,4]` with payloads11,20,40.
   Escaped handle3 still resolves MissingEntity. ID4 differs from3 and follows it
   numerically; the failed reservation was consumed, not rewound/reissued.

IDs above are **actual public returned values** in this run. They are never
adapter-assigned constants or read from an internal allocation counter.
Assertions derive expected entity IDs from `commands.spawn` returns, preserve
raw IDs in evidence and compare subsequent reservations rather than normalizing
away consumed IDs. Membership comes from declared public queries, and handle
resolution from the public lookup API through real systems dispatched by
`runtime.tick`. No debug dump or internal world access is used.

## Scope and retained gates

This fresh prerequisite distinguishes reservation consumption from failed
structural publication, rollback of a scalar component, earlier committed work,
explicit barriers and skipped tail execution. It does not establish two-schema
integrated Bend ownership/rollback, readers/lifecycle/captures, Type payload
restoration, allocator exhaustion/reuse, universal refinement or performance.
The #19 concrete integration trace still requires review before Bend runtime
implementation. Existing source explains the observation: reservation increments
allocation immediately while transaction rollback restores journaled components;
the adapter verifies this through public observations rather than inspecting it.
Read-only references and the original `/workspace/typescript/jev` remain untouched.
