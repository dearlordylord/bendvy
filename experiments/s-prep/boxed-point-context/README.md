# Boxed cached Held context hypothesis

Bounded S-PERF-NEXT #21 source hypothesis from Native profile observations; no
adoption or qualified speed improvement is established. Only held-adapter.bend changes.
Input is the complete point/metadata/query/batched-marks overlay, excluding flat-owner.

The copied private helper family retains original CC.Cache Main/Ledger and actual
generic callbacks. Only successful motion/health fields_checked branches select
private taken helpers; all originals and fallback paths remain. Namespace and
row bounds/liveness checks remain unchanged. Undo, commands, pings, marks, all
World fields and affine payload ownership are carried unchanged. Live setter
mutation anchors move to prototype_boxed_motion_set_fused_done and
prototype_boxed_health_set_fused_done (MainInverse and marks); Ledger anchors move
to prototype_boxed_motion_setledger_fused_done and
prototype_boxed_health_setledger_fused_done. Mutating unused original held setters
cannot establish this private path's owner suppression acceptance.

The fail-closed recipe requires absent output, exact adapter revision, all 29
source pins and coherent embedded/standalone cache receipts/closure digest. It
retains all public definition/type headers and all runtime modules, changes only
adapter and updates both complete closure maps. No compiler/reference/dependency,
proof/law or Data-only change. Version2.0.35 and guide ran before source work.

Initial Array<World> attempt constructed exactly one ALeaf at private held entry;
getters/setters carried the array untouched and row return matched ALeaf{World}.
Standalone checker under15s on CPU10 rejected the return as nonexhaustive:
expected cases for ANode, observed none, at prototype_boxed_motion_return.
Array's Type does not express its singleton shape. A total ANode case would own
multiple Worlds; silently discarding or inventing one would weaken the representation
contract. This attempt is not a checking candidate or passing capability gate.

A one-constructor affine custom box could encode exactly one World, but may itself
be flattened by Native lowering. No emitted ABI claim follows from its source shape.
Every tested box design adds one context constructor at held entry and destructs it
at restoration. Cache wrappers and generic callback operation counts remain intact;
no wrapper reduction is predicted. Benefits, if any, must come from actually reduced
Native argument transport, balanced against box allocation and indirection costs.

Follow-up: inspect source-generated Native helper signatures before profiling;
connected correctness/cache/full-field/access/ownership gates and retargeted live
mutants remain required. No codegen/runtime/profiler/timing ran during the source-only checkpoint;
later diagnostic executions are recorded below.
Canonical failed-cap evidence and checker limits are not reset by executable
module diagnostics (authorized15s; runtime5/codegen30). Finite traces are not
universal refinement. Parent coordinates any additional bounded attempt.

Authorized tagged alternative: PrototypeWorldBox<W:Type> has Root{world:W} and
Nested{inner:PrototypeWorldBox<W>} constructors. Every finite inhabitant owns exactly
one World, so total structurally decreasing prototype_world_unbox handles both
constructors without inventing or dropping a World. Only Root is constructed on
the reachable held path. Private getters/setters transport this context unchanged;
return unwraps it before the original restoration operation. Original Cache types
and helpers remain. Tagged source shape does not yet establish Native boxing or
reduced ABI parameter count; root must inspect emitted C.

```sh
python3 experiments/s-prep/boxed-point-context/materialize.py \
  --input /tmp/bendvy-batched-marks-reproduced \
  --output /tmp/bendvy-boxed-point-context-final
taskset -c 10 timeout 15s bend \
  /tmp/bendvy-boxed-point-context-final/experiments/s-integrate/held-adapter.bend \
  --check-only
```

The Array attempt is retained as array-attempt.patch negative evidence. Tagged
attempt initially rejected return_world's binder match order (World matched before
earlier Handle). Final source orders the two scrutinees and patterns by their
parameter order. This correction changes no callback, field or restoration behavior.

Final standalone diagnostic checker exited0, ALL PROOFS CHECK under15s CPU10.
This checks generic executable source; no proof or connected gate is inferred.
Output adapter SHA256:
ea9bce769439500a28ec9a266a23d3966e9ba5c44faeb108351d9aa2704a2c96.

## JS diagnostic execution

Fresh Motion256 batch source checked under15s and generated JS under30s on CPU10.
The existing root js-profile/run.py now exposes --cpu10; its SHA is recorded rather
than modifying the runner. Uninstrumented and counted diagnostics both validated
all nine complete worlds (warmup + eight fresh worlds,64ticks each) against freshly
executed pinned TS, with each full process under5s. GC tracing was disabled.
Counted source constructor executions:10,349,120 (78.95751953125/callback), versus
batched baseline10,218,048. Difference131,072 is exactly one extra Root construction
per callback, entirely held-adapter; all other module counts are identical.
Instrumentation counts expressions, not materialized heap allocations or bytes;
CPU profiles perturb execution and give no qualified speedup/canonical metric.

Reproduce after deriving the Motion64 JS batch:

```sh
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py \
  --cpu 10 --no-gc --generated-js /tmp/bendvy-boxed-point-js-build/batch.js \
  --output /tmp/fresh-boxed-profile
node --expose-internals experiments/s-prep/js-allocation-map/instrument.cjs \
  /tmp/bendvy-boxed-point-js-build/batch.js /tmp/fresh-boxed-count.js
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py \
  --cpu 10 --no-gc --generated-js /tmp/fresh-boxed-count.js \
  --output /tmp/fresh-boxed-counted
```

Evidence includes build, source/tool pins, validator receipts, full counted outputs,
profiles, generated JS and baseline/current count maps with deterministic gzip.
This is Motion JS diagnostic coverage, not Native/Health/full22 capability acceptance.

## Native ABI and execution diagnostic

Batched marks materialized onto the separate complete combined Native overlay, then
this tagged-box recipe materialized onto that result, retaining coherent all29 pins.
The first attempted static recipe path was unavailable in the detached checkout;
shell execution continued with an unstatic driver. That driver checked under15s but
Cemit exceeded30s. This negative preparation/deadline receipt is retained. Corrected
preparation uses root's absolute static-schema-driver recipe, selecting Motion at
main without changing callback/runtime/workload fields. Static driver checker15s,
Cemit30s and clangO3/120s all pass on CPU10. Native one worker/GPUoff and freshly
executed pinned TS each finish under5s; all65 full-world observations match.
Raw phase clocks are1012ms Native and1168.375218ms TS, diagnostic samples only;
no cohort, performance ratio qualification, canonical metric or adoption follows.

Mechanical C inspection counts spin75 parameters as63 baseline (47 values,14
location q parameters, Env/out), versus36 boxed (27 values,7 q, Env/out). The named
Motion row case statically reaches subject spin75 through spin98 -> spin85. Its
body processes an Access pair and four-cell sum, so no exact getter label is claimed.
Numeric helper identity alone cannot establish source identity. The complete sorted
helper arity distributions, headers, named caller routes and C hashes are archived.
This establishes narrower transport on a reachable Motion point helper, while exact
motion_get/ledger ABI mapping and phase-profile attribution remain open.

```sh
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/static-schema-driver/materialize.py \
  --driver /tmp/bendvy-boxed-native-build/batch.bend --schema Motion
python3 experiments/s-prep/boxed-point-context/analyze-c-abi.py \
  --subject /tmp/bendvy-boxed-native-build/batch.c \
  --baseline /tmp/bendvy-static-native-motion/batch.c \
  --output /tmp/fresh-boxed-native-abi.json
```

Native evidence archives complete generated C, derived driver/measurement, full
Native/TS output, complete source/cache book, static recipe and bounded build/run
receipts. Remaining connected access/ownership/rollback/mutation gates, Health,
full22 and qualified measurement remain root responsibilities; these diagnostics
approve no laws/proofs or universal refinement.

Root follow-up: [fresh actual Tx receipts](tx-evidence/index.json) pass original
success/failure/no-op ownership observations for both schemas, cached/raw observers
and JS/Native. Live private boxed Main setter omission and inverse-order mutants
compile and are detected; suppression records the actual private done-helper names.
The regenerated recognizer requires exact Main setter arguments and the guarded
taken/invoke chain. [Computation-only Native profile](../native-phase-profile/README.md)
excludes setup/output. [Fresh access/provider/factory controls](../profile-directed-access/README.md)
also pass for the boxed/direct Native role. Stale/torn controls, full22 and qualified
Health/product performance remain open; none of these receipts establish adoption.
