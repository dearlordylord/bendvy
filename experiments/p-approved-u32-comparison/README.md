# Approved universal U32 comparison

`PROOF.bend` proves the exact approved `u32_comparison_agrees_nat` for every pair
of U32 values against the original `B.less` bridge. Approval is pinned to master
`8e149fd`, `docs/reviews/delegated-owned-law-approval.md`; the extracted law block
is byte-checked against the unchanged proposal (hash in `PLAN.md`). No other
catalogue endpoint is proved here.

`structural.bend` proves full `Word.cmp`/`Nat.cmp` correspondence for every width
and pair. Four recursive low-bit parity lemmas lift tail comparisons through
`Nat.double` and `Word.cmp.fin`. Instantiating width 32 and projecting `Cmp.is_lt`
proves the public law. This is structural induction, without finite enumeration,
MAX expansion, unchecked holes or imported comparison assumptions.

Run from the repository root:

```sh
python3 experiments/p-approved-u32-comparison/run.py
```

Fresh results: original structural toolkit, endpoint and complete-law `0 < 1`
witness pass both checker and independent kernel. A temporary bridge reverses
`U32.is_lt(left,right)` to `U32.is_lt(right,left)`: it compiles, the unchanged
structural toolkit still passes kernel, and the original witness and unchanged
endpoint fail at `true_instance` and `Laws.u32_comparison_agrees_nat` respectively.
The mutant is rejected by the checker; no independent kernel rejection is claimed.
Separately, forcing `BENDTT=/usr/bin/false` makes the originally accepted endpoint
fail the requested kernel gate, confirming the gate does invoke BendTT.

Every Bend invocation uses the existing five-second wrapper; the subprocess
watchdog does not extend that limit. `evidence.json` records exact output, source
hashes, frozen bridge/compiler/Base/approval hashes and reference commits.
Installed compiler is 2.0.34; pinned source reference is recorded separately.
No dependencies, original subjects or source references changed.

Reusable contextual signature: `word_cmp(width,left,right)` returns full Cmp
equality; projection through `Cmp.is_eq` can support equality reflection in the
separately approved owned-runtime correspondence proof. Increment, that owned
endpoint, integration and performance gates belong to their separate packages.
