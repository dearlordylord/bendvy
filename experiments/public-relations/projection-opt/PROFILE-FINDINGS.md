# Full-cell projection diagnostic

Both admitted baseline/candidate profiler executions terminated successfully. Each JS/TS CPU and heap run validated all600 original complete application records (20fresh lifecycles); exact stage/source/tool/environment/output guards stayed active. CPU8 is released. These are sampled collected-inclusive heap quantities and instrumented CPU profiles including output flushing and20ms drain, not physical allocations or operation-region timing.

| Sampled quantity | Baseline | Candidate |
|---|---:|---:|
| JS total heap self |450,927,480B|382,343,896B|
| JS project_cells family heap self |90,502,168B|6,998,528B|
| Anonymous closures enclosed by project_cells |85,097,160B|0B|
| TS total heap self (control) |133,934,064B|132,867,368B|
| JS CPU-profile duration |448.866ms|440.897ms|
| JS GC CPU self samples |54.860ms|40.045ms|

Generated candidate code contains a direct while/tail loop and no per-cell continuation in this family. All required cells, owner restoration, tags and original callbacks remain. Sampled family allocation reduction supports the targeted observer-continuation mechanism; other allocations and sampling variation mean family savings do not equal total savings. These exploratory single-run diagnostics establish no speed target, native improvement, production adoption or ECS-only performance gain.

`profile-analysis.json` binds both receipts and profiles and preserves each family bucket. `analyze-profiles.py` sums each heap node selfSize once and attributes anonymous generated functions to their enclosing top-level declaration using zero-based profiler line coordinates. Raw profiles/wrappers/outputs remain in `profile-results/`.
