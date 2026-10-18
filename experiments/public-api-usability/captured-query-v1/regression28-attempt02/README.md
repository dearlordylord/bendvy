# Combined #28 — pinned attempt02

Integrated source: `b72b0a0f7`. The unchanged runner uses Bend 2.0.35 selected by
an isolated PATH symlink to `/home/node/.bend/bin/bend-2.0.35`; Node 24.20.0,
Clang 19.1.7, CPU11 and the original statistical contract remain unchanged.
The receipt confirms the selected compiler. Attempt01's 2.0.37 result is retained
separately; correcting that concrete provenance error justifies this successor.

Command: `PATH=/tmp/bendvy-regression73-tools:$PATH python3 benchmarks/run.py --output .artifacts/regression73-20261018-pinned02 --cpu 11`.

| Backend | Slower pairs | Median paired current/baseline | Exact one-sided p | Result |
| --- | ---: | ---: | ---: | --- |
| JS | 16/20 | 1.0432622582 | 0.0059089661 | Confirmed regression |
| Native | 10/20 | 1.0002036579 | 0.5880985260 | No confirmed regression |

All complete observations pass, but the unchanged Holm/sign-test gate returns
**REGRESSION**. #73 remains open. The baseline is the frozen Bend baseline, not
bevy-ts. These whole-process pairs do not qualify the full product matrix.

`EVIDENCE.zip` losslessly retains all 526 run files; `MANIFEST.json` binds every
member's size and SHA-256 and the archive hash. Every member was read back and
verified. Separate CPU/allocation diagnostics use these exact pinned artifacts;
no further gate run is justified without a concrete source fix or new evidence.
