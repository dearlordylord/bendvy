# Blind ECS consumer audit — #25

**Audit delivered; full application blocked on missing interfaces.** Read the
[coordinator outcome](../../docs/reports/blind-ecs-api-audit.md) for the corrected
verdict. The [original blind report](blind-evidence/report.md) is a frozen raw
artifact: its claim that useful query getters are blocked is **incorrect**.
The [assisted correction](assisted-evidence/after-assistance.md) and independent
replay distinguish this client mistake from real interface limitations.

A fresh agent (`fork_turns=none`) received only exact29 source modules, installed
guide/Base, local pinned Bevy/bevy-ts/Bend primary sources and neutral consumer
requirements. No optimization history, timings, task reports or prior agents
were supplied. Source snapshot had no Git history. Filesystem access was shared;
blindness is a documented read protocol, not an enforced security sandbox.
First impressions and initial verdict were frozen before language assistance.
The original44 artifact bytes remained unchanged. Source archive and manifest
preserve exact input; original-blind-evidence.tar.xz also preserves all44 original
artifacts with decoded hashes verified; provenance records lineage separately for the coordinator.

## Reproduce

```sh
python3 experiments/api-blind-audit/replay.py --output /tmp/bendvy-api-audit-FRESH
```

Use a nonexistent output directory. Runner verifies archive, all29 decoded source
hashes, installed Bend/Node/Base and all three reference commits. It extracts
read-only library files, copies consumer files to a fresh workspace and preserves
per-command receipts. Checker5s, emit30s, runtime5s; timeout kills only its own
process group and never counts as rejection. Root replay passed26 commands.

- `blind-consumer/`: independent structural example, initial callback mistakes,
  four paired negatives and registrar counterexample; original scripts retain
  their original absolute workspace path as historical inputs.
- `assisted-consumer/`: corrected closed-template queries, actual owned Array
  payload and actual public-setter positive/negative pair.
- `blind-evidence/` and `assisted-evidence/`: original immutable observations and
  explicitly separated post-assistance observations, including preservation hash
  checks. Relative links in raw reports refer to their original workspace; use
  the extracted library/consumer in fresh replay to inspect source.
- `coordinator/`: independently corrected client, raw command error retained
  (`bend check` is invalid CLI syntax), verified replay receipts and summary.
  That command error is not an API or access-safety failure.

Commands pass deferred spawn/remove/insert/despawn and compiledJS observation.
Query templates read payload3; the corrected owned-array query also reads3.
A concrete setter changes the payload, while the same public setter rejects an
abstract read owner for the intended reason. Earlier getter arity/token negatives
are language-shape evidence only. Foreign runtime handles, constructor escape,
full rollback/reader coverage, Native execution, full22 and performance are not
passed by this package. No ECS laws/proofs, new dependency, compiler/library or
reference edits occurred.

Real missing seams are caller-authored system registration and independent
component-family declarations/access. [Follow-up #26](../../docs/tickets/24-user-system-api.md)
requires reviewed API design and fresh application/negative/integration evidence.
The full-core scope and mandatory performance requirements remain unchanged.
