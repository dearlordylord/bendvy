# Connected cache/held gates — preparation, not passing evidence

Target: the actual persistent 64-tick dispatcher/Host integration, both nominal
schemas, Type Main/Aux/Ledger and both original capture styles. Existing held
prototype results cannot satisfy these gates. Numerical targets and timing belong
to the root contract; this package runs semantic/capability checks only.

## Required actual boundaries

- Original generic transaction staging (`transaction.tx_stage_command`) retains
  receiver commands/undo/pings/marks exactly. A raw Main owner cannot inhabit a
  cached Main command; reject this undeclared conversion at the checker. A trusted
  factory must wrap the complete raw owner through `cached_new` before stage.
  Do not reject legitimate removal/Flag commands or change deferred publication.
- Foreign namespace/same logical ID returns MissingEntity before any write/stage;
  a failed attempt leaves the receiving queue, full payloads and inverse journal
  unchanged. Check lookup, mutation and entity-handle command ingress separately.
- Absent Main does not fabricate a cache/owner. Absent Ledger after a valid Main
  write preserves the original write, inverse and mark until original failure
  unwinds them. Earlier committed work survives failure; failed publications vanish.
- Complete raw payload and cached view agree after each actual factory, scalar
  setter, undo restoration, InsertMain/Spawn command barrier and reconstruction.
  Preserve all four fields and schema-specific frame/reserve/class/epoch metadata.
  Reads through query, payload, transaction, readers/snapshot and held callbacks
  must observe the same owner. No checksum-only substitute.
- Structural query membership must change after Spawn/Despawn, RemoveMain /
  InsertMain, Flag add/remove, holes and capacity growth. Logical ascending order,
  abstract Aux callback execution and metadata/ticks survive each boundary.

## Mutations required on the delivered source

Each exact anchor must be in the invoked integration path, match exactly once or
an explicitly counted symmetric schema pair, compile on Native and JS, then fail
an actual full-field/effect checkpoint: stale scalar cache; wrong preserved tail
field; restoration cache not refreshed; factory skips refresh; foreign namespace
bypass; wrong selected slot; dropped immediate mark; inverse reorder; stale
membership after remove/insert; query-order reversal. A checker/build failure is
not a detected runtime mutant. Unsupported mutations remain BLOCKED, not PASS.

## Evidence and limits

The eventual runner must bind actual integrated source hashes and original oracle /
TS closure provenance, retain full raw outputs, and label every required gate as
PASS/FAIL/BLOCKED. Checker/runtime 5s, codegen30s, clang120s. No new law/proof,
unsafe function, dependency, protected-source edit or benchmark loop. Universal
cache coherence and generic raw transformations are not proved by finite controls.

## Delivered finite actual controls

`staging-evidence.json` binds the first actual persistent cached Host overlay.
Both cached Main positives compile through original generic X.tx_stage_command;
raw Main negatives report the exact expected Cache<Raw,View>/observed Raw type
mismatch. Source/import closure is confined and unchanged.

`construction-evidence.json` records one actual original64tick Dense64 connected
Host construction, both schemas NativeO3/JS against fresh pinned TS with original
full-field validator. It predates held integration and cannot accept the later
combined source. Six original callback definitions are byte-pinned.

`tx-controls.bend` exercises the actual later cached/held source: original point
providers versus actual HA.row(~original callback). Nine scenarios ×two schemas
×success/failure yield144 pre/post records/backend. Cached observation getters and
raw-owner observation getters are built independently, must agree in all fields,
and pass independent exact inverse/mark/command/ping/tick/scalar assertions. This
is actual Tx/cache rollback evidence, not arbitrary callback/cache authority.
The forward-definition development failure and initial noncompiling tail mutant
are retained, neither counts as a runtime kill. The revised tail-field corruption
compiled Native/JS and the raw/cache full-field discrepancy was detected.

```sh
python3 experiments/s-prep/fivehour-connected-gates/staging-controls.py --overlay /tmp/actual-overlay --output /tmp/staging-gates --cpu 9
python3 experiments/s-prep/fivehour-connected-gates/construction-run.py --overlay /tmp/actual-overlay --build-dir /tmp/construction-gates --cpu 9
python3 experiments/s-prep/fivehour-connected-gates/tx-controls-run.py --overlay /tmp/actual-held-overlay --output /tmp/tx-gates --cpu 9
python3 experiments/s-prep/fivehour-connected-gates/tx-controls-run.py --overlay /tmp/actual-held-overlay --output /tmp/tail-mutant --mutation torn-tail --cpu 9
```

Required factory/raw rejected-owner preservation, membership/Flag/hole/growth,
actual Host capture path mutations and whole performance matrix remain pending.
No passing cache audit boundary set has been produced by observe-cache.py yet.
