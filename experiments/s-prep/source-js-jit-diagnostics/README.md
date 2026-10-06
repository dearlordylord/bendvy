# Joined Health V8 JIT diagnostic

The exact retained eight-world Health profile driver is restored by decoded hash
from `source-fold-noaux-join/profile/index.json`; no generated computation or
source definition changes. Node24.20.0 uses trace-opt/trace-deopt, CPU11,
runtime5. Both actual pinned TS and JS complete all nine full-world comparisons.
This is a diagnostic during parallel source work, not an elapsed cohort or keep.

The JS trace contains one bailout: prepare-for-OSR in the indexed noAux query
loop. It contains no other bailout or aborted/disabled optimization in this
finite execution. This does not establish JIT stability for all workloads, nor
attribute elapsed costs. TS also emits deoptimizations, including validation
outside the measured phase; counts must not be interpreted as relative speed.

Next source investigation remains actual owner/ledger reconstruction and query
state transport, rather than an assumed recurring V8 wrong-map/call-target issue.
All complete raw trace/observation output and execution receipts have decoded and
archive pins in `evidence/index.json`. Drivers are unchanged retained artifacts;
reproducer `run.py` restores them by pin before running. Compiler/kernel/source,
shared controls and public API remain unchanged. No performance acceptance,
new law/proof, dependency or canonical attempt allowance is implied.
