# Combined #28 — wrong-compiler attempt01

Integrated source: `b72b0a0f7`. The launcher selected Bend **2.0.37** from PATH,
whereas acceptance pins **2.0.35**. This attempt is retained as a 2.0.37 result,
not the required pinned-toolchain gate. A successor selects the existing 2.0.35
executable explicitly; neither ECS source nor the statistical contract changes.

Existing `benchmarks/run.py`, unchanged contract,
CPU11, 20 adjacent randomized pairs per backend. All complete observations pass.
Command: `python3 benchmarks/run.py --output .artifacts/regression73-20261018-integrated01 --cpu 11`.

| Backend | Slower pairs | Median paired current/baseline | Exact one-sided p | Result |
| --- | ---: | ---: | ---: | --- |
| JS | 18/20 | 1.0380334065 | 0.0002012253 | Confirmed regression |
| Native | 9/20 | 0.9782217776 | 0.7482776642 | No confirmed regression |

The result is **REGRESSION** under the unchanged zero-allowance Holm/sign-test
gate for 2.0.37. Preserve this attempt; it does not close #73.

All 356 previously monitored source hashes match the earlier protected receipt;
the only additional monitored file is `ordinary-app-capture-query.bend`.
The receipt records the compiler-version difference. Separate comparison found
byte-identical generated application regions on each side of the old/new runs,
with compiler-runtime and IO-lowering differences outside those regions; see
`generated-comparison.json`. This does not establish the cause of the timing
difference or justify an ECS source fix.

The receipt retains every pair, tool and input hash and actual command result.
`EVIDENCE.zip` retains every run file; `MANIFEST.json` binds all member bytes
and the archive hash. Lossless archival was independently read back and checked. Host load was about 6 on 12 allowed CPUs before the run; external
contention remains possible. The randomized paired decision is not a qualified
five-family comparative result or a causal attribution to the new helper.
