# Generic affine query handoff controls

**Bounded pass on final v7 only.** Source 29 closure:
`a9a2fa20913658b9561056e660803e3afd74870f321ff3a30c839e62fa44a56b`.
Source modules remain unchanged. Task-local mutant copies alter only reached
`query.bend` functions. No source/kernel/reference, dependency, law or proof edit.

The trusted fixtures use both nominal Motion/Health schemas with Main directly
`Array<U32>` and independently defined affine `Owned{raw:Array<U32>,cache,marker}`.
Raw/cache values deliberately differ. Aux and Ledger also own arrays. These are
synthetic generic query inputs, not factory/foreign-world command controls or a
production component restriction.

For each schema/payload, depths 0–4 cover physical lengths 1/2/4/8/16 and every
raw cell. Ten states cover mixed/all/missing/dead Main, zero/partial high-water,
high-water above capacity, reduced/zero capacity, and LedgerNone. All physical
arrays use supported balanced constructors; declared capacity stays <= physical
size. Each state runs Required/Present/Absent/Optional.

Actual route:
`Q.prototype_cursor_ids → Q.prototype_handoff_each → Q.prototype_handoff_recover`.
Every row compares independent literal Python oracles with original cursor IDs,
ascending handed payloads, every raw/cached field, temporary Main holes,
ascending recovered IDs and the complete restored world: Main/Aux/metadata
columns, namespace/next/capacity/depth/high/mode, complete pending commands and
owned Ledger. A fresh identical fixture provides the full input-world snapshot;
actual handed Data snapshots remain held across recovery and appear unchanged
in the final output. **1,600 complete records over eight schema/payload/backend
roles** pass on JS and O3 Native.

Two intended type negatives reject duplication of the affine Batch and passing
Motion rows to Health recovery. They check their actual consumed-binder and
nominal expected/observed type diagnostics. They are not public authority tests.
Three actual compiling source mutations—lost recovered owner, reversed recovery
IDs and inverted handoff selection—are detected against the same unchanged
fixture/oracle hashes in **all 24 roles**. Failed compiler runs are not mutants.

## Explicit scope

`PrototypeHandoffBatch` and helpers remain exported. Destructuring the Batch and
observing its hole-world while detached owners remain held is **expected accepted
behavior**, including direct LedgerNone calls. This is not a sealed production
API or an authority refusal. These controls cover generic Q ownership/content
and selection; they do not admit the new HA packed consumer, Tx/rollback,
abstract query confinement, universal runtime refinement or performance gates.

Unsupported foreign/malformed Arrays are not admitted. History retains initial
fixture syntax/affine-literal preparation failures, provisional v2 records,
v5 open-Array emission failure, and v6 unsupported ragged-constructor fail-stop.
None transfers a gate to v7. Final v7 removed the manual shape-inspection helpers;
its minimum-size HA guard and consumer fallback are owned by separate controls.
Production confinement and broader proofs remain follow-ups under the approved
specification workflow.

## Evidence

[summary.json](summary.json) and [evidence/manifest.json](evidence/manifest.json)
pin exact source, normal/mutant receipts, fixtures, independent oracles and all
stdout/failure history. Every 495 archive member was decoded and SHA256 checked.
Generated JS/C/native artifact hashes are retained; binaries are reproducible
from source and recorded build commands. [fixtures.py](fixtures.py) is the
literal input/oracle recipe; [run.py](run.py) and [mutants.py](mutants.py) record
actual commands and unchanged deadlines: CPU 6, executable checker 15s,
default proof 5s, emission 30s, private Clang 19/O3 build 120s, runtime 5s; Native
uses one thread and GPU off. No clocks, timing cohorts or cap resets are claimed.

```sh
python3 run.py --source /tmp/bendvy-slot-host-handoff-v7 --output <fresh-baseline>
python3 mutants.py --baseline <fresh-baseline> --output <fresh-mutants>
```
