# Current-source scheduled Bundle consumer

This retained slice runs the current-source Bundle consumer on JavaScript and Native. Both complete outputs match the independently derived historical 21,569-byte oracle (`39fa741680b22d0f0448f9a8f6c3fbc5a3b874608e4608d3f923deedb349a1a6`). The archive includes the exact plans, receipts, commands, full stdout/stderr streams, guards, generated JS/C and Native executable, 34-source literal closure, compiler/runtime/tool pins, and historical oracle/model inputs.

The current-source check record and import-join record are retained with both checker attempts and raw logs. The root adoption report binds all 34 current source bodies to their repository paths; the root entry check is retained separately. An independent source-only review confirmed that the old pure model derives the complete output and that the newly exhaustive `Initial` cases are unreachable through this fixture's `H.prepare` path. The runtime output was not used to create or revise the oracle.

This is a bounded two-backend qualification, not full issue #48 acceptance. It makes no timing or performance claim.

Run `python3 verify.py` or `python3 verify.py --selftest` in this directory to verify exact source paths, plan/receipt/tool joins, complete output bytes, and path-preserving archive relocation.
