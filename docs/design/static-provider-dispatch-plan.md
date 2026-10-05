# Static provider dispatch — draft

**Draft for discussion. File edit scope is approved; production API and a replacement measured contract remain unapproved.** Parent: [#23](https://github.com/dearlordylord/bendvy/issues/23). Follow-up discussion ticket: [#24](https://github.com/dearlordylord/bendvy/issues/24). Evidence: [prototype](../research/static-provider-dispatch/README.md).

The prototype replaces per-row curried providers with closed template arguments while keeping an abstract affine `Owner: Type`. Its tested live callback chain contains no provider `run_clo` constructions; the old chain constructs ten. This is code-generation evidence, not measured speedup.

Proposed next slice:

1. Validate the callback boundary: arbitrary affine owners, public-constructor/raw-setter confinement, cross-schema rejection and declared read/write authority. Validate the corrected erased-provider callback type with independently authored callbacks and normal library registration; the miniature two-callback result does not approve a production interface.
2. Freeze the source and adapt controls to the actual static consumer. Run all 22 fresh connected gates, including nested suppressed-owner, rollback, mark/inverse order and handles from two actual runtime-created worlds. Timeouts never count as negative-control success. Resolve the five-second full-entry checking limit before claiming that gate.
3. Measure equivalent Dense256 work on both schemas with B64/full65 records. Keep JS/TS ≤1.00, Native/TS ≤0.50, Native O3/one worker/GPU off, two noise-qualification repeats and the existing conservative comparator. Scope or method changes require a reviewed contract before evaluation.

Approved file edit scope (2026-10-05, user: “да любые файлы меняй”): project files may be changed as needed; the previous 13/17-path whitelist is removed. The current prototype happens to change 17 backend-specific Bend paths; that count is an inventory, not a restriction or feature limit. The eight existing held-adapter callback type headers gain erased provider binders; their bodies stay unchanged. The initial19-path named-row proposal is superseded. Preserve original callback blocks and catalogue the new callback contract explicitly. Supporting control/materialization changes must have an exact reviewed diff; they cannot silently weaken the gates. No compiler/kernel/dependency changes or Data-only restriction.

Outstanding decisions: reusable library registration for named templates; exact source/check freeze; full-entry checker execution; support for independent user callbacks. Passing a finite prototype does not settle these decisions or prove universal runtime refinement.

Budget remains global15/20 attempts consumed. A new segment does not reset that count or grant another time window. The current two-hour allowance ends2026-10-05T18:55:07Z. Two repeated evaluator gate failures stopped the old measured loop; this draft does not bypass that stop.

Follow-ups remain explicit: full five-family/three-size performance matrix in #21, production API selection, approved-law proofs and copied Tower Defense integration. Targets and core scope remain unchanged.
