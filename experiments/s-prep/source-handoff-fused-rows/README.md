# Fused affine handoff rows — bounded source candidate

Frozen v8: `/tmp/bendvy-slot-host-handoff-v8`, closure
`4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235`.
Baseline v7: `a9a2fa20913658b9561056e660803e3afd74870f321ff3a30c839e62fa44a56b`.

Q uses nominal `PrototypeHandoffRows<Schema,M:Type>` with `HandoffNil`
and `HandoffCon{id,owner,rest}`. This fuses the previous affine List node
and separate row wrapper. Producer traversal, selection, evacuation,
ascending recovery IDs and the single final ID reversal retain their bodies.
Both HA drains match the fused constructors. Their ledger-None branches
reconstruct the complete current node before recovery; their ledger-Some
branches retain the original callback and returned context.

Only query.bend and held-adapter.bend changed. All 27 other source files,
including the measurement body, are byte-identical to v7. The original Q
and HA prefixes are byte-identical. Overlay/cache source maps agree.
`source-v8.tar.xz` contains the complete 29-file source closure; all decoded
member hashes match `fused-rows-recipe.json`. `prepare.py` reproduces the
candidate from the exact v7 directory into a new directory.

Three executable module checks passed with a 15-second limit on CPU 6:
query, held-adapter, measurement-bend. Commands and outputs are retained.
The initial preparation accidentally changed an original query initializer;
checking rejected it. The recipe was narrowed to the handoff initializer;
initial failure logs are retained and do not count as passing evidence.

Actual emitted C/JS consumer, arbitrary affine payload controls, negative
controls, allocation counts and comparative timing require fresh independent
receipts against this v8 closure. Module checking alone supplies none of
those gates. No allocation or speed improvement is claimed here.
The exposed Batch still permits observing an evacuated World. This candidate
adds no production confinement, proof or universal runtime refinement.
