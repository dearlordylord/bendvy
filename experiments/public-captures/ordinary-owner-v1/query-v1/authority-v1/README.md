# Captured query authority controls

These fixtures reuse the resource-capture authority pattern against the frozen `a56f80401` query entry and its actual `P.Pack` containing two affine arrays. No production source is changed.

- `positive.bend`: actual `O.define` accepts the supplied Type capture, closed declaration and rank-2 callback; exit 0.
- `duplicate-owner.bend`: duplicating the real `F.Owned(First)` fails as consumed more than once.
- `cross-schema.bend`: actual `F.run` rejects an Other-schema World for a First-schema owner.
- `write-through-read.bend`: actual `O.define` rejects a read-only declaration where the body requests write capabilities.
- `undeclared.bend`: actual `O.define` rejects a filter-only declaration (Unit grant) where the body requests write operations.
- `abstract-owner-escape.bend`: an authored callback cannot return opaque H as a concrete World.

Every negative exits 1 at its intended type/affine boundary, with no parser error or deadline. `CHECKS.json`, the two batch records, full stdout/stderr and `SOURCE-PINS.json` bind the exact fixtures, imported bodies, pinned checker, selected compiler and Base. Checks ran in two coordinated batches of four and two with the existing 5-second cap and OS affinity 0–11. These are finite static authority controls; ordinary runtime semantics, foreign-world refusal and full query traces are separate evidence.
