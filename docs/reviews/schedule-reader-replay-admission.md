# #35 replay orchestration admission

Independent read-only source review admits bounded replay wrapper
`experiments/public-schedule-readers/replay.py`, SHA256 `2dd148d1457f271b1550e6d3bbf37b5726c97a9d7aa18d849228de23f124aae9`.
Original runner SHA256 `b2201487dee41e703582e9d450fc158763604c2e490f0a57e59b6f3098975920` remains untouched.
The AST transformation removes only its run function and OUT assignment, then
adds the pinned reference HEAD guard. Original assertions and mutations remain.

Per-command execution uses the existing reviewed owned-descendant supervisor,
restores the original working directory, and calls the original stage guard
before and after each child. Live source/reference/tool pins, prospective output
absence and immutable complete stdout/stderr/generated hashes are retained.
Checker/runtime5, emit30 and Clang120 limits and Native1/GPUoff are unchanged.
No backend execution or source-current #35 acceptance follows from this admission.

The previous 40-source correctness receipt is historical: World, reader domains
and event runtime changed. Execute the admitted wrapper after the next core
batch, then reconcile the complete semantic gates, current unchanged #28 receipt
and equivalent feature measurements before delivery. Recorded heavy-reader JS
and Native deficits remain full-product performance obligations in #21/#23/#24;
no comparison threshold or law approval is changed here.
