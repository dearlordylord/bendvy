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

Current final JS E11 evidence (`final-js-e11-evidence.json`) retains all ten fresh TypeScript lanes, twenty actual backend lanes, and ten compiling semantic mutants. Each mutation is compiled using a control-only reachable slice of its original Motion/designated-lane input; runtime modules remain whole. The first 30-second codegen block and first repair-path negative remain in the evidence history. This is finite capability evidence, not a proof or performance acceptance.

The proposed exact-source reuse interface accepts `--reuse-receipt` plus an externally reviewed `--reuse-receipt-sha256`. It requires a complete fresh two-role receipt, byte-identical runtime modules, freshly derived complete control source maps, unchanged gate/protected fixture/tool/reference dependencies, and unchanged child receipts. Whole overlay metadata is retained as provenance. A reused receipt explicitly reports `EXACT_UNCHANGED_TWO_ROLE_GATES_REUSED`; changed sources require the full gate set. Four synthetic negative receipt controls pass; no complete two-role receipt has been frozen or reused yet.

Both observation harnesses now use `original-raw-observer.bend`: unwrap the Cache owner, call the protected original raw payload getter, and rewrap the unchanged cached view. This avoids validating an optimized native getter against itself. Actual callback/provider bodies are untouched. Final Native gates remain pending.

The JS observer retains its original `CP.*_uncached` calls after verifying the raw module is byte-identical to the protected original payload module. A fresh deterministic materialization matches all 430 previously executed JS control source hashes (`js-observer-source-equality.json`). Native uses the separate original-owner observer. This equality check is not a new runtime execution. The exact-source gate set includes cached-head corruption explicitly, alongside tail corruption, missing marks and inverse order.

The checks supervisor copies the reviewed owned-subprocess cleanup functions, pins their local helper source, preserves pre-existing children, and bounds final pipe draining. Orphaned sessions and fork races are rejected by controls. Reuse preparation honors the remaining global deadline, expected gate IDs and statuses are exact, installed Bend kernel/effect files are pinned, and dependency drift is checked after execution/reuse. Native cheap controls run by the integrator on CPU 6 are finite evidence; CPU 9 remains the proposed serial check orchestration setting.

The complete initial evidence (`complete-evidence.json`) assembles recorded commands from this task: both source roles passed all eleven required gates, including original Host 12 mutations, nine access controls, original E11 twenty candidate cases and ten semantic mutants, generic affine storage controls, staging boundaries and five full144-record Tx/cache cases. It explicitly reports `freshCheckSetExecution:false`; the status is a protocol name, not a claim of a new invocation. Native E11 reuses ten observed TypeScript outputs from this task while executing every candidate subject/mutant. Historical environment was not recorded; current relevant environment and exact adapter, Node and all33 reference source bytes are guarded. Earlier02:56 task source/tool pins provide complementary provenance without changing old receipts. This reuse is finite correctness evidence and needs explicit inclusion in any accepted future check protocol.

Native E11 original subjects are split by schema and lane; Tx fixture subjects may split by schema and rejoin Motion8+Health8 per scenario to the unchanged144-record order. All cases, callbacks, full fields, journal order and actual runtime source remain present. Five-second checker/runtime,30-second codegen and120-second clang limits remain unchanged. First Node/codegen/clang blocks are retained. The authoritative checkout must rebind final dependency hashes after merging these artifacts; doing so is source bookkeeping, not a new passing check execution.
