# Seven approved endpoints — aggregate proof gate

This package selects the seven approved #18 IDs from the unchanged
31-law source at SHA256 `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
`subjects.json` preserves every original exact block and the canonical import closure, and separately records the delegated approval of the sole live-affine owned binder amendment and two supporting arithmetic statements. The selected owned statement matches the exact frozen proposal; its predicate/equality/domain are unchanged. [Astra decision](../../docs/reviews/delegated-owned-law-approval.md) supplies explicit user-delegated authorization.
The remaining 22 catalogue candidates stay unapproved. Original proposal files remain immutable historical snapshots, including their old UNAPPROVED comments.

`PROOF.bend` delegates the completed total lookup, three queries, explicit flush and pure schedule to its independently checked
proof package. Other endpoints remain open until their real proofs land. Import
both the lookup law and its filling proof: Bend does not expose an imported law
through a nested `P.L` alias. The attempted nested name was rejected; the direct
law import works and exposes the actual remaining TODOs.

Run `python3 experiments/p-observe/verify.py`. It verifies frozen subjects and exact
selection, then checks the aggregate proof with the normal checker and BendTT
kernel under the existing five-second wrapper. **Incomplete proof returns exit 1**;
a successful partial worker runner cannot make this full proof gate green.
Current result is one TODO, not completion. `evidence.json` preserves diagnostics.

Even a future aggregate proof pass will require the separately specified per-law
compiling mutations, original true-domain controls, independent review and #18
acceptance audit. This gate is not a substitute for those requirements and says
nothing about #19 integration, runtime/backend correctness or performance.
