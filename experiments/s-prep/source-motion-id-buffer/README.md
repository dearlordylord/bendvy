# Motion-only owner rows and split ID buffer — layout probe

Frozen source `/tmp/bendvy-slot-host-motion-id-buffer-v10`, closure
`b5dd78364ee9ef376eb8227fd7d11c79bc3ecf26c3e17e35bb17fc613f41848e`.
Baseline concrete-v3 `a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
Root authorized the conditional split-ID design in
`docs/reviews/native1024-concrete-source.md` after raw v3 comparisons.

Q preserves the entire v3 byte prefix and appends Motion-only private types and
helpers. Owner rows carry the nominal MainSlot plus recursive tail, without ID.
An affine companion Bundle carries owned Array<U32> and selected count. Only
successful Some evacuation writes buffer[count] and increments count. Descending
production and prepend align the head with ID[count-1]; ascending drain/recovery
read that index and decrement once. Recovery restores full current and remaining
owners and reverses the accumulated Data IDs once.

HA inserts new private Motion helpers before the existing Motion entry (Bend
requires filled definitions before use), redirects one existing Some/Main guard
call, and preserves all original function bodies and the Health route. The new
preflight allocates the actual ID buffer and reads its actual Array.size before
Q evacuation; both Main and IDs sizes must cover declared capacity. Initial
LedgerNone and rejected preflight use the original query/fold route. Callback,
returned context, pending Pair, marks, namespace/id and true-old journal bodies
remain original. Original generic arbitrary-Type and concrete-v3 Q routes remain.

All three module checks passed on CPU6, limit15s. The original Motion Dense1024
batch/measurement driver was changed only by source path and emitted to C within
30s. Actual successful prepend allocates cls_fit(8): seven explicit MainSlot
fields and one recursive tail. Actual scalar ID read/write and selected-count
increment remain in the reached C; ID buffer setup and guards remain workload
work. There is no allocation or speed claim from this layout observation.

Native build, runtime/oracle comparisons, fresh semantic/mutation gates and
allocation/timing await root decision. No v3 acceptance transfers. The private
producer invariant aligns owner-list length, selected count and initialized ID
prefix; arbitrary exported malformed detached Bundles cannot be universally
recovered. Preflight size controls belong before evacuation.

Bounded failure history v1–v9 is retained as exact compressed checker output and
frozen source directories. Errors included forward definitions, helper ordering,
tuple matching, generated guard header, callback shadowing, incomplete ledger
match and unmarked repeated Nat depth. These are rejected preparations, not
admission. v10 checks and actual C are separately archived. `freeze.py` verifies
original bytes and decoded source archive hashes. No law/proof, compiler/kernel,
reference, dependency or external-repository edits occurred.
