# Ordinary App Motion larger consumers

Four consumer-only plans reuse the exact generated JS and Native artifacts from qualified ordinary Motion64 actual02. Source is integrated on master `88611af9e`; no emission, Native build, observer optimization or source change occurs here.

| Runtime size | JS | Native | Complete stdout bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| 256 | PASS | PASS | 118614122 | `41a054579aa0e8d224d9d9a99ebbe01cd624b8290651c9d4b95df5b2c0bcf433` |
| 1024 | PASS | PASS | 444624902 | `b46c21923f303fc17c04c31b6af7fef16b45223883356d81c3e94a9c469ed0de` |

Each actual stdout equals its complete independent preserved oracle; all four stderr streams are empty. Consumer cap is 30 seconds. Execution is serialized, with the unchanged development-v2 collector and immutable producer/source/foreign/tool bindings. `RETENTION.json` stores source, plans, receipts, guards, artifacts and complete streams; `verify.py` validates objects and compares every actual byte against its oracle without the original /tmp paths.

This establishes ordinary FailedTxn Motion correctness at 64/256/1024, together with the existing64 packet. It is not a comparative timing result or complete #21 acceptance. Health and other workload ordinary routes, the accepted full workload matrix and final product performance criteria remain separate gates. Combined #28 and focused core authority controls are recorded by their existing owners.
