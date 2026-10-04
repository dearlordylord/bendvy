# Actual payload slice

`python3 experiments/s-integrate/payload-run.py` passes six complete Native/JS
rows and four compiling wrong-slot mutants. Position/Vitals and both Ledgers
retain genuine Type arrays through two scalar writes and inverse swaps. Every
array element and metadata field is compared; Velocity/Armor returned owners
are read again. Actual `Array.swap` returns the old scalar; observations never
replace payload owners. [Evidence](payload-evidence.json) pins source/compiler/Base.

Each mutant changes slot0 to slot1 in exactly one actual swap helper. It checks,
builds and runs on both backends, differing in exactly its expected full-field row.
This is payload-operation evidence, not integrated transaction rollback,
callback confinement, TS trace parity, universal proof or performance acceptance.

Checker/runtime limits remain five seconds, code generation30 and clang120.
The initial ordinary interpreter invocation timed out (exit137); it did not pass.
Explicit checker and separately built Native/JS executions pass. No law, dependency,
compiler install or production policy was newly approved.
