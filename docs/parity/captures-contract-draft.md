# Captured systems — ownership decision draft

Status: proposed for discussion and explicit #50 approval. No law, proof or implementation approval is inferred.

## Proposed public behavior

1. A capture pack is an arbitrary affine `Type` owner, separate from the reusable closed runner definition and from World-specific registration. Every actual run consumes and returns this same pack on success and system failure. The runner cannot copy a closure or discard the pack to report failure.
2. Capture changes survive a failing system invocation; the ECS transaction still rolls back its component/resource/command/event changes. Capture state and Local remain distinct APIs. A skipped or refused invocation never calls the body and returns the capture pack unchanged.
3. Independently created packs remain independent. The same pack can be threaded sequentially through valid registrations in two compatible Worlds, preserving its updates across those runs. Registering or scheduling the closed definition does not implicitly copy an affine pack; explicit fresh packs create independent instances. Registration authority stays World-specific.
4. For invocation and disposal, the registration and capture pack are paired affine owners. Explicit detach returns them separately; reattachment can move the pack to a compatible runner/schema registration without moving registration authority or reader positions. Successful disposal consumes both owners exactly once. Release is a caller-supplied reusable closed finalizer `Capture -> Unit`: it consumes the pack, returns no capture owner and has no recoverable-failure result in this API. Rejected disposal returns both owners unchanged and does not call release. A disposed owner cannot be reused or disposed again. Mutable capture aliases are not exposed. Exactly-once finalization means one invocation and consumption of the pack; physical cleanup is the caller finalizer's responsibility, not an implicit runtime destructor guarantee.

The cross-World case preserves the observed shared-capture behavior through explicit ownership transfer. It does not permit simultaneous aliases or transfer a registration into another World. Public refusal and reader-cursor behavior must preserve the existing System contract; captures must be returned even when execution refuses before entering the body.

## Source basis and acceptance

The actual [TS reference](../../experiments/public-captures/README.md) observes failure persistence, condition skip, independent callbacks and the same callback shared by two runtimes. Pinned Rust Bevy stores the persistent function/parameter state in `FunctionSystem`; pinned Bend permits at most one call to a closure, including Data captures. Explicit affine pack threading reconciles those constraints. TS does not establish Bend release semantics; disposal above is a proposed ownership-visible decision.

[#50](https://github.com/dearlordylord/bendvy/issues/50) requires: “Obtain approval for any new ownership-visible decision before implementation.” This draft is the concrete approval subject, separate from the already approved Local behavior.

After approval, implement the generic reusable runner and actual two-Array consumers, preserving closed-template callers. Verify repeated runs, failure, skip, refusal/retry, sequential two-World sharing, independent packs and one-time release in two nominal schemas on JS/Native. Include undeclared access, cross-schema, writes-through-read and owner-duplication negatives, a reached compiling lost-capture defect and a double-release refusal; complete equivalent feature performance and unchanged production regression remain required. New proofs require their own specific law approval.
