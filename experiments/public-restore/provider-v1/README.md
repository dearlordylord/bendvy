# Detached constructor transport — development prototype

`provider.bend` binds a trusted closed schema-author callback to the **existing**
ordinary `Constructed` declaration. The callback receives its retained Codec and
original detached Raw; it returns affine Context plus the existing
`standard-owned.Reply<Raw,Payload,Issues>`. Payload, Context and Issues may be
arbitrary `Type`. No callback is copied or stored as a runtime function.

This follows TS Descriptor.decoderOf/Runtime.validate: select decode before
result, pass original input, retain the selected decoder's opaque output/error.
The wrapper does not automatically validate/canonicalize before the callback,
assert that a trusted callback implements its recipe, construct arbitrary Type
from Raw, install into World, or choose partial-construction recovery/release.
Rejected Raw and Issues are returned using the existing Reply protocol; Async
is merely an existing owned reply tag, not native asynchronous execution.

Source-only controls instantiate accepted Payload Array, rejected Issues Array,
and affine Context sentinel. `duplicate-owner-negative.bend` is an intended
checker refusal: accepted Payload cannot be consumed twice. These are type
checks, not executed value/owner preservation observations or #59 acceptance.
No backend, proof, numeric criterion, delivery or performance gate was run.

Retained raw evidence: `bend guide` completed under timeout5 and telemetry off;
`scripts/bend-check controls.bend` completed exit0; the negative completed exit1
with `owner (consumed more than once)`. Source commands used the existing shared
`/tmp/bendvy-parity-heavy.lock` and five-second checker cap. The lock here is the
ordinary direct development shell boundary, not a frozen collector protocol.
Absolute imports intentionally select root canonical nominal modules. This
worktree source check is not clean-checkout portable dependency qualification.
