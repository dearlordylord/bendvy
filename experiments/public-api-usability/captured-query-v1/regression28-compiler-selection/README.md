# Compiler-selection boundary control

The existing regression runner now defaults to the pinned Bend 2.0.35 executable, resolves its path, records its hash and checks the version before workload preparation. All four compiler calls use that executable. Statistics, fixture, ordering and execution limits remain unchanged.

Independent launch review: `enum_mode_launch_review`, GO, 2026-10-18. A focused real-compiler control passes `--bend /home/node/.bend/bin/bend` (2.0.37). It exits1 with receipt `ERROR` after exactly three version commands; no checker, emission, build, timing, baseline or candidate stage is reached. The receipt and raw refusal log are retained here.

This prevents repetition of the actual attempt01 PATH-selection error. It does not invalidate either historical result or resolve pinned attempt02's confirmed JS regression. The positive default is exercised by the next required combined gate after the verified source fix.
