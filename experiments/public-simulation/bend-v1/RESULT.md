# Full fixed-step simulation development result

The actual registered ECS consumer executes fourteen checkpoints for each of
Workshop and Garden: independent readers, deferred spawn, explicit activation,
three movement/damage steps, hit/death publication, deferred cleanup, reader B
failure and retry, final empty reads. Every checkpoint retains all physical
component slots and affine array cells, resource cells, liveness, pending command counts,
component clock, event batches/positions/retention metadata and reader journals.

- Installed Bend JS emission and Node execution exited zero. Complete pure
  Data stdout: 48,608 bytes; parsing/rendering roundtrips the entire report.
- The independent complete structural oracle was authored without inspecting
  candidate output. SHA256: `f821c68264eb25c33a674841d0f2abcf466a9d6372e888cfc40b7ae691ae071a`.
  All fields match after 32 explicit source-backed constructor path joins.
- All 28 checkpoints match the executed pinned TS reference for shared live
  component values, Step, pending command count, per-phase success and full
  independent hit/death journals. TS world tick, Bend component clock and ER
  event tick remain distinct observations; no clock equality is claimed.
- Installed Bend C emission, the approved private Clang 19 build and Native
  execution exited zero. Native stdout equals JS stdout byte for byte. Native
  uses one thread, GPU off. Source pins remained unchanged across both runs.

These are development observations, not full #63 delivery qualification.
Frozen complete source/tool/environment evidence, independently reviewed
negative diagnostics and reached semantic mutation results, unchanged #28
regression gate and scoped equal-work timing remain delivery requirements.
No performance ratio, universal proof or full parity claim is established.
Runtime/generated files remain local development artifacts; original attempts
and raw command results are retained, and no historical receipt is rebound.

The current candidate removes one trailing EOF LF from geometry.bend.
The exact executed source remains archived; candidate-source-correction.json
and source_evidence.py validate this byte delta without rebinding receipts.
The corrected full entry passes its default five-second source check.
