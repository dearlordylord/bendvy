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

## Concrete schema-author witness

`witness.bend` now supplies an actual detached constructor for a Boolean cell in
an affine `Array<Bool>`. It invokes the complete decoder on the original Raw and
the callback's retained Codec **before** allocating the payload. Acceptance
constructs its Array from the validated Boolean, then `roundtrip` consumes that
payload through the same ordinary declaration's projection/complete validator.
The projection reads the owned Array using `Array.get`, returning its owner and
Boolean Raw. Refusal returns the entire original Raw, original affine Context,
and Issues containing the exact decoder error plus an affine Array sentinel.
No stored/prebuilt accepted Payload is passed into this constructor.

`accepted_control` and `refused_control` are source-consuming complete paths,
not executed output comparisons or universal round-trip proofs. The witness
callback's fallback for a wrong accepted shape is schema-author behavior only;
the generic provider neither constrains Payload nor introduces an error policy.
The first source check rejected the reusable `+raw` function argument annotation
against the affine callback type. The correction copies Data only inside its
match; source attempt2 PASS, cap5/telemetry off. Both raw attempts are retained.
No World transaction, allocation rollback, release or capture policy is added.
