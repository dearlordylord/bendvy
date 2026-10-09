# Coordinator review of the independent reader countermodel

Scoped PASS for model `3f15bf71`, source `118923c8`, before runtime execution.
All source and consuming-closure pins in SOURCE-BASIS.json match current bytes.

Reviewed the changed `inspect_read` route: it retains the World returned by
`C.get`, substitutes only detached Access, and leaves membership, lifecycle and
Check routes unchanged. Query projection reaches this route; lookup errors and
cardinality depend on unchanged validity and row membership.

Independently reconstructed the complete output using the five source formatter
branches: required fields become `UNEXPECTED_ABSENT_REQUIRED`, optional fields
become `{present:false}`. All146 query records remain;36 change. Every other line
stays exact. Recomputed5,072,061 bytes/SHA
`3bd051674ecd00b642317c34e1620186d505915e5f6340d76ee1e49c2b0abb87`
match the frozen countermodel. Focused model controls pass.

This admits the expected data, not a backend launch or public delivery. Normal
execution must first match the unchanged5,077,477-byte oracle; mutant execution
must match this entire countermodel and reject that entire normal oracle.
