# Two write-control repairs

Final review found that the original `query-write` and `both-write-through-read`
controls supplied a fourth erased argument to `Cap.value_write_field`. Those
failures stopped at its three-template-argument boundary and did **not** qualify
write-through-read rejection. The original source, raw streams, CHECKS and pin
manifest are preserved byte-for-byte under `history/arity-predecessor01`.
Their original broad diagnostic flag is superseded; neither predecessor counts.

The repaired calls pass the operation as the runtime fourth argument. Each was
recaptured with actual pinned CPU5/default5 argv, exit1, raw streams and exact
pre/post current pins. Both now fail at the intended operation type:

| Current subject | Expected | Observed |
| --- | --- | --- |
| `query-write` | `Cap.ValueWrite<H,Array<U32>,U32>` | `CQ.Read<S,RowView,H>` |
| `both-write-through-read` | `Cap.ValueWrite<H,Array<U32>,U32>` | `D.ResourceRead<S,Array<U32>,Threshold,H,U32>` |

The other eight negatives were separately audited against their complete raw
streams: cross-schema CD.both and CQ.Read, missing query grant, presence-only
versus projected view, abstract World/Frame/Handle escape, and affine App
quantity. Each reaches its actual type/quantity diagnostic; none is an arity,
parser, missing-file, timeout or foreign-IO refusal.

The other13 actual checker invocations were **not rerun**. Their rows retain
original source/raw hashes and point to the archived original execution pins.
CURRENT-REUSE.json joins each unchanged reachable import closure and raw stream
to current source; only the two changed, unimported sibling controls are excluded
from the old package-wide pin comparison. Their original bytes are retained in
the history and mapped by original path/hash. The two recaptured checks bind the
updated current SOURCE-PINS.json. No core, consumer, oracle or backend changed.
