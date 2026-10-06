# Route-aware Host12: bounded feasibility result

Exact cursor source bdf6b2, unchanged29 bound in `interface-evidence.json`. The original Host12 fixture cannot be connected to this persistent private Slot route by replacing constructors/types alone. A fresh executable checker call on CPU9 under15s observed the concrete mismatch: `H.motion_dispatch` expects `D.Runtime<H.MotionHost(),...>` with `Cache<Position,PositionView>`, while `H.prototype_packed_MotionHost()` carries `PrototypeMotionMainSlot`. Full diagnostic and exact fixture are retained. No Host runtime, independent TS comparison or Host12 pass was executed. First receipt-wrapper assertion inspected stdout only although diagnostics were emitted on the combined stream; the original combined output was independently validated without repeating the check.

## Missing interface, beyond a bounded fixture adapter

Current private `host.bend` helpers provide only Host alias, snapshot/read/foreign, presence, mode and transition methods. There are **no private Slot `invoke`, `tick`, `dispatch`, reserve, service/transaction or barrier counterparts**. Original public dispatch (`host.bend:504`) calls original Cache-typed tick (`:412`); its transaction branch (`:299`) calls `IA.motion_a/b`, structural branch calls `SI.motion_cleanup`, and reserve observes complete nominal bundles before staging. These concrete audited/structural invokers likewise have no packed/cursor family. The unchanged original Host fixture uses those dispatchers in both returned-owner and regenerated-closure styles, plus preflight Host exchange/retention.

Replacing only `H.MotionHost()` by the private alias fails at the dispatch boundary. Keeping original dispatch would run generic Cache storage. Converting the complete Slot world back to Cache at every dispatch would cease exercising persistent private storage and relocate allocations; it is not an acceptable passing adapter. Replacing authored Host A/B systems with measured `SC.motion_body/health_body` or wrapping every schedule call in the benchmark cursor fold would change original algorithms/work and is also not acceptable. The private benchmark cursor registration currently belongs to `measurement-bend.bend`, not to these original Host system bodies.

## Concrete next design and return conditions

1. Add a separately reviewed private Slot Host service family that retains every original Host definition/header, copies only the necessary concrete type/provider transport and preserves authored `U`/audited/structural client bodies. Retain complete raw/cache values, reservations, pending FIFO, failed publications, clock/log/Audit effects and all captured owners across frames. This requires actual implementations rather than a recognizer change.
2. Implement Slot-aware audited and structural ingress/barrier providers with nominal views and complete returned-world transport. Add corresponding private preflight Host exchange wrappers. The existing generic scheduler/reader logic can remain unchanged where its Type parameters are genuinely generic; preserve both capture styles.
3. Connect the original fixture to those persistent private providers. Explicitly distinguish original public/query clients from the private identity collector. The original Host query-order mutant must target its reached query, while the benchmark cursor route needs its own selection/order control; neither can substitute for the other.
4. First check/emit/run cached Motion original Host fixture against the unchanged independent TS oracle, then both schemas/capture styles and all twelve reached compiling Host mutations under15/30/120/5 bounds. Verify live callee/source pins, complete channels and no fallback whole-world Cache conversion before claiming a private-route pass.

No source candidate, shared recognizer, compiler, reference, dependency or proof was changed. This task stops at the concrete interface rejection and design boundary rather than broadening into a new Host implementation. Full22, Host12, performance and adoption remain open.

Reproduce the bounded negative:

```sh
python3 experiments/s-prep/source-private-id-query-host-gates/replay.py --output /tmp/bendvy-cursor-host-interface-replay
```
