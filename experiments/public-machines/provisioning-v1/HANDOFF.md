# Pre-output handoff

No generated/runtime outputs exist. Review main.bend and main-mutant.bend (17 complete checkpoint strings per SchemaA/B); the sole mutant bypasses the explicit required missing preflight. The complete observer is observer.bend and scene/observe.bend: actual factory, owner pack, registry fields/cursors, physical world arrays/stamps, resources, machine slots, streams/readers, pending/events/clock are threaded, with opaque queued commands represented by retained queue counts as in the reused observer.

Separately review flow-only.bend (five full world/registry checkpoints per schema): registered-missing, false-gate-missing, required-flow-missing, install, flow-only-level-absent. Its last enabled call actually uses run_tracked; Level remains missing. Generic arbitrary Type initialization and nominal/affine/read-only negatives are retained.

Optional conditions follow pinned Rust absent=false semantics, including not/OR/state_exists. Main uses Decl.frame→App.named, distinct from historical App.frame's blanket preflight. Main's broad dispatcher registrations are intentionally broad, not minimal opcode requirements. No public duplicate-initial, before-frame scheduler refusal, initialization message/changeflag, capture or disposal contract is selected. Initial Occupied is private empty-slot primitive evidence only.

Independent whole normal/countermodels are required before any backend; source/type gates are not runtime or proof credit.
