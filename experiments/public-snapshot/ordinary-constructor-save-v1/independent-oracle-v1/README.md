# #58 independent ordinary constructor/save oracle

This directory is a source-derived expected-output packet for the frozen
`ordinary-constructor-save-v1` fixture. The model follows the current
`consumer-io.bend` entrypoint, `Driver`/`Setup`/`Consumer` state flow, the
explicit `Format` renderer, and the `Supplement` inventory/admission path.
It does not read candidate output and does not run a backend.

`expected.stdout` is the compact JSON emitted by `IO.print`, including its
single trailing LF. `expected.stdout.gz` is deterministic gzip transport and
`expected.json` is the same parsed value in review-friendly form.
`SOURCE-BASIS.json` records the 47 frozen source hashes (16 fixture-owned)
and the import closure. `verify.py` only checks source hashes, regeneration,
JSON/gzip round trips, and the exact expected digest.

The current `Game.ordinary` reaches four bare schema entries in this order:
`Payload`, `Scratch`, `Settings`, `ScratchSettings`. The renderer includes a
branch for `Fragment.Classified`, but no classified value is constructed by
this fixture. The accepted supplement admission uses literal values `[7,9]`;
the subsequent `[11,13]` request is rejected at `$[0]` and retains the
incoming owner while leaving the accepted column unchanged.

The Workshop/Garden state model agrees with the retained qualified model's
semantic report (raw SHA `c381bdeab1e75d6ecbe893baabc2e901ee162499c2e59d838f7cdaa0a9a201dc`).
That historical model is a cross-check only; no historical or candidate
runtime bytes are used as input.
