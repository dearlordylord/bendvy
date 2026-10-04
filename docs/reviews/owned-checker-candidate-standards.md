# Owned checker candidate — Standards review

## Frozen diagnostic `73a45fc` + `1be5a1c` (2026-10-04)

Reviewed the isolated patch, runner, fixtures, evidence and existing comparison/
kernel implementation. Independently replayed `1be5a1c` from a temporary archive:
all fifteen matrix outcomes matched, runner exit0; root artifacts were untouched.
Pinned-source Base and installed Base currently have identical bytes. The patch
calls the complete existing rigid comparison with unchanged mode/depth/arguments,
and prevents retry recursion; it does not accept matching heads alone. Original
quantity, nominal and directional comparison rules remain in that relation.

**Hard findings:**

- **Medium — timeout cleanup:** `subprocess.run(timeout=5)` kills its direct
  process, but candidate Node can spawn the kernel. No owned process group is
  established/killed, so descendants can outlive the deadline. README's cleanup
  claim is stronger than this implementation. Use a new process session and
  group cleanup on timeout, including collected diagnostics.
- **Medium — diagnostic gates:** negative cases require only exit1, and original
  positive-case failures also require only exit1. Unrelated import/runtime/kernel
  failure can satisfy an intended affine/nominal/false-equality or stack-overflow
  rejection. Require the actual fixture location and corresponding diagnostic,
  and require the baseline stack-overflow signal; add an explicit false-kernel
  control for accepted candidates.
- **Low — provenance completeness:** hashes are freshly recorded rather than
  asserted against a frozen inventory. Source `safe.ts` and copied Base are not
  hashed; same-Base equality and exact expected source/kernel/fixture bytes are
  not runner-enforced. Pin these inputs and assert them before execution.

The accepted positives genuinely invoke the pre-existing installed BendTT through
candidate `safe_check`; no kernel/source reference/global installation changes
occur. Candidate source2.0.35 versus installed binary2.0.34 is accurately disclosed,
and executable strings are not claimed to recover authoritative source. Patch
construction writes only task-local output and temporary copied compiler modules.

**Heuristic findings: none actionable.** This is a bounded optimization diagnostic,
not adoption, broad compiler validation or full owned endpoint acceptance. Wider
regressions and exact adopted tool provenance remain necessary. Findings above
apply to the frozen revision; followup hardening must be reviewed separately.
