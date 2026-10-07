# Constant-None captured seek equivalence matrix (#30)

Run `python3 experiments/public-optimized-compose/capture-matrix/verify.py
--output <fresh-directory>`. Output directories must be fresh; omitted output
creates a unique `.artifacts` directory. Checker5, emission30, approved private
Clang19 build120 and runtime5 are enforced. No timing is collected.

The oracle is actual original Col.seek with incoming None, not a reconstruction
from capture_seek. Old and new calls each construct fresh actual Type payloads
owning two-cell Arrays. New capture's affine restore closure is exercised with
Slot(None, dirty=False), matching original replacement None.

A six-pair nonempty zero-fuel smoke must pass before widening to the complete
2,430-pair product: target0–5 × fuel0–8 × Inspect/four Choice boolean combinations
× three remaining shapes × three history shapes. Remaining is empty, one owner,
or two owners. History is empty or owner/hole entries in both orders. The raw
physical array also contains three unrelated actual owners and holes. Every case
checks outcome, target, returned owner's complete payload and captured stamp;
accepted/rejected current id/owner, capacity, complete remaining/history entries;
and all eight recovered physical cells plus the complete lifecycle stamp list.

Both JS and Native execute every actual old/new pair and their full transcripts
must also match each other. Empty remaining at zero fuel must accept because Nil
precedence comes before fuel rejection. Inconsistent supplied Choice booleans and
raw prepared-state shapes deliberately test the helper's actual defined behavior;
this is finite specialization equivalence, not production-state validity or an
approved universal runtime refinement theorem. Incoming Some, dirty restoration,
other capacities and longer lists are outside this matrix.

The additive indexed Column variants require explicit exhaustive matcher cases.
This legacy corpus still constructs only legacy states; an indexed result is
reported as `UNEXPECTED_INDEXED_REPRESENTATION` and rejected by the verifier,
even if both compared paths return it. Authored inputs and legacy observations
remain unchanged. Indexed state comparisons use the separate
`../indexed-capture-matrix` corpus rather than weakening this legacy gate.

The runner freezes and hashes only recursively reachable imported project sources,
its verifier and fixture entry points; final closure/inventory drift is rejected.
No unrelated owned-family source changes can invalidate these checker/backend
receipts. Complete outputs, commands, tool versions and exact source hashes are
retained in evidence/receipt.json. No core changes, laws, proofs or dependencies.
