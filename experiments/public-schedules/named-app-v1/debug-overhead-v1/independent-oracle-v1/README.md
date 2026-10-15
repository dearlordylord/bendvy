# Named-plan per-mode independent oracle v1

This source-only oracle follows the frozen `debug-overhead-v1` entrypoint,
freeze `bb025b2d3a965cecb574d84185a161f7f7c4d89d71f2774e10421d1504337d50`,
and its 65-file Bend closure plus 34-file TypeScript closure.  It derives the
complete logical output for both fixed modes: `enabled` and `disabled`.

Each mode creates fresh Workshop and Garden scenes in that order and executes
all 26 actions in each scene.  The outputs therefore contain 52, 104, or 208
records at scales 1, 2, and 4.  Mode selection happens before scene creation;
no completed lifecycle is filtered.  Enabled snapshots carry the ordinary
schedule descriptions and grouped Counter access index.  Disabled snapshots
carry `null` views.

`model.py.source` is a finite source-derived interpreter.  It never invokes a
backend and never reads runtime output.  The six `expected-{enabled,disabled}-scale-{1,2,4}.stdout`
files are compact UTF-8 JSON returned by `run_mode(N, debug)` followed by the
single terminal LF added by the pinned `IO.print` effect.  Deterministic gzip
companions are provided.  Bend affine-owner state and TypeScript captured
Runtime state remain separate physical boundaries.
