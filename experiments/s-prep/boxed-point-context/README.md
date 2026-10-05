# Boxed cached Held context hypothesis

Bounded S-PERF-NEXT #21 source hypothesis from Native profile observations; no
adoption, speed or ABI improvement is established. Only held-adapter.bend changes.
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
mutants remain required. No codegen/runtime/profiler/timing ran in this worker.
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
