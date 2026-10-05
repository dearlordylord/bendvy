# Direct raw scalar swap source probe

Bounded S-PERF-NEXT #21 diagnostic. Only uncached-payload.bend changes in a fresh
29-module point/metadata/query/batched-marks overlay. Protected payload.bend,
original callbacks, compiler, references and dependencies remain unchanged.

```sh
python3 experiments/s-prep/js-direct-raw-swap/materialize.py \
  --input /tmp/bendvy-batched-marks-reproduced \
  --output /tmp/fresh-direct-raw-swap
python3 experiments/s-prep/js-direct-raw-swap/literal-run.py \
  --overlay /tmp/fresh-direct-raw-swap --output /tmp/fresh-swap-controls --cpu 10
```

Materializer requires absent output, the exact original uncached payload revision,
all29 actual source pins, coherent embedded/standalone cache receipts and complete
closure maps/digest. It preserves every original public type/definition header and
retains old swapped helpers. Four public scalar swap bodies pass Array.get's array
and true-old result to dedicated one-match helpers, which Array.set index0 and
rebuild the complete original affine Position/Vitals/MotionLedger/HealthLedger.
All other cells and frame/reserve/class/epoch fields remain unchanged. No payload
or owner is made Data; getters still return the full affine owner. Cache patches
and callback algorithm are unchanged. Normal Base array shapes remain the domain;
no new malformed-shape guarantee is inferred.

Generated JS directly reads array[0 % length] and directly assigns that cell in
Array.set, without creating Array.swap's update closure. Successful actual Motion
callback writes Main and Ledger, predicting two fewer closures per callback.
Counted execution confirms exactly that:9,955,904 constructor expressions versus
batched baseline10,218,048, delta−262,144 across131,072 callbacks, or−2/update.
Only ArrowFunctionExpression/base-runtime counts change; every other module and
constructor-kind count is equal. This counts source expressions, not materialized
heap allocations, allocation bytes or performance improvement.

Fresh Motion256 batch checks under15s and emits JS under30s. Uninstrumented and
counted profiles each pass all nine full worlds (warmup +8 fresh worlds,64ticks)
against freshly executed pinned TS under5s perprocess, serial CPU10. No qualified
speed ratio, canonical metric, full22 acceptance or adoption is claimed.

Literal controls cover both schemas' four raw types with two sequential writes.
They check true-old before each write, all four returned cells, and every metadata
field against an explicit literal output oracle. JS and NativeO3/one worker/
GPUoff both match all four lines. Checker15s, codegen30s, clang120s and runtime5s
pass. Initial fixture generator had Python f-string brace syntax failure before
creating/checking any Bend source; that negative preparation receipt is retained.
No Bend checker/runtime failure occurred in this probe.

Public *_swap and cached raw-wrapper names stay live. True-old/wrong-cell mutation
anchors now are prototype_direct_position_swap, prototype_direct_vitals_swap,
prototype_direct_motion_ledger_swap and prototype_direct_health_ledger_swap;
mutations of unused original *_swapped helpers are not acceptance controls.
Original held owner/inverse/marks/queue helper anchors remain live because the
adapter and journal were not edited. Connected Health, authority/affinity negatives,
rollback/journal/full22 and mutation gates remain root responsibilities. Literal
and finite world comparisons establish no universal runtime refinement or proofs.

Run version2.0.35 and guide before work. Governing AGENTS/checkpoint/#21/SPEC and
Bend LDD remain applicable. No new laws/proofs, cap reset or dependency approval.
Archive evidence pins source closure, tools, generated sources, full observed
outputs, validator/count receipts, JS lowering excerpts and explicit limits.
