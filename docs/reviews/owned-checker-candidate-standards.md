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

## Hardening resolution — `d24cf49` (2026-10-04)

**All three frozen-revision findings resolved.** Independently replayed the frozen
commit from a temporary archive: exit0, all twenty-one checker matrix outcomes,
seven direct comparator cases on each source variant, and the forced false-kernel
control passed. Root evidence/source references/installations were untouched.

Each child starts a task-owned session; its complete invocation has a five-second
deadline, with process-group SIGKILL and output collection on timeout. Diagnostic
gates now require baseline stack-failure signals and intended false/affine/nominal/
hole/unsafe reasons, including exact false-equality and nominal fixture names.
Accepted candidates require explicit kernel success; the false backend control
first establishes checker acceptance, then rejects at the kernel. A timeout or
unrelated failure cannot satisfy a positive gate.

Enforced pins cover exact source revision, checker and safe modules, source and
installed Base (identical hash), source/installed kernel sources, installed binary,
actual existing kernel executable, patch, comparator and every fixture. The patch
bytes are also mechanically compared with the generated complete rigid-retry diff.
The harness rejects holes and non-Base unsafe/foreign definitions before accepting
proofs; its Base-only exception permits existing trusted intrinsic definitions,
while every accepted closure still passes the unchanged independent kernel.
No new dependency, compiler installation, reference edit or production tool change
is introduced. Existing mode, binder quantity/depth and label cases remain active.

**No new hard violations or actionable smells found.** The source2.0.35/installed
binary2.0.34 distinction remains explicit. This resolves diagnostic reproducibility
and cleanup findings; these bounded controls do not establish broad compiler
regression coverage or full owned proof acceptance, which require separately frozen
packages and review.
