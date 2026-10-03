# Candidate statements, not approved laws

Recorded before implementation/proof work. No ECS proof is authorized or written.

1. Ordered required traversal returns each matching live entity exactly once in setup order; presence/absence partition those rows and optional selection preserves required membership. Finite falsification inputs: Motion a=0+Tag{}, b=10; Health a=20,Damage=3,Armor=1, b=30,Damage=2 without Armor.
2. A declared update followed by a writable-cell read returns the new value; the later reader in the same sequence observes it without a structural barrier. Repeat the same Step three times. Motion adds 1; Health subtracts Damage. Armor remains unchanged.
3. Lookup of live b with presence selection returns typed QueryMismatch, while optional lookup returns a match with explicit absence.
4. Arbitrary abstract affine handles cannot be replaced by detached concrete cells/rows/worlds or used with undeclared concrete operations. Paired type fixtures attempt these paths; finite controls are not parametricity or universal authority proofs.

Planted falsification: compiling Step mutant writes the old Motion value rather than adding 1. The required first writable-read checkpoint must differ from the reference. Results are recorded in README after execution. Universal statements remain candidates pending human approval and broader falsification; finite comparison does not prove them.
