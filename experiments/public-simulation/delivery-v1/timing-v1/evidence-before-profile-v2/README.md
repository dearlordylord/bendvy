# Original before profiles

Two actual unchanged full-simulation Node commands exited zero with empty stderr. All full stdout, nine guards, 48 ordinary probes, generated CPU/heap artifacts and executed small sources are losslessly retained; tool binaries remain SHA-bound rather than duplicated. `python3 verify.py` performs no children.

The original receipt inherits `REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT`. Preserve that label; command scope and actual profile artifacts establish profiling, not additional sequencing controls or a performance verdict.

CPU capture spans the whole process (41.689 ms), including loader, JIT and printing outside the application timer. Forty samples are sparse. Weighted self observations include component.tx_get specialization 1262 (1.660 ms), geometry.projected_second (1.195 ms), and all show_val frames (4.133 ms). Recursive inclusive sums must not be added across repeated nodes. This cannot explain the measured 3.371× JS/TS ratio by itself.

The heap capture has only three samples. One estimated 524,304-byte sample is attributed to event-runtime.run_reading; the others are loader and process exit. It is not a literal allocation size, total allocation measurement, RSS, or leak finding.

Source mapping: component.bend:221 tx_get calls get then tx_get_join:217. get preserves column ownership through projection, World reconstruction, returned Tuple, then Tx reconstruction. compose.bend:106 family_match reaches the same get and subsequently retains only its selected access result. geometry.bend:project reads both payload/sentinel Array cells and packages a Cell/Tuple. Generated corresponding continuations appear at simulation.js:8245, 8666, and 8057. event-runtime.bend:206 run_reading builds Input then invokes actual registered System.run, preserving reader and runtime fields (generated line2380).

A possible small shared-core candidate is reducing intermediate transaction/read packaging while preserving the exact number/order of projections, foreign-handle checks and all affine owners. The profile does not establish its payoff. Existence-query shortcuts would change observable generic project calls and must not be inferred safe. Finer CPU/allocation sampling is prepared separately to choose a consequential candidate; original evidence stays unchanged.
