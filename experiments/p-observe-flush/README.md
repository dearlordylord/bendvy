# P-OBS stage 3 — exact independent flush proof

[GitHub #18](https://github.com/dearlordylord/bendvy/issues/18),
[approved task](../../docs/tickets/17-approved-observation-proofs.md).
**The general `explicit_flush_independent` endpoint is proved**, with ordinary
checker, BendTT kernel and compiling own-endpoint mutation gates. Its original
statement/domain/model/independent spec are unchanged at approved law SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
This is the bounded Nat flush observation theorem, not production runtime or
owned-payload refinement, arbitrary scheduler/reader correctness or performance.

## Exact subject and proof composition

[PLAN.md](PLAN.md) persisted contextual inventories before the corresponding
checks; [subjects.json](subjects.json) froze the original law/core hashes.
[verify.py](verify.py) checks the sole selected [LAWS.bend](LAWS.bend) block
against that exact source. [PROOF.bend](PROOF.bend) fills it without weakening
the independent admissibility premise or assuming any unapproved catalogue law.

| Checked link | Subject and argument |
|---|---|
| `toolkit.application_prefix`, `replay_prefix` | Separate actual whole-list / independent per-slot left-to-right prefix composition. Both quantify arbitrary commands/rows/current observations. |
| `coherence.command_slot` | Each actual command agrees with independent slot semantics at any observed slot. Nat equality reflection/no-confusion proves cross-target preservation; duplicate or malformed rows are included. |
| `coherence.mixed_fifo_slot` | Arbitrary mixed Spawn/Target FIFO induction generalizes intermediate raw rows, using the complete single-command link. |
| `prefix.modify_rows_valid` | Actual Insert/Remove/Despawn preserves independently counted row validity; present rows remain bounded and unique. |
| `prefix.pending_modify`, `pending_after_spawn` | Future reservation zero-count freshness is preserved; a fresh bounded unique Spawn moves from pending to actual live rows while preserving the remaining spawn guards. |
| `prefix.apply_all_rows_valid` | Recursive FIFO execution passes actual intermediate row validity and remaining-command freshness at every consumed prefix; final actual rows satisfy independent counted validity. This is contextual command execution, not the unapproved blanket step-preservation law. |
| `materialization.materialize_enumeration` | For every interval/raw input, independent per-slot materialization equals enumeration of actual whole-list command output. No validity premise needed for this pointwise link. |
| `PROOF.flush_rows` | Combine counted actual-output validity, committed query `rows_complete`, materialization correspondence and committed `enumeration_stable`. Remove the oracle's second enumeration and preserve complete ascending public rows. |
| `PROOF.guarded`, filled endpoint | Original computed independent guard: false gives Unit; true extracts actual invariant evidence. Observation constructors preserve namespace/next metadata and cleared pending queue. The endpoint links the actual `M.flush` caller. |

Other narrowly contextual helpers expose comparison decisions, count/freshness
transport and conjunction evidence. Existing lookup comparison symmetry and
committed query sorting/count/enumeration helpers are imported read-only and
hashed. No allocator/exhaustion policy, new dependency, raw physical-list order,
root authority or one of the 24 unapproved catalogue statements is adopted.
Only Base definitions, ordinary equality transport and safe structural recursion
are used. No unsafe/foreign proof dependency.

The earlier residual `command_slot` and `mixed_fifo_slot` are now general typed
proof definitions. The final endpoint-local `RESIDUAL.flush_rows_observation`
is also filled in PROOF.bend at its original conditional domain. Standalone
LAWS/RESIDUAL files each report one TODO until their paired proof module is
imported; the complete PROOF module has **no TODOs** and passes the kernel.

## Executed verification and mutation gates

```sh
BENDVY_PROOF_CPU=8 python3 experiments/p-observe-flush/verify.py
```

[evidence.json](evidence.json) records terminal **exit0 PASS**, commands, outputs,
canonical and proof/helper/Base/runner hashes. Bend 2.0.34 version/guide ran before
both initial and resumed proof work. Every checker/kernel invocation uses
`experiments/t01/bend-check` with five-second kill limit. The six-second process
watchdog detects wrapper failure; it does not extend that limit.

- Complete proof and each contextual module pass ordinary checker and `--verdict` kernel. Forced `/usr/bin/false` kernel control fails as expected.
- Eight fresh concrete controls ground spawn at own/other slot, duplicate despawn, untouched survivor, noncommuting Insert→Remove, missing target, full unsorted world with Spawn/unknown target/Despawn, and the full world's true independent premise. They are separate from the universal proof.
- Wrong Spawn tag rejects unchanged `spawn_slot` after the mutant implementation checks.
- Reverse whole-list FIFO rejects unchanged `target_fifo`; a focused copy excludes the earlier independent prefix theorem to expose this particular contextual result. The identical copied positive passes the kernel first.
- Target application no-op rejects unchanged universal `command_slot`, with the older same-slot theorem excluded only for focus; copied positive and safe mutant checks pass.
- **Actual `M.flush` caller no-op** leaves contextual application algorithms and independent oracle unchanged. Its implementation checks, but the **unchanged complete proof fails at `Location: Laws.explicit_flush_independent`**, rather than a shared helper. A fresh complete-world observation true on the original also fails on this mutant. The copied unmutated full proof passes the kernel from the same location.

These are new actual gates; isolated earlier probe results are not substituted.
The runner verifies the expected standalone open-claim diagnostics separately
from the filled proof. Code emission/runtime timings are outside this pure proof
acceptance; no backend or performance conclusion follows.

## Development history and remaining scope

Initial delivery contained checked same-slot/prefix links and three exact
residuals; it did not complete the endpoint. The resumed tranche proved cross-slot
coherence and independently counted prefix invariants, then composed the endpoint
after the query lane delivered its actual checked interval stability. Early rewrite
orientation, symbolic Despawn reduction and singular TODO diagnostic errors were
corrected and are not mutation evidence. A preflight import was unavailable before
query helper integration; final checks use committed dependencies. Neither law/core
revision nor timeout increase was used to obtain a pass.

For the schedule Barrier seam, `materialize_inside` additionally proves lookup of
materialized rows equals per-slot replay at any in-interval target, while
`materialize_above` proves None at or above the interval end. Both quantify arbitrary
raw inputs and are kernel-checked; they compose existing enumeration lookup facts
with the actual mixed-FIFO theorem. No oracle-world validity is assumed.

The other approved schedule/owned-runtime endpoints retain their own gates. Global
root provenance, arbitrary Type/full-payload preservation, transactional allocation
policy, readers/retention/lifecycle logs, relations/scopes, generated backend and
host IO proofs, production layout and performance remain outside this theorem.
The original Tower Defense repository and references are untouched.
