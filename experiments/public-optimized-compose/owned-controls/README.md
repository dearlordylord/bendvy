# Owned-plan capability confinement controls (#30)

Run `python3 experiments/public-optimized-compose/owned-controls/verify.py
--output <fresh-directory>`. The runner snapshots the exact current imported
source closure, invokes checker-only commands under five seconds, retains complete
diagnostics/source hashes and rejects final source drift. No code generation,
backend execution, timing, dependencies, laws or proofs are added.

Every callback fixture has an actual closed `O.each` instantiation using the new
owned Plan executor and existing Cap operations. The positive control checks the
same plan/callback setup and concrete provisioning reads. Five negatives require
both the exact intended expected/observed types and source location:

- Duplicating universally quantified H rejects repeated affine consumption.
- Calling the concrete public Row getter with abstract H rejects specialization.
- Reading the undeclared Other payload through its public concrete projection
  rejects treating abstract H as that separately owned family.
- Passing the declared Read capability to Cap.set rejects Read versus Write.
- Applying the closed schema-P plan selection to a schema-Other world rejects
  mismatched typed query Frames at the actual owned Plan instantiation.

Parse errors, setup failures, timeouts and generic runtime-template mistakes are
not counted as intended rejection. The concrete adapter supplied by the imported
owned-seam fixture is its documented finite prototype, not the forthcoming general
owned-store implementation. These tests establish its bounded callback-confinement
seam and must be replayed against the final module closure; they do not establish
runtime recovery, read purity, arbitrary-world refinement or performance acceptance.
