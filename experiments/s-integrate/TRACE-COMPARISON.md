# Public trace comparison contract

`trace-compare.py reference.json observed.json` compares exactly four nominal
schema/capture lanes and ten complete public observation channels. Its observed
input must be produced from the actual joined runtime. It does not execute Bend,
normalize allocator IDs, discard payload cells or infer missing observations.
Missing channels or lanes fail as incomplete. Scalar types and sequence order
are exact; object key order is irrelevant.

The input envelope carries `results`, each with `lane`, `schema`, `style` and
the channels listed by the comparator. Source/environment manifests are kept
outside the comparison: runners must independently check and record them.
Reference bookkeeping (`scope`, `unexecuted`) is not runtime output. Approved
foreign-handle divergence is a separate E10 control, not an equality with TS's
numeric-handle lookup; E11 retention uses its separate reference and gate.

Comparator perturbation controls only establish that comparison detects defects.
They do not establish any integrated runtime capability. Full Host output and
fresh TS/Native/JS parity remain required before acceptance.

`trace-decode.py observed.jsonl decoded.json` accepts actual lane headers,
lossless Host events and actual plain Audit lines. It converts Four records to
arrays, constructor tags to public result shapes and actual namespaced handles
to their previously observed labels. Raw IDs remain exact; namespace checks reject
foreign handles in local observation channels. Original complete events remain
in `actualEvents`, including world marks/queue/allocator and reader boundaries.
The extra pre-write B observation remains in that raw evidence while the two
public own-write checkpoints use its actual middle/after views.

Decoder fixture controls check encoding and invalid observations, not a joined
execution. Provisioning is deliberately absent until the actual runtime control
is bound; full comparison then reports incomplete rather than supplying results.
