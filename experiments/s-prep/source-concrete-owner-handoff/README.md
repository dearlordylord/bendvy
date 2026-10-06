# Concrete nominal owner transport — layout probe

Frozen source: `/tmp/bendvy-slot-host-concrete-owner-v3`, closure
`a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
The approved design is docs/design/native1024-owner-transport.md.

Q appends two concrete producer/state/batch/recovery families. Only Schema/Main
are fixed; Aux remains Type, Flag Data, Ledger Type and Mode Data. Nominal nodes
retain the exact Motion/Health MainSlot field. The complete v8 Q source remains
an exact prefix after removing one new CP header import. The generic arbitrary-M
route remains unchanged. HA switches only its concrete handoff rows, batch,
producer/recovery selections. Original callback family, namespace/id construction,
minimum-size guard and original fallback bodies remain unchanged.

All three executable module checks passed (CPU6, 15 seconds). Actual original
Dense1024 Motion/Health batch and measurement inputs were adapted only by source
path and emitted to C (30 seconds). Successful take now allocates a 9-word Motion
or 11-word Health node, containing an Array plus the distinct raw/cached scalars.
The owner has no opaque MainSlot seal or new separate constructor box at this
edge. Tail sealing remains. Both nodes round to 16 words. This is a positive
layout mechanism only; allocation and speed improvement are unmeasured.

Native compilation, runtime correctness, fresh semantic controls, allocation
attribution and timing await root's next decision. No acceptance transfers from
v8. The original exposed Batch confinement limit remains.

Failure history: v1 attempted an appended import rejected by the parser; v2
missed changing the ready Batch constructor, rejected by the checker. Both failed
source directories and outputs are retained. v3 corrects those two preparation
errors. No failed check counts as admission.

Source/cache maps and exact producer SHA are in source-recipe.json. The complete
29-file source archive decodes to the recorded hashes. Emission inputs, complete
C files and receipts are archived separately. No compiler/kernel/dependency,
law/proof, reference or external repository change was made.
