# Public affine per-instance Local (#36)

Run `python3 experiments/public-local-owner/verify.py --output <fresh-directory>`
for correctness. Add `--timing` for five raw equivalent-work samples per backend;
without an explicit output path the runner creates a unique `.artifacts` directory.
It refuses to overwrite existing output. Checker5, emission30, the previously
approved private Clang19 build120 and runtime5 are enforced. No dependencies are
installed. All outputs, exact diagnostics, tool/reference provenance and executable
source/oracle/verifier/expected-fixture hashes are retained with final drift guards.

Two actual public Local registrations share one closed runner but own different
four-cell affine Arrays. Complete snapshots cover initial state, repeated runs,
conditional skip, a failed run and successful retry. The registered runner uses
actual World resource transactions: failure rolls that write back while retaining
the returned Local update. Gameplay Local reads/replacements use rank-2 Ops.

A second actual factory-created World contains a real colliding registration
(id=1, name/access equal). A foreign run must refuse before invoking gameplay and
return the instance plus both original argument-array cells. That same returned
owner and arguments execute successfully in the correct World. Foreign disposal
returns the instance; successful disposal unregisters each actual id and consumes
its Local through a closed disposer that exposes the complete final payload.

The TS oracle is an explicit policy adapter around actual public bevy-ts systems
and resource rollback. No dedicated upstream Local API exists. The adapter owns
per-instance arrays, runtime-object identity and an active-registration map;
its disposal and those logical registration keys are adapter behavior, not an
observed upstream unregister API. All nineteen complete lines must match Bend.

Intended negatives reject instance duplication, writes using an undeclared
abstract owner, cross-schema instance coercion and changing a closed runner index.
A compiling namespace-identity mutant must execute the foreign callback and fail
complete observations on both JS and Native. Compilation failure is not detection.

Raw feature timing includes startup and printing. It does not establish product
JS/Native targets or the full hot-path matrix. The unchanged #28 paired gate and
independent Spec/Standards reviews are separate root delivery requirements.
Arbitrary destructive Type/IO rollback and runtime-captured callbacks remain
full-core #1 extensions; no new exact law or proof is introduced here.
