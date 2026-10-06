# S-QUERY-COMPOSE #27 — completion evidence

**Complete for the governing query composition ticket.** General heterogeneous
component capabilities replace the main/aux restriction for new consumers.
This advances the complete [SPEC](../SPEC.md); it does not close full-core #1
or the connected implementation/performance gates in #21/#24.

## Delivered and verified

- `Compose.each` accepts arbitrary caller-defined `Ops(H)` records and a closed
  cohesive Plan; the library has no family-count-specific callback overloads.
  Schema-local wrappers and named records reuse ordinary Bend declarations.
- Read/write/optional selections and independent conjunctive with/without
  predicates retain exact schema/family types. Empty and contradictory selections,
  repeated getters and shared read/write aliases execute correctly.
- One transaction spans all selected rows in ascending ID order. Actual affine
  Array components retain complete replacement rollback; failed commands/events
  and returned observations do not publish. The same registered owner retries.
- Typed column lifecycle stamps support AND-composed added/changed predicates.
  Equal writes change stamps; reads do not. Rollback restores old stamps/owners.
  Independent reader cursors remain separate and failed readers retain theirs.
  `System.run_tracked` consumes the authoritative post-success clock, including
  the system's own writes. Structural cleanup removes payloads and stamps.
- Optional resource/event/command fields grant only their declared operations.
  Ten actual public controls pass: four positives and six intended negatives
  for read-only writes, owner duplication, undeclared access, reconstruction,
  cross-schema binding and open runtime capability templates.

The independently authored Workshop schema uses five families, three actual Type
Array payloads, repeatable registered systems and explicit deferred boundaries.
Both compiled backends match all **22 ordinary frozen TS checkpoints** and the
separately approved foreign-world result: MissingEntity, queue unchanged and
post-barrier observations unchanged. Array projection controls preserve complete
logical payloads of lengths 0, 9 and 17; no fixed-size truncation is accepted.

## Review correction

Independent Spec review found that advancing a successful reader to the pre-run
clock made its own changed-selected writes appear again. The implementation was
corrected in this ticket. Actual TS and Bend controls observe first/repeat counts
1,0; failed write/retry/repeat counts 1,1,0 with restored owned payloads. A compiling
post-clock-minus-one mutant is detected. Final independent Standards and Spec
reviews are recorded in [the review](../reviews/query-composition-final.md).

## Reproduction and exact evidence

Run from repository root with Bend 2.0.35 and existing Node v24.20.0:

```sh
timeout 5 node examples/query-composition/reference.mjs --verify
python3 experiments/query-composition/run-controls.py --output /tmp/query-controls
python3 experiments/query-composition/mechanism/run.py
python3 experiments/query-composition/lifecycle-controls/run.py
python3 experiments/query-composition/build.py --output .artifacts/query-composition --evidence /tmp/query-application
python3 experiments/query-composition/regression.py --evidence /tmp/query-regression
python3 experiments/query-composition/timing.py --output .artifacts/query-timing --evidence /tmp/query-timing --cpu 0
```

Fresh source hashes and actual outputs are retained in
[application evidence](../../experiments/query-composition/application-evidence/receipt.json),
[public controls](../../experiments/query-composition/integrated-controls/receipt.json),
[lifecycle controls and mutant](../../experiments/query-composition/lifecycle-controls/evidence/receipt.json),
and [regression](../../experiments/query-composition/regression-evidence/regression.json).
The prior suite passes 31 design/core/system/transaction controls, 12 provider
controls with three JS/Native programs, the independent Arena consumer and its
five negatives, and the prior complete simulation on both backends. Historical
receipts are preserved by replaying that suite in an isolated source copy.

Checker/runtime limits remain five seconds; emission30 and approved private
Clang19 compilation120. No dependency, compiler/kernel or canonical-defense
source changes were made. No new law or ECS proof was introduced.

## Cost and limits

The [informational cohort](../../experiments/query-composition/timing-evidence/receipt.json)
runs ten complete equivalent 22-checkpoint applications per process, five rows
per backend in interleaved order, pinned to CPU0, validating every output. Median
whole-process times: TS253.019ms, JS105.869ms, Native19.328ms; JS/TS0.418,
Native/TS0.0764. Startup, imports and output are included. This is measured
application cost, **not qualified hot-path performance or product acceptance**.

Closed schema adapters and operation-only Ops records are trusted provisioning;
the executor does not certify arbitrary malicious type constructors. Source
confinement controls are finite evidence. The unchanged kernel cannot model the
generic higherkind callback; universal proof/refinement remains unpassed.
Composition retains the compiler's existing template-depth bound. Column metadata
is list-backed and clock exhaustion rejects writes while preserving owners.
Relations/removal streams, global root authority, runtime affine captures and
qualified scaling/performance remain existing full-core gates described in the
[core map](../reference/core-map.md), not implied delivery by this ticket.
