# Seven approved endpoints — aggregate proof gate

This package selects exactly the seven approved #18 statements from the unchanged
31-law source at SHA256 `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
`subjects.json` records every exact statement and the canonical import closure.
No remaining catalogue law is imported or promoted as an approved contract.

`PROOF.bend` delegates the completed total lookup to its independently checked
proof package. Other endpoints remain open until their real proofs land. Import
both the lookup law and its filling proof: Bend does not expose an imported law
through a nested `P.L` alias. The attempted nested name was rejected; the direct
law import works and exposes the actual remaining six TODOs.

Run `python3 experiments/p-observe/verify.py`. It verifies frozen subjects and exact
selection, then checks the aggregate proof with the normal checker and BendTT
kernel under the existing five-second wrapper. **Incomplete proof returns exit 1**;
a successful partial worker runner cannot make this full proof gate green.
Current result is six TODOs, not completion. `evidence.json` preserves diagnostics.

Even a future aggregate proof pass will require the separately specified per-law
compiling mutations, original true-domain controls, independent review and #18
acceptance audit. This gate is not a substitute for those requirements and says
nothing about #19 integration, runtime/backend correctness or performance.
