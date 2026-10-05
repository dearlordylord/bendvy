# Current primitive-column speed diagnostic

Incomplete. User explicitly authorized a 15-second executable checker limit on 2026-10-05. This one-shot diagnostic does not renew the exhausted canonical optimization loop or authorize a keep. Full22 checks remain incomplete.

One fully validated Motion JS sample: 1966 ms versus pinned bevy-ts 902.517064 ms, elapsed ratio 2.178352 (JS slower). All 65 worlds (warmup plus 64 fresh worlds ×64 ticks ×256 entities) match every normalized final field. This single observation is not a qualified cohort or product acceptance. The next sample exceeded the unchanged five-second runtime limit. No Native or Health ratio exists.

Full Host Motion checker passed at 15 seconds; its C codegen exceeded 30 seconds. The Motion JS batch driver checked and generated successfully; Native batch checker passed but C codegen exceeded 30 seconds. Clang/runtime/codegen limits remain120/5/30 seconds. Native policy is O3, one worker, GPU off; CPU11 affinity, shared machine.

Reproduce using freshly materialized actual candidates from ../primitive-columns-candidate/materialize.py:

```sh
BENDVY_CHECKER_SECONDS=15 python3 ../fivehour-connected-gates/checks.py --js-overlay /path/JS --native-overlay /path/Native --cpu 11 --output /fresh/full
python3 run.py --js /path/JS --native /path/Native --output /fresh/speed
# If Motion JS was built before a Native build failure:
python3 motion-js.py --output /fresh/speed
```

[evidence-index.json](evidence-index.json) archives source-pinned positive/negative receipts and both successful raw outputs. run.py uses the existing unchanged recipe/validator; motion-js.py extracts the JS-only diagnostic without rebuilding or rerunning failed Native compilation. Timing excludes setup/final output. No source optimization occurred in this diagnostic. New checker-limit plumbing changes protected runner bytes; canonical guard pins/contracts must be reconciled before any later canonical run. Targets remain JS/TS<=1 and Native/TS<=0.5. Next blockers are C codegen30s and full-process runtime5s; they were not silently enlarged.
