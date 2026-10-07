# Hierarchy reference observations (#44)

`python3 experiments/public-hierarchy/run-reference.py` observes the pinned public
bevy-ts runtime for two nominal schemas. It retains complete component payloads,
all entity parent/children/ancestor/root/depth/breadth results, child/descendant
query matches, relation failures and component-removal/despawn records.

The 23 checkpoints per schema cover queued/applied reorder, reparenting, self and
cycle refusals, missing/duplicate/unrelated children and child-set mismatch,
linked subtree/root deletion and repeated deletion. Every refusal preserves all
captured payloads and traversal results. An ordinary relation from a surviving
entity is detached when its hierarchy target is deleted. Literal order and
survivor controls are checked by the actual public application. Raw stdout/stderr,
reference heads, source membership/hashes and the shared runner hash are retained.

The pinned descriptor factory fixes hierarchy `linkedDespawn=true` and ordinary
relations `linkedDespawn=false`; it offers no public configurable despawn option.
Rust Bevy `ChildOf` protects the derived `Children` collection and uses linked
spawn cleanup. These are source references, not approval to add Rust-only APIs.

This is TS reference evidence for the pending #44 contract. It does not complete
#44 or its #42 prerequisite, implement the Bend traversal API, establish affine
payload disposal, pass negative/mutation/backend gates, prove refinement or qualify
performance. Those obligations remain on #44 and its governing specification #37.
