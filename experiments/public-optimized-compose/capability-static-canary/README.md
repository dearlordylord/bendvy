# Capability callback application canary

Finite comparison against actual `Cap.read/get/set` on an affine Array payload.
Repeated reads mutate and reinstall the actual returned owner; replacement then
read observes the actual replacement. JS and Native return exactly:
`[[3,7,4,7,5,7],[3,7,4,7,5,7],[41,43,42,43],[41,43,42,43]]`.

`rejected-template-match.bend` retains the unsuccessful direct match on `~cap`.
The unchanged checker refuses it with `an annotated term (cannot infer)`;
pinned Bend `tests/page/comp_param_match.bend` documents this restriction and
`bend2/safe.ts:1208` explains opaque template constants. No compiler workaround.

The checked alternative (`static_*` wrappers in `main.bend`) passes the closed
capability as a runtime argument to a helper that matches it and immediately
applies the selected callback to the actual affine row/replacement. This removes
one field-return helper call in emitted JS. It **does not** remove capability
record construction, callback closures, indirect `run_tail`, or setter currying.
The Native emitter already specializes these small helpers; selected static and
original callback groups have equal closure-group sizes in this finite fixture.
No allocation-byte, universal refinement or performance improvement claim.

Reproduce with `python3 experiments/public-optimized-compose/capability-static-canary/run.py --output /tmp/capability-canary-new`.
Five-second checker/runtime caps, separate JS/Native observations and rejected
source are retained in `evidence/`. Existing core capabilities are unchanged.
