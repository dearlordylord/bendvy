# Source flat transport observations

These receipts are bounded diagnostic observations, not canonical packets, qualified speed improvements, adoption or acceptance of a production API. The source candidate is the actual flat Held v5 overlay; no emitted-JS rewrite implements it. Exact source and generated artifacts are pinned in each receipt.

Two full65 comparisons pass every field for both schemas against fresh pinned bevy-ts. Raw Motion milliseconds: TS223.577, baseline Native254/candidate342, baseline JS523/candidate365. Health: TS870.581, Native440/458, JS573/686. Owned compilation ran concurrently; clocks vary and adverse results are retained. No parity or Native gain is concluded.

An existing V8 diagnostic runs eight timed Motion worlds plus warmup and checks nine complete fields against fresh TS. Its phase CPU samples put struct_cols_live at13.2%, garbage collection at10.0%, motion_body_read at8.4%, flat setledger at7.3% and flat set at6.3% self time. Allocation intervals around GC can cross phase boundaries, so the reported354,974,336bytes are neither exact phase allocation nor physical memory. Profiling perturbs execution and eight worlds differ from the full benchmark population.

Reproduction commands use existing scripts with unchanged runtime5 limit:

```sh
python3 experiments/s-prep/js-profile/run.py --generated-js /tmp/bendvy-held-flat-both-motion-build-v5/batch.js --output NEW_DIRECTORY --cpu 7
python3 experiments/s-prep/js-profile/summarize.py NEW_DIRECTORY
```

Full65 commands and artifact/source pins are retained verbatim in the comparison receipts. Each gzip archive contains exact original data; archive.json pins uncompressed hashes. Native source construction attribution independently finds zero delta for both flat Held and flat query candidates, despite the finite JS constructor reduction. Full core/refinement/performance gates remain open.
