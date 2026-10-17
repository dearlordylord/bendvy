# Canonical Readers consumer

`motion-main.bend` accepts entity count and iteration count. It uses ordinary
registered Local systems and composite query/event readers, including deferred
spawn/disposal barriers, separate reader cursors and complete owner observations.
The selected runs use 64 iterations with 64, 256 or 1024 initial entities.

The [selected packet](runtime-v1/indexed-optional-selected/actual-attempt01/RETENTION.json)
retains six full oracle matches: Motion64, Motion256 and the affine returned-owner
control, each on JS and Native. Both Motion1024 runs hit the existing five-second
limit; their correct prefixes are incomplete results. The packet also preserves
two failed control preparations. Run its `verify.py` to check retained evidence.

Indexed observation applies to canonically balanced arrays; size checks alone do
not establish shape. Arbitrary affine `Type` payloads are projected once and the
returned owners are restored before advancing. Raw columns retain structural
observation. The separate control mutates an affine owner and re-observes it
through the structural path.

This is a bounded correctness checkpoint, not a speedup or full #21 acceptance.
The 1024 gates and equivalent-work TS/JS/Native timing qualification remain open.
