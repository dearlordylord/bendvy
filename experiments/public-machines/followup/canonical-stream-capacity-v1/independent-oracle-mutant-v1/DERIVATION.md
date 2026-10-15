# Reached no-capacity-eviction counter oracle

Normal oracle df3845cce7cee2ead099cb9aa4af0dc1437da82d and all qualified normal
outputs remain unchanged. This countermodel is independently source-derived;
no mutant output, generated artifacts or backend execution was consulted.

The isolated snapshot `/tmp/bendvy48-canonical-capacity-no-eviction-mutant-source01`
retains all 30 literal source paths, including the exact 28 Bend module identities
and two actual World namespace C/JS effect bodies. Only one source expression
changes, inside Q.capacity_normalized in `src/ecs/machine-stream-queue.bend`:

- Before: `trim_step(~E,Nat.is_lt(capacity,size),tick,count,items,rest,back,size,dropped,batches,ih)`
- After: `trim_step(~E,False{},tick,count,items,rest,back,size,dropped,batches,ih)`

`source-freeze.json` records the precise before/after hashes. The selftest verifies
this exact single replacement and byte identity for all other 29 files against
the preserved normal snapshot. No import, count, frame, publication, callback,
serializer, namespace allocator, collector or numerical limit changes.

The independent queue model changes only the capacity-pass predicate to false.
The expired-prefix pass, normalization, cached event size/batch count, reads,
reader cursors, raw snapshot, transaction status and complete observation remain
unchanged. It recomputes the entire actual operation loop and all payload lists;
no textual normal-output patch supplies the counter bytes.

Every actual one of 65,537 singleton publications and its per-publication frame
still occurs. Through `65537-published`, all normal observations are identical:
active cursor0 holds expiry at boundary0, and the normal final publication is
after that invocation's frame. At the explicit capacity-frame, the mutant now
retains every event, including the oldest tick6 transition0→1; droppedThrough
remains0. Failure and retry therefore each expose the complete ordered 65,537
transitions0→1 through65536→65537 with lagged=false. The first failed callback
preserves cursor0; the successful callback commits196616 exactly as normal.
The next frame's unchanged expiry pass then removes all batches through196614;
empty repeat is still empty/lagged=false and commits196617.

All seven checkpoint ticks, frames, status/error, World/component/affine owner
state and registration metadata retain their normal values. The changed states
are capacity-frame/overflow failure/retry stream size65,537/dropped0 and the
complete failure/retry payload/lag views retained in all later deliveries.
The final droppedThrough196614 is unchanged because expiry still executes.
The complete counter wire has 19,367,924 bytes; it differs from normal and the
model asserts rejection by the normal full oracle. The compressed artifact is
the whole raw wire, not an aggregate. The model regenerates the raw stdout file
beside it for ordinary collector comparison.

The entry and framing are unchanged: fixed full.bend → checked parsed count →
two actual WorldIO scenarios, namespaces1/2 in a fresh process, seven complete
rows each, raw SCHEMA headers and exactly one terminal IO.print LF. Every existing
observer field/list/order/identity/metadata and every payload remains present.
`source-join.json` retains the normal qualified operation/CLI/format source basis;
it does not classify this capacity mutation as accepted behavior.

Run `python3 model.py` to check pins, exact mutation/inverse join, source joins,
finite failure/retry/expiry and full payload invariants, and reproduce full
raw/gzip/hash/timeline. This executes Python models only. As with the normal
fixture, Initial/skip/disposal and arbitrary-tick/empty-batch runtime controls are
not reached or claimed; source-model checks are not runtime qualification or
universal proofs. Root owns the unchanged collector execution of this mutant.
