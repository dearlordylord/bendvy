# Current compile-time identity and owner controls

These examples use the current Workshop/Garden schemas, full index+generation
entity keys, central allocator World type, and a payload containing both an
Array<U32> and an Array<Array<U32>>. No old constructor arity failure counts.
The positive example checks valid full-key construction, affine owner threading,
Read use and Write use through the current public functions.

Seven intended refusals are retained with their complete checked source and raw
compiler streams: undeclared World enumeration through abstract H, cross-schema
entity handle, cross-schema Column, Read passed to Write, duplicate Column owner,
duplicate complete World owner, and recovery of a concrete World from abstract H.

The existing scripts/scenario_controls.py TypeMismatch helper qualifies the
three distinct-outer-type cases: undeclared World access, Read→Write and abstract
owner recovery. It intentionally does not accept same-outer schema mismatches or
affine quantity errors. Those four cases match predeclared exact expected/observed
fields, declaration location and checked source span. Their full documented
compiler messages are preserved in EXPECTED-DIAGNOSTICS.json and checks/*.stderr.
RESULTS.json binds each result and raw stream to its checked source hash;
SOURCE-PINS.json binds the complete current import closure and checker/helper.

All checks used the current absolute wrapper, CPU6 and its unchanged five-second
budget. One positive example passed; all seven negatives terminated with the
intended compiler refusal and empty stdout. No validation code, library contract,
tool or runner was changed. These checks establish these type/capability/affine
rejections, not language-wide secrecy of raw constructors or runtime authority.

The source-current runtime and integration gates remain separate. REFERENCE-JOIN
records retained source/behavior applicability and differences without inventing
new reference runs or treating TS inventory as the generational semantic contract.
