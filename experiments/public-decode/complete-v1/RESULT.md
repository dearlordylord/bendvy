# Development result

Complete automatic-budget decoding matches the independent eight-case oracle
on actual JS and Native, including every original Raw field, canonical output,
error path/actual value and affine sentinel. Their whole 79,545-byte stdout is
identical: SHA256 `917231359d590da45bf7de1bb02fab2b2dcdc42bbac801c7ec6fb15315e407cd`.
The independent complete oracle is `13607718be581d8b76de1db1cc0e6439e0c60a7f5641a9dfd1eb4f7578cc83c2`.

The fixed128 sibling rejects valid 128/256-element arrays and reports fuel
exhaustion instead of the late item error. Its entire eight-case output matches
the corrected independent bounded oracle `09983234541bba0c32b230bfca75f63a4ff2131068d97fdd21f3cb8be6f77be0`.
The 64-field struct is canonicalized correctly by the old decoder: `1n++more`
marks the predecessor reusable; it does not subtract two. The earlier bounded
oracle and original INCOMPLETE comparison receipt remain preserved.

A reached source mutant changes only the new `Size.budget` body to `128n`,
retaining the complete wrapper and projection callsite. Actual JS emit/run
succeed; the complete oracle rejects it and the **entire** mutant observation
matches the independently modeled fixed128 counterpart, including all owners.
Owner duplication is rejected at the intended affine binder by the unchanged
five-second checker. A comparator-only omitted-sentinel control is also refused;
it is separate from the actual compiling semantic mutant.

The first JS collector had an incorrect local constructor-path join. The old
helper and failed receipt remain intact; a corrected helper reconciles retained
raw outputs without rerunning the backend. Native and the targeted mutant then
ran with their own guarded plans/receipts. No private environment contents or
generated binaries should be committed in the evidence supplement.

These are direct development observations, not full installed-tool/resolver or
portable delivery qualification, an approved universal law, a generic Raw-to-Type
inverse or performance acceptance. Public API adoption, task-specific full
controls/delivery and required regression/equivalent-work performance gates
remain open under #46 and its consuming tasks. No unchanged source/backend
checks or comparative timing were repeated to repair the helper/oracle mistakes.
