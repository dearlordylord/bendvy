# Private flat point-owner experiment

Bounded S-PERF-NEXT #21 source variant; no production adoption or performance acceptance.

```sh
python3 experiments/s-prep/js-flat-point-owner/materialize.py \
  --input /tmp/bendvy-profile-combined-js \
  --output /tmp/bendvy-flat-point-owner-corrected
```

The fail-closed recipe requires fresh absent output, exactly 29 modules, exact
held-adapter revision, matching source pins and matching embedded/standalone
cache-specialization receipts. It changes only held-adapter.bend, preserves all
original type/definition headers and writes coherent complete closure pins.
Original actual generic callbacks and all other source modules remain unchanged.
Only motion_fields_checked and health_fields_checked successful namespace + ledger
branches select new private helpers. Bounds/liveness checks remain in S.take_rows.
Original public get/set/invoke/return/taken helpers and fallback paths remain.

PrototypeFlatHeld is affine and generic over World/Main/Ledger/Command Type and
cached-view/Handle Data. Separate raw Main, Main view, raw Ledger and Ledger view
fields replace two CC.Cache wrappers inside the owner. Trusted private schema
helpers read copied Data views, use the same raw swap functions and view patches,
and carry complete World, handle, undo, commands, pings and marks. Original Cache
constructors rebuild only at final row and ledger restoration. Every raw payload
stays affine; this introduces no Data-only payload assumption or altered callback.

Source prediction: each held Main get, Main set, Ledger read and Ledger set removes
one intermediate Cache construction. Final restoration adds two Cache constructions.
The actual motion_body/health_body successful path executes all four operations,
so predicted net reduction is two Cache objects per callback; Held becomes FlatHeld
with the same number of owner constructions and two extra fields. No generated
object count or speed improvement is yet observed. More fields may affect runtime
cost; source simplification alone is not a performance gate.

Initial diagnostic checker on CPU11 under 15 seconds rejected +value parameter
binders on private setters: callback expected an affine U32 arrow but observed
@+value:U32. The corrected source retains affine parameter binders and introduces
local '+value = value', exactly as the original setter does. Attempted CPU12 check
could not start because available affinity is 0-11 (taskset Invalid argument).
No codegen, runtime, profiler or timing was executed by this worker.

Old setter mutation anchors are no longer authoritative on the selected private
held path. Retarget live owner-suppression controls to prototype_flat_motion_set_done
and prototype_flat_health_set_done, which construct MainInverse and handle<>marks;
Ledger controls target prototype_flat_motion_setledger_done and
prototype_flat_health_setledger_done, which construct LedgerInverse. Remove both
inverse and mark effects for a Main owner-suppression mutant, retain raw/cache writes,
and require the actual-live witness to distinguish it. Do not count a mutation of
unused original setters as this variant's passing acceptance.

Return conditions: execute connected finite traces and cache-after-write/full-field
checks; foreign/invalid/dead/missing-ledger fallbacks; declared-access and affine
ownership controls; retargeted compiling inverse/marks/queue mutations. Then inspect
emitted JS/C construction counts before profiling. Canonical failed-cap evidence
remains; authorized diagnostics are checker15s, runtime5/codegen30, with no cap reset.
No new laws/proofs/dependencies/compiler changes. Finite traces cannot establish
universal refinement. Bend version 2.0.35 and guide were run before source work;
AGENTS/checkpoint, #21/SPEC and Bend LDD instructions remain governing.

Corrected standalone diagnostic: taskset -c 10 timeout 15s bend
/tmp/bendvy-flat-point-owner-corrected/experiments/s-integrate/held-adapter.bend
--check-only exited 0 with ALL PROOFS CHECK. This is executable module checking,
not a new proof or replacement for connected gates. Output adapter SHA256:
aef254216044bc6ea813a1320d7d7925b501ec423237bd37624086289afc7fd1.
