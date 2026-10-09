# Duplicate entries within one bundle: pending #41 contract

The concrete trigger is one authored bundle containing Stock and Queue.front entries targeting the same component family. The retained experiment processes both entries sequentially, so the later payload replaces the first and the authored inverse preserves recovery. This is distinct from inserting one component to replace a component already present in the World.

No explicit selection of this within-bundle behavior was found in SPEC, the owning bundles acceptance document, or the inspected #41 issue comments. Those materials require duplicate coverage; they do not approve sequential overwrite. Historical surface-RESULT.md and COVERAGE.md report an experimental TS divergence, not a governing approval. Existing outputs, oracles and timing receipts remain unchanged and retain that scope.

Pinned Rust Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60 rejects repeated explicit component IDs in BundleInfo::new (crates/bevy_ecs/src/bundle/info.rs:99–118). The pinned TS3040a3b2 surface trace demonstrates sequential writes. SPEC reference priority is Rust Bevy, then Bend ownership/runtime constraints, then TS inspiration; a TS trace cannot select this contract.

Two observable choices remain for the existing #41 owner:

- Reject repeated family entries within one bundle. A Bend adaptation must specify the admission/refusal boundary and preserve all incoming affine owners, queues and reservation state; copying Rust panic behavior is not automatically an owned refusal contract. Core duplicate detection should use existing nominal family declarations, without a second registry.
- Explicitly approve sequential repeated writes as a divergence from Rust Bevy. Current experiments provide finite order, replacement, inverse and recovery observations, but do not themselves supply that approval.

This packet selects neither choice, error shape nor activation policy. Root remains the shared-core integrator. Replacement of an existing World component must retain its separate coverage under either choice. Full #41 acceptance remains pending this decision alongside its existing delivery/performance gates; descriptive measurements remain evidence for the experimental candidate only.

Source basis: [SPEC implementation decisions](../../../docs/SPEC.md), [owning #41 acceptance](../../../docs/parity/bundles.md), pinned local Rust source above, and retained surface-reference / surface-RESULT observations. The relative document links are navigation aids; exact reference revisions above govern the source claims.
