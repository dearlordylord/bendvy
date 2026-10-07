# #34 metadata laws — DRAFT, awaiting human approval

These five statements are proposed contracts, not approved laws or proofs.
Bend 2.0.35 checks their declarations/specification and reports exactly five
unfilled TODOs. No PROOF.bend or proof definition was written.

- Category identity: numeric IDs are equal only within the same category.
- Stable first-occurrence union: retain the first occurrence of each category/ID
  key in authored order. This ordered union is intentionally not commutative.
- Flatten: left authored branch before right, preserving systems, conditions,
  phases and barriers; Empty contributes no step.
- Authored requirements: every leaf contributes its entire declared list,
  including condition requirements even when that condition later returns false.
- Complete missing list: remove every granted category/ID from the input needs,
  retaining the order and multiplicity of all ungranted input items. The build
  path deduplicates needs; the raw missing helper must not silently deduplicate.

`spec.bend` is an independent executable specification: disjoint textual keys,
right-fold union that removes matching keys from the suffix, suffix-based tree
traversal, and grants-first subtraction. It does not call the production identity,
union, flatten or missing helpers. Textual U32 encoding is an explicit spec
choice; a future proof would need its injectivity or a reviewed structural key
specification. No new arithmetic fact is approved here.

`python3 docs/laws/nested-provision-draft/run.py` reproduces the finite evidence.
The guarded copied import closure is recorded in `evidence/receipt.json`.
There are eleven complete actual/spec literal comparisons on each backend:
empty input, duplicate same-category IDs, equal IDs across categories, ID zero,
maximum U32, duplicate grants, no grants, complete grants, nested empty branches,
phase/barrier order and leaf requirement retention. The actual-core omitted-leaf
mutant is reached and disagrees on requirements on both JS and Native. The
actual-core precheck-bypass mutant intentionally survives these pure metadata
checks: it changes execution, not any metadata function. Existing #34 application
controls independently detect it; their pass is not this draft's proof.

Commands retain checker5/emit30/Clang120/runtime5 caps. The expected nonzero law
check is recorded, not reported as a successful proof. The executable literal
fixture checks and runs successfully. There are no timings or dependency changes.
The runner freezes project imports and its own source; installed Base/compiler
are the current environment, not independently versioned by this small runner.

Approval is still required before any proof work. These statements do not prove
World owner preservation, callback truthfulness, no partial execution, namespace
or registry compatibility, arbitrary affine Type refinement, host rollback,
reader lifecycle or performance. Data metadata equality must not be presented as
universal Type-owner refinement. No ambiguous runtime policy has been added.

The strengthened replay is `evidence-final/receipt.json`; original `evidence/`
remains historical. Reproduction defaults to a fresh timestamped `.artifacts/`
directory; `--output PATH` selects a new explicit directory. Live project inputs
and copied inputs are checked before and after every command.

Each proposed law now has a reached, compiling actual-core mutation on both
backends: `category-equality` flips cross-category identity (`identity-cross`),
`union-order` reverses the stable union (`union`), `flatten-order` swaps authored
branches (`flatten`), `omitted-requirement` drops leaf needs (`requirements`), and
`missing-omission` drops ungranted items (`missing`). The receipt records exact
changed source hashes and every observed mismatch, including secondary effects
of category corruption. `precheck-bypass` remains an explicit execution gap.
