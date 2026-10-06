# Exact generated-JS raw observations

Incomplete performance acceptance under #21/#24. These are descriptive full65
Dense256 ×64tick ×64fresh-world observations on CPU11, Node24.20.0, five-second
runtime limits and the pinned actual bevy-ts execution. Every compared final
field is validated. No canonical attempt allowance, noise qualification,
production adoption, compiler change or complete workload matrix is implied.

| Exact source and candidate | Schema | Fresh TS ms | Candidate JS ms |
| --- | --- | ---: | ---: |
| Query-v3 scalar Tuple clone | Motion | 196.207 | 216 |
| Query-v3 scalar Tuple clone | Health | 191.110 | 218 |
| Packed+paired scalar Tuple, serial | Motion | 192.996 | 187 |
| Packed+paired scalar Tuple, serial | Health | 180.592 | 222 |
| Typed cursor row/token/Tuple/nested | Motion | 182.114 | 189 |
| Typed cursor row/token/Tuple/nested | Health | 182.156 | 213 |

Each candidate has its own source29 and actual producer/catalog/recipe hashes.
The typed cursor closure is bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94;
its current generated probe changes JS only. Native observations of that source
are separately recorded in source-identity-query-observations. Different source
rows must not be joined into a success claim. Construction-expression reductions
are not measurements of materialized heap allocations or elapsed improvement.

The Motion packed observation ending `-r2` overlaps the root Native Health driver
on CPU11. Their elapsed comparisons are invalid, even though full fields pass;
original receipts and explicit measurement-limit annotations are retained. Serial
reruns above replace those comparisons, without deleting the failed protocol.

`observe-query-v1.py` and `observe-firststage-v1.py` retain exact prior recipes.
Current `observe.py` also admits exact nested-recipe receipts, validating the
parent analysis and all actual provenance pins before timing. Three roles run
sequentially in rotated order: actual TS, exact input-stage JS and candidate JS.
`summary.json` contains raw values, input-stage clocks and all failures.
`archive.py` verifies every decoded member against SHA256; the archive retains
receipts, outputs, reference adapters, candidates, source modules and producer
pins. No timeout or rejected receipt counts as a passing comparison.
