# Approved comparison proof: contextual dependency inventory

Approval: `docs/reviews/delegated-owned-law-approval.md` at master `8e149fd`.
The selected exact `u32_comparison_agrees_nat` block is unchanged from
`experiments/p-observe/ARITHMETIC-PROPOSED.bend`, SHA256
`7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937`.
Before execution, the local dependencies are: the four Bool low-bit parity cases
relating comparison of doubled/successor Nat values to `Word.cmp.fin`; structural
Word-width comparison versus conversion for every pair; and the actual U32/B.less
boundary. No support catalogue assumption, unary MAX expansion or new dependency.
Installed Base, guide and existing p-owned-arithmetic were read; no installed
mathlib `PUBLIC_API.lock` exists in the inspected Bend/repository locations.
Checker and kernel each use the existing five-second wrapper. Acceptance requires
an exact unchanged theorem, compiling reversed B.less mutant failing in that
section, original complete-law witness, and a control proving the kernel ran.
