# Node call-stack and allocation profiles

Use the built-in inspector on frozen generated JS; no new packages are required.
CPU and memory runs are separate. Each run executes twenty fresh program scopes
and verifies every complete application against the supplied normative output.
Five-second process limits and source/output hashes are retained.

```
python3 experiments/public-optimized-compose/node-profiles/run.py \
  --generated <frozen-workshop.js> --expected <full-output.stdout.gz> \
  --output <fresh-directory> --cpu 0
python3 experiments/public-optimized-compose/node-profiles/summarize.py <directory>
node --expose-gc experiments/public-optimized-compose/node-profiles/verify-memory-sampling.cjs
```

The allocation profiler explicitly includes objects collected by minor and major
GC. Ordinary sampling defaults to live objects, which can hide transient owner
transport. The infrastructure canary forces collection and compares retained-only
against collected-object attribution. A small retained function-metadata residue
is permitted; the canary requires a broad separation, not exact allocation totals.
See the [official protocol](https://github.com/ChromeDevTools/devtools-protocol/blob/master/json/js_protocol.json)
and [Node inspector API](https://nodejs.org/api/inspector.html).

Profiles include serialization, runtime and instrumentation. A twenty-millisecond
post-work delay drains asynchronous GC observations; it is outside the recorded
iteration durations but inside the profile. Inclusive stack summaries overlap.
Sampling attribution is not an exact physical allocation total or a retained-heap
snapshot. Compare equal-work before/after artifacts with the same runner settings;
neither profile replaces the unchanged paired regression gate.
