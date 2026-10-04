# Actual large query and owner-return read gate

`python3 experiments/s-integrate/query-bulk-run.py` checks both nominal schemas
at runtime counts 1, 17 and 65,537. Actual factory/reserve/deferred application
creates width-four Type Main/Aux arrays. A rank-2 query returns complete declared
observations and actual owners; a subsequent full world read checks those owners
again, allocator, queue, Ledger, mode and persistent marks. Every observation's
handle/order and every payload cell/metadata is checked before the compact Bool
result is emitted. This is not an expected-state substitute or a full E11 run.

The original large Native runs passed; both JS runs failed with a machine-stack
memory fault. [Baseline](query-bulk-baseline.json) preserves the failure and
compiled artifact hashes. The small rank-2 instantiation also found a checker
gap in `O.client_main`: opaque runtime owner binders had been passed as templates.
That helper now accepts erased runtime binders; the public callback stays abstract.

Query enumeration and complete row observation now accumulate reversed actual
owners and Data views tail-recursively, then restore both orders once. Public
interfaces and selection semantics are unchanged. All six large/small cases and
three compiling order mutants pass/differ as intended on Native and JS under
five seconds. Existing full storage stage, its seven access rejection pairs and
five semantic mutants also pass against the changed query traversal.

Lookup traversal is a separate repair. Actual schedule/retention integration,
general root confinement and production performance acceptance remain open.
The [draft obligations](QUERY-BULK-LAWS-DRAFT.md) are executable intent, not
approval or evidence of a universal proof.
