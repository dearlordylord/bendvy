# Native point cache boxing — draft follow-up

#21/#24 hypothesis, **not implementation or performance acceptance**. Follow the
profiled transport/drop seam; preserve the full ECS scope and arbitrary affine
component payloads.

Read-only agent inspection of the [live-first Native C archive](../../experiments/s-prep/js-query-live-first/evidence/native-batch.c.gz)
finds reached Motion held-row calls to `spin_97`/`spin_98`, with21/22 value
parameters plus7 `q` parameters. `spin_98` reaches `spin_86`, with42 values/12q.
The existing boxed World occupies one value; each concrete Main/Ledger Cache
still flattens to seven (raw array, raw scalar and five view scalars).

Two recursive private cache boxes might reduce the held-state portion from21
values to9, while q transport remains roughly unchanged. Pinned Bend2
`a950fd6`, `bend2/comp.ts:938`, forces recursive datatypes to BOX; a simple
nonrecursive wrapper would flatten again. These are ABI observations and a
layout prediction, not a performance result or Health ABI claim.

Minimal experiment: use the existing generic recursive world-box mechanism for
`Cache<Raw,View>`, or an equivalent private recursive cache box. Wrap only the two
private held fields at guarded owner entry. Open/rebox the affected cache in each
provider; leave the other boxed. Unbox both at final World restoration. Preserve
the public Cache representation and immutable Data snapshots, true-old journal,
marks, queue and ownership. Every recursive constructor needs a total unbox path.

Extra boundary allocation and repeated box reconstruction/free may outweigh
transport savings; the sampled Native drop cost makes this a concrete risk to
measure. First inspect actual reached C ABI and negative owned-array/access/schema
controls; then suppressed setter, inverse/rollback and complete fields. Exact-role
full22 and complete equivalent JS/Native performance remain required before any
adoption. No compiler/reference/kernel changes or new law/proof are authorized
by this draft. This source probe is a separate follow-up from compiler node reuse.
