# Primitive columns in the actual candidate

Direct implementation under #21/#23/#24. This is an experimental candidate, not an accepted keep or production layout. The previous measured allowance remains exhausted; no timing packet is launched here.

Both JS/Native storage use affine MetadataColumns<F> with aligned Bool, Maybe<F>, U32 added and U32 changed arrays. Main/Aux remain arbitrary Type owners. Empty/grow, placement/rejection, extraction/restoration, removal, Main take/put/fused point access and replacement preserve owner transport and original guards. Mark changes only the changed column. Indexed query observes only live/flag and returns all metadata owners unchanged; callback bodies and rank-2 authority are unchanged.

Run `python3 experiments/s-prep/primitive-columns-candidate/materialize.py --role JS --output /tmp/new-js-overlay` (Native similarly). The recipe validates all29 runtime members, actual static callback algorithms and exact source hashes. It produces correctness-only overlay manifests; it grants no measurement contract or reuse of old gates. Current lifecycle evidence is in [primitive-storage-integration](../primitive-storage-integration/README.md).

Original Tx fixtures construct two metadata trees directly. The narrow provider-controls adapter translates exactly these expressions into four trees while retaining every original live/flag/tick/scenario value. Missing/ambiguous anchors or remaining Metadata constructors fail closed. Original fixtures and literal field/effect oracle remain unchanged; generic older-layout fixtures remain supported.

Required follow-ups: finish all22 exact-source connected gates, including flag command paths and actual provider/rollback/cursor/membership observations, then qualify equivalent-work comparisons under a renewed explicit measured allowance. Public detached constructors can misalign column depths; normal lifecycle preserves alignment, but arbitrary malformed-shape validation or a stronger production boundary is still required. No model/function proof, universal refinement or speedup is claimed.
