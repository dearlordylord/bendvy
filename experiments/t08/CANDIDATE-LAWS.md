# T08 candidate obligations — draft, not approved

No ECS proof is written against these statements. This finite executable probe
is not a universal refinement proof; T11 must supply exact generalized laws,
admissibility/projection boundaries, literal falsification and approval requests.

- Successful runs advance only their own change/lifecycle and message positions;
  failed runs advance neither. Other reader positions are unchanged.
- Skipping an existing reader advances its message position only. Changes and
  removal/despawn records remain observable by that reader.
- For each live present component, added/changed membership is exactly its own
  stamp greater than the reader's previous successful-run tick. Values observed
  are current committed values, not historical copies; absent components do not
  match. Logs expiring must not erase marks on surviving components.
- A committed write is visible without a structural marker. Failed writes
  preserve values and marks. Overwriting an existing component changes its change
  mark but preserves its addition mark; reinsertion stamps both.
- Pending commands do not affect membership/observations until explicit flush.
  Removal/despawn logs outlive entities, preserve operation order and independent
  reads, and are held by the oldest registered lifecycle cursor.
- Lifecycle capacity drops oldest individual records, including part of a group
  at the same tick. Lag means a drop after both last-run and registration tick.

Boundaries: one component/U32 projection, trusted closed operation driver,
nonwrapping clocks, unique fresh spawn IDs, ordered immutable rows inside an
owned Type World. Data snapshot restoration here does not establish inverse
restoration of arbitrary affine payloads; T06 is separate executable evidence.
Generic schema/access declarations, Type payload marks, captured systems,
reader destruction, nested schedules, indexed sparse storage and runtime-wide
refinement remain distinct gates. Buffered events retain their own batch policy.
