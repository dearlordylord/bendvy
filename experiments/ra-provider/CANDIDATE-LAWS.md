# Candidate statements — unapproved, no proofs

Recorded during the experiment before any proof work. These are candidate obligations for a future concrete design, not approved ECS laws or universal results.

1. **Authority confinement:** a checked callback quantified over arbitrary affine P/V, supplied only declared operations, cannot replace the provider-owned P with a fabricated concrete cell or apply a concrete setter to P. This matters because exported cell constructors remain public. Falsification: direct setter, constructor reconstruction after a read, concrete setter-on-new-cell and nested provider return all reject for abstract/concrete type mismatches. This is finite adversarial evidence, not a parametricity theorem.
2. **Schema separation:** the supplied Position operations accept MotionToken, never OtherToken. Falsification: OtherPosition rejects; Position checks. The second schema is token-only, no second world.
3. **Update agreement:** for the closed move callback and U32 inputs without overflow, each step preserves Velocity and returns Position plus Velocity. Observed input (0,2), three steps: 2,4,6. Planted no-update callback checks and executes but produces 0,0,0; runner distinguishes it from the expected trace. No general arithmetic or preservation proof.
4. **Ownership return:** the provider recovers both affine cells from the callback result for reuse. Successful compiled three-step execution is the positive evidence. Affine-payload rollback and dropped/failing callbacks remain outside this probe.

No LAWS.bend or PROOF.bend, model proofs, executable-function proofs, kernel verdict claim, or universal runtime refinement. Specific laws require separate human approval before proofs; the experiment approval does not supply it.
